//
//  VanishingPointDetector.m
//  RoomPlanner
//
//  Created by Tobias Scheck on 05.02.17.
//  Copyright © 2017 AR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VanishingPointDetector.h"

#define RADIANS_TO_DEGREES(radians) (radians * 180.0 / M_PI)


@implementation VanishingPointDetector
-(id)initWithHoughLines:(NSArray *)lines {
    self = [super init];
    if (self != nil) {
        self.classifiedHoughLines = [NSMutableArray new];
        for (int i = 0; i < 3; i++) {
            NSMutableArray *arr = [NSMutableArray<HoughLine *> new];
            [self.classifiedHoughLines insertObject:arr atIndex:i];
        }
        
        for(HoughLine *line in lines) {
            [[self.classifiedHoughLines objectAtIndex:line.type] addObject:line];
        }
        
        [self intersectionLookup];
    }
    
    return self;
}

-(void)intersectionLookup {
    CGFloat w1 = 0.2;
    CGFloat w2 = 0.8;
    CGFloat threashold = 5.0;
    CGFloat maxLine =  sqrt(pow(720, 2) + pow(1280, 2));
    
    NSMutableArray *vanishingPoints = [NSMutableArray new];
    for(int i = 0; i < 3; i++) {
        [vanishingPoints insertObject:[NSNull null] atIndex:i];
        NSMutableDictionary<NSString *, NSNumber *> *intersections = [NSMutableDictionary new];
        NSMutableArray *lines = [self.classifiedHoughLines objectAtIndex:i];
        int idx = 0;
        for(HoughLine *lineA in lines) {
            NSArray *toSearch = [lines subarrayWithRange:NSMakeRange(idx, lines.count - idx)];
            idx++;
            
            for (HoughLine *lineB in toSearch) {
                CGPoint p = [VanishingPointDetector findIntersectionBetweenLine1:lineA andLine2:lineB];
                
                if ( p.x != -1 && p.y != -1) {
                    CGFloat dx = p.x - lineA.p1.x;
                    CGFloat dy = p.y - lineA.p1.y;
                    
                    CGFloat cross = dx * lineA.line.y - dy * lineA.line.x;
                    if(cross == 0 )
                        continue;
                    
                    NSString *key = [NSString stringWithFormat:@"%d, %d", (int)p.x, (int)p.y];
                    if([intersections objectForKey:key] == nil)
                        [intersections setObject:[NSNumber numberWithDouble:0.0] forKey:key];
                    
                    
                    CGPoint midA = [lineA mid];
                    CGPoint midB = [lineB mid];
                    dx = midA.x - midB.x;
                    dy = midA.y - midB.y;
                    CGFloat angle = RADIANS_TO_DEGREES(atan2(dy, dx));
                    
                    double v = [[intersections objectForKey:key] doubleValue];
                    v += w1 * (1 - (angle / threashold)) + w2 * (lineB.weight / maxLine);
                    [intersections setObject:[NSNumber numberWithDouble:v] forKey:key];
                }
                    
            }
            
        }
        
        if(intersections.count > 0) {
            double best = DBL_MIN;
            for( NSString *key in intersections) {
                NSArray *p = [key componentsSeparatedByString:@","];
                CGPoint vanishingPoint = CGPointMake([p[0] doubleValue], [p[1] doubleValue]);
                
                double val = [[intersections objectForKey:key] doubleValue];
                if ( val > best) {
                    [vanishingPoints replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:vanishingPoint]];
                    
                    best = val;
                }
                
            }
        }
    }
    
    self.vanishingPoints = vanishingPoints;
    
    NSLog(@"VanishingPoint %@", vanishingPoints);
}

+(CGPoint)findIntersectionBetweenLine1:(HoughLine *)v1 andLine2:(HoughLine*)v2 {
    CGFloat xA = v1.p1.x - v1.p2.x;
    CGFloat xB = v2.p1.x - v2.p2.x;
    CGFloat yA = v1.p1.y - v1.p2.y;
    CGFloat yB = v2.p1.y - v2.p2.y;
    
    CGFloat c = xA * yB - yA * xB;
    
    if (fabs(c) >= 0.01) {
        CGFloat a = v1.p1.x * v1.p2.y - v1.p1.y * v1.p2.x;
        CGFloat b = v2.p1.x * v2.p2.y - v2.p1.y * v2.p2.x;
        
        CGFloat x = (a * xB - b * xA) / c;
        CGFloat y = (a * yB - b * yA) / c;
        
        return CGPointMake((int)x, (int)y);
    }
    
    return CGPointMake(-1, -1);
}

@end
