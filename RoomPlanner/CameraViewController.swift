//
//  CameraViewController.swift
//  RoomPlanner
//
//  Created by Michél Neumann on 04/11/2016.
//  Copyright © 2016 AR. All rights reserved.
//

import UIKit
import AVFoundation
import GLKit

class CameraViewController: GLKViewController, CVStateListener {
    
    //@IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var renderView: RenderView!
    private var cameraStream: CameraStreamController?
    private var preview: AVCaptureVideoPreviewLayer?
    var rv:RenderView? = nil
    var videoTextureId = GLuint()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Execute only on real iOS devices
        if(TARGET_OS_IPHONE != 0 && TARGET_IPHONE_SIMULATOR == 0) {
            // Get camera and start stream
            self.cameraStream = CameraStreamController()
            self.cameraStream?.delegate = self
            self.cameraStream?.startCaptureSession()
            // Attach stream to this view
            //self.preview = AVCaptureVideoPreviewLayer(session: self.cameraStream?.session)
            //self.view.layer.addSublayer(self.preview!)
            //self.preview?.frame = self.view.layer.frame
        }
        
        self.rv = self.view as? RenderView
        
        rv!.context = EAGLContext(api: .openGLES2)
        rv!.drawableDepthFormat = .format24
        rv!.drawableColorFormat = .RGBA8888
        rv!.drawableStencilFormat = .format8
        rv!.backgroundColor = UIColor.clear
        EAGLContext.setCurrent(rv!.context)
        rv!.setup()
                
        glGenTextures(1, &self.videoTextureId)
        OpenCV.bindContext(rv!.context, withTextureID: self.videoTextureId)
        self.rv!.updateTexture(id: self.videoTextureId)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Stop processing stream
        self.cameraStream?.stopCaptureSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Restart processing stream
        self.cameraStream?.startCaptureSession()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func update() {
        self.cameraStream?.currentFrame = self.framesDisplayed
    }
    
    func onFrameReady(image: UIImage) {
        
    }
    
    func onFeaturesDetected(data: NSArray) {
        
    }

}

