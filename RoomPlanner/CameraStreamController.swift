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
    func onFeaturesDetected(data: NSArray)
}

class CameraStreamController: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private var currentFrame:Int = 0
    private var device: AVCaptureDevice?
    public var delegate: CVStateListener?
    internal var session: AVCaptureSession?
    public var ctx: EAGLContext?
    var backgroundQueue: DispatchQueue?
    
    override init() {
        super.init()
        
        self.session = AVCaptureSession()
        self.session!.sessionPreset = AVCaptureSessionPreset1280x720
        self.device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) as AVCaptureDevice
     
        self.createVideoInput()
        self.createVideoOutput()
        
        backgroundQueue = DispatchQueue(label: "com.app.queue",
                                            qos: .background,
                                            target: nil)
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
        self.currentFrame += 1
        
        if(self.currentFrame % 25 == 0) {
            backgroundQueue!.async {
                let processed: NSArray = OpenCV.cornerHarrisDetection(image, sobel_kernel: 3, blocksize: 8) as NSArray
                //let test = self.drawImage(image: image, data: processed)
                if self.delegate != nil {
                    //self.delegate!.onFrameReady(image: test)
                    self.delegate!.onFeaturesDetected(data: processed)
                }
            }
            
            
        }
    }
    
    internal func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {}
    
    internal func drawImage(image: UIImage, data: NSArray) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
        
        image.draw(at: CGPoint.zero)
        
        for point in data {
            let p = point as! CGPoint
            
            UIColor.red.setFill()
            UIRectFill(CGRect(x: p.x, y: p.y, width: 10, height: 10))
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}
