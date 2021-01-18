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
        var popupKYC = PopupKYC()
        if (KYCController.flowKYC!["kycIdentifyImg"]! == true) {
            popupKYC.active = 0
            PayME.currentVC?.present(popupKYC, animated: true)
        } else if (KYCController.flowKYC!["kycFace"]! == true) {
            popupKYC.active = 1
            PayME.currentVC?.present(popupKYC, animated: true)
        } else if (KYCController.flowKYC!["kycVideo"] == true) {
            popupKYC.active = 2
            PayME.currentVC?.present(popupKYC, animated: true)
        }
    }
    
    internal static func uploadKYC() {
        let uploadKYC = UploadKYC(imageDocument: KYCController.imageDocument, imageAvatar: KYCController.imageAvatar, videoKYC: KYCController.videoKYC, active: KYCController.active)
        uploadKYC.upload()
    }
    
    internal static func kycDecide(currentVC : UIViewController) {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) !=  AVAuthorizationStatus.authorized {
            currentVC.navigationController?.pushViewController(PermissionCamera(), animated: true)
        }
    }
    /*
    private func kycByDocument() {
        serialQueue.async{
            DispatchQueue.main.async {
                if (self.flowKYC["kycIdentifyImg"] == true) {
                    let kycDocument = KYCCameraController()
                    
                    PayME.currentVC?.navigationController?.pushViewController(kycDocument, animated: true)
//                    if PayME.currentVC?.navigationController != nil {
//                        PayME.currentVC?.navigationController?.pushViewController(kycDocument, animated: true)
//                    } else {
//                        PayME.currentVC?.present(kycDocument, animated: true, completion: nil)
//                    }
                    kycDocument.onSuccessCapture = { image, active in
                        if (self.imageDocument == nil && self.active == nil) {
                            self.imageDocument = image
                            self.active = active
                            self.dispatchGroup.leave()
                        } else {
                            self.imageDocument = image
                            self.active = active
                            self.kycByAvatar()
                            self.kycByVideo()
                            self.uploadKYC()
                        }
                    }
                } else {
                    self.dispatchGroup.leave()
                }
                
            }
        }
    }
    private func kycByAvatar() {
        serialQueue.async{
            self.dispatchGroup.wait()
            self.dispatchGroup.enter()
            if (self.flowKYC["kycFace"] == true ) {
                DispatchQueue.main.async {
                    let avatarController = AvatarController()
                    
                    if PayME.currentVC?.navigationController != nil {
                        PayME.currentVC?.navigationController?.pushViewController(avatarController, animated: true)
                    } else {
                        PayME.currentVC?.present(avatarController, animated: true, completion: nil)
                    }
                    avatarController.onSuccessCapture = { avatar in
                        if (self.imageAvatar == nil) {
                            self.imageAvatar = avatar
                            self.dispatchGroup.leave()
                        } else {
                            self.imageAvatar = avatar
                            self.kycByVideo()
                            self.uploadKYC()
                        }
                    }
                }
            } else {
                self.dispatchGroup.leave()
            }
        }
    }
    private func kycByVideo() {
        serialQueue.async{
            self.dispatchGroup.wait()
            self.dispatchGroup.enter()
            if (self.flowKYC["kycVideo"] == true) {
                DispatchQueue.main.async {
                    let videoController = VideoController()
                    videoController.onSuccessRecording = { video in
                        if (self.videoKYC == nil) {
                            self.videoKYC = video
                            self.dispatchGroup.leave()
                        } else {
                            self.videoKYC = video
                            self.uploadKYC()
                        }
                    }
                    if PayME.currentVC?.navigationController != nil {
                        PayME.currentVC?.navigationController?.pushViewController(videoController, animated: true)
                    } else {
                        PayME.currentVC?.present(videoController, animated: true, completion: nil)
                    }
                }
            } else {
                self.dispatchGroup.leave()
            }
        }
    }
     */
    
}
