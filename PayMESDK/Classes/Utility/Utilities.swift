//
//  Utilities.swift
//  PayMESDK
//
//  Created by HuyOpen on 12/31/20.
//

import Foundation

func handleColor(input: [String]) -> String {
    let newString = input.joined(separator: "\",\"")
    return newString
}

func checkIntNil(input: Int?) -> String {
    if input != nil {
        return String(input!)
    }
    return "\"\""
}

func checkStringNil(input: String?) -> String {
    if input != nil {
        return input!
    }
    return ""
}

func formatMoney(input: Int) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    numberFormatter.maximumFractionDigits = 3
    let temp = numberFormatter.string(from: NSNumber(value: input))
    return "\(temp!)"
}

func urlFeENV(env: PayME.Env) -> String {
    if (env == PayME.Env.SANDBOX) {
        return "https://sbx-wam.payme.vn/v1/"
    }
    return "https://wam.payme.vn/v1/"
}

func urlGraphQL(env: PayME.Env) -> String {
    if (env == PayME.Env.DEV) {
        return "https://dev-fe.payme.net.vn"
    } else if (env == PayME.Env.SANDBOX) {
        return "https://sbx-fe.payme.vn"
    } else if (env == PayME.Env.STAGING) {
        return "https://sfe.payme.vn"
    }
    return "https://fe.payme.vn"
}

func urlWebview(env: PayME.Env) -> String {
    if (env == PayME.Env.DEV) {
        return "https://dev-sdk.payme.com.vn/active/"
    } else if (env == PayME.Env.SANDBOX) {
        return "https://sbx-sdk.payme.com.vn/active/"
    } else if env == PayME.Env.STAGING {
        return "https://staging-sdk.payme.com.vn/active/"
    }
    return "https://sdk.payme.com.vn/active/"
}

func urlUpload(env: PayME.Env) -> String {
    if (env == PayME.Env.SANDBOX || env == PayME.Env.DEV) {
        return "https://sbx-static.payme.vn"
    }
    return "https://static.payme.vn"
}

func trimKeyRSA(key: String) -> String {
    key.replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "").replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "").replacingOccurrences(of: "-----BEGIN RSA PRIVATE KEY-----", with: "").replacingOccurrences(of: "-----END RSA PRIVATE KEY-----", with: "").replacingOccurrences(of: "-----BEGIN PRIVATE KEY-----", with: "").replacingOccurrences(of: "-----END PRIVATE KEY-----", with: "")
}

func toastMess(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
    PayME.currentVC?.present(alert, animated: true, completion: nil)
}

func toDateString(date: Date?) -> String {
  guard let date = date else { return "" }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm dd/MM/yyyy"
    print(dateFormatter.string(from: date))
    return dateFormatter.string(from: date)
}

func toDate(dateString: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return dateFormatter.date(from: dateString)
}

func getMethodText(method: String) -> String {
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

func convertStringToDictionary(text: String) -> [String: AnyObject]? {
    if let data = text.data(using: .utf8) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject]
            return json
        } catch {
            print("Something went wrong")
        }
    }
    return nil
}

