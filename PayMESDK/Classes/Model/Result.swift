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

struct Result {
    var type : ResultType! // loại kết quả: succees/fail
    var image : String = "" // hình thành công/thất bại
    var titleLabel: String = "" // Tiêu đề
    var failReasonLabel: String = "" // lí do thất bại
    var orderTransaction: OrderTransaction // thông tin đơn hàng
    var transactionInfo: TransactionInformation // thông tin giao dịch

    init(
            type: ResultType,
            image: String = "",
            titleLabel: String = "",
            failReasonLabel: String = "",
            orderTransaction: OrderTransaction,
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
        self.failReasonLabel = failReasonLabel
        self.orderTransaction = orderTransaction
        self.transactionInfo = transactionInfo
    }
}