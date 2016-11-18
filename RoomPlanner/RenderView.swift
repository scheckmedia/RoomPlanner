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
    var planes : [Plane] = []
    var perspective:Mat4 = Mat4.Identity()
    var cam:Mat4 = Mat4.Identity()
    
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
        
        let pos = Mat4.Identity();
        let p = Plane(pos: pos)
        p.setTexture(textureFile: Bundle.main.path(forResource: "room", ofType: "jpg")!)
        planes.append(p);
    }
    
    public func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClearColor(0.0, 0.5, 0.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        
        for p in planes {
            p.render(projection: self.perspective, view: self.cam)
        }
    }
    
    public func updateTexture(withImage image: UIImage) {
        for p in planes {
            p.setTexture(withImage: image)
        }
    }
    
}
