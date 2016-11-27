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
    let f: Furniture?
    init(scale: Float) {
        let front = Plane(pos: .Identity())
        front.modelPosition.scale(by: Vec4(
            v: (aspectRatio, 1, 1, 1)))
        //walls.append(front)
        
        f = Furniture(path: ModelObject.all()!.first?.value(forKey: "path") as! String)
        f!.modelPosition.scale(by: Vec4(v: (aspectRatio, 1, 1, 1)))
        f!.modelPosition.rotateAroundY(byAngle: Float(45.0).degreesToRadians)
        f!.modelPosition.translate(by: Vec3(v: (0.0, 0.0, -2.0)))
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
    
    func addWall(topLef tl:GLPoint3, topRight tr:GLPoint3, bl:GLPoint3, br:GLPoint3) {
//        let coords : [Vertex] = [
//            Vertex(position: (x:  tl.x, y:  tl.y, z: tl.z), uv: (x: 0.0, y: 1.0)),
//            Vertex(position: (x:  bl.x, y:  bl.y, z: bl.z), uv: (x: 1.0, y: 1.0)),
//            Vertex(position: (x:  br.x, y:  br.y, z: br.z), uv: (x: 1.0, y: 0.0)),
//            
//            Vertex(position: (x:  br.x, y:  br.y, z: br.z), uv: (x: 1.0, y: 0.0)),
//            Vertex(position: (x:  tr.x, y:  tr.y, z: tr.z), uv: (x: 0.0, y: 0.0)),
//            Vertex(position: (x:  tl.x, y:  tl.y, z: tl.z), uv: (x: 0.0, y: 1.0))
//        ]
//        
//        let p = Plane(pos: Mat4.Identity(), vertices: coords)
//        walls.append(p)
    }
    
}
