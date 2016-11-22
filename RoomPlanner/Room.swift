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
    
    init() {
        let front = Plane(pos: .Identity())
        
        let left = Plane(pos: .Identity())
        left.modelPosition.rotateAroundY(byAngle: Float(-90.0.degreesToRadians))
        
        let right = Plane(pos: .Identity())
        right.modelPosition.rotateAroundY(byAngle: Float(90.0.degreesToRadians))
        
        walls.append(contentsOf: [front, left, right])
        
    }
    
    public func updateTexture(id: GLuint) {
        for wall in walls {
            wall.texture = id
        }
    }
    
    internal func render(projection: Mat4, view:Mat4) {
        for wall in walls {
            wall.render(projection: projection, view: view)
        }
        
    }
    
    func addWall(topLef tl:GLPoint3, topRight tr:GLPoint3, bl:GLPoint3, br:GLPoint3) {
        let coords : [Vertex] = [
            Vertex(position: (x:  tl.x, y:  tl.y, z: tl.z), uv: (x: 0.0, y: 1.0)),
            Vertex(position: (x:  bl.x, y:  bl.y, z: bl.z), uv: (x: 1.0, y: 1.0)),
            Vertex(position: (x:  br.x, y:  br.y, z: br.z), uv: (x: 1.0, y: 0.0)),
            
            Vertex(position: (x:  br.x, y:  br.y, z: br.z), uv: (x: 1.0, y: 0.0)),
            Vertex(position: (x:  tr.x, y:  tr.y, z: tr.z), uv: (x: 0.0, y: 0.0)),
            Vertex(position: (x:  tl.x, y:  tl.y, z: tl.z), uv: (x: 0.0, y: 1.0))
        ]
        
        let p = Plane(pos: Mat4.Identity(), vertices: coords)
        walls.append(p)
    }
    
}
