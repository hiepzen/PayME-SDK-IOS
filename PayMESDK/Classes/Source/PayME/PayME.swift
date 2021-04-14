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
import AVFoundation

public class PayME {
    internal static var appPrivateKey: String = ""
    internal static var appToken: String = ""
    internal static var publicKey: String = ""
    internal static var connectToken: String = ""
    internal static var env: Env!
    internal static var configColor: [String] = [""]
    internal static var description: String = ""
    internal static var amount: Int = 0
    internal static let packageName = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
    internal static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    internal static let deviceID = UIDevice.current.identifierForVendor!.uuidString
    internal static var clientID: String = ""
    internal static var currentVC: UIViewController?
    internal static var rootVC: UIViewController?
    internal static var webviewController: WebViewController?
    internal static var isRecreateNavigationController: Bool = false
    internal static var accessToken: String = ""
    internal static var handShake: String = ""
    internal static var kycState: String = ""
    internal static var appENV: String = ""
    internal static var dataInit: [String: AnyObject]? = nil
    internal static var appId: String = ""
    internal static var showLog: Int = 0
    internal static var loggedIn: Bool = false
    internal static var configService = Array<ServiceConfig>()
    internal static var language: Language = PayME.Language.VIETNAM

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

    public enum CompassPoint {
        case NotActivated
        case NotKYC
        case KYCOK
    }

    public struct ResponseCode {
        public static let EXPIRED = 401
        public static let NETWORK = -1
        public static let SYSTEM = -2
        public static let LIMIT = -3
        public static let ACCOUNT_NOT_ACTIVETES = -4
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
                PayME.appId = String((finalJSON!["appId"] as? Int) ?? 0)
            } else {
                PayME.appId = ""
            }
        } else {
            PayME.appId = ""
        }
        if (env != PayME.env) {
            PayME.env = env
            PayME.clientID = ""
        }
        PayME.connectToken = connectToken
        PayME.publicKey = publicKey
        PayME.appPrivateKey = appPrivateKey

        PayME.configColor = configColor
        PayME.accessToken = ""
        PayME.handShake = ""
        PayME.kycState = ""
        PayME.appENV = ""
        PayME.loggedIn = false
        PayME.dataInit = nil
        PayME.showLog = showLog
        if (language != nil) {
            PayME.language = language!
        }
    }

    public func getAccountInfo(
            onSuccess: @escaping ([String: AnyObject]) -> (),
            onError: @escaping ([String: AnyObject]) -> ()
    ) {
        if (PayME.loggedIn == true) {
            PayME.initSDK(
                    onSuccess: { success in onSuccess(success) },
                    onError: { error in onError(error) })
        } else {
            onError(["code": PayME.ResponseCode.ACCOUNT_NOT_LOGIN as AnyObject, "message": "Vui lòng đăng nhập để tiếp tục" as AnyObject])
        }
    }

    public func getService(
            onSuccess: @escaping ([String: AnyObject]) -> (),
            onError: @escaping ([String: AnyObject]) -> ()
    ) {
        API.getService(
                onSuccess: { success in onSuccess(success) },
                onError: { error in onError(error) }
        )
    }

    public func getSupportedServices() -> [ServiceConfig] {
        PayME.configService
    }

    internal static func initSDK(
            onSuccess: @escaping ([String: AnyObject]) -> (),
            onError: @escaping ([String: AnyObject]) -> ()
    ) {
        if (PayME.clientID != "") {
            initAccount(onSuccess, onError)
        } else {
            API.registerClient(onSuccess: { response in
                let result = response["Client"]!["Register"] as! [String: AnyObject]
                let clientID = result["clientId"] as! String
                PayME.clientID = clientID
                initAccount(onSuccess, onError)
            }, onError: { error in onError(error) })
        }
    }

    private static func initAccount(
            _ onSuccess: @escaping ([String: AnyObject]) -> (),
            _ onError: @escaping ([String: AnyObject]) -> ()
    ) {
        API.initAccount(
                clientID: PayME.clientID,
                onSuccess: { responseAccessToken in
                    let result = responseAccessToken["OpenEWallet"]!["Init"] as! [String: AnyObject]
                    let accessToken = result["accessToken"] as? String
                    let kycState = result["kyc"]!["state"] as? String
                    let appENV = result["appEnv"] as? String

                    PayME.accessToken = accessToken ?? ""
                    PayME.appENV = appENV ?? ""
                    PayME.kycState = kycState ?? ""
                    PayME.dataInit = result

                    API.getSetting(onSuccess: { success in
                        let configs = success["Setting"]!["configs"] as! [[String: AnyObject]]
                        if let configLimitPayment = configs.first(where: { config in
                            let key = (config["key"] as? String) ?? ""
                            return key == "limit.param.amount.payment"
                        }) {

                            Methods.min = (configLimitPayment["value"]!["min"] as? Int) ?? 10000
                            Methods.max = (configLimitPayment["value"]!["max"] as? Int) ?? 100000000
                        } else {
                            onError(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": "Không lấy được config thanh toán, vui lòng thử lại sau" as AnyObject])
                        }

                        if let configService = configs.first(where: { config in
                            let key = (config["key"] as? String) ?? ""
                            return key == "service.main.visible"
                        }) {
                            self.configService = Array<ServiceConfig>()
                            let values: [AnyObject]
                            let valueConfigService = configService["value"]
                            if (valueConfigService is String) {
                                values = (convertStringToDictionary(text: valueConfigService as! String))!["listService"] as! [AnyObject]
                            } else {
                                values = (configService["value"] as AnyObject)["listService"] as! [AnyObject]
                            }
                            for value in values {
                                let enable = value["enable"] as! Bool
                                if (enable) {
                                    self.configService.append(ServiceConfig(value["code"] as! String, value["description"] as! String))
                                }
                            }
                        } else {
                            onError(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": "Không lấy được config dịch vụ, vui lòng thử lại sau" as AnyObject])
                        }

                        onSuccess(result)
                    }, onError: { error in onError(error) })
                }, onError: { errorAccessToken in onError(errorAccessToken) })
    }

    public func login(
            onSuccess: @escaping ([String: AnyObject]) -> (),
            onError: @escaping ([String: AnyObject]) -> ()
    ) {
        PayME.initSDK(onSuccess: { success in
            PayME.loggedIn = true
            if (PayME.accessToken == "") {
                onSuccess(["code": PayME.CompassPoint.NotActivated as AnyObject, "message": "Tài khoản chưa kích hoạt" as AnyObject])
                return
            }
            if (PayME.kycState != "APPROVED") {
                onSuccess(["code": PayME.CompassPoint.NotKYC as AnyObject, "message": "Tài khoản chưa định danh" as AnyObject])
                return
            }
            if (PayME.accessToken != "" && PayME.kycState == "APPROVED") {
                onSuccess(["code": PayME.CompassPoint.KYCOK as AnyObject, "message": "Đăng nhập thành công" as AnyObject])
                return
            }
        }, onError: { error in
            PayME.loggedIn = false
            onError(error)
        })
    }

    internal static func logoutAction() {
        PayME.loggedIn = false
        PayME.accessToken = ""
        PayME.handShake = ""
        PayME.kycState = ""
        PayME.dataInit = nil
    }

    public func logout() {
        PayME.logoutAction()
    }

    internal func encryptAES(data: String) -> String {
        let aes = try? AES(key: Array("LkaWasflkjfqr2g3".utf8), blockMode: CBC(iv: [UInt8](repeating: 0, count: 16)), padding: .pkcs5)
        let dataEncrypted = try? aes!.encrypt(Array(data.utf8))
        return dataEncrypted!.toBase64()!
    }

    public func openWallet(
            currentVC: UIViewController, action: Action, amount: Int?, description: String?, extraData: String?, serviceCode: String = "",
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping ([String: AnyObject]) -> ()
    ) {
        if (PayME.loggedIn == false || PayME.dataInit == nil) {
            onError(["code": PayME.ResponseCode.ACCOUNT_NOT_LOGIN as AnyObject, "message": "Vui lòng đăng nhập để tiếp tục" as AnyObject])
            return
        }
        if !(Reachability.isConnectedToNetwork()) {
            onError(["code": PayME.ResponseCode.NETWORK as AnyObject, "message": "Vui lòng kiểm tra lại đường truyền mạng" as AnyObject])
            return
        }

        let webViewController = WebViewController(nibName: "WebView", bundle: nil)
        currentVC.navigationItem.hidesBackButton = true
        currentVC.navigationController?.isNavigationBarHidden = true
        PayME.currentVC = currentVC
        PayME.webviewController = webViewController
        PayME.webviewController?.tabBarController?.tabBar.isHidden = true
        PayME.webviewController?.hidesBottomBarWhenPushed = true

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
                PayME.currentVC?.isModalInPresentation = false
            }
            currentVC.present(navigationController, animated: true, completion: {
            })
        }

        let topSafeArea: CGFloat
        let bottomSafeArea: CGFloat
        if #available(iOS 11.0, *) {
            topSafeArea = PayME.isRecreateNavigationController ? 1 : currentVC.view.safeAreaInsets.top
            bottomSafeArea = currentVC.view.safeAreaInsets.bottom
        } else {
            topSafeArea = PayME.isRecreateNavigationController ? 1 : currentVC.topLayoutGuide.length
            bottomSafeArea = currentVC.bottomLayoutGuide.length
        }

        let message = PayME.dataInit!["message"] as? String
        let accessToken = PayME.dataInit!["accessToken"] as? String
        let succeeded = PayME.dataInit!["succeeded"] as? Bool
        let phone = PayME.dataInit!["phone"] as? String
        let kycID = PayME.dataInit!["kyc"]!["kycId"] as? Int
        let handShake = PayME.dataInit!["handShake"] as? String
        let kycState = PayME.dataInit!["kyc"]!["state"] as? String
        let identifyNumber = PayME.dataInit!["kyc"]!["identifyNumber"] as? String
        let reason = PayME.dataInit!["kyc"]!["reason"] as? String
        let sentAt = PayME.dataInit!["kyc"]!["sentAt"] as? String

        let data =
                """
                {
                  "connectToken":  "\(PayME.connectToken)",
                  "publicKey": "\(PayME.publicKey.replacingOccurrences(of: "\n", with: ""))",
                  "privateKey": "\(PayME.appPrivateKey.replacingOccurrences(of: "\n", with: ""))",
                  "xApi": "\(PayME.appId)",
                  "appToken": "\(PayME.appToken)",
                  "clientId": "\(PayME.clientID)",
                  "configColor":["\(handleColor(input: PayME.configColor))"],
                  "dataInit" : {
                        "message" : "\(checkStringNil(input: message))",
                        "accessToken": "\(checkStringNil(input: accessToken))",
                        "phone": "\(checkStringNil(input: phone))",
                        "succeeded": \(succeeded!),
                        "handShake": "\(checkStringNil(input: handShake))",
                        "kyc" : {
                            "kycId": "\(checkIntNil(input: kycID))",
                            "state": "\(checkStringNil(input: kycState))",
                            "identifyNumber": "\(checkStringNil(input: identifyNumber))",
                            "reason" : "\(checkStringNil(input: reason))",
                            "sentAt" : "\(checkStringNil(input: sentAt))"
                        }
                  },
                  "partner" : {
                       "type":"IOS",
                       "paddingTop":\(topSafeArea),
                       "paddingBottom":\(bottomSafeArea)
                  },
                  "actions":{
                    "type":"\(action)",
                    "serviceCode":"\(serviceCode)",
                    "amount":"\(checkIntNil(input: amount))"
                  },
                    "env": "\(PayME.env.rawValue)",
                    "showLog" : "\(PayME.showLog)"
                }
                """

        let url = urlWebview(env: PayME.env)
        webViewController.urlRequest = url + "\(encryptAES(data: data))"
        print("hihihihih")
        webViewController.setOnSuccessCallback(onSuccess: onSuccess)
        webViewController.setOnErrorCallback(onError: onError)
    }

    public func deposit(currentVC: UIViewController, amount: Int?, description: String?, extraData: String?,
                        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
                        onError: @escaping ([String: AnyObject]) -> ()) {
        if (checkCondition(onError: onError) == true) {
            openWallet(currentVC: currentVC, action: PayME.Action.DEPOSIT, amount: amount, description: nil, extraData: nil, onSuccess: onSuccess, onError: onError)
        }
    }

    public func withdraw(currentVC: UIViewController, amount: Int?, description: String?, extraData: String?,
                         onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
                         onError: @escaping ([String: AnyObject]) -> ()) {
        if (checkCondition(onError: onError) == true) {
            openWallet(currentVC: currentVC, action: PayME.Action.WITHDRAW, amount: amount, description: nil, extraData: nil, onSuccess: onSuccess, onError: onError)
        }
    }

    public func openService(currentVC: UIViewController, amount: Int?, description: String?, extraData: String?, service: ServiceConfig,
                            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
                            onError: @escaping ([String: AnyObject]) -> ()) {
        if (checkCondition(onError: onError) == true) {
            openWallet(
                    currentVC: currentVC, action: PayME.Action.UTILITY, amount: amount, description: nil,
                    extraData: nil, serviceCode: service.code, onSuccess: onSuccess, onError: onError
            )
        }
    }

    internal static func openQRCode(currentVC: UIViewController, onSuccess: @escaping ([String: AnyObject]) -> (), onError: @escaping ([String: AnyObject]) -> ()) {
        if (checkCondition(onError: onError) == true) {
            let qrScan = QRScannerController()
            qrScan.setScanSuccess(onScanSuccess: { response in
                API.readQRContent(qrContent: response, onSuccess: { response in
                    let payment = response["OpenEWallet"]!["Payment"] as! [String: AnyObject]
                    let detect = payment["Detect"] as! [String: AnyObject]
                    let succeeded = detect["succeeded"] as! Bool
                    if (succeeded == true) {
                        if (PayME.accessToken != "" && PayME.kycState == "APPROVED") {
                            PayME.payQR(currentVC: currentVC, storeId: (detect["stordeId"] as? Int) ?? 0, orderId: (detect["orderId"] as? String) ?? "", amount: (detect["amount"] as? Int) ?? 0, note: (detect["note"] as? String) ?? "", extraData: nil, onSuccess: onSuccess, onError: onError)
                        }
                    } else {
                        currentVC.presentPanModal(QRNotFound())
                    }
                }, onError: { error in
                    currentVC.presentPanModal(QRNotFound())
                })
            })
            qrScan.setScanFail(onScanFail: { error in
                onError(["message": error as AnyObject])
                currentVC.presentPanModal(QRNotFound())
            })
            currentVC.navigationItem.hidesBackButton = true
            currentVC.navigationController?.isNavigationBarHidden = true
            currentVC.navigationController?.pushViewController(qrScan, animated: false)
        }
    }

    public func pay(
            currentVC: UIViewController, storeId: Int, orderId: String, amount: Int,
            note: String?, paymentMethodID: Int?, extraData: String?, isShowResultUI: Bool = true,
            onSuccess: @escaping ([String: AnyObject]) -> (), onError: @escaping ([String: AnyObject]) -> ()) {
        if (checkCondition(onError: onError) == true) {
            PayME.payAction(
                    currentVC: currentVC, storeId: storeId, orderId: orderId, amount: amount, note: note,
                    paymentMethodID: paymentMethodID,extraData: extraData, isShowResultUI: isShowResultUI,
                    onSuccess: onSuccess, onError: onError
            )
        }
    }

    public func getListPaymentMethodID(
            onSuccess: @escaping ([Dictionary<String, Any>]) -> (),
            onError: @escaping ([String: AnyObject]) -> ()
    ) {
        API.getTransferMethods(onSuccess: { response in
            let items = (response["Utility"]!["GetPaymentMethod"] as! [String: AnyObject])["methods"] as! [[String: AnyObject]]
            var listPaymentMethodID: [Dictionary<String, Any>] = []
            for item in items {
                let method: [String: Any] = ["title": item["title"] as! String, "methodId": item["methodId"] as! Int]
                listPaymentMethodID.append(method)
            }
            onSuccess(listPaymentMethodID)
        }, onError: { error in onError(error) })
    }

    internal static func payQR(currentVC: UIViewController, storeId: Int, orderId: String, amount: Int, note: String?, extraData: String?, onSuccess: @escaping ([String: AnyObject]) -> (), onError: @escaping ([String: AnyObject]) -> ()) {
        if (checkCondition(onError: onError) == true) {
            PayME.payAction(currentVC: currentVC, storeId: storeId, orderId: orderId, amount: amount, note: note, extraData: extraData, onSuccess: onSuccess, onError: onError)
        }
    }

    internal static func payAction(
            currentVC: UIViewController,
            storeId: Int, orderId: String,
            amount: Int, note: String?,
            paymentMethodID: Int? = nil,
            extraData: String?,
            isShowResultUI: Bool = true,
            onSuccess: @escaping ([String: AnyObject]) -> (),
            onError: @escaping ([String: AnyObject]) -> ()
    ) {
        if (checkCondition(onError: onError) == true) {
            PayME.currentVC = currentVC
            if (amount < Methods.min) {
                onError(["code": PayME.ResponseCode.LIMIT as AnyObject, "message": "Vui lòng thanh toán số tiền lớn hơn \(formatMoney(input: Methods.min))" as AnyObject])
                return
            }
            if (amount > Methods.max) {
                onError(["code": PayME.ResponseCode.LIMIT as AnyObject, "message": "Vui lòng thanh toán số tiền nhỏ hơn \(formatMoney(input: Methods.max))" as AnyObject])
                return
            }
            if (PayME.accessToken != "" && PayME.kycState == "APPROVED") {
                let methods = Methods()
                methods.onSuccess = onSuccess
                methods.onError = onError
                Methods.amount = amount
                Methods.storeId = storeId
                Methods.orderId = orderId
                Methods.note = note ?? ""
                Methods.extraData = extraData ?? ""
                Methods.paymentMethodID = paymentMethodID
                Methods.isShowResultUI = isShowResultUI
                currentVC.presentPanModal(methods)
            }
        }
    }

    public func getWalletInfo(
            onSuccess: @escaping ([String: AnyObject]) -> (),
            onError: @escaping ([String: AnyObject]) -> ()
    ) {
        if (checkCondition(onError: onError) == true) {
            API.getWalletInfo(
                    onSuccess: { walletInfo in onSuccess(walletInfo) },
                    onError: { error in onError(error) }
            )
        }
    }
}

