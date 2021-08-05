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
    var onDeposit: String = "onDeposit"
    var onWithdraw: String = "onWithdraw"
    var onTransfer: String = "onTransfer"
    var onUpdateIdentify: String = "onUpdateIdentify"
    var showButtonCloseNapas: String = "showButtonCloseNapas"
    var form = ""
    var imageFront: UIImage?
    var imageBack: UIImage?
    var active: Int?
    var individualTaskTimer: Timer!
    var payMEFunction: PayMEFunction?

    private var onSuccessWebView: ((String) -> ())? = nil
    private var onFailWebView: ((String) -> ())? = nil
    private var onSuccess: ((Dictionary<String, AnyObject>) -> ())? = nil
    private var onError: (([String: AnyObject]) -> ())? = nil
    private var onNavigateToHost: ((String) -> ())? = nil

    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(for: QRNotFound.self, named: "16Px"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(payMEFunction: PayMEFunction?, nibName: String?, bundle: Bundle?) {
        self.payMEFunction = payMEFunction
        super.init(nibName: nibName, bundle: bundle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
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
        userController.add(self, name: onDeposit)
        userController.add(self, name: onWithdraw)
        userController.add(self, name: onTransfer)
        userController.add(self, name: onUpdateIdentify)
        userController.add(self, name: showButtonCloseNapas)
        userController.addUserScript(getZoomDisableScript())

        let config = WKWebViewConfiguration()
        config.userContentController = userController
        webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView

        reloadHomePage()
    }

    func reloadHomePage() {
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
            closeButton.isHidden = true
        } else {
            webView.loadHTMLString(form, baseURL: nil)
            closeButton.isHidden = false
        }
    }

//    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
//        showSpinner(onView: PayME.currentVC!.view)
//    }
//
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        removeSpinner()
//    }

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
                onFailWebView?(wkError.localizedDescription)
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

    func updateIdentify() {
        let injectedJS = "       const script = document.createElement('script');\n" +
                "          script.type = 'text/javascript';\n" +
                "          script.async = true;\n" +
                "          script.text = 'onUpdateIdentify()';\n" +
                "          document.body.appendChild(script);\n" +
                "          true; // note: this is required, or you'll sometimes get silent failures\n"
        webView.evaluateJavaScript("(function() {\n" + injectedJS + ";\n})();")
    }

    func reload() {
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

        webView.addSubview(closeButton)
        closeButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        closeButton.topAnchor.constraint(equalTo: webView.topAnchor, constant: 60).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: webView.trailingAnchor, constant: -20).isActive = true
        closeButton.addTarget(self, action: #selector(closeWebViewPaymentModal), for: .touchUpInside)
    }

    @objc func closeWebViewPaymentModal() {
        if form == "" { //form == "" -> payme open wallet, form != "" -> napas
            reloadHomePage()
        } else {
            dismiss(animated: true) {
                PayME.currentVC?.dismiss(animated: true)
            }
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if (form != "") {
            if (navigationAction.request.url != nil) {
                if ((payMEFunction?.authenCreditLink ?? "") != "") {
                    if navigationAction.request.url!.absoluteString.contains(payMEFunction!.authenCreditLink) {
                        onNavigateToHost?("authenticated")
                        decisionHandler(.cancel)
                        return
                    }
                }
                let host = navigationAction.request.url!.host ?? ""
//                if host.contains("payme.vn") == true || host.contains("centinelapistag.cardinalcommerce.com") {
                onNavigateToHost?(host)
                if (host == "payme.vn") {
                    let params = navigationAction.request.url!.queryParameters ?? ["": ""]
                    if (params["success"] == "true") {
                        DispatchQueue.main.async {
                            self.onSuccessWebView?("success")
                        }
                        decisionHandler(.cancel)
                        return
                    }
                    if (params["success"] == "false") {
                        onFailWebView?(params["message"]!)
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

    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        if(error.code == NSURLErrorNotConnectedToInternet){
            webView.loadHTMLString("""
                                   <html lang="en">
                                   <head>
                                       <meta charset="UTF-8">
                                       <meta http-equiv="X-UA-Compatible" content="IE=edge">
                                       <meta name="viewport" content="width=device-width, initial-scale=1.0">
                                       <title>Error Page</title>
                                   </head>

                                   <body>
                                       <div
                                           style="display: flex;width: 100%;height: 100%;align-items: center;margin: auto 0;justify-content: center;flex-direction: column;">
                                           <svg xmlns="http://www.w3.org/2000/svg" width="161" height="161" viewBox="0 0 161 161">
                                               <g fill="none" fill-rule="evenodd">
                                                   <g>
                                                       <g>
                                                           <g
                                                               transform="translate(-107.000000, -220.000000) translate(107.000000, 220.000000) translate(0.000000, 24.527344)">
                                                               <path fill="#000" fill-opacity=".2" fill-rule="nonzero"
                                                                   d="M25.762 60.903c20.59-3.146 35.32.735 43.496 14.312C78.412 90.4 81.68 103.481 99.37 109.338c22.229 7.352 50.162-8.31 58.904-39.688 4.29-15.484 5.268-38.056-10.406-56.01C136.355.448 114.984-3.323 98.255 3.62c-12.328 5.13-28.07 10.456-44.054 2.017C38.22-2.8 19.233-2.622 6.631 12.067-7.32 28.345 1.533 64.588 25.76 60.903z"
                                                                   opacity=".15" />
                                                               <rect width="118.314" height="87.96" x="21.215" y="7.416" fill="#DDD" fill-rule="nonzero"
                                                                   rx="10.165" />
                                                               <path fill="#FFF" fill-rule="nonzero"
                                                                   d="M46.544-2.12H114.2c2.507 0 4.54 2.031 4.54 4.538v97.964c0 2.507-2.033 4.539-4.54 4.539H46.544c-2.507 0-4.54-2.032-4.54-4.54V2.419c0-2.507 2.033-4.539 4.54-4.539z"
                                                                   transform="translate(80.371963, 51.399984) rotate(90.000000) translate(-80.371963, -51.399984)" />
                                                               <path fill="#F3F3F3" fill-rule="nonzero"
                                                                   d="M133.893 40.332v44.904c-.005 2.499-2.04 4.523-4.547 4.523H31.39c-2.508 0-4.543-2.024-4.547-4.523V72.804c21.019-.307 69.902-4.3 107.05-32.472z" />
                                                               <path fill="#DDD" fill-rule="nonzero"
                                                                   d="M65.483 94.555c-.005 1.73.682 3.392 1.909 4.618 1.226 1.225 2.891 1.914 4.628 1.914h21.637c3.605 0 6.528-2.913 6.528-6.506l-34.702-.026zM57.316 104.464h51.037c3.278 0 5.936 2.65 5.936 5.917v1.564H51.38v-1.564c0-3.268 2.658-5.917 5.937-5.917z" />
                                                               <rect width="48.12" height="6.746" x="58.302" y="71.146" fill="#DDD" fill-rule="nonzero"
                                                                   rx="3.373" />
                                                               <path fill="#EC2A2A"
                                                                   d="M78.446 26.636L60.301 56.5c-.87 1.433-.897 3.221-.073 4.68.825 1.46 2.374 2.363 4.054 2.365h36.298c1.682.001 3.234-.901 4.06-2.36.827-1.46.8-3.25-.07-4.685L86.415 26.636c-.844-1.39-2.355-2.239-3.985-2.239s-3.141.85-3.985 2.239" />
                                                               <path fill="#FFF"
                                                                   d="M80.445 42.564c-.137-2.85-.206-4.845-.206-5.985 0-1.206 1.09-1.796 2.3-1.796.513-.055 1.027.108 1.414.45s.612.83.618 1.346c0 1.168-.031 3.163-.094 5.985-.051 2.838-.086 4.839-.086 5.985 0 .855-1.064 1.29-1.853 1.29-1.26 0-1.887-.427-1.887-1.29 0-1.14-.069-3.135-.206-5.985M84.717 54.132c.02 1.21-.931 2.214-2.145 2.265-1.293.034-2.372-.977-2.419-2.265.009-.623.271-1.216.728-1.642.456-.426 1.067-.648 1.691-.616 1.212.047 2.165 1.05 2.145 2.258" />
                                                           </g>
                                                       </g>
                                                   </g>
                                               </g>
                                           </svg>
                                           <p>Lỗi kết nối mạng. Vui lòng thử lại!</p>
                                       </div>
                                   </body>
                                   </html>
                                   """,baseURL:  nil)
        }
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == onDeposit || message.name == onWithdraw || message.name == onTransfer {
            onCloseWebview()
            if let dictionary = message.body as? [String: AnyObject] {
                let status = dictionary["data"]!["status"] as! String
                if status == "SUCCEEDED" {
                    onSuccess!(dictionary["data"] as! [String: AnyObject])
                } else {
                    let message = dictionary["data"]!["message"] as? String ?? "Có lỗi xảy ra"
                    onError!(["code": PayME.ResponseCode.OTHER as AnyObject, "message": message as AnyObject])
                }
            }
        }
        if message.name == onUpdateIdentify {
            setupCamera(dictionary: [
                "identifyImg": true,
                "faceImg": false,
                "kycVideo": false
            ] as [String: AnyObject], isUpdateIdentify: true)
        }
        if message.name == openCamera {
            if let dictionary = message.body as? [String: AnyObject] {
                setupCamera(dictionary: dictionary)
            }
        }
        if message.name == showButtonCloseNapas {
            if let dictionary = message.body as? [String: AnyObject] {
                if let isShowButtonClose = dictionary["isShowButtonClose"] as? Bool {
                    closeButton.isHidden = !isShowButtonClose
                }
            }
        }
        if message.name == onCommunicate {
            if let dictionary = message.body as? [String: AnyObject] {
                let actions = (dictionary["actions"] as? String) ?? ""
                if (actions == "onRegisterSuccess") {
                    if let data = dictionary["data"] as? [String: AnyObject] {
                        if let dataInit = data["Init"] as? [String: AnyObject] {
                            let accessToken = (dataInit["accessToken"] as? String) ?? ""
                            let kycState = (dataInit["kyc"]!["state"] as? String) ?? ""
                            let isAccountActivated = (dataInit["isAccountActived"] as? Bool) ?? true
                            payMEFunction?.isAccountActivated = isAccountActivated
                            payMEFunction?.dataInit = dataInit
                            payMEFunction?.accessToken = accessToken
                            payMEFunction?.kycState = kycState
                            payMEFunction?.handShake = (dataInit["handShake"] as? String) ?? ""
                            payMEFunction?.request.setAccessData(kycState == "APPROVED" ? accessToken : "", accessToken, nil)
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
                    onCloseWebview()
                    payMEFunction?.resetInitState()
                }
                onError!(dictionary)
            }
        }
        if message.name == onClose {
            onCloseWebview()
        }
        if message.name == onPay {
            payMEFunction?.openQRCode(currentVC: self, onSuccess: onSuccess!, onError: onError!)
        }
    }


    func setupCamera(dictionary: [String: AnyObject], isUpdateIdentify: Bool? = nil) {
        KYCController.reset()
        KYCController.isUpdateIdentify = isUpdateIdentify ?? KYCController.isUpdateIdentify
        if let dictionary = dictionary as? [String: Bool] {
            let kycController = KYCController(payMEFunction: payMEFunction!, flowKYC: dictionary)
            if isUpdateIdentify ?? false {
                kycController.updateIdentify()
            } else {
                kycController.kyc()
            }
        }
    }

    func onCloseWebview() {
        onRemoveMessageHandler()
        if PayME.currentVC?.navigationController?.viewControllers.count == 1 && PayME.isRecreateNavigationController == true {
            dismiss(animated: true) {
                PayME.isWebviewOpening = false
            }
        } else {
            navigationController?.popViewController(animated: true) {
                PayME.isWebviewOpening = false
            }
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

    public func setOnNavigateToHost(onNavigateToHost: @escaping (String) -> ()){
        self.onNavigateToHost = onNavigateToHost
    }

    public func setOnErrorCallback(onError: @escaping ([String: AnyObject]) -> ()) {
        self.onError = onError
    }

    public func setURLRequest(_ url: String) {
        urlRequest = url
    }
}



