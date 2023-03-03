//
//  VietQRInformation.swift
//  PayMESDK
//
//  Created by Nam Phan Thanh on 09/05/2022.
//

import Foundation

class VietQRInformation {
  var qrContent: String
  var manualInfo: PayMEQRTransfer?
//  var banks: [String]?
  init(qrContent: String, manualInfo: PayMEQRTransfer? = nil) {
    self.qrContent = qrContent
    self.manualInfo = manualInfo
  }
}

class PayMEQRTransfer {
  var bankName: String
  var shortBankName: String
  var bankNumber: String
  var accountName: String
  var branchName: String
  var content: String
  
  init(bankName: String, shortBankName: String, bankNumber: String, accountName: String, branchName: String, content: String) {
    self.bankName = bankName
    self.shortBankName = shortBankName
    self.bankNumber = bankNumber
    self.accountName = accountName
    self.branchName = branchName
    self.content = content
  }
}
