//
//  VietQRInformation.swift
//  PayMESDK
//
//  Created by Nam Phan Thanh on 09/05/2022.
//

import Foundation

class VietQRInformation {
  var qrContent: String
  var banks: [String]?

  init(qrContent: String, banks: [String]?) {
    self.qrContent = qrContent
    self.banks = banks
  }
}