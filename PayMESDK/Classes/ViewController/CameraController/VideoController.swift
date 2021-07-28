//
//  KYCCameraController.swift
//  PayMESDK
//
//  Created by HuyOpen on 11/23/20.
//

import Foundation
import UIKit
import AVFoundation
import Lottie


class VideoController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let session = AVCaptureSession()
    var camera: AVCaptureDevice?
    var imagePicker = UIImagePickerController()
    var activeInput: AVCaptureDeviceInput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var cameraCaptureOutput: AVCaptureMovieFileOutput?
    let screenSize: CGRect = UIScreen.main.bounds
    weak var shapeLayer_topLeft: CAShapeLayer?
    weak var shapeLayer_topRight: CAShapeLayer?
    weak var shapeLayer_bottomLeft: CAShapeLayer?
    weak var shapeLayer_bottomRight: CAShapeLayer?
    var txtFront = ""
    var imageFront: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        view.addSubview(backButton)
        view.addSubview(guideLabel)
        view.addSubview(animationButton)

        setupAnimation()

        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                backButton.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0),
                animationButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -18)
            ])
        } else {
            let standardSpacing: CGFloat = 8.0
            NSLayoutConstraint.activate([
                backButton.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing),
                animationButton.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: -standardSpacing)
            ])
        }

        animationButton.translatesAutoresizingMaskIntoConstraints = false

        backButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 30).isActive = true

        animationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        animationButton.widthAnchor.constraint(equalToConstant: 160).isActive = true
        animationButton.heightAnchor.constraint(equalToConstant: 160).isActive = true

        guideLabel.text = "kycContent1".localize()
        guideLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        guideLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 10).isActive = true
        guideLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true

        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        animationButton.addTarget(self, action: #selector(takePicture), for: .touchUpInside)

        view.bringSubviewToFront(backButton)
    }

    @objc func back() {
        session.stopRunning()
        navigationController?.popViewController(animated: true)
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
        if (cameraCaptureOutput != nil) {
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
    }

    func stopRecording() {
        if cameraCaptureOutput!.isRecording == true {
            cameraCaptureOutput!.stopRecording()
        }
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

    func setupAnimation() {
        let bundle = Bundle(for: ResultView.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let animation = Animation.named("Dangquay_3", bundle: resourceBundle!)
        animationButton.animation = animation

        let color = ColorValueProvider(UIColor(hexString: PayME.configColor[0]).lottieColorValue)
        let keyPath = AnimationKeypath(keypath: "Camera.**.Color")
        animationButton.setValueProvider(color, keypath: keyPath)

        animationButton.contentMode = .scaleAspectFit
        animationButton.setPlayRange(fromMarker: "touchDownStart", toMarker: "touchDownEnd", event: .touchDown)
    }

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

    let animationButton = AnimatedButton()

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        initializeCaptureSession()
        setupAnimation()
    }

    func initializeCaptureSession() {
        AVCaptureDevice.requestAccess(for: .video) { success in
            if !success {
                DispatchQueue.main.async {
                    KYCController.kycDecide(currentVC: self)
                }
            }
        }
        if (cameraCaptureOutput == nil) {
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
        session.startRunning()
    }
}

extension VideoController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
            let confirmView = VideoConfirm()
            confirmView.avatarVideo = outputFileURL
            navigationController?.pushViewController(confirmView, animated: true)
        }
    }
}

