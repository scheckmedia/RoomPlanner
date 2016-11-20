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
}

class Plane: Renderable {
    internal var modelPosition: Mat4
    public var texture: GLuint? = nil
    var vao  = GLuint()
    var vbo = GLuint()
    var program : GLuint?
    var posid: GLuint = GLuint()
    var uvid:GLuint = GLuint()
    var aspectRatio:Float = 1.0 {
        didSet {
            self.modelPosition.scale(by: Vec4(v: (aspectRatio, 1, 1, 0)))
        }
    }

    
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
        glGenVertexArrays(1, &vao)
        glBindVertexArray(vao)
        
        glGenBuffers(1, &vbo)
        
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
