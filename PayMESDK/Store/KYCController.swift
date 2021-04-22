//
//  KYCController.swift
//  PayMESDK
//
//  Created by HuyOpen on 1/6/21.
//

import Foundation
import AVFoundation

public class KYCController{
    internal static var imageDocument : [UIImage]?
    internal static var imageAvatar : UIImage?
    internal static var videoKYC : URL?
    internal static var active: Int?
    internal static var flowKYC: [String: Bool]?

    public init(flowKYC: [String: Bool]){
        KYCController.flowKYC = flowKYC
    }

    public func kyc(){
        PayME.currentVC?.navigationItem.hidesBackButton = true
        PayME.currentVC?.navigationController?.isNavigationBarHidden = true
        let popupKYC = PopupKYC()
        if (KYCController.flowKYC!["kycIdentifyImg"]! == true) {
            print("flow1")
            popupKYC.active = 0
            PayME.currentVC?.present(popupKYC, animated: true)
        } else if (KYCController.flowKYC!["kycFace"]! == true) {
            print("flow2")
            popupKYC.active = 1
            PayME.currentVC?.present(popupKYC, animated: true)
        } else if (KYCController.flowKYC!["kycVideo"] == true) {
            print("flow3")
            popupKYC.active = 2
            PayME.currentVC?.present(popupKYC, animated: true)
        }
    }
    
    internal static func reset() {
        KYCController.imageDocument = nil
        KYCController.imageAvatar = nil
        KYCController.videoKYC = nil
        KYCController.active = nil
        KYCController.flowKYC = nil
    }
    
    internal static func uploadKYC() {
        let uploadKYC = UploadKYC(imageDocument: KYCController.imageDocument, imageAvatar: KYCController.imageAvatar, videoKYC: KYCController.videoKYC, active: KYCController.active)
        uploadKYC.upload()
    }
    
    internal static func kycDecide(currentVC : UIViewController) {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus ==  AVAuthorizationStatus.denied {
            currentVC.navigationController?.pushViewController(PermissionCamera(), animated: true)
        }
    }
}
