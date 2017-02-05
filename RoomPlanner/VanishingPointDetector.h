//
//  VanishingPointDetector.h
//  RoomPlanner
//
//  Created by Tobias Scheck on 05.02.17.
//  Copyright © 2017 AR. All rights reserved.
//

#ifndef VanishingPointDetector_h
#define VanishingPointDetector_h
#import "HoughClassifier.h"

@interface VanishingPointDetector : NSObject
@property NSMutableArray<NSMutableArray<HoughLine *> *>* classifiedHoughLines;
@property NSArray *vanishingPoints;

-(id) initWithHoughLines: (NSArray *) lines;
-(void) intersectionLookup;
-(CGPoint) findIntersectionBetweenLine1: (HoughLine *) v1 andLine2: (HoughLine *) v2;

@end
#endif /* VanishingPointDetector_h */
