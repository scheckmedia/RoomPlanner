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
        float dx = self.p2.x - self.p1.x;
        float dy = self.p2.y - self.p1.y;
        
        self.weight = sqrt(pow(dx, 2) + pow(dy, 2));
    
        self.line = CGPointMake(dx, dy);
    
        double delta = 10.0;
        self.angle = atan2(dy / self.weight, dx / self.weight) * 180 / M_PI;
        self.angle = delta * floor((self.angle / delta) + 0.5);
        while(self.angle < 0)
            self.angle += 180.0;
    
        [self classify];
    }
    
    return self;

}

- (NSString*) description {
    return [NSString stringWithFormat: @"HoughLine: x1: %.2f y1: %.2f x2: %.2f y2: %.2f angle: %.2f and type %d", self.p1.x, self.p1.y, self.p2.x, self.p2.y, self.angle, self.type];
}

-(void) classify {
    if (self.angle == 0 || self.angle == 180) {
        self.type = kHorizontal;
    } else if(self.angle == 90 || self.angle == 270) {
        self.type = kVertical;
    } else {
        self.type = kDiagonal;
    }
}

-(CGPoint) mid {
    
        return CGPointMake((self.p1.x + self.p2.x) / 2.0, (self.p1.y + self.p2.y) / 2.0 );
}

-(void)extendByLength:(float)length withPoint1:(bool) p1{
    
    
    if(p1) {
        float x = self.p1.x + ( self.p1.x - self.p2.x ) / self.weight * length;
        float y = self.p1.y + ( self.p1.y - self.p2.y ) / self.weight * length;
        self.p1 = CGPointMake(x, y);
    } else {
        float x = self.p2.x + ( self.p2.x - self.p1.x ) / self.weight * length;
        float y = self.p2.y + ( self.p2.y - self.p1.y ) / self.weight * length;
        self.p2 = CGPointMake(x, y);
    }
        
    
}

@end

