//
//  PayMEFunction.swift
//  PayMESDK
//
//  Created by Minh Khoa on 5/5/21.
//

import CryptoSwift
import Foundation
import RxCocoa
import RxSwift
import SwiftyJSON

class PayMEFunction {
    let paymentViewModel = PaymentViewModel()
    var paymentModalController: PaymentModalController?

    private let disposeBag = DisposeBag()
    private var configService = [ServiceConfig]()
    private var connectToken = ""
    private var publicKey = ""
    private var privateKey = ""
    private var appToken = ""
    private var loggedIn = false
    private var isShowLog = 0
    private var storeName = ""
    private var storeImage: String = ""
    private var kycMode: [String: Bool]?
    private var webKey = ""
    var showScanModule: Bool = false
    var authenCreditLink: String = ""
    static var language = PayME.Language.VIETNAMESE

    var request: API
    var appEnv = ""
    var appId = ""
    var env: PayME.Env
    var configColor: [String]
    var clientId = ""
    var accessToken = ""
    var isAccountActivated = false
    var handShake = ""
    var kycState = ""
    var dataInit: [String: AnyObject]?

    init(
        _ appToken: String, _ publicKey: String, _ connectToken: String, _ privateKey: String,
        _ language: String? = PayME.Language.VIETNAMESE, _ env: PayME.Env, _ configColor: [String],
        _ isShowLog: Int = 0, _ appId: String
    ) {
        self.appToken = appToken
        self.publicKey = publicKey
        self.connectToken = connectToken
        self.privateKey = privateKey
        self.isShowLog = isShowLog
        self.appId = appId
        self.env = env
        PayMEFunction.language = language ?? PayME.Language.VIETNAMESE
        self.configColor = configColor

        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        request = API(publicKey, privateKey, env, appToken, connectToken, deviceId, appId)
    }

    func checkCondition(_ onError: @escaping ([String: AnyObject]) -> ()) -> Bool {
        if loggedIn == false || dataInit == nil {
            onError(["code": PayME.ResponseCode.ACCOUNT_NOT_LOGIN as AnyObject, "message": "needLogin".localize() as AnyObject])
            return false
        }
        if !NetworkReachability.isConnectedToNetwork() {
            onError(["code": PayME.ResponseCode.NETWORK as AnyObject, "message": "Vui lòng kiểm tra lại đường truyền mạng" as AnyObject])
            return false
        }
        if !isAccountActivated {
            onError(["code": PayME.ResponseCode.ACCOUNT_NOT_ACTIVATED as AnyObject, "message": "notActivated".localize() as AnyObject])
            return false
        }
        if kycState != "APPROVED" {
            onError(["code": PayME.ResponseCode.ACCOUNT_NOT_KYC as AnyObject, "message": "notKYC".localize() as AnyObject])
            return false
        }
        return true
    }

    func checkPayCondition(_ onError: @escaping ([String: AnyObject]) -> ()) -> Bool {
        if loggedIn == false || dataInit == nil {
            onError(["code": PayME.ResponseCode.ACCOUNT_NOT_LOGIN as AnyObject, "message": "needLogin".localize() as AnyObject])
            return false
        }
        if !(NetworkReachability.isConnectedToNetwork()) {
            onError(["code": PayME.ResponseCode.NETWORK as AnyObject, "message": "Vui lòng kiểm tra lại đường truyền mạng" as AnyObject])
            return false
        }
        return true
    }

    func encryptAES(_ data: String) -> String {
        let aes = try? AES(key: Array(webKey.utf8), blockMode: CBC(iv: [UInt8](repeating: 0, count: 16)), padding: .pkcs5)
        let dataEncrypted = try? aes!.encrypt(Array(data.utf8))
        return dataEncrypted!.toBase64()!
    }

    func getWalletInfo(
        _ onSuccess: @escaping ([String: AnyObject]) -> (),
        _ onError: @escaping ([String: AnyObject]) -> ()
    ) {
        if checkCondition(onError) {
            if isAccountActivated, kycState == "APPROVED" {
                request.getWalletInfo(
                    onSuccess: { walletInfo in onSuccess(walletInfo) },
                    onError: { error in onError(error) }
                )
            }
        }
    }

    func openWallet(
        _ isChecked: Bool = false,
        _ currentVC: UIViewController, _ action: PayME.Action, _ amount: Int?, _ description: String?,
        _ extraData: String?, _ serviceCode: String = "", _ closeWhenDone: Bool = false,
        _ onSuccess: @escaping ([String: AnyObject]) -> (), _ onError: @escaping ([String: AnyObject]) -> ()
    ) {
        let condition = isChecked ? checkCondition(onError) : checkPayCondition(onError)
        if condition {
            currentVC.navigationItem.hidesBackButton = true
            currentVC.navigationController?.isNavigationBarHidden = true
            PayME.currentVC = currentVC
            let webViewController = WebViewController(payMEFunction: self, nibName: "WebView", bundle: nil)
            webViewController.tabBarController?.tabBar.isHidden = true
            webViewController.hidesBottomBarWhenPushed = true

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
                currentVC.present(navigationController, animated: true) {
                    PayME.isWebviewOpening = true
                }
            }

            let topSafeArea: CGFloat
            let bottomSafeArea: CGFloat
            if #available(iOS 11.0, *) {
                if currentVC.view.safeAreaInsets.top > 60 {
                    topSafeArea = PayME.isRecreateNavigationController ? 1 : currentVC.view.safeAreaInsets.top - 44
                } else {
                    topSafeArea = PayME.isRecreateNavigationController ? 1 : currentVC.view.safeAreaInsets.top
                }
                bottomSafeArea = currentVC.view.safeAreaInsets.bottom
            } else {
                topSafeArea = PayME.isRecreateNavigationController ? 1 : currentVC.topLayoutGuide.length
                bottomSafeArea = currentVC.bottomLayoutGuide.length
            }

            let message = dataInit!["message"] as? String
            let accessToken = dataInit!["accessToken"] as? String
            let succeeded = dataInit!["succeeded"] as? Bool
            let phone = dataInit!["phone"] as? String
            let kycID = dataInit!["kyc"]!["kycId"] as? Int
            let handShake = dataInit!["handShake"] as? String
            let kycState = dataInit!["kyc"]!["state"] as? String
            let identifyNumber = dataInit!["kyc"]!["identifyNumber"] as? String
            let reason = dataInit!["kyc"]!["reason"] as? String
            let sentAt = dataInit!["kyc"]!["sentAt"] as? String
            let fullnameKyc = dataInit!["fullnameKyc"] as? String

            let data =
                """
                {
                  "connectToken": "\(connectToken)",
                  "publicKey": "\(publicKey.replacingOccurrences(of: "\n", with: ""))",
                  "privateKey": "\(privateKey.replacingOccurrences(of: "\n", with: ""))",
                  "language": "\(PayMEFunction.language)",
                  "xApi": "\(appId)",
                  "appToken": "\(appToken)",
                  "clientId": "\(clientId)",
                  "configColor":["\(handleColor(input: configColor))"],
                  "dataInit" : {
                        "message" : "\(checkStringNil(input: message))",
                        "accessToken": "\(checkStringNil(input: accessToken))",
                        "phone": "\(checkStringNil(input: phone))",
                        "succeeded": \(succeeded!),
                        "handShake": "\(checkStringNil(input: handShake))",
                        "kyc" : {
                            "kycId": \(checkIntNil(input: kycID)),
                            "state": "\(checkStringNil(input: kycState))",
                            "identifyNumber": "\(checkStringNil(input: identifyNumber))",
                            "reason" : "\(checkStringNil(input: reason))",
                            "sentAt" : "\(checkStringNil(input: sentAt))"
                        },
                        "fullnameKyc": "\(checkStringNil(input: fullnameKyc))"
                  },
                  "partner" : {
                       "type":"IOS",
                       "paddingTop":\(topSafeArea),
                       "paddingBottom":\(bottomSafeArea)
                  },
                  "actions": {
                    "type": "\(action)",
                    "serviceCode": "\(serviceCode)",
                    "amount": \(checkIntNil(input: amount)),
                    "closeWhenDone": \(closeWhenDone),
                    "description": "\(description ?? "")",
                    "extraData": "\(extraData ?? "")"
                  },
                  "env": "\(env.rawValue)",
                  "showLog": "\(isShowLog)"
                }
                """

            print("minh khoa")
            print(data)
            print(urlWebview(env: env) + "\(encryptAES(data))")

            webViewController.setURLRequest(urlWebview(env: env) + "\(encryptAES(data))")
            webViewController.setOnSuccessCallback(onSuccess: onSuccess)
            webViewController.setOnErrorCallback(onError: onError)
        }
    }

    func resetInitState() {
        loggedIn = false
        accessToken = ""
        handShake = ""
        kycState = ""
        dataInit = nil
    }

    func payAction(
        currentVC: UIViewController, storeId: Int?, userName: String?, orderId: String, amount: Int, note: String?,
        payCode: String = "PAYME", extraData: String?, isShowResultUI: Bool = true,
        onSuccess: @escaping ([String: AnyObject]) -> (),
        onError: @escaping ([String: AnyObject]) -> ()
    ) {
        if checkPayCondition(onError) {
            if appEnv.isEqual("SANDBOX"), payCode != PayCode.PAYME.rawValue {
                onError(["code": PayME.ResponseCode.LIMIT as AnyObject, "message": "onlyProduction".localize() as AnyObject])
                return
            }
            PayME.currentVC = currentVC
            request.setExtraData(storeId: storeId)
            if amount < PaymentModalController.minAmount {
                onError(["code": PayME.ResponseCode.LIMIT as AnyObject, "message": "Vui lòng thanh toán số tiền lớn hơn \(formatMoney(input: PaymentModalController.minAmount))" as AnyObject])
                return
            }
            if amount > PaymentModalController.maxAmount {
                onError(["code": PayME.ResponseCode.LIMIT as AnyObject, "message": "Vui lòng thanh toán số tiền nhỏ hơn \(formatMoney(input: PaymentModalController.maxAmount))" as AnyObject])
                return
            }

            var curStoreName: String = storeName
            var curStoreImage: String = storeImage
            var isShowHeader: Bool = false
            request.getMerchantInformation(storeId: storeId, onSuccess: { response in
                let data = JSON(response)
                if data["OpenEWallet"]["GetInfoMerchant"]["succeeded"].boolValue == true {
                    curStoreName = data["OpenEWallet"]["GetInfoMerchant"]["storeName"].string ?? self.storeName
                    curStoreImage = data["OpenEWallet"]["GetInfoMerchant"]["storeImage"].string ?? self.storeImage
                    isShowHeader = data["OpenEWallet"]["GetInfoMerchant"]["isVisibleHeader"].boolValue
                }

                let orderTransaction = OrderTransaction(amount: amount, storeId: storeId, storeName: curStoreName, storeImage: curStoreImage,
                                                        orderId: orderId, note: note ?? "", extraData: extraData ?? "", total: amount, isShowHeader: isShowHeader, userName: userName)
                self.paymentModalController = PaymentModalController(
                    payMEFunction: self, orderTransaction: orderTransaction,
                    payCode: payCode, isShowResultUI: isShowResultUI,
                    onSuccess: onSuccess, onError: onError
                )
                self.paymentModalController?.redirectURLVNPay = ""
                currentVC.presentModal(self.paymentModalController!)
            }, onError: { _ in
                let orderTransaction = OrderTransaction(amount: amount, storeId: storeId, storeName: curStoreName, storeImage: curStoreImage,
                                                        orderId: orderId, note: note ?? "", extraData: extraData ?? "", total: amount, isShowHeader: isShowHeader, userName: userName)
                self.paymentModalController = PaymentModalController(
                    payMEFunction: self, orderTransaction: orderTransaction,
                    payCode: payCode, isShowResultUI: isShowResultUI,
                    onSuccess: onSuccess, onError: onError
                )
                self.paymentModalController?.redirectURLVNPay = ""
                currentVC.presentModal(self.paymentModalController!)
            })
        }
    }

    func getPaymentMethods(
        _ storeId: Int?,
        _ onSuccess: @escaping ([[String: Any]]) -> (),
        _ onError: @escaping ([String: AnyObject]) -> ()
    ) {
        request.setExtraData(storeId: storeId)
        request.getTransferMethods(onSuccess: { response in
            let items = (response["Utility"]!["GetPaymentMethod"] as! [String: AnyObject])["methods"] as! [[String: AnyObject]]
            onSuccess(items)
        }, onError: { error in
            onError(error)
        })
    }

    func getRemainingQuota(_ onSuccess: @escaping (Int) -> (), _ onError: @escaping ([String: AnyObject]) -> ()) {
        request.getTransferMethods(payCode: "", onSuccess: { response in
            guard let quota = (response["Utility"]!["GetPaymentMethod"] as! [String: AnyObject])["remainingQuota"] as? Int else {
                return
            }
            onSuccess(quota)
        }, onError: { error in
            onError(error)
        })
    }

    func openQRCode(
        currentVC: UIViewController,
        payCode: String = "PAYME",
        onSuccess: @escaping ([String: AnyObject]) -> (),
        onError: @escaping ([String: AnyObject]) -> (),
        isStartDirectFromUser: Bool = false
    ) {
        if checkPayCondition(onError) {
            let qrScan = QRScannerController()
            qrScan.setScanSuccess(onScanSuccess: { response in
                if self.loggedIn == false || self.dataInit == nil {
                    onError(["code": PayME.ResponseCode.ACCOUNT_NOT_LOGIN as AnyObject, "message": "needLogin".localize() as AnyObject])
                    return
                }
                self.request.readQRContent(qrContent: response, onSuccess: { response in
                    let payment = response["OpenEWallet"]!["Payment"] as! [String: AnyObject]
                    let detect = payment["DetectV2"] as! [String: AnyObject]
                    let succeeded = detect["succeeded"] as! Bool
                    let message = detect["message"] as? String ?? "hasError".localize()
                    let qrInfo = detect["qrInfo"] as! [String: AnyObject]

                    let typename = qrInfo["__typename"] as! String

                    guard let amountString = qrInfo["amount"] as? String else {
                        return
                    }
                    let amount = Int(amountString) ?? 0

                    let onSuccessPay = isStartDirectFromUser ? { _ in
                    } : onSuccess
                    let onErrorPay = isStartDirectFromUser ? { _ in
                    } : onError
                    let currentViewController = currentVC

                    if succeeded == true {
                        if typename == "DefaultQR" {
                            let storeId = (qrInfo["storeId"] as? Int) ?? 0
                            let orderId = (qrInfo["orderId"] as? String) ?? ""

                            let note = (qrInfo["note"] as? String) ?? ""
                            let userName = (qrInfo["userName"] as? String) ?? ""
                            self.payAction(
                                currentVC: currentViewController, storeId: storeId, userName: userName, orderId: orderId, amount: amount,
                                note: note, payCode: payCode, extraData: nil,
                                isShowResultUI: true, onSuccess: onSuccessPay, onError: onErrorPay
                            )
                        } else if typename == "VietQR" {
                            let swiftCode = (qrInfo["swiftCode"] as? String) ?? ""
                            let fullname = (qrInfo["fullname"] as? String) ?? ""
                            let bankNumber = (qrInfo["bankNumber"] as? String) ?? ""
                            let note = (qrInfo["note"] as? String) ?? ""

                            let extraData: [String: Any] = [
                                "swiftCode": swiftCode,
                                "fullname": fullname,
                                "bankNumber": bankNumber
                            ]

                            if let jsonData = try? JSONSerialization.data(withJSONObject: extraData, options: []),
                               let jsonString = String(data: jsonData, encoding: .utf8)
                            {
                                let formattedExtraData = jsonString.replacingOccurrences(of: "\\", with: "\\\\")
                                    .replacingOccurrences(of: "\"", with: "\\\"")
                                self.openWallet(false, currentVC, PayME.Action.TRANSFER, amount, note, formattedExtraData, "", false, { _ in }, { error in print("lỗi r \(error)") })
                                print(formattedExtraData)
                            } else {
                                print("Không thể chuyển đổi extraData thành chuỗi JSON")
                            }
                        } else {
                            currentVC.presentModal(QRNotFound())
                        }
                    } else {
                        currentVC.presentModal(QRNotFound())
                    }
                }, onError: { _ in
                    currentVC.presentModal(QRNotFound())
                })
            })
            qrScan.setScanFail(onScanFail: { error in
                onError(["message": error as AnyObject])
                currentVC.presentModal(QRNotFound())
            })

            currentVC.navigationItem.hidesBackButton = true
            currentVC.navigationController?.isNavigationBarHidden = true
            PayME.currentVC = currentVC

            navigationAdapter(currentVC: currentVC, navigateVC: qrScan)
        }
    }

    func payQRCode(
        currentVC: UIViewController,
        qr: String, payCode: String = "PAYME",
        isShowResultUI: Bool = true,
        onSuccess: @escaping ([String: AnyObject]) -> (),
        onError: @escaping ([String: AnyObject]) -> ()
    ) {
        if loggedIn == false || dataInit == nil {
            onError(["code": PayME.ResponseCode.ACCOUNT_NOT_LOGIN as AnyObject, "message": "needLogin".localize() as AnyObject])
            return
        }
        request.readQRContent(qrContent: qr, onSuccess: { response in
            let payment = response["OpenEWallet"]!["Payment"] as! [String: AnyObject]
            let detect = payment["DetectV2"] as! [String: AnyObject]
            let succeeded = detect["succeeded"] as! Bool
            let message = detect["message"] as? String ?? "hasError".localize()
            let qrInfo = detect["qrInfo"] as! [String: AnyObject]

            let typename = qrInfo["__typename"] as! String

            guard let amountString = qrInfo["amount"] as? String else {
                return
            }
            let amount = Int(amountString) ?? 0

            if succeeded == true {
                if typename == "DefaultQR" {
                    let storeId = (qrInfo["storeId"] as? Int) ?? 0
                    let orderId = (qrInfo["orderId"] as? String) ?? ""
                    let note = (qrInfo["note"] as? String) ?? ""
                    let userName = (qrInfo["userName"] as? String) ?? ""

                    self.payAction(currentVC: currentVC, storeId: storeId, userName: userName, orderId: orderId, amount: amount, note: note,
                                   payCode: payCode, extraData: nil, isShowResultUI: isShowResultUI,
                                   onSuccess: onSuccess, onError: onError)
                } else if typename == "VietQR" {
                    let swiftCode = (qrInfo["swiftCode"] as? String) ?? ""
                    let fullname = (qrInfo["fullname"] as? String) ?? ""
                    let bankNumber = (qrInfo["bankNumber"] as? String) ?? ""
                    let note = (qrInfo["note"] as? String) ?? ""

                    let extraData: [String: Any] = [
                        "swiftCode": swiftCode,
                        "fullname": fullname,
                        "bankNumber": bankNumber
                    ]
                    if let jsonData = try? JSONSerialization.data(withJSONObject: extraData, options: []),
                       let jsonString = String(data: jsonData, encoding: .utf8)
                    {
                        let formattedExtraData = jsonString.replacingOccurrences(of: "\\", with: "\\\\")
                            .replacingOccurrences(of: "\"", with: "\\\"")
                        self.openWallet(false, currentVC, PayME.Action.TRANSFER, amount, note, formattedExtraData, "", false, { _ in }, { error in print("lỗi r \(error)") })
                        print(formattedExtraData)
                    } else {
                        print("Không thể chuyển đổi extraData thành chuỗi JSON")
                    }
                } else {
                    onError(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": message as AnyObject])
                }
            } else {
                onError(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": message as AnyObject])
            }
        }, onError: { error in
            let message = error["message"] as? String ?? "hasError".localize()
            onError(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": message as AnyObject])
        })
    }

    private func initAccount(
        _ onSuccess: @escaping ([String: AnyObject]) -> (),
        _ onError: @escaping ([String: AnyObject]) -> ()
    ) {
        request.initAccount(
            clientID: clientId,
            onSuccess: { responseAccessToken in
                let result = responseAccessToken["OpenEWallet"]!["Init"] as! [String: AnyObject]
                let accessToken = result["accessToken"] as? String
                let updateToken = result["updateToken"] as? String
                let kycState = result["kyc"]!["state"] as? String
                let appEnv = result["appEnv"] as? String
                let succeeded = result["succeeded"] as? Bool
                let storeName = result["storeName"] as? String
                let storeImage: String? = result["storeImage"] as? String
                let handShake = result["handShake"] as? String
                let phone = result["phone"] as? String

                if !(succeeded ?? false), phone == nil || handShake == nil {
                    if handShake != nil, phone == nil {
                        onError(["code": PayME.ResponseCode.ACCOUNT_ERROR as AnyObject, "message": "pleaseEnterPhoneNumber".localize() as AnyObject])
                    } else {
                        onError(["code": PayME.ResponseCode.ACCOUNT_ERROR as AnyObject, "message": result["message"] as AnyObject])
                    }
                    return
                }

                self.isAccountActivated = succeeded ?? false && accessToken != nil && updateToken == nil
                self.accessToken = accessToken ?? ""
                self.appEnv = appEnv ?? ""
                self.kycState = kycState ?? ""
                self.dataInit = result
                self.storeName = storeName ?? ""
                self.storeImage = storeImage ?? ""

                self.request.setAccessData(self.accessToken, self.accessToken, self.clientId)

                self.request.getSetting(onSuccess: { success in
                    let configs = success["Setting"]!["configs"] as! [[String: AnyObject]]
                    if let configLimitPayment = configs.first(where: { config in
                        let key = (config["key"] as? String) ?? ""
                        return key == "limit.param.amount.payment"
                    }) {
                        PaymentModalController.minAmount = (configLimitPayment["value"]!["min"] as? Int) ?? 1
                        PaymentModalController.maxAmount = (configLimitPayment["value"]!["max"] as? Int) ?? 100000000
                    } else {
                        onError(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": "cantAccessPaymentConfig".localize() as AnyObject])
                    }

                    if let configService = configs.first(where: { config in
                        let key = (config["key"] as? String) ?? ""
                        return key == "service.main.visible"
                    }) {
                        self.configService = [ServiceConfig]()
                        let values: [AnyObject]
                        let valueConfigService = configService["value"]
                        if valueConfigService is String {
                            values = convertStringToDictionary(text: valueConfigService as! String)!["listService"] as! [AnyObject]
                        } else {
                            values = (configService["value"] as AnyObject)["listService"] as! [AnyObject]
                        }
                        for value in values {
                            let enable = value["enable"] as! Bool
                            if enable {
                                self.configService.append(ServiceConfig(value["code"] as! String, value["description"] as! String))
                            }
                        }
                    } else {
                        onError(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": "cantAccessServiceConfig".localize() as AnyObject])
                    }

                    if let configPayMEPay = configs.first(where: { config in
                        let key = (config["key"] as? String) ?? ""
                        return key == "limit.payment.password"
                    }) {
                        PaymentModalController.passwordLimit = configPayMEPay["value"]!["max"] as? Int
                    } else {
                        onError(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": "cantAccessServiceConfig".localize() as AnyObject])
                    }

                    if let configKYCMode = configs.first(where: { config in
                        let key = (config["key"] as? String) ?? ""
                        return key == "kyc.mode.enable"
                    }) {
                        if let kycMode = configKYCMode["value"] as? [String: Bool] {
                            self.kycMode = kycMode
                        } else {
                            self.kycMode = [
                                "identifyImg": true,
                                "faceImg": true,
                                "kycVideo": true
                            ]
                        }
                    } else {
                        onError(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": "Không lấy được config dịch vụ, vui lòng thử lại sau" as AnyObject])
                    }

                    if let configCreditAuthenLink = configs.first(where: { config in
                        let key = (config["key"] as? String) ?? ""
                        return key == "credit.sacom.auth.link"
                    }) {
                        if let authenLink = configCreditAuthenLink["value"] as? String {
                            self.authenCreditLink = authenLink
                        }
                    }

                    if let configWebKey = configs.first(where: { config in
                        let key = (config["key"] as? String) ?? ""
                        return key == "sdk.web.secretKey"
                    }) {
                        self.webKey = configWebKey["value"] as? String ?? ""
                    }

                    if let scanModuleConfig = configs.first(where: { config in
                        let key = (config["key"] as? String) ?? ""
                        return key == "sdk.scanModule.enable"
                    }) {
                        let enableAppIds = (scanModuleConfig["value"] as? [String: [Int]])?["appId"]
                        self.showScanModule = enableAppIds?.first(where: { appId in
                            appId == Int(self.appId) ?? 0
                        }) != nil
                    }

                    onSuccess(result)
                }, onError: { error in onError(error) })
            }, onError: { errorAccessToken in onError(errorAccessToken) }
        )
    }

    func KYC(
        _ currentVC: UIViewController,
        _ onSuccess: @escaping () -> (),
        _ onError: @escaping ([String: AnyObject]) -> ()
    ) {
        if !isAccountActivated {
            onError(["code": PayME.ResponseCode.ACCOUNT_NOT_ACTIVATED as AnyObject, "message": "notActivated".localize() as AnyObject])
            return
        }

        getAccountInfo({ response in
            let data = JSON(response)
            let kycState = data["Account"]["kyc"]["state"].string
            self.kycState = kycState ?? self.kycState

            if self.kycState == "APPROVED" {
                onError(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": "kycApproved".localize() as AnyObject])
                return
            }
            if self.kycState == "PENDING" {
                self.openWallet(false, currentVC, PayME.Action.OPEN, nil, "", "", "", false, { _ in }, onError)
                return
            }
            if self.kycMode == nil {
                onError(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": "Không lấy được config KYC, vui lòng thử lại sau" as AnyObject])
                return
            }

            if data["Account"]["kyc"]["kycId"].boolValue {
                let video = data["Account"]["kyc"]["details"]["video"]["state"].string
                let face = data["Account"]["kyc"]["details"]["face"]["state"].string
                let image = data["Account"]["kyc"]["details"]["image"]["state"].string
                let videoCondition = !(video == "APPROVED" || video == "PENDING")
                let faceCondition = !(face == "APPROVED" || face == "PENDING")
                let imageCondition = !(image == "APPROVED" || image == "PENDING")

                self.kycMode = [
                    "identifyImg": (self.kycMode!["identifyImg"] ?? false) && videoCondition,
                    "faceImg": (self.kycMode!["faceImg"] ?? false) && faceCondition,
                    "kycVideo": (self.kycMode!["kycVideo"] ?? false) && imageCondition
                ]
            }

            PayME.currentVC = currentVC
            KYCController.reset()
            let kycController = KYCController(payMEFunction: self, flowKYC: self.kycMode!, onSuccess: onSuccess)
            kycController.kyc()
        }, { error in
            onError(error)
        })
    }

    private func initSDK(
        onSuccess: @escaping ([String: AnyObject]) -> (),
        onError: @escaping ([String: AnyObject]) -> ()
    ) {
        if clientId != "" {
            initAccount(onSuccess, onError)
        } else {
            request.registerClient(onSuccess: { response in
                let result = response["Client"]!["Register"] as! [String: AnyObject]
                let clientId = result["clientId"] as! String
                self.clientId = clientId
                self.initAccount(onSuccess, onError)
            }, onError: { error in onError(error) })
        }
    }

    func login(
        _ onSuccess: @escaping ([String: AnyObject]) -> (),
        _ onError: @escaping ([String: AnyObject]) -> ()
    ) {
        initSDK(onSuccess: { _ in
            self.loggedIn = true
            if !self.isAccountActivated {
                onSuccess(["code": PayME.KYCState.NOT_ACTIVATED as AnyObject, "message": "notActivated".localize() as AnyObject])
                return
            }
            switch self.kycState {
            case "APPROVED":
                break
            case "REJECTED":
                onSuccess(["code": PayME.KYCState.KYC_REJECTED as AnyObject])
                return
            case "PENDING":
                onSuccess(["code": PayME.KYCState.KYC_REVIEW as AnyObject])
                return
            default:
                onSuccess(["code": PayME.KYCState.NOT_KYC as AnyObject, "message": "notKYC".localize() as AnyObject])
                return
            }
            if self.accessToken != "", self.kycState == "APPROVED" {
                onSuccess(["code": PayME.KYCState.KYC_APPROVED as AnyObject, "message": "loginSuccess".localize() as AnyObject])
                return
            }
        }, onError: { error in
            self.loggedIn = false
            onError(error)
        })
    }

    func getAccountInfo(
        _ onSuccess: @escaping ([String: AnyObject]) -> (),
        _ onError: @escaping ([String: AnyObject]) -> ()
    ) {
        if loggedIn == true {
            if !isAccountActivated {
                onError(["code": PayME.ResponseCode.ACCOUNT_NOT_ACTIVATED as AnyObject, "message": "notActivated".localize() as AnyObject])
                return
            }
            request.getAccountInfo(
                accountPhone: dataInit?["phone"] as Any,
                onSuccess: { success in onSuccess(success) },
                onError: { error in onError(error) }
            )

        } else {
            onError(["code": PayME.ResponseCode.ACCOUNT_NOT_LOGIN as AnyObject, "message": "needLogin".localize() as AnyObject])
        }
    }

    func getService(
        _ onSuccess: @escaping ([String: AnyObject]) -> (),
        _ onError: @escaping ([String: AnyObject]) -> ()
    ) {
        request.getService(onSuccess: { success in onSuccess(success) }, onError: { error in onError(error) })
    }

    func getSupportedServices(
        _ onSuccess: @escaping ([ServiceConfig]) -> (),
        _ onError: @escaping ([String: AnyObject]) -> ()
    ) {
        if loggedIn == false || dataInit == nil {
            onError(["code": PayME.ResponseCode.ACCOUNT_NOT_LOGIN as AnyObject, "message": "needLogin".localize() as AnyObject])
        } else {
            onSuccess(configService)
        }
    }

    func navigationAdapter(currentVC: UIViewController, navigateVC: UIViewController) {
        if currentVC.navigationController != nil {
            PayME.currentVC = currentVC
            PayME.rootVC = currentVC
            currentVC.navigationController?.pushViewController(navigateVC, animated: true)
        } else {
            let navigationController = UINavigationController(rootViewController: navigateVC)
            PayME.currentVC = navigateVC
            PayME.rootVC = currentVC
            PayME.isRecreateNavigationController = true
            if #available(iOS 13.0, *) {
                PayME.currentVC?.isModalInPresentation = false
            }
            currentVC.present(navigationController, animated: true)
        }
    }
}
