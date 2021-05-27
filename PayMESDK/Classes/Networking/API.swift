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
    private let env: PayME.Env
    private var clientId: String = ""
    private let appId: String
    private let appToken: String
    private let connectToken: String
    private let deviceId: String

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

    func setAccessData(_ accessToken: String, _ clientId: String) {
        self.accessToken = accessToken
        self.clientId = clientId
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
            onNetworkError: @escaping () -> () = {}
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        let variables: [String: Any] = ["configsAppId": appId as Any]
        let json: [String: Any] = [
            "query": GraphQuery.getServiceQuery,
            "variables": variables
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onNetworkError)
    }

    func getAccountInfo(
            accountPhone: Any,
            onSuccess: @escaping ([String: AnyObject]) -> (),
            onError: @escaping ([String: AnyObject]) -> (),
            onNetworkError: @escaping () -> () = {}
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        let variables: [String: Any] = ["accountPhone": accountPhone]
        let json: [String: Any] = [
            "query": GraphQuery.getAccountInfoQuery,
            "variables": variables
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onNetworkError)
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
            onNetworkError: @escaping () -> () = {}
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        let variables: [String: Any] = [:]
        let json: [String: Any] = [
            "query": GraphQuery.getSettingQuery,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onNetworkError)
    }


    func getWalletInfo(
            onSuccess: @escaping ([String: AnyObject]) -> (),
            onError: @escaping ([String: AnyObject]) -> (),
            onNetworkError: @escaping () -> () = {}
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        let variables: [String: Any] = [:]
        let json: [String: Any] = [
            "query": GraphQuery.getWalletInfoQuery,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onNetworkError)
    }

    func transferATM(
            storeId: Int, orderId: String, extraData: String, note: String,
            cardNumber: String, cardHolder: String, issuedAt: String, amount: Int,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onNetworkError: @escaping () -> () = {}
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        var payInput: [String: Any] = [
            "clientId": clientId,
            "storeId": storeId,
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
        if (note != "") {
            payInput.updateValue(note, forKey: "note")
        }
        if (extraData != "") {
            payInput.updateValue(extraData, forKey: "referExtraData")
        }
        var variables: [String: Any] = ["payInput": payInput]
        let json: [String: Any] = [
            "query": GraphQuery.transferATMQuery,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onNetworkError)
    }


    func createSecurityCode(
            password: String,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onNetworkError: @escaping () -> () = {}
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
        onRequest(url, path, params, onSuccess, onError, onNetworkError)
    }

    func transferByLinkedBank(
            transaction: String, storeId: Int, orderId: String, linkedId: Int,
            extraData: String, note: String, otp: String, amount: Int,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onNetworkError: @escaping () -> () = {}
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        var payInput: [String: Any] = [
            "transaction": transaction,
            "referExtraData": extraData,
            "note": note,
            "clientId": clientId,
            "storeId": storeId,
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
        onRequest(url, path, params, onSuccess, onError, onNetworkError)
    }

    func readQRContent(
            qrContent: String,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onNetworkError: @escaping () -> () = {}
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
        onRequest(url, path, params, onSuccess, onError, onNetworkError)
    }

    func checkFlowLinkedBank(
            storeId: Int, orderId: String, linkedId: Int, extraData: String, note: String, amount: Int,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onNetworkError: @escaping () -> () = {}
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        var payInput: [String: Any] = [
            "referExtraData": extraData,
            "note": note,
            "clientId": clientId,
            "storeId": storeId,
            "amount": amount,
            "orderId": orderId,
            "payment": [
                "linked": [
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
        let variables: [String: Any] = ["payInput": payInput]
        let json: [String: Any] = [
            "query": GraphQuery.checkFlowLinkedBankQuery,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onNetworkError)
    }

    func transferWallet(
            storeId: Int, orderId: String, securityCode: String, extraData: String, note: String, amount: Int,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onNetworkError: @escaping () -> () = {}
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        var payInput: [String: Any] = [
            "clientId": clientId,
            "storeId": storeId,
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
        onRequest(url, path, params, onSuccess, onError, onNetworkError)
    }

    func getTransferMethods(
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onNetworkError: @escaping () -> () = {}
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        let variables: [String: Any] = [
            "getPaymentMethodInput": [
                "serviceType": "OPEN_EWALLET_PAYMENT"
            ]
        ]
        let json: [String: Any] = [
            "query": GraphQuery.getTranferMethodsQuery,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onNetworkError)
    }


    func verifyKYC(
            pathFront: String?, pathBack: String?, pathAvatar: String?, pathVideo: String?,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onNetworkError: @escaping () -> () = {}
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
            kycInput.updateValue(image, forKey: "image")
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
        onRequest(url, path, params, onSuccess, onError, onNetworkError)
    }

    func getBankName(
            swiftCode: String, cardNumber: String,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onNetworkError: @escaping () -> () = {}
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
        onRequest(url, path, params, onSuccess, onError, onNetworkError)
    }

    func getBankList(
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onNetworkError: @escaping () -> () = {}
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        let variables: [String: Any] = [:]
        let json: [String: Any] = [
            "query": GraphQuery.getBankListQuery,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onNetworkError)
    }

    func registerClient(
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onNetworkError: @escaping () -> () = {}
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
        onRequest(url, path, params, onSuccess, onError, onNetworkError)
    }

    func initAccount(
            clientID: String,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onNetworkError: @escaping () -> () = {}
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
        onRequest(url, path, params, onSuccess, onError, onNetworkError)
    }

    func getWalletGraphQL(
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onNetworkError: @escaping () -> () = {}
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        let variables: [String: Any] = [:]
        let json: [String: Any] = [
            "query": GraphQuery.getWalletGraphQLQuery,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onNetworkError)
    }

    func getFee(
            amount: Int,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onNetworkError: @escaping () -> () = {}
    ) {
        let url = urlGraphQL(env: env)
        let path = "/graphql"
        let variables: [String: Any] = ["getFeeInput": [
            "clientId": clientId,
            "serviceType": "OPEN_EWALLET_PAYMENT",
            "amount": amount
        ]]
        let json: [String: Any] = [
            "query": GraphQuery.getFeeGraphQLQuery,
            "variables": variables,
        ]
        let params = try? JSONSerialization.data(withJSONObject: json)
        onRequest(url, path, params, onSuccess, onError, onNetworkError)
    }

    private func onRequest(
            _ url: String, _ path: String, _ params: Data?,
            _ onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            _ onError: @escaping (Dictionary<String, AnyObject>) -> (),
            _ onNetworkError: @escaping () -> () = {}
    ) {
        let request = NetworkRequestGraphQL(appId: appId, url: url, path: path, token: accessToken, params: params, publicKey: publicKey, privateKey: privateKey)
        if (env == PayME.Env.DEV) {
            request.setOnRequest(onError: { error in onError(error) }, onSuccess: { data in onSuccess(data) })
        } else {
            request.setOnRequestCrypto(onError: { error in onError(error) },
                    onSuccess: { data in onSuccess(data) },
                    onNetworkError: { onNetworkError() }
            )
        }
    }
}
