//
//  Feature.swift
//  RoomPlanner
//
//  Created by Tobias Scheck on 20.11.16.
//  Copyright © 2016 AR. All rights reserved.
//

import Foundation
import GLMatrix
import GLKit
// simple class for feature visualization
class Feature: Renderable {
    internal var texture: GLuint?
    internal var modelPosition: Mat4
    private var points:[GLPoint3]
    private var colors:[GLKVector4]
    var vao  = GLuint()
    var vbo = [GLuint(), GLuint()]
    var posid = GLuint()
    var typeid = GLuint()
    var program : GLuint?
    
    init (edges: [HoughLine]) {
        self.points = [GLPoint3]()
        self.colors = [GLKVector4]()
        let c = [
            GLKVector4(v: (1, 0, 0, 1)),
            GLKVector4(v: (0, 1, 0, 1)),
            GLKVector4(v: (0, 0, 1, 1))
        ];
        for edge in edges {
            points.append(GLPoint3(x: GLfloat(edge.p1.x), y: GLfloat(edge.p1.y), z: 0))
            points.append(GLPoint3(x: GLfloat(edge.p2.x), y: GLfloat(edge.p2.y), z: 0))
            colors.append(c[Int(edge.type)])
            colors.append(c[Int(edge.type)])
        }
        self.modelPosition = Mat4.Identity()
        self.program = GLHelper.linkProgram(vertexShader: "feature.vsh", fragmentShader: "feature.fsh")
        self.posid = GLuint(glGetAttribLocation(program!, "position"))
        self.typeid = GLuint(glGetAttribLocation(program!, "colors"))
        
        createData()
    }
    
    deinit {
        glDeleteBuffers(1, &vbo)
        glDeleteVertexArrays(1, &vao)
    }
    
    func createData() {
        glGenVertexArrays(1, &vao)
        glBindVertexArray(vao)
        
        glGenBuffers(2, &vbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo[0])
        glBufferData(GLenum(GL_ARRAY_BUFFER),  points.size(), points, GLenum(GL_STATIC_DRAW))
        glEnableVertexAttribArray(posid)
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo[0])
        glVertexAttribPointer(posid, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLPoint3>.size), nil)
        
        
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo[1])
        glBufferData(GLenum(GL_ARRAY_BUFFER),  colors.size(), colors, GLenum(GL_STATIC_DRAW))
        glEnableVertexAttribArray(typeid)
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo[1])
        glVertexAttribPointer(typeid, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLKVector4>.size), nil)
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArray(0)
        
    }
    
    internal func render(projection: Mat4, view: Mat4) {
        glUseProgram(self.program!)
        let mvp = Mat4.Zero()
        view.multiply(with: modelPosition, andOutputTo: mvp)
        projection.multiply(with: mvp, andOutputTo: mvp)
        
        glUniformMatrix4fv(GLint(glGetUniformLocation(program!, "mvp")), 1, GLboolean(GL_FALSE), mvp)
        
        glBindVertexArray(vao)
        
//        for i in 0...GLsizei(self.points.count) / 2 {
//            glDrawArrays(GLenum(GL_LINES), i * 2, 2)
//        }
        glDrawArrays(GLenum(GL_LINES), 0, GLsizei(self.points.count) / 2)
        
        
        glBindVertexArray(0)
        glUseProgram(0)
    }
    
    
}
