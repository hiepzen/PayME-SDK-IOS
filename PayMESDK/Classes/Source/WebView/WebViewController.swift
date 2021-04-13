//
//  WebViewController.swift
//  PayMESDK
//
//  Created by HuyOpen on 9/29/20.
//  Copyright © 2020 PayME. All rights reserved.
//

import UIKit
import  WebKit

class WebViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler, WKNavigationDelegate, PanModalPresentable{
    var KYCAgain : Bool? = nil
    
    var panScrollable: UIScrollView? {
        return nil
    }

    var topOffset: CGFloat {
        return 0.0
    }

    var springDamping: CGFloat {
        return 1.0
    }

    var transitionDuration: Double {
        return 0.4
    }

    var transitionAnimationOptions: UIView.AnimationOptions {
        return [.allowUserInteraction, .beginFromCurrentState]
    }

    var shouldRoundTopCorners: Bool {
        return false
    }

    var showDragIndicator: Bool {
        return false
    }
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
    var onRegisterSuccess : String = "onRegisterSuccess"
    var onPay : String = "onPay"
    var form = ""
    var imageFront : UIImage?
    var imageBack : UIImage?
    var active: Int?
    var individualTaskTimer : Timer!
    
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
    
    private var onSuccessWebView: ((String) -> ())? = nil
    private var onFailWebView: ((String) -> ())? = nil
    private var onSuccess: ((Dictionary<String, AnyObject>) -> ())? = nil
    private var onError: (([String: AnyObject]) -> ())? = nil
    
    override func loadView() {
        PayME.currentVC?.navigationItem.hidesBackButton = true
        PayME.currentVC?.navigationController?.isNavigationBarHidden = true
        
        let userController: WKUserContentController = WKUserContentController()
        userController.add(self, name: onCommunicate)
        userController.add(self, name: onClose)
        userController.add(self, name: openCamera)
        userController.add(self, name: onErrorBack)
        userController.add(self, name: onPay)
        userController.add(self, name: onRegisterSuccess)
        userController.addUserScript(self.getZoomDisableScript())
        
        let config = WKWebViewConfiguration()
        config.userContentController = userController
        webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        //self.individualTaskTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: Selector(("onCloseWebview")), userInfo: nil, repeats: false)
        //self.showSpinner(onView: PayME.currentVC!.view)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //self.individualTaskTimer.invalidate()
        self.removeSpinner()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("error 01")
        let wkerror = (error as NSError)
        self.removeSpinner()
        if (wkerror.code == NSURLErrorNotConnectedToInternet) {
            self.onError!(["code": PayME.ResponseCode.NETWORK as AnyObject, "message" : wkerror.localizedDescription as AnyObject])
        } else {
            self.onError!(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message" : wkerror.localizedDescription as AnyObject])
        }
        onCloseWebview()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let wkerror = (error as NSError)
        if (self.form == "") {
        self.removeSpinner()
            if (wkerror.code == NSURLErrorNotConnectedToInternet) {
                self.onError!(["code": PayME.ResponseCode.NETWORK as AnyObject, "message" : wkerror.localizedDescription as AnyObject])
            } else {
                self.onError!(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message" : wkerror.localizedDescription as AnyObject])
            }
            onCloseWebview()
        } else {
            if (wkerror.code != 102) {
                self.onFailWebView!(wkerror.localizedDescription)
            } else {
                // donothing
            }
        }
    }
    
    private func getZoomDisableScript() -> WKUserScript {
        let source: String = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum- scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);"
        return WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }
    
    /*override func viewDidLoad() {
        webView.loadHTMLString(content, baseURL: nil)
    }
    */
    internal func reload(){
        self.webView.reload()
    }
    
     override func viewDidLoad() {
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { (records) in
            for record in records {
                if record.displayName.contains("payme.com.vn") {
                    dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: [record], completionHandler: {
                        
                    })
                }
            }
        }
        if #available(iOS 9.0, *) {
          let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
          let date = NSDate(timeIntervalSince1970: 0)
            WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
        } else {
            var libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, false).first!
            libraryPath += "/Cookies"

            do {
                try FileManager.default.removeItem(atPath: libraryPath)
            } catch {
              print("Lỗi")
            }
            URLCache.shared.removeAllCachedResponses()
        }
        if(self.form == "")
        {
            let urlString = urlRequest.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let  myURL = URL(string: urlString!)
            let myRequest : URLRequest
            if myURL != nil
            {
                myRequest = URLRequest(url: myURL!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
            } else {
                myRequest = URLRequest(url: URL(string: "http://google.com/")!)
            }
            print(myURL)
            
            if #available(iOS 11.0, *) {
                webView.scrollView.contentInsetAdjustmentBehavior = .never;
            } else {
                self.automaticallyAdjustsScrollViewInsets = false;
            }
            webView.scrollView.alwaysBounceVertical = false
            webView.scrollView.bounces = false
            webView.load(myRequest)
        } else {
            /*
            if #available(iOS 11.0, *) {
                webView.scrollView.contentInsetAdjustmentBehavior = .never;
            } else {
                self.automaticallyAdjustsScrollViewInsets = false;
            }
            webView.scrollView.alwaysBounceVertical = false
            webView.scrollView.bounces = false
            */
            webView.loadHTMLString(self.form, baseURL: nil)
        }
        
     }
    /*
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // some other code
        NotificationCenter.default.addObserver(self, selector: #selector(goingAway), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(activeAgain), name: UIApplication.didBecomeActiveNotification, object: nil)

    }
    
    @objc func activeAgain() {
        if (self.individualTaskTimer != nil) {
            self.individualTaskTimer!.invalidate()
        }
    }
    
    @objc func goingAway() {
        individualTaskTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { timer in
            self.navigationController?.popViewController(animated: true)
        }
    }
    */
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if (self.form != "") {
            print("URL:", navigationAction.request.url)
            if (navigationAction.request.url != nil)
            {
                let host = navigationAction.request.url!.host ?? ""
                print(host)
                //if (navigationAction.request.url!.host!) {
                if (host == "payme.vn") {
                    let params = navigationAction.request.url!.queryParameters ?? ["":""]
                    if (params["success"] == "true") {
                        self.onSuccessWebView!("success")
                        decisionHandler(.cancel)
                        return
                    }
                    if (params["success"] == "false") {
                        self.onFailWebView!(params["message"]!)
                        decisionHandler(.cancel)
                        return
                    }
                    decisionHandler(.allow)

                } else {
                    decisionHandler(.allow)
                }

            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == openCamera {
            if let dictionary = message.body as? [String: AnyObject] {
                print(dictionary)
                KYCController.reset()
                setupCamera(dictionary: dictionary)
            }
        }
        if message.name == onCommunicate {
            if let dictionary = message.body as? [String: AnyObject] {
                let actions = (dictionary["actions"] as? String) ?? ""
                if (actions == "onRegisterSuccess") {
                    if let data = dictionary["data"] as? [String : AnyObject] {
                        if let dataInit = data["Init"] as? [String: AnyObject] {
                            PayME.dataInit = dataInit
                            PayME.accessToken = (dataInit["accessToken"] as? String) ?? ""
                            PayME.kycState = (dataInit["kyc"]!["state"] as? String) ?? ""
                            PayME.handShake = (dataInit["handShake"] as? String) ?? ""
                        }
                    }
                    self.onSuccess!(dictionary)
                }
                if (actions == "onNetWorkError") {
                    if let data = dictionary["data"] as? [String : AnyObject] {
                        self.onError!(["code": PayME.ResponseCode.NETWORK as AnyObject, "message" : data["message"] as AnyObject])
                    }
                }
                if (actions == "onKYC") {
                    print("Hello1")
                    if let data = dictionary["data"] as? [String : AnyObject] {
                        setupCamera(dictionary: data)
                    }
                }
            }
        }
        if message.name == onErrorBack {
            if let dictionary = message.body as? [String: AnyObject] {
                self.removeSpinner()
                let code = dictionary["code"] as! Int
                if (code == 401) {
                    self.navigationController?.popViewController(animated: true)
                    PayME.logoutAction()
                }
                self.onError!(dictionary)
            }
        }
        if message.name == onClose {
            self.onCloseWebview()
        }
        if message.name == onPay {
            PayME.openQRCode(currentVC: self, onSuccess: onSuccess!, onError: onError!)
        }
    }
    

    func setupCamera(dictionary: [String: AnyObject]) {
        if let dictionary = dictionary as? [String: Bool] {
            let kycController = KYCController(flowKYC: dictionary)
            kycController.kyc()
        }
    }
    
    func onCloseWebview() {
        if PayME.isRecreateNavigationController {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    public func setOnSuccessCallback(onSuccess: @escaping (Dictionary<String, AnyObject>) -> ()) {
        self.onSuccess = onSuccess
    }
    public func setOnSuccessWebView(onSuccessWebView: @escaping (String) -> ()){
        self.onSuccessWebView = onSuccessWebView
    }
    public func setOnFailWebView(onFailWebView: @escaping (String) -> ()){
        self.onFailWebView = onFailWebView
    }
    public func setOnErrorCallback(onError: @escaping ([String:AnyObject]) -> ()) {
        self.onError = onError
    }
}



