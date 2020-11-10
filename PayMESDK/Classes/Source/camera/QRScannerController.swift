//
//  QRScannerController.swift
//  PayMESDK
//
//  Created by HuyOpen on 11/8/20.
//

import UIKit
import AVFoundation

class QRScannerController: UIViewController {

    // @IBOutlet var topbar: UIView!
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    private var onScanSuccess: ((String) -> ())? = nil
    private var onScanFail: ((String) -> ())? = nil
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
   
    public func setScanSuccess(onScanSuccess: @escaping (String) -> ()) {
        self.onScanSuccess = onScanSuccess
    }
    public func setScanFail(onScanFail: @escaping (String) -> ()){
        self.onScanFail = onScanFail
    }
    
    let messageLabel : UILabel = {
        let messageLabel = UILabel()
        messageLabel.textColor = .white
        messageLabel.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        messageLabel.font = UIFont(name: "Arial", size: 16)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textAlignment = .center
        return messageLabel
    }()
    
    let scanLabel: UILabel = {
        let scanLabel = UILabel()
        scanLabel.textColor = .white
        scanLabel.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        scanLabel.font = UIFont(name: "Arial", size: 16)
        scanLabel.translatesAutoresizingMaskIntoConstraints = false
        scanLabel.text = "SCAN"
        return scanLabel
    }()
    
    let topView : UIView = {
        let topView  = UIView()
        topView.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.5)
        topView.translatesAutoresizingMaskIntoConstraints = false
        return topView
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(messageLabel)
        view.addSubview(topView)
        topView.addSubview(scanLabel)
        // Get the back-facing camera for capturing videos
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
//            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        
        topView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        topView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        topView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        scanLabel.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        scanLabel.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        
        messageLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10).isActive = true
        messageLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Move the message label and top bar to the front
        view.bringSubviewToFront(messageLabel)
        view.bringSubviewToFront(topView)

        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helper methods

    
    func launchApp(decodedURL: String) {
        
        if presentedViewController != nil {
            return
        }
        self.onScanSuccess!(decodedURL)
       
    }
  private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
    layer.videoOrientation = orientation
    videoPreviewLayer?.frame = self.view.bounds
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    if let connection =  self.videoPreviewLayer?.connection  {
      let currentDevice: UIDevice = UIDevice.current
      let orientation: UIDeviceOrientation = currentDevice.orientation
      let previewLayerConnection : AVCaptureConnection = connection
      
      if previewLayerConnection.isVideoOrientationSupported {
        switch (orientation) {
        case .portrait:
          updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
          break
        case .landscapeRight:
          updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
          break
        case .landscapeLeft:
          updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
          break
        case .portraitUpsideDown:
          updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
          break
        default:
          updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
          break
        }
      }
    }
  }
}

extension QRScannerController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                self.captureSession.stopRunning()
                launchApp(decodedURL: metadataObj.stringValue!)
                messageLabel.text = metadataObj.stringValue
            }
        }
    }
    
}

