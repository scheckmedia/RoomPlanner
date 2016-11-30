//
//  Room.swift
//  RoomPlanner
//
//  Created by Tobias Scheck on 20.11.16.
//  Copyright © 2016 AR. All rights reserved.
//

import Foundation
import GLMatrix
import GLKit

class Room : Renderable{
    var modelPosition = Mat4.Identity()
    var texture:GLuint?
    var walls = [Plane]()
    var aspectRatio = GLfloat(1280.0 / 720.0)
    var f: Furniture?
    init(scale: Float) {
        let front = Plane(pos: .Identity())
        front.modelPosition.scale(by: Vec4(
            v: (aspectRatio, 1, 1, 1)))
        //walls.append(front)
        
        let furniturePos = Mat4.Identity()
        furniturePos.translate(by: Vec3(v: (0.0, -0.75, -2.0)))
        
        f = Furniture(pos: furniturePos, path: ModelObject.all()!.first?.value(forKey: "path") as! String)
//        let left = Plane(pos: .Identity())
//        left.modelPosition.rotateAroundY(byAngle: Float(90.0.degreesToRadians))
//        left.modelPosition.translate(by: Vec3(v:(-0.5,0,0)))
//        walls.append(left)
//    
//        let right = Plane(pos: .Identity())
//        right.modelPosition.rotateAroundY(byAngle: Float(-90.0.degreesToRadians))
//        right.modelPosition.translate(by: Vec3(v:(0.5,0,0)))
//        walls.append(right)
//        
        
    }
    
    public func updateTexture(id: GLuint) {
        self.texture = id
        for wall in walls {
            wall.texture = self.texture
        }
    }
    
    internal func render(projection: Mat4, view:Mat4) {
        for wall in walls {
            wall.render(projection: projection, view: view)
        }
        
        f?.render(projection: projection, view: view)
        
    }
    
    public func updateModel(path: String) {
        var oldPos = Mat4.Identity()
        
        if let old = f {
            oldPos = old.modelPosition
        }
        
        f = Furniture(pos: oldPos, path: path)
    }
    
}
