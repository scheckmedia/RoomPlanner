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

@interface HoughLine : NSObject
@property float angle;
@property float qAngle;
@property int type;
@property CGPoint p1;
@property CGPoint p2;
@end

@implementation HoughLine
- (NSString*) description {
    return [NSString stringWithFormat: @"HoughLine: x1: %.2f y1: %.2f x2: %.2f y2: %.2f angle: %.2f and type %d", self.p1.x, self.p1.y, self.p2.x, self.p2.y, self.angle, self.type];
}
@end



@interface OpenCV : NSObject

+(void) bindContext:(EAGLContext*) ctx withTextureID:(GLuint) tid;
+(UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;
+(NSArray *) cornerHarrisDetection:(UIImage *)src blocksize:(int)bs ksize:(int)ksize k:(float)k;
+(NSArray *) cannyCornerDetection:(UIImage *)src thres_1:(int)t1 thres_2:(int)t2;
+(NSArray *) detectFeatures:(UIImage *) src;
//+(UIImage *) greyScaleFromImage: (UIImage *) image;

@end

