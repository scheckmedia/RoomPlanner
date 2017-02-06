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

extension Quat {
    convenience init(roll: Float, pitch: Float, yaw: Float) {
        let t0 = cos(yaw * 0.5);
        let t1 = sin(yaw * 0.5);
        let t2 = cos(roll * 0.5);
        let t3 = sin(roll * 0.5);
        let t4 = cos(pitch * 0.5);
        let t5 = sin(pitch * 0.5);
        
        let w = t0 * t2 * t4 + t1 * t3 * t5;
        let x = t0 * t3 * t4 - t1 * t2 * t5;
        let y = t0 * t2 * t5 + t1 * t3 * t4;
        let z = t1 * t2 * t4 - t0 * t3 * t5;
        
        self.init(x: x, y: y, z: z, w: w)
    }
    
    func appendAngle(roll: Float, pitch: Float, yaw: Float) {
        let ysqr = self.y * self.y
        
        // roll (x-axis rotation)
        var t0 = +2.0 * (self.w * self.x + self.y * self.z);
        var t1 = +1.0 - 2.0 * (self.x * self.x + ysqr)
        let r = atan2(t0, t1) + roll
        
        // pitch (y-axis rotation)
        var t2 = +2.0 * (self.w * self.y - self.z * self.x)
        t2 = t2 > 1.0 ? 1.0 : t2
        t2 = t2 < -1.0 ? -1.0 : t2
        let p = asin(t2) + pitch
        
        // yaw (z-axis rotation)
        var t3 = +2.0 * (self.w * self.z + self.x * self.y)
        var t4 = +1.0 - 2.0 * (ysqr + self.z * self.z)
        let y = atan2(t3, t4) + yaw
        
        t0 = cos(y * 0.5);
        t1 = sin(y * 0.5);
        t2 = cos(r * 0.5);
        t3 = sin(r * 0.5);
        t4 = cos(p * 0.5);
        let t5 = sin(p * 0.5);
        
        self.w = t0 * t2 * t4 + t1 * t3 * t5;
        self.x = t0 * t3 * t4 - t1 * t2 * t5;
        self.y = t0 * t2 * t5 + t1 * t3 * t4;
        self.z = t1 * t2 * t4 - t0 * t3 * t5;
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
    
    func rotateAroundX(byAngle angle: Float) {
        let s = GLfloat(sin(angle / 2.0))
        let rot = Quat(x: s, y: 0.0, z: 0.0, w: GLfloat(cos(angle / 2.0)))
        
        self.transform(with: rot)
    }
    
    public func transformMirroredY(with quat: Quat, andOutputTo out: Vec3? = nil) {
        guard let out = out else { return transform(with: quat, andOutputTo: self) }
        
        let x = self[0], y = self[1], z = self[2],
        qx = quat[0], qy = quat[1], qz = quat[2], qw = quat[3],
        
        // calculate quat vec
        ix = qw * x + qy * z - qz * y,
        iy = qw * y + qz * x - qx * z,
        iz = qw * z + qx * y - qy * x,
        iw = -qx * x - qy * y - qz * z
        
        // calculate result inverse quat
        out[0] = -(ix * qw + iw * -qx + iy * -qz - iz * -qy)
        out[1] = iy * qw + iw * -qy + iz * -qx - ix * -qz
        out[2] = iz * qw + iw * -qz + ix * -qy - iy * -qx
    }
}

extension Mat4 {
    func rotateAroundX(byAngle angle: Float) {
        let s = GLfloat(sin(angle / 2.0))
        let rot = Quat(x: s, y: 0.0, z: 0.0, w: GLfloat(cos(angle / 2.0)))
        let rotmat = Mat4.Zero()
        Mat4.fromQuat(q: rot, andOutputTo: rotmat)
        self.multiply(with: rotmat)
    }
    
    func rotateAroundY(byAngle angle: Float) {
        let s = GLfloat(sin(angle / 2.0))
        let rot = Quat(x: 0.0, y: s, z: 0.0, w: GLfloat(cos(angle / 2.0)))
        let rotmat = Mat4.Zero()
        Mat4.fromQuat(q: rot, andOutputTo: rotmat)
        self.multiply(with: rotmat)
    }
    
    func rotateAroundZ(byAngle angle: Float) {
        let s = GLfloat(sin(angle / 2.0))
        let rot = Quat(x: 0.0, y: 0.0, z: s, w: GLfloat(cos(angle / 2.0)))
        let rotmat = Mat4.Zero()
        Mat4.fromQuat(q: rot, andOutputTo: rotmat)
        self.multiply(with: rotmat)
    }
    
    func rotate(with quaternion: Quat) {        
        let rotmat = Mat4.Zero()
        Mat4.fromQuat(q: quaternion, andOutputTo: rotmat)
        self.multiply(with: rotmat)
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
            var message = [CChar](repeating: CChar(0), count: 256)
            var length = GLsizei(0)
            glGetProgramInfoLog(pid, 256, &length, &message)
            
            print(String(utf8String: message))
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
    
    public static func glOrtho(left:Float, right:Float,
                               top:Float, bottom:Float, near:Float, far:Float) -> Mat4{
        let destMatrix = Mat4.Zero()
        destMatrix.m00 = 2.0 / (right - left)
        destMatrix.m03 = -(right + left) / (right - left)
        
        destMatrix.m11 = 2.0 / (top - bottom)
        destMatrix.m13 = -(top + bottom) / (top - bottom)
        
        destMatrix.m22 = -2.0 / (far - near)
        destMatrix.m23 = -(far + near) / (far - near)
        
        destMatrix.m33 = 1.0
        
        return destMatrix
        
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
