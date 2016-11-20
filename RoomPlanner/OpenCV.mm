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

+(UIImage *) greyScaleFromImage:(UIImage *)image
{
    return MatToUIImage([self toGreyScale:image]);
}

+(cv::Mat) toGreyScale:(UIImage *)image
{
    cv::Mat imageMat, greyMat, outMat;
    
    UIImageToMat(image, imageMat);
    
    cv::cvtColor(imageMat, greyMat, CV_BGRA2GRAY);
    cv::transpose(greyMat, outMat);
    cv::flip(outMat, outMat, 1);

    return greyMat;
}

+(NSArray *) cornerHarrisDetection:(UIImage *)src sobel_kernel:(int)k blocksize:(int)block_size
{
    NSMutableArray* res = [[NSMutableArray alloc] init];
    const int THRESHOLD = 50;
    
    cv::Mat cvt = [self toGreyScale:src];
    cv::Mat dst = cv::Mat::zeros(cvt.size(), CV_32FC1);
    cv::Mat dst_norm;
    
    // Do the corner harris - biatch
    cv::cornerHarris(cvt, dst, block_size, k, 0.01, cv::BORDER_DEFAULT);
    cv::normalize(dst, dst_norm, 0, 255, cv::NORM_MINMAX, CV_32FC1, cv::Mat());

//    cv::transpose(dst_norm, dst_norm);
    cv::flip(dst_norm, dst_norm, 1);
    cv::flip(dst_norm, dst_norm, 0);
    
    // Iterate over image, push points after a determined threshold
    for(int y = 0; y < dst_norm.cols; y++)
    {
        for(int x = 0; x < dst_norm.rows; x++)
        {
            if((int) dst_norm.at<float>(x,y) > THRESHOLD) //Thres
            {
                [res addObject: [NSValue valueWithCGPoint:CGPointMake(-0.5 + x / static_cast<float>(dst_norm.rows),
                                                                      -0.5 + y / static_cast<float>(dst_norm.cols))]];
            }
        }
    }
    
    return res;
}


@end
