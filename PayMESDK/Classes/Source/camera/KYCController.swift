//
//  KYCController.swift
//  PayMESDK
//
//  Created by HuyOpen on 1/6/21.
//

import Foundation

public class KYCController{
    internal var imageDocument : [UIImage]?
    internal var imageAvatar : UIImage?
    internal var videoKYC : URL?
    internal var active: Int?
    internal var flowKYC: [String: Bool]
    let dispatchGroup = DispatchGroup()
    let serialQueue = DispatchQueue(label: "serialQueue")



    
    public init(flowKYC: [String: Bool]){
        self.flowKYC = flowKYC
    }
    public func kyc(){
        PayME.currentVC?.navigationItem.hidesBackButton = true
        PayME.currentVC?.navigationController?.isNavigationBarHidden = true
        /*
        if(flowKYC["a"] == true){
            PayME.currentVC?.navigationItem.hidesBackButton = true
            PayME.currentVC?.navigationController?.isNavigationBarHidden = true
            var kycDocument = KYCCameraController()
            PayME.currentVC?.navigationController?.pushViewController(kycDocument, animated: true)
            dispatchGroup.enter()
        }
        */
        dispatchGroup.enter()
        kycByDocument()
        kycByAvatar()
        kycByVideo()
        uploadKYC()
        
        
    }
    private func uploadKYC() {
        serialQueue.async{
            self.dispatchGroup.wait()
            self.dispatchGroup.enter()
            let uploadKYC = UploadKYC(imageDocument: self.imageDocument, imageAvatar: self.imageAvatar, videoKYC: self.videoKYC, active: self.active)
            uploadKYC.upload()
            self.dispatchGroup.leave()

        }
    }

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
    
}
