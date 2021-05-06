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
import RxSwift
import RxCocoa

public class PayME {
    static var appPrivateKey: String = ""
    static var appToken: String = ""
    static var publicKey: String = ""
    static var connectToken: String = ""
    static var env: Env!
    static var configColor: [String] = [""]
    static var description: String = ""
    static var amount: Int = 0
    static let packageName = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    static let deviceID = UIDevice.current.identifierForVendor!.uuidString
    static var clientID: String = ""
    static var currentVC: UIViewController?
    static var rootVC: UIViewController?
    static var isRecreateNavigationController: Bool = false
    static var accessToken: String = ""
    static var handShake: String = ""
    static var kycState: String = ""
    static var appENV: String = ""
    static var dataInit: [String: AnyObject]? = nil
    static var appId: String = ""
    static var showLog: Int = 0
    static var loggedIn: Bool = false
    static var language: Language = PayME.Language.VIETNAM

    var configService = Array<ServiceConfig>()
    let resultViewModel = ResultViewModel()
    lazy var payMEFunction = PayMEFunction(self)
    let disposeBag = DisposeBag()

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
            API.getAccountInfo(
                    accountPhone: PayME.dataInit?["phone"] as Any,
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
        configService
    }

    func initSDK(
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
                self.initAccount(onSuccess, onError)
            }, onError: { error in onError(error) })
        }
    }

    private func initAccount(
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

                            PaymentModalController.min = (configLimitPayment["value"]!["min"] as? Int) ?? 10000
                            PaymentModalController.max = (configLimitPayment["value"]!["max"] as? Int) ?? 100000000
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
        initSDK(onSuccess: { success in
            PayME.loggedIn = true
            if (PayME.accessToken == "") {
                onSuccess(["code": PayME.KYCState.NOT_ACTIVATED as AnyObject, "message": "Tài khoản chưa kích hoạt" as AnyObject])
                return
            }
            if (PayME.kycState != "APPROVED") {
                onSuccess(["code": PayME.KYCState.NOT_KYC as AnyObject, "message": "Tài khoản chưa định danh" as AnyObject])
                return
            }
            if (PayME.accessToken != "" && PayME.kycState == "APPROVED") {
                onSuccess(["code": PayME.KYCState.KYC_APPROVED as AnyObject, "message": "Đăng nhập thành công" as AnyObject])
                return
            }
        }, onError: { error in
            PayME.loggedIn = false
            onError(error)
        })
    }

    static func logoutAction() {
        PayME.loggedIn = false
        PayME.accessToken = ""
        PayME.handShake = ""
        PayME.kycState = ""
        PayME.dataInit = nil
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
        payMEFunction.openWallet(currentVC, PayME.Action.DEPOSIT, amount, nil, nil, "", self, onSuccess, onError)
    }

    public func withdraw(
            currentVC: UIViewController, amount: Int?, description: String?, extraData: String?,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> Void,
            onError: @escaping (Dictionary<String, AnyObject>) -> Void
    ) {
        payMEFunction.openWallet(currentVC, PayME.Action.WITHDRAW, amount, nil, nil, "", self, onSuccess, onError)
    }

    public func openService(
            currentVC: UIViewController, amount: Int?, description: String?, extraData: String?, service: ServiceConfig,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> Void,
            onError: @escaping (Dictionary<String, AnyObject>) -> Void
    ) {
        payMEFunction.openWallet(currentVC, PayME.Action.UTILITY, amount, nil, nil, service.code, self, onSuccess, onError)
    }

    public func openWallet(
            currentVC: UIViewController, action: Action, amount: Int?, description: String?, extraData: String?, serviceCode: String = "",
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> Void,
            onError: @escaping (Dictionary<String, AnyObject>) -> Void
    ) {
        payMEFunction.openWallet(currentVC, action, amount, description, extraData, serviceCode, self, onSuccess, onError)
    }

    func openQRCode(
            currentVC: UIViewController,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> Void,
            onError: @escaping (Dictionary<String, AnyObject>) -> Void
    ) {
        if (payMEFunction.checkCondition(onError)) {
            let qrScan = QRScannerController()
            qrScan.setScanSuccess(onScanSuccess: { response in
                API.readQRContent(qrContent: response, onSuccess: { [self] response in
                    let payment = response["OpenEWallet"]!["Payment"] as! [String: AnyObject]
                    let detect = payment["Detect"] as! [String: AnyObject]
                    let succeeded = detect["succeeded"] as! Bool
                    if (succeeded == true) {
                        if (PayME.accessToken != "" && PayME.kycState == "APPROVED") {
                            self.payQR(currentVC: currentVC, storeId: (detect["stordeId"] as? Int) ?? 0, orderId: (detect["orderId"] as? String) ?? "", amount: (detect["amount"] as? Int) ?? 0, note: (detect["note"] as? String) ?? "", extraData: nil, onSuccess: onSuccess, onError: onError)
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
        if (payMEFunction.checkCondition(onError)) {
            payAction(
                    currentVC: currentVC, storeId: storeId, orderId: orderId, amount: amount, note: note,
                    paymentMethodID: paymentMethodID, extraData: extraData, isShowResultUI: isShowResultUI,
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
            onSuccess(items)
        }, onError: { error in onError(error) })
    }

    func payQR(
            currentVC: UIViewController, storeId: Int, orderId: String, amount: Int, note: String?, extraData: String?,
            onSuccess: @escaping ([String: AnyObject]) -> (),
            onError: @escaping ([String: AnyObject]) -> ()
    ) {
        if (payMEFunction.checkCondition(onError)) {
            payAction(currentVC: currentVC, storeId: storeId, orderId: orderId, amount: amount, note: note, extraData: extraData, onSuccess: onSuccess, onError: onError)
        }
    }

    func payAction(
            currentVC: UIViewController,
            storeId: Int, orderId: String,
            amount: Int, note: String?,
            paymentMethodID: Int? = nil,
            extraData: String?,
            isShowResultUI: Bool = true,
            onSuccess: @escaping ([String: AnyObject]) -> (),
            onError: @escaping ([String: AnyObject]) -> ()
    ) {
        if (payMEFunction.checkCondition(onError) == true) {
            PayME.currentVC = currentVC
            if (amount < PaymentModalController.min) {
                onError(["code": PayME.ResponseCode.LIMIT as AnyObject, "message": "Vui lòng thanh toán số tiền lớn hơn \(formatMoney(input: PaymentModalController.min))" as AnyObject])
                return
            }
            if (amount > PaymentModalController.max) {
                onError(["code": PayME.ResponseCode.LIMIT as AnyObject, "message": "Vui lòng thanh toán số tiền nhỏ hơn \(formatMoney(input: PaymentModalController.max))" as AnyObject])
                return
            }
            if (PayME.accessToken != "" && PayME.kycState == "APPROVED") {
                PaymentModalController.amount = amount
                PaymentModalController.storeId = storeId
                PaymentModalController.orderId = orderId
                PaymentModalController.note = note ?? ""
                PaymentModalController.extraData = extraData ?? ""
                PaymentModalController.paymentMethodID = paymentMethodID
                PaymentModalController.isShowResultUI = isShowResultUI
                let methods = PaymentModalController()

                resultViewModel
                        .resultSubject
                        .observe(on: MainScheduler.instance)
                        .bind(to: methods.resultSubject)
                        .disposed(by: disposeBag)

                methods.onSuccess = onSuccess
                methods.onError = onError
                currentVC.presentPanModal(methods)
            }
        }
    }
}
