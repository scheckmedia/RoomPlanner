//
//  HoughClassifier.m
//  RoomPlanner
//
//  Created by Tobias Scheck on 05.02.17.
//  Copyright © 2017 AR. All rights reserved.
//

#import "HoughClassifier.h"


@implementation HoughLine
-(id)initWithPoint1:(CGPoint)p1 andPoint2:(CGPoint)p2 {
    self = [super init];
    if (self != nil) {
        self.p1 = p1;
        self.p2 = p2;
        float dy = self.p2.y - self.p1.y;
        float dx = self.p2.x - self.p1.x;
        
        self.weight = sqrt(pow(dx, 2) + pow(dy, 2));
    
        self.line = CGVectorMake(dx, dy);
    
        double delta = 5.0;
        self.angle = atan2(dy, dx)  * 180 / M_PI;
        self.angle = delta * floor((self.angle / delta) * 0.5);
        if(self.angle < 0) self.angle += 180.0;
    
        [self classify];
    }
    
    return self;

}

- (NSString*) description {
    return [NSString stringWithFormat: @"HoughLine: x1: %.2f y1: %.2f x2: %.2f y2: %.2f angle: %.2f and type %d", self.p1.x, self.p1.y, self.p2.x, self.p2.y, self.angle, self.type];
}

-(void) classify {
    if (self.angle == 0 || self.angle == 180)
        self.type = kVertical;
    else if(self.angle == 90 || self.angle == 270)
        self.type = kHorizontal;
    else
        self.type = kDiagonal;
}

-(CGPoint) mid {
    
    return CGPointMake(self.p1.x + (self.line.dx / 2.0), self.p2.y / (self.line.dy / 2.0) );
}

@end

