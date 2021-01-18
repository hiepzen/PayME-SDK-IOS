//
//  KYCController.swift
//  PayMESDK
//
//  Created by HuyOpen on 1/6/21.
//

import Foundation

public class UploadKYC{
    internal var imageDocument : [UIImage]?
    internal var imageAvatar : UIImage?
    internal var videoKYC : URL?
    internal var active: Int?
    internal var flowKYC: [String: Bool]?
    private var pathFront : String?
    private var pathBack : String?
    private var pathAvatar : String?
    private var pathVideo : String?
    let dispatchGroup = DispatchGroup()
    let serialQueue = DispatchQueue(label: "uploadQueue")

    public init(imageDocument : [UIImage]?, imageAvatar : UIImage?, videoKYC : URL?, active: Int?){
        self.imageDocument = imageDocument
        self.imageAvatar = imageAvatar
        self.videoKYC = videoKYC
        self.active = active
    }
    public func upload(){
        
        /*
        if(flowKYC["a"] == true){
            PayME.currentVC?.navigationItem.hidesBackButton = true
            PayME.currentVC?.navigationController?.isNavigationBarHidden = true
            var kycDocument = KYCCameraController()
            PayME.currentVC?.navigationController?.pushViewController(kycDocument, animated: true)
            dispatchGroup.enter()
        }
        */
        DispatchQueue.main.async {
            PayME.currentVC?.navigationItem.hidesBackButton = true
            PayME.currentVC?.navigationController?.isNavigationBarHidden = true
            PayME.currentVC?.showSpinner(onView: (PayME.currentVC?.view)!)
        }
        dispatchGroup.enter()
        uploadDocument()
        uploadAvatar()
        uploadVideo()
        verifyKYC()
    }
    private func verifyKYC() {
        serialQueue.async{
            self.dispatchGroup.wait()
            self.dispatchGroup.enter()
            API.verifyKYC(pathFront: self.pathFront, pathBack: self.pathBack, pathAvatar: self.pathAvatar, pathVideo: self.pathVideo,
              onSuccess: { response in
                let result = response["Account"]!["KYC"] as! [String: AnyObject]
                let succeeded = result["succeeded"] as! Bool
                if (succeeded == true) {
                    DispatchQueue.main.async {
                        PayME.currentVC?.removeSpinner()
                        guard let navigationController = PayME.currentVC?.navigationController else { return }
                        let navigationArray = navigationController.viewControllers
                        if PayME.isRecreateNavigationController {
                            PayME.currentVC?.navigationController?.viewControllers = [navigationArray[0]]
                            let rootViewController = navigationArray.first
                            (rootViewController as! WebViewController).reload()
                        } else {
                            PayME.currentVC?.navigationController?.viewControllers = [navigationArray[0],navigationArray[1]]
                            (PayME.currentVC?.navigationController?.visibleViewController as! WebViewController).reload()
                        }
                        return
                    }
                } else {
                    DispatchQueue.main.async {
                        PayME.currentVC?.removeSpinner()
                        return
                    }
                    self.toastMess(title: "Lỗi", message: response["data"]!["message"] as? String ?? "Something went wrong")
                }
            },onError: {error in
                PayME.currentVC?.removeSpinner()
                self.toastMess(title: "Lỗi", message: error["message"] as? String ?? "Something went wrong")
            })
            self.dispatchGroup.leave()
        }
    }
    
    private func uploadVideo() {
        serialQueue.async{
            self.dispatchGroup.wait()
            self.dispatchGroup.enter()
            if (self.videoKYC != nil) {
                API.uploadVideoKYC(videoURL: self.videoKYC!, onSuccess: {response in
                     let code = response["code"]! as! Int
                     if (code == 1000) {
                        let data = response["data"] as! [[String:Any]]
                        self.pathVideo = data[0]["path"] as? String ?? ""
                        
                     } else {
                        self.toastMess(title: "Lỗi", message: response["data"]!["message"] as? String ?? "Something went wrong")
                    }
                    self.dispatchGroup.leave()
                }, onError: {error in
                    DispatchQueue.main.async {
                        PayME.currentVC?.removeSpinner()
                        self.toastMess(title: "Lỗi", message: "Something went wrong")
                        return
                    }
                })
            } else {
                self.dispatchGroup.leave()
            }
        }
    }
    
    private func toastMess(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        PayME.currentVC?.present(alert, animated: true, completion: nil)
    }
    
    private func uploadAvatar() {
        serialQueue.async{
            self.dispatchGroup.wait()
            self.dispatchGroup.enter()
            if (self.imageAvatar != nil) {
                API.uploadImageKYC(imageFront: self.imageAvatar!, imageBack: nil,
                onSuccess: {response in
                     let code = response["code"]! as! Int
                     if (code == 1000) {
                        let data = response["data"] as! [[String:Any]]
                        self.pathAvatar = data[0]["path"] as? String ?? ""
                     } else {
                        self.toastMess(title: "Lỗi", message: response["data"]!["message"] as? String ?? "Something went wrong")
                    }
                    self.dispatchGroup.leave()
                }, onError: {error in
                    DispatchQueue.main.async {
                        PayME.currentVC?.removeSpinner()
                        self.toastMess(title: "Lỗi", message: "Something went wrong")
                        return
                    }
                })
            } else {
                self.dispatchGroup.leave()
            }
        }
    }
    
    private func uploadDocument() {
        serialQueue.async{
            if (self.imageDocument != nil) {
                if (self.active == 2) {
                    API.uploadImageKYC(imageFront: self.imageDocument![0], imageBack: nil,
                    onSuccess: {response in
                         let code = response["code"]! as! Int
                         if (code == 1000) {
                            let data = response["data"] as! [[String:Any]]
                            self.pathFront = data[0]["path"] as? String ?? ""
                         } else {
                            self.toastMess(title: "Lỗi", message: response["data"]!["message"] as? String ?? "Something went wrong")
                        }
                        self.dispatchGroup.leave()
                    }, onError: {error in
                        DispatchQueue.main.async {
                            PayME.currentVC?.removeSpinner()
                            self.toastMess(title: "Lỗi", message: "Something went wrong")
                            return
                        }
                    })
                } else {
                    API.uploadImageKYC(imageFront: self.imageDocument![0], imageBack: self.imageDocument![1], onSuccess: {response in
                             let code = response["code"]! as! Int
                             if (code == 1000) {
                                let data = response["data"] as! [[String:Any]]
                                self.pathFront = data[0]["path"] as? String ?? ""
                                self.pathBack = data[1]["path"] as? String ?? ""
                             } else {
                                self.toastMess(title: "Lỗi", message: response["data"]!["message"] as? String ?? "Something went wrong")
                            }
                            self.dispatchGroup.leave()
                    }, onError: {error in
                        DispatchQueue.main.async {
                            PayME.currentVC?.removeSpinner()
                            self.toastMess(title: "Lỗi", message: "Something went wrong")
                            return
                        }
                    })
                }
            }  else {
                self.dispatchGroup.leave()
            }
        }
    }
    
    
    
}
