//
//  CameraStreamController.swift
//  RoomPlanner
//
//  Created by Michél Neumann on 09/11/2016.
//  Copyright © 2016 AR. All rights reserved.
//

import Foundation
import UIKit
import GLKit
import AVFoundation

protocol CVStateListener {
    func onFrameReady(image: UIImage)
    func onFeaturesDetected()
}

class CameraStreamController: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private var device: AVCaptureDevice?
    public var delegate: CVStateListener?
    internal var session: AVCaptureSession?
    public var ctx: EAGLContext?
    
    override init() {
        super.init()
        
        self.session = AVCaptureSession()
        self.session!.sessionPreset = AVCaptureSessionPreset1280x720
        self.device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) as AVCaptureDevice
     
        self.createVideoInput()
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
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "HTW.AR.Frame_Buffer"))
        
        self.session!.addOutput(output)
    }
    
    internal func startCaptureSession() {
        self.session?.startRunning()
    }
    
    internal func stopCaptureSession() {
        self.session?.stopRunning()
    }
    
    internal func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {        
        let image: UIImage = OpenCV.image(from: sampleBuffer)
//        let processed = OpenCV.greyScale(from: image)
//        
//        
//        if self.delegate != nil {
//            self.delegate!.onFrameReady(image: processed!)
//        }
        
    }
    
    internal func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        print("frame dropped")
    }
    
}
