//
//  PayMEFunction.swift
//  PayMESDK
//
//  Created by Minh Khoa on 5/5/21.
//

import Foundation
import CryptoSwift
import RxSwift
import RxCocoa

class PayMEFunction {
    let paymentViewModel = PaymentViewModel()

    private let disposeBag = DisposeBag()
    private var configService = Array<ServiceConfig>()
    private var connectToken = ""
    private var appId = ""
    private var publicKey = ""
    private var privateKey = ""
    private var appToken = ""
    private var loggedIn = false
    private var isShowLog = 0
    private var storeName = ""
    private var kycMode: [String: Bool]? = nil

    var request: API
    var appEnv = ""
    var env: PayME.Env
    var language = PayME.Language.VIETNAM
    var configColor: [String]
    var clientId = ""
    var accessToken = ""
    var isAccountActivated = false
    var handShake = ""
    var kycState = ""
    var dataInit: Dictionary<String, AnyObject>? = nil

    init(
            _ appToken: String, _ publicKey: String, _ connectToken: String, _ privateKey: String,
            _ language: PayME.Language? = PayME.Language.VIETNAM, _ env: PayME.Env, _ configColor: [String],
            _ isShowLog: Int = 0, _ appId: String) {
        self.appToken = appToken
        self.publicKey = publicKey
        self.connectToken = connectToken
        self.privateKey = privateKey
        self.isShowLog = isShowLog
        self.appId = appId
        self.env = env
        self.language = language ?? PayME.Language.VIETNAM
        self.configColor = configColor

        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        request = API(publicKey, privateKey, env, appToken, connectToken, deviceId, appId)
    }

    func checkCondition(_ onError: @escaping (Dictionary<String, AnyObject>) -> Void) -> Bool {
        if loggedIn == false || dataInit == nil {
            onError(["code": PayME.ResponseCode.ACCOUNT_NOT_LOGIN as AnyObject, "message": "Vui lòng đăng nhập để tiếp tục" as AnyObject])
            return false
        }
        if !Reachability.isConnectedToNetwork() {
            onError(["code": PayME.ResponseCode.NETWORK as AnyObject, "message": "Vui lòng kiểm tra lại đường truyền mạng" as AnyObject])
            return false
        }
        if !isAccountActivated {
            onError(["code": PayME.ResponseCode.ACCOUNT_NOT_ACTIVATED as AnyObject, "message": "Tài khoản chưa kích hoạt" as AnyObject])
            return false
        }
        if kycState != "APPROVED" {
            onError(["code": PayME.ResponseCode.ACCOUNT_NOT_KYC as AnyObject, "message": "Tài khoản chưa định danh" as AnyObject])
            return false
        }
        return true
    }

    func checkPayCondition(_ onError: @escaping (Dictionary<String, AnyObject>) -> Void) -> Bool {
        if (loggedIn == false || dataInit == nil) {
            onError(["code": PayME.ResponseCode.ACCOUNT_NOT_LOGIN as AnyObject, "message": "Vui lòng đăng nhập để tiếp tục" as AnyObject])
            return false
        }
        if !(Reachability.isConnectedToNetwork()) {
            onError(["code": PayME.ResponseCode.NETWORK as AnyObject, "message": "Vui lòng kiểm tra lại đường truyền mạng" as AnyObject])
            return false
        }
        return true
    }

    func encryptAES(_ data: String) -> String {
        let aes = try? AES(key: Array("LkaWasflkjfqr2g3".utf8), blockMode: CBC(iv: [UInt8](repeating: 0, count: 16)), padding: .pkcs5)
        let dataEncrypted = try? aes!.encrypt(Array(data.utf8))
        return dataEncrypted!.toBase64()!
    }

    func getWalletInfo(
            _ onSuccess: @escaping ([String: AnyObject]) -> (),
            _ onError: @escaping ([String: AnyObject]) -> ()
    ) {
        if checkCondition(onError) {
            if isAccountActivated && kycState == "APPROVED" {
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
            _ onSuccess: @escaping (Dictionary<String, AnyObject>) -> (), _ onError: @escaping ([String: AnyObject]) -> ()
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
                currentVC.present(navigationController, animated: true)
            }

            let topSafeArea: CGFloat
            let bottomSafeArea: CGFloat
            if #available(iOS 11.0, *) {
                if (currentVC.view.safeAreaInsets.top > 60) {
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

            let data =
                    """
                    {
                      "connectToken": "\(connectToken)",
                      "publicKey": "\(publicKey.replacingOccurrences(of: "\n", with: ""))",
                      "privateKey": "\(privateKey.replacingOccurrences(of: "\n", with: ""))",
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
                      "actions": {
                        "type": "\(action)",
                        "serviceCode": "\(serviceCode)",
                        "amount": "\(checkIntNil(input: amount))",
                        "closeWhenDone": \(closeWhenDone),
                        "description": "\(description ?? "")"
                      },
                      "env": "\(env.rawValue)",
                      "showLog": "\(isShowLog)"
                    }
                    """
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
            _ currentVC: UIViewController, _ storeId: Int, _ orderId: String, _ amount: Int, _ note: String?,
            _ paymentMethodID: Int? = nil, _ extraData: String?, _ isShowResultUI: Bool = true,
            _ onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            _ onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        if checkPayCondition(onError) {
            PayME.currentVC = currentVC
            request.setExtraData(storeId: storeId)
            if (amount < PaymentModalController.minAmount) {
                onError(["code": PayME.ResponseCode.LIMIT as AnyObject, "message": "Vui lòng thanh toán số tiền lớn hơn \(formatMoney(input: PaymentModalController.minAmount))" as AnyObject])
                return
            }
            if (amount > PaymentModalController.maxAmount) {
                onError(["code": PayME.ResponseCode.LIMIT as AnyObject, "message": "Vui lòng thanh toán số tiền nhỏ hơn \(formatMoney(input: PaymentModalController.maxAmount))" as AnyObject])
                return
            }
            let orderTransaction = OrderTransaction(amount: amount, storeId: storeId, storeName: storeName, orderId: orderId, note: note ?? "", extraData: extraData ?? "")
            let paymentModalController = PaymentModalController(
                    payMEFunction: self, orderTransaction: orderTransaction,
                    paymentMethodID: paymentMethodID, isShowResultUI: isShowResultUI,
                    onSuccess: onSuccess, onError: onError
            )
            currentVC.presentPanModal(paymentModalController)
        }
    }

    func getPaymentMethods(
            _ storeId: Int,
            _ onSuccess: @escaping ([Dictionary<String, Any>]) -> (),
            _ onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        request.setExtraData(storeId: storeId)
        request.getTransferMethods(onSuccess: { response in
            let items = (response["Utility"]!["GetPaymentMethod"] as! Dictionary<String, AnyObject>)["methods"] as! [Dictionary<String, AnyObject>]
            onSuccess(items)
        }, onError: { error in
            onError(error)
        })
    }

    func openQRCode(
            currentVC: UIViewController,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> Void,
            onError: @escaping (Dictionary<String, AnyObject>) -> Void
    ) {
        if checkPayCondition(onError) {
            let qrScan = QRScannerController()
            qrScan.setScanSuccess(onScanSuccess: { response in
                self.request.readQRContent(qrContent: response, onSuccess: { response in
                    let payment = response["OpenEWallet"]!["Payment"] as! Dictionary<String, AnyObject>
                    let detect = payment["Detect"] as! Dictionary<String, AnyObject>
                    let succeeded = detect["succeeded"] as! Bool
                    if (succeeded == true) {
                        if (self.accessToken != "" && self.kycState == "APPROVED") {
                            let storeId = (detect["stordeId"] as? Int) ?? 0
                            let orderId = (detect["orderId"] as? String) ?? ""
                            let amount = (detect["amount"] as? Int) ?? 0
                            let note = (detect["note"] as? String) ?? ""
                            self.payAction(currentVC, storeId, orderId, amount, note, nil, nil, true, onSuccess, onError)
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

    private func initAccount(
            _ onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            _ onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        request.initAccount(
                clientID: clientId,
                onSuccess: { responseAccessToken in
                    let result = responseAccessToken["OpenEWallet"]!["Init"] as! Dictionary<String, AnyObject>
                    let accessToken = result["accessToken"] as? String
                    let updateToken = result["updateToken"] as? String
                    let kycState = result["kyc"]!["state"] as? String
                    let appEnv = result["appEnv"] as? String
                    let succeeded = result["succeeded"] as? Bool
                    let storeName = result["storeName"] as? String

                    self.isAccountActivated = succeeded ?? false && accessToken != nil && updateToken == nil
                    self.accessToken = accessToken ?? ""
                    self.appEnv = appEnv ?? ""
                    self.kycState = kycState ?? ""
                    self.dataInit = result
                    self.storeName = storeName ?? ""

                    self.request.setAccessData(kycState == "APPROVED" ? self.accessToken : "", self.accessToken, self.clientId)

                    self.request.getSetting(onSuccess: { success in
                        let configs = success["Setting"]!["configs"] as! [Dictionary<String, AnyObject>]
                        if let configLimitPayment = configs.first(where: { config in
                            let key = (config["key"] as? String) ?? ""
                            return key == "limit.param.amount.payment"
                        }) {

                            PaymentModalController.minAmount = (configLimitPayment["value"]!["min"] as? Int) ?? 10000
                            PaymentModalController.maxAmount = (configLimitPayment["value"]!["max"] as? Int) ?? 100000000
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

                        if let configKYCMode = configs.first(where: { config in
                            let key = (config["key"] as? String) ?? ""
                            return key == "kyc.mode.enable"
                        }) {
                            if let kycMode = configKYCMode["value"] as? [String : Bool] {
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

                        onSuccess(result)
                    }, onError: { error in onError(error) })
                }, onError: { errorAccessToken in onError(errorAccessToken) })
    }

    func KYC(
            _ currentVC: UIViewController,
            _ onSuccess: @escaping () -> (),
            _ onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        if !isAccountActivated {
            onError(["code": PayME.ResponseCode.ACCOUNT_NOT_ACTIVATED as AnyObject, "message": "Tài khoản chưa kích hoạt" as AnyObject])
            return
        }
        if kycState == "APPROVED" {
            onError(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": "Tài khoản đã định danh" as AnyObject])
            return
        }
        if kycState == "PENDING" {
            openWallet(false, currentVC, PayME.Action.OPEN, nil, "", "", "", false, { dictionary in  }, onError)
            return
        }
        if kycMode == nil {
            onError(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": "Không lấy được config KYC, vui lòng thử lại sau" as AnyObject])
            return
        }
        PayME.currentVC = currentVC
        KYCController.reset()
        let kycController = KYCController(payMEFunction: self, flowKYC: kycMode!, onSuccess: onSuccess)
        kycController.kyc()
    }

    private func initSDK(
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        if (clientId != "") {
            initAccount(onSuccess, onError)
        } else {
            request.registerClient(onSuccess: { response in
                let result = response["Client"]!["Register"] as! Dictionary<String, AnyObject>
                let clientId = result["clientId"] as! String
                self.clientId = clientId
                self.initAccount(onSuccess, onError)
            }, onError: { error in onError(error) })
        }
    }

    func login(
            _ onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            _ onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        initSDK(onSuccess: { success in
            self.loggedIn = true
            if !self.isAccountActivated {
                onSuccess(["code": PayME.KYCState.NOT_ACTIVATED as AnyObject, "message": "Tài khoản chưa kích hoạt" as AnyObject])
                return
            }
            if self.kycState != "APPROVED" {
                onSuccess(["code": PayME.KYCState.NOT_KYC as AnyObject, "message": "Tài khoản chưa định danh" as AnyObject])
                return
            }
            if self.accessToken != "" && self.kycState == "APPROVED" {
                onSuccess(["code": PayME.KYCState.KYC_APPROVED as AnyObject, "message": "Đăng nhập thành công" as AnyObject])
                return
            }
        }, onError: { error in
            self.loggedIn = false
            onError(error)
        })
    }

    func getAccountInfo(
            _ onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            _ onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        if (loggedIn == true) {
            if !isAccountActivated {
                onError(["code": PayME.ResponseCode.ACCOUNT_NOT_ACTIVATED as AnyObject, "message": "Tài khoản chưa kích hoạt" as AnyObject])
                return
            }
            request.getAccountInfo(
                    accountPhone: dataInit?["phone"] as Any,
                    onSuccess: { success in onSuccess(success) },
                    onError: { error in onError(error) })

        } else {
            onError(["code": PayME.ResponseCode.ACCOUNT_NOT_LOGIN as AnyObject, "message": "Vui lòng đăng nhập để tiếp tục" as AnyObject])
        }
    }

    func getService(
            _ onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            _ onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        request.getService(onSuccess: { success in onSuccess(success) }, onError: { error in onError(error) })
    }

    func getSupportedServices() -> [ServiceConfig] {
        configService
    }
}
