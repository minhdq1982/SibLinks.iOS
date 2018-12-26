//
//  SLCameraViewController.swift
//  SibLinks
//
//  Created by Jana on 9/29/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

protocol SLCameraViewControllerDelegate {
    func result(image: UIImage)
}

class SLCameraViewController: UIViewController {

    static let cameraViewController = "SLCameraViewController"
    static var controller: SLCameraViewController! {
        let controller = SLCameraViewController(nibName: SLCameraViewController.cameraViewController, bundle: nil)
        return controller
    }
    
    @IBOutlet weak var closeCameraControllerButton: UIButton! {
        didSet {
            closeCameraControllerButton.addTarget(self, action: #selector(self.closeViewControllerWithAnimated), forControlEvents: .TouchUpInside)
        }
    }
    
    @IBOutlet weak var openCameraRollButton: UIButton! {
        didSet {
            openCameraRollButton.addTarget(self, action: #selector(self.openCameraRoll), forControlEvents: .TouchUpInside)
        }
    }
    
    @IBOutlet weak var capturePhotoButton: UIButton! {
        didSet {
            capturePhotoButton.addTarget(self, action: #selector(self.takeAPhotoAction), forControlEvents: .TouchUpInside)
        }
    }
    
    @IBOutlet weak var flashButton: UIButton! {
        didSet {
            flashButton.addTarget(self, action: #selector(self.toggleFlash), forControlEvents: .TouchUpInside)
        }
    }
    
    var delegate: AnyObject?
    
    static let flashSettings = "IS_FLASH"
    var flashEnable: Bool =  NSUserDefaults.standardUserDefaults().boolForKey(SLCameraViewController.flashSettings) ?? false
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up camera
        self.setUpCamera()
        
        // Get latest photo
        self.getLatestPhotos { (cameraRollImage) in
            self.openCameraRollButton.layer.borderColor = UIColor.whiteColor().CGColor
            self.openCameraRollButton.layer.borderWidth = 1
            self.openCameraRollButton.setBackgroundImage(cameraRollImage ?? UIImage(named: "CameraRoll"), forState: .Normal)
        }
        
        self.view.bringSubviewToFront(self.closeCameraControllerButton)
        self.view.bringSubviewToFront(self.openCameraRollButton)
        self.view.bringSubviewToFront(self.capturePhotoButton)
        self.view.bringSubviewToFront(self.flashButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer?.frame = self.view.bounds
    }
}

extension SLCameraViewController {
    
    // MARK: - Actions
    
    func closeViewControllerWithAnimated() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func closeViewControllerWithoutAnimated() {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func openCameraRoll() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func takeAPhotoAction() {
        guard let stillImageOutput = self.stillImageOutput else {
            return
        }
        
        if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    if let dataProvider = CGDataProviderCreateWithCFData(imageData) {
                        let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                        
                        let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                        
                        self.closeViewControllerWithoutAnimated()
                        if let delegate = self.delegate as? SLCameraViewControllerDelegate {
                            delegate.result(image)
                        }
                    }
                }
            })
        }
    }
    
    func toggleFlash() {
        guard let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo) else {
            return
        }
        
        if self.flashEnable {
            self.setFlashMode(.Off, device: device)
            self.flashButton.setBackgroundImage(UIImage(named: "CameraFlashOff"), forState: .Normal)
        } else {
            self.setFlashMode(.On, device: device)
            self.flashButton.setBackgroundImage(UIImage(named: "CameraFlashOn"), forState: .Normal)
        }
        self.flashEnable = !self.flashEnable
        NSUserDefaults.standardUserDefaults().setBool(self.flashEnable, forKey: SLAskCameraViewController.flashSettings)
    }
    
}

extension SLCameraViewController {
    
    // MARK: - Flash mode
    
    func setFlashMode(flashMode: AVCaptureFlashMode, device: AVCaptureDevice){
        if device.hasFlash && device.isFlashModeSupported(flashMode) {
            do {
                try device.lockForConfiguration()
                device.flashMode = flashMode
                device.unlockForConfiguration()
            } catch {}
        }
    }
}

extension SLCameraViewController {
    
    // MARK: - Set up camera
    
    func setUpCamera() {
        guard AVCaptureDevice.devices().count > 0 else {
            return
        }
        
        self.captureSession = AVCaptureSession()
        self.captureSession?.sessionPreset = AVCaptureSessionPresetPhoto
        
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if error == nil && self.captureSession!.canAddInput(input) {
            self.captureSession!.addInput(input)
            
            self.stillImageOutput = AVCaptureStillImageOutput()
            self.stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession!.canAddOutput(self.stillImageOutput) {
                self.captureSession!.addOutput(self.stillImageOutput)
                
                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                self.previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                self.previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                self.view.layer.addSublayer(self.previewLayer!)
                
                self.captureSession!.startRunning()
            }
            
            if (self.flashEnable == true) {
                self.flashButton.setBackgroundImage(UIImage(named: "CameraFlashOn"), forState: .Normal)
                self.setFlashMode(.On, device: AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo))
            } else {
                self.flashButton.setBackgroundImage(UIImage(named: "CameraFlashOff"), forState: .Normal)
                self.setFlashMode(.Off, device: AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo))
            }
        }
    }
    
}

extension SLCameraViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: - UINavigationControllerDelegate, UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil);
        
        self.closeViewControllerWithoutAnimated()
        if let delegate = self.delegate as? SLCameraViewControllerDelegate {
            delegate.result(image)
        }
    }
    
}

extension SLCameraViewController {
    
    // MARK: - Get latest photo
    
    func getLatestPhotos(completion completionBlock : (UIImage? -> ()))   {
        let library = ALAssetsLibrary();
        var stopped = false
        
        library.enumerateGroupsWithTypes(ALAssetsGroupSavedPhotos, usingBlock: { (group, stop) -> Void in
            group?.setAssetsFilter(ALAssetsFilter.allPhotos())
            
            group?.enumerateAssetsWithOptions(NSEnumerationOptions.Reverse, usingBlock: {
                (asset : ALAsset!, index, stopEnumeration) -> Void in
                if (!stopped) {
                    let image = UIImage(CGImage: asset.defaultRepresentation().fullScreenImage().takeUnretainedValue())
                    stopEnumeration.memory = ObjCBool(true)
                    stop.memory = ObjCBool(true)
                    completionBlock(image)
                    stopped = true
                }
            })
            }, failureBlock: nil)
    }
    
}
