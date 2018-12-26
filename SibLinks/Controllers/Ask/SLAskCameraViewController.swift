//
//  SLAskCameraViewController.swift
//  SibLinks
//
//  Created by Jana on 9/7/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

class SLAskCameraViewController: SLBaseViewController {
    
    static let askCameraViewController = "SLAskCameraViewControllerID"
    var isAddMore = false
    weak var delegate: CustomCropImageController?
    
    static var controller: SLAskCameraViewController! {
        let controller = UIStoryboard(name: "AskScreen", bundle: nil).instantiateViewControllerWithIdentifier(SLAskCameraViewController.askCameraViewController) as! SLAskCameraViewController
        return controller
    }
    
    static var navigationController: UINavigationController! {
        let controller = UIStoryboard(name: "AskScreen", bundle: nil).instantiateViewControllerWithIdentifier(SLAskCameraViewController.askCameraViewController) as! SLAskCameraViewController
        let navigationController = SLRootNavigationController(rootViewController: controller)
        return navigationController
    }
    
    static let flashSettings = "IS_FLASH"
    var isOpenFlash: Bool =  NSUserDefaults.standardUserDefaults().boolForKey(SLAskCameraViewController.flashSettings) ?? false
    
    // Outlet
    @IBOutlet weak var backButton: UIButton! {
        didSet {
            backButton.addTarget(self, action: #selector(self.backAction), forControlEvents: .TouchUpInside)
        }
    }
    
    @IBOutlet weak var backButtonIcon: UIButton!
    @IBOutlet weak var cameraRollButton: UIButton! {
        didSet {
            cameraRollButton.addTarget(self, action: #selector(self.openCameraRoll), forControlEvents: .TouchUpInside)
        }
    }
    
    @IBOutlet weak var cameraTakeAPhotoButton: UIButton! {
        didSet {
            cameraTakeAPhotoButton.addTarget(self, action: #selector(self.takeAPhotoAction), forControlEvents: .TouchUpInside)
        }
    }
    
    @IBOutlet weak var cameraFlashButton: UIButton! {
        didSet {
            cameraFlashButton.addTarget(self, action: #selector(self.toggleFlash), forControlEvents: .TouchUpInside)
        }
    }
    
    @IBOutlet weak var skipButton: UIButton! {
        didSet {
            skipButton.addTarget(self, action: #selector(self.skipAction), forControlEvents: .TouchUpInside)
        }
    }
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        if isAddMore {
            skipButton.hidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func skipAction() {
        self.switchToCustomCropImageVC(nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer?.frame = self.view.bounds
    }
}

extension SLAskCameraViewController {
    
    // MARK: - Configure
    
    override func configView() {
        super.configView()
        
        self.navigationController?.navigationBarHidden = true
        
        // Set up camera
        self.setUpCamera()
        
        // Get latest photo
        self.getLatestPhotos { (cameraRollImage) in
            self.cameraRollButton.layer.borderColor = UIColor.whiteColor().CGColor
            self.cameraRollButton.layer.borderWidth = 1
            self.cameraRollButton.setBackgroundImage(cameraRollImage ?? UIImage(named: "CameraRoll"), forState: .Normal)
        }
        
        self.view.bringSubviewToFront(self.backButton)
        self.view.bringSubviewToFront(self.skipButton)
        self.view.bringSubviewToFront(self.backButtonIcon)
        self.view.bringSubviewToFront(self.cameraRollButton)
        self.view.bringSubviewToFront(self.cameraTakeAPhotoButton)
        self.view.bringSubviewToFront(self.cameraFlashButton)
    }
}

extension SLAskCameraViewController {
    
    // MARK: - Actions
    
    func backAction() {
        self.dismissViewControllerAnimated(true, completion: nil)
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
                        
                        self.switchToCustomCropImageVC(image)
                    }
                }
            })
        }
    }
    
    func toggleFlash() {
        guard let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo) else {
            return
        }
        
        if self.isOpenFlash {
            self.setFlashMode(.Off, device: device)
            self.cameraFlashButton.setBackgroundImage(UIImage(named: "CameraFlashOff"), forState: .Normal)
        } else {
            self.setFlashMode(.On, device: device)
            self.cameraFlashButton.setBackgroundImage(UIImage(named: "CameraFlashOn"), forState: .Normal)
        }
        self.isOpenFlash = !self.isOpenFlash
        NSUserDefaults.standardUserDefaults().setBool(self.isOpenFlash, forKey: SLAskCameraViewController.flashSettings)
    }
    
}

extension SLAskCameraViewController {
    
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

extension SLAskCameraViewController {
    
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
            
            if (self.isOpenFlash == true) {
                self.cameraFlashButton.setBackgroundImage(UIImage(named: "CameraFlashOn"), forState: .Normal)
                self.setFlashMode(.On, device: AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo))
            } else {
                self.cameraFlashButton.setBackgroundImage(UIImage(named: "CameraFlashOff"), forState: .Normal)
                self.setFlashMode(.Off, device: AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo))
            }
        }
    }
    
}

extension SLAskCameraViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: - UINavigationControllerDelegate, UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil);
        
        self.switchToCustomCropImageVC(image)
    }
    
}

extension SLAskCameraViewController {
    
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
extension SLAskCameraViewController {
    // MARK: custom method
    func switchToCustomCropImageVC(image: UIImage?) {
        if isAddMore {
            if let image = image {
                delegate?.image = image
                delegate?.photos.append(image)
                delegate?.originPhotos.append(image)
            }
            self.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        let storyboard = UIStoryboard(name: "CustomCropImageScreen", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("CustomCropImage") as! CustomCropImageController
        if let image = image {
            vc.image = image
            vc.photos.append(image)
            vc.originPhotos.append(image)
        }
//        self.addChildViewController(vc)
//        self.view.addSubview(vc.view)
//        UIView.performWithoutAnimation {
//            self.navigationController?.showViewController(vc, sender: self)
//        }
        self.navigationController?.viewControllers = [vc]
    }
}
