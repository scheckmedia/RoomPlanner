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
    
    var plane : Plane?
        
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
        
        self.plane = Plane(pos: Mat4.Identity())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClearColor(0.0, 0.0, 0.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        
        plane!.render()
        
        self.setNeedsFocusUpdate()
    }
}
