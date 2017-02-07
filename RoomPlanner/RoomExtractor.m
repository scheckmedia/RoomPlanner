//
//  RoomExtractor.m
//  RoomPlanner
//
//  Created by Tobias Scheck on 07.02.17.
//  Copyright © 2017 AR. All rights reserved.
//

#import "RoomExtractor.h"
#import "HoughClassifier.h"
#import "VanishingPointDetector.h"

@implementation RoomSurface

@end

@implementation RoomExtractor
bool _found = false;
@synthesize _vanishingPoints;

-(id)initWithVanishingPoints:(NSArray *)points andHoughLines: (NSArray *) houghLines {
    
    self = [super init];
    if (self != nil) {
        self._vanishingPoints = points;
        self._houghLines = houghLines;
        self.surfaces = [NSMutableDictionary new];
        [self.surfaces setObject:[NSNull null] forKey:@"left_wall"];
        [self.surfaces setObject:[NSNull null] forKey:@"right_wall"];
        [self.surfaces setObject:[NSNull null] forKey:@"ceiling"];
        [self.surfaces setObject:[NSNull null] forKey:@"ground"];                         
    }
    
    return self;
}

-(bool)extractRoom{
    
    [self findFloor];    
    return _found;
}

-(void) findFloor {
    // find closest horizontal line to vanishing where y is smaller than vp y
    NSValue *val = (NSValue *) self._vanishingPoints[kDiagonal];
    CGPoint vp =  val.CGPointValue;
    
    float best = FLT_MAX;
    HoughLine *groundLine = nil;
    
    float distWeight = 0.2;
    float lineWeight = 0.8;
    
    for (HoughLine *line in self._houghLines[kHorizontal]) {
        CGPoint refPoint = line.p1.y < line.p2.y ? line.p1 : line.p2;
        
        if(refPoint.y < vp.y)
            continue;
        
        float dist = sqrt(pow(refPoint.x - vp.x, 2) + pow(refPoint.y - vp.y, 2));
        float weight = dist;// * distWeight - lineWeight * log(1 + line.weight);
        
        if(weight < best) {
            groundLine = line;
            best = weight;
        }
    }
    
    if(groundLine == nil)
        return;
    
    HoughLine *lineToLeft = nil;
    HoughLine *lineToRight = nil;
    
    float leftBest = FLT_MIN;
    float rightBest = FLT_MIN;
    
    for (HoughLine *line in self._houghLines[kDiagonal]) {
        CGPoint refPoint = line.p1.y > line.p2.y ? line.p1 : line.p2;
        
        if(refPoint.y < vp.y)
            continue;
        
        float dist = sqrt( pow(refPoint.x - vp.x, 2) + pow(refPoint.y - vp.y, 2));
        float weight = dist;
        
        if(refPoint.x < vp.x) {
            if(weight > leftBest) {
                lineToLeft = line;
                leftBest = weight;
            }
        } else {
            if(weight > rightBest) {
                lineToRight = line;
                rightBest = weight;
            }
            
        }
    }
    
    if( lineToLeft == nil || lineToRight == nil )
        return;
    
    CGPoint leftStart = [VanishingPointDetector findIntersectionBetweenLine1:groundLine andLine2:lineToLeft];
    CGPoint rightStart = [VanishingPointDetector findIntersectionBetweenLine1:groundLine andLine2:lineToRight];
    
    if((leftStart.x == -1 && leftStart.y == -1) || (rightStart.x == -1 && rightStart.y == -1))
        return;
    
    RoomSurface *ground = [RoomSurface new];
    ground.bottomLeft = leftStart;
    ground.bottomRight = rightStart;
    
    // extend lines (lineToleft and right) to end of image
    [lineToLeft extendByLength:10000.0 withPoint1:YES];
    [lineToRight extendByLength:10000.0 withPoint1:NO];
    ground.topLeft = lineToLeft.p1;
    ground.topRight = lineToRight.p2;
    [self.surfaces setValue:ground forKey:@"ground"];
    
    _found = true;
    
}

-(void) findCeiling {
    
}

@end
