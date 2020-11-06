//
//  PayMethod.swift
//  PayMESDK
//
//  Created by HuyOpen on 11/5/20.
//

import Foundation

public class PayMethod : Codable {
    internal var amount : String = ""
    internal var bankCode : String = ""
    internal var cardNumber : String = ""
    internal var detail : String = ""
    internal var linkedId : String = ""
    internal var swiftCode : String = ""
    internal var type : String = ""


    public init(phone :String,fullName:String,address:String,identify:String){
        self.setPhone(phoneNumber:phone)
        self.setFullName(fullNameUser: fullName)
        self.setAddress(addressUser: address)
        self.setIdentify(identifyUser: identify)
    }

    public func setPhone(phoneNumber: String){
         phone = phoneNumber
    }
    public func setFullName(fullNameUser: String){
        fullName = fullNameUser
    }
    public func setAddress(addressUser: String){
        address = addressUser
    }
    public func setIdentify(identifyUser: String){
        identify = identifyUser
    }
    public func getPhone() -> String {
        return self.phone
    }
    public func getFullName() -> String {
        return self.fullName
    }
    public func getAddress() -> String {
        return self.address
    }
    public func getIndentify() -> String {
        return self.identify
    }
    public func toJson() -> String{
        return "{phone:\(self.phone),fullName:\(self.fullName),address:\(self.address),identify:\(identify)}"
    }
}


