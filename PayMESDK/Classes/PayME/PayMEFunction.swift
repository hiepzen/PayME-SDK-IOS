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
    let resultViewModel = ResultViewModel()

    private var payME: PayME?
    private let disposeBag = DisposeBag()
    private var request: API? = nil
    private var configService = Array<ServiceConfig>()
    private var connectToken: String = ""
    private var appId: String = ""
    private var publicKey: String = ""
    private var privateKey: String = ""
    private var appToken: String = ""

    var clientId: String = ""
    var accessToken: String = ""
    var handShake: String = ""
    var kycState: String = ""
    var dataInit: Dictionary<String, AnyObject>? = nil

    init(_ payME: PayME? = nil) {
        self.payME = payME
    }

    init() {}

    func initRequest(_ publicKey: String, _ privateKey: String, _ env: PayME.Env, _ appId: String,
                     _ appToken: String, _ connectToken: String, _ deviceId: String) {
        self.connectToken = connectToken
        self.appToken = appToken
        self.appId = appId
        self.publicKey = publicKey
        self.privateKey = privateKey
        request = API(publicKey, privateKey, env, appToken, connectToken, deviceId, appId)
    }

    func checkCondition(_ onError: @escaping (Dictionary<String, AnyObject>) -> Void) -> Bool {
        if (PayME.loggedIn == false || dataInit == nil) {
            onError(["code": PayME.ResponseCode.ACCOUNT_NOT_LOGIN as AnyObject, "message": "Vui lòng đăng nhập để tiếp tục" as AnyObject])
            return false
        }
        if !(Reachability.isConnectedToNetwork()) {
            onError(["code": PayME.ResponseCode.NETWORK as AnyObject, "message": "Vui lòng kiểm tra lại đường truyền mạng" as AnyObject])
            return false
        }
        if (accessToken == "") {
            onError(["code": PayME.ResponseCode.ACCOUNT_NOT_ACTIVATED as AnyObject, "message": "Tài khoản chưa kích hoạt" as AnyObject])
            return false
        }
        if (kycState != "APPROVED") {
            onError(["code": PayME.ResponseCode.ACCOUNT_NOT_KYC as AnyObject, "message": "Tài khoản chưa định danh" as AnyObject])
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
            request?.getWalletInfo(
                    onSuccess: { walletInfo in onSuccess(walletInfo) },
                    onError: { error in onError(error) }
            )
        }
    }

    func openWallet(
            _ currentVC: UIViewController, _ action: PayME.Action, _ amount: Int?, _ description: String?,
            _ extraData: String?, _ serviceCode: String = "",
            _ onSuccess: @escaping (Dictionary<String, AnyObject>) -> (), _ onError: @escaping ([String: AnyObject]) -> ()
    ) {
        if checkCondition(onError) {
            currentVC.navigationItem.hidesBackButton = true
            currentVC.navigationController?.isNavigationBarHidden = true
            PayME.currentVC = currentVC
            let webViewController = WebViewController(payME: payME, nibName: "WebView", bundle: nil)
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
                topSafeArea = PayME.isRecreateNavigationController ? 1 : currentVC.view.safeAreaInsets.top
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
                      "actions": {
                        "type": "\(action)",
                        "serviceCode": "\(serviceCode)",
                        "amount": "\(checkIntNil(input: amount))"
                      },
                      "env": "\(PayME.env.rawValue)",
                      "showLog": "\(PayME.showLog)"
                    }
                    """

            webViewController.setURLRequest(urlWebview(env: PayME.env) + "\(encryptAES(data))")
            webViewController.setOnSuccessCallback(onSuccess: onSuccess)
            webViewController.setOnErrorCallback(onError: onError)
        }
    }

    func payAction(
            _ currentVC: UIViewController, _ storeId: Int, _ orderId: String, _ amount: Int, _ note: String?,
            _ paymentMethodID: Int? = nil, _ extraData: String?, _ isShowResultUI: Bool = true,
            _ onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            _ onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        if checkCondition(onError) {
            PayME.currentVC = currentVC
            if (amount < PaymentModalController.min) {
                onError(["code": PayME.ResponseCode.LIMIT as AnyObject, "message": "Vui lòng thanh toán số tiền lớn hơn \(formatMoney(input: PaymentModalController.min))" as AnyObject])
                return
            }
            if (amount > PaymentModalController.max) {
                onError(["code": PayME.ResponseCode.LIMIT as AnyObject, "message": "Vui lòng thanh toán số tiền nhỏ hơn \(formatMoney(input: PaymentModalController.max))" as AnyObject])
                return
            }
            if (accessToken != "" && kycState == "APPROVED") {
                PaymentModalController.amount = amount
                PaymentModalController.storeId = storeId
                PaymentModalController.orderId = orderId
                PaymentModalController.note = note ?? ""
                PaymentModalController.extraData = extraData ?? ""
                PaymentModalController.paymentMethodID = paymentMethodID
                PaymentModalController.isShowResultUI = isShowResultUI
                let paymentModalController = PaymentModalController()

                resultViewModel
                        .resultSubject
                        .observe(on: MainScheduler.instance)
                        .bind(to: paymentModalController.resultSubject)
                        .disposed(by: disposeBag)

                paymentModalController.onSuccess = onSuccess
                paymentModalController.onError = onError
                currentVC.presentPanModal(paymentModalController)
            }
        }
    }

    func getListPaymentMethodID(
            _ onSuccess: @escaping ([Dictionary<String, Any>]) -> (),
            _ onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        request?.getTransferMethods(onSuccess: { response in
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
        if checkCondition(onError) {
            let qrScan = QRScannerController()
            qrScan.setScanSuccess(onScanSuccess: { response in
                self.request?.readQRContent(qrContent: response, onSuccess: { response in
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
        request?.initAccount(
                clientID: clientId,
                onSuccess: { responseAccessToken in
                    let result = responseAccessToken["OpenEWallet"]!["Init"] as! Dictionary<String, AnyObject>
                    let accessToken = result["accessToken"] as? String
                    let kycState = result["kyc"]!["state"] as? String
                    let appENV = result["appEnv"] as? String

                    self.accessToken = accessToken ?? ""
                    PayME.appENV = appENV ?? ""
                    self.kycState = kycState ?? ""
                    self.dataInit = result

                    self.request?.setAccessData(accessToken ?? "", self.clientId)

                    self.request?.getSetting(onSuccess: { success in
                        let configs = success["Setting"]!["configs"] as! [Dictionary<String, AnyObject>]
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

    private func initSDK(
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        if (clientId != "") {
            initAccount(onSuccess, onError)
        } else {
            request?.registerClient(onSuccess: { response in
                let result = response["Client"]!["Register"] as! Dictionary<String, AnyObject>
                let clientId = result["clientId"] as! String
                self.clientId = clientId
                self.initAccount(onSuccess, onError)
            }, onError: { error in onError(error)})
        }
    }

    func login(
            _ onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            _ onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        initSDK(onSuccess: { success in
            PayME.loggedIn = true
            if (self.accessToken == "") {
                onSuccess(["code": PayME.KYCState.NOT_ACTIVATED as AnyObject, "message": "Tài khoản chưa kích hoạt" as AnyObject])
                return
            }
            if (self.kycState != "APPROVED") {
                onSuccess(["code": PayME.KYCState.NOT_KYC as AnyObject, "message": "Tài khoản chưa định danh" as AnyObject])
                return
            }
            if (self.accessToken != "" && self.kycState == "APPROVED") {
                onSuccess(["code": PayME.KYCState.KYC_APPROVED as AnyObject, "message": "Đăng nhập thành công" as AnyObject])
                return
            }
        }, onError: { error in
            PayME.loggedIn = false
            onError(error)
        })
    }

    func getAccountInfo(
            _ onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            _ onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        if (PayME.loggedIn == true) {
            request?.getAccountInfo(
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
        request?.getService(onSuccess: { success in onSuccess(success) }, onError: { error in onError(error) })
    }

    func getSupportedServices() -> [ServiceConfig] {
        configService
    }
}
