//
//  OpenCV.m
//  RoomPlanner
//
//  Created by Michél Neumann on 07/11/2016.
//  Copyright © 2016 AR. All rights reserved.
//

#import "OpenCV.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <GLKit/GLKit.h>

@implementation OpenCV

static EAGLContext *glContext = NULL;
static GLuint textureId;

+(void) bindContext:(EAGLContext *)ctx withTextureID:(GLuint) tid
{
    if(ctx != NULL)
        glContext = [[EAGLContext alloc]initWithAPI: kEAGLRenderingAPIOpenGLES2 sharegroup:ctx.sharegroup];
    
    textureId = tid;
    
    //create an empty texture and alloc memory
    [EAGLContext setCurrentContext: glContext];
    glBindTexture(GL_TEXTURE_2D, textureId);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 720, 1280, 0, GL_RGBA, GL_UNSIGNED_BYTE, nil);
    
    glFlush();
}

/*
    Source: https://developer.apple.com/library/content/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/06_MediaRepresentations.html#//apple_ref/doc/uid/TP40010188-CH2-SW4
*/
 +(UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);

    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    if(glContext != nil)
    {
        cv::Mat imageMat, outMat;
        
        UIImageToMat(image, imageMat);
        cv::transpose(imageMat, outMat);
        cv::flip(outMat, outMat, 1);
        [EAGLContext setCurrentContext: glContext];
        glBindTexture(GL_TEXTURE_2D, textureId);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, outMat.cols, outMat.rows, GL_RGBA, GL_UNSIGNED_BYTE, outMat.ptr());
        glFlush();
    }
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

/*+(UIImage *) greyScaleFromImage:(UIImage *)image
{
    return MatToUIImage([self toGreyScale:image]);
}*/

+(cv::Mat) toGreyScale:(UIImage *)image
{
    cv::Mat imageMat, greyMat, outMat;
    
    UIImageToMat(image, imageMat);
    
    cv::cvtColor(imageMat, greyMat, CV_BGRA2GRAY);
    cv::transpose(greyMat, outMat);
    cv::flip(outMat, outMat, 1);

    return greyMat;
}

+(NSArray *) cornerHarrisDetection:(UIImage *)src blocksize:(int)bs ksize:(int)ksize k:(float)k
{
    cv::Mat cvt = [self toGreyScale:src];
    cv::Mat dst = cv::Mat::zeros(cvt.size(), CV_32FC1);
    
    // Do the corner harris - biatch
    cv::cornerHarris(cvt, dst, bs, ksize, k, cv::BORDER_DEFAULT);

    return [self bundleDetectedData:dst];
}

+(NSArray *) cannyCornerDetection:(UIImage *)src thres_1:(int)t1 thres_2:(int)t2
{
    cv::Mat cvt = [self toGreyScale:src];
    cv::Mat dst = cv::Mat::zeros(cvt.size(), CV_32FC1);
    
    // Do the canny - biatch
    cv::Canny(cvt, dst, t1, t2);
    
    return [self bundleDetectedData:dst];
}

+(NSArray *)detectFeatures:(UIImage *)src {
    NSMutableArray *arr = [NSMutableArray array];
    
    if(!src)
        return arr;
    
    cv::Mat cvt = [self toGreyScale:src];
    std::vector<cv::Vec4i> lines;
    
    cv::flip(cvt, cvt, 1);
    //cv::flip(cvt, cvt, 0);
 
    cv::Mat dst = cv::Mat::zeros(cvt.size(), CV_32FC1);
    cv::Canny(cvt, dst, 30, 100);
    cv::HoughLinesP(dst, lines, 1, M_PI / 180, 80, 100, 10);
    
    std::map<float, int> angles;
    for (int i = 0; i < lines.size(); i++) {
        cv::Vec4i line = lines.at(i);
        
        HoughLine *e = [[HoughLine alloc] init];
        
        e.p1 = CGPointMake(-0.5 + line[0] / src.size.width, -0.5 + line[1] / src.size.height);
        e.p2 = CGPointMake(-0.5 + line[2] / src.size.width, -0.5 + line[3] / src.size.height);
        
        float dy = e.p2.y - e.p1.y;
        float dx = e.p2.x - e.p1.x;
        
        float angle = abs(atan2(dy, dx)  * 180 / M_PI);
        float delta = 5.0;
        float qangle = delta * floor((angle / delta) * 0.5);
        
        e.angle = angle;
        e.qAngle = qangle;
        
        if(angles.count(qangle) == false)
        {
            angles.insert(std::pair<float, int>(qangle, 0));
        }
        
        angles[qangle] += 1;
        
        [arr addObject:e];
    }
    
    int numberOfClusters = 3;
    if(angles.size() < numberOfClusters)
        return nil;
    
    std::vector<float> availableAngles;
    for(auto angle: angles)
        availableAngles.push_back(angle.first);
    
    cv::Mat clusteredAngles, bestLables;
    cv::TermCriteria criteria;
    criteria.type = cv::TermCriteria::Type::EPS + cv::TermCriteria::Type::MAX_ITER;
    criteria.maxCount = 30;
    criteria.epsilon = 1.0;
    cv::kmeans(cv::Mat(availableAngles, false), numberOfClusters, bestLables, criteria, 50, cv::KMEANS_PP_CENTERS, clusteredAngles);
    
    
    for(HoughLine *line in arr)
    {
        std::vector<float>::const_iterator it = std::find(availableAngles.begin(), availableAngles.end(), line.qAngle);
        if(it != availableAngles.end())
        {
            int idx = (int)(it - availableAngles.begin());
            line.type = bestLables.at<int>(0, idx);
            
            //NSLog(@"%@", line);
        }
    }
    
//    for (int i = 0; i < lines.size(); i++) {
//        cv::Vec4i line = lines.at(i);
//        
//        
//        
//        int dy = e.p2.y - e.p1.y;
//        int dx = e.p2.x - e.p1.x;
//        float rad = atan2(dy, dx);
//        float deg = rad * 180 / M_PI;
//        float bestAngle = 0;
//        
//        for(int j = 0; j < clusteredAngles.rows; j++)
//        {
//            float angle = clusteredAngles.at<float>(0, j);
//            float dist = (deg - angle) * (deg - angle);
//            if (dist < last)
//            {
//                bestAngle = angle;
//                last = dist;
//            }
//        }
//        
//        
//        // NSLog(@"HoughLine: %@", e);
//        
//    }
    
    return arr;
}

+(NSArray *) bundleDetectedData:(cv::Mat)dst
{
    NSMutableArray* res = [[NSMutableArray alloc] init];
    const int THRESHOLD = 150;
    cv::Mat dst_norm;
    
    cv::normalize(dst, dst_norm, 0, 255, cv::NORM_MINMAX, CV_32FC1, cv::Mat());
    // cv::transpose(dst_norm, dst_norm);
    cv::flip(dst_norm, dst_norm, 1);
    cv::flip(dst_norm, dst_norm, 0);
    
    // Iterate over image, push points after a determined threshold
    for(int y = 0; y < dst_norm.cols; y++)
    {
        for(int x = 0; x < dst_norm.rows; x++)
        {
            if((int) dst_norm.at<float>(x,y) > THRESHOLD)
            {
                [res addObject:[NSValue valueWithCGPoint:CGPointMake(-0.5 + x / static_cast<float>(dst_norm.rows),
                                                                      -0.5 + y / static_cast<float>(dst_norm.cols))]];
            }
        }
    }
    
    return res;
}

@end
