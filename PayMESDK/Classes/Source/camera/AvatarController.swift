//
//  KYCCameraController.swift
//  PayMESDK
//
//  Created by HuyOpen on 11/23/20.
//

import Foundation
import UIKit
import AVFoundation
class AvatarController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let session = AVCaptureSession()
    var camera : AVCaptureDevice?
    var imagePicker = UIImagePickerController()
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    var cameraCaptureOutput : AVCapturePhotoOutput?
    let screenSize:CGRect = UIScreen.main.bounds
    weak var shapeLayer_topLeft: CAShapeLayer?
    weak var shapeLayer_topRight: CAShapeLayer?
    weak var shapeLayer_bottomLeft: CAShapeLayer?
    weak var shapeLayer_bottomRight: CAShapeLayer?
    public var txtFront = ""
    public var imageFront : UIImage?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(backButton)
        view.addSubview(pressCamera)
        view.addSubview(guideLabel)
        
        initializeCaptureSession()
        if #available(iOS 11, *) {
          let guide = view.safeAreaLayoutGuide
          NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0),
            pressCamera.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -18)
           ])
        } else {
           let standardSpacing: CGFloat = 8.0
           NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing),
            pressCamera.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: -standardSpacing)
           ])
        }
        backButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 30).isActive = true

        pressCamera.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pressCamera.widthAnchor.constraint(equalToConstant: 80).isActive = true
        pressCamera.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        guideLabel.text = "Vui lòng giữ gương mặt trong khung tròn"
        guideLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        guideLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 10).isActive = true
        guideLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        pressCamera.addTarget(self, action: #selector(takePicture), for: .touchUpInside)
        view.bringSubviewToFront(backButton)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func back () {
        self.session.stopRunning()
        
        self.navigationController?.popViewController(animated: true)

    }
    @objc func takePicture() {
        let settings = AVCapturePhotoSettings()
        cameraCaptureOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    
    let backButton: UIButton = {
        let button = UIButton()
        let bundle = Bundle(for: KYCCameraController.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let image = UIImage(named: "previous", in: resourceBundle, compatibleWith: nil)?.resizeWithWidth(width: 16)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let pressCamera: UIButton = {
        let button = UIButton()
        let bundle = Bundle(for: KYCCameraController.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let image = UIImage(named: "shootvidBtn", in: resourceBundle, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let guideLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor(255,255,255)
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    override func viewWillAppear(_ animated: Bool){
        self.session.startRunning()
    }
    
    func initializeCaptureSession() {
        
        session.sessionPreset = AVCaptureSession.Preset.high
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
            else {
                print("Unable to access front camera!")
                return
        }
        do {
            let cameraCaptureInput = try AVCaptureDeviceInput(device: camera)
            cameraCaptureOutput = AVCapturePhotoOutput()
            session.addInput(cameraCaptureInput)
            session.addOutput(cameraCaptureOutput!)
            cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            cameraPreviewLayer?.frame = CGRect(x: 16, y: 120, width: screenSize.width - 32, height: screenSize.width-32)
            cameraPreviewLayer?.masksToBounds = true
            cameraPreviewLayer?.cornerRadius = (screenSize.width - 32) / 2
            cameraPreviewLayer?.borderWidth = 2
            cameraPreviewLayer?.borderColor = UIColor(13,170,39).cgColor
            cameraPreviewLayer?.connection!.videoOrientation = AVCaptureVideoOrientation.portrait
            
            view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
            session.startRunning()
        } catch {
            print(error.localizedDescription)
        }
        
        
    }
    
}

extension AvatarController : AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let sampleBuffer = photoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
        {
            let image : UIImage = UIImage(data: dataImage)!

            let originalSize : CGSize
            let visibleLayerFrame = self.cameraPreviewLayer!.bounds // THE ACTUAL VISIBLE AREA IN THE LAYER FRAME

            // Calculate the fractional size that is shown in the preview
            let metaRect : CGRect = (self.cameraPreviewLayer?.metadataOutputRectConverted(fromLayerRect: visibleLayerFrame))!
            if (image.imageOrientation == UIImage.Orientation.left || image.imageOrientation == UIImage.Orientation.right) {
                // For these images (which are portrait), swap the size of the
                // image, because here the output image is actually rotated
                // relative to what you see on screen.
                originalSize = CGSize(width: image.size.height, height: image.size.width)
            }
            else {
                originalSize = image.size
            }

            // metaRect is fractional, that's why we multiply here.
            let cropRect : CGRect = CGRect( x: metaRect.origin.x * originalSize.width,
                                            y: metaRect.origin.y * originalSize.height,
                                            width: metaRect.size.width * originalSize.width,
                                            height: metaRect.size.height * originalSize.height).integral
            let finalImage : UIImage =
            UIImage(cgImage: image.cgImage!.cropping(to: cropRect)!,
                scale:1,
                orientation: .leftMirrored)
            let resizeImage = finalImage.resizeImage(targetSize: CGSize(width:screenSize.width - 32, height: screenSize.width - 32))
            self.session.stopRunning()
            let vc = AvatarConfirm()
            vc.avatarImage = resizeImage
            self.navigationController?.pushViewController(vc, animated: true)
        
        }
    }
}

