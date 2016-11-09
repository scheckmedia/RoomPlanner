//
//  CameraViewController.swift
//  RoomPlanner
//
//  Created by Michél Neumann on 04/11/2016.
//  Copyright © 2016 AR. All rights reserved.
//

import UIKit
import AVFoundation

/**
    IMPORTANT: Will cause bad access errors if tested in the iOS Simulator!
 */

class CameraViewController: UIViewController {
    
    private var cameraStream: CameraStreamController?
    private var preview: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Execute only on real iOS devices
        if(TARGET_OS_IPHONE != 0 && TARGET_IPHONE_SIMULATOR == 0) {
            // Get camera and start stream
            self.cameraStream = CameraStreamController()
            self.cameraStream?.startCaptureSession()
            
            // Attach stream to this view
            self.preview = AVCaptureVideoPreviewLayer(session: self.cameraStream?.session)
            self.view.layer.addSublayer(self.preview!)
            self.preview?.frame = self.view.layer.frame
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

