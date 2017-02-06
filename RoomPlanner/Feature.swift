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
    private var vanishingPoints: [GLPoint3]
    var vao  = [GLuint(), GLuint()]
    var vbo = [GLuint(), GLuint()]
    var vboPoint = GLuint()
    var posid = GLuint()
    var typeid = GLuint()
    var program : GLuint?
    var pointProgram: GLuint?
    
    init (edges: [HoughLine], andVanishingPoint p: [CGPoint]) {
        self.points = [GLPoint3]()
        self.colors = [GLKVector4]()
        
        self.vanishingPoints = []
        
        for point in p {
            self.vanishingPoints.append(GLPoint3(x: GLfloat(point.x), y: GLfloat(point.y), z: 0))
        }
        
        
        
        let c = [
            GLKVector4(v: (1, 0, 0, 1)),
            GLKVector4(v: (0, 1, 0, 1)),
            GLKVector4(v: (0, 0, 1, 1))
        ];
        for edge in edges {
            points.append(GLPoint3(x: GLfloat(edge.p1.x), y: GLfloat(edge.p1.y), z: 0))
            points.append(GLPoint3(x: GLfloat(edge.p2.x), y: GLfloat(edge.p2.y), z: 0))
            colors.append(c[Int(edge.type.rawValue)])
            colors.append(c[Int(edge.type.rawValue)])
        }
        self.modelPosition = Mat4.Identity()
        self.program = GLHelper.linkProgram(vertexShader: "feature.vsh", fragmentShader: "feature.fsh")
        self.pointProgram = GLHelper.linkProgram(vertexShader: "vanshing.vsh", fragmentShader: "feature.fsh")
        self.posid = GLuint(glGetAttribLocation(program!, "position"))
        self.typeid = GLuint(glGetAttribLocation(program!, "colors"))
        
        createData()
    }
    
    deinit {
        glDeleteBuffers(1, &vbo)
        glDeleteVertexArrays(3, &vao)
    }
    
    func createData() {
        glGenVertexArrays(2, &vao)
        glBindVertexArray(vao[0])
        
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
        
        glBindVertexArray(vao[1])
        
        let pos = GLuint(glGetAttribLocation(self.pointProgram!, "position"))
        glGenBuffers(2, &self.vboPoint)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vboPoint)
        glBufferData(GLenum(GL_ARRAY_BUFFER),  vanishingPoints.size(), vanishingPoints, GLenum(GL_STATIC_DRAW))
        glEnableVertexAttribArray(pos)
        glVertexAttribPointer(pos, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLPoint3>.size), nil)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArray(0)
    }
    
    internal func render(projection: Mat4, view: Mat4) {
        glUseProgram(self.program!)
        let mvp = Mat4.Zero()
        view.multiply(with: modelPosition, andOutputTo: mvp)
        projection.multiply(with: mvp, andOutputTo: mvp)
        
        glUniformMatrix4fv(GLint(glGetUniformLocation(program!, "mvp")), 1, GLboolean(GL_FALSE), mvp)
        
        glBindVertexArray(vao[0])
        glDrawArrays(GLenum(GL_LINES), 0, GLsizei(self.points.count) / 2)
        glBindVertexArray(0)
        
        glUseProgram(self.pointProgram!)
        glUniformMatrix4fv(GLint(glGetUniformLocation(pointProgram!, "mvp")), 1, GLboolean(GL_FALSE), mvp)
        glBindVertexArray(vao[1])
        glDrawArrays(GLenum(GL_POINTS), 0, GLsizei(self.vanishingPoints.count))
        glBindVertexArray(0)
        glUseProgram(0)
    }
    
    
}
