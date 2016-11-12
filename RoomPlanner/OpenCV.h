//
//  OpenCV.h
//  RoomPlanner
//
//  Created by Michél Neumann on 07/11/2016.
//  Copyright © 2016 AR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCV : NSObject

+(NSString *) openCVVersion;
+(UIImage *) cornersWithCornerHarris: (UIImage *)src size:(int) block_size;
//+(UIImage *) cornersWithCanny;

@end
