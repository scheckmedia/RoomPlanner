//
//  OpenCV.h
//  RoomPlanner
//
//  Created by Michél Neumann on 07/11/2016.
//  Copyright © 2016 AR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface OpenCV : NSObject

+(UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;
+(UIImage *) greyScaleFromImage: (UIImage *) image;
+(NSArray *) cornerHarrisDetection:(UIImage *)src sobel_kernel:(int)k blocksize:(int)block_size;
//+(void) bindContext:(EAGLContext*) ctx withTextureID:(GLuint) tid;

@end
