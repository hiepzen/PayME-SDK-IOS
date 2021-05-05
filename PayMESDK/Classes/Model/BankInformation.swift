//
//  BankInformation.swift
//  PayMESDK
//
//  Created by Minh Khoa on 5/4/21.
//

import Foundation

class BankInformation {
    internal var cardNumber: String = ""
    internal var cardHolder: String = ""
    internal var issueDate: String = ""

    init(cardNumber: String = "", cardHolder: String = "", issueDate: String = "") {
        self.cardNumber = cardNumber
        self.cardHolder = cardHolder
        self.issueDate = issueDate
    }
}