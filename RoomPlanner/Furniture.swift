//
//  Model.swift
//  RoomPlanner
//
//  Created by Tobias Scheck on 20.11.16.
//  Copyright © 2016 AR. All rights reserved.
//

import Foundation
import GLMatrix
import GLKit
import ModelIO

class Furniture : Renderable{
    var modelPosition:Mat4
    var texture:GLuint?
    var vao  = GLuint()
    var vbo: UnsafeMutablePointer<GLuint>? = nil
    var program : GLuint?
    var posid: GLuint = GLuint()
    var uvid:GLuint = GLuint()
    var normalid:GLuint = GLuint()
    var mesh: GLKMesh?
    var rot = Float(0.0)
    
    init(pos:Mat4, path: String) {
        modelPosition = pos        
        self.program = GLHelper.linkProgram(vertexShader: "model.vsh", fragmentShader: "model.fsh")
        
        let alloc = GLKMeshBufferAllocator.init()
        let path = Bundle.main.path(forResource: path, ofType: nil)
        let url = URL(fileURLWithPath: path!)
        let asset = MDLAsset(url: url, vertexDescriptor: nil, bufferAllocator: alloc)
        let mmesh = asset.object(at: 0) as! MDLMesh
        do {
            mesh = try GLKMesh.init(mesh: mmesh)
            createData()
        } catch  {
            print("Failed to create MTKMesh from MDLMesh! \(error)")
        }
        
        //modelPosition.scale(by: 0.000005)
        //modelPosition.rotateAroundY(byAngle: Float(70.0).degreesToRadians)
        //modelPosition.translate(by: Vec3(v: (0.0, 0.0, -2.0)))
    
    }
    
    private func createData() {
        if let m = mesh {
            let numBuffers = m.vertexBuffers.count
            if(numBuffers <= 0) {
                return
            }
            
            
            glGenVertexArrays(1, &vao)
            glBindVertexArray(vao)
           
            let descriptor = m.vertexDescriptor
            let stride = descriptor.layouts[0] as! MDLVertexBufferLayout
            let pos = descriptor.attributeNamed("position")
            let normal = descriptor.attributeNamed("normal")
            
            
            let posParam = GLKVertexAttributeParametersFromModelIO(pos!.format)
            let normalParam = GLKVertexAttributeParametersFromModelIO(normal!.format)
            let buffer = m.vertexBuffers[pos!.bufferIndex]
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), buffer.glBufferName)
            glBufferData(GLenum(GL_ARRAY_BUFFER),  buffer.length, buffer.map().bytes, GLenum(GL_STATIC_DRAW))
            
            posid = GLuint(glGetAttribLocation(self.program!, "position"))
            glEnableVertexAttribArray(posid)
            glVertexAttribPointer(posid, posParam.size, posParam.type, posParam.normalized, GLsizei(stride.stride), BUFFER_OFFSET(n: buffer.offset + pos!.offset))
            
            normalid = GLuint(glGetAttribLocation(self.program!, "normals"))
            glEnableVertexAttribArray(normalid)
            glVertexAttribPointer(normalid, normalParam.size, normalParam.type, normalParam.normalized, GLsizei(stride.stride), BUFFER_OFFSET(n: buffer.offset + normal!.offset ))
            
            
            for sm in m.submeshes {
                glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), sm.elementBuffer.glBufferName)
                glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), sm.elementBuffer.length, sm.elementBuffer.map().bytes, GLenum(GL_STATIC_DRAW))
            }
            
            glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        }
        glBindVertexArray(0)
    }
    
    func BUFFER_OFFSET(n: Int) -> UnsafeRawPointer? {
        if(n == 0) {
            return nil
        }
        
        return UnsafeRawPointer(bitPattern: n)!
    }
    
    func render(projection: Mat4, view: Mat4) {    
        glUseProgram(self.program!)
        let modelView = Mat4.Zero()
        let normalMatrix = Mat4.Zero()
        view.multiply(with: modelPosition, andOutputTo: modelView)
        modelView.invert(andOutputTo: normalMatrix)
        normalMatrix.transpose()
        
        glUniformMatrix4fv(GLint(glGetUniformLocation(program!, "projection")), 1, GLboolean(GL_FALSE), projection)
        glUniformMatrix4fv(GLint(glGetUniformLocation(program!, "model_view")), 1, GLboolean(GL_FALSE), modelView)
        glUniformMatrix4fv(GLint(glGetUniformLocation(program!, "normal_matrix")), 1, GLboolean(GL_FALSE), normalMatrix)
        
        
        glBindVertexArray(vao)
        if let m = mesh {
            for sm in m.submeshes {
                glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), sm.elementBuffer.glBufferName)
                glDrawElements(GLenum(GL_TRIANGLES), sm.elementCount, sm.type, BUFFER_OFFSET(n: sm.elementBuffer.offset))
                
            }
        }
        glBindVertexArray(0)
        glUseProgram(0)
    }

}

//let path = Bundle.main.path(forResource: "RoundSofa", ofType: "obj")
//let url = URL(fileURLWithPath: path!)
//let asset = MDLAsset(url: url)
//let mesh = asset.object(at: 0) as! MDLMesh
//
//let vertexBuffer = mesh.vertexBuffers[0]
//let descripter = mesh.vertexDescriptor
//let submeshes = mesh.submeshes
