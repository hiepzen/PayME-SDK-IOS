//
//  PayME.swift
//  PayMESDK
//
//  Created by HuyOpen on 9/29/20.
//  Copyright © 2020 PayME. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

public class PayME {
    static var description: String = ""
    static var amount: Int = 0
    static var configColor: [String] = [""]

    static var currentVC: UIViewController?
    static var rootVC: UIViewController?
    static var isRecreateNavigationController: Bool = false
    static var isWebviewOpening: Bool = false

    let payMEFunction: PayMEFunction

    public enum Action: String {
        case OPEN
        case DEPOSIT
        case WITHDRAW
        case UTILITY
        case FORGOT_PASSWORD
        case TRANSFER
        case OPEN_HISTORY
    }

    public enum Env: String {
        case SANDBOX = "sandbox"
        case PRODUCTION = "production"
        case DEV = "dev"
        case STAGING = "staging"
    }

    public enum Language {
        public static let VIETNAMESE = "vi"
        public static let ENGLISH = "en"
    }

    public enum KYCState {
        case NOT_ACTIVATED
        case NOT_KYC
        case KYC_APPROVED
        case KYC_REJECTED
        case KYC_REVIEW
    }

    public enum ResponseCode {
        public static let EXPIRED = 401
        public static let OTHER = 0
        public static let NETWORK = -1
        public static let SYSTEM = -2
        public static let LIMIT = -3
        public static let ACCOUNT_NOT_ACTIVATED = -4
        public static let ACCOUNT_NOT_KYC = -5
        public static let PAYMENT_ERROR = -6
        public static let ERROR_KEY_ENCODE = -7
        public static let USER_CANCELLED = -8
        public static let ACCOUNT_NOT_LOGIN = -9
        public static let BALANCE_ERROR = -10
        public static let PAYMENT_PENDING = -11
        public static let ACCOUNT_ERROR = -12
    }

    public init(appToken: String, publicKey: String, connectToken: String, appPrivateKey: String, language: String? = PayME.Language.VIETNAMESE, env: Env, configColor: [String], showLog: Int = 0) {
        PayME.configColor = configColor
        payMEFunction = PayMEFunction(appToken, publicKey, connectToken, appPrivateKey, language, env, configColor, showLog, PayME.getAppId(appToken))
    }

    public func logout() {
        payMEFunction.resetInitState()
    }

    public func close() {
        PaymentModalController.isShowCloseModal = false
        if PayME.isWebviewOpening {
            if PayME.isRecreateNavigationController {
                PayME.currentVC?.dismiss(animated: true)
            } else {
                PayME.currentVC?.navigationController?.popViewController(animated: true)
            }
        } else {
            PayME.currentVC?.dismiss(animated: true)
        }
    }

    public func getAccountInfo(
        onSuccess: @escaping ([String: AnyObject]) -> Void,
        onError: @escaping ([String: AnyObject]) -> Void
    ) {
        payMEFunction.getAccountInfo(onSuccess, onError)
    }

    public func getSupportedServices(
        onSuccess: @escaping ([ServiceConfig]) -> Void,
        onError: @escaping ([String: AnyObject]) -> Void
    ) {
        payMEFunction.getSupportedServices(onSuccess, onError)
    }

    public func login(
        onSuccess: @escaping ([String: AnyObject]) -> Void,
        onError: @escaping ([String: AnyObject]) -> Void
    ) {
        payMEFunction.login(onSuccess, onError)
    }

    public func getWalletInfo(
        onSuccess: @escaping ([String: AnyObject]) -> Void,
        onError: @escaping ([String: AnyObject]) -> Void
    ) {
        payMEFunction.getWalletInfo(onSuccess, onError)
    }

    public func deposit(
        currentVC: UIViewController, amount: Int?, description: String?, extraData: String?, closeWhenDone: Bool = false,
        onSuccess: @escaping ([String: AnyObject]) -> Void,
        onError: @escaping ([String: AnyObject]) -> Void
    ) {
        payMEFunction.openWallet(true, currentVC, PayME.Action.DEPOSIT, amount, nil, nil, "", closeWhenDone, onSuccess, onError)
    }

    public func withdraw(
        currentVC: UIViewController, amount: Int?, description: String?, extraData: String?, closeWhenDone: Bool = false,
        onSuccess: @escaping ([String: AnyObject]) -> Void,
        onError: @escaping ([String: AnyObject]) -> Void
    ) {
        payMEFunction.openWallet(true, currentVC, PayME.Action.WITHDRAW, amount, nil, nil, "", closeWhenDone, onSuccess, onError)
    }

    public func transfer(
        currentVC: UIViewController, amount: Int?, description: String?, extraData: String?, closeWhenDone: Bool = false,
        onSuccess: @escaping ([String: AnyObject]) -> Void,
        onError: @escaping ([String: AnyObject]) -> Void
    ) {
        payMEFunction.openWallet(true, currentVC, PayME.Action.TRANSFER, amount, description, nil, "", closeWhenDone, onSuccess, onError)
    }

    public func openHistory(
        currentVC: UIViewController,
        onSuccess: @escaping ([String: AnyObject]) -> Void,
        onError: @escaping ([String: AnyObject]) -> Void
    ) {
        payMEFunction.openWallet(true, currentVC, PayME.Action.OPEN_HISTORY, nil, "", nil, "", false, onSuccess, onError)
    }

    public func openService(
        currentVC: UIViewController, amount: Int?, description: String?, extraData: String?, service: ServiceConfig,
        onSuccess: @escaping ([String: AnyObject]) -> Void,
        onError: @escaping ([String: AnyObject]) -> Void
    ) {
        payMEFunction.openWallet(true, currentVC, PayME.Action.UTILITY, amount, nil, nil, service.code, false, onSuccess, onError)
    }

    public func openWallet(
        currentVC: UIViewController, action: Action, amount: Int?, description: String?, extraData: String?,
        onSuccess: @escaping ([String: AnyObject]) -> Void,
        onError: @escaping ([String: AnyObject]) -> Void
    ) {
        payMEFunction.openWallet(false, currentVC, action, amount, description, extraData, "", false, onSuccess, onError)
    }

    public func pay(
        currentVC: UIViewController, storeId: Int?, userName: String?, orderId: String, amount: Int,
        note: String?, payCode: String, extraData: String?, isShowResultUI: Bool = true,
        onSuccess: @escaping ([String: AnyObject]) -> Void,
        onError: @escaping ([String: AnyObject]) -> Void
    ) {
        payMEFunction.payAction(
            currentVC: currentVC, storeId: storeId, userName: userName, orderId: orderId, amount: amount, note: note,
            payCode: payCode, extraData: extraData, isShowResultUI: isShowResultUI,
            onSuccess: onSuccess, onError: onError
        )
    }

    public func scanQR(
        currentVC: UIViewController, payCode: String,
        onSuccess: @escaping ([String: AnyObject]) -> Void,
        onError: @escaping ([String: AnyObject]) -> Void
    ) {
        payMEFunction.openQRCode(currentVC: currentVC, payCode: payCode, onSuccess: onSuccess, onError: onError, isStartDirectFromUser: true)
    }

    public func payQRCode(
        currentVC: UIViewController, qr: String, payCode: String,
        isShowResultUI: Bool = true,
        onSuccess: @escaping ([String: AnyObject]) -> Void,
        onError: @escaping ([String: AnyObject]) -> Void
    ) {
        payMEFunction.payQRCode(currentVC: currentVC, qr: qr, payCode: payCode, isShowResultUI: isShowResultUI, onSuccess: onSuccess, onError: onError)
    }

    public func openKYC(
        currentVC: UIViewController,
        onSuccess: @escaping () -> Void,
        onError: @escaping ([String: AnyObject]) -> Void
    ) {
        payMEFunction.KYC(currentVC, onSuccess, onError)
    }

    public func setLanguage(language: String) {
        PayMEFunction.language = language
    }

    public func getRemainingQuota(onSuccess: @escaping (Int) -> Void, onError: @escaping ([String: AnyObject]) -> Void) {
        payMEFunction.getRemainingQuota(onSuccess, onError)
    }

    private static func getAppId(_ appToken: String) -> String {
        var appId = ""
        let temp = appToken.components(separatedBy: ".")
        let jwt = temp[1].fromBase64()
        if jwt != nil {
            let data = Data(jwt!.utf8)
            if let finalJSON = try? (JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: AnyObject]) {
                appId = String((finalJSON["appId"] as? Int) ?? 0)
            }
        }
        return appId
    }
}
