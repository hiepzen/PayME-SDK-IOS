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

    func cardNumberFormatted() -> String {
        let tempCard = cardNumber.filter("0123456789".contains)
        if (bank?.cardNumberLength == 16) {
            return String(tempCard.enumerated().map { $0 > 0 && $0 % 4 == 0 ? ["-", $1] : [$1] }.joined())
        }
        if (bank?.cardNumberLength == 19) {
            return String(tempCard.enumerated().map { $0 > 0 && $0 % 8 == 0 ? ["-", $1] : [$1] }.joined())
        }
        return cardNumber
    }
}

class CreditCardInfomation {
    var cardNumber: String = ""
    var expiredAt: String = ""
    var cvv: String = ""

    init(cardNumber: String = "", expiredAt: String = "", cvv: String = "") {
        self.cardNumber = cardNumber
        self.expiredAt = expiredAt
        self.cvv = cvv
    }
}