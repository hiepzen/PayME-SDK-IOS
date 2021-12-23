//
//  API.swift
//  PayMESDK
//
//  Created by HuyOpen on 12/31/20.
//

import Foundation
import Alamofire

class API {
    private var alamoFireManager: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        let sessionManger = Session(configuration: configuration, startRequestsImmediately: true)
        return sessionManger
    }()
    private static var isRoot: Bool {
        guard TARGET_IPHONE_SIMULATOR != 1 else {
            return false
        }
        if FileManager.default.fileExists(atPath: "/Applications/Cydia.app")
                   || FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib")
                   || FileManager.default.fileExists(atPath: "/bin/bash")
                   || FileManager.default.fileExists(atPath: "/usr/sbin/sshd")
                   || FileManager.default.fileExists(atPath: "/etc/apt")
                   || FileManager.default.fileExists(atPath: "/private/var/lib/apt/")
                   || UIApplication.shared.canOpenURL(URL(string: "cydia://package/com.example.package")!) {

            return true
        }
        let stringToWrite = "Jailbreak Test"
        do {
            try stringToWrite.write(toFile: "/private/JailbreakTest.txt", atomically: true, encoding: String.Encoding.utf8)
            return true
        } catch {
            return false
        }
    }
    private static var isEmulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    private let publicKey: String
    private let privateKey: String
    private var accessToken: String = ""
    private var accessTokenKYC: String = ""
    private let env: PayME.Env
    private var clientId: String = ""
    private let appId: String
    private let appToken: String
    private let connectToken: String
    private let deviceId: String
    private var storeId: Int? = 0

    init(_ publicKey: String, _ privateKey: String, _ env: PayME.Env, _ appToken: String,
         _ connectToken: String, _ deviceId: String, _ appId: String) {
        self.publicKey = publicKey
        self.privateKey = privateKey
        self.env = env
        self.appToken = appToken
        self.connectToken = connectToken
        self.deviceId = deviceId
        self.appId = appId
    }

    func setAccessData(_ accessToken: String, _ accessTokenKYC: String, _ clientId: String?) {
        self.accessToken = accessToken
        self.clientId = clientId ?? self.clientId
        self.accessTokenKYC = accessTokenKYC
    }

    func setExtraData(storeId: Int? = 0) {
        self.storeId = storeId
    }

    func uploadVideoKYC(
            videoURL: URL,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping ([String: AnyObject]) -> ()
    ) {
        print(videoURL)
        let url = urlUpload(env: env)
        let path = url + "/Upload"
        let headers: HTTPHeaders = ["Content-type": "multipart/form-data",
                                    "Content-Disposition": "form-data"]
        alamoFireManager.upload(multipartFormData: { (multipartFormData) in
                    multipartFormData.append(videoURL, withName: "files", fileName: "video.mp4", mimeType: "video/mp4")
                }, to: path, method: .post, headers: headers)
                .responseJSON { response in
                    let result = response.result
                    switch result {
                    case .success(let value):
                        onSuccess(value as! Dictionary<String, AnyObject>)
                    case .failure(let error):
                        if let underlyingError = error.underlyingError {
                            if let urlError = underlyingError as? URLError {
                                switch urlError.code {
                                case .timedOut:
                                    print("Timed out error")
                                    onError(["code": 500 as AnyObject, "message": "Kết nối mạng bị sự cố, vui lòng kiểm tra và thử lại. Xin cảm ơn !" as AnyObject])
                                case .notConnectedToInternet:
                                    onError(["code": 500 as AnyObject, "message": "Kết nối mạng bị sự cố, vui lòng kiểm tra và thử lại. Xin cảm ơn !" as AnyObject])
                                default:
                                    onError(["code": 500 as AnyObject, "message": "Something went wrong" as AnyObject])
                                }
                            }
                        }
                    }
                }
    }

    func getService(
            onSuccess: @escaping ([String: AnyObject]) -> (),
            onError: @escaping ([String: AnyObject]) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        let variables: [String: Any] = ["configsAppId": appId as Any]
        let json: [String: Any] = [
            "query": GraphQuery.getServiceQuery,
            "variables": variables
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onPaymeError)
    }

    func getAccountInfo(
            accountPhone: Any,
            onSuccess: @escaping ([String: AnyObject]) -> (),
            onError: @escaping ([String: AnyObject]) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        let variables: [String: Any] = ["accountPhone": accountPhone]
        let json: [String: Any] = [
            "query": GraphQuery.getAccountInfoQuery,
            "variables": variables
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onPaymeError)
    }


    func uploadImageKYC(
            imageFront: UIImage,
            imageBack: UIImage?,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping ([String: AnyObject]) -> ()
    ) {
        let url = urlUpload(env: env)
        let path = url + "/Upload"
        let imageData = imageFront.jpegData(compressionQuality: 1)
        let headers: HTTPHeaders = ["Content-type": "multipart/form-data",
                                    "Content-Disposition": "form-data"]


        alamoFireManager.upload(multipartFormData: { multipartFormData in
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
                    case .failure(let error):
                        if let underlyingError = error.underlyingError {
                            if let urlError = underlyingError as? URLError {
                                switch urlError.code {
                                case .timedOut:
                                    print("Timed out error")
                                    onError(["code": 500 as AnyObject, "message": "Kết nối mạng bị sự cố, vui lòng kiểm tra và thử lại. Xin cảm ơn !" as AnyObject])
                                case .notConnectedToInternet:
                                    onError(["code": 500 as AnyObject, "message": "Kết nối mạng bị sự cố, vui lòng kiểm tra và thử lại. Xin cảm ơn !" as AnyObject])
                                default:
                                    onError(["code": 500 as AnyObject, "message": "Something went wrong" as AnyObject])
                                }
                            }
                        }
                    }
                }
    }

    func getSetting(
            onSuccess: @escaping ([String: AnyObject]) -> (),
            onError: @escaping ([String: AnyObject]) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        let variables: [String: Any] = [
            "configsKeys": ["limit.param.amount.payment",
                            "kyc.mode.enable",
                            "credit.sacom.auth.link",
                            "service.main.visible",
                            "sdk.web.secretKey"]
        ]
        let json: [String: Any] = [
            "query": GraphQuery.getSettingQuery,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onPaymeError)
    }


    func getWalletInfo(
            onSuccess: @escaping ([String: AnyObject]) -> (),
            onError: @escaping ([String: AnyObject]) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        let variables: [String: Any] = [:]
        let json: [String: Any] = [
            "query": GraphQuery.getWalletInfoQuery,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onPaymeError)
    }

    func transferATM(
            storeId: Int?, userName: String?, orderId: String, extraData: String, note: String,
            cardNumber: String, cardHolder: String, issuedAt: String, amount: Int,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        var payInput: [String: Any] = [
            "clientId": clientId,
            "amount": amount,
            "orderId": orderId,
            "payment": [
                "bankCard": [
                    "cardNumber": cardNumber,
                    "cardHolder": cardHolder,
                    "issuedAt": issuedAt
                ]
            ]
        ]
        if (storeId != nil) {
            payInput.updateValue(storeId, forKey: "storeId")
        }
        if userName != nil {
            payInput.updateValue(userName, forKey: "userName")
        }
        if (note != "") {
            payInput.updateValue(note, forKey: "note")
        }
        if (extraData != "") {
            payInput.updateValue(extraData, forKey: "referExtraData")
        }
        let variables: [String: Any] = ["payInput": payInput]
        let json: [String: Any] = [
            "query": GraphQuery.transferATMQuery,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onPaymeError)
    }

    func payVNPayQRCode(
            storeId: Int?, userName: String?, orderId: String, extraData: String, note: String, amount: Int,
            redirectUrl: String, failedUrl: String,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) -> URLSessionDataTask? {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        var payInput: [String: Any] = [
            "clientId": clientId,
            "orderId": orderId,
            "amount": amount,
            "payment": [
                "bankQRCode": [
                    "active": true,
                    "redirectUrl": redirectUrl,
                ]
            ]
        ]
        if (storeId != nil) {
            payInput.updateValue(storeId, forKey: "storeId")
        }
        if userName != nil {
            payInput.updateValue(userName, forKey: "userName")
        }
        let variables: [String: Any] = ["payInput": payInput]
        let json: [String: Any] = [
            "query": GraphQuery.paymentVNPayQRCode,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        return onRequestCancellable(url, path, params, onSuccess, onError)
    }

    func transferCreditCard(
            storeId: Int?, userName: String?, orderId: String, extraData: String, note: String,
            cardNumber: String, cardHolder: String, expiredAt: String, cvv: String, refId: String, amount: Int,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        var payInput: [String: Any] = {
            if refId != "" {
                return [
                    "clientId": clientId,
                    "amount": amount,
                    "orderId": orderId,
                    "payment": [
                        "creditCard": [
                            "cardNumber": cardNumber,
                            "cardHolder": cardHolder,
                            "expiredAt": expiredAt,
                            "cvv": cvv,
                            "referenceId": refId
                        ]
                    ]
                ]
            } else {
                return [
                    "clientId": clientId,
                    "amount": amount,
                    "orderId": orderId,
                    "payment": [
                        "creditCard": [
                            "cardNumber": cardNumber,
                            "expiredAt": expiredAt,
                            "cvv": cvv
                        ]
                    ]
                ]
            }
        }()
        if userName != nil {
            payInput.updateValue(userName, forKey: "userName")
        }
        if (storeId != nil) {
            payInput.updateValue(storeId, forKey: "storeId")
        }
        if (note != "") {
            payInput.updateValue(note, forKey: "note")
        }
        if (extraData != "") {
            payInput.updateValue(extraData, forKey: "referExtraData")
        }
        let variables: [String: Any] = ["payInput": payInput]
        let json: [String: Any] = [
            "query": GraphQuery.transferCreditCardQuery,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onPaymeError)
    }

    func paymentBankTransfer(
            storeId: Int?, userName: String?, orderId: String, extraData: String, note: String, amount: Int,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        var payInput: [String: Any] = [
            "clientId": clientId,
            "amount": amount,
            "orderId": orderId,
            "payment": [
                "bankTransfer": [
                    "active": true,
                    "recheck": true
                ]
            ]
        ]
        if userName != nil {
            payInput.updateValue(userName, forKey: "userName")
        }
        if (storeId != nil) {
            payInput.updateValue(storeId, forKey: "storeId")
        }
        if (note != "") {
            payInput.updateValue(note, forKey: "note")
        }
        if (extraData != "") {
            payInput.updateValue(extraData, forKey: "referExtraData")
        }
        let variables: [String: Any] = ["payInput": payInput]
        let json: [String: Any] = [
            "query": GraphQuery.paymentBankTransfer,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onPaymeError)
    }

    func createSecurityCode(
            password: String,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        let variables: [String: Any] = [
            "createCodeByPasswordInput": [
                "clientId": clientId,
                "password": password
            ]
        ]
        let json: [String: Any] = [
            "query": GraphQuery.createSecurityCodeQuery,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onPaymeError)
    }

    func transferByLinkedBank(
            transaction: String, storeId: Int?, userName: String?, orderId: String, linkedId: Int,
            extraData: String, note: String, otp: String, amount: Int,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        var payInput: [String: Any] = [
            "transaction": transaction,
            "referExtraData": extraData,
            "note": note,
            "clientId": clientId,
            "amount": amount,
            "orderId": orderId,
            "payment": [
                "linked": [
                    "linkedId": linkedId,
                    "otp": otp,
                    "envName": "MobileApp"
                ]
            ]
        ]
        if (storeId != nil) {
            payInput.updateValue(storeId, forKey: "storeId")
        }
        if userName != nil {
            payInput.updateValue(userName, forKey: "userName")
        }
        if (note != "") {
            payInput.updateValue(note, forKey: "note")
        }
        if (extraData != "") {
            payInput.updateValue(extraData, forKey: "referExtraData")
        }
        let variables: [String: Any] = ["payInput": payInput]
        let json: [String: Any] = [
            "query": GraphQuery.transferByLinkedBankQuery,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onPaymeError)
    }

    func readQRContent(
            qrContent: String,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        let variables: [String: Any] = [
            "detectInput": [
                "clientId": clientId,
                "qrContent": qrContent
            ]
        ]
        let json: [String: Any] = [
            "query": GraphQuery.readQRContentQuery,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onPaymeError)
    }

    func authenCreditCard(
            cardNumber: String, expiredAt: String, linkedId: Int?,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        var authCreditCardInput: [String: Any] = [
            "cardNumber": cardNumber
        ]
        if storeId != nil {
            authCreditCardInput.updateValue(storeId, forKey: "storeId")
        }
        if expiredAt != "" {
            authCreditCardInput.updateValue(expiredAt, forKey: "expiredAt")
        }
        if linkedId != nil {
            authCreditCardInput.updateValue(linkedId!, forKey: "linkedId")
        }
        let variables: [String: Any] = ["authCreditCardInput": authCreditCardInput]
        let json: [String: Any] = [
            "query": GraphQuery.mutationAuthenCredit,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onPaymeError)
    }

    func checkFlowLinkedBank(
            storeId: Int?, userName: String?, orderId: String, linkedId: Int, refId: String, extraData: String, note: String, amount: Int,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        var payInput: [String: Any] = {
            if refId != "" {
                return [
                    "referExtraData": extraData,
                    "note": note,
                    "clientId": clientId,
                    "amount": amount,
                    "orderId": orderId,
                    "payment": [
                        "linked": [
                            "linkedId": linkedId,
                            "envName": "MobileApp",
                            "referenceId": refId
                        ]
                    ]
                ]
            } else {
                return [
                    "referExtraData": extraData,
                    "note": note,
                    "clientId": clientId,
                    "amount": amount,
                    "orderId": orderId,
                    "payment": [
                        "linked": [
                            "linkedId": linkedId,
                            "envName": "MobileApp"
                        ]
                    ]
                ]
            }
        }()
        if storeId != nil {
            payInput.updateValue(storeId, forKey: "storeId")
        }
        if userName != nil {
            payInput.updateValue(userName, forKey: "userName")
        }
        if (note != "") {
            payInput.updateValue(note, forKey: "note")
        }
        if (extraData != "") {
            payInput.updateValue(extraData, forKey: "referExtraData")
        }
        let variables: [String: Any] = ["payInput": payInput]
        let json: [String: Any] = [
            "query": GraphQuery.checkFlowLinkedBankQuery,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onPaymeError)
    }

    func transferWallet(
            storeId: Int?, userName: String?, orderId: String, securityCode: String, extraData: String, note: String, amount: Int,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        var payInput: [String: Any] = [
            "clientId": clientId,
            "amount": amount,
            "orderId": orderId,
            "note": note,
            "payment": [
                "wallet": [
                    "active": true,
                    "securityCode": securityCode
                ]
            ]
        ]
        if (storeId != nil) {
            payInput.updateValue(storeId, forKey: "storeId")
        }
        if userName != nil {
            payInput.updateValue(userName, forKey: "userName")
        }
        if (note != "") {
            payInput.updateValue(note, forKey: "note")
        }
        if (extraData != "") {
            payInput.updateValue(extraData, forKey: "referExtraData")
        }
        let variables: [String: Any] = ["payInput": payInput]
        let json: [String: Any] = [
            "query": GraphQuery.transferWalletQuery,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onPaymeError)
    }

    func getTransferMethods(
            payCode: String = "",
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        var input = [
            "serviceType": "OPEN_EWALLET_PAYMENT",
        ] as [String: Any]
        if storeId != nil {
            input.updateValue(["storeId": storeId], forKey: "extraData")
        }
        if payCode != "" {
            input.updateValue(payCode, forKey: "payCode")
        }
        let variables: [String: Any] = [
            "getPaymentMethodInput": input
        ]
        let json: [String: Any] = [
            "query": GraphQuery.getTranferMethodsQuery,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onPaymeError)
    }


    func verifyKYC(
            pathFront: String?, pathBack: String?, pathAvatar: String?, pathVideo: String?, isUpdateIdentify: Bool = false,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        var kycInput: [String: Any] = ["clientId": clientId]
        if (pathBack != nil || pathFront != nil) {
            var image: [String: Any] = [:]
            if (pathFront != nil) {
                image.updateValue(pathFront!, forKey: "front")
            }
            if (pathBack != nil) {
                image.updateValue(pathBack!, forKey: "back")
            }
            if isUpdateIdentify {
                kycInput.updateValue(image, forKey: "identifyIC")
            } else {
                kycInput.updateValue(image, forKey: "image")
            }
        }
        if (pathVideo != nil) {
            kycInput.updateValue(pathVideo!, forKey: "video")
        }
        if (pathAvatar != nil) {
            kycInput.updateValue(pathAvatar!, forKey: "face")
        }
        let variables: [String: Any] = ["kycInput": kycInput]
        let json: [String: Any] = [
            "query": GraphQuery.verifyKYCQuery,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        let request = NetworkRequestGraphQL(appId: appId, url: url, path: path, token: accessTokenKYC, params: params, publicKey: publicKey, privateKey: privateKey)
        if (env == PayME.Env.DEV) {
            request.setOnRequest(onError: { error in onError(error) }, onSuccess: { data in onSuccess(data) })
        } else {
            request.setOnRequestCrypto(onError: { error in onError(error) },
                    onSuccess: { data in onSuccess(data) },
                    onPaymeError: { message in onPaymeError(message) }
            )
        }
    }

    func getBankName(
            swiftCode: String, cardNumber: String,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        let variables: [String: Any] = [
            "getBankNameInput": [
                "swiftCode": swiftCode,
                "type": "CARD",
                "cardNumber": cardNumber
            ]
        ]
        let json: [String: Any] = [
            "query": GraphQuery.getBankNameQuery,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onPaymeError)
    }

    func getBankList(
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        let variables: [String: Any] = [:]
        let json: [String: Any] = [
            "query": GraphQuery.getBankListQuery,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onPaymeError)
    }

    func registerClient(
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        let variables: [String: Any] = [
            "registerInput": [
                "platform": "IOS_SDK",
                "deviceId": deviceId,
                "channel": "",
                "version": "1",
                "isEmulator": API.isEmulator,
                "isRoot": API.isRoot,
                "userAgent": UIDevice.current.name
            ]
        ]
        print(variables)
        let json: [String: Any] = [
            "query": GraphQuery.registerClientQuery,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onPaymeError)
    }

    func getMerchantInformation(
            storeId: Int?,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        var variables: [String: Any] = ["infoInput": [
            "appId": appId,
        ]]
        if (storeId != nil) {
            variables.updateValue(storeId, forKey: "storeId")
        }
        let json: [String: Any] = [
            "query": GraphQuery.getMerchantInformation,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onPaymeError)
    }

    func initAccount(
            clientID: String,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        let variables: [String: Any] = ["initInput": [
            "appToken": appToken,
            "connectToken": connectToken,
            "clientId": clientID
        ]]
        let json: [String: Any] = [
            "query": GraphQuery.initAccountQuery,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onPaymeError)
    }

    func getWalletGraphQL(
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        let variables: [String: Any] = [:]
        let json: [String: Any] = [
            "query": GraphQuery.getWalletGraphQLQuery,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onPaymeError)
    }

    func getFee(
            amount: Int,
            payment: [String: Any]?,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        var variables = [
            "clientId": clientId,
            "serviceType": "OPEN_EWALLET_PAYMENT",
            "amount": amount
        ] as [String: Any]
        if payment != nil {
            variables.updateValue(payment, forKey: "payment")
        }
        if storeId != nil {
            variables.updateValue(storeId, forKey: "storeId")
        }
        let json: [String: Any] = [
            "query": GraphQuery.getFeeGraphQLQuery,
            "variables": [
                "getFeeInput": variables
            ],
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onPaymeError)
    }

    func getTransactionInfo(
            transaction: String,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) -> URLSessionDataTask? {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        let variables: [String: Any] = [
            "getTransactionInfoInput": [
                "transaction": transaction
            ]
        ]
        let json: [String: Any] = [
            "query": GraphQuery.getTransactionInfo,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        return onRequestCancellable(url, path, params, onSuccess, onError)
    }

    func getListBankManual(
            storeId: Int?, userName: String?, orderId: String, amount: Int,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        var variables: [String: Any] = [
            "clientId": clientId,
            "amount": amount,
            "orderId": orderId,
            "payment": [
                "bankTransfer": [
                    "active": true,
                    "recheck": false
                ]
            ]
        ]
        if (storeId != nil) {
            variables.updateValue(storeId, forKey: "storeId")
        }
        if userName != nil {
            variables.updateValue(userName, forKey: "userName")
        }
        let json: [String: Any] = [
            "query": GraphQuery.getListBankManual,
            "variables": [
                "payInput": variables
            ],
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onPaymeError)
    }

    private func onRequest(
            _ url: String, _ path: String, _ params: Data?,
            _ onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            _ onError: @escaping (Dictionary<String, AnyObject>) -> (),
            _ onPaymeError: @escaping (String) -> () = { s in
            }
    ) {
        let request = NetworkRequestGraphQL(appId: appId, url: url, path: path, token: accessToken, params: params, publicKey: publicKey, privateKey: privateKey)
        if (env == PayME.Env.DEV) {
            request.setOnRequest(onError: { error in onError(error) }, onSuccess: { data in onSuccess(data) })
        } else {
            request.setOnRequestCrypto(onError: { error in onError(error) },
                    onSuccess: { data in onSuccess(data) },
                    onPaymeError: { message in onPaymeError(message) }
            )
        }
    }

    private func onRequestCancellable(
            _ url: String, _ path: String, _ params: Data?,
            _ onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            _ onError: @escaping (Dictionary<String, AnyObject>) -> (),
            _ onPaymeError: @escaping (String) -> () = { s in
            }
    ) -> URLSessionDataTask? {
        let request = NetworkRequestGraphQL(appId: appId, url: url, path: path, token: accessToken, params: params, publicKey: publicKey, privateKey: privateKey)
        if (env == PayME.Env.DEV) {
            return request.setOnRequest(onError: { error in onError(error) }, onSuccess: { data in onSuccess(data) })
        } else {
            return request.setOnRequestCrypto(onError: { error in onError(error) }, onSuccess: { data in onSuccess(data) }, onPaymeError: { message in onPaymeError(message) })
        }
    }

    public func decryptSubscriptionMessage(
            xAPIMessageResponse: String,
            xAPIKeyResponse: String,
//            xAPIValidateResponse: String,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping ([String: AnyObject]) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) {
        guard let decryptKey = try? CryptoRSA.decryptRSA(encryptedString: xAPIKeyResponse, privateKey: self.privateKey) else {
            DispatchQueue.main.async {
                onError(["code": PayME.ResponseCode.ERROR_KEY_ENCODE as AnyObject, "message": "Giải mã thất bại" as AnyObject])
            }
            return
        }
        let stringJSON = CryptoAES.decryptAES(text: xAPIMessageResponse, password: decryptKey)
//        let formattedString = self.formatString(dataRaw: stringJSON)
        let dataJSON = stringJSON.data(using: .utf8)
        if let finalJSON = try? JSONSerialization.jsonObject(with: dataJSON!, options: []) as? Dictionary<String, AnyObject> {
            if let errors = finalJSON["errors"] as? [[String: AnyObject]] {
                DispatchQueue.main.async {
                    var code = PayME.ResponseCode.SYSTEM
                    if let extensions = errors[0]["extensions"] as? [String: AnyObject] {
                        if let responseCode = extensions["code"] as? Int {
                            if responseCode == 401 {
                                code = PayME.ResponseCode.EXPIRED
                            }
                        }
                    }
                    let message = (errors[0]["message"] as? String) ?? "Có lỗi xảy ra!"
                    onError(["code": code as AnyObject, "message": message as AnyObject])
                }
                return
            }
            if let data = finalJSON["data"] as? Dictionary<String, AnyObject> {
                DispatchQueue.main.async {
                    onSuccess(data)
                }
            }
        } else {
            let dataJSONRest = stringJSON.data(using: .utf8)
            if let finalJSON = try? JSONSerialization.jsonObject(with: dataJSONRest!, options: []) as? Dictionary<String, AnyObject> {
                if let data = finalJSON["data"] as? [String: AnyObject] {
                    DispatchQueue.main.async {
//                        onError(["code": code as AnyObject, "message": data["message"] as AnyObject])
                    }
                    return
                }
            } else {
                DispatchQueue.main.async {
                    onError(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": "Không thể kết nỗi tới server" as AnyObject])
                    return
                }
            }
        }
    }
}
