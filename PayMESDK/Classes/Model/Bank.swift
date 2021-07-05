//
//  UserInfo.swift
//  PayMESDK
//
//  Created by HuyOpen on 9/29/20.
//  Copyright © 2020 PayME. All rights reserved.
//

import UIKit



import Foundation

public class Bank {
    var id : Int!
    var cardNumberLength: Int
    var cardPrefix: String = ""
    var enName: String = ""
    var viName: String = ""
    var shortName: String = ""
    var swiftCode: String = ""
    var isVietQr: Bool = false
    
    public init(id : Int, cardNumberLength: Int, cardPrefix: String , enName: String, viName: String, shortName: String, swiftCode: String, isVietQr: Bool = false){
        self.id = id
        self.cardNumberLength = cardNumberLength
        self.cardPrefix = cardPrefix
        self.enName = enName
        self.viName = viName
        self.shortName = shortName
        self.swiftCode = swiftCode
        self.isVietQr = isVietQr
    }
}

