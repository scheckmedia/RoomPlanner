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
    var texture:GLKTextureInfo? { get set }
    func render(projection: Mat4, view:Mat4)
}

struct Vertex {
    var position : (x: GLfloat, y: GLfloat, z: GLfloat)
    var uv : (x: GLfloat, y: GLfloat)
}

class Plane: Renderable {
    internal var modelPosition: Mat4
    internal var texture: GLKTextureInfo? = nil
    var vao  = GLuint()
    var vbo = GLuint()
    var program : GLuint?
    var posid: GLuint = GLuint()
    var uvid:GLuint = GLuint()

    
    private let vertices : [Vertex] = [
            Vertex(position: (x: -0.5, y:  0.5, z: 0), uv: (x: 0.0, y: 1.0)),
            Vertex(position: (x:  0.5, y:  0.5, z: 0), uv: (x: 1.0, y: 1.0)),
            Vertex(position: (x:  0.5, y: -0.5, z: 0), uv: (x: 1.0, y: 0.0)),
            
            Vertex(position: (x:  0.5, y: -0.5, z: 0), uv: (x: 1.0, y: 0.0)),
            Vertex(position: (x: -0.5, y: -0.5, z: 0), uv: (x: 0.0, y: 0.0)),
            Vertex(position: (x: -0.5, y:  0.5, z: 0), uv: (x: 0.0, y: 1.0))
    ]
    
    init(pos:Mat4) {
        self.modelPosition = pos
        self.program = GLHelper.linkProgram(vertexShader: "plane.vsh", fragmentShader: "plane.fsh")
        self.posid = GLuint(glGetAttribLocation(program!, "position"))
        self.uvid = GLuint(glGetAttribLocation(program!, "uv_coord"))
        
        glGenVertexArrays(1, &vao)
        glBindVertexArray(vao)
        
        glGenBuffers(1, &vbo)
        
        createData()
        
        
        let path = Bundle.main.path(forResource: "RoundSofa", ofType: "obj")
        let url = URL(fileURLWithPath: path!)
        let asset = MDLAsset(url: url)
        let mesh = asset.object(at: 0) as! MDLMesh

        let vertexBuffer = mesh.vertexBuffers[0]
        let descripter = mesh.vertexDescriptor
        let submeshes = mesh.submeshes
        

        
    }
    
    deinit {
        glDeleteBuffers(1, &vbo)
        glDeleteVertexArrays(1, &vao)
    }
    
    private func createData() {
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER),  vertices.size(), vertices, GLenum(GL_STATIC_DRAW))
        
        glEnableVertexAttribArray(posid)
        glEnableVertexAttribArray(uvid)
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        glVertexAttribPointer(posid, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), nil)
        glVertexAttribPointer(uvid, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET(n: 3 * MemoryLayout<GLfloat>.size))
        
        
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
        
        let mvp = Mat4.Zero()
        view.multiply(with: modelPosition, andOutputTo: mvp)
        projection.multiply(with: mvp, andOutputTo: mvp)
        
        glUniformMatrix4fv(GLint(glGetUniformLocation(program!, "mvp")), 1, GLboolean(GL_FALSE), mvp)
        
        if self.texture != nil {
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(texture!.target, texture!.name)
            glUniform1i(glGetUniformLocation(program!, "tex"), 0)
        }
        
        glBindVertexArray(vao)
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 6)
        glBindVertexArray(0)
        
        glUseProgram(0)
    }

    
    public func setTexture(textureFile: String) {
        do {
            self.texture = try GLKTextureLoader.texture(withContentsOfFile: textureFile, options: nil)
            glBindTexture(texture!.target, texture!.name)
            let aspect = GLfloat(self.texture!.width) / GLfloat(self.texture!.height)
            self.modelPosition.scale(by: Vec4(v: (aspect, 1, 1, 0)))
        } catch _ {
            
        }
    }

    
}
