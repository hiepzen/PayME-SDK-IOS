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
    internal static var rootVC : UIViewController?
    internal static var webviewController: WebViewController?
    internal static var isRecreateNavigationController: Bool = false
    internal static var accessToken : String = ""
    internal static var handShake : String = ""

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
        PayME.accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjA4MDIsImFjY291bnRJZCI6NDk1OTQ3OTIxLCJzY29wZSI6W10sImNsaWVudElkIjoiQUQxRTVCOUMtNUFDMy00NUE3LTk3NUEtQjdFOTNCREFCMjY5IiwiYXBwSWQiOjEsImlhdCI6MTYxMDUzMjg5NH0.4P3gsa7EbDd8MLtpqW4iQJq3ZCDyotVetniUi3m9i28"
        PayME.handShake = ""
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
    
    // cần thay API
    public static func getAccountInfo(
        onSuccess: @escaping ([String: AnyObject]) -> (),
        onError: @escaping ([String: AnyObject]) -> ()
    
    ) {
        if (PayME.clientID != "") {
            API.initAccount(clientID: PayME.clientID,
                                 onSuccess: { responseAccessToken in
                                    let result = responseAccessToken["OpenEWallet"]!["Init"] as! [String: AnyObject]
                                    let accessToken = result["accessToken"] as? String
                                    PayME.accessToken = accessToken ?? ""
                                    onSuccess(result)
                                 }, onError: { errorAccessToken in
                                    onError(errorAccessToken)
                                 }
            )
        } else {
            API.registerClient(onSuccess: { response in
                let result = response["Client"]!["Register"] as! [String: AnyObject]
                let clientID = result["clientId"] as! String
                PayME.clientID = clientID
                print(clientID)
                API.initAccount(clientID: PayME.clientID,
                    onSuccess: { responseAccessToken in
                        let result = responseAccessToken["OpenEWallet"]!["Init"] as! [String: AnyObject]
                        let accessToken = result["accessToken"] as? String
                        PayME.accessToken = accessToken ?? ""
                       onSuccess(result)
                    }, onError: { errorAccessToken in
                       onError(errorAccessToken)
                    }
                )
            }, onError: {b in })
        }
    }
    
    public static func initSDK(
        onSuccess: @escaping ([String: AnyObject]) -> (),
        onError: @escaping ([String: AnyObject]) -> ()
    ){
        if (PayME.clientID != "") {
            API.initAccount(clientID: PayME.clientID,
                                 onSuccess: { responseAccessToken in
                                    let result = responseAccessToken["OpenEWallet"]!["Init"] as! [String: AnyObject]
                                    let accessToken = result["accessToken"] as? String
                                    PayME.accessToken = accessToken ?? ""
                                    onSuccess(result)
                                 }, onError: { errorAccessToken in
                                    onError(errorAccessToken)
                                 }
            )
        } else {
            API.registerClient(onSuccess: { response in
                let result = response["Client"]!["Register"] as! [String: AnyObject]
                let clientID = result["clientId"] as! String
                PayME.clientID = clientID
                print(clientID)
                API.initAccount(clientID: PayME.clientID,
                    onSuccess: { responseAccessToken in
                        let result = responseAccessToken["OpenEWallet"]!["Init"] as! [String: AnyObject]
                        let accessToken = result["accessToken"] as? String
                        PayME.accessToken = accessToken ?? ""
                       onSuccess(result)
                    }, onError: { errorAccessToken in
                       onError(errorAccessToken)
                    }
                )
            }, onError: {error in
                onError(error)
            })
        }
    }
    public func openWallet(currentVC : UIViewController, action : Action, amount: Int?, description: String?, extraData: String?,
                           onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
                           onError: @escaping ([String:AnyObject]) -> ()
    )-> () {
        currentVC.navigationItem.hidesBackButton = true
        currentVC.navigationController?.isNavigationBarHidden = true
        PayME.currentVC = currentVC
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
                "type":"\(action)",
                "amount":0
              },
              "env": "\(PayME.env.rawValue)",
              "showLog" : "1"
            }
            """
            let webViewController = WebViewController(nibName: "WebView", bundle: nil)
            let url = urlWebview(env: PayME.env)
            PayME.webviewController = webViewController
            webViewController.urlRequest = url + "\(data)"
            webViewController.setOnSuccessCallback(onSuccess: onSuccess)
            webViewController.setOnErrorCallback(onError: onError)
            if currentVC.navigationController != nil {
                PayME.currentVC = currentVC
                PayME.rootVC = currentVC
                currentVC.navigationController?.pushViewController(webViewController, animated: true)
            } else {
                let navigationController = UINavigationController(rootViewController: webViewController)
                PayME.currentVC = webViewController
                PayME.rootVC = currentVC
                PayME.isRecreateNavigationController = true
                if #available(iOS 13.0, *) {
                    PayME.currentVC?.isModalInPresentation = true
                }
                currentVC.present(navigationController, animated: true, completion: nil)
            }
            
        } else {
            API.registerClient(onSuccess: { response in
                let result = response["Client"]!["Register"] as! [String: AnyObject]
                let clientID = result["clientId"] as! String
                PayME.clientID = clientID
                //PayME.openQRCode(currentVC: currentVC)
              
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
                  },
                    "env": "\(PayME.env.rawValue)",
                    "showLog" : "1"
                }
                """
                let webViewController = WebViewController(nibName: "WebView", bundle: nil)
                let url = urlWebview(env: PayME.env)

                PayME.webviewController = webViewController

                webViewController.urlRequest = url + "\(data)"
                webViewController.setOnSuccessCallback(onSuccess: onSuccess)
                webViewController.setOnErrorCallback(onError: onError)

                if currentVC.navigationController != nil {
                    PayME.currentVC = currentVC
                    PayME.rootVC = currentVC
                    currentVC.navigationController?.pushViewController(webViewController, animated: true)
                } else {
                    let navigationController = UINavigationController(rootViewController: webViewController)
                    PayME.currentVC = webViewController
                    PayME.rootVC = currentVC
                    PayME.isRecreateNavigationController = true
                    if #available(iOS 13.0, *) {
                        PayME.currentVC?.isModalInPresentation = true
                    }
                    currentVC.present(navigationController, animated: true, completion: {
                    })
                }
                
            }, onError: { error in
                onError(error)
            })
        }
    }

    public func abc() {
        var dictionary = ["kycIdentifyImg": true, "kycFace": true, "kycVideo": true]
        var kycController = KYCController(flowKYC: dictionary)
        kycController.kyc()
    }
    
    public func deposit(currentVC : UIViewController, amount: Int?, description: String?, extraData: String?,
                        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
                        onError: @escaping ([String : AnyObject]) -> ()) {
        openWallet(currentVC: currentVC, action: PayME.Action.DEPOSIT, amount: amount, description: nil, extraData: nil, onSuccess: onSuccess, onError: onError)
    }
    
    public func withdraw(currentVC : UIViewController, amount: Int?, description: String?, extraData: String?,
                         onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
                         onError: @escaping ([String : AnyObject]) -> ()) {
        openWallet(currentVC: currentVC, action: PayME.Action.WITHDRAW, amount: amount, description: nil, extraData: nil, onSuccess: onSuccess, onError: onError)
    }
    
    public func showModal(currentVC : UIViewController){
        PayME.currentVC = currentVC
        currentVC.presentPanModal(Methods())
    }
    
    public static func openQRCode(currentVC : UIViewController) {
        let qrScan = QRScannerController()
        qrScan.setScanSuccess(onScanSuccess: { response in
            PayME.currentVC!.showSpinner(onView: PayME.currentVC!.view)
            qrScan.dismiss(animated: true)
            API.readQRContent(qrContent: response, onSuccess: { response in
                print(response)
                let payment = response["OpenEWallet"]!["Payment"] as! [String:AnyObject]
                let detect = payment["Detect"] as! [String:AnyObject]
                let succeeded = detect["succeeded"] as! Bool
                if (succeeded == true) {
                    PayME.currentVC!.removeSpinner()
                    let methods = Methods()
                    methods.amount = (detect["amount"] as? Int) ?? 0
                    methods.storeId = (detect["stordeId"] as? Int) ?? 0
                    methods.orderId = (detect["orderId"] as? Int) ?? 0
                    methods.note = (detect["note"] as? String) ?? ""
                    if (PayME.accessToken != "") {
                        PayME.currentVC!.presentPanModal(methods)
                    } else {
                        toastMess(title: "Lỗi", message: "Vui lòng mở web SDK để thực hiện kích hoạt ví")
                    }
                } else {
                    PayME.currentVC!.removeSpinner()
                    if currentVC.navigationController != nil {
                        currentVC.navigationController?.popViewController(animated: true)
                    } else {
                        currentVC.dismiss(animated: true, completion: nil)
                    }
                    PayME.currentVC!.presentPanModal(QRNotFound())
                }
                
            }, onError: { error in
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
            PayME.rootVC!.presentPanModal(QRNotFound())
            PayME.currentVC!.removeSpinner()
            PayME.currentVC!.navigationController?.popViewController(animated: true)
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
    
    public func pay(currentVC : UIViewController,storeId: Int, orderId: Int, amount: Int, note: String?, extraData: String?) {
        print(PayME.accessToken)
        PayME.currentVC = currentVC
        let methods = Methods()
        methods.amount = amount
        methods.storeId = storeId
        methods.orderId = orderId
        methods.note = note ?? ""
        methods.extraData = extraData ?? ""
        if (PayME.accessToken != "") {
            PayME.currentVC!.presentPanModal(methods)
        } else {
            toastMess(title: "Lỗi", message: "Vui lòng mở web SDK để thực hiện kích hoạt ví")
        }
    }
    
    public static func getWalletInfo(
        onSuccess: @escaping ([String: AnyObject]) -> (),
        onError: @escaping ([String: AnyObject]) -> ()
    ){
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
                    toastMess(title: "Lỗi", message: error["message"] as! String)
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                  // print("onSuccess \(data)")
                }
            )
        } else {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequestCrypto(
                onError: { error in
                    toastMess(title: "Lỗi", message: error["message"] as! String)
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                }
            )
        }
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
    
}

