//
//  RoomExtractor.h
//  RoomPlanner
//
//  Created by Tobias Scheck on 07.02.17.
//  Copyright © 2017 AR. All rights reserved.
//

#ifndef RoomExtractor_h
#define RoomExtractor_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RoomSurface : NSObject
@property CGPoint topLeft;
@property CGPoint topRight;
@property CGPoint bottomLeft;
@property CGPoint bottomRight;

@end

@interface RoomExtractor : NSObject

@property NSArray* _vanishingPoints;
@property NSArray* _houghLines;
@property NSMutableDictionary* surfaces;

-(id) initWithVanishingPoints: (NSArray *) points  andHoughLines: (NSArray *) houghLines ;
-(bool) extractRoom;

@end

#endif /* RoomExtractor_h */
