//
//  UserInfo.swift
//  PayMESDK
//
//  Created by HuyOpen on 9/29/20.
//  Copyright © 2020 PayME. All rights reserved.
//

import Foundation

public enum PayCode: String {
    case PAYME = "PAYME"
    case ATM = "ATM"
    case VN_PAY = "VN_PAY"
    case CREDIT = "CREDIT"
    case MOMO = "MOMO"
    case ZALO_PAY = "ZALO_PAY"
    case MANUAL_BANK = "MANUAL_BANK"
}

enum MethodType: String {
    case WALLET = "WALLET"
    case BANK_CARD = "BANK_CARD"
    case BANK_ACCOUNT = "BANK_ACCOUNT"
    case BANK_QR_CODE = "BANK_QR_CODE"
    case BANK_TRANSFER = "BANK_TRANSFER"
    case CREDIT_CARD = "CREDIT_CARD"
    case LINKED = "LINKED"
    case PAYME_CREDIT = "PAYME_CREDIT"
    case BANK_CARD_PG = "BANK_CARD_PG"
    case MOMO_PG = "MOMO_PG"
    case CREDIT_CARD_PG = "CREDIT_CARD_PG"
    case BANK_QR_CODE_PG = "BANK_QR_CODE_PG"
    case ZALOPAY_PG = "ZALOPAY_PG"
}

class PaymentData {
    var payCode: String = ""
    var methods: [PaymentMethod]
    init(payCode: String, methods: [PaymentMethod]) {
        self.payCode = payCode
        self.methods = methods
    }
}

class PaymentMethod {
    var type: String = ""
    var title: String = ""
    var label: String = ""
    var fee: Int!
    var feeDescription: String
    var dataWallet: WalletInformation?
    var dataLinked: LinkedInformation?
    var dataBank: BankInformation?
    var dataBankTransfer: BankManual?
    var dataCreditCard: CreditCardInfomation?

    init(
        type: String,
        title: String,
        label: String = "",
        fee: Int = 0,
        feeDescription: String = "",
        dataWallet: WalletInformation? = nil,
        dataLinked: LinkedInformation? = nil,
        dataBank: BankInformation? = nil,
        dataBankTransfer: BankManual? = nil,
        dataCreditCard: CreditCardInfomation? = nil
    ) {
        self.type = type
        self.title = title
        self.label = label
        self.fee = fee
        self.feeDescription = feeDescription
        self.dataWallet = dataWallet
        self.dataLinked = dataLinked
        self.dataBank = dataBank
        self.dataBankTransfer = dataBankTransfer
        self.dataCreditCard = dataCreditCard
    }
}

