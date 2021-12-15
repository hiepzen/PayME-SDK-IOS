//
//  BankManual.swift
//  PayMESDK
//
//  Created by Minh Khoa on 15/06/2021.
//

import Foundation

class BankManual {
    var bankAccountName: String = ""
    var bankAccountNumber: String = ""
    var bankBranch: String = ""
    var bankCity: String = ""
    var bankName: String = ""
    var content: String = ""
    var swiftCode: String = ""
    var qrCode: String = ""

    init(
            bankAccountName: String = "",
            bankAccountNumber: String = "",
            bankBranch: String = "",
            bankCity: String = "",
            bankName: String = "",
            content: String = "",
            swiftCode: String = "",
            qrCode: String = ""
    ) {
        self.bankAccountName = bankAccountName
        self.bankAccountNumber = bankAccountNumber
        self.bankBranch = bankBranch
        self.bankCity = bankCity
        self.bankName = bankName
        self.content = content
        self.swiftCode = swiftCode
        self.qrCode = qrCode
    }
}
