//
//  RenderableObject.swift
//  RoomPlanner
//
//  Created by Tobias Scheck on 06.11.16.
//  Copyright © 2016 AR. All rights reserved.
//
import GLMatrix

protocol Renderable {
    var modelPosition:Mat4 { get set }
    func render()
}

class Plane: Renderable {
    internal var modelPosition: Mat4
    
    init(pos:Mat4) {
        self.modelPosition = pos
    }
    
    internal func render() {
        
    }

    

    
}
