//
//  CameraStreamControllerDelegate.swift
//  RoomPlanner
//
//  Created by Michél Neumann on 09/11/2016.
//  Copyright © 2016 AR. All rights reserved.
//

import Foundation
import AVFoundation

class CameraStreamControllerDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    internal func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        print("new frame written")
    }
    
    internal func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        print("frame dropped")
    }
}
