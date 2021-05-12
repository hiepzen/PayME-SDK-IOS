//
//  NetworkRequest.swift
//  PayMESDK
//
//  Created by HuyOpen on 9/29/20.
//  Copyright © 2020 PayME. All rights reserved.
//

import Foundation

public class NetworkRequest {
    private var url: String
    private var path: String
    private var token: String
    private var params: Data?
    private var publicKey: String
    private var privateKey: String

    init(url: String, path: String, token: String, params: Data?, publicKey: String, privateKey: String) {
        self.url = url
        self.path = path
        self.token = token
        self.params = params
        self.publicKey = publicKey
        self.privateKey = privateKey
    }

    public func setOnRequest(
            onError: @escaping (Dictionary<Int, Any>) -> (),
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        let url = NSURL(string: self.url + self.path)
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST"
        request.addValue(self.token, forHTTPHeaderField: "Authorization")
        if (self.url == "https://sbx-static.payme.vn/Upload" || self.url == "https://static.payme.vn/Upload") {
            request.addValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        } else {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

        }
        request.httpBody = self.params

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        let session = URLSession(configuration: sessionConfig)

        let task = session.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error != nil) {
                DispatchQueue.main.async {
                    if (error?.localizedDescription != nil) {
                        if (error?.localizedDescription == "The Internet connection appears to be offline.") {
                            onError([500: ["message": "Kết nối mạng bị sự cố, vui lòng kiểm tra và thử lại. Xin cảm ơn !"]])
                        } else {
                            onError([500: ["message": error?.localizedDescription]])
                        }
                    } else {
                        onError([500: ["message": "Something went wrong"]])

                    }

                }
                return
            }
            let json = try? (JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>)
            let code = json!["code"] as! Int
            if code == 1000 {
                if let data = json!["data"] as? Dictionary<String, AnyObject> {
                    DispatchQueue.main.async {
                        onSuccess(data)
                    }
                }
            } else {
                if let data = json!["data"] as? Dictionary<String, AnyObject> {
                    DispatchQueue.main.async {
                        onError([code: data])
                    }
                }
            }
        }
        task.resume()
    }

    public func setOnRequestCrypto(
            onError: @escaping (Dictionary<Int, Any>) -> (),
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        let encryptKey = "10000000"
        guard let xAPIKey = try? CryptoRSA.encryptRSA(plainText: encryptKey, publicKey: self.publicKey) else {
            DispatchQueue.main.async {
                onError([500: "Public Key sai định dạng" as Any])
            }
            return
        }

        let xAPIAction = CryptoAES.encryptAES(text: path, password: encryptKey)
        var xAPIMessage = ""
        if self.params != nil {
            xAPIMessage = CryptoAES.encryptAES(text: String(data: params!, encoding: .utf8)!, password: encryptKey)
        } else {
            let dictionaryNil = [String: String]()
            let paramsNil = try? JSONSerialization.data(withJSONObject: dictionaryNil)
            xAPIMessage = CryptoAES.encryptAES(text: String(data: paramsNil!, encoding: .utf8)!, password: encryptKey)
        }
        var valueParams = ""
        valueParams += xAPIAction
        valueParams += "POST"
        valueParams += token
        valueParams += xAPIMessage
        valueParams += encryptKey
        let xAPIValidate = CryptoAES.MD5(valueParams)!


        let url = NSURL(string: self.url)
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST"
        request.addValue(self.token, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("app", forHTTPHeaderField: "x-api-client")
        request.addValue(xAPIKey, forHTTPHeaderField: "x-api-key")
        request.addValue(xAPIAction, forHTTPHeaderField: "x-api-action")
        request.addValue(xAPIValidate, forHTTPHeaderField: "x-api-validate")
        let jsonBody = ["x-api-message": xAPIMessage]
        let dataBody = try? JSONSerialization.data(withJSONObject: jsonBody)
        request.httpBody = dataBody!

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        let session = URLSession(configuration: sessionConfig)

        let task = session.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error != nil) {
                DispatchQueue.main.async {
                    if (error?.localizedDescription != nil) {
                        if (error?.localizedDescription == "The Internet connection appears to be offline.") {
                            onError([500: ["message": "Kết nối mạng bị sự cố, vui lòng kiểm tra và thử lại. Xin cảm ơn !"]])
                        } else {
                            onError([500: ["message": error?.localizedDescription]])
                        }
                    } else {
                        onError([500: ["message": "Something went wrong"]])

                    }

                }
                return
            }

            let json = try? (JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>)
            guard let xAPIMessageResponse = json?["x-api-message"] as? String else {
                return
            }

            guard let headers = response as? HTTPURLResponse else {
                return
            }
            let xAPIKeyResponse = headers.allHeaderFields["x-api-key"] as! String
//            let xAPIValidateResponse = headers.allHeaderFields["x-api-validate"] as! String
            let xAPIActionResponse = headers.allHeaderFields["x-api-action"] as! String

            guard let decryptKey = try? CryptoRSA.decryptRSA(encryptedString: xAPIKeyResponse, privateKey: self.privateKey) else {
                DispatchQueue.main.async {
                    onError([500: "Private Key sai định dạng" as Any])
                }
                return
            }

            var validateString = ""
            validateString += xAPIActionResponse
            validateString += "POST"
            validateString += self.token
            validateString += xAPIMessageResponse
            validateString += decryptKey

//            let validateMD5 = CryptoAES.MD5(validateString)!
            let stringJSON = CryptoAES.decryptAES(text: xAPIMessageResponse, password: decryptKey)
            let dataJSON = stringJSON.data(using: .utf8)
            guard let finalJSON = try? JSONSerialization.jsonObject(with: dataJSON!, options: []) as? Dictionary<String, AnyObject> else {
                return
            }

            let code = finalJSON["code"] as! Int
            if code == 1000 {
                if let data = finalJSON["data"] as? Dictionary<String, AnyObject> {
                    DispatchQueue.main.async {
                        onSuccess(data)
                    }
                }
            } else {
                if let data = finalJSON["data"] as? Dictionary<String, AnyObject> {
                    DispatchQueue.main.async {
                        onError([code: data])
                    }
                    DispatchQueue.main.async {
                        
                    }
                }
            }
        }
        task.resume()
    }
}

public class NetworkRequestGraphQL {
    private var url: String
    private var path: String
    private var token: String
    private var params: Data?
    private var publicKey: String
    private var privateKey: String
    private var appId: String

    init(appId: String, url: String, path: String, token: String, params: Data?, publicKey: String, privateKey: String) {
        self.appId = appId
        self.url = url
        self.path = path
        self.token = token
        self.params = params
        self.publicKey = publicKey
        self.privateKey = privateKey
    }

    public func setOnRequest(
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        let url = NSURL(string: self.url + self.path)
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST"
        request.addValue(self.token, forHTTPHeaderField: "Authorization")
        if (self.url == "https://sbx-static.payme.vn/Upload" || self.url == "https://static.payme.vn/Upload") {
            request.addValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        } else {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

        }
        request.httpBody = self.params
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error != nil) {
                DispatchQueue.main.async {
                    if (error?.localizedDescription != nil) {
                        if (error?.localizedDescription == "The Internet connection appears to be offline.") {
                            onError(["code": PayME.ResponseCode.NETWORK as AnyObject, "message": "Kết nối mạng bị sự cố, vui lòng kiểm tra và thử lại. Xin cảm ơn !" as AnyObject])
                            return
                        } else {
                            onError(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": error?.localizedDescription as AnyObject])
                            return
                        }
                    } else {
                        onError(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": "Có lỗi hệ thống!" as AnyObject])
                        return
                    }
                }
                return
            }
            if let finalJSON = try? (JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject>) {
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
                if let finalJSON = try? JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, AnyObject> {
                    let code = finalJSON["code"] as! Int
                    if let data = finalJSON["data"] as? [String: AnyObject] {
                        DispatchQueue.main.async {
                            onError(["code": code as AnyObject, "message": data["message"] as AnyObject])
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
        task.resume()
    }

    public func setOnRequestCrypto(
            onError: @escaping ([String: AnyObject]) -> (),
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        let encryptKey = "10000000"

        guard let xAPIKey = try? CryptoRSA.encryptRSA(plainText: encryptKey, publicKey: self.publicKey) else {
            DispatchQueue.main.async {
                onError(["code": PayME.ResponseCode.ERROR_KEY_ENCODE as AnyObject, "message": "Mã hóa thất bại" as AnyObject])
            }
            return
        }
        let xAPIAction = CryptoAES.encryptAES(text: path, password: encryptKey)
        var xAPIMessage = ""
        if self.params != nil {
            xAPIMessage = CryptoAES.encryptAES(text: String(data: params!, encoding: .utf8)!, password: encryptKey)
        } else {
            let dictionaryNil = [String: String]()
            let paramsNil = try? JSONSerialization.data(withJSONObject: dictionaryNil)
            xAPIMessage = CryptoAES.encryptAES(text: String(data: paramsNil!, encoding: .utf8)!, password: encryptKey)
        }
        var valueParams = ""
        valueParams += xAPIAction
        valueParams += "POST"
        valueParams += token
        valueParams += xAPIMessage
        valueParams += encryptKey
        let xAPIValidate = CryptoAES.MD5(valueParams)!

        let url = NSURL(string: self.url)
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST"
        request.addValue(self.token, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(appId, forHTTPHeaderField: "x-api-client")
        request.addValue(xAPIKey, forHTTPHeaderField: "x-api-key")
        request.addValue(xAPIAction, forHTTPHeaderField: "x-api-action")
        request.addValue(xAPIValidate, forHTTPHeaderField: "x-api-validate")
        let jsonBody = ["x-api-message": xAPIMessage]
        let dataBody = try? JSONSerialization.data(withJSONObject: jsonBody)
        request.httpBody = dataBody!

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        let session = URLSession(configuration: sessionConfig)

        let task = session.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error != nil) {
                DispatchQueue.main.async {
                    if (error?.localizedDescription != nil) {
                        if (error?.localizedDescription == "The Internet connection appears to be offline.") {
                            onError(["code": PayME.ResponseCode.NETWORK as AnyObject, "message": "Kết nối mạng bị sự cố, vui lòng kiểm tra và thử lại. Xin cảm ơn !" as AnyObject])
                            return
                        } else {
                            onError(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": error?.localizedDescription as AnyObject])
                            return
                        }
                    } else {
                        onError(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": "Có lỗi hệ thống!" as AnyObject])
                        return
                    }
                }
                return
            }

            let json = try? (JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>)

            guard let xAPIMessageResponse = json?["x-api-message"] as? String else {
                if let code = json?["code"] as? Int {
                    if let data = json!["data"] as? [String: AnyObject] {
                        DispatchQueue.main.async {
                            onError(["code": code as AnyObject, "message": data["message"] as AnyObject])
                            return
                        }
                    } else {
                        DispatchQueue.main.async {
                            onError(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": "Không thể kết nối tới server" as AnyObject])
                            return
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        onError(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": "Không thể kết nối tới server" as AnyObject])
                        return
                    }
                }
                return
            }

            guard let headers = response as? HTTPURLResponse else {
                return
            }
            let xAPIKeyResponse = headers.allHeaderFields["x-api-key"] as! String
            let xAPIValidateResponse = headers.allHeaderFields["x-api-validate"] as! String
            let xAPIActionResponse = headers.allHeaderFields["x-api-action"] as! String
            guard let decryptKey = try? CryptoRSA.decryptRSA(encryptedString: xAPIKeyResponse, privateKey: self.privateKey) else {
                DispatchQueue.main.async {
                    onError(["code": PayME.ResponseCode.ERROR_KEY_ENCODE as AnyObject, "message": "Giải mã thất bại" as AnyObject])
                }
                return
            }

            var validateString = ""
            validateString += xAPIActionResponse
            validateString += "POST"
            validateString += self.token
            validateString += xAPIMessageResponse
            validateString += decryptKey

            let validateMD5 = CryptoAES.MD5(validateString)!
            let stringJSON = CryptoAES.decryptAES(text: xAPIMessageResponse, password: decryptKey)
            let formattedString = self.formatString(dataRaw: stringJSON)
            let dataJSON = formattedString.data(using: .utf8)
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
                    let code = finalJSON["code"] as! Int
                    if let data = finalJSON["data"] as? [String: AnyObject] {
                        DispatchQueue.main.async {
                            onError(["code": code as AnyObject, "message": data["message"] as AnyObject])
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
        task.resume()
    }

    func formatString(dataRaw: String) -> String {
        var str = dataRaw
        str = str.replacingOccurrences(of: "\\r", with: "");
        str = str.replacingOccurrences(of: "\\n", with: "");
        str = String(str.dropFirst(1).dropLast(1))
        let regex = try! NSRegularExpression(pattern: "\\\\\"", options: NSRegularExpression.Options.caseInsensitive)
        let range = NSMakeRange(0, str.count)
        let modString = regex.stringByReplacingMatches(in: str, options: [], range: range, withTemplate: "\"")
        str = modString.replacingOccurrences(of: "\\\\", with: "\\");
        str = str.replacingOccurrences(of: "\\\"}", with: "\"}")

        let detect = """
                     {"data":{"Setting":{"configs"
                     """
        if (str.contains(detect)) {
            str = str.replacingOccurrences(of: "\"{", with: "{")
            str = str.replacingOccurrences(of: "}\"", with: "}")
            str = str.replacingOccurrences(of: "\\", with: "")
            str = str.replacingOccurrences(of: "\"\"", with: "\"")
        }
        return str
    }
}


