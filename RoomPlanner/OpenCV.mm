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

@implementation OpenCV

+(NSString *) openCVVersion
{
    return [NSString stringWithFormat:@"OpenCV %s", CV_VERSION];
}

+(UIImage *) cornersWithCornerHarris:(UIImage *)src size:(int)block_size
{
    cv::Mat buffer, response;
 
    UIImageToMat(src, buffer);

    cvCornerHarris(&buffer, &response, block_size);
    
    return MatToUIImage(response);
}

@end
