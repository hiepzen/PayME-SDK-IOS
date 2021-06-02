//
//  KYCStore.swift
//  PayMESDK
//
//  Created by HuyOpen on 1/6/21.
//

import Foundation
import AVFoundation

class KYCController {
    static var imageDocument: [UIImage]?
    static var imageAvatar: UIImage?
    static var videoKYC: URL?
    static var active: Int?
    static var flowKYC: [String: Bool]?
    static var isUpdateIdentify: Bool?
    var onOpenModalSuccess: () -> () = {}

    static var payMEFunction: PayMEFunction?

    init(payMEFunction: PayMEFunction, flowKYC: [String: Bool], onSuccess: @escaping () -> () = {}) {
        KYCController.payMEFunction = payMEFunction
        KYCController.flowKYC = flowKYC
        onOpenModalSuccess = onSuccess
    }

    func kyc() {
        PayME.currentVC?.navigationItem.hidesBackButton = true
        PayME.currentVC?.navigationController?.isNavigationBarHidden = true
        let popupKYC = PopupKYC()
        if (KYCController.flowKYC!["identifyImg"] == true) {
            print("flow1")
            popupKYC.active = 0
            PayME.currentVC?.present(popupKYC, animated: true) {
                self.onOpenModalSuccess()
            }
        } else if (KYCController.flowKYC!["faceImg"] == true) {
            print("flow2")
            popupKYC.active = 1
            PayME.currentVC?.present(popupKYC, animated: true) {
                self.onOpenModalSuccess()
            }
        } else if (KYCController.flowKYC!["kycVideo"] == true) {
            print("flow3")
            popupKYC.active = 2
            PayME.currentVC?.present(popupKYC, animated: true) {
                self.onOpenModalSuccess()
            }
        }
    }

    static func reset() {
        KYCController.imageDocument = nil
        KYCController.imageAvatar = nil
        KYCController.videoKYC = nil
        KYCController.active = nil
        KYCController.flowKYC = nil
        KYCController.isUpdateIdentify = nil
    }

    static func uploadKYC() {
        let uploadKYC = UploadKYC(
                payMEFunction: KYCController.payMEFunction!,
                imageDocument: KYCController.imageDocument,
                imageAvatar: KYCController.imageAvatar,
                videoKYC: KYCController.videoKYC,
                active: KYCController.active
        )
        uploadKYC.upload()
    }

    static func kycDecide(currentVC: UIViewController) {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == AVAuthorizationStatus.denied {
            currentVC.navigationController?.pushViewController(PermissionCamera(), animated: true)
        }
    }
}
