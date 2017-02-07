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
#import "VanishingPointDetector.h"
#import "RoomExtractor.h"

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
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 1280, 720, 0, GL_RGBA, GL_UNSIGNED_BYTE, nil);
    
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
    
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ref" ofType:@"jpg"];
//    image = [UIImage imageWithContentsOfFile:filePath];
    
    if(glContext != nil)
    {
        cv::Mat imageMat, outMat;
        
        UIImageToMat(image, imageMat);
        //cv::transpose(imageMat, outMat);
        //cv::flip(imageMat, outMat, 1);
        [EAGLContext setCurrentContext: glContext];
        glBindTexture(GL_TEXTURE_2D, textureId);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, imageMat.cols, imageMat.rows, GL_RGBA, GL_UNSIGNED_BYTE, imageMat.ptr());
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

+(NSMutableDictionary *)detectFeatures:(UIImage *)src andDraw:(bool)draw {
    if(!src)
        return [NSMutableDictionary new];
    
    cv::Mat org, source;
    UIImageToMat(src, org);
    cv::Mat cvt = [self toGreyScale:src];
    std::vector<cv::Vec4i> lines;
    
    //cv::flip(cvt, cvt, 1);
    //cv::flip(cvt, cvt, 0);
    
    
    cv::Mat dst = cv::Mat::zeros(cvt.size(), CV_32FC1);
    cv::Mat canny = cv::Mat::zeros(cvt.size(), CV_32FC1);
    // cv::equalizeHist(cvt, dst);
    cv::Canny(cvt, canny, 50, 200);
    cv::HoughLinesP(canny, lines, 1, M_PI / 180, 80, 30 , 10);
    NSMutableArray *houghLines = [NSMutableArray new];
    std::vector<cv::Scalar> colors = {
        cv::Scalar(255,0,0),
        cv::Scalar(0,255,0),
        cv::Scalar(0,0,255)
    };
    
    for (int i = 0; i < lines.size(); i++) {
        cv::Vec4i line = lines.at(i);
        
        
//        CGPoint p1 = CGPointMake(-0.5 + line[0] / src.size.width, -0.5 + line[1] / src.size.height);
//        CGPoint p2 = CGPointMake(-0.5 + line[2] / src.size.width, -0.5 + line[3] / src.size.height);
        CGPoint p1 = CGPointMake(line[0], line[1]);
        CGPoint p2 = CGPointMake(line[2], line[3]);
        
        HoughLine *e = [[HoughLine alloc] initWithPoint1:p1 andPoint2:p2];
        [houghLines addObject:e];
        
        cv::line( org, cv::Point(lines[i][0], lines[i][1]),
                 cv::Point(lines[i][2], lines[i][3]), colors[e.type], 2, CV_FILLED );
        
    }
    
    
    
    VanishingPointDetector *p = [[VanishingPointDetector alloc] initWithHoughLines:houghLines];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setValue:houghLines forKey:@"HoughLines"];
    [dict setValue:p.vanishingPoints forKey:@"VanishingPoints"];
    
    for(int i = 0; i < p.vanishingPoints.count; i++) {
        
        if(p.vanishingPoints[i] != [NSNull null]) {
            CGPoint point = ((NSValue *)p.vanishingPoints[i]).CGPointValue;
            cv::circle(org, cv::Point(point.x, point.y), 5, colors[i], CV_FILLED);
        }
    }
    
    NSMutableDictionary *surfaces = nil;
    if(p.vanishingPoints[kDiagonal] != [NSNull null]) {
        RoomExtractor *roomEx = [[RoomExtractor alloc] initWithVanishingPoints:p.vanishingPoints andHoughLines:p.classifiedHoughLines];
        [roomEx extractRoom];
        surfaces = roomEx.surfaces;
    }
    
    if(surfaces) {
        RoomSurface *ground = [surfaces objectForKey:@"ground"];
        if ([ground isKindOfClass:[RoomSurface class]]) {
            cv::Point surface[4];
            surface[0] = cv::Point(ground.topLeft.x, ground.topLeft.y);
            surface[1] = cv::Point(ground.bottomLeft.x, ground.bottomLeft.y);
            surface[2] = cv::Point(ground.bottomRight.x, ground.bottomRight.y);
            surface[3] = cv::Point(ground.topRight.x, ground.topRight.y);
            
            int n[] = {4};
            const cv::Point* points[1] = {surface};
            cv::fillPoly(org, points, n, 1, colors[2]);
            cv::circle(org, surface[0], 30, cv::Scalar(255,255,0));
            cv::circle(org, surface[1], 30, cv::Scalar(255,0,255));
            cv::circle(org, surface[2], 30, cv::Scalar(255,0,255));
            cv::circle(org, surface[3], 30, cv::Scalar(255,255,0));
            
        }
    
    }
    
    if(glContext != nil && draw)
    {
        cv::Mat outMat;
        //cv::transpose(org, outMat);
        //cv::flip(outMat, outMat, 1);
        [EAGLContext setCurrentContext: glContext];
        glBindTexture(GL_TEXTURE_2D, textureId);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, org.cols, org.rows, GL_RGBA, GL_UNSIGNED_BYTE, org.ptr());
        glFlush();
        
    }
    
    
    return dict;
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
