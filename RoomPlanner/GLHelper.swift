//
//  GLHelper.swift
//  RoomPlanner
//
//  Created by Tobias Scheck on 06.11.16.
//  Copyright © 2016 AR. All rights reserved.
//
import Foundation
import GLKit
import GLMatrix

extension Array {
    func size () -> Int {
        return self.count * MemoryLayout.size(ofValue: self[0])
    }
}


extension Vec3 {
    static func cross(left:Vec3, right:Vec3) -> Vec3 {
        let res = Vec3(v: (
            left.v1 * right.v2 - left.v2 * right.v1,
            left.v2 * right.v0 - left.v0 * right.v2,
            left.v0 * right.v1 - left.v1 * right.v0
        ))
        
        return res
    }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

struct GLPoint3 {
    init(x: GLfloat, y:GLfloat, z:GLfloat) {
        self.x = x
        self.y = y
        self.z = z
    }
    var x = GLfloat(0.0)
    var y = GLfloat(0.0)
    var z = GLfloat(0.0)
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
            let errMsg = NSString(bytes: infoLog, length: Int(infoLogLength),
                                  encoding: String.Encoding.ascii.rawValue)
            print("Error: \(errMsg)")
            return 0
        }
        return shaderHandle
    }
    
    public static func glPerspective(destMatrix:Mat4, fov:Float, aspectRatio:Float, near:Float, far:Float) {
        let tanHalfFOV = tanf(fov.degreesToRadians / 2.0)
        
        destMatrix.m00 = 1.0 / (tanHalfFOV * aspectRatio)
        destMatrix.m01 = 0.0
        destMatrix.m02 = 0.0
        destMatrix.m03 = 0.0
        
        destMatrix.m10 = 0.0
        destMatrix.m11 = 1.0 / tanHalfFOV
        destMatrix.m12 = 0.0
        destMatrix.m13 = 0.0
        
        destMatrix.m20 = 0.0
        destMatrix.m21 = 0.0
        destMatrix.m22 = -(far + near) / (far - near)
        destMatrix.m23 = -1
        
        destMatrix.m30 = 0.0
        destMatrix.m31 = 0.0
        destMatrix.m32 = -(2.0 * far * near) / (far - near)
        destMatrix.m33 = 0.0
        
        //Mat4.frustum(left: -xmax, right: xmax, bottom: -ymax, top: ymax, near: near, far: far, andOutputTo: destMatrix)
    }
    
    public static func lookAt(eye:Vec3, center:Vec3, up:Vec3, destMatrix:Mat4) {
        let f = Vec3.Zero()
        center.subtract(eye, andOutputTo: f)
        f.normalize()
        
        var u = up.clone()
        u.normalize()
        
        let s = Vec3.cross(left: f, right: u)
        s.normalize()
        u = Vec3.cross(left: s, right: f)
        
        destMatrix.m00 = s.v0
        destMatrix.m10 = s.v1
        destMatrix.m20 = s.v2
        destMatrix.m01 = u.v0
        destMatrix.m11 = u.v1
        destMatrix.m21 = u.v2
        destMatrix.m02 = -f.v0
        destMatrix.m12 = -f.v1
        destMatrix.m22 = -f.v2
        destMatrix.m30 = -s.dot(eye)
        destMatrix.m31 = -u.dot(eye)
        destMatrix.m32 =  f.dot(eye)
    }
}
