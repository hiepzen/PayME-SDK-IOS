//
//  Result.swift
//  PayMESDK
//
//  Created by Minh Khoa on 4/28/21.
//

import Foundation

public enum ResultType {
    case SUCCESS
    case FAIL
}

public struct Result {
    internal var type : ResultType! // loại kết quả: succees/fail
    internal var image : String = "" // hình thành công/thất bại
    internal var amount: Int = 0 // số tiền thanh toán
    internal var titleLabel: String = "" // Tiêu đề
    internal var failReasonLabel: String = "" // lí do thất bại
    internal var descriptionLabel: String = "" // nội dung thanh toán
    internal var paymentMethod: PaymentMethod // phương thức thanh toán
    internal var transactionInfo: TransactionInformation // thông tin giao dịch

    init(
            type: ResultType,
            image: String = "",
            amount: Int = 0,
            titleLabel: String = "",
            failReasonLabel: String = "",
            descriptionLabel: String = "",
            paymentMethod: PaymentMethod,
            transactionInfo: TransactionInformation
        ) {
        self.type = type
        if (type == ResultType.SUCCESS) {
            self.image = "success"
            self.titleLabel = "Thanh toán thành công"
        } else if (type == ResultType.FAIL) {
            self.image = "failed"
            self.titleLabel = "Thanh toán thất bại"
        } else {
            self.image = image
            self.titleLabel = titleLabel
        }
        self.amount = amount
        self.failReasonLabel = failReasonLabel
        self.descriptionLabel = descriptionLabel
        self.paymentMethod = paymentMethod
        self.transactionInfo = transactionInfo
    }
}