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
    internal var id : Int!
    internal var cardNumberLength: Int
    internal var cardPrefix: String = ""
    internal var enName: String = ""
    internal var viName: String = ""
    internal var shortName: String = ""
    internal var swiftCode: String = ""
    
    public init(id : Int, cardNumberLength: Int, cardPrefix: String , enName: String, viName: String, shortName: String, swiftCode: String){
        self.id = id
        self.cardNumberLength = cardNumberLength
        self.cardPrefix = cardPrefix
        self.enName = enName
        self.viName = viName
        self.shortName = shortName
        self.swiftCode = swiftCode
    }
}

