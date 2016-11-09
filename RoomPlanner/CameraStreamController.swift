//
//  CameraStreamController.swift
//  RoomPlanner
//
//  Created by Michél Neumann on 09/11/2016.
//  Copyright © 2016 AR. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class CameraStreamController: NSObject {
    
    public var session: AVCaptureSession?
    private var device: AVCaptureDevice?
    private var delegate: CameraStreamControllerDelegate?
    
    override init() {
        super.init()
        
        self.session = AVCaptureSession()
        self.session!.sessionPreset = AVCaptureSessionPresetPhoto
        self.device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) as AVCaptureDevice
        self.delegate = CameraStreamControllerDelegate()
        
        self.createVideoInput()
        self.startCaptureSession()
        self.createVideoOutput()
    }
    
    internal func createVideoInput() {
        do {
            self.session!.addInput(try AVCaptureDeviceInput(device: self.device))
        } catch let err as NSError {
            print("Could not connect to AVCaptureDevice! \(err)")
        }
    }
    
    internal func createVideoOutput() {
        let output = AVCaptureVideoDataOutput()
        
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self.delegate, queue: DispatchQueue(label: "HTW.AR.frame_buffer"))
        
        self.session!.addOutput(output)
    }
    
    internal func startCaptureSession() {
        self.session?.startRunning()
    }
    
    internal func stopCaptureSession() {
        self.session?.stopRunning()
    }
    
}
