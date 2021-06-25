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
    var camera: AVCaptureDevice?
    var imagePicker = UIImagePickerController()
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    let screenSize: CGRect = UIScreen.main.bounds
    weak var shapeLayer_topLeft: CAShapeLayer?
    weak var shapeLayer_topRight: CAShapeLayer?
    weak var shapeLayer_bottomLeft: CAShapeLayer?
    weak var shapeLayer_bottomRight: CAShapeLayer?
    public var txtFront = ""
    public var imageFront: UIImage?
    var cameraCaptureInput: AVCaptureDeviceInput?
    var cameraCaptureOutput: AVCapturePhotoOutput?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(backButton)
        view.addSubview(pressCamera)
        view.addSubview(guideLabel)

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

        guideLabel.text = "kycContent5".localize()
        guideLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        guideLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 10).isActive = true
        guideLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true

        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        pressCamera.addTarget(self, action: #selector(takePicture), for: .touchUpInside)
        view.bringSubviewToFront(backButton)

    }

    @objc func back() {
        session.stopRunning()
        navigationController?.popViewController(animated: true)
    }

    @objc func takePicture() {
        let settings = AVCapturePhotoSettings()
        cameraCaptureOutput?.capturePhoto(with: settings, delegate: self)
    }

    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(for: KYCCameraController.self, named: "previous")?.resizeWithWidth(width: 16), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let pressCamera: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(for: KYCCameraController.self, named: "shootvidBtn"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let guideLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(255, 255, 255)
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    override func viewWillAppear(_ animated: Bool) {
        initializeCaptureSession()
    }

    func initializeCaptureSession() {
        AVCaptureDevice.requestAccess(for: .video) { success in
            if !success {
                DispatchQueue.main.async {
                    KYCController.kycDecide(currentVC: self)
                }
            }
        }
        session.sessionPreset = AVCaptureSession.Preset.high
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
                else {
            print("Unable to access front camera!")
            return
        }
        do {
            if (cameraCaptureInput == nil && cameraCaptureOutput == nil) {
                cameraCaptureInput = try AVCaptureDeviceInput(device: camera)
                cameraCaptureOutput = AVCapturePhotoOutput()
                session.addInput(cameraCaptureInput!)
                session.addOutput(cameraCaptureOutput!)
                cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
                cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                cameraPreviewLayer?.frame = CGRect(x: 16, y: 120, width: screenSize.width - 32, height: screenSize.width - 32)
                cameraPreviewLayer?.masksToBounds = true
                cameraPreviewLayer?.cornerRadius = (screenSize.width - 32) / 2
                cameraPreviewLayer?.borderWidth = 2
                cameraPreviewLayer?.borderColor = UIColor(13, 170, 39).cgColor
                cameraPreviewLayer?.connection!.videoOrientation = AVCaptureVideoOrientation.portrait
                view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
            }
            session.startRunning()
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension AvatarController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let sampleBuffer = photoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) {
            let image: UIImage = UIImage(data: dataImage)!
            let originalSize: CGSize
            let visibleLayerFrame = cameraPreviewLayer!.bounds
            let metaRect: CGRect = (cameraPreviewLayer?.metadataOutputRectConverted(fromLayerRect: visibleLayerFrame))!
            if (image.imageOrientation == UIImage.Orientation.left || image.imageOrientation == UIImage.Orientation.right) {
                originalSize = CGSize(width: image.size.height, height: image.size.width)
            } else {
                originalSize = image.size
            }
            let cropRect: CGRect = CGRect(x: metaRect.origin.x * originalSize.width,
                    y: metaRect.origin.y * originalSize.height,
                    width: metaRect.size.width * originalSize.width,
                    height: metaRect.size.height * originalSize.height).integral
            let finalImage: UIImage =
                    UIImage(cgImage: image.cgImage!.cropping(to: cropRect)!,
                            scale: 1,
                            orientation: .leftMirrored)
            let resizeImage = finalImage.resizeImage(targetSize: CGSize(width: screenSize.width - 32, height: screenSize.width - 32))
            session.stopRunning()
            let vc = AvatarConfirm()
            vc.avatarImage = resizeImage
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

