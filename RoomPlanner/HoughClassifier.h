//
//  HoughClassifier.h
//  RoomPlanner
//
//  Created by Tobias Scheck on 05.02.17.
//  Copyright © 2017 AR. All rights reserved.
//

#ifndef HoughClassifier_h
#define HoughClassifier_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    kHorizontal,
    kVertical,
    kDiagonal
} HoughLineType;

@interface HoughLine : NSObject
@property float angle;
@property CGPoint p1;
@property CGPoint p2;
@property CGPoint line;
@property CGFloat weight;
@property HoughLineType type;

-(id) initWithPoint1: (CGPoint) p1 andPoint2: (CGPoint) p2;
-(void) classify;
-(CGPoint) mid;
-(void)extendByLength:(float)length withPoint1:(bool) p1;
@end


#endif /* HoughClassifier_h */
