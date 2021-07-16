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
    case PENDING
}

struct Result {
    var type : ResultType! // loại kết quả: succees/fail
    var image : String = "" // hình thành công/thất bại
    var titleLabel: String = "" // Tiêu đề
    var failReasonLabel: String = "" // lí do thất bại
    var orderTransaction: OrderTransaction // thông tin đơn hàng
    var transactionInfo: TransactionInformation // thông tin giao dịch
    var extraData: Dictionary<String, AnyObject> // data response server trả về

    init(
            type: ResultType,
            image: String = "",
            titleLabel: String = "",
            failReasonLabel: String = "",
            orderTransaction: OrderTransaction,
            transactionInfo: TransactionInformation,
            extraData: Dictionary<String, AnyObject> = [:]
        ) {
        self.type = type
        switch type {
        case ResultType.SUCCESS:
            self.image = "success"
            self.titleLabel = "Thanh toán thành công"
            break
        case ResultType.FAIL:
            self.image = "failed"
            self.titleLabel = "Thanh toán thất bại"
            break
        case ResultType.PENDING:
            self.image = "success"
            self.titleLabel = "Thanh toán đang chờ xử lí"
        default:
            self.image = image
            self.titleLabel = titleLabel
        }
        self.failReasonLabel = failReasonLabel
        self.orderTransaction = orderTransaction
        self.transactionInfo = transactionInfo
        self.extraData = extraData
    }
}