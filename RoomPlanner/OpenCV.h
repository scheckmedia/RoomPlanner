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

+(NSString *) openCVVersion;
+(UIImage *) greyScaleFromImage: (UIImage *) image;
+(UIImage *) cornerHarrisDetection: (UIImage *) src blocksize:(int) block_size;
+(UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;
+(void) bindContext:(EAGLContext*) ctx withTextureID:(GLuint) tid;

@end
