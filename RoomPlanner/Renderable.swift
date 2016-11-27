//
//  RenderableObject.swift
//  RoomPlanner
//
//  Created by Tobias Scheck on 06.11.16.
//  Copyright © 2016 AR. All rights reserved.
//
import GLMatrix
import GLKit

protocol Renderable {
    var modelPosition:Mat4 { get set }
    var texture:GLuint? { get set }
    func render(projection: Mat4, view:Mat4)
}

struct Vertex {
    var position : (x: GLfloat, y: GLfloat, z: GLfloat)
    var uv : (x: GLfloat, y: GLfloat)
    var normal: (x: GLfloat, y: GLfloat, z: GLfloat)
}

