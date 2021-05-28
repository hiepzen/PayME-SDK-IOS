//
//  PayME.swift
//  PayMESDK
//
//  Created by HuyOpen on 9/29/20.
//  Copyright © 2020 PayME. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

public class PayME {
    static var description: String = ""
    static var amount: Int = 0
    static var configColor: [String] = [""]

    static var currentVC: UIViewController?
    static var rootVC: UIViewController?
    static var isRecreateNavigationController: Bool = false

    let payMEFunction: PayMEFunction

    public enum Action: String {
        case OPEN = "OPEN"
        case DEPOSIT = "DEPOSIT"
        case WITHDRAW = "WITHDRAW"
        case UTILITY = "UTILITY"
        case FORGOT_PASSWORD = "FORGOT_PASSWORD"
        case TRANSFER = "TRANSFER"
    }

    public enum Env: String {
        case SANDBOX = "sandbox"
        case PRODUCTION = "production"
        case DEV = "dev"
        case STAGING = "staging"
    }

    public enum Language: String {
        case VIETNAM = "vi"
    }

    public enum KYCState {
        case NOT_ACTIVATED
        case NOT_KYC
        case KYC_APPROVED
    }

    public struct ResponseCode {
        public static let EXPIRED = 401
        public static let NETWORK = -1
        public static let SYSTEM = -2
        public static let LIMIT = -3
        public static let ACCOUNT_NOT_ACTIVATED = -4
        public static let ACCOUNT_NOT_KYC = -5
        public static let PAYMENT_ERROR = -6
        public static let ERROR_KEY_ENCODE = -7
        public static let USER_CANCELLED = -8
        public static let ACCOUNT_NOT_LOGIN = -9
    }

    public init(appToken: String, publicKey: String, connectToken: String, appPrivateKey: String, language: Language? = PayME.Language.VIETNAM, env: Env, configColor: [String], showLog: Int = 0) {
        PayME.configColor = configColor
        payMEFunction = PayMEFunction(appToken, publicKey, connectToken, appPrivateKey, language, env, configColor, showLog, PayME.getAppId(appToken))
    }

    public func logout() {
        payMEFunction.resetInitState()
    }

    public func getAccountInfo(
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        payMEFunction.getAccountInfo(onSuccess, onError)
    }

    public func getService(
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        payMEFunction.getService(onSuccess, onError)
    }

    public func getSupportedServices() -> [ServiceConfig] {
        payMEFunction.getSupportedServices()
    }

    public func login(
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        payMEFunction.login(onSuccess, onError)
    }

    public func getWalletInfo(
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> Void,
            onError: @escaping (Dictionary<String, AnyObject>) -> Void
    ) {
        payMEFunction.getWalletInfo(onSuccess, onError)
    }

    public func deposit(
            currentVC: UIViewController, amount: Int?, description: String?, extraData: String?, closeWhenDone: Bool = false,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> Void,
            onError: @escaping (Dictionary<String, AnyObject>) -> Void
    ) {
        payMEFunction.openWallet(true, currentVC, PayME.Action.DEPOSIT, amount, nil, nil, "", closeWhenDone, onSuccess, onError)
    }

    public func withdraw(
            currentVC: UIViewController, amount: Int?, description: String?, extraData: String?, closeWhenDone: Bool = false,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> Void,
            onError: @escaping (Dictionary<String, AnyObject>) -> Void
    ) {
        payMEFunction.openWallet(true, currentVC, PayME.Action.WITHDRAW, amount, nil, nil, "", closeWhenDone, onSuccess, onError)
    }

    public func transfer(
            currentVC: UIViewController, amount: Int?, description: String?, extraData: String?, closeWhenDone: Bool = false,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> Void,
            onError: @escaping (Dictionary<String, AnyObject>) -> Void
    ) {
        payMEFunction.openWallet(true, currentVC, PayME.Action.TRANSFER, amount, description, nil, "", closeWhenDone, onSuccess, onError)
    }

    public func openService(
            currentVC: UIViewController, amount: Int?, description: String?, extraData: String?, service: ServiceConfig,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> Void,
            onError: @escaping (Dictionary<String, AnyObject>) -> Void
    ) {
        payMEFunction.openWallet(true, currentVC, PayME.Action.UTILITY, amount, nil, nil, service.code, false, onSuccess, onError)
    }

    public func openWallet(
            currentVC: UIViewController, action: Action, amount: Int?, description: String?, extraData: String?, serviceCode: String = "",
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> Void,
            onError: @escaping (Dictionary<String, AnyObject>) -> Void
    ) {
        payMEFunction.openWallet(false, currentVC, action, amount, description, extraData, serviceCode, false, onSuccess, onError)
    }

    public func pay(
            currentVC: UIViewController, storeId: Int, orderId: String, amount: Int,
            note: String?, paymentMethodID: Int?, extraData: String?, isShowResultUI: Bool = true,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> ()) {
        payMEFunction.payAction(currentVC, storeId, orderId, amount, note, paymentMethodID, extraData, isShowResultUI, onSuccess, onError)
    }

    public func getPaymentMethods(
            storeId: Int,
            onSuccess: @escaping ([Dictionary<String, Any>]) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        payMEFunction.getPaymentMethods(storeId, onSuccess, onError)
    }

    public func KYC(
            onSuccess: @escaping (Dictionary<String, Any>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        payMEFunction.KYC(onSuccess, onError)
    }

    static private func getAppId(_ appToken: String) -> String {
        var appId: String = ""
        let temp = appToken.components(separatedBy: ".")
        let jwt = temp[1].fromBase64()
        if (jwt != nil) {
            let data = Data(jwt!.utf8)
            if let finalJSON = try? (JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject>) {
                appId = String((finalJSON["appId"] as? Int) ?? 0)
            }
        }
        return appId
    }
}
