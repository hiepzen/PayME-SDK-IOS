//
//  PaymentInformation.swift
//  PayMESDK
//
//  Created by Minh Khoa on 5/4/21.
//

import Foundation

public class TransactionInformation {
    internal var transaction: String = "" // mã giao dịch
    internal var transactionTime: String = "" // thời gian giao dịch
    internal var cardNumber: String = "" // số thẻ (khi phương thức thanh toán là thẻ liên kết hoặc thẻ ngân hàng)

    init (transaction: String = "", transactionTime: String = "", cardNumber: String = "") {
        self.transaction = transaction
        self.transactionTime = transactionTime
        self.cardNumber = cardNumber
    }
}