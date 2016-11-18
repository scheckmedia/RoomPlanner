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
             
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
                
        
        //self.setNeedsFocusUpdate()
    }
    
    @IBAction func handleZoomGesture(recognizer:UIPinchGestureRecognizer) {
        //planes[0].modelPosition.scale(by: GLfloat(recognizer.scale))
//        recognizer.scale = 1
    }
    
    @IBAction func handlePanGesture(recognizer: UIPanGestureRecognizer) {
//        let angle = recognizer.translation(in: recognizer.view).y * CGFloat(M_PI / 180.0)
//        let s = GLfloat(sin(angle / 2.0))
//        let rot = Quat(x: s, y: 0.0, z: 0.0, w: GLfloat(cos(angle / 2.0)))
//        let rotmat = Mat4.Zero()
//        let pos = planes[0].modelPosition
//        Mat4.fromQuat(q: rot, andOutputTo: rotmat)
//        pos.multiply(with: rotmat)
//        recognizer.setTranslation(CGPoint(x:0, y:0), in: recognizer.view)
    }
}
