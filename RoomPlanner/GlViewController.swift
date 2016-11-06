//
//  SecondViewController.swift
//  RoomPlanner
//
//  Created by Michél Neumann on 04/11/2016.
//  Copyright © 2016 AR. All rights reserved.
//

import GLKit
import GLMatrix


class GlViewController: GLKViewController {
    
    var planes : [Plane] = []
        
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
        
        var posP1 = Mat4.Identity()
        var posP2 = Mat4.Identity()
        
        posP1.scale(by: 0.4)
        
        posP2.scale(by: 0.3)
        posP2.translate(by: Vec3(v: (0.3, -0.1, 0.0)))
        
        planes.append( Plane(pos: posP2) )
        planes.append( Plane(pos: posP1) )
        planes[0].color = Vec3(v: (GLfloat(0), GLfloat(0), GLfloat(1)))
        planes[1].color = Vec3(v: (GLfloat(1), GLfloat(0), GLfloat(0)))
        
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
        
        
        self.setNeedsFocusUpdate()
    }
}
