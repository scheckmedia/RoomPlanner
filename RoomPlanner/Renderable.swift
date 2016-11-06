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
    var textureId:GLuint? { get set }
    func render()
}

struct Vertex {
    var position : (x: GLfloat, y: GLfloat, z: GLfloat)
    var uv : (x: GLfloat, y: GLfloat)
}

class Plane: Renderable {
    internal var modelPosition: Mat4
    internal var textureId: GLuint? = nil
    var vao  = GLuint()
    var vbo = GLuint()
    var program : GLuint?
    private let vertices : [Vertex] = [
            Vertex(position: (x: -0.5, y:  0.5, z: 0), uv: (x: 0.0, y: 1.0)),
            Vertex(position: (x:  0.5, y:  0.5, z: 0), uv: (x: 1.0, y: 1.0)),
            Vertex(position: (x:  0.5, y: -0.5, z: 0), uv: (x: 1.0, y: 1.0)),
            
            Vertex(position: (x:  0.5, y: -0.5, z: 0), uv: (x: 1.0, y: 0.0)),
            Vertex(position: (x: -0.5, y: -0.5, z: 0), uv: (x: 0.0, y: 0.0)),
            Vertex(position: (x: -0.5, y:  0.5, z: 0), uv: (x: 0.0, y: 1.0))
    ]
    
    init(pos:Mat4) {
        self.modelPosition = pos
        self.program = GLHelper.linkProgram(vertexShader: "plane.vsh", fragmentShader: "plane.fsh")
        
        glGenVertexArrays(1, &vao)
        glBindVertexArray(vao)
        
        glGenBuffers(1, &vbo)
    }
    
    deinit {
        glDeleteBuffers(1, &vbo)
        glDeleteVertexArrays(1, &vao)
    }
    
    private func createData() {
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER),  vertices.size(), vertices, GLenum(GL_STATIC_DRAW))
        
        
        glEnableVertexAttribArray(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), 0, nil)
        glVertexAttribPointer(1, 2, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), 0, BUFFER_OFFSET(n: 12))
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArray(0)
    }
    
    func BUFFER_OFFSET(n: Int) -> UnsafeRawPointer {
        let ptr: UnsafeRawPointer? = nil
        return ptr! + n
    }
    
    internal func render() {
        if self.program != nil {
            glUseProgram(self.program!)
        }
        
        glBindVertexArray(vao)
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 6)
        glBindVertexArray(0)
        
        glUseProgram(0)
    }

    

    
}
