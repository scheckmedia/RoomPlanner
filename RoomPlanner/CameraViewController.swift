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
    
    private let session = AVCaptureSession()
    private var device: AVCaptureDevice?
    private var preview: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set session quality to highest resolution
        session.sessionPreset = AVCaptureSessionPresetPhoto
        
        // Fetch all available devices and return the back-facing camera only
        for device in (AVCaptureDevice.devices() as! [AVCaptureDevice]) {
            if device.hasMediaType(AVMediaTypeVideo) && device.position == AVCaptureDevicePosition.back {
                self.device = device
            }
        }
        
        // WTF Error Handling?!
        do {
            session.addInput(try AVCaptureDeviceInput(device: self.device))
        } catch _ {
            print("Could not connect to AVCaptureDevice!")
        }
        
        // Attach camera preview to this view controller (for testing)
        self.preview = AVCaptureVideoPreviewLayer(session: self.session)
        self.view.layer.addSublayer(self.preview!)
        self.preview?.frame = self.view.layer.frame
        
        self.session.startRunning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

