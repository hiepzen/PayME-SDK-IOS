//
//  PaymentPresentation.swift
//  PayMESDK
//
//  Created by Minh Khoa on 5/13/21.
//

import Foundation

struct ResponseError: Error {
    let code: Int
}

class PaymentPresentation {
    private let resultViewModel: ResultViewModel
    private let request: API
    private let onSuccess: (Dictionary<String, AnyObject>) -> ()
    private let onError: (Dictionary<String, AnyObject>) -> ()

    init(
            request: API, resultViewModel: ResultViewModel,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        self.request = request
        self.resultViewModel = resultViewModel
        self.onSuccess = onSuccess
        self.onError = onError
    }

    func paymentPayMEMethod(securityCode: String, orderTransaction: OrderTransaction) {
        request.transferWallet(
                storeId: orderTransaction.storeId, orderId: orderTransaction.orderId, securityCode: securityCode,
                extraData: orderTransaction.extraData, note: orderTransaction.note, amount: orderTransaction.amount,
                onSuccess: { response in
                    let paymentInfo = response["OpenEWallet"]!["Payment"] as! [String: AnyObject]
                    let payInfo = paymentInfo["Pay"] as! [String: AnyObject]
                    let message = payInfo["message"] as! String
                    let succeeded = payInfo["succeeded"] as! Bool
                    var formatDate = ""
                    var transactionNumber = ""
                    if let history = payInfo["history"] as? [String: AnyObject] {
                        if let createdAt = history["createdAt"] as? String {
                            if let date = toDate(dateString: createdAt) {
                                formatDate = toDateString(date: date)
                            }
                        }
                        if let payment = history["payment"] as? [String: AnyObject] {
                            if let transaction = payment["transaction"] as? String {
                                transactionNumber = transaction
                            }
                        }
                    }

                    if (succeeded == true) {
                        let paymentInfo = payInfo["history"]!["payment"] as! [String: AnyObject]
                        let responseSuccess = [
                            "payment": ["transaction": paymentInfo["transaction"] as? String]
                        ] as [String: AnyObject]
                        self.onSuccess(responseSuccess)

                    } else {
                        self.onError(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": message as AnyObject])

                    }

                    let result = Result(
                            type: succeeded ? ResultType.SUCCESS : ResultType.FAIL,
                            failReasonLabel: message,
                            orderTransaction: orderTransaction,
                            transactionInfo: TransactionInformation(transaction: transactionNumber, transactionTime: formatDate)
                    )
                    self.resultViewModel.resultSubject.onNext(result)
                },
                onError: { error in
                    if let code = error["code"] as? Int {
                        if (code == 401) {
                            self.resultViewModel.resultSubject.onError(ResponseError(code: code))
                        }
                    }
                    self.onError(error)
                })
    }

    func transferByLinkedBank(transaction: String, orderTransaction: OrderTransaction, linkedId: Int, OTP: String) {
        request.transferByLinkedBank(
                transaction: transaction, storeId: orderTransaction.storeId, orderId: orderTransaction.orderId, linkedId: linkedId,
                extraData: orderTransaction.extraData, note: orderTransaction.note, otp: OTP, amount: orderTransaction.amount,
                onSuccess: { response in
                    let paymentInfo = response["OpenEWallet"]!["Payment"] as! [String: AnyObject]
                    if let payInfo = paymentInfo["Pay"] as? [String: AnyObject] {
                        let succeeded = payInfo["succeeded"] as! Bool
                        var formatDate = ""
                        var transactionNumber = ""
                        var cardNumber = ""
                        if let history = payInfo["history"] as? [String: AnyObject] {
                            if let createdAt = history["createdAt"] as? String {
                                if let date = toDate(dateString: createdAt) {
                                    formatDate = toDateString(date: date)
                                }
                            }
                            if let payment = history["payment"] as? [String: AnyObject] {
                                if let transaction = payment["transaction"] as? String {
                                    transactionNumber = transaction
                                }
                                if let description = payment["description"] as? String {
                                    cardNumber = description
                                }
                            }
                        }
                        if (succeeded == true) {
                            let paymentInfo = payInfo["history"]!["payment"] as! [String: AnyObject]
                            let responseSuccess = [
                                "payment": ["transaction": paymentInfo["transaction"] as? String]
                            ] as [String: AnyObject]
                            self.onSuccess(responseSuccess)
                        } else {
                            let message = payInfo["message"] as? String
                            self.onError(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": (message ?? "Có lỗi xảy ra") as AnyObject])
                        }

                        let message = payInfo["message"] as? String
                        let result = Result(
                                type: succeeded ? ResultType.SUCCESS : ResultType.FAIL,
                                failReasonLabel: message ?? "Có lỗi xảy ra",
                                orderTransaction: orderTransaction,
                                transactionInfo: TransactionInformation(transaction: transactionNumber, transactionTime: formatDate, cardNumber: cardNumber)
                        )
                        self.resultViewModel.resultSubject.onNext(result)
                    } else {
                        self.onError(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": "Có lỗi xảy ra" as AnyObject])
                    }
                },
                onError: { error in
                    if let code = error["code"] as? Int {
                        if (code == 401) {
                            self.resultViewModel.resultSubject.onError(ResponseError(code: code))
                        }
                    }
                    self.onError(error)
                })
    }
}