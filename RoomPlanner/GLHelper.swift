//
//  GLHelper.swift
//  RoomPlanner
//
//  Created by Tobias Scheck on 06.11.16.
//  Copyright © 2016 AR. All rights reserved.
//
import Foundation
import GLKit

extension Array {
    func size () -> Int {
        return self.count * MemoryLayout.size(ofValue: self[0])
    }
}

class GLHelper {
    public static func linkProgram(vertexShader: String, fragmentShader: String) -> GLuint{
        let vid = GLHelper.compileShader(shaderName: vertexShader, shaderType: GLenum(GL_VERTEX_SHADER))
        let fid = GLHelper.compileShader(shaderName: fragmentShader, shaderType: GLenum(GL_FRAGMENT_SHADER))
        
        let pid: GLuint = glCreateProgram()
        glAttachShader(pid, vid)
        glAttachShader(pid, fid)
        glLinkProgram(pid)
        
        // Check for any errors.
        var linkSuccess: GLint = GLint()
        glGetProgramiv(pid, GLenum(GL_LINK_STATUS), &linkSuccess)
        if (linkSuccess == GL_FALSE) {
            print("Failed to create shader program!")
            // TODO: Actually output the error that we can get from the glGetProgramInfoLog function.
            return 0
        }
        
        return pid
    }
    
    private static func compileShader(shaderName: String, shaderType: GLenum) -> GLuint {
        
        let shaderPath: String? = Bundle.main.path(forResource: shaderName, ofType: nil)
        
        if shaderPath == nil {
            print("Can't find shader \(shaderName)")
            return 0
        }
        
        var shaderString:String? = nil
        do {
             shaderString = try String(contentsOfFile: shaderPath!)
        } catch {
            return 0
        }
        
        
        let shaderHandle: GLuint = glCreateShader(shaderType)
        var shaderCode = (shaderString! as NSString).utf8String
        glShaderSource(shaderHandle, 1, &shaderCode, nil)
        glCompileShader(shaderHandle)
        
        var compileSuccess: GLint = GLint()
        glGetShaderiv(shaderHandle, GLenum(GL_COMPILE_STATUS), &compileSuccess)
        if (compileSuccess == GL_FALSE) {
            print("Failed to compile shader! \(shaderName)")
            var value: GLint = 0
            glGetShaderiv(shaderHandle, GLenum(GL_INFO_LOG_LENGTH), &value)
            
            var infoLog: [GLchar] = [GLchar](repeating: 0, count: Int(value))
            var infoLogLength: GLsizei = 0
            glGetShaderInfoLog(shaderHandle, value, &infoLogLength, &infoLog)
            var errMsg = NSString(bytes: infoLog, length: Int(infoLogLength),
                                  encoding: String.Encoding.ascii.rawValue)
            print("Error: \(errMsg)")
            return 0
        }
        return shaderHandle
    }
}
