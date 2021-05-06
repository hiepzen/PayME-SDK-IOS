//
//  PayMEFunction.swift
//  PayMESDK
//
//  Created by Minh Khoa on 5/5/21.
//

import Foundation
import CryptoSwift

class PayMEFunction {
    private var payME: PayME?

    init(_ payME: PayME? = nil) {
        self.payME = payME
    }

    func checkCondition(_ onError: @escaping ([String: AnyObject]) -> ()) -> Bool {
        if (PayME.loggedIn == false || PayME.dataInit == nil) {
            onError(["code": PayME.ResponseCode.ACCOUNT_NOT_LOGIN as AnyObject, "message": "Vui lòng đăng nhập để tiếp tục" as AnyObject])
            return false
        }
        if !(Reachability.isConnectedToNetwork()) {
            onError(["code": PayME.ResponseCode.NETWORK as AnyObject, "message": "Vui lòng kiểm tra lại đường truyền mạng" as AnyObject])
            return false
        }
        if (PayME.accessToken == "") {
            onError(["code": PayME.ResponseCode.ACCOUNT_NOT_ACTIVATED as AnyObject, "message": "Tài khoản chưa kích hoạt" as AnyObject])
            return false
        }
        if (PayME.kycState != "APPROVED") {
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
            API.getWalletInfo(
                    onSuccess: { walletInfo in onSuccess(walletInfo) },
                    onError: { error in onError(error) }
            )
        }
    }

    func openWallet(
            _ currentVC: UIViewController, _ action: PayME.Action, _ amount: Int?, _ description: String?,
            _ extraData: String?, _ serviceCode: String = "", _ payME: PayME,
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
                      "connectToken": "\(PayME.connectToken)",
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
}
