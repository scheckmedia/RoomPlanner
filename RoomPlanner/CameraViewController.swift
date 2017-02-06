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
import GLMatrix


class CameraViewController: GLKViewController, CVStateListener {
    
    @IBOutlet weak var btnPlace: UIButton!
    @IBOutlet weak var state: UILabel!
    
    enum EditorMode {
        case TRANSLATION, ROTATION
    }

    
    @IBOutlet weak var renderView: RenderView!
    private var cameraStream: CameraStreamController?
    private var preview: AVCaptureVideoPreviewLayer?
    var rv:RenderView? = nil
    var videoTextureId = GLuint()
    var mode = EditorMode.TRANSLATION
   
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

        EAGLContext.setCurrent(rv!.context)
        rv!.setup()
                
        glGenTextures(1, &self.videoTextureId)
        OpenCV.bindContext(rv!.context, withTextureID: self.videoTextureId)
        
        EAGLContext.setCurrent(rv!.context)
        rv?.updateTexture(id: self.videoTextureId)
        
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
    
    
    func onFrameReady(image: UIImage) {}
    
    
    func onFeaturesDetected(edges: [HoughLine], andVanishPoint vp: [CGPoint]) {
        DispatchQueue.main.async {
            let pos = Mat4.Identity()
            let f = Feature(edges: edges, andVanishingPoint: vp)
            pos.rotateAroundZ(byAngle: Float(90.0.degreesToRadians))
            pos.scale(by: Vec4(v: (GLfloat(1280.0 / 720.0), 1.0, 1.0, 1.0)))
            pos.scale(by: self.rv!.stageScaleFactor)
            pos.translate(by: Vec3(v: (0.0, 0.0, -9.9)))
            f.modelPosition = pos
            self.rv!.debugFeature = f
        }
    }
    
    @IBAction func unwindToRootViewController(segue: UIStoryboardSegue) {
        if let activeModels = UserDefaults.standard.value(forKey: "activeModels") as? Array<String> {
            if(activeModels.count == 0) {
                return;
            }
            
            self.rv?.updateModel(path: activeModels[0] )
        }
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        let translate = sender.translation(in: self.rv!)
        let x = translate.x
        let y = translate.y
        let delta = CGFloat(5)
        let dx = (delta * floor((x / delta + 0.5))) / self.view.frame.width
        let dy = (delta * floor((y / delta + 0.5))) / (self.view.frame.height / 2.0)
        
        if let model = self.rv?.furniture {
            if(mode == .TRANSLATION) {
                model.modelPosition.translate(by: Vec3(v: (GLfloat(dx), 0.0, GLfloat(dy))))
            } else {
                let angle = CGFloat.pi * dx
                let rot = Float(copysign(angle, sender.velocity(in: self.rv!).x))
                model.modelPosition.rotateAroundY(byAngle: rot)
            }
        }
        
        sender.setTranslation(CGPoint.zero, in: self.rv!)
    }
    
    @IBAction func placeInRoom() {
        if cameraStream != nil {
            if cameraStream?.place == false {
                cameraStream?.place = true
                btnPlace.titleLabel?.text = "Place"
            } else {
                cameraStream?.place = false
                cameraStream?.startCaptureSession()
                btnPlace.titleLabel?.text = "Repeat"
            }
        }
    }
    
    @IBAction func handleDoubleTap(_ sender: UITapGestureRecognizer) {        
        if mode == .TRANSLATION {
            mode = .ROTATION
            state.text = "Rotate"
        } else {
            mode = .TRANSLATION
            state.text = "Translate"
        }
    }
    
}

