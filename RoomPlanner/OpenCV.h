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

typedef struct HoughLine {
    float angle;
    CGPoint p1;
    CGPoint p2;
} HoughLine;

+(void) bindContext:(EAGLContext*) ctx withTextureID:(GLuint) tid;
+(UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;
+(NSArray *) cornerHarrisDetection:(UIImage *)src blocksize:(int)bs ksize:(int)ksize k:(float)k;
+(NSArray *) cannyCornerDetection:(UIImage *)src thres_1:(int)t1 thres_2:(int)t2;
+(NSArray *) detectFeatures:(UIImage *) src;
//+(UIImage *) greyScaleFromImage: (UIImage *) image;

@end

@interface NSValue (HoughLine)
+ (instancetype)valuewithHoughLines:(HoughLine)value;
@property (readonly) HoughLine houghLinesValue;
@end

@implementation NSValue (HoughLine)
+ (instancetype)valuewithHoughLines:(HoughLine)value
{
    return [self valueWithBytes:&value objCType:@encode(HoughLine *)];
}
- (HoughLine) houghLinesValue
{
    HoughLine value;
    [self getValue:&value];
    return value;
}
@end
