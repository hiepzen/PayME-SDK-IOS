//
//  KYCCameraController.swift
//  PayMESDK
//
//  Created by HuyOpen on 11/23/20.
//

import Foundation
import UIKit
import AVFoundation
import SVGKit

class KYCCameraController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let session = AVCaptureSession()
    var camera: AVCaptureDevice?
    var imagePicker = UIImagePickerController()
    private let popupPassport: PopupPassport = {
        let popUpWindowView = PopupPassport()
        popUpWindowView.translatesAutoresizingMaskIntoConstraints = false
        return popUpWindowView
    }()
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    let screenSize: CGRect = UIScreen.main.bounds
    weak var shapeLayer_topLeft: CAShapeLayer?
    weak var shapeLayer_topRight: CAShapeLayer?
    weak var shapeLayer_bottomLeft: CAShapeLayer?
    weak var shapeLayer_bottomRight: CAShapeLayer?
    var txtFront = ""
    var imageFront: UIImage?
    var cameraCaptureInput: AVCaptureDeviceInput?
    var cameraCaptureOutput: AVCapturePhotoOutput?
    let kycDocumentController = KYCDocumentController()

    public var data: [KYCDocument] = [
        KYCDocument(id: "0", name: "identifyCard".localize(), active: true),
        KYCDocument(id: "1", name: "identifyCitizen".localize(), active: false),
        KYCDocument(id: "2", name: "passport".localize(), active: false)
    ]
    public var active = 0

    let getPhoto: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(for: QRScannerController.self, named: "photo"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let titleButton: UIButton = {
        let button = UIButton()
        button.setTitle("Chọn hình", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    @objc func choiceImage() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(pressCamera)
        view.addSubview(guideLabel)
        view.addSubview(choiceDocumentType)
        view.addSubview(frontSide)
        view.addSubview(getPhoto)
        view.addSubview(titleButton)
        view.addSubview(popupPassport)

        getPhoto.isHidden = true
        titleButton.isHidden = true

        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                backButton.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0),
                titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.3),
                getPhoto.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -45),
                pressCamera.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -18)
            ])
        } else {
            let standardSpacing: CGFloat = 8.0
            NSLayoutConstraint.activate([
                backButton.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing),
                titleLabel.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing + 5),
                getPhoto.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: -40),
                pressCamera.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: -standardSpacing)
            ])
        }
        backButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 30).isActive = true

        choiceDocumentType.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
        choiceDocumentType.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 37).isActive = true
        choiceDocumentType.heightAnchor.constraint(equalToConstant: 30).isActive = true

        getPhoto.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        getPhoto.widthAnchor.constraint(equalToConstant: 32).isActive = true
        getPhoto.heightAnchor.constraint(equalToConstant: 32).isActive = true

        pressCamera.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pressCamera.widthAnchor.constraint(equalToConstant: 80).isActive = true
        pressCamera.heightAnchor.constraint(equalToConstant: 80).isActive = true

        titleLabel.text = "captureDocument".localize()
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        if (imageFront != nil) {
            txtFront = "backDocument".localize()
            choiceDocumentType.isHidden = true
        } else {
            txtFront = "frontDocument".localize()
        }
        frontSide.text = self.txtFront
        frontSide.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 44).isActive = true
        frontSide.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true

        guideLabel.text = "kycContent4".localize()
        guideLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        guideLabel.topAnchor.constraint(equalTo: choiceDocumentType.bottomAnchor, constant: (self.cameraPreviewLayer?.bounds.height ?? (screenSize.width - 32) * 0.67) + 60).isActive = true
        guideLabel.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true

        titleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        titleButton.topAnchor.constraint(equalTo: getPhoto.bottomAnchor).isActive = true

        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        pressCamera.addTarget(self, action: #selector(takePicture), for: .touchUpInside)
        if KYCController.isUpdateIdentify ?? false {
            active = 1
            choiceDocumentType.setTitle("identifyCitizen".localize(), for: .normal)
            choiceDocumentType.imageEdgeInsets = UIEdgeInsets(top: 0, left: 185, bottom: 0, right: 0)
        } else {
            choiceDocumentType.addTarget(self, action: #selector(choiceDocument), for: .touchUpInside)
        }
        getPhoto.addTarget(self, action: #selector(choiceImage), for: .touchUpInside)
        titleButton.addTarget(self, action: #selector(choiceImage), for: .touchUpInside)
        view.bringSubviewToFront(backButton)

        popupPassport.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        popupPassport.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        popupPassport.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        popupPassport.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        popupPassport.continueButton.addTarget(self, action: #selector(acceptOptionPassport), for: .touchUpInside)
        popupPassport.cancelButton.addTarget(self, action: #selector(closePopupPassport), for: .touchUpInside)
        popupPassport.isHidden = true
    }

    @objc func choiceDocument() {
        kycDocumentController.data = data
        kycDocumentController.active = active
        kycDocumentController.setOnSuccessChoiceKYC(onSuccessChoiceKYC: { response in
            DispatchQueue.main.async {
                if (response == 0) {
                    self.choiceDocumentType.setTitle("identifyCard".localize(), for: .normal)
                    self.choiceDocumentType.imageEdgeInsets = UIEdgeInsets(top: 0, left: 185, bottom: 0, right: 0) //adjust these to have fit right
                    self.active = response
                }
                if (response == 1) {
                    self.choiceDocumentType.setTitle("identifyCitizen".localize(), for: .normal)
                    self.choiceDocumentType.imageEdgeInsets = UIEdgeInsets(top: 0, left: 160, bottom: 0, right: 0) //adjust these to have fit right
                    self.active = response
                }
                if (response == 2) {
                    self.popupPassport.isHidden = false
                }
            }
        })
        presentPanModal(kycDocumentController)
    }

    @objc func closePopupPassport() {
        popupPassport.isHidden = true
        kycDocumentController.onSelectionRow(index: active)
        kycDocumentController.tableView.reloadData()
        presentPanModal(kycDocumentController)
    }

    @objc func acceptOptionPassport() {
        choiceDocumentType.setTitle("passport".localize(), for: .normal)
        choiceDocumentType.imageEdgeInsets = UIEdgeInsets(top: 0, left: 80, bottom: 0, right: 0) //adjust these to have fit right
        active = 2
        popupPassport.isHidden = true
    }

    @objc func back() {
        session.stopRunning()
        navigationController?.popViewController(animated: true)
    }

    @objc func takePicture() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
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
        let imageSVG = SVGKImage(for: KYCCameraController.self, named: "buttonTakepic")
        imageSVG?.fillColor(color: UIColor(hexString: PayME.configColor[0]), opacity: 1)
        button.setImage(imageSVG?.uiImage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(255, 255, 255)
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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

    let frontSide: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(230, 230, 230)
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let choiceDocumentType: UIButton = {
        let button = UIButton()
        button.setTitle("Chứng minh nhân dân", for: .normal)
        button.setImage(UIImage(for: KYCCameraController.self, named: "24Px"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 185, bottom: 0, right: 0)
        return button
    }()

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
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

        guard let camera = AVCaptureDevice.default(for: AVMediaType.video)
                else {
            print("Unable to access back camera!")
            return
        }
        do {
            if (cameraCaptureInput == nil && cameraCaptureOutput == nil) {
                cameraCaptureInput = try AVCaptureDeviceInput(device: camera)
                session.addInput(cameraCaptureInput!)
                cameraCaptureOutput = AVCapturePhotoOutput()
                session.addOutput(cameraCaptureOutput!)
                cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
                cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                cameraPreviewLayer?.frame = CGRect(x: 16, y: 160, width: screenSize.width - 32, height: (screenSize.width - 32) * 0.67)
                cameraPreviewLayer?.masksToBounds = true
                cameraPreviewLayer?.cornerRadius = 15
                cameraPreviewLayer?.borderWidth = 2
                cameraPreviewLayer?.borderColor = UIColor(255, 255, 255).cgColor
                cameraPreviewLayer?.connection!.videoOrientation = AVCaptureVideoOrientation.portrait
                view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
            }
            session.startRunning()
        } catch {
            print(error.localizedDescription)
        }
    }

    private func openConfirmImage(image: UIImage) {
        if (imageFront == nil) {
            let confirmKYCFront = KYCFrontController()
            confirmKYCFront.kycImage = image
            confirmKYCFront.active = active
            confirmKYCFront.parentVC = self
            navigationController?.pushViewController(confirmKYCFront, animated: true)
        } else {
            let confirmKYCBack = KYCBackController()
            confirmKYCBack.kycImage = imageFront
            confirmKYCBack.kycImageBack = image
            confirmKYCBack.active = active
            navigationController?.pushViewController(confirmKYCBack, animated: true)

        }
    }

    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage else {
            return
        }
        dismiss(animated: true, completion: nil)
        session.stopRunning()
        openConfirmImage(image: image)
    }
}


extension KYCCameraController: AVCapturePhotoCaptureDelegate {
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
                            orientation: image.imageOrientation)
            let resizeImage = finalImage.resizeImage(targetSize: CGSize(width: 512, height: 512 * 0.67))
            session.stopRunning()
            openConfirmImage(image: resizeImage)
        }
    }
}

