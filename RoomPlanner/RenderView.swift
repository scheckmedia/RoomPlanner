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

class RenderView : GLKView, GLKViewDelegate {
    var room: Room?
    var perspective:Mat4 = Mat4.Identity()
    var cam:Mat4 = Mat4.Identity()
    var debugFeature: Feature?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
    }
    
    public func setup() {
        let aspect = GLfloat(1280.0/720.0)
        
        let w = self.frame.width / 720
        let h = self.frame.height / 1280.0
        let scale = min(w, h)
        
        GLHelper.glPerspective(destMatrix: self.perspective, fov: 56.3, aspectRatio: aspect, near: 0.1, far: 100.0)
        GLHelper.lookAt(eye: Vec3(v: (0,0, 1)),
                        center: Vec3(v: (0, 0, 0)),
                        up: Vec3(v: (0, 1, 0)),
                        destMatrix: self.cam)
        room = Room(scale: Float(scale))
//        let pos = Mat4.Identity()
//        let p = Plane(pos: pos)
//        p.aspectRatio = Float(self.frame.width / self.frame.height)
//        planes.append(p)
    }
    
    public func glkView(_ view: GLKView, drawIn rect: CGRect) {
        EAGLContext.setCurrent(self.context)
        glClearColor(0.0, 0.5, 0.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        
        room!.render(projection: self.perspective, view: self.cam)
        
        if debugFeature != nil {
            debugFeature!.render(projection: self.perspective, view: self.cam)
        }
    }

    
    public func updateTexture(id: GLuint) {
        room!.updateTexture(id: id)
    }
    
}
