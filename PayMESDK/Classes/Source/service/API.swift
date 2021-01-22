//
//  API.swift
//  PayMESDK
//
//  Created by HuyOpen on 12/31/20.
//

import Foundation
import Alamofire

internal class API {
    
    private static var alamoFireManager: Session = {
     let configuration = URLSessionConfiguration.default
     configuration.timeoutIntervalForRequest = 30
     configuration.timeoutIntervalForResource = 60
     let sessionManger = Session(configuration: configuration, startRequestsImmediately: true)
     return sessionManger

    }()
    
    static var isRoot: Bool {

        guard TARGET_IPHONE_SIMULATOR != 1 else { return false }

        // Check 1 : existence of files that are common for jailbroken devices
        if FileManager.default.fileExists(atPath: "/Applications/Cydia.app")
        || FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib")
        || FileManager.default.fileExists(atPath: "/bin/bash")
        || FileManager.default.fileExists(atPath: "/usr/sbin/sshd")
        || FileManager.default.fileExists(atPath: "/etc/apt")
        || FileManager.default.fileExists(atPath: "/private/var/lib/apt/")
        || UIApplication.shared.canOpenURL(URL(string:"cydia://package/com.example.package")!) {

            return true
        }

        // Check 2 : Reading and writing in system directories (sandbox violation)
        let stringToWrite = "Jailbreak Test"
        do {
            try stringToWrite.write(toFile:"/private/JailbreakTest.txt", atomically:true, encoding:String.Encoding.utf8)
            // Device is jailbroken
            return true
        } catch {
            return false
        }
    }
    static var isEmulator : Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }
    
    internal static func uploadVideoKYC(
        videoURL: URL,
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping ([String:AnyObject]) -> ()
    ){
        print(videoURL)
        let url = urlUpload(env: PayME.env)
        let path = url + "/Upload"
        let headers : HTTPHeaders = ["Content-type": "multipart/form-data",
                                     "Content-Disposition" : "form-data"]
        alamoFireManager.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(videoURL, withName: "files", fileName: "video.mp4", mimeType: "video/mp4")
        }, to: path, method: .post, headers: headers)
        .responseJSON { response in
            let result = response.result
            switch result {
            case .success(let value):
                onSuccess(value as! Dictionary<String, AnyObject>)
                // Do something with value
            case .failure(let error):
                if let underlyingError = error.underlyingError {
                    if let urlError = underlyingError as? URLError {
                        switch urlError.code {
                        case .timedOut:
                            print("Timed out error")
                            onError(["code" : 500 as AnyObject, "message": "Kết nối mạng bị sự cố, vui lòng kiểm tra và thử lại. Xin cảm ơn !" as AnyObject])
                        case .notConnectedToInternet:
                            onError(["code" : 500 as AnyObject, "message": "Kết nối mạng bị sự cố, vui lòng kiểm tra và thử lại. Xin cảm ơn !" as AnyObject])
                        default:
                            onError(["code" : 500 as AnyObject, "message": "Something went wrong" as AnyObject])
                        }
                    }
                }
            }
        }
    }
    
    internal static func uploadImageKYC(
        imageFront: UIImage,
        imageBack: UIImage?,
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping ([String:AnyObject]) -> ()
    ) {
        let url = urlUpload(env: PayME.env)
        let path = url + "/Upload"
        let imageData = imageFront.jpegData(compressionQuality: 1)
        let headers : HTTPHeaders = ["Content-type": "multipart/form-data",
                                     "Content-Disposition" : "form-data"]
        
        
        alamoFireManager.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(imageData!, withName: "files", fileName: "imageFront.png", mimeType: "image/png")
                if (imageBack != nil) {
                    let imageDataBack = imageBack!.jpegData(compressionQuality: 1)
                    multipartFormData.append(imageDataBack!, withName: "files", fileName: "imageBack.png", mimeType: "image/png")
                }
            }, to: path, method: .post, headers: headers)
            .responseJSON { response in
                let result = response.result
                switch result {
                case .success(let value):
                    onSuccess(value as! Dictionary<String, AnyObject>)
                    // Do something with value
                case .failure(let error):
                    if let underlyingError = error.underlyingError {
                        if let urlError = underlyingError as? URLError {
                            switch urlError.code {
                            case .timedOut:
                                print("Timed out error")
                                onError(["code" : 500 as AnyObject, "message": "Kết nối mạng bị sự cố, vui lòng kiểm tra và thử lại. Xin cảm ơn !" as AnyObject])
                            case .notConnectedToInternet:
                                onError(["code" : 500 as AnyObject, "message": "Kết nối mạng bị sự cố, vui lòng kiểm tra và thử lại. Xin cảm ơn !" as AnyObject])
                            default:
                                onError(["code" : 500 as AnyObject, "message": "Something went wrong" as AnyObject])
                            }
                        }
                    }
                }
            }
    }
    
    internal static func getSetting (
        onSuccess: @escaping ([String: AnyObject]) -> (),
        onError: @escaping ([String: AnyObject]) -> ()
    ) {
        let url = urlGraphQL(env: PayME.env)
        let path = "/graphql"
        let sql = """
        query Query($configsTags: String) {
          Setting {
            configs(tags: $configsTags) {
              key
              value
              tags
            }
          }
        }
        """
        let variables : [String: Any] = [:]
        let json: [String: Any] = [
          "query": sql,
          "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        if (PayME.env == PayME.Env.DEV) {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequest(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                  // print("onSuccess \(data)")
                }
            )
        } else {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequestCrypto(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                }
            )
        }
    }


    
    internal static func getWalletInfo(
        onSuccess: @escaping ([String: AnyObject]) -> (),
        onError: @escaping ([String: AnyObject]) -> ()
    ){
        let url = urlGraphQL(env: PayME.env)
        let path = "/graphql"
        let sql = """
        query Query {
          Wallet {
            balance
            cash
            credit
            lockCash
            creditLimit
          }
        }
        """
        let variables : [String: Any] = [:]
        let json: [String: Any] = [
          "query": sql,
          "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        if (PayME.env == PayME.Env.DEV) {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequest(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                  // print("onSuccess \(data)")
                }
            )
        } else {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequestCrypto(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                }
            )
        }
    }
    
    internal static func transferATM(
        storeId: Int,
        orderId: String,
        extraData: String,
        note: String,
        cardNumber: String,
        cardHolder: String,
        issuedAt: String,
        amount: Int,
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        let url = urlGraphQL(env: PayME.env)
        let path = "/graphql"
        let sql =
        """
        mutation GetBankNameMutation($payInput: OpenEWalletPaymentPayInput!) {
          OpenEWallet {
            Payment {
              Pay(input: $payInput) {
                succeeded
                message
                payment {
                  ... on PaymentBankCardResponsed {
                    state
                    message
                    html
                  }
                }
              }
            }
          }
        }
        """
        var payInput : [String : Any] = [
            "clientId": PayME.clientID,
            "storeId": storeId,
            "amount": amount,
            "orderId": orderId,
            "payment": [
                "bankCard" : [
                    "cardNumber": cardNumber,
                    "cardHolder": cardHolder,
                    "issuedAt": issuedAt
                ]
            ]
        ]
        if (note != "") {
            payInput.updateValue(note, forKey: "note")
        }
        if (extraData != "") {
            payInput.updateValue(extraData, forKey: "referExtraData")
        }
        var variables : [String: Any] = [
            "payInput": payInput
        ]
        let json: [String: Any] = [
          "query": sql,
          "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        print(variables)
        if (PayME.env == PayME.Env.DEV) {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequest(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                  // print("onSuccess \(data)")
                }
            )
        } else {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequestCrypto(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                }
            )
        }
    }
    
    
    
    internal static func createSecurityCode(
        password: String,
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        let url = urlGraphQL(env: PayME.env)
        let path = "/graphql"
        let sql =
        """
        mutation Mutation($createCodeByPasswordInput: CreateSecurityCodeByPassword!) {
          Account {
            SecurityCode {
              CreateCodeByPassword(input: $createCodeByPasswordInput) {
                securityCode
                succeeded
                message
              }
            }
          }
        }
        """
        let variables : [String: Any] = [
            "createCodeByPasswordInput": [
                "clientId": PayME.clientID,
                "password": password
            ]
        ]
        let json: [String: Any] = [
          "query": sql,
          "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        if (PayME.env == PayME.Env.DEV) {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequest(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                  // print("onSuccess \(data)")
                }
            )
        } else {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequestCrypto(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                }
            )
        }
    }
    internal static func transferByLinkedBank(
        transaction: String,
        storeId: Int,
        orderId: String,
        linkedId: Int,
        extraData: String,
        note: String,
        otp: String,
        amount: Int,
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        let url = urlGraphQL(env: PayME.env)
        let path = "/graphql"
        let sql =
        """
        mutation PayMutation($payInput: OpenEWalletPaymentPayInput!) {
          OpenEWallet {
            Payment {
              Pay(input: $payInput) {
                succeeded
                message
                payment {
                  ... on PaymentLinkedResponsed {
                    state
                    message
                    linkedId
                    transaction
                    html
                  }
                }
              }
            }
          }
        }
        """
        var payInput : [String:Any] =
        [
            "transaction": transaction,
            "referExtraData": extraData,
            "note": note,
            "clientId": PayME.clientID,
            "storeId": storeId,
            "amount": amount,
            "orderId": orderId,
            "payment": [
                "linked" : [
                    "linkedId": linkedId,
                    "otp": otp,
                    "envName": "MobileApp"
                ]
            ]
        ]
        if (note != "") {
            payInput.updateValue(note, forKey: "note")
        }
        if (extraData != "") {
            payInput.updateValue(extraData, forKey: "referExtraData")
        }
        let variables : [String: Any] = [
            "payInput": payInput
        ]
        let json: [String: Any] = [
          "query": sql,
          "variables": variables,
        ]
        print(variables)
        let params = try? JSONSerialization.data(withJSONObject: json)
        print(variables)
        print(PayME.accessToken)
        if (PayME.env == PayME.Env.DEV) {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequest(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                  // print("onSuccess \(data)")
                }
            )
        } else {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequestCrypto(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                }
            )
        }
        
    }
    
    internal static func readQRContent(
        qrContent: String,
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        let url = urlGraphQL(env: PayME.env)
        let path = "/graphql"
        let sql =
        """
        mutation Mutation($detectInput: OpenEWalletPaymentDetectInput!) {
          OpenEWallet {
            Payment {
              Detect(input: $detectInput) {
                action
                succeeded
                message
                type
                storeId
                amount
                note
                orderId
              }
            }
          }
        }
        """
        
        let variables : [String: Any] = [
            "detectInput": [
                "clientId": PayME.clientID,
                "qrContent" : qrContent
            ]
        ]
        let json: [String: Any] = [
          "query": sql,
          "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        print(variables)
        print(PayME.accessToken)
        if (PayME.env == PayME.Env.DEV) {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequest(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                }
            )
        } else {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequestCrypto(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                }
            )
        }
    }
    
    internal static func checkFlowLinkedBank(
        storeId: Int,
        orderId: String,
        linkedId: Int,
        extraData: String,
        note: String,
        amount: Int,
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        let url = urlGraphQL(env: PayME.env)
        let path = "/graphql"
        let sql =
        """
        mutation Mutation($payInput: OpenEWalletPaymentPayInput!) {
          OpenEWallet {
            Payment {
              Pay(input: $payInput) {
                succeeded
                message
                payment {
                  ... on PaymentLinkedResponsed {
                    state
                    message
                    linkedId
                    transaction
                    html
                  }
                }
              }
            }
          }
        }
        """
        
        var payInput : [String:Any] =
        [
            "referExtraData": extraData,
            "note": note,
            "clientId": PayME.clientID,
            "storeId": storeId,
            "amount": amount,
            "orderId": orderId,
            "payment": [
                "linked" : [
                    "linkedId": linkedId,
                    "envName": "MobileApp"
                ]
            ]
        ]
        if (note != "") {
            payInput.updateValue(note, forKey: "note")
        }
        if (extraData != "") {
            payInput.updateValue(extraData, forKey: "referExtraData")
        }
        let variables : [String: Any] = [
            "payInput": payInput
        ]
        let json: [String: Any] = [
          "query": sql,
          "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        print(variables)
        print(PayME.accessToken)
        if (PayME.env == PayME.Env.DEV) {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequest(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                  // print("onSuccess \(data)")
                }
            )
        } else {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequestCrypto(
                onError: { error in
                    onError(error)
            },
                onSuccess: { data in
                    onSuccess(data)
                }
            )
        }
        
    }
    
    internal static func transferWallet(
        storeId: Int,
        orderId: String,
        securityCode: String,
        extraData: String,
        note: String,
        amount: Int,
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        let url = urlGraphQL(env: PayME.env)
        let path = "/graphql"
        let sql =
        """
        mutation Mutation($payInput: OpenEWalletPaymentPayInput!) {
          OpenEWallet {
            Payment {
              Pay(input: $payInput) {
                succeeded
                message
              }
            }
          }
        }
        """
        var payInput : [String:Any] = [
            "clientId": PayME.clientID,
            "storeId": storeId,
            "amount": amount,
            "orderId": orderId,
            "note": note,
            "payment": [
                "wallet" : [
                    "active": true,
                    "securityCode": securityCode
                ]
            ]
        ]
        if (note != "") {
            payInput.updateValue(note, forKey: "note")
        }
        if (extraData != "") {
            payInput.updateValue(extraData, forKey: "referExtraData")
        }
        
        let variables : [String: Any] = [
            "payInput": payInput
        ]
        let json: [String: Any] = [
          "query": sql,
          "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        if (PayME.env == PayME.Env.DEV) {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequest(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                  // print("onSuccess \(data)")
                }
            )
        } else {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequestCrypto(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                }
            )
        }
    }
    
    internal static func getTransferMethods(
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        let url = urlGraphQL(env: PayME.env)
        let path = "/graphql"
        let sql =
        """
        mutation GetPaymentMethodMutation($getPaymentMethodInput: PaymentMethodInput) {
          Utility {
            GetPaymentMethod(input: $getPaymentMethodInput) {
              succeeded
              message
              methods {
                methodId
                type
                title
                label
                fee
                minFee
                data {
                  ... on LinkedMethodInfo {
                    swiftCode
                    linkedId
                  }
                  ... on WalletMethodInfo {
                    accountId
                  }
                }
              }
            }
          }
        }
        """
        let variables : [String: Any] = [
              "getPaymentMethodInput": [
                "serviceType": "OPEN_EWALLET_PAYMENT"
              ]
        ]
        let json: [String: Any] = [
          "query": sql,
          "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        if (PayME.env == PayME.Env.DEV) {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequest(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                }
            )
        } else {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequestCrypto(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                }
            )
        }
        
        
        
    }
    
    
    internal static func verifyKYC(
        pathFront: String?, pathBack: String?, pathAvatar: String?, pathVideo: String?,
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping (Dictionary<String, AnyObject>) -> ())
    {
        let url = urlGraphQL(env: PayME.env)
        let path = "/graphql"
        let sql = """
        mutation KYCMutation($kycInput: KYCInput!) {
          Account {
            KYC(input: $kycInput) {
              succeeded
              message
            }
          }
        }

        """
        var variables : [String: Any]
        if (pathBack == nil)
        {
            if (pathFront != nil) {
                variables = [
                    "kycInput": [
                      "clientId" : PayME.clientID,
                      "video": pathVideo ?? "",
                      "face": pathAvatar ?? "",
                      "image": ["front": pathFront!]
                  ]
                ]
            } else {
                variables = [
                    "kycInput": [
                      "clientId" : PayME.clientID,
                      "video": pathVideo ?? "",
                      "face": pathAvatar ?? "",
                      "image": []
                  ]
                ]
            }
        } else {
            if (pathFront != nil) {
                variables = [
                    "kycInput": [
                      "clientId" : PayME.clientID,
                      "video": pathVideo ?? "",
                      "face": pathAvatar ?? "",
                      "image": ["front":pathFront!,"back":pathBack!]
                  ]
                ]
            } else {
                variables = [
                    "kycInput": [
                        "clientId" : PayME.clientID,
                        "video": pathVideo ?? "",
                        "face": pathAvatar ?? "",
                        "image": ["back":pathBack!]
                  ]
                ]
            }
        }
        let json: [String: Any] = [
          "query": sql,
          "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        if (PayME.env == PayME.Env.DEV) {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequest(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                  // print("onSuccess \(data)")
                }
            )
        } else {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequestCrypto(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                  // print("onSuccess \(data)")
                }
            )
        }
    }
    
    
    
    internal static func getBankName(
        swiftCode : String,
        cardNumber: String,
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ){
        let url = urlGraphQL(env: PayME.env)
        let path = "/graphql"
        print(url+path)
        let sql = """
        mutation GetBankNameMutation($getBankNameInput: AccountBankInfoInput) {
          Utility {
            GetBankName(input: $getBankNameInput) {
              succeeded
              message
              accountName
            }
          }
        }
        """
        let variables : [String: Any] = [
            "getBankNameInput": [
                "swiftCode": swiftCode,
                "type" : "CARD",
                "cardNumber" : cardNumber
            ]
        ]
        let json: [String: Any] = [
          "query": sql,
          "variables": variables,
        ]
        print(variables)
        let params = try? JSONSerialization.data(withJSONObject: json)
        if (PayME.env == PayME.Env.DEV) {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequest(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                }
            )
        } else {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequestCrypto(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                }
            )
        }
    }
    
    internal static func getBankList(
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        let url = urlGraphQL(env: PayME.env)
        let path = "/graphql"
        print(url+path)
        let sql = """
        query Query {
          Setting {
            banks {
              id
              viName
              enName
              shortName
              swiftCode
              cardNumberLength
              cardPrefix
            }
          }
        }
        """
        let variables : [String: Any] = [:]
        let json: [String: Any] = [
          "query": sql,
          "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        if (PayME.env == PayME.Env.DEV) {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequest(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                }
            )
        } else {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequestCrypto(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                }
            )
        }
        
    }
    
    internal static func registerClient(
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping (Dictionary<String, AnyObject>) -> ())
    {
        let url = urlGraphQL(env: PayME.env)
        let path = "/graphql"
        print(url+path)
        let sql = """
        mutation InitMutation($registerInput: ClientRegisterInput!) {
          Client {
            Register(input: $registerInput) {
              clientId
              succeeded
            }
          }
        }
        """
        
        let variables : [String: Any] = [
            "registerInput": [
              "platform": "IOS",
              "deviceId": PayME.deviceID,
              "channel": "",
              "version": "1",
              "isEmulator": API.isEmulator,
              "isRoot": API.isRoot,
              "userAgent": UIDevice.current.name
          ]
        ]
        let json: [String: Any] = [
          "query": sql,
          "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        if (PayME.env == PayME.Env.DEV) {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequest(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                }
            )
        } else {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequestCrypto(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                }
            )
        }
    }
    
    internal static func initAccount (
        clientID: String,
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        let url = urlGraphQL(env: PayME.env)
        let path = "/graphql"
        let sql = """
        mutation Mutation($initInput: CheckInitInput) {
          OpenEWallet {
            Init(input: $initInput) {
              succeeded
              message
              handShake
              accessToken
              kyc {
                kycId
                state
                identifyNumber
                reason
                sentAt
              }
              phone
              isExistInMainWallet
            }
          }
        }
        """
        let variables : [String: Any] = [
            "initInput" : [
            "appToken": PayME.appToken,
            "connectToken": PayME.connectToken,
            "clientId": clientID
            ]
        ]
        let json: [String: Any] = [
          "query": sql,
          "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        if (PayME.env == PayME.Env.DEV) {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequest(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                  // print("onSuccess \(data)")
                }
            )
        } else {
            // check lai nil Token
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequestCrypto(
                onError: { error in
                    onError(error)
                },
                onSuccess: { data in
                    onSuccess(data)
                }
            )
        }
    }
    
    internal static func getWalletGraphQL(
      onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
      onError: @escaping (Dictionary<String, AnyObject>) -> ())
    {
      let url = urlGraphQL(env: PayME.env)
      let path = "/graphql"
      let sql = """
      query Query {
        Wallet {
          balance
          cash
          credit
          lockCash
          creditLimit
        }
      }
      """
      let variables : [String: Any] = [:]
      let json: [String: Any] = [
        "query": sql,
        "variables": variables,
      ]
      let params = try? JSONSerialization.data(withJSONObject: json)
      if (PayME.env == PayME.Env.DEV) {
          let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
          request.setOnRequest(
              onError: { error in
                  onError(error)
              },
              onSuccess: { data in
                  onSuccess(data)
                // print("onSuccess \(data)")
              }
          )
      } else {
          let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
          request.setOnRequestCrypto(
              onError: { error in
                  onError(error)
              },
              onSuccess: { data in
                  onSuccess(data)
                // print("onSuccess \(data)")
              }
          )
      }
    }

}
