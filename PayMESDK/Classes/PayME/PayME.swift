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
    static var appPrivateKey: String = ""
    static var appToken: String = ""
    static var publicKey: String = ""
    static var connectToken: String = ""
    static var env: Env!
    static var configColor: [String] = [""]
    static var description: String = ""
    static var amount: Int = 0
    static var currentVC: UIViewController?
    static var rootVC: UIViewController?
    static var isRecreateNavigationController: Bool = false
    static var appENV: String = ""
    static var appId: String = ""
    static var showLog: Int = 0
    static var loggedIn: Bool = false
    static var language: Language = PayME.Language.VIETNAM

    lazy var payMEFunction = PayMEFunction(self)

    public enum Action: String {
        case OPEN = "OPEN"
        case DEPOSIT = "DEPOSIT"
        case WITHDRAW = "WITHDRAW"
        case UTILITY = "UTILITY"
    }

    public enum Env: String {
        case SANDBOX = "sandbox"
        case PRODUCTION = "production"
        case DEV = "dev"
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
        PayME.appToken = appToken;
        let temp = PayME.appToken.components(separatedBy: ".")
        let jwt = temp[1].fromBase64()
        if (jwt != nil) {
            let data = Data(jwt!.utf8)
            if let finalJSON = try? (JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject>) {
                PayME.appId = String((finalJSON["appId"] as? Int) ?? 0)
            }
        }
        if (env != PayME.env) {
            PayME.env = env
            payMEFunction.clientId = ""
        }
        PayME.configColor = configColor
        payMEFunction.accessToken = ""
        payMEFunction.handShake = ""
        payMEFunction.kycState = ""
        payMEFunction.dataInit = nil
        PayME.appENV = ""
        PayME.loggedIn = false
        PayME.showLog = showLog
        if (language != nil) {
            PayME.language = language!
        }

        payMEFunction.initRequest(publicKey, appPrivateKey, env, appToken, connectToken, UIDevice.current.identifierForVendor!.uuidString, PayME.appId)
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

    static func logoutAction() {
        PayME.loggedIn = false
//        PayME.accessToken = ""
//        PayME.handShake = ""
//        PayME.kycState = ""
//        PayME.dataInit = nil
    }

    public func logout() {
        PayME.logoutAction()
    }

    public func getWalletInfo(
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> Void,
            onError: @escaping (Dictionary<String, AnyObject>) -> Void
    ) {
        payMEFunction.getWalletInfo(onSuccess, onError)
    }

    public func deposit(
            currentVC: UIViewController, amount: Int?, description: String?, extraData: String?,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> Void,
            onError: @escaping (Dictionary<String, AnyObject>) -> Void
    ) {
        payMEFunction.openWallet(currentVC, PayME.Action.DEPOSIT, amount, nil, nil, "", onSuccess, onError)
    }

    public func withdraw(
            currentVC: UIViewController, amount: Int?, description: String?, extraData: String?,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> Void,
            onError: @escaping (Dictionary<String, AnyObject>) -> Void
    ) {
        payMEFunction.openWallet(currentVC, PayME.Action.WITHDRAW, amount, nil, nil, "", onSuccess, onError)
    }

    public func openService(
            currentVC: UIViewController, amount: Int?, description: String?, extraData: String?, service: ServiceConfig,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> Void,
            onError: @escaping (Dictionary<String, AnyObject>) -> Void
    ) {
        payMEFunction.openWallet(currentVC, PayME.Action.UTILITY, amount, nil, nil, service.code, onSuccess, onError)
    }

    public func openWallet(
            currentVC: UIViewController, action: Action, amount: Int?, description: String?, extraData: String?, serviceCode: String = "",
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> Void,
            onError: @escaping (Dictionary<String, AnyObject>) -> Void
    ) {
        payMEFunction.openWallet(currentVC, action, amount, description, extraData, serviceCode, onSuccess, onError)
    }

    public func pay(
            currentVC: UIViewController, storeId: Int, orderId: String, amount: Int,
            note: String?, paymentMethodID: Int?, extraData: String?, isShowResultUI: Bool = true,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> ()) {
        payMEFunction.payAction(currentVC, storeId, orderId, amount, note, paymentMethodID, extraData, isShowResultUI, onSuccess, onError)
    }

    public func getListPaymentMethodID(
            onSuccess: @escaping ([Dictionary<String, Any>]) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        payMEFunction.getListPaymentMethodID(onSuccess, onError)
    }
}
