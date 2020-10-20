//
//  PayME.swift
//  PayMESDK
//
//  Created by HuyOpen on 9/29/20.
//  Copyright © 2020 PayME. All rights reserved.
//

import Foundation
import UIKit

public class PayME {
    private var appPrivateKey: String
    private var appID: String
    private var publicKey: String
    private var connectToken : String
    private var env : String
    private var configColor : [String]
    private let packageName = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    private let deviceID = UIDevice.current.identifierForVendor!.uuidString

    public init(appID: String, publicKey: String, connectToken: String, appPrivateKey: String, env: String, configColor: [String]) {
        self.appPrivateKey = appPrivateKey;
        self.appID = appID;
        self.connectToken = connectToken;
        self.publicKey = publicKey;
        self.env = env;
        self.configColor = configColor
    }
    public func setPrivateKey(appPrivateKey : String) {
        self.appPrivateKey = appPrivateKey
    }
    public func setAppID(appID : String) {
        self.appID = appID
    }
    public func setPublicKey(publicKey: String) {
        self.publicKey = publicKey
    }
    public func setAppPrivateKey(appPrivateKey: String) {
        self.appPrivateKey = appPrivateKey
    }
    public func getAppID() -> String {
        return self.appID
    }
    public func getPublicKey() -> String{
        return self.publicKey
    }
    public func getConnectToken() -> String{
        return self.connectToken
    }
    public func getAppPrivateKey() -> String {
        return self.appPrivateKey
    }
    public func getEnv() -> String {
        return self.env
    }
    public func setEnv(env: String) {
        self.env = env
    }
    public func isConnected() -> Bool {
        return false
    }
    public func openWallet(currentVC : UIViewController, action : String, amount: Int?, description: String?, extraData: String?,
                           onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
                           onError: @escaping (String) -> ()
    )-> () {
        var data =
        """
        {"connectToken":"\(self.connectToken)","appToken":"\(self.appID)","clientInfo":{"clientId":"\(self.deviceID)","platform":"IOS","appVersion":"\(self.appVersion!)","sdkVesion":"0.1","sdkType":"IOS","appPackageName":"\(self.packageName!)"},"partner":"IOS","configColor":["\(handleColor(input:self.configColor))"]}
        """
        let webViewController = WebViewController(nibName: "WebView", bundle: nil)
        let url = urlWebview(env: self.env)
        webViewController.urlRequest = url + "\(data)"
        //webViewController.urlRequest = "https://tuoitre.vn/"
        webViewController.setOnSuccessCallback(onSuccess: onSuccess)
        webViewController.setOnErrorCallback(onError: onError)
        currentVC.navigationItem.hidesBackButton = true
        currentVC.navigationController?.isNavigationBarHidden = true
        currentVC.navigationController?.pushViewController(webViewController, animated: true)
    }
    private func handleColor(input: [String]) -> String {
        let newString = input.joined(separator: "\",\"")
        print(newString)
        return newString
    }
    private func checkDoubleNil(input: Double?) -> String {
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

    private func urlFeENV(env: String?) -> String {
        if (env == "sandbox") {
            return "https://sbx-wam.payme.vn/v1/"
        }
        return "https://wam.payme.vn/v1/"
    }
    private func urlWebview(env: String?) -> String {
        if (env == "sandbox") {
            return "https://sbx-sdk.payme.com.vn/active/"
        }
        return "https://sdk.payme.com.vn/active/"
    }
    public func getWalletInfo(
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping ([Int:Any]) -> ()
    ) {
        let url = urlFeENV(env: self.env)
        let path = "/Wallet/Information"
        let clientInfo: [String: String] = [
            "clientId": self.deviceID,
            "platform": "IOS",
            "appVersion": self.appVersion!,
            "sdkType" : "IOS",
            "sdkVesion": "0.1",
            "appPackageName": self.packageName!
        ]
        let data: [String: Any] = [
            "connectToken": self.connectToken,
            "clientInfo": clientInfo
        ]
        let params = try? JSONSerialization.data(withJSONObject: data)
        let request = NetworkRequest(url : url, path :path, token: self.appID, params: params, publicKey: self.publicKey, privateKey: self.appPrivateKey)
        request.setOnRequestCrypto(
        onStart: {},
        onError: {(error) in
            print(error)
            onError(error)
        },
       onSuccess : {(response) in
            print(response)
            onSuccess(response)
        },
       onFinally: {}, onExpired: {})
    }
    
}
