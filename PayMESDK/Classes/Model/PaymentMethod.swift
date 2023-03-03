//
//  UserInfo.swift
//  PayMESDK
//
//  Created by HuyOpen on 9/29/20.
//  Copyright © 2020 PayME. All rights reserved.
//

import Foundation

public enum PayCode: String {
  case PAYME
  case ATM
  case VN_PAY
  case CREDIT
  case MOMO
  case ZALO_PAY
  case MANUAL_BANK
  case VIET_QR
}

enum MethodType: String {
  case WALLET
  case BANK_CARD
  case BANK_ACCOUNT
  case BANK_QR_CODE
  case BANK_TRANSFER
  case CREDIT_CARD
  case LINKED
  case PAYME_CREDIT
  case BANK_CARD_PG
  case MOMO_PG
  case CREDIT_CARD_PG
  case BANK_QR_CODE_PG
  case ZALOPAY_PG
  case CREDIT_BALANCE
  case VIET_QR
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
  var dataCreditWallet: CreditWalletInformation?
  var dataVietQR: VietQRInformation?
  var iconUrl: String

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
    dataCreditCard: CreditCardInfomation? = nil,
    dataCreditWallet: CreditWalletInformation? = nil,
    dataVietQR: VietQRInformation? = nil,
    iconUrl: String = ""
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
    self.dataCreditWallet = dataCreditWallet
    self.dataVietQR = dataVietQR
    self.iconUrl = iconUrl
  }
  
  func cloneWith(type: String) -> PaymentMethod {
    return PaymentMethod(type: type, title: self.title, label: self.label, fee: self.fee, dataWallet: self.dataWallet, dataLinked: self.dataLinked, dataBank: self.dataBank, iconUrl: self.iconUrl)
  }
}
