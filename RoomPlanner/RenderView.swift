//
//  RenderView.swift
//  RoomPlanner
//
//  Created by Tobias Scheck on 18.11.16.
//  Copyright © 2016 AR. All rights reserved.
//

import Foundation
import GLKit
import GLMatrix
import CoreMotion

class RenderView : GLKView, GLKViewDelegate {
    var furniture: Furniture?
    var stage : Plane?
    var stageScaleFactor: Float = 0.0
    var perspective = Mat4.Identity()
    var cam = Mat4.Identity()
    var stageCam = Mat4.Identity()
    var debugFeature: Feature? {
        didSet {
            
        }
    }

    var manager:CMMotionManager?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        initMotionManager()
    }
    
    private func initMotionManager() {
        manager = CMMotionManager()
        manager!.startDeviceMotionUpdates()
    }
    
    public func setup() {
        glEnable(GLenum(GL_DEPTH_TEST))
        glEnable(GLenum(GL_BLEND)); // Enable the OpenGL Blending functionality
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        
        let rvAspect = Float(self.frame.width / self.frame.height)
        GLHelper.glPerspective(destMatrix: self.perspective, fov: 56.3, aspectRatio: rvAspect, near: 0.1, far: 100.0)
        GLHelper.lookAt(eye: Vec3(v: (0,0, 1)),
                        center: Vec3(v: (0, 0, 0)),
                        up: Vec3(v: (0, 1, 0)),
                        destMatrix: self.cam)
        
        
        GLHelper.lookAt(eye: Vec3(v: (0,0, 1)),
                        center: Vec3(v: (0, 0, 0)),
                        up: Vec3(v: (0, 1, 0)),
                        destMatrix: self.stageCam)
        
        
        let furniturePos = Mat4.Identity()
        furniturePos.translate(by: Vec3(v: (0.0, 0.0, -2.0)))
        furniture = Furniture(pos: furniturePos, path: ModelObject.all()!.first?.value(forKey: "path") as! String)
        
        
        // 11.0 is the distance between the camera and the plane with the video texture
        let rmax = Float(2.0 * 7.0 * tan(56.3.degreesToRadians * 0.5))
        stageScaleFactor = Float(rmax * rvAspect)
        let pos = Mat4.Identity()
        pos.scale(by: Vec4(v:(1280 / 720, 1, 1, 1)))
        pos.scale(by: stageScaleFactor)
        pos.translate(by: Vec3(v:(0, 0, -10)))
        stage = Plane(pos: pos)
    }
    
    public func glkView(_ view: GLKView, drawIn rect: CGRect) {
        EAGLContext.setCurrent(self.context)
        glClearColor(0.3, 0.3, 0.3, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT))
        self.cam = Mat4.Identity()
        
        if let d = manager?.deviceMotion?.attitude {
            // yaw and pitch are inverted cause landscape mode
            let q = Quat(roll: Float(d.roll + .pi / 2.0), pitch: Float(-d.yaw), yaw: Float(d.pitch))
            
            let eye = Vec3(v:(0,0, 1))
            let up = Vec3(v: (0, 1, 0))
            GLHelper.lookAt(eye: eye,
                            center: Vec3(v: (0, 0, 0)),
                            up: up,
                            destMatrix: self.cam)
            
            self.cam.rotate(with: q)
        }
        
        furniture?.render(projection: self.perspective, view: self.cam)
        stage?.render(projection: self.perspective, view: self.stageCam)
        
        let pos = Mat4.Identity()
        pos.scale(by: Vec4(v:(1, 1280 / 720, 1, 1)))
        pos.rotateAroundX(byAngle: Float(90.degreesToRadians))
        pos.translate(by: Vec3(v:(0, -0.5, 0)))
        
        let floor = Plane(pos: pos)
        floor.render(projection: self.perspective, view: self.cam)

        
        if debugFeature != nil {
            debugFeature!.render(projection: self.perspective, view: self.stageCam)
        }
    }

    public func updateTexture(id: GLuint) {
        stage?.texture = id
    }
    
    public func updateModel(path: String) {
        var oldPos = Mat4.Identity()
        
        if let old = furniture {
            oldPos = old.modelPosition
        }
        
        furniture = Furniture(pos: oldPos, path: path)
    }
}
