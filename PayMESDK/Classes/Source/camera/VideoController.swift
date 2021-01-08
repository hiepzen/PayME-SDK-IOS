//
//  KYCCameraController.swift
//  PayMESDK
//
//  Created by HuyOpen on 11/23/20.
//

import Foundation
import UIKit
import AVFoundation

class VideoController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let session = AVCaptureSession()
    var camera : AVCaptureDevice?
    var imagePicker = UIImagePickerController()
    var activeInput: AVCaptureDeviceInput?
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    var cameraCaptureOutput : AVCaptureMovieFileOutput?
    let screenSize:CGRect = UIScreen.main.bounds
    weak var shapeLayer_topLeft: CAShapeLayer?
    weak var shapeLayer_topRight: CAShapeLayer?
    weak var shapeLayer_bottomLeft: CAShapeLayer?
    weak var shapeLayer_bottomRight: CAShapeLayer?
    internal var onSuccessRecording: ((URL) -> ())? = nil
    public var txtFront = ""
    public var imageFront : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }
        
        return orientation
    }
    @objc func takePicture() {
        if cameraCaptureOutput!.isRecording == false {
        
            let connection = cameraCaptureOutput!.connection(with: AVMediaType.video)
        
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = currentVideoOrientation()
            }
        
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            connection?.isVideoMirrored = true
            
        
            let device = activeInput!.device
        
            if (device.isSmoothAutoFocusSupported) {
            
                do {
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    device.unlockForConfiguration()
                } catch {
                   print("Error setting configuration: \(error)")
                }
            
            }
            
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let fileUrl = paths[0].appendingPathComponent("output.mp4")
            try? FileManager.default.removeItem(at: fileUrl)
            cameraCaptureOutput!.startRecording(to: fileUrl, recordingDelegate: self)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.stopRecording()
            }
        }
    }
    
    func stopRecording() {
        if cameraCaptureOutput!.isRecording == true {
            cameraCaptureOutput!.stopRecording()
         }
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
            activeInput = cameraCaptureInput
            cameraCaptureOutput = AVCaptureMovieFileOutput()
            session.addInput(cameraCaptureInput)
            session.addOutput(cameraCaptureOutput!)
            cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            cameraPreviewLayer?.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
            cameraPreviewLayer?.masksToBounds = true
            cameraPreviewLayer?.connection!.videoOrientation = AVCaptureVideoOrientation.portrait

            view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
            session.startRunning()
        } catch {
            print(error.localizedDescription)
        }
    }
    
}

extension VideoController : AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
            var cv = VideoConfirm()
            cv.avatarVideo = outputFileURL
            cv.onSuccessRecording = { video in
                self.onSuccessRecording!(video)
            }
        
            self.navigationController?.pushViewController(cv, animated: true)
            
            // UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
        }
    }
}

