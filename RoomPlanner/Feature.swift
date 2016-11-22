//
//  Feature.swift
//  RoomPlanner
//
//  Created by Tobias Scheck on 20.11.16.
//  Copyright © 2016 AR. All rights reserved.
//

import Foundation
import GLMatrix

// simple class for feature visualization
class Feature: Renderable {
    internal var texture: GLuint?
    internal var modelPosition: Mat4
    private let points:[GLPoint3]?
    var vao  = GLuint()
    var vbo = GLuint()
    var posid = GLuint()
    var program : GLuint?
    var aspectRatio:Float = 1.0 {
        didSet {
            self.modelPosition.scale(by: Vec4(v: (aspectRatio, 1, 1, 0)))
        }
    }
    
    init (points: [GLPoint3]) {
        self.points = points
        self.modelPosition = Mat4.Identity()
        self.program = GLHelper.linkProgram(vertexShader: "feature.vsh", fragmentShader: "feature.fsh")
        self.posid = GLuint(glGetAttribLocation(program!, "position"))
        
        createData()
    }
    
    deinit {
        glDeleteBuffers(1, &vbo)
        glDeleteVertexArrays(1, &vao)
    }
    
    func createData() {
        glGenVertexArrays(1, &vao)
        glBindVertexArray(vao)
        
        glGenBuffers(1, &vbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER),  points!.size(), points!, GLenum(GL_STATIC_DRAW))
        
        glEnableVertexAttribArray(posid)
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        glVertexAttribPointer(posid, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLPoint3>.size), nil)
        
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
        glDrawArrays(GLenum(GL_POINTS), 0, GLsizei(self.points!.count))
        glBindVertexArray(0)
        glUseProgram(0)
    }
    
    
}
