//
//  PayME.swift
//  PayMESDK
//
//  Created by HuyOpen on 9/29/20.
//  Copyright © 2020 PayME. All rights reserved.
//

import Foundation
import UIKit

protocol StarNodeDelegate: class {
    func endGame()
}

public class PayME{
    var delegate : StarNodeDelegate?
    public static var appPrivateKey: String = ""
    public static var appID: String = ""
    public static var publicKey: String = ""
    private static var connectToken : String = ""
    public static var env : String = ""
    private static var configColor : [String] = [""]
    public static var description : String = ""
    public static var amount : Int = 0
    private static let packageName = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
    private static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    private static let deviceID = UIDevice.current.identifierForVendor!.uuidString
    static var currentVC : UIViewController?

    
    public func showModal(currentVC : UIViewController){
        PayME.currentVC = currentVC
        currentVC.presentPanModal(Methods())
    }
    
    public static func openQRCode(currentVC : UIViewController) {
        PayME.currentVC = currentVC
        let qrScan = QRScannerController()
        qrScan.setScanSuccess(onScanSuccess: { response in
            print(response)
            qrScan.dismiss(animated: true)
            PayME.payWithQRCode(QRContent: response, onSuccess: { result in
                if ((result["type"] ?? "" as AnyObject) as! String == "Payment")
                {
                    PayME.currentVC = currentVC
                    PayME.amount = result["amount"] as! Int
                    PayME.description = (result["content"] ?? "" as AnyObject) as! String
                    PayME.currentVC!.presentPanModal(Methods())
                } else {
                    let alert = UIAlertController(title: "Error", message: "Phương thức này chưa được hỗ trợ", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    PayME.currentVC!.present(alert, animated: true, completion: nil)
                }
                
            }, onError: { result in
                qrScan.dismiss(animated: true)
                PayME.currentVC!.presentPanModal(QRNotFound())
            })
        })
        qrScan.setScanFail(onScanFail: { error in
            qrScan.dismiss(animated: true)
            PayME.currentVC!.presentPanModal(QRNotFound())
        })
        currentVC.present(qrScan, animated: true)
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
    
    public init(appID: String, publicKey: String, connectToken: String, appPrivateKey: String, env: String, configColor: [String]) {
        PayME.appPrivateKey = appPrivateKey;
        PayME.appID = appID;
        PayME.connectToken = connectToken;
        PayME.publicKey = publicKey;
        PayME.env = env;
        PayME.configColor = configColor
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
    public func getEnv() -> String {
        return PayME.env
    }
    public func setEnv(env: String) {
        PayME.env = env
    }
    public func isConnected() -> Bool {
        return false
    }
    public func openWallet(currentVC : UIViewController, action : String, amount: Int?, description: String?, extraData: String?,
                           onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
                           onError: @escaping (String) -> ()
    )-> () {
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
        {"connectToken":"\(PayME.connectToken)","appToken":"\(PayME.appID)","clientInfo":{"clientId":"\(PayME.deviceID)","platform":"IOS","appVersion":"\(PayME.appVersion!)","sdkVesion":"0.1","sdkType":"IOS","appPackageName":"\(PayME.packageName!)"},"partner":{"type":"IOS","paddingTop":"\(topSafeArea)", "paddingBottom":"\(bottomSafeArea)"},"configColor":["\(handleColor(input:PayME.configColor))"],"actions":{"type":"\(action)","amount":"\(checkIntNil(input: amount))","description":"\(checkStringNil(input: description))"},"extraData":"\(checkStringNil(input:extraData))"}
        """
        let webViewController = WebViewController(nibName: "WebView", bundle: nil)
        let url = PayME.urlWebview(env: PayME.env)
        PayME.currentVC = currentVC
        webViewController.urlRequest = url + "\(data)"
        //webViewController.urlRequest = "https://tuoitre.vn/"
        webViewController.setOnSuccessCallback(onSuccess: onSuccess)
        webViewController.setOnErrorCallback(onError: onError)
        currentVC.navigationItem.hidesBackButton = true
        currentVC.navigationController?.isNavigationBarHidden = true
        currentVC.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    public func deposit(currentVC : UIViewController, amount: Int?, description: String?, extraData: String?,
    onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
    onError: @escaping (String) -> ()) {
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
        {"connectToken":"\(PayME.connectToken)","appToken":"\(PayME.appID)","clientInfo":{"clientId":"\(PayME.deviceID)","platform":"IOS","appVersion":"\(PayME.appVersion!)","sdkVesion":"0.1","sdkType":"IOS","appPackageName":"\(PayME.packageName!)"},"partner":{"type":"IOS","paddingTop":"\(topSafeArea)", "paddingBottom":"\(bottomSafeArea)"},"configColor":["\(handleColor(input:PayME.configColor))"],"actions":{"type":"DEPOSIT","amount":"\(checkIntNil(input: amount))","description":"\(checkStringNil(input: description))"},"extraData":"\(checkStringNil(input:extraData))"}
        """
        let webViewController = WebViewController(nibName: "WebView", bundle: nil)
        let url = PayME.urlWebview(env: PayME.env)
        PayME.currentVC = currentVC
        webViewController.urlRequest = url + "\(data)"
        webViewController.setOnSuccessCallback(onSuccess: onSuccess)
        webViewController.setOnErrorCallback(onError: onError)
        currentVC.navigationItem.hidesBackButton = true
        currentVC.navigationController?.isNavigationBarHidden = true
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
        {"connectToken":"\(PayME.connectToken)","appToken":"\(PayME.appID)","clientInfo":{"clientId":"\(PayME.deviceID)","platform":"IOS","appVersion":"\(PayME.appVersion!)","sdkVesion":"0.1","sdkType":"IOS","appPackageName":"\(PayME.packageName!)"},"partner":{"type":"IOS","paddingTop":"\(topSafeArea)", "paddingBottom":"\(bottomSafeArea)"},"configColor":["\(handleColor(input:PayME.configColor))"],"actions":{"type":"WITHDRAW","amount":"\(checkIntNil(input: amount))","description":"\(checkStringNil(input: description))"},"extraData":"\(checkStringNil(input:extraData))"}
        """
        let webViewController = WebViewController(nibName: "WebView", bundle: nil)
        let url = PayME.urlWebview(env: PayME.env)
        PayME.currentVC = currentVC
        webViewController.urlRequest = url + "\(data)"
        webViewController.setOnSuccessCallback(onSuccess: onSuccess)
        webViewController.setOnErrorCallback(onError: onError)
        currentVC.navigationItem.hidesBackButton = true
        currentVC.navigationController?.isNavigationBarHidden = true
        currentVC.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    public func pay(currentVC : UIViewController, amount: Int, description: String?) {
        PayME.currentVC = currentVC
        PayME.amount = amount
        PayME.description = description ?? ""
        PayME.currentVC!.presentPanModal(Methods())
    }
    
    
    
    private func handleColor(input: [String]) -> String {
        let newString = input.joined(separator: "\",\"")
        return newString
    }
    private func checkIntNil(input: Int?) -> String {
        if input != nil {
            return String(input!)
        }
        return ""
    }
    private func checkUserInfoNil(input: UserInfo?) -> String{
        if input != nil {
            return input!.toJson()
        }
        return "{}"
    }
    private func checkStringNil(input: String?) -> String {
        if input != nil {
            return input!
        }
        return ""
    }
    
    public static func formatMoney(input: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 3
        let temp = numberFormatter.string(from: NSNumber(value: input))
        return "\(temp!)"
    }


    private static func  urlFeENV(env: String?) -> String {
        if (env == "sandbox") {
            return "https://sbx-wam.payme.vn/v1/"
        }
        return "https://wam.payme.vn/v1/"
    }
    private static func  urlWebview(env: String?) -> String {
        if (env == "sandbox") {
            return "https://sbx-sdk.payme.com.vn/active/"
        }
        return "https://sdk.payme.com.vn/active/"
    }
    public func getWalletInfo(
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping ([Int:Any]) -> ()
    ) {
        let url = PayME.urlFeENV(env: PayME.env)
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
        onStart: {},
        onError: {(error) in
            onError(error)
        },
       onSuccess : {(response) in
            onSuccess(response)
        },
       onFinally: {}, onExpired: {})
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
        onStart: {},
        onError: {(error) in
            onError(error)
        },
       onSuccess : {(response) in
            onSuccess(response)
        },
       onFinally: {}, onExpired: {})
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
         onStart: {},
         onError: {(error) in
             onError(error)
         },
        onSuccess : {(response) in
             onSuccess(response)
         },
        onFinally: {}, onExpired: {})
        
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
         onStart: {},
         onError: {(error) in
             onError(error)
         },
        onSuccess : {(response) in
             onSuccess(response)
         },
        onFinally: {}, onExpired: {})
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
         onStart: {},
         onError: {(error) in
             onError(error)
         },
        onSuccess : {(response) in
             onSuccess(response)
         },
        onFinally: {}, onExpired: {})
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
         onStart: {},
         onError: {(error) in
             onError(error)
         },
        onSuccess : {(response) in
             onSuccess(response)
         },
        onFinally: {}, onExpired: {})
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
         onStart: {},
         onError: {(error) in
             onError(error)
         },
        onSuccess : {(response) in
             onSuccess(response)
         },
        onFinally: {}, onExpired: {})
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
         onStart: {},
         onError: {(error) in
             onError(error)
         },
        onSuccess : {(response) in
             onSuccess(response)
         },
        onFinally: {}, onExpired: {})
    }
    
    
    
    
    
}

