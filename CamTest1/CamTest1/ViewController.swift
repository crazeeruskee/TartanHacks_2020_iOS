//
//  ViewController.swift
//  CamTest1
//
//  Created by Lucas Moiseyev on 2/15/20.
//  Copyright © 2020 Crazeeruskee. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    let captureSession = AVCaptureSession()
    var previewLayer:CALayer!

    var captureDevice:AVCaptureDevice!
    
    var takePhoto = false
//    var image2 : UIImage = UIImage();

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("yurtt appeared")
     //   prepareCamera()
    }
    
    func prepareCamera(){
            captureSession.sessionPreset = AVCaptureSession.Preset.photo
                    
            let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices
            captureDevice = availableDevices.first
              
            /*
            if let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices {
                captureDevice = availableDevices.first
            }
            */
            
            beginSession()
        }
        
        func beginSession(){
            do{
                let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
                captureSession.addInput(captureDeviceInput)
            } catch{
                print(error.localizedDescription)
            }
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            self.previewLayer = previewLayer
            self.view.layer.addSublayer(self.previewLayer)
            self.previewLayer.frame = self.view.layer.frame
            captureSession.startRunning()
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value:kCVPixelFormatType_32BGRA)] as [String : Any]
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if captureSession.canAddOutput(dataOutput) {
                captureSession.addOutput(dataOutput)
            }
                
            captureSession.commitConfiguration()
            
            //let queue = DispatchQueue(label: "com.crazee.CamTest1")
            //dataOutput.setSampleBufferDelegate(self, queue: queue)
            
            let queue = DispatchQueue(label: "com.crazee.TakePhoto")
            dataOutput.setSampleBufferDelegate(self as AVCaptureVideoDataOutputSampleBufferDelegate, queue: queue)
                
            
        } //end beginSession()
       
        
        /*
            if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession){
                self.previewLayer = previewLayer
                self.view.layer.addSublayer(self.previewLayer)
                self.previewLayer.frame = self.view.layer.frame
                captureSession.startRunning()
            
                let dataOutput = AVCaptureVideoDataOutput()
                dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString)]:NSNumber(value:kCVPixelFormatType_32BGRA)
                
                dataOutput.alwaysDiscardsLateVideoFrames = true
                
                if captureSession.canAddOutput(dataOutput){
                    captureSession.addOutput(dataOutput)
                }
                
                captureSession.commitConfiguration()
            }
     
        }
     */
    @IBAction func takePhoto(_ sender: Any) {
        takePhoto = true
        print("Yeet")

    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
         if takePhoto {
             takePhoto = false
             
             if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer) {
                 
                 let photoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoVC") as! PhotoViewController
                 
                 photoVC.takenPhoto = image
                 
                 DispatchQueue.main.async {
                     self.present(photoVC, animated: true, completion: {
                         self.stopCaptureSession()
                     })
                     
                 }
             }
             
         }
     } //end captureOutput()
    
    /*
    //func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            
        print("Yee")

        if takePhoto {
            print("Yeetoniple")

            takePhoto = false
            
            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer){
                image2 = image;
                //let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let photoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoVC") as! PhotoViewController
                //self.performSegue(withIdentifier: "segue", sender: self)
                
                photoVC.takenPhoto = image
                
                DispatchQueue.main.async {
                    self.present(photoVC, animated: true, completion: {
                        self.stopCaptureSession()
                    })
                }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let photoVC = segue.destination as! PhotoViewController
        photoVC.takenPhoto = image2
    }
       */
    
    func getImageFromSampleBuffer(buffer:CMSampleBuffer) -> UIImage? {
        print("yoorto")
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer){
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect){
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }
        
        return nil
    }
    
    func stopCaptureSession(){
        self.captureSession.stopRunning()
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.captureSession.removeInput(input)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
            
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
