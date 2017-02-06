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
    func onFeaturesDetected(edges: [HoughLine], andVanishPoint vp: [CGPoint])
}

class CameraStreamController: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private var currentFrame:Int = 0
    private var device: AVCaptureDevice?
    public var delegate: CVStateListener?
    internal var session: AVCaptureSession?
    public var ctx: EAGLContext?
    var backgroundQueue: DispatchQueue?
    public var place = false
    
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
        place = false
        self.session?.startRunning()
    }
    
    internal func stopCaptureSession() {
        self.session?.stopRunning()
    }
    
    internal func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        if self.session?.isRunning == false {
            return
        }
        
        let image: UIImage = OpenCV.image(from: sampleBuffer)
        if place == false {
            return
        }
        
        
        stopCaptureSession()
        
        let start = DispatchTime.now()
        let processed = OpenCV.detectFeatures(image, andDraw: true) as! NSMutableDictionary //OpenCV.cannyCornerDetection(image, thres_1: 50, thres_2: 150) as NSArray
        let end = DispatchTime.now()
        
        let hl = processed.object(forKey: "HoughLines") as! [HoughLine];
        let vp = processed.object(forKey: "VanishingPoints") as! [Any];
        
        var vps: [CGPoint] = []
        for val in vp {
            if let v = val as? NSValue {
                vps.append(v.cgPointValue)
            }
        }
        
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000
        print("execution time of canny: \(timeInterval) ms")
        
        //print("exectime: \(end.time)")
        
        if self.delegate != nil {
            //self.delegate!.onFrameReady(image: test)
            // self.delegate!.onFeaturesDetected(edges: hl, andVanishPoint: vps)
        }
        //self.place = false
    }
    
    internal func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {}
}
