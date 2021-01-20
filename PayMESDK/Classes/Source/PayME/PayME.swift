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

public class PayME{
    internal static var appPrivateKey: String = ""
    internal static var appToken: String = ""
    internal static var publicKey: String = ""
    internal static var connectToken : String = ""
    internal static var env : Env!
    internal static var configColor : [String] = [""]
    internal static var description : String = ""
    internal static var amount : Int = 0
    internal static let packageName = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
    internal static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    internal static let deviceID = UIDevice.current.identifierForVendor!.uuidString
    internal static var clientID: String = ""
    internal static var currentVC : UIViewController?
    internal static var rootVC : UIViewController?
    internal static var webviewController: WebViewController?
    internal static var isRecreateNavigationController: Bool = false
    internal static var accessToken : String = ""
    internal static var handShake : String = ""
    internal static var kycState : String = ""
    internal static var appENV: String = ""
    internal static var dataInit : [String:AnyObject]? = nil
    internal static var appId: String = ""

    public enum Action: String {
        case OPEN = "OPEN"
        case DEPOSIT = "DEPOSIT"
        case WITHDRAW = "WITHDRAW"
    }
    public enum Env: String{
        case SANDBOX = "sandbox"
        case PRODUCTION = "production"
        case DEV = "dev"
    }
    
    public init(appToken: String, publicKey: String, connectToken: String, appPrivateKey: String, env: Env, configColor: [String]) {
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
        PayME.connectToken = connectToken;
        PayME.publicKey = publicKey;
        PayME.appPrivateKey = appPrivateKey;
        PayME.env = env;
        PayME.configColor = configColor;
        PayME.accessToken = ""
        PayME.handShake = ""
        PayME.kycState = ""
        PayME.appENV = ""
        PayME.dataInit = nil
        
    }

    
    public static func genConnectToken(userId: String, phone: String) -> String {
        let data : [String: Any] = ["timestamp": (Date().timeIntervalSince1970), "userId" : "\(userId)", "phone" : "\(phone)"]
        let params = try? JSONSerialization.data(withJSONObject: data)
        let aes = try? AES(key: Array("zfQpwE6iHbOeAfgX".utf8), blockMode: CBC(iv: [UInt8](repeating: 0, count: 16)), padding: .pkcs5)
        let dataEncrypted = try? aes!.encrypt(Array(String(data: params!, encoding: .utf8)!.utf8))
        print(dataEncrypted!.toBase64()!)
        return dataEncrypted!.toBase64()!
    }
    
    // cần thay API
    
    public func getAccountInfo(
        onSuccess: @escaping ([String: AnyObject]) -> (),
        onError: @escaping ([String: AnyObject]) -> ()
    ){
        if (PayME.clientID != "") {
            if (PayME.dataInit != nil) {
                let accessToken = PayME.dataInit!["accessToken"] as? String
                let kycState = PayME.dataInit!["kyc"]!["state"] as? String
                let appENV = PayME.dataInit!["appEnv"] as? String
                PayME.accessToken = accessToken ?? ""
                PayME.appENV = appENV ?? ""
                PayME.kycState = kycState ?? ""
                onSuccess(PayME.dataInit!)
            }
            else {
                API.initAccount(clientID: PayME.clientID,
                                     onSuccess: { responseAccessToken in
                                        print(responseAccessToken)
                                        let result = responseAccessToken["OpenEWallet"]!["Init"] as! [String: AnyObject]
                                        let accessToken = result["accessToken"] as? String
                                        let kycState = result["kyc"]!["state"] as? String
                                        let appENV = result["appEnv"] as? String
                                        PayME.accessToken = accessToken ?? ""
                                        PayME.appENV = appENV ?? ""
                                        PayME.kycState = kycState ?? ""
                                        onSuccess(result)
                                     }, onError: { errorAccessToken in
                                        onError(errorAccessToken)
                                     }
                )
            }
        } else {
            API.registerClient(onSuccess: { response in
                let result = response["Client"]!["Register"] as! [String: AnyObject]
                let clientID = result["clientId"] as! String
                PayME.clientID = clientID
                if (PayME.dataInit != nil) {
                    let accessToken = PayME.dataInit!["accessToken"] as? String
                    let kycState = PayME.dataInit!["kyc"]!["state"] as? String
                    let appENV = PayME.dataInit!["appEnv"] as? String
                    PayME.accessToken = accessToken ?? ""
                    PayME.appENV = appENV ?? ""
                    PayME.kycState = kycState ?? ""
                    onSuccess(PayME.dataInit!)
                } else {
                    API.initAccount(clientID: PayME.clientID,
                        onSuccess: { responseAccessToken in
                            let result = responseAccessToken["OpenEWallet"]!["Init"] as! [String: AnyObject]
                            let accessToken = result["accessToken"] as? String
                            let kycState = result["kyc"]!["state"] as? String
                            let appENV = result["appEnv"] as? String
                            PayME.accessToken = accessToken ?? ""
                            PayME.appENV = appENV ?? ""
                            PayME.kycState = kycState ?? ""
                           onSuccess(result)
                        }, onError: { errorAccessToken in
                           onError(errorAccessToken)
                        }
                    )
                }
            }, onError: {error in
                onError(error)
            })
        }
    }
    
    internal static func initSDK(
        onSuccess: @escaping ([String: AnyObject]) -> (),
        onError: @escaping ([String: AnyObject]) -> ()
    ){
        if (PayME.clientID != "") {
            if (PayME.dataInit != nil) {
                let accessToken = PayME.dataInit!["accessToken"] as? String
                let kycState = PayME.dataInit!["kyc"]!["state"] as? String
                let appENV = PayME.dataInit!["appEnv"] as? String
                PayME.accessToken = accessToken ?? ""
                PayME.appENV = appENV ?? ""
                PayME.kycState = kycState ?? ""
                onSuccess(dataInit!)
            }
            else {
                API.initAccount(clientID: PayME.clientID,
                                     onSuccess: { responseAccessToken in
                                        print(responseAccessToken)
                                        let result = responseAccessToken["OpenEWallet"]!["Init"] as! [String: AnyObject]
                                        let accessToken = result["accessToken"] as? String
                                        let kycState = result["kyc"]!["state"] as? String
                                        let appENV = result["appEnv"] as? String
                                        PayME.accessToken = accessToken ?? ""
                                        PayME.appENV = appENV ?? ""
                                        PayME.kycState = kycState ?? ""
                                        onSuccess(result)
                                     }, onError: { errorAccessToken in
                                        onError(errorAccessToken)
                                     }
                )
            }
        } else {
            API.registerClient(onSuccess: { response in
                let result = response["Client"]!["Register"] as! [String: AnyObject]
                let clientID = result["clientId"] as! String
                PayME.clientID = clientID
                if (PayME.dataInit != nil) {
                    let accessToken = PayME.dataInit!["accessToken"] as? String
                    let kycState = PayME.dataInit!["kyc"]!["state"] as? String
                    let appENV = PayME.dataInit!["appEnv"] as? String
                    PayME.accessToken = accessToken ?? ""
                    PayME.appENV = appENV ?? ""
                    PayME.kycState = kycState ?? ""
                    onSuccess(dataInit!)
                } else {
                    API.initAccount(clientID: PayME.clientID,
                        onSuccess: { responseAccessToken in
                            let result = responseAccessToken["OpenEWallet"]!["Init"] as! [String: AnyObject]
                            let accessToken = result["accessToken"] as? String
                            let kycState = result["kyc"]!["state"] as? String
                            let appENV = result["appEnv"] as? String
                            PayME.accessToken = accessToken ?? ""
                            PayME.appENV = appENV ?? ""
                            PayME.kycState = kycState ?? ""
                           onSuccess(result)
                        }, onError: { errorAccessToken in
                           onError(errorAccessToken)
                        }
                    )
                }
            }, onError: {error in
                onError(error)
            })
        }
    }
    
    public func login(
        onSuccess: @escaping ([String: AnyObject]) -> (),
        onError: @escaping ([String: AnyObject]) -> ()
    ){
        if (PayME.clientID != "") {
                API.initAccount(clientID: PayME.clientID,
                 onSuccess: { responseAccessToken in
                    print(responseAccessToken)
                    let result = responseAccessToken["OpenEWallet"]!["Init"] as! [String: AnyObject]
                    let accessToken = result["accessToken"] as? String
                    let kycState = result["kyc"]!["state"] as? String
                    let appENV = result["appEnv"] as? String
                    PayME.accessToken = accessToken ?? ""
                    PayME.appENV = appENV ?? ""
                    PayME.kycState = kycState ?? ""
                    onSuccess(result)
                 }, onError: { errorAccessToken in
                    onError(errorAccessToken)
                 }
            )
        } else {
            API.registerClient(onSuccess: { response in
                let result = response["Client"]!["Register"] as! [String: AnyObject]
                let clientID = result["clientId"] as! String
                PayME.clientID = clientID
                API.initAccount(clientID: PayME.clientID,
                    onSuccess: { responseAccessToken in
                        let result = responseAccessToken["OpenEWallet"]!["Init"] as! [String: AnyObject]
                        let accessToken = result["accessToken"] as? String
                        let kycState = result["kyc"]!["state"] as? String
                        let appENV = result["appEnv"] as? String
                        PayME.accessToken = accessToken ?? ""
                        PayME.appENV = appENV ?? ""
                        PayME.kycState = kycState ?? ""
                       onSuccess(result)
                    }, onError: { errorAccessToken in
                       onError(errorAccessToken)
                    }
                )
                
            }, onError: {error in
                onError(error)
            })
        }
    }
    
    internal func encryptAES(data: String) -> String {
        let aes = try? AES(key: Array("LkaWasflkjfqr2g3".utf8), blockMode: CBC(iv: [UInt8](repeating: 0, count: 16)), padding: .pkcs5)
        let dataEncrypted = try? aes!.encrypt(Array(data.utf8))
        return dataEncrypted!.toBase64()!
    }
    
    public func openWallet(currentVC : UIViewController, action : Action, amount: Int?, description: String?, extraData: String?,
                           onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
                           onError: @escaping ([String:AnyObject]) -> ()
    )-> () {
        currentVC.navigationItem.hidesBackButton = true
        currentVC.navigationController?.isNavigationBarHidden = true
        PayME.currentVC = currentVC
        let topSafeArea: CGFloat
        let bottomSafeArea: CGFloat
        if #available(iOS 11.0, *) {
            topSafeArea = currentVC.view.safeAreaInsets.top
            bottomSafeArea = currentVC.view.safeAreaInsets.bottom
        } else {
            topSafeArea = currentVC.topLayoutGuide.length
            bottomSafeArea = currentVC.bottomLayoutGuide.length
        }
        if !(Reachability.isConnectedToNetwork()){
            onError(["code" : 500 as AnyObject, "message" : "Vui lòng kiểm tra lại đường truyền mạng" as AnyObject])
            return
        }
        PayME.initSDK(onSuccess: {success in
            let message = success["message"] as? String
            let accessToken = success["accessToken"] as? String
            let succeeded = success["succeeded"] as? Bool
            let phone = success["phone"] as? String
            let kycID = success["kyc"]!["kycID"] as? Int
            let handShake = success["handShake"] as? String
            let isExistInMainWallet = success["isExistInMainWallet"] as? Bool
            let kycState = success["kyc"]!["kycState"] as? String
            let identifyNumber = success["kyc"]!["identifyNumber"] as? String
            let reason = success["kyc"]!["reason"] as? String
            let sentAt = success["kyc"]!["sentAt"] as? String
            
            let data =
            """
            {
              "connectToken":  "\(PayME.connectToken)",
              "publicKey": "\(PayME.publicKey.replacingOccurrences(of: "\n", with: ""))",
              "privateKey": "\(PayME.appPrivateKey.replacingOccurrences(of: "\n", with: ""))",
              "xApi": "\(PayME.appId)",
              "appToken": "\(PayME.appToken)",
              "clientId": "\(PayME.clientID)",
              "configColor":["\(handleColor(input:PayME.configColor))"],
              "dataInit" : {
                    "message" : "\(checkStringNil(input: message))",
                    "accessToken": "\(checkStringNil(input: accessToken))",
                    "phone": "\(checkStringNil(input: phone))",
                    "succeeded": \(succeeded!),
                    "isExistInMainWallet": \(isExistInMainWallet!),
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
                "amount":"\(checkIntNil(input: amount))"
              },
                "env": "\(PayME.env.rawValue)",
                "showLog" : "1"
            }
            """
            let webViewController = WebViewController(nibName: "WebView", bundle: nil)
            let url = urlWebview(env: PayME.env)

            PayME.webviewController = webViewController

            webViewController.urlRequest = url + "\(self.encryptAES(data: data))"
            webViewController.setOnSuccessCallback(onSuccess: onSuccess)
            webViewController.setOnErrorCallback(onError: onError)

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
                    PayME.currentVC?.isModalInPresentation = true
                }
                currentVC.present(navigationController, animated: true, completion: {
                })
            }
        }, onError: {error in
            onError(error)
        })
    }

    public func abc() {
        var dictionary = ["kycIdentifyImg": false, "kycFace": true, "kycVideo": true]
        var kycController = KYCController(flowKYC: dictionary)
        kycController.kyc()
    }
    
    public func deposit(currentVC : UIViewController, amount: Int?, description: String?, extraData: String?,
                        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
                        onError: @escaping ([String : AnyObject]) -> ()) {
        // currentVC.presentPanModal(Test())
        //PayME.currentVC = currentVC
        //currentVC.present(PopupKYC(active: 0), animated: true)
        //abc()
        openWallet(currentVC: currentVC, action: PayME.Action.DEPOSIT, amount: amount, description: nil, extraData: nil, onSuccess: onSuccess, onError: onError)
    }
    
    public func withdraw(currentVC : UIViewController, amount: Int?, description: String?, extraData: String?,
                         onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
                         onError: @escaping ([String : AnyObject]) -> ()) {
        openWallet(currentVC: currentVC, action: PayME.Action.WITHDRAW, amount: amount, description: nil, extraData: nil, onSuccess: onSuccess, onError: onError)
    }
    
    public func showModal(currentVC : UIViewController){
        PayME.currentVC = currentVC
        currentVC.presentPanModal(Methods())
    }
    
    public static func openQRCode(currentVC : UIViewController, onSuccess: @escaping ([String:AnyObject]) -> (), onError: @escaping ([String:AnyObject]) -> ()) {
        let qrScan = QRScannerController()
        qrScan.setScanSuccess(onScanSuccess: { response in
            print(response)
            currentVC.showSpinner(onView: PayME.currentVC!.view)
            API.readQRContent(qrContent: response, onSuccess: { response in
                let payment = response["OpenEWallet"]!["Payment"] as! [String:AnyObject]
                let detect = payment["Detect"] as! [String:AnyObject]
                let succeeded = detect["succeeded"] as! Bool
                if (succeeded == true) {
                    currentVC.removeSpinner()
                    if (PayME.accessToken != "" && PayME.kycState == "APPROVED") {
                        PayME.payQR(currentVC: currentVC, storeId: (detect["stordeId"] as? Int) ?? 0, orderId: (detect["orderId"] as? String) ?? "", amount: (detect["amount"] as? Int) ?? 0, note: (detect["note"] as? String) ?? "", extraData: nil, onSuccess: onSuccess, onError: onError)
                    } else {
                        PayME.initSDK(onSuccess: { success in
                            let accessToken = success["accessToken"] as? String
                            let kycState = success["kyc"]!["state"] as? String
                            let appENV = success["appEnv"] as? String
                            PayME.accessToken = accessToken ?? ""
                            PayME.kycState = kycState ?? ""
                            PayME.appENV = appENV ?? ""
                            if (PayME.accessToken != "" && PayME.kycState == "APPROVED") {
                                PayME.payQR(currentVC: currentVC, storeId: (detect["stordeId"] as? Int) ?? 0, orderId: (detect["orderId"] as? String) ?? "", amount: (detect["amount"] as? Int) ?? 0, note: (detect["note"] as? String) ?? "", extraData: nil, onSuccess: onSuccess, onError: onError)
                            } else {
                                onError(["message" : "Vui lòng mở webview để kích hoạt hoặc định danh tài khoản" as AnyObject])
                            }
                        }, onError: { error in
                            onError(error)
                        })
                    }
                } else {
                    currentVC.removeSpinner()
                    currentVC.presentPanModal(QRNotFound())
                }
            }, onError: { error in
                currentVC.removeSpinner()
                currentVC.presentPanModal(QRNotFound())
            })
        })
        qrScan.setScanFail(onScanFail: { error in
            onError(["message": error as AnyObject])
            currentVC.removeSpinner()
            currentVC.presentPanModal(QRNotFound())
        })
        currentVC.navigationItem.hidesBackButton = true
        currentVC.navigationController?.isNavigationBarHidden = true
        currentVC.navigationController?.pushViewController(qrScan, animated: false)
    }
    
    public static func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
    public func pay(currentVC : UIViewController,storeId: Int, orderId: String, amount: Int, note: String?, extraData: String?, onSuccess: @escaping ([String:AnyObject])->(), onError: @escaping ([String:AnyObject])->()) {
        if (Methods.min == 0 && Methods.max == 0) {
            API.getSetting(onSuccess: { success in
                let configs = success["Setting"]!["configs"] as! [[String:AnyObject]]
                var flag = false
                for tempConfig in configs {
                    var key = (tempConfig["key"] as? String) ?? ""
                    if (key == "limit.param.amount.payment")
                    {
                        flag = true
                        let min = (tempConfig["value"]!["min"] as? Int) ?? 10000
                        let max = (tempConfig["value"]!["max"] as? Int) ?? 100000000
                        Methods.min = min
                        Methods.max = max
                        PayME.payAction(currentVC: currentVC, storeId: storeId, orderId: orderId, amount: amount, note: note, extraData: extraData, onSuccess: onSuccess, onError: onError)
                        break
                    }
                }
                if (flag == false) {
                    onError(["message" : "Không lấy được config thanh toán, vui lòng thử lại sau" as AnyObject])
                }
            }, onError: {error in
                onError(error)
            })
        } else {
            PayME.payAction(currentVC: currentVC, storeId: storeId, orderId: orderId, amount: amount, note: note, extraData: extraData, onSuccess: onSuccess, onError: onError)
        }
    }
    
    public static func payQR(currentVC : UIViewController,storeId: Int, orderId: String, amount: Int, note: String?, extraData: String?, onSuccess: @escaping ([String:AnyObject])->(), onError: @escaping ([String:AnyObject])->()) {
        if (Methods.min == 0 && Methods.max == 0) {
            API.getSetting(onSuccess: { success in
                let configs = success["Setting"]!["configs"] as! [[String:AnyObject]]
                var flag = false
                for tempConfig in configs {
                    var key = (tempConfig["key"] as? String) ?? ""
                    if (key == "limit.param.amount.payment")
                    {
                        flag = true
                        let min = (tempConfig["value"]!["min"] as? Int) ?? 10000
                        let max = (tempConfig["value"]!["max"] as? Int) ?? 100000000
                        Methods.min = min
                        Methods.max = max
                        PayME.payAction(currentVC: currentVC, storeId: storeId, orderId: orderId, amount: amount, note: note, extraData: extraData, onSuccess: onSuccess, onError: onError)
                        break
                    }
                }
                if (flag == false) {
                    onError(["message" : "Không lấy được config thanh toán, vui lòng thử lại sau" as AnyObject])
                }
            }, onError: {error in
                onError(error)
            })
        } else {
            PayME.payAction(currentVC: currentVC, storeId: storeId, orderId: orderId, amount: amount, note: note, extraData: extraData, onSuccess: onSuccess, onError: onError)
        }
    }
    
    internal static func payAction(currentVC : UIViewController,storeId: Int, orderId: String, amount: Int, note: String?, extraData: String?, onSuccess: @escaping ([String:AnyObject])->(), onError: @escaping ([String:AnyObject])->()) {
        if (amount < Methods.min) {
            onError(["message" : "Vui lòng thanh toán số tiền lớn hơn \(formatMoney(input: Methods.min))" as AnyObject])
            return
        }
        if (amount > Methods.max) {
            onError(["message" : "Vui lòng thanh toán số tiền lớn hơn \(formatMoney(input: Methods.max))" as AnyObject])
            return
        }
        if (PayME.accessToken != "" && PayME.kycState == "APPROVED") {
            PayME.currentVC = currentVC
            let methods = Methods()
            methods.onSuccess = onSuccess
            methods.onError = onError
            Methods.amount = amount
            Methods.storeId = storeId
            Methods.orderId = orderId
            Methods.note = note ?? ""
            Methods.extraData = extraData ?? ""
            methods.appENV = PayME.appENV
            PayME.currentVC!.presentPanModal(methods)
        } else {
            PayME.initSDK(onSuccess: { success in
                let accessToken = success["accessToken"] as? String
                let kycState = success["kyc"]!["state"] as? String
                let appENV = success["appEnv"] as? String
                PayME.accessToken = accessToken ?? ""
                PayME.kycState = kycState ?? ""
                PayME.appENV = appENV ?? ""
                if (PayME.accessToken != "" && PayME.kycState == "APPROVED") {
                    PayME.currentVC = currentVC
                    let methods = Methods()
                    methods.onSuccess = onSuccess
                    methods.onError = onError
                    Methods.amount = amount
                    Methods.storeId = storeId
                    Methods.orderId = orderId
                    methods.appENV = PayME.appENV
                    Methods.note = note ?? ""
                    Methods.extraData = extraData ?? ""
                    PayME.currentVC!.presentPanModal(methods)
                } else {
                    onError(["message" : "Vui lòng mở webview để kích hoạt hoặc định danh tài khoản" as AnyObject])
                }
            }, onError: { error in
                onError(error)
            })
        }
    }
    
    public static func getWalletInfo(
        onSuccess: @escaping ([String: AnyObject]) -> (),
        onError: @escaping ([String: AnyObject]) -> ()
    ) {
        if (PayME.accessToken != "" && PayME.kycState == "APPROVED") {
            API.getWalletInfo(onSuccess: { walletInfo in
                onSuccess(walletInfo)
            }, onError: { error in
                onError(error)
            })
        } else {
            PayME.initSDK(onSuccess: { success in
                let accessToken = success["accessToken"] as? String
                let kycState = success["kyc"]!["state"] as? String
                PayME.accessToken = accessToken ?? ""
                PayME.kycState = kycState ?? ""
                if (PayME.accessToken != "" && PayME.kycState == "APPROVED") {
                    API.getWalletInfo(onSuccess: { walletInfo in
                        onSuccess(walletInfo)
                    }, onError: { error in
                        onError(error)
                    })
                } else {
                    onError(["message" : "Vui lòng mở webview để kích hoạt hoặc định danh tài khoản" as AnyObject])
                }
            }, onError: {error in
                onError(error)
            })
        }
    }
}

