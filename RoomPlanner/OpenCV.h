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
#import "HoughClassifier.h"


@interface OpenCV : NSObject

+(void) bindContext:(EAGLContext*) ctx withTextureID:(GLuint) tid;
+(UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;
+(NSArray *) cornerHarrisDetection:(UIImage *)src blocksize:(int)bs ksize:(int)ksize k:(float)k;
+(NSArray *) cannyCornerDetection:(UIImage *)src thres_1:(int)t1 thres_2:(int)t2;
+(NSMutableDictionary *) detectFeatures:(UIImage *) src andDraw: (bool) draw;
//+(UIImage *) greyScaleFromImage: (UIImage *) image;

@end

