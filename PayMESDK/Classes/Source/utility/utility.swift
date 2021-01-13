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
    if(key.contains("PUBLIC")) {
        let indexStart = key.index(key.startIndex, offsetBy: 26)
        let firstTemp  = key[indexStart...]
        let indexEnd = key.index(firstTemp.endIndex, offsetBy: -25)
        let secondTemp = firstTemp[...indexEnd]
        return String(secondTemp)
    } else if(key.contains("PRIVATE")) {
        let indexStart = key.index(key.startIndex, offsetBy: 31)
        let firstTemp  = key[indexStart...]
        let indexEnd = key.index(firstTemp.endIndex, offsetBy: -30)
        let secondTemp = firstTemp[...indexEnd]
        return String(secondTemp)
    }
    return key
}
internal func toastMess(title: String, message: String){
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
    PayME.currentVC?.present(alert, animated: true, completion: nil)
}
