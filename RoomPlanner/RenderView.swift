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
    let room: Room = Room()
    var perspective:Mat4 = Mat4.Identity()
    var cam:Mat4 = Mat4.Identity()
    var debugFeature: Feature?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
    }
    
    public func setup() {
        let aspect = GLfloat(self.bounds.width / self.bounds.height)
        
        GLHelper.glPerspective(destMatrix: self.perspective, fov: 56.3, aspectRatio: aspect, near: 0.1, far: 100.0)
        GLHelper.lookAt(eye: Vec3(v: (0,0, 1)),
                        center: Vec3(v: (0, 0, -1)),
                        up: Vec3(v: (0, 1, 0)),
                        destMatrix: self.cam)
        
//        let pos = Mat4.Identity()
//        let p = Plane(pos: pos)
//        p.aspectRatio = Float(self.frame.width / self.frame.height)
//        planes.append(p)
    }
    
    public func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClearColor(0.0, 0.5, 0.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        
//        for p in planes {
//            p.render(projection: self.perspective, view: self.cam)
//        }
        room.render(projection: self.perspective, view: self.cam)
        
        if debugFeature != nil {
            debugFeature!.render(projection: self.perspective, view: self.cam)
        }
    }
    
    public func updateTexture(withImage image: UIImage) {
//        for p in planes {            
//            p.setTexture(withImage: image)
//        }
    }
    
    public func updateTexture(id: GLuint) {
//        for p in planes {
//            p.texture = id
//        }
        
        room.updateTexture(id: id)
    }
    
}
