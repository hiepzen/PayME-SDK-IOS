//
//  WebViewController.swift
//  PayMESDK
//
//  Created by HuyOpen on 9/29/20.
//  Copyright © 2020 PayME. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler, WKNavigationDelegate, PanModalPresentable {
    var KYCAgain: Bool? = nil

    var panScrollable: UIScrollView? {
        nil
    }

    var topOffset: CGFloat {
        0.0
    }

    var springDamping: CGFloat {
        1.0
    }

    var transitionDuration: Double {
        0.4
    }

    var transitionAnimationOptions: UIView.AnimationOptions {
        [.allowUserInteraction, .beginFromCurrentState]
    }

    var shouldRoundTopCorners: Bool {
        false
    }

    var showDragIndicator: Bool {
        false
    }

    var vc: UIImagePickerController!
    var urlRequest: String = ""
    var webView: WKWebView!
    var onCommunicate: String = "onCommunicate"
    var onClose: String = "onClose"
    var openCamera: String = "openCamera"
    var onErrorBack: String = "onError"
    var onRegisterSuccess: String = "onRegisterSuccess"
    var onPay: String = "onPay"
    var form = ""
    var imageFront: UIImage?
    var imageBack: UIImage?
    var active: Int?
    var individualTaskTimer: Timer!
    var payME: PayME?

    private var onSuccessWebView: ((String) -> ())? = nil
    private var onFailWebView: ((String) -> ())? = nil
    private var onSuccess: ((Dictionary<String, AnyObject>) -> ())? = nil
    private var onError: (([String: AnyObject]) -> ())? = nil

    init(payME: PayME?, nibName: String?, bundle: Bundle?) {
        self.payME = payME
        super.init(nibName: nibName, bundle: bundle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        userController.addUserScript(getZoomDisableScript())

        let config = WKWebViewConfiguration()
        config.userContentController = userController
        webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView

        if (form == "") {
            let urlString = urlRequest.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let myURL = URL(string: urlString!)
            let myRequest: URLRequest
            if myURL != nil {
                myRequest = URLRequest(url: myURL!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
            } else {
                myRequest = URLRequest(url: URL(string: "http://google.com/")!)
            }

            if #available(iOS 11.0, *) {
                webView.scrollView.contentInsetAdjustmentBehavior = .never;
            } else {
                automaticallyAdjustsScrollViewInsets = false;
            }
            webView.scrollView.alwaysBounceVertical = false
            webView.scrollView.bounces = false
            webView.load(myRequest)
        } else {
            webView.loadHTMLString(form, baseURL: nil)
        }
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        showSpinner(onView: PayME.currentVC!.view)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        removeSpinner()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("error 01")
        let wkError = (error as NSError)
        removeSpinner()
        if (wkError.code == NSURLErrorNotConnectedToInternet) {
            onError!(["code": PayME.ResponseCode.NETWORK as AnyObject, "message": wkError.localizedDescription as AnyObject])
        } else {
            onError!(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": wkError.localizedDescription as AnyObject])
        }
        onCloseWebview()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let wkError = (error as NSError)
        if (form == "") {
            removeSpinner()
            if (wkError.code == NSURLErrorNotConnectedToInternet) {
                onError!(["code": PayME.ResponseCode.NETWORK as AnyObject, "message": wkError.localizedDescription as AnyObject])
            } else {
                onError!(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": wkError.localizedDescription as AnyObject])
            }
            onCloseWebview()
        } else {
            if (wkError.code != 102) {
                onFailWebView!(wkError.localizedDescription)
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

    internal func reload() {
        webView.reload()
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
            WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler: {})
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
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if (form != "") {
            if (navigationAction.request.url != nil) {
                let host = navigationAction.request.url!.host ?? ""
                print(host)
                //if (navigationAction.request.url!.host!) {
                if (host == "payme.vn") {
                    let params = navigationAction.request.url!.queryParameters ?? ["": ""]
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
                    if let data = dictionary["data"] as? [String: AnyObject] {
                        if let dataInit = data["Init"] as? [String: AnyObject] {
                            payME?.dataInit = dataInit
                            payME?.accessToken = (dataInit["accessToken"] as? String) ?? ""
                            payME?.kycState = (dataInit["kyc"]!["state"] as? String) ?? ""
                            payME?.handShake = (dataInit["handShake"] as? String) ?? ""
                        }
                    }
                    onSuccess!(dictionary)
                }
                if (actions == "onNetWorkError") {
                    if let data = dictionary["data"] as? [String: AnyObject] {
                        onError!(["code": PayME.ResponseCode.NETWORK as AnyObject, "message": data["message"] as AnyObject])
                    }
                }
                if (actions == "onKYC") {
                    if let data = dictionary["data"] as? [String: AnyObject] {
                        setupCamera(dictionary: data)
                    }
                }
            }
        }
        if message.name == onErrorBack {
            if let dictionary = message.body as? [String: AnyObject] {
                removeSpinner()
                let code = dictionary["code"] as! Int
                if (code == 401) {
                    navigationController?.popViewController(animated: true)
                    PayME.logoutAction()
                }
                onError!(dictionary)
            }
        }
        if message.name == onClose {
            onCloseWebview()
        }
        if message.name == onPay {
            payME?.payMEFunction.openQRCode(currentVC: self, onSuccess: onSuccess!, onError: onError!)
        }
    }


    func setupCamera(dictionary: [String: AnyObject]) {
        if let dictionary = dictionary as? [String: Bool] {
            let kycController = KYCController(flowKYC: dictionary)
            kycController.kyc()
        }
    }

    func onCloseWebview() {
        onRemoveMessageHandler()
        if PayME.isRecreateNavigationController {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    private func onRemoveMessageHandler() {
        let userController = webView.configuration.userContentController
        userController.removeScriptMessageHandler(forName: onCommunicate)
        userController.removeScriptMessageHandler(forName: onClose)
        userController.removeScriptMessageHandler(forName: openCamera)
        userController.removeScriptMessageHandler(forName: onErrorBack)
        userController.removeScriptMessageHandler(forName: onPay)
        userController.removeScriptMessageHandler(forName: onRegisterSuccess)
    }

    public func setOnSuccessCallback(onSuccess: @escaping (Dictionary<String, AnyObject>) -> ()) {
        self.onSuccess = onSuccess
    }

    public func setOnSuccessWebView(onSuccessWebView: @escaping (String) -> ()) {
        self.onSuccessWebView = onSuccessWebView
    }

    public func setOnFailWebView(onFailWebView: @escaping (String) -> ()) {
        self.onFailWebView = onFailWebView
    }

    public func setOnErrorCallback(onError: @escaping ([String: AnyObject]) -> ()) {
        self.onError = onError
    }

    public func setURLRequest(_ url: String) {
        urlRequest = url
    }
}



