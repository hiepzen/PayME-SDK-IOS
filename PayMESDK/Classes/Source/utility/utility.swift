//
//  utility.swift
//  PayMESDK
//
//  Created by HuyOpen on 12/31/20.
//

import Foundation

internal func handleColor(input: [String]) -> String {
    let newString = input.joined(separator: "\",\"")
    return newString
}
internal func checkIntNil(input: Int?) -> String {
    if input != nil {
        return String(input!)
    }
    return ""
}

internal func checkStringNil(input: String?) -> String {
    if input != nil {
        return input!
    }
    return ""
}

internal func formatMoney(input: Int) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    numberFormatter.maximumFractionDigits = 3
    let temp = numberFormatter.string(from: NSNumber(value: input))
    return "\(temp!)"
}

internal func  urlFeENV(env: PayME.Env) -> String {
    if (env == PayME.Env.SANDBOX) {
        return "https://sbx-wam.payme.vn/v1/"
    }
    return "https://wam.payme.vn/v1/"
}
internal func urlGraphQL(env: PayME.Env) -> String {
    if (env == PayME.Env.DEV) {
        return "https://dev-fe.payme.net.vn"
    } else if (env == PayME.Env.SANDBOX) {
        return "https://sbx-fe.payme.vn"
    }
    return "https://fe.payme.vn"
}

internal func  urlWebview(env: PayME.Env) -> String {
    if (env == PayME.Env.DEV) {
        return "https://sbx-sdk2.payme.com.vn/active/"
    } else if (env == PayME.Env.SANDBOX) {
        return "https://sbx-sdk.payme.com.vn/active/"
    }
    return "https://sdk.payme.com.vn/active/"
}

internal func urlUpload(env: PayME.Env) -> String {
    if (env == PayME.Env.SANDBOX || env == PayME.Env.DEV) {
        return "https://sbx-static.payme.vn/"
    }
    return "https://static.payme.vn/"
}
internal func trimKeyRSA(key: String) -> String {
    key.replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "").replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "").replacingOccurrences(of: "-----BEGIN RSA PRIVATE KEY-----", with: "").replacingOccurrences(of: "-----END RSA PRIVATE KEY-----", with: "").replacingOccurrences(of: "-----BEGIN PRIVATE KEY-----", with: "").replacingOccurrences(of: "-----END PRIVATE KEY-----", with: "")
}
internal func toastMess(title: String, message: String){
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
    PayME.currentVC?.present(alert, animated: true, completion: nil)
}

internal func toDateString(date: Date ) -> String
{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm dd/MM/yyyy"
    print(dateFormatter.string(from: date))
    return dateFormatter.string(from: date)
}

internal func toDate(dateString: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    print(dateFormatter.date(from: dateString) as Any)
    return dateFormatter.date(from: dateString)
}

internal func getMethodText(method: String) -> String {
    if (method == "WALLET") {
        return "Ví PayME"
    }
    if (method == "BANK_CARD") {
        return "Thẻ ATM nội địa"
    }
    if (method == "BANK_ACCOUNT" || method == "BANK_QR_CODE") {
        return "Tài khoản ngân hàng"
    }
    if (method == "BANK_TRANSFER") {
        return "Chuyển tiền"
    }
    if (method == "LINKED") {
        return "Tài khoản liên kết"
    }
    return method
}

internal func convertStringToDictionary(text: String) -> [String:AnyObject]? {
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
internal func checkCondition(onError: @escaping ([String:AnyObject]) -> ()) -> Bool {
    if (PayME.loggedIn == false || PayME.dataInit == nil) {
        onError(["code": PayME.ResponseCode.ACCOUNT_NOT_LOGIN as AnyObject, "message" : "Vui lòng đăng nhập để tiếp tục" as AnyObject])
        return false
    }
    if !(Reachability.isConnectedToNetwork()){
        onError(["code" : PayME.ResponseCode.NETWORK as AnyObject, "message" : "Vui lòng kiểm tra lại đường truyền mạng" as AnyObject])
        return false
    }
    if (PayME.accessToken == "") {
        onError(["code" : PayME.ResponseCode.ACCOUNT_NOT_ACTIVETES as AnyObject, "message" : "Tài khoản chưa kích hoạt" as AnyObject])
        return false
    }
    if (PayME.kycState != "APPROVED") {
        onError(["code" : PayME.ResponseCode.ACCOUNT_NOT_KYC as AnyObject, "message" : "Tài khoản chưa định danh" as AnyObject])
        return false
    }
    return true
}
