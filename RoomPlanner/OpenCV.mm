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

+(NSString *) openCVVersion
{
    return [NSString stringWithFormat:@"OpenCV %s", CV_VERSION];
}

+(UIImage *) cornerHarrisDetection:(UIImage *)src blocksize:(int)block_size
{
    cv::Mat buffer, response;
 
    UIImageToMat(src, buffer);

    cvCornerHarris(&buffer, &response, block_size);
    
    return MatToUIImage(response);
}

+(void) bindContext:(EAGLContext *)ctx withTextureID:(GLuint) tid
{
    if(ctx != NULL)
        glContext = ctx;
    
    textureId = tid;
    
    [EAGLContext setCurrentContext: glContext];
    glBindTexture(GL_TEXTURE_2D, textureId);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 1280, 720, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glBindTexture(GL_TEXTURE_2D, 0);
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
        cv::Mat imageMat;
        UIImageToMat(image, imageMat);
        [EAGLContext setCurrentContext: glContext];
        glBindTexture(GL_TEXTURE_2D, textureId);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, imageMat.cols, imageMat.rows, GL_RGBA, GL_UNSIGNED_BYTE, imageMat.ptr());
        glBindTexture(GL_TEXTURE_2D, 0);
    }
    
    
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

+(UIImage *) greyScaleFromImage:(UIImage *)image
{
    cv::Mat imageMat, greyMat, outMat;
    
    UIImageToMat(image, imageMat);
    
    cv::cvtColor(imageMat, greyMat, CV_BGRA2GRAY);
    cv::transpose(greyMat, outMat);
    cv::flip(outMat, outMat, 1);
        
    
    return MatToUIImage(outMat);
}

@end
