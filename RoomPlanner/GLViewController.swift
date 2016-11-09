//
//  GLViewController.swift
//  RoomPlanner
//
//  Created by Michél Neumann on 04/11/2016.
//  Copyright © 2016 AR. All rights reserved.
//

import GLKit
import GLMatrix

class GLViewController: GLKViewController {
    
    var planes : [Plane] = []
    var perspective:Mat4 = Mat4.Identity()
    var cam:Mat4 = Mat4.Identity()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let rv = (self.view as! GLKView)
        // glv.delegate = rv
        rv.context = EAGLContext(api: .openGLES2)
        rv.drawableDepthFormat = .format24
        rv.drawableColorFormat = .RGBA8888
        rv.drawableStencilFormat = .format8
        rv.backgroundColor = UIColor.clear
        EAGLContext.setCurrent(rv.context)
        
        let posP1 = Mat4.Identity()
        let posP2 = Mat4.Identity()
        
        posP1.scale(by: 0.4)
        posP2.scale(by: 0.5)
        posP2.translate(by: Vec3(v: (0.0, 0.0, -1.0)))
        let aspect = GLfloat(self.view!.bounds.width / self.view!.bounds.height)
        
        self.perspective = Mat4.Identity()
        // Todo: https://www.boinx.com/chronicles/2013/3/22/field-of-view-fov-of-cameras-in-ios-devices/
//        Mat4.frustum(left: -aspect, right: aspect,
//                     bottom: 1.0, top: -1.0,
//                     near: 1, far: 10, andOutputTo: self.cam)
        GLHelper.glPerspective(destMatrix: self.perspective, fov: 60.0, aspectRatio: aspect, near: 1.0, far: 255.0)
        self.cam = Mat4.Identity()
        GLHelper.lookAt(eye: Vec3(v: (0,0,-2)),
                        center: Vec3(v: (0,0,-1)),
                        up: Vec3(v: (0,1,0)),
                        destMatrix: self.cam)
        
        let out = Mat4.Zero()
        let out2 = Mat4.Zero()
        self.cam.multiply(with: posP2, andOutputTo: out)
        self.perspective.multiply(with: posP2, andOutputTo: out2)
        
        planes.append( Plane(pos: out2) )
        //planes.append( Plane(pos: posP1) )
        planes[0].setTexture(textureFile: Bundle.main.path(forResource: "wall", ofType: "jpg")!)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClearColor(0.0, 0.0, 0.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        
        for p in planes {
            p.render()
        }
        
        
        //self.setNeedsFocusUpdate()
    }
    
    @IBAction func handleZoomGesture(recognizer:UIPinchGestureRecognizer) {
        planes[0].modelPosition.scale(by: GLfloat(recognizer.scale))
        recognizer.scale = 1
    }
    
    @IBAction func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let angle = recognizer.translation(in: recognizer.view).y * CGFloat(M_PI / 180.0)
        let s = GLfloat(sin(angle / 2.0))
        let rot = Quat(x: s, y: 0.0, z: 0.0, w: GLfloat(cos(angle / 2.0)))
        let rotmat = Mat4.Zero()
        let pos = planes[0].modelPosition
        Mat4.fromQuat(q: rot, andOutputTo: rotmat)
        pos.multiply(with: rotmat)
        recognizer.setTranslation(CGPoint(x:0, y:0), in: recognizer.view)
    }
}
