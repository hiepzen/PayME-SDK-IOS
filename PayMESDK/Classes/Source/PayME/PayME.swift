//
//  PayME.swift
//  PayMESDK
//
//  Created by HuyOpen on 9/29/20.
//  Copyright © 2020 PayME. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import CryptoSwift

public class PayME{
    internal static var appPrivateKey: String = ""
    internal static var appID: String = ""
    internal static var publicKey: String = ""
    internal static var connectToken : String = ""
    internal static var env : Env!
    internal static var configColor : [String] = [""]
    internal static var description : String = ""
    internal static var amount : Int = 0
    internal static let packageName = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
    internal static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    internal static let deviceID = UIDevice.current.identifierForVendor!.uuidString
    internal static var clientID: String = ""
    internal static var currentVC : UIViewController?
    internal static var webviewController: WebViewController?
    internal static var isRecreateNavigationController: Bool = false
    internal static var accessToken : String = ""
    
    public enum Action: String {
        case OPEN = "OPEN"
        case DEPOSIT = "DEPOSIT"
        case WITHDRAW = "WITHDRAW"
    }
    public enum Env: String{
        case SANDBOX = "sandbox"
        case PRODUCTION = "production"
        case DEV = "dev"
    }
    
    public init(appID: String, publicKey: String, connectToken: String, appPrivateKey: String, env: Env, configColor: [String]) {
        PayME.appPrivateKey = trimKeyRSA(key: appPrivateKey);
        PayME.appID = appID;
        PayME.connectToken = connectToken;
        PayME.publicKey = trimKeyRSA(key:publicKey);
        PayME.env = env;
        PayME.configColor = configColor;
    }
    
    public func setPrivateKey(appPrivateKey : String) {
        PayME.appPrivateKey = appPrivateKey
    }
    public func setAppID(appID : String) {
        PayME.appID = appID
    }
    public func setPublicKey(publicKey: String) {
        PayME.publicKey = publicKey
    }
    public func setAppPrivateKey(appPrivateKey: String) {
        PayME.appPrivateKey = appPrivateKey
    }
    public func getAppID() -> String {
        return PayME.appID
    }
    public func getPublicKey() -> String{
        return PayME.publicKey
    }
    public func getConnectToken() -> String{
        return PayME.connectToken
    }
    public func getAppPrivateKey() -> String {
        return PayME.appPrivateKey
    }
    public func getEnv() -> Env {
        return PayME.env
    }
    public func setEnv(env: Env) {
        PayME.env = env
    }
    
    public static func genConnectToken(userId: String, phone: String) -> String {
        let data : [String: Any] = ["timestamp": (Date().timeIntervalSince1970), "userId" : "\(userId)", "phone" : "\(phone)"]
        let params = try? JSONSerialization.data(withJSONObject: data)
        let aes = try? AES(key: Array("3zA9HDejj1GnyVK0".utf8), blockMode: CBC(iv: [UInt8](repeating: 0, count: 16)), padding: .pkcs5)
        let dataEncrypted = try? aes!.encrypt(Array(String(data: params!, encoding: .utf8)!.utf8))
        print(dataEncrypted!.toBase64()!)
        return dataEncrypted!.toBase64()!
    }
    
    public static func isConnected(onConnect: @escaping (Bool) -> ()) {
        if (PayME.clientID != "") {
            API.checkAccessToken(clientID: PayME.clientID,
                                 onSuccess: { responseAccessToken in
                                    let result = responseAccessToken["OpenEWallet"]!["Init"] as! [String: AnyObject]
                                    let accessToken = result["accessToken"]
                                    if accessToken is NSNull {
                                        onConnect(false)
                                    } else {
                                        PayME.accessToken = accessToken as! String
                                        onConnect(true)
                                    }
                                 }, onError: { errorAccessToken in
                                    print(errorAccessToken)
                                 }
            )
        } else {
            API.registerClient(onSuccess: { response in
                let result = response["Client"]!["Register"] as! [String: AnyObject]
                let clientID = result["clientId"] as! String
                PayME.clientID = clientID
                print(clientID)
                API.checkAccessToken(clientID: clientID,
                                     onSuccess: { responseAccessToken in
                                        let result = responseAccessToken["OpenEWallet"]!["Init"] as! [String: AnyObject]
                                        let accessToken = result["accessToken"]
                                        if accessToken is NSNull {
                                            onConnect(false)
                                        } else {
                                            PayME.accessToken = accessToken as! String
                                            print(PayME.accessToken)
                                            onConnect(true)
                                        }
                                     }, onError: { errorAccessToken in
                                        print(errorAccessToken)
                                     }
                )
            }, onError: {b in })
        }
    }
    private static func abc() {
        print("accessTOken")
        print(PayME.accessToken)
        var kycController = KYCController(flowKYC: ["kycIdentifyImg": true, "kycFace": true, "kycVideo": true])
        kycController.kyc()
    }
    public func openWallet(currentVC : UIViewController, action : Action, amount: Int?, description: String?, extraData: String?,
                           onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
                           onError: @escaping (String) -> ()
    )-> () {
        /*
         PayME.currentVC = currentVC
         var blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
         var blurEffectView = UIVisualEffectView(effect: blurEffect)
         blurEffectView.frame = PayME.currentVC?.view.bounds as! CGRect
         blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
         PayME.currentVC?.view.addSubview(blurEffectView)
         let popupView = PopUpWindow(title: "Hello", text: "100%", buttontext: "Rõ")
         PayME.currentVC?.present(popupView, animated: true)
         */
        /*
         currentVC.navigationItem.hidesBackButton = true
         currentVC.navigationController?.isNavigationBarHidden = true
         PayME.currentVC = currentVC
         PayME.isConnected(onConnect: {a in
         print(a)
         PayME.abc()
         
         })
         */
        
        currentVC.navigationItem.hidesBackButton = true
        currentVC.navigationController?.isNavigationBarHidden = true
        
        let topSafeArea: CGFloat
        let bottomSafeArea: CGFloat
        if #available(iOS 11.0, *) {
            topSafeArea = currentVC.view.safeAreaInsets.top
            bottomSafeArea = currentVC.view.safeAreaInsets.bottom
        } else {
            topSafeArea = currentVC.topLayoutGuide.length
            bottomSafeArea = currentVC.bottomLayoutGuide.length
        }
        if (PayME.clientID != "")
        {
            let data =
                """
            {
              "connectToken":  "\(PayME.connectToken)",
              "appToken": "\(PayME.appID)",
              "clientId": "\(PayME.clientID)",
              "configColor":["\(handleColor(input:PayME.configColor))"],
              "partner" : {
                   "type":"IOS",
                   "paddingTop":\(topSafeArea),
                   "paddingBottom":\(bottomSafeArea)
              },
              "actions":{
                "type":"",
                "amount":0
              }
            }
            """
            let webViewController = WebViewController(nibName: "WebView", bundle: nil)
            let url = urlWebview(env: PayME.env)
            PayME.webviewController = webViewController
            webViewController.urlRequest = "https://sbx-sdk2.payme.com.vn/active/" + "\(data)"
            webViewController.setOnSuccessCallback(onSuccess: onSuccess)
            webViewController.setOnErrorCallback(onError: onError)
            if currentVC.navigationController != nil {
                PayME.currentVC = currentVC
                currentVC.navigationController?.pushViewController(webViewController, animated: true)
            } else {
                let navigationController = UINavigationController(rootViewController: webViewController)
                PayME.currentVC = webViewController
                PayME.isRecreateNavigationController = true
                currentVC.present(navigationController, animated: true, completion: nil)
            }
            
            
        } else {
            API.registerClient(onSuccess: { response in
                let result = response["Client"]!["Register"] as! [String: AnyObject]
                let clientID = result["clientId"] as! String
                PayME.clientID = clientID
                let data =
                    """
                {
                  "connectToken":  "\(PayME.connectToken)",
                  "appToken": "\(PayME.appID)",
                  "clientId": "\(PayME.clientID)",
                  "configColor":["\(handleColor(input:PayME.configColor))"],
                  "partner" : {
                       "type":"IOS",
                       "paddingTop":\(topSafeArea),
                       "paddingBottom":\(bottomSafeArea)
                  },
                  "actions":{
                    "type":"\(action)",
                    "amount":"\(checkIntNil(input: amount))"
                  }
                }
                """
                let webViewController = WebViewController(nibName: "WebView", bundle: nil)
                let url = urlWebview(env: PayME.env)
                
                PayME.webviewController = webViewController
                webViewController.urlRequest = "https://sbx-sdk2.payme.com.vn/active/" + "\(data)"
                webViewController.setOnSuccessCallback(onSuccess: onSuccess)
                webViewController.setOnErrorCallback(onError: onError)
                
                if currentVC.navigationController != nil {
                    PayME.currentVC = currentVC
                    currentVC.navigationController?.pushViewController(webViewController, animated: true)
                } else {
                    let navigationController = UINavigationController(rootViewController: webViewController)
                    PayME.currentVC = webViewController
                    PayME.isRecreateNavigationController = true
                    currentVC.present(navigationController, animated: true, completion: {
                        print("khoa")
                    })
                }
                
            }, onError: { error in
                print(error)
            })
        }
        
    }
    internal static func openWalletAgain(currentVC : UIViewController, action : Action, amount: Int?, description: String?, extraData: String?, active: Int?
    )-> () {
        PayME.currentVC?.navigationItem.hidesBackButton = true
        PayME.currentVC?.navigationController?.isNavigationBarHidden = true
        let topSafeArea: CGFloat
        let bottomSafeArea: CGFloat
        if #available(iOS 11.0, *) {
            topSafeArea = currentVC.view.safeAreaInsets.top
            bottomSafeArea = currentVC.view.safeAreaInsets.bottom
        } else {
            topSafeArea = currentVC.topLayoutGuide.length
            bottomSafeArea = currentVC.bottomLayoutGuide.length
        }
        let data =
            """
        {"connectToken":"\(PayME.connectToken)","appToken":"\(PayME.appID)","clientInfo":{"clientId":"\(PayME.deviceID)","platform":"IOS","appVersion":"\(PayME.appVersion!)","sdkVesion":"0.1","sdkType":"IOS","appPackageName":"\(PayME.packageName!)"},"partner":{"type":"IOS","paddingTop":\(topSafeArea), "paddingBottom":\(bottomSafeArea)},"configColor":["\(handleColor(input:PayME.configColor))"],"actions":{"type":"\(action)","amount":"\(checkIntNil(input: amount))","description":"\(checkStringNil(input: description))"},"extraData":"\(checkStringNil(input:extraData))"}
        """
        let webViewController = WebViewController(nibName: "WebView", bundle: nil)
        let url = urlWebview(env: PayME.env)
        webViewController.urlRequest = url + "\(data)"
        webViewController.KYCAgain = true
        webViewController.active = active!
        
        if currentVC.navigationController != nil {
            PayME.currentVC = currentVC
            currentVC.navigationController?.pushViewController(webViewController, animated: true)
        } else {
            let navigationController = UINavigationController(rootViewController: webViewController)
            PayME.currentVC = webViewController
            PayME.isRecreateNavigationController = true
            currentVC.present(navigationController, animated: true, completion: nil)
        }
    }
    
    public func deposit(currentVC : UIViewController, amount: Int?, description: String?, extraData: String?,
                        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
                        onError: @escaping (String) -> ()) {
        currentVC.navigationItem.hidesBackButton = true
        currentVC.navigationController?.isNavigationBarHidden = true
        let topSafeArea: CGFloat
        let bottomSafeArea: CGFloat
        if #available(iOS 11.0, *) {
            topSafeArea = currentVC.view.safeAreaInsets.top
            bottomSafeArea = currentVC.view.safeAreaInsets.bottom
        } else {
            topSafeArea = currentVC.topLayoutGuide.length
            bottomSafeArea = currentVC.bottomLayoutGuide.length
        }
        let data =
            """
        {"connectToken":"\(PayME.connectToken)","appToken":"\(PayME.appID)","clientInfo":{"clientId":"\(PayME.deviceID)","platform":"IOS","appVersion":"\(PayME.appVersion!)","sdkVesion":"0.1","sdkType":"IOS","appPackageName":"\(PayME.packageName!)"},"partner":{"type":"IOS","paddingTop":\(topSafeArea), "paddingBottom":\(bottomSafeArea)},"configColor":["\(handleColor(input:PayME.configColor))"],"actions":{"type":"DEPOSIT","amount":"\(checkIntNil(input: amount))","description":"\(checkStringNil(input: description))"},"extraData":"\(checkStringNil(input:extraData))"}
        """
        let webViewController = WebViewController(nibName: "WebView", bundle: nil)
        let url = urlWebview(env: PayME.env)
        PayME.currentVC = currentVC
        webViewController.urlRequest = url + "\(data)"
        webViewController.setOnSuccessCallback(onSuccess: onSuccess)
        webViewController.setOnErrorCallback(onError: onError)
        
        currentVC.navigationController?.pushViewController(webViewController, animated: true)
        
    }
    
    public func goToTest(currentVC : UIViewController, amount: Int?, description: String?, extraData: String?,
                         onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
                         onError: @escaping (String) -> ()
    ){
        let topSafeArea: CGFloat
        let bottomSafeArea: CGFloat
        if #available(iOS 11.0, *) {
            topSafeArea = currentVC.view.safeAreaInsets.top
            bottomSafeArea = currentVC.view.safeAreaInsets.bottom
        } else {
            topSafeArea = currentVC.topLayoutGuide.length
            bottomSafeArea = currentVC.bottomLayoutGuide.length
        }
        let data =
            """
        {"connectToken":"\(PayME.connectToken)","appToken":"\(PayME.appID)","clientInfo":{"clientId":"\(PayME.deviceID)","platform":"IOS","appVersion":"\(PayME.appVersion!)","sdkVesion":"0.1","sdkType":"IOS","appPackageName":"\(PayME.packageName!)"},"partner":"IOS","partnerTop":"\(topSafeArea)","configColor":["\(handleColor(input:PayME.configColor))"]}
        """
        let webViewController = WebViewController(nibName: "WebView", bundle: nil)
        webViewController.urlRequest = "https://sbx-sdk.payme.com.vn/test"
        //webViewController.urlRequest = "https://tuoitre.vn/"
        webViewController.setOnSuccessCallback(onSuccess: onSuccess)
        webViewController.setOnErrorCallback(onError: onError)
        currentVC.navigationItem.hidesBackButton = true
        currentVC.navigationController?.isNavigationBarHidden = true
        
        currentVC.navigationController?.pushViewController(webViewController, animated: true)
        
    }
    
    public func withdraw(currentVC : UIViewController, amount: Int?, description: String?, extraData: String?,
                         onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
                         onError: @escaping (String) -> ()) {
        currentVC.navigationItem.hidesBackButton = true
        currentVC.navigationController?.isNavigationBarHidden = true
        let topSafeArea: CGFloat
        let bottomSafeArea: CGFloat
        if #available(iOS 11.0, *) {
            topSafeArea = currentVC.view.safeAreaInsets.top
            bottomSafeArea = currentVC.view.safeAreaInsets.bottom
        } else {
            topSafeArea = currentVC.topLayoutGuide.length
            bottomSafeArea = currentVC.bottomLayoutGuide.length
        }
        let data =
            """
        {"connectToken":"\(PayME.connectToken)","appToken":"\(PayME.appID)","clientInfo":{"clientId":"\(PayME.deviceID)","platform":"IOS","appVersion":"\(PayME.appVersion!)","sdkVesion":"0.1","sdkType":"IOS","appPackageName":"\(PayME.packageName!)"},"partner":{"type":"IOS","paddingTop":\(topSafeArea), "paddingBottom":\(bottomSafeArea)},"configColor":["\(handleColor(input:PayME.configColor))"],"actions":{"type":"WITHDRAW","amount":"\(checkIntNil(input: amount))","description":"\(checkStringNil(input: description))"},"extraData":"\(checkStringNil(input:extraData))"}
        """
        let webViewController = WebViewController(nibName: "WebView", bundle: nil)
        let url = urlWebview(env: PayME.env)
        PayME.currentVC = currentVC
        webViewController.urlRequest = url + "\(data)"
        webViewController.setOnSuccessCallback(onSuccess: onSuccess)
        webViewController.setOnErrorCallback(onError: onError)
        
        currentVC.navigationController?.pushViewController(webViewController, animated: true)
        
    }
    
    public func showModal(currentVC : UIViewController){
        PayME.currentVC = currentVC
        currentVC.presentPanModal(Methods())
    }
    
    public static func openQRCode(currentVC : UIViewController) {
        PayME.currentVC = currentVC
        let qrScan = QRScannerController()
        qrScan.setScanSuccess(onScanSuccess: { response in
            PayME.currentVC!.showSpinner(onView: PayME.currentVC!.view)
            qrScan.dismiss(animated: true)
            PayME.payWithQRCode(QRContent: response, onSuccess: { result in
                if ((result["type"] ?? "" as AnyObject) as! String == "Payment")
                {
                    PayME.currentVC = currentVC
                    PayME.amount = result["amount"] as! Int
                    PayME.description = (result["content"] ?? "" as AnyObject) as! String
                    PayME.currentVC!.presentPanModal(Methods())
                    PayME.currentVC!.removeSpinner()
                    
                } else {
                    let alert = UIAlertController(title: "Lỗi", message: "Phương thức này chưa được hỗ trợ", preferredStyle: UIAlertController.Style.alert)
                    
                    
                    currentVC.navigationController?.popViewController(animated: true)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    PayME.currentVC!.present(alert, animated: true, completion: nil)
                    PayME.currentVC!.removeSpinner()
                }
                
            }, onError: { result in
                PayME.currentVC!.removeSpinner()
                if currentVC.navigationController != nil {
                    currentVC.navigationController?.popViewController(animated: true)
                } else {
                    currentVC.dismiss(animated: true, completion: nil)
                }
                PayME.currentVC!.presentPanModal(QRNotFound())
            })
        })
        qrScan.setScanFail(onScanFail: { error in
            
            currentVC.navigationController?.popViewController(animated: true)
            
            PayME.currentVC!.presentPanModal(QRNotFound())
        })
        currentVC.navigationItem.hidesBackButton = true
        currentVC.navigationController?.isNavigationBarHidden = true
        
        currentVC.navigationController?.pushViewController(qrScan, animated: true)
        
    }
    
    public static func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
    public func pay(currentVC : UIViewController, amount: Int, description: String?, extraData: String?) {
        PayME.currentVC = currentVC
        PayME.amount = amount
        PayME.description = description ?? ""
        PayME.currentVC!.presentPanModal(Methods())
    }
    
    // open after this version
    private static func getWalletGraphQL(
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping ([Int:Any]) -> ()) {
        let url = urlGraphQL(env: PayME.env)
        let path = "/graphql"
        let sql = """
        query Query {
          Wallet {
            balance
            cash
            credit
            lockCash
            creditLimit
          }
        }
        """
        let variables : [String: Any] = [:]
        let json: [String: Any] = [
            "query": sql,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        if (PayME.env == PayME.Env.DEV) {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequest(
                onError: { error in
                    onError(error)
                },
                onErrorGraphQL: { errors in
                    print("onErrorGraphQL \(errors[0])")
                },
                
                onSuccess: { data in
                    onSuccess(data)
                    // print("onSuccess \(data)")
                }
            )
        } else {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequestCrypto(
                onErrorGraphQL: { errors in
                    print("onErrorGraphQL \(errors[0])")
                },
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                    // print("onSuccess \(data)")
                }
            )
        }
    }
    
    public static func getWalletInfo(
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping ([Int:Any]) -> ()
    ) {
        let url = urlFeENV(env: PayME.env)
        let path = "/Wallet/Information"
        let clientInfo: [String: String] = [
            "clientId": PayME.deviceID,
            "platform": "IOS",
            "appVersion": PayME.appVersion!,
            "sdkType" : "IOS",
            "sdkVesion": "0.1",
            "appPackageName": PayME.packageName!
        ]
        let data: [String: Any] = [
            "connectToken": PayME.connectToken,
            "clientInfo": clientInfo
        ]
        let params = try? JSONSerialization.data(withJSONObject: data)
        let request = NetworkRequest(url : url, path :path, token: PayME.appID, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
        request.setOnRequestCrypto(
            onError: {(error) in
                onError(error)
            },
            onSuccess : {(response) in
                onSuccess(response)
            }
        )
    }
    
    public static func registerClient(){
        let url = "https://dev-fe.payme.net.vn/graphql"
        let sql = """
        mutation InitMutation($registerInput: ClientRegisterInput!) {
          Client {
            Register(input: $registerInput) {
              clientId
              succeeded
            }
          }
        }
        """
        let variables : [String: Any] = [
            "registerInput": [
                "platform": "WEB",
                "deviceId": "HUY",
                "channel": "11",
                "version": "1.2.8",
                "isEmulator": true,
                "isRoot": false
            ]
        ]
        let parameters: [String: Any] = [
            "query": sql,
            "variables": variables,
        ]
        let headers : HTTPHeaders = ["Authorization":PayME.appID]
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            response in
            print(response)
            switch (response.result) {
            case .success:
                print("Huy")
                print(response)
                break
            case .failure:
                print(Error.self)
            }
        }
    }
    public static func verifyKYC(
        imageFront: String,
        imageBack: String?,
        identifyType: String,
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping ([Int:Any]) -> ()
    ) {
        let url = urlFeENV(env: PayME.env)
        let path = "/v1/Account/Kyc"
        let clientInfo: [String: String] = [
            "clientId": PayME.deviceID,
            "platform": "IOS",
            "appVersion": PayME.appVersion!,
            "sdkType" : "IOS",
            "sdkVesion": "0.1",
            "appPackageName": PayME.packageName!
        ]
        var data : [String: Any]
        if (imageBack != nil) {
            data = [
                "connectToken": PayME.connectToken,
                "clientInfo": clientInfo,
                "identifyType": identifyType,
                "image": ["front" : imageFront, "back": imageBack!]
            ]
        } else {
            data = [
                "connectToken": PayME.connectToken,
                "clientInfo": clientInfo,
                "identifyType": identifyType,
                "image": ["front" : imageFront]
            ]
        }
        print(data)
        let params = try? JSONSerialization.data(withJSONObject: data)
        let request = NetworkRequest(url : url, path :path, token: PayME.appID, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
        request.setOnRequestCrypto(
            onError: {(error) in
                onError(error)
            },
            onSuccess : {(response) in
                print(response)
                onSuccess(response)
            }
        )
    }
    
    
    public static func getTransferMethods(
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping ([Int:Any]) -> ()
    ) {
        let url = urlFeENV(env: PayME.env)
        let path = "/Transfer/GetMethods"
        let clientInfo: [String: String] = [
            "clientId": PayME.deviceID,
            "platform": "IOS",
            "appVersion": PayME.appVersion!,
            "sdkType" : "IOS",
            "sdkVesion": "0.1",
            "appPackageName": PayME.packageName!
        ]
        let data: [String: Any] = [
            "connectToken": PayME.connectToken,
            "clientInfo": clientInfo
        ]
        let params = try? JSONSerialization.data(withJSONObject: data)
        let request = NetworkRequest(url : url, path :path, token: PayME.appID, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
        request.setOnRequestCrypto(
            onError: {(error) in
                onError(error)
            },
            onSuccess : {(response) in
                onSuccess(response)
            }
        )
    }
    public static func postTransferAppWallet(onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
                                             onError: @escaping ([Int:Any]) -> ()){
        let url = urlFeENV(env: PayME.env)
        let path = "/Transfer/AppWallet/Generate"
        let clientInfo: [String: String] = [
            "clientId": PayME.deviceID,
            "platform": "IOS",
            "appVersion": PayME.appVersion!,
            "sdkType" : "IOS",
            "sdkVesion": "0.1",
            "appPackageName": PayME.packageName!
        ]
        let data: [String: Any] = [
            "connectToken": PayME.connectToken,
            "clientInfo": clientInfo,
            "amount" : PayME.amount,
            "destination" : "AppPartner",
            "data" : ["":""]
        ]
        let params = try? JSONSerialization.data(withJSONObject: data)
        let request = NetworkRequest(url : url, path :path, token: PayME.appID, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
        request.setOnRequestCrypto(
            onError: {(error) in
                onError(error)
            },
            onSuccess : {(response) in
                onSuccess(response)
            }
        )
    }
    public static func postTransferNapas(method: MethodInfo,onSuccess: @escaping (Dictionary<String, AnyObject>) -> (), onError: @escaping ([Int:Any]) -> ()) {
        let url = urlFeENV(env: PayME.env)
        let path = "/Transfer/Napas/Generate"
        let clientInfo: [String: String] = [
            "clientId": PayME.deviceID,
            "platform": "IOS",
            "appVersion": PayME.appVersion!,
            "sdkType" : "IOS",
            "sdkVesion": "0.1",
            "appPackageName": PayME.packageName!
        ]
        let data: [String: Any] = [
            "connectToken": PayME.connectToken,
            "clientInfo": clientInfo,
            "amount" : PayME.amount,
            "destination" : "AppPartner",
            "returnUrl" : "https://sbx-fe.payme.vn/",
            "linkedId" : method.linkedId!,
            "bankCode" : method.bankCode!,
            "data" : ["":""]
        ]
        let params = try? JSONSerialization.data(withJSONObject: data)
        let request = NetworkRequest(url : url, path :path, token: PayME.appID, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
        request.setOnRequestCrypto(
            onError: {(error) in
                onError(error)
            },
            onSuccess : {(response) in
                onSuccess(response)
            }
        )
    }
    public static func postTransferPVCB(method: MethodInfo,onSuccess: @escaping (Dictionary<String, AnyObject>) -> (), onError: @escaping ([Int:Any]) -> ()) {
        let url = urlFeENV(env: PayME.env)
        let path = "/Transfer/PVCBank/Generate"
        let clientInfo: [String: String] = [
            "clientId": PayME.deviceID,
            "platform": "IOS",
            "appVersion": PayME.appVersion!,
            "sdkType" : "IOS",
            "sdkVesion": "0.1",
            "appPackageName": PayME.packageName!
        ]
        let data: [String: Any] = [
            "connectToken": PayME.connectToken,
            "clientInfo": clientInfo,
            "amount" : PayME.amount,
            "destination" : "AppPartner",
            "linkedId" : method.linkedId!,
            "data" : ["":""]
        ]
        let params = try? JSONSerialization.data(withJSONObject: data)
        let request = NetworkRequest(url : url, path :path, token: PayME.appID, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
        request.setOnRequestCrypto(
            onError: {(error) in
                onError(error)
            },
            onSuccess : {(response) in
                onSuccess(response)
            }
        )
    }
    
    public static func postTransferPVCBVerify(transferId:Int, OTP:String, onSuccess: @escaping (Dictionary<String, AnyObject>) -> (), onError: @escaping ([Int:Any]) -> ()){
        let url = urlFeENV(env: PayME.env)
        let path = "/Transfer/PVCBank/Verify"
        let clientInfo: [String: String] = [
            "clientId": PayME.deviceID,
            "platform": "IOS",
            "appVersion": PayME.appVersion!,
            "sdkType" : "IOS",
            "sdkVesion": "0.1",
            "appPackageName": PayME.packageName!
        ]
        let data: [String: Any] = [
            "connectToken": PayME.connectToken,
            "clientInfo": clientInfo,
            "transferId" : transferId,
            "destination" : "AppPartner",
            "OTP" : OTP,
            "data" : ["":""]
        ]
        let params = try? JSONSerialization.data(withJSONObject: data)
        let request = NetworkRequest(url : url, path :path, token: PayME.appID, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
        request.setOnRequestCrypto(
            onError: {(error) in
                onError(error)
            },
            onSuccess : {(response) in
                onSuccess(response)
            }
        )
    }
    public static func payWithQRCode(QRContent: String, onSuccess: @escaping (Dictionary<String, AnyObject>) -> (), onError: @escaping ([Int:Any]) -> ()){
        let url = urlFeENV(env: PayME.env)
        let path = "/Pay/PayWithQRCode"
        let clientInfo: [String: String] = [
            "clientId": PayME.deviceID,
            "platform": "IOS",
            "appVersion": PayME.appVersion!,
            "sdkType" : "IOS",
            "sdkVesion": "0.1",
            "appPackageName": PayME.packageName!
        ]
        let data: [String: Any] = [
            "connectToken": PayME.connectToken,
            "clientInfo": clientInfo,
            "data" : QRContent
        ]
        let params = try? JSONSerialization.data(withJSONObject: data)
        let request = NetworkRequest(url : url, path :path, token: PayME.appID, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
        request.setOnRequestCrypto(
            onError: {(error) in
                onError(error)
            },
            onSuccess : {(response) in
                onSuccess(response)
            }
        )
    }
    public static func generateConnectToken(usertId: String, phoneNumber: String?, timestamp: String, onSuccess: @escaping (Dictionary<String, AnyObject>) -> (), onError: @escaping ([Int:Any]) -> ()){
        let url = urlFeENV(env: PayME.env)
        let path = "/Internal/ConnectToken/Generate"
        let data: [String: Any] = [
            "userId" : usertId,
            "phone" : phoneNumber ?? "",
            "timestamp": timestamp
        ]
        let params = try? JSONSerialization.data(withJSONObject: data)
        let request = NetworkRequest(url : url, path :path, token: PayME.appID, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
        request.setOnRequestCrypto(
            onError: {(error) in
                onError(error)
            },
            onSuccess : {(response) in
                onSuccess(response)
            }
        )
    }
}

