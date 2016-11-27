//
//  Plane.swift
//  RoomPlanner
//
//  Created by Tobias Scheck on 20.11.16.
//  Copyright © 2016 AR. All rights reserved.
//

import Foundation
import GLMatrix
import GLKit

class Plane: Renderable {
    internal var modelPosition: Mat4
    public var texture: GLuint? = nil
    var vao  = GLuint()
    var vbo = GLuint()
    var program : GLuint?
    var posid: GLuint = GLuint()
    var uvid:GLuint = GLuint()
    var normalid:GLuint = GLuint()
    
    var vertices: [Vertex]? = nil
    
    private static let defaults : [Vertex] = [
        Vertex(position: (x: -0.5, y:  0.5, z: 0), uv: (x: 0.0, y: 1.0), normal: (0.0, 0.0, -0.5)),
        Vertex(position: (x:  0.5, y:  0.5, z: 0), uv: (x: 1.0, y: 1.0), normal: (0.0, 0.0, -0.5)),
        Vertex(position: (x:  0.5, y: -0.5, z: 0), uv: (x: 1.0, y: 0.0), normal: (0.0, 0.0, -0.5)),
        
        Vertex(position: (x:  0.5, y: -0.5, z: 0), uv: (x: 1.0, y: 0.0), normal: (0.0, 0.0, -0.5)),
        Vertex(position: (x: -0.5, y: -0.5, z: 0), uv: (x: 0.0, y: 0.0), normal: (0.0, 0.0, -0.5)),
        Vertex(position: (x: -0.5, y:  0.5, z: 0), uv: (x: 0.0, y: 1.0), normal: (0.0, 0.0, -0.5))
    ]
    
    init(pos:Mat4, vertices : [Vertex] ) {
        self.modelPosition = pos
        self.program = GLHelper.linkProgram(vertexShader: "plane.vsh", fragmentShader: "plane.fsh")
        self.posid = GLuint(glGetAttribLocation(program!, "position"))
        self.uvid = GLuint(glGetAttribLocation(program!, "uv_coord"))
        self.normalid = GLuint(glGetAttribLocation(program!, "normals"))
        self.vertices = vertices
        createData()
    }
    
    convenience init(pos:Mat4) {
        self.init(pos: pos, vertices: Plane.defaults)
    }
    
    deinit {
        glDeleteBuffers(1, &vbo)
        glDeleteVertexArrays(1, &vao)
    }
    
    private func createData() {
        glGenVertexArrays(1, &vao)
        glBindVertexArray(vao)
        
        glGenBuffers(1, &vbo)
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER),  vertices!.size(), vertices!, GLenum(GL_STATIC_DRAW))
        
        glEnableVertexAttribArray(posid)
        glEnableVertexAttribArray(uvid)
        glEnableVertexAttribArray(normalid)
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        glVertexAttribPointer(posid, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), nil)
        glVertexAttribPointer(uvid, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET(n: 3 * MemoryLayout<GLfloat>.size))
        glVertexAttribPointer(normalid, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET(n: 5 * MemoryLayout<GLfloat>.size))
        
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArray(0)
    }
    
    func BUFFER_OFFSET(n: Int) -> UnsafeRawPointer {
        return UnsafeRawPointer(bitPattern: n)!
    }
    
    internal func render(projection: Mat4, view: Mat4) {
        if self.program != nil {
            glUseProgram(self.program!)
        }
        
        let modelView = Mat4.Zero()
        let normalMatrix = Mat4.Zero()
        view.multiply(with: modelPosition, andOutputTo: modelView)
        modelView.invert(andOutputTo: normalMatrix)
        normalMatrix.transpose()
        
        glUniformMatrix4fv(GLint(glGetUniformLocation(program!, "projection")), 1, GLboolean(GL_FALSE), projection)
        glUniformMatrix4fv(GLint(glGetUniformLocation(program!, "model_view")), 1, GLboolean(GL_FALSE), modelView)
        glUniformMatrix4fv(GLint(glGetUniformLocation(program!, "normal_matrix")), 1, GLboolean(GL_FALSE), normalMatrix)
        
        if self.texture != nil {
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), self.texture!)
            glUniform1i(glGetUniformLocation(program!, "tex"), 0)
        }
        
        glBindVertexArray(vao)
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 6)
        glBindVertexArray(0)
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        glUseProgram(0)
    }
    
    
    public func setTexture(textureFile: String) {
        do {
            let tex = try GLKTextureLoader.texture(withContentsOfFile: textureFile, options: nil)
            self.texture = tex.name
            glBindTexture(tex.target, self.texture!)
        } catch _ {
            
        }
    }
    
    
    public func setTexture(withImage image:UIImage) {
        if(self.texture == nil) {
            self.texture = 0
            glGenTextures(1, &self.texture!)
        }
        
        
        let imgRef = image.cgImage!
        let width = size_t(image.size.width)
        let height = size_t(image.size.height)
        let colorPlanes:size_t = 4
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let rawData = UnsafeMutablePointer<GLubyte>.allocate(capacity: width * height * colorPlanes)
        let spriteCtx = CGContext(data: rawData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * colorPlanes, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        spriteCtx!.draw(imgRef, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        glBindTexture(GLenum(GL_TEXTURE_2D), self.texture!)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE);
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE);
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR);
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR);
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GLint(GL_RGBA), GLsizei(width), GLsizei(height), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), rawData);
        
        free(rawData)
    }
}
