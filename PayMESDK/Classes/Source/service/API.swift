//
//  API.swift
//  PayMESDK
//
//  Created by HuyOpen on 12/31/20.
//

import Foundation
import Alamofire

internal class API {
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
    
    internal static func uploadImageKYC(
        imageFront: UIImage,
        imageBack: UIImage?,
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping ([Int:Any]) -> ()
    ) {
        let url = urlUpload(env: PayME.env)
        let path = url + "/Upload"
        let imageData = imageFront.jpegData(compressionQuality: 1)
        let headers : HTTPHeaders = ["Content-type": "multipart/form-data",
                                     "Content-Disposition" : "form-data"]
        AF.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(imageData!, withName: "files", fileName: "imageFront.png", mimeType: "image/png")
                if (imageBack != nil) {
                    let imageDataBack = imageBack!.jpegData(compressionQuality: 1)
                    multipartFormData.append(imageDataBack!, withName: "files", fileName: "imageBack.png", mimeType: "image/png")
                }
            }, to: path, method: .post, headers: headers)
            .response { response in
                do {
                    if response.response?.statusCode == 200 {
                        let jsonData = response.data
                        let parsedData = try JSONSerialization.jsonObject(with: jsonData!) as! Dictionary<String, AnyObject>
                        onSuccess(parsedData)
                    }
                } catch {
                    onError([1001: "Some thing went wrong"])
                }
            }
    }
    
    internal static func registerClient(
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping ([Int:Any]) -> ()){
        
        let url = urlGraphQL(env: PayME.env)
        let path = "graphql"
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
              "version": "0.0.1",
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
                onErrorGraphQL: { errors in
                    print("onErrorGraphQL \(errors[0])")
                  },
                onSuccess: { data in
                    onSuccess(data)
                  // print("onSuccess \(data)")
                }
            )
        } else {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequestCrypto(
                onErrorGraphQL: { errors in
                    print("onErrorGraphQL \(errors[0])")
                  },
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
    
    internal static func checkAccessToken (
        clientID: String,
        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
        onError: @escaping ([Int:Any]) -> ()
    )
    {
        let url = urlGraphQL(env: PayME.env)
        let path = "graphql"
        let sql = """
        mutation InitMutation($initInput: CheckInitInput) {
          OpenEWallet {
            Init(input: $initInput) {
              accessToken
            }
          }
        }
        """
        let variables : [String: Any] = [
            "appToken": PayME.appID,
            "connectToken": PayME.connectToken,
            "clientId": clientID
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
                onErrorGraphQL: { errors in
                    print("onErrorGraphQL \(errors[0])")
                  },
                
                onSuccess: { data in
                    print(data)
                    onSuccess(data)
                  // print("onSuccess \(data)")
                }
            )
        } else {
            let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
            request.setOnRequestCrypto(
                onErrorGraphQL: { errors in
                    print("onErrorGraphQL \(errors[0])")
                  },
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
      onError: @escaping ([Int:Any]) -> ()) {
      let url = urlGraphQL(env: PayME.env)
      let path = "graphql"
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
              onErrorGraphQL: { errors in
                  print("onErrorGraphQL \(errors[0])")
                },
              
              onSuccess: { data in
                  onSuccess(data)
                // print("onSuccess \(data)")
              }
          )
      } else {
          let request = NetworkRequestGraphQL(url: url, path: path, token: PayME.accessToken, params: params, publicKey: PayME.publicKey, privateKey: PayME.appPrivateKey)
          request.setOnRequestCrypto(
              onErrorGraphQL: { errors in
                  print("onErrorGraphQL \(errors[0])")
                },
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
