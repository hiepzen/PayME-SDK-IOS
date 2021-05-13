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
    var orderId: String
    var extraData: String
    var note: String
    var paymentMethod: PaymentMethod?

    init(
            amount: Int = 10000,
            storeId: Int,
            orderId: String,
            note: String,
            extraData: String,
            paymentMethod: PaymentMethod? = nil
    ) {
        self.amount = amount
        self.storeId = storeId
        self.orderId = orderId
        self.note = note
        self.extraData = extraData
        self.paymentMethod = paymentMethod
    }
}