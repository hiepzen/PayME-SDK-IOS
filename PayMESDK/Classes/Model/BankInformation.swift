//
//  BankInformation.swift
//  PayMESDK
//
//  Created by Minh Khoa on 5/4/21.
//

import Foundation

class BankInformation {
    var cardNumber: String = ""
    var cardHolder: String = ""
    var issueDate: String = ""
    var bank: Bank?

    init(cardNumber: String = "", cardHolder: String = "", issueDate: String = "", bank: Bank? = nil) {
        self.cardNumber = cardNumber
        self.cardHolder = cardHolder
        self.issueDate = issueDate
        self.bank = bank
    }
}