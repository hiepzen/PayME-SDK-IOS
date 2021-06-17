//
//  UserInfo.swift
//  PayMESDK
//
//  Created by HuyOpen on 9/29/20.
//  Copyright © 2020 PayME. All rights reserved.
//

import Foundation

class PaymentMethod {
    var methodId: Int!
    var type: String = ""
    var title: String = ""
    var label: String = ""
    var fee: Int!
    var minFee: Int!
    var feeDescription: String
    var dataWallet: WalletInformation?
    var dataLinked: LinkedInformation?
    var dataBank: BankInformation?
    var dataBankTransfer: BankManual?
    var dataCreditCard: CreditCardInfomation?
    var active: Bool!

    init(
        methodId: Int?,
        type: String,
        title: String,
        label: String,
        fee: Int = 0,
        minFee: Int,
        feeDescription: String = "",
        dataWallet: WalletInformation? = nil,
        dataLinked: LinkedInformation? = nil,
        dataBank: BankInformation? = nil,
        dataBankTransfer: BankManual? = nil,
        dataCreditCard: CreditCardInfomation? = nil,
        active: Bool
    ) {
        self.methodId = methodId
        self.type = type
        self.title = title
        self.label = label
        self.fee = fee
        self.minFee = minFee
        self.feeDescription = feeDescription
        self.dataWallet = dataWallet
        self.dataLinked = dataLinked
        self.dataBank = dataBank
        self.dataBankTransfer = dataBankTransfer
        self.dataCreditCard = dataCreditCard
        self.active = active
    }
}

