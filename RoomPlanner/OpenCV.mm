//
//  OpenCV.m
//  RoomPlanner
//
//  Created by Michél Neumann on 07/11/2016.
//  Copyright © 2016 AR. All rights reserved.
//

#import "OpenCV.h"
#import <opencv2/opencv.hpp>

@implementation OpenCV

+(NSString *) OpenCVVersion
{
    return [NSString stringWithFormat:@"OpenCV %s", CV_VERSION];

}

@end
