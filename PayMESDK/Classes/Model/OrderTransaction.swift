//
//  Transaction.swift
//  PayMESDK
//
//  Created by Minh Khoa on 5/13/21.
//

import Foundation

class OrderTransaction {
    var amount: Int
    var storeId: Int
    var storeName: String
    var storeImage: String
    var orderId: String
    var extraData: String
    var note: String
    var paymentMethod: PaymentMethod?
    var transactionInformation: TransactionInformation?
    var total: Int
    var isShowHeader: Bool

    init(
            amount: Int = 10000,
            storeId: Int,
            storeName: String = "",
            storeImage: String = "",
            orderId: String,
            note: String,
            extraData: String,
            paymentMethod: PaymentMethod? = nil,
            transactionInformation: TransactionInformation? = nil,
            total: Int? = nil,
            isShowHeader: Bool = false
    ) {
        self.amount = amount
        self.storeId = storeId
        self.storeName = storeName
        self.storeImage = storeImage
        self.orderId = orderId
        self.note = note
        self.extraData = extraData
        self.paymentMethod = paymentMethod
        self.transactionInformation = transactionInformation
        self.total = total ?? amount
        self.isShowHeader = isShowHeader
    }
}