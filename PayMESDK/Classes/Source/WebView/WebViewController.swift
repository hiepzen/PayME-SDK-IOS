//
//  WebViewController.swift
//  PayMESDK
//
//  Created by HuyOpen on 9/29/20.
//  Copyright © 2020 PayME. All rights reserved.
//

import UIKit
import  WebKit

class WebViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler{
    /*
     var urlRequest : String = ""
     var webView : WKWebView!
     var mNativeToWebHandler : String = "callBackFromJS"
     
     override func loadView() {
     let userController: WKUserContentController = WKUserContentController()
     userController.add(self, name: mNativeToWebHandler)
     let config = WKWebViewConfiguration()
     config.userContentController = userController
     webView = WKWebView(frame: .zero, configuration: config)
     webView.uiDelegate = self
     view = webView
     }
     
     func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
     if message.name == "callBackFromJS", let messageBody = message.body as? String {
     print("message.body:\(messageBody)")
     }
     }
     
     override func viewDidLoad() {
     self.navigationItem.hidesBackButton = true
     let urlString = urlRequest.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
     print(urlString)
     let  myURL = URL(string: urlString!)
     let myRequest : URLRequest
     if myURL != nil
     {
     myRequest = URLRequest(url: myURL!)
     } else {
     myRequest = URLRequest(url: URL(string: "https://www.google.com/")!)
     }
     let appVersion = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
     print(appVersion)
     print(1111)
     webView.load(myRequest)
     }
     */
    var vc : UIImagePickerController!
    var urlRequest : String = ""
    var webView : WKWebView!
    var onCommunicate: String = "onCommunicate"
    var onClose: String = "onClose"
    var openCamera : String = "openCamera"
    var onErrorBack : String = "onError"
    /*let content = """
          <!DOCTYPE html><html><body>
          <button onclick="onClick()">Click me</button>
          <script>
          function onClick() {
            window.webkit.messageHandlers.onCommunicate.postMessage({huy: "123", hieu: 1});
            window.webkit.messageHandlers.onClose.postMessage("success");
          }
          </script>
          </body></html>
          """
     */
    

    private var onSuccess: ((Dictionary<String, AnyObject>) -> ())? = nil
    private var onError: ((String) -> ())? = nil
    
    override func loadView() {
        let userController: WKUserContentController = WKUserContentController()
        userController.add(self, name: onCommunicate)
        userController.add(self, name: onClose)
        userController.add(self, name: openCamera)
        userController.add(self, name: onErrorBack)
        let config = WKWebViewConfiguration()
        config.userContentController = userController
        webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = self
        view = webView
    }
    
    /*override func viewDidLoad() {
        webView.loadHTMLString(content, baseURL: nil)
    }
    */
    
     override func viewDidLoad() {
        let urlString = urlRequest.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let  myURL = URL(string: urlString!)
        let myRequest : URLRequest
        if myURL != nil
        {
            myRequest = URLRequest(url: myURL!)
        } else {
            myRequest = URLRequest(url: URL(string: "http://localhost:3000/")!)
        }
        print(myRequest)
        
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never;
        } else {
            self.automaticallyAdjustsScrollViewInsets = false;
        }
        
        webView.scrollView.alwaysBounceVertical = false
        webView.scrollView.bounces = false
        webView.load(myRequest)
     }
     
    
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == openCamera {
            setupCamera()
        }
        if message.name == onCommunicate {
            if let dictionary = message.body as? [String: AnyObject] {
                self.onSuccess!(dictionary)
            }
        }
        if message.name == onErrorBack {
            if let dictionary = message.body as? [String: AnyObject] {
                if let b = dictionary["message"] as? String {
                    self.onError!(b)
                } else {
                    self.onError!("Đã có lỗi xảy ra")
                }
            }
        }
        if message.name == onClose {
            self.onCloseWebview()
        }
    }
    

    func setupCamera() {
        vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        self.present(vc, animated: true)
    }
    @objc override func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage else { return }
        let resizeImage = image.resizeImage(targetSize: CGSize(width:1024, height: 1024))
        let imageData:Data =  resizeImage.pngData()!
        let base64String = "data:image/jpeg;base64," + imageData.base64EncodedString()
        webView?.evaluateJavaScript("document.getElementById('ImageReview').src='\(base64String)'") { (result, error) in
            //print(result)
        }
        picker.dismiss(animated: true, completion: nil)
    }

    
    func onCloseWebview() {
        navigationController?.popViewController(animated: true)
    }
    
    public func setOnSuccessCallback(onSuccess: @escaping (Dictionary<String, AnyObject>) -> ()) {
        self.onSuccess = onSuccess
    }
    public func setOnErrorCallback(onError: @escaping (String) -> ()) {
        self.onError = onError
    }
}
extension UIViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage else { return }
        let resizeImage = image.resizeImage(targetSize: CGSize(width:70, height: 70))
        let imageData:Data =  resizeImage.pngData()!
        let base64String = imageData.base64EncodedString()
        print(base64String)
        picker.dismiss(animated: true, completion: nil)
    }
}
extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
      let size = self.size
      let widthRatio  = targetSize.width  / size.width
      let heightRatio = targetSize.height / size.height
      let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
      let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

      UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
      self.draw(in: rect)
      let newImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
    
      return newImage!
    }
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}

