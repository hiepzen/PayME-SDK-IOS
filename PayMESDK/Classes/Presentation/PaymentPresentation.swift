//
//  PaymentPresentation.swift
//  PayMESDK
//
//  Created by Minh Khoa on 5/13/21.
//

import Foundation
import SwiftyJSON

enum ResponseErrorCode {
    case EXPIRED
    case PASSWORD_RETRY_TIMES_OVER
    case PASSWORD_INVALID
    case REQUIRED_OTP
    case REQUIRED_VERIFY
    case REQUIRED_AUTHEN_CARD
    case INVALID_OTP
    case OVER_QUOTA
    case SERVER_ERROR
}

struct ResponseError {
    var code: ResponseErrorCode
    var message: String
    var transaction: String
    var html: String
    var transactionInformation: TransactionInformation?
    var paymentInformation: Dictionary<String, AnyObject>?

    init(
            code: ResponseErrorCode, message: String = "", transaction: String = "", html: String = "",
            transactionInformation: TransactionInformation? = nil,
            paymentInformation: Dictionary<String, AnyObject>? = nil
    ) {
        self.code = code
        self.message = message
        self.transaction = transaction
        self.html = html
        self.transactionInformation = transactionInformation
        self.paymentInformation = paymentInformation
    }
}

class PaymentPresentation {
    private let paymentViewModel: PaymentViewModel
    private let request: API
    private let onSuccess: (Dictionary<String, AnyObject>) -> ()
    private let onError: (Dictionary<String, AnyObject>) -> ()
    var onPaymeError: (String) -> ()
    private let accessToken: String
    private let kycState: String

    init(
            request: API, paymentViewModel: PaymentViewModel,
            accessToken: String, kycState: String,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> (),
            onPaymeError: @escaping (String) -> () = { s in
            }
    ) {
        self.request = request
        self.paymentViewModel = paymentViewModel
        self.accessToken = accessToken
        self.kycState = kycState
        self.onSuccess = onSuccess
        self.onError = { dictionary in
            guard let code = dictionary["code"] as? Int else {
                let message = dictionary["message"] as? String ?? "hasError".localize()
                onError(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": message as AnyObject])
                return
            }
            if code == PayME.ResponseCode.SYSTEM {
                paymentViewModel.paymentSubject.onNext(PaymentState(state: .ERROR,
                        error: ResponseError(code: .SERVER_ERROR, message: dictionary["message"] as? String ?? "hasError".localize())))
            } else {
                onError(dictionary)
            }
        }
        self.onPaymeError = onPaymeError
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
                        let result = Result(
                                type: ResultType.SUCCESS,
                                orderTransaction: orderTransaction,
                                transactionInfo: TransactionInformation(transaction: transactionNumber, transactionTime: formatDate),
                                extraData: responseSuccess
                        )
                        self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.RESULT, result: result))
                    } else {
                        let result = Result(
                                type: ResultType.FAIL,
                                failReasonLabel: message,
                                orderTransaction: orderTransaction,
                                transactionInfo: TransactionInformation(transaction: transactionNumber, transactionTime: formatDate),
                                extraData: ["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": message as AnyObject]
                        )
                        self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.RESULT, result: result))
                    }
                },
                onError: { error in
                    if let code = error["code"] as? Int {
                        if (code == 401) {
                            self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.ERROR, error: ResponseError(code: ResponseErrorCode.EXPIRED)))
                        }
                    }
                    self.onError(error)
                },
                onPaymeError: onPaymeError)
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
                            let result = Result(
                                    type: ResultType.SUCCESS,
                                    orderTransaction: orderTransaction,
                                    transactionInfo: TransactionInformation(transaction: transactionNumber, transactionTime: formatDate, cardNumber: cardNumber),
                                    extraData: responseSuccess
                            )
                            self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.RESULT, result: result))
                        } else {
                            if let state = payInfo["payment"]!["state"] as? String {
                                if state == "INVALID_OTP" {
                                    self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.ERROR, error: ResponseError(
                                            code: ResponseErrorCode.INVALID_OTP, message: payInfo["message"] as? String ?? "hasError".localize()
                                    )))
                                }
                                if state == "FAILED" {
                                    let message = payInfo["message"] as? String
                                    let result = Result(
                                            type: ResultType.FAIL,
                                            failReasonLabel: payInfo["message"] as? String ?? "hasError".localize(),
                                            orderTransaction: orderTransaction,
                                            transactionInfo: TransactionInformation(transaction: transactionNumber, transactionTime: formatDate, cardNumber: cardNumber),
                                            extraData: ["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": (message ?? "hasError".localize()) as AnyObject]
                                    )
                                    self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.RESULT, result: result))
                                }
                            }
                        }
                    } else {
                        self.onError(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": "hasError".localize() as AnyObject])
                    }
                },
                onError: { error in
                    if let code = error["code"] as? Int {
                        if (code == 401) {
                            self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.ERROR, error: ResponseError(code: ResponseErrorCode.EXPIRED)))
                        }
                    }
                    self.onError(error)
                },
                onPaymeError: onPaymeError)
    }

    func authenCreditCard(orderTransaction: OrderTransaction) {
        var cardNum = ""
        var exp: String = ""
        var linkedId: Int? = nil
        if orderTransaction.paymentMethod?.type == MethodType.CREDIT_CARD.rawValue {
            cardNum = orderTransaction.paymentMethod?.dataCreditCard?.cardNumber ?? ""
            linkedId = nil
            exp = orderTransaction.paymentMethod?.dataCreditCard?.expiredAt ?? ""
        } else if orderTransaction.paymentMethod?.type == MethodType.LINKED.rawValue {
            cardNum = orderTransaction.paymentMethod?.dataLinked?.cardNumber ?? ""
            linkedId = orderTransaction.paymentMethod?.dataLinked?.linkedId
            exp = ""
        }
        request.authenCreditCard(cardNumber: cardNum, expiredAt: exp, linkedId: linkedId,
                onSuccess: { response in
                    let data = JSON(response)
                    if let isSucceeded = data["CreditCardLink"]["AuthCreditCard"]["succeeded"].bool,
                       let refId = data["CreditCardLink"]["AuthCreditCard"]["referenceId"].string,
                       let html = data["CreditCardLink"]["AuthCreditCard"]["html"].string,
                       let isAuth = data["CreditCardLink"]["AuthCreditCard"]["isAuth"].bool {
                        if isSucceeded == true {
                            if isAuth == true {
                                if orderTransaction.paymentMethod?.type == MethodType.CREDIT_CARD.rawValue {
                                    orderTransaction.paymentMethod?.dataCreditCard?.referenceId = refId
                                } else if orderTransaction.paymentMethod?.type == MethodType.LINKED.rawValue {
                                    orderTransaction.paymentMethod?.dataLinked?.referenceId = refId
                                }
                                let realHtml = "<html><body onload=\"document.forms[0].submit();\">\(html)</body></html>"
                                self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.ERROR, orderTransaction: orderTransaction,
                                        error: ResponseError(code: ResponseErrorCode.REQUIRED_AUTHEN_CARD, html: realHtml))
                                )
                            } else {
                                if orderTransaction.paymentMethod?.type == MethodType.CREDIT_CARD.rawValue {
                                    self.payCreditCard(orderTransaction: orderTransaction)
                                } else {
                                    self.paymentLinkedMethod(orderTransaction: orderTransaction)
                                }
                            }
                        } else {
                            let result = Result(
                                    type: ResultType.FAIL,
                                    failReasonLabel: data["CreditCardLink"]["AuthCreditCard"]["message"].string ?? "hasError".localize(),
                                    orderTransaction: orderTransaction,
                                    transactionInfo: TransactionInformation(transaction: orderTransaction.orderId, transactionTime: toDateString(date: Date())),
                                    extraData: ["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": (data["CreditCardLink"]["AuthCreditCard"]["message"].string ?? "hasError".localize()) as AnyObject]
                            )
                            self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.RESULT, result: result))
                        }
                    } else {
                        let result = Result(
                                type: ResultType.FAIL,
                                failReasonLabel: data["CreditCardLink"]["AuthCreditCard"]["message"].string ?? "hasError".localize(),
                                orderTransaction: orderTransaction,
                                transactionInfo: TransactionInformation(transaction: orderTransaction.orderId, transactionTime: toDateString(date: Date())),
                                extraData: ["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": (data["CreditCardLink"]["AuthCreditCard"]["message"].string ?? "hasError".localize()) as AnyObject]
                        )
                        self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.RESULT, result: result))
                    }
                },
                onError: { error in
                    self.onError(error)
                    if let code = error["code"] as? Int {
                        if (code == 401) {
                            self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.ERROR, error: ResponseError(code: ResponseErrorCode.EXPIRED)))
                        }
                    }
                }, onPaymeError: onPaymeError)
    }

    func paymentLinkedMethod(orderTransaction: OrderTransaction) {
        request.checkFlowLinkedBank(
                storeId: orderTransaction.storeId, orderId: orderTransaction.orderId, linkedId: (orderTransaction.paymentMethod?.dataLinked!.linkedId)!,
                refId: orderTransaction.paymentMethod?.dataLinked?.referenceId ?? "",
                extraData: orderTransaction.extraData, note: orderTransaction.note, amount: orderTransaction.amount,
                onSuccess: { flow in
                    let pay = flow["OpenEWallet"]!["Payment"] as! [String: AnyObject]
                    if let payInfo = pay["Pay"] as? [String: AnyObject] {
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
                        let succeeded = payInfo["succeeded"] as! Bool
                        if (succeeded == true) {
                            let paymentInfo = payInfo["history"]!["payment"] as! [String: AnyObject]
                            let responseSuccess = [
                                "payment": ["transaction": paymentInfo["transaction"] as? String]
                            ] as [String: AnyObject]
                            let result = Result(
                                    type: ResultType.SUCCESS,
                                    orderTransaction: orderTransaction,
                                    transactionInfo: TransactionInformation(transaction: transactionNumber, transactionTime: formatDate, cardNumber: cardNumber),
                                    extraData: responseSuccess
                            )
                            self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.RESULT, result: result))
                        } else {
                            if let payment = payInfo["payment"] as? [String: AnyObject] {
                                let state = (payment["state"] as? String) ?? ""
                                if (state == "REQUIRED_OTP") {
                                    let transaction = payment["transaction"] as! String
                                    self.paymentViewModel.paymentSubject.onNext(
                                            PaymentState(state: State.ERROR, error: ResponseError(code: ResponseErrorCode.REQUIRED_OTP, transaction: transaction))
                                    )
                                } else if (state == "REQUIRED_VERIFY") {
                                    if let html = payment["html"] as? String {
                                        let realHtml = (orderTransaction.paymentMethod?.dataLinked?.swiftCode != nil ? html : "<html><body onload=\"document.forms[0].submit();\">\(html)</body></html>")
                                        self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.ERROR, error: ResponseError(
                                                code: ResponseErrorCode.REQUIRED_VERIFY,
                                                html: realHtml,
                                                transactionInformation: TransactionInformation(
                                                        transaction: transactionNumber, transactionTime: formatDate, cardNumber: cardNumber
                                                ),
                                                paymentInformation: payInfo
                                        )))
                                    }
                                } else {
                                    let message = payment["message"] as? String
                                    let result = Result(
                                            type: ResultType.FAIL,
                                            failReasonLabel: message ?? "hasError".localize(),
                                            orderTransaction: orderTransaction,
                                            transactionInfo: TransactionInformation(transaction: transactionNumber, transactionTime: formatDate, cardNumber: cardNumber),
                                            extraData: ["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": (message ?? "hasError".localize()) as AnyObject]
                                    )
                                    self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.RESULT, result: result))
                                }
                            } else {
                                let message = payInfo["message"] as? String
                                self.onError(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": (message ?? "hasError".localize()) as AnyObject])
                                let result = Result(
                                        type: ResultType.FAIL,
                                        failReasonLabel: message ?? "hasError".localize(),
                                        orderTransaction: orderTransaction,
                                        transactionInfo: TransactionInformation(transaction: transactionNumber, transactionTime: formatDate, cardNumber: cardNumber),
                                        extraData: ["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": (message ?? "hasError".localize()) as AnyObject]
                                )
                                self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.RESULT, result: result))
                            }
                        }
                    } else {
                        self.onError(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": "hasError".localize() as AnyObject])
                    }
                },
                onError: { flowError in
                    self.onError(flowError)
                    if let code = flowError["code"] as? Int {
                        if (code == 401) {
                            self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.ERROR, error: ResponseError(code: ResponseErrorCode.EXPIRED)))
                        }
                    }
                },
                onPaymeError: onPaymeError)
    }

    func createSecurityCode(password: String, orderTransaction: OrderTransaction) {
        request.createSecurityCode(password: password,
                onSuccess: { securityInfo in
                    let account = securityInfo["Account"]!["SecurityCode"] as! [String: AnyObject]
                    let securityResponse = account["CreateCodeByPassword"] as! [String: AnyObject]
                    let securitySucceeded = securityResponse["succeeded"] as! Bool
                    if (securitySucceeded == true) {
                        let securityCode = securityResponse["securityCode"] as! String
                        let methodType = orderTransaction.paymentMethod?.type
                        if methodType == "WALLET" {
                            self.paymentPayMEMethod(securityCode: securityCode, orderTransaction: orderTransaction)
                        }
                        if methodType == "LINKED" {
                            if (orderTransaction.paymentMethod?.dataLinked?.issuer ?? "") != "" {
                                self.authenCreditCard(orderTransaction: orderTransaction)
                            } else {
                                self.paymentLinkedMethod(orderTransaction: orderTransaction)
                            }
                        }
                    } else {
                        let message = securityResponse["message"] as! String
                        let code = securityResponse["code"] as! String
                        if (code == "PASSWORD_INVALID" || code == "PASSWORD_RETRY_TIMES_OVER") {
                            self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.ERROR, error: ResponseError(
                                    code: ResponseErrorCode.PASSWORD_INVALID, message: message
                            )))
                        } else {
                            let result = Result(
                                    type: ResultType.FAIL,
                                    failReasonLabel: message,
                                    orderTransaction: orderTransaction,
                                    transactionInfo: TransactionInformation(),
                                    extraData: ["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": message as AnyObject]
                            )
                            self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.RESULT, result: result))
                        }
                    }
                },
                onError: { error in
                    if let code = error["code"] as? Int {
                        if (code == 401) {
                            self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.ERROR, error: ResponseError(code: ResponseErrorCode.EXPIRED)))
                        }
                    }
                    self.onError(error)
                }, onPaymeError: onPaymeError)
    }

    func payBankTransfer(orderTransaction: OrderTransaction) {
        paymentViewModel.paymentSubject.onNext(PaymentState(state: .BANK_TRANS_RESULT, orderTransaction: orderTransaction, bankTransferState: .PENDING))
        request.paymentBankTransfer(
                storeId: orderTransaction.storeId, orderId: orderTransaction.orderId, extraData: orderTransaction.extraData,
                note: orderTransaction.note, amount: orderTransaction.amount,
                onSuccess: { success in
                    var formatDate = ""
                    var transactionNumber = ""
                    let paymentInfo = success["OpenEWallet"]!["Payment"] as! [String: AnyObject]
                    if let payInfo = paymentInfo["Pay"] as? [String: AnyObject] {
                        if let payment = payInfo["payment"] as? [String: AnyObject] {
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
                            if let bankTranferState = payment["bankTranferState"] as? String {
                                if bankTranferState == "SUCCEEDED" {
                                    let responseSuccess = [
                                        "payment": ["transaction": transactionNumber]
                                    ] as [String: AnyObject]
                                    let result = Result(
                                            type: ResultType.SUCCESS,
                                            orderTransaction: orderTransaction,
                                            transactionInfo: TransactionInformation(transaction: transactionNumber, transactionTime: formatDate),
                                            extraData: responseSuccess
                                    )
                                    self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.RESULT, result: result))
                                } else if bankTranferState == "REQUIRED_TRANSFER" {
                                    self.paymentViewModel.paymentSubject.onNext(PaymentState(state: .BANK_TRANS_RESULT, orderTransaction: orderTransaction, bankTransferState: .FAIL))
                                } else {
                                    let message = payment["message"] as? String
                                    let result = Result(
                                            type: ResultType.FAIL,
                                            failReasonLabel: message ?? "hasError".localize(),
                                            orderTransaction: orderTransaction,
                                            transactionInfo: TransactionInformation(transaction: transactionNumber, transactionTime: formatDate),
                                            extraData: ["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": (message ?? "hasError".localize()) as AnyObject]
                                    )
                                    self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.RESULT, result: result))
                                }
                            }
                        }
                    }
                },
                onError: { error in
                    self.onError(error)
                    if let code = error["code"] as? Int {
                        if (code == 401) {
                            self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.ERROR, error: ResponseError(code: ResponseErrorCode.EXPIRED)))
                        }
                    }
                },
                onPaymeError: onPaymeError
        )
    }

    func payVNQRCode(orderTransaction: OrderTransaction, redirectURL: String) -> URLSessionDataTask? {
        request.payVNPayQRCode(
                storeId: orderTransaction.storeId, orderId: orderTransaction.orderId, extraData: orderTransaction.extraData,
                note: orderTransaction.note, amount: orderTransaction.amount, redirectUrl: redirectURL, failedUrl: "",
                onSuccess: { success in
                    let data = JSON(success)
                    if let qrContent = data["OpenEWallet"]["Payment"]["Pay"]["payment"]["qrContent"].string,
                       let transaction = data["OpenEWallet"]["Payment"]["Pay"]["history"]["payment"]["transaction"].string {
                        orderTransaction.transactionInformation = TransactionInformation(transaction: transaction)
                        self.paymentViewModel.paymentSubject.onNext(PaymentState(
                                state: State.BANK_QR_CODE_PG, orderTransaction: orderTransaction, qrContent: qrContent
                        ))
                    } else {
                        let result = Result(
                                type: ResultType.FAIL,
                                failReasonLabel: data["OpenEWallet"]["Payment"]["Pay"]["message"].string ?? "hasError".localize(),
                                orderTransaction: orderTransaction,
                                transactionInfo: TransactionInformation(transaction: orderTransaction.orderId, transactionTime: toDateString(date: Date())),
                                extraData: ["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": (data["OpenEWallet"]["Payment"]["Pay"]["message"].string ?? "hasError".localize()) as AnyObject]
                        )
                        self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.RESULT, result: result))
                    }
                },
                onError: { error in
                    print("minh khoa")
                    print(error)
                    self.onError(error)
                    if let code = error["code"] as? Int {
                        if (code == 401) {
                            self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.ERROR, error: ResponseError(code: ResponseErrorCode.EXPIRED)))
                        }
                    }
                },
                onPaymeError: onPaymeError
        )
    }

    func payATM(orderTransaction: OrderTransaction) {
        request.transferATM(
                storeId: orderTransaction.storeId, orderId: orderTransaction.orderId, extraData: orderTransaction.extraData,
                note: orderTransaction.note, cardNumber: orderTransaction.paymentMethod!.dataBank!.cardNumber,
                cardHolder: orderTransaction.paymentMethod!.dataBank!.cardHolder,
                issuedAt: orderTransaction.paymentMethod!.dataBank!.issueDate, amount: orderTransaction.amount,
                onSuccess: { success in
                    let payment = success["OpenEWallet"]!["Payment"] as! [String: AnyObject]
                    if let payInfo = payment["Pay"] as? [String: AnyObject] {
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
                        let succeeded = payInfo["succeeded"] as! Bool
                        if (succeeded == true) {
                            let paymentInfo = payInfo["history"]!["payment"] as! [String: AnyObject]
                            let responseSuccess = [
                                "payment": ["transaction": paymentInfo["transaction"] as? String]
                            ] as [String: AnyObject]
                            let result = Result(
                                    type: ResultType.SUCCESS,
                                    orderTransaction: orderTransaction,
                                    transactionInfo: TransactionInformation(transaction: transactionNumber, transactionTime: formatDate, cardNumber: cardNumber),
                                    extraData: responseSuccess
                            )
                            self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.RESULT, result: result))
                        } else {
                            let statePay = payInfo["payment"] as? [String: AnyObject]
                            if (statePay == nil) {
                                let message = payInfo["message"] as? String
                                let result = Result(
                                        type: ResultType.FAIL,
                                        failReasonLabel: message ?? "hasError".localize(),
                                        orderTransaction: orderTransaction,
                                        transactionInfo: TransactionInformation(transaction: transactionNumber, transactionTime: formatDate, cardNumber: cardNumber),
                                        extraData: ["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": (message ?? "hasError".localize()) as AnyObject]
                                )
                                self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.RESULT, result: result))
                                return
                            }
                            let state = statePay?["state"] as? String ?? ""
                            if (state == "REQUIRED_VERIFY") {
                                if let html = statePay!["html"] as? String {
                                    self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.ERROR, error: ResponseError(
                                            code: ResponseErrorCode.REQUIRED_VERIFY,
                                            html: html,
                                            transactionInformation: TransactionInformation(
                                                    transaction: transactionNumber, transactionTime: formatDate, cardNumber: cardNumber
                                            ),
                                            paymentInformation: payInfo
                                    )))
                                }
                            } else {
                                let message = statePay!["message"] as? String
                                let result = Result(
                                        type: ResultType.FAIL,
                                        failReasonLabel: message ?? "hasError".localize(),
                                        orderTransaction: orderTransaction,
                                        transactionInfo: TransactionInformation(transaction: transactionNumber, transactionTime: formatDate, cardNumber: cardNumber),
                                        extraData: ["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": (message ?? "hasError".localize()) as AnyObject]
                                )
                                self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.RESULT, result: result))
                            }
                        }
                    } else {
                        self.onError(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": "hasError".localize() as AnyObject])
                    }
                },
                onError: { error in
                    self.onError(error)
                    if let code = error["code"] as? Int {
                        if (code == 401) {
                            self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.ERROR, error: ResponseError(code: ResponseErrorCode.EXPIRED)))
                        }
                    }
                },
                onPaymeError: onPaymeError)
    }

    func payCreditCard(orderTransaction: OrderTransaction) {
        request.transferCreditCard(storeId: orderTransaction.storeId, orderId: orderTransaction.orderId, extraData: orderTransaction.extraData,
                note: orderTransaction.note, cardNumber: orderTransaction.paymentMethod!.dataCreditCard!.cardNumber,
                cardHolder: orderTransaction.paymentMethod!.dataCreditCard!.cardHolder,
                expiredAt: orderTransaction.paymentMethod!.dataCreditCard!.expiredAt, cvv: orderTransaction.paymentMethod!.dataCreditCard!.cvv,
                refId: orderTransaction.paymentMethod!.dataCreditCard?.referenceId ?? "", amount: orderTransaction.amount,
                onSuccess: { success in
                    let payment = success["OpenEWallet"]!["Payment"] as! [String: AnyObject]
                    if let payInfo = payment["Pay"] as? [String: AnyObject] {
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
                        let succeeded = payInfo["succeeded"] as? Bool ?? false
                        let statePay = payInfo["payment"] as? [String: AnyObject]
                        if (succeeded == true) && statePay != nil {
                            let state = statePay!["state"] as? String
                            if let transState = state {
                                if transState == "SUCCEEDED" {
                                    let paymentInfo = payInfo["history"]!["payment"] as? [String: AnyObject]
                                    let responseSuccess = [
                                        "payment": ["transaction": paymentInfo?["transaction"] as? String]
                                    ] as [String: AnyObject]
                                    let result = Result(
                                            type: ResultType.SUCCESS,
                                            orderTransaction: orderTransaction,
                                            transactionInfo: TransactionInformation(transaction: transactionNumber, transactionTime: formatDate, cardNumber: cardNumber),
                                            extraData: responseSuccess
                                    )
                                    self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.RESULT, result: result))
                                }
                            }
                        } else {
                            if statePay != nil {
                                let state = statePay!["state"] as? String
                                let message = statePay!["message"] as? String
                                if let transState = state {
                                    if (transState == "REQUIRED_VERIFY") {
                                        if let html = statePay!["html"] as? String {
                                            let realHtml = "<html><body onload=\"document.forms[0].submit();\">\(html)</body></html>"
                                            self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.ERROR, error: ResponseError(
                                                    code: ResponseErrorCode.REQUIRED_VERIFY,
                                                    html: realHtml,
                                                    transactionInformation: TransactionInformation(
                                                            transaction: transactionNumber, transactionTime: formatDate, cardNumber: cardNumber
                                                    ),
                                                    paymentInformation: payInfo
                                            )))
                                        }
                                    } else {
                                        let result = Result(
                                                type: ResultType.FAIL,
                                                failReasonLabel: message ?? "hasError".localize(),
                                                orderTransaction: orderTransaction,
                                                transactionInfo: TransactionInformation(transaction: transactionNumber, transactionTime: formatDate, cardNumber: cardNumber),
                                                extraData: ["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": (message ?? "hasError".localize()) as AnyObject]
                                        )
                                        self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.RESULT, result: result))
                                    }
                                    return
                                }
                            }
                            let message = payInfo["message"] as? String
                            let result = Result(
                                    type: ResultType.FAIL,
                                    failReasonLabel: message ?? "hasError".localize(),
                                    orderTransaction: orderTransaction,
                                    transactionInfo: TransactionInformation(transaction: transactionNumber, transactionTime: formatDate, cardNumber: cardNumber),
                                    extraData: ["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": (message ?? "hasError".localize()) as AnyObject]
                            )
                            self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.RESULT, result: result))
                        }
                    } else {
                        self.onError(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": "hasError".localize() as AnyObject])
                    }
                },
                onError: { error in
                    self.onError(error)
                    if let code = error["code"] as? Int {
                        if (code == 401) {
                            self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.ERROR, error: ResponseError(code: ResponseErrorCode.EXPIRED)))
                        }
                    }
                }, onPaymeError: onPaymeError
        )
    }

    func getListMethods(
            payCode: String = "",
            onSuccess: @escaping ([PaymentMethod]) -> Void,
            onError: @escaping (Dictionary<String, AnyObject>) -> Void
    ) {
        request.getTransferMethods(payCode: payCode,
                onSuccess: { response in
                    let items = (response["Utility"]!["GetPaymentMethod"] as! [String: AnyObject])["methods"] as! [[String: AnyObject]]
                    var methods: [PaymentMethod] = []
                    for (index, item) in items.enumerated() {
                        guard let methodType = item["type"] as? String else {
                            continue
                        }
                        let methodInformation = PaymentMethod(
                                type: methodType, title: item["title"] as! String, label: item["label"] as! String
                        )
                        if methodType == "WALLET" {
                            methodInformation.dataWallet = WalletInformation(balance: 0)
                        }
                        if methodType == "LINKED" {
                            methodInformation.dataLinked = LinkedInformation(
                                    swiftCode: (item["data"] as! [String: AnyObject])["swiftCode"] as? String,
                                    linkedId: (item["data"] as! [String: AnyObject])["linkedId"] as! Int,
                                    issuer: (item["data"] as! [String: AnyObject])["issuer"] as? String ?? ""
                            )
                        }
                        methods.append(methodInformation)
                    }
                    guard let method = methods.first(where: { $0.type == "WALLET" }) else {
                        onSuccess(methods)
                        return
                    }
                    if self.accessToken != "" && self.kycState == "APPROVED" {
                        self.request.getWalletInfo(onSuccess: { response in
                            let balance = (response["Wallet"] as! [String: AnyObject])["balance"] as? Int ?? 0
                            method.dataWallet?.balance = balance
                            onSuccess(methods)
                        }, onError: { error in onError(error) })
                    } else {
                        onSuccess(methods)
                    }

                },
                onError: { error in onError(error) },
                onPaymeError: onPaymeError)
    }

    func getLinkBank(orderTransaction: OrderTransaction) {
        request.getBankList(onSuccess: { bankListResponse in
            let banks = bankListResponse["Setting"]!["banks"] as! [[String: AnyObject]]
            var listBank: [Bank] = []
            for bank in banks {
                if bank["depositable"] as? Bool ?? false && ((bank["cardNumberLength"] as? Int) != nil) && ((bank["cardPrefix"] as? String) != nil) {
                    var dateString: String
                    if (bank["requiredDate"] as? String ?? "") == "EXPIRED_DATE" {
                        dateString = "expiredDate".localize()
                    } else {
                        dateString = "releaseDate".localize()
                    }
                    let temp = Bank(id: bank["id"] as! Int, cardNumberLength: bank["cardNumberLength"] as! Int,
                            cardPrefix: bank["cardPrefix"] as! String, enName: bank["enName"] as! String, viName: bank["viName"] as! String,
                            shortName: bank["shortName"] as! String, swiftCode: bank["swiftCode"] as! String,
                            isVietQr: bank["vietQRAccepted"] as? Bool ?? false,
                            requiredDateString: dateString
                    )
                    listBank.append(temp)
                }
            }
            if orderTransaction.paymentMethod?.type == MethodType.BANK_TRANSFER.rawValue {
                let vietQRBank: [Bank] = listBank.filter {
                    $0.isVietQr == true
                }
                self.getListBankManual(orderTransaction: orderTransaction, listSettingBank: vietQRBank)
            } else {
                self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.ATM, banks: listBank, orderTransaction: orderTransaction))
            }
        }, onError: { bankListError in
            self.onError(bankListError)
        }, onPaymeError: onPaymeError)
    }

    func getFee(orderTransaction: OrderTransaction) {
        let payment: [String: Any]? = {
            switch orderTransaction.paymentMethod?.type {
            case MethodType.WALLET.rawValue:
                return [
                    "wallet": [
                        "active": true
                    ]
                ]

            case MethodType.LINKED.rawValue:
                return [
                    "linked": [
                        "linkedId": orderTransaction.paymentMethod?.dataLinked?.linkedId ?? 0,
                        "envName": "MobileApp"
                    ]
                ]
            default: return nil
            }
        }()
        request.getFee(amount: orderTransaction.amount, payment: payment, onSuccess: { response in
            let data = JSON(response)
            if data["Utility"]["GetFee"]["succeeded"].boolValue {
                if let state = (response["Utility"]!["GetFee"] as? [String: AnyObject])?["state"] as? String {
                    if state == "OVER_DAY_QUOTA" || state == "OVER_MONTH_QUOTA" {
                        self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.ERROR,
                                error: ResponseError(code: ResponseErrorCode.OVER_QUOTA,
                                        message: (response["Utility"]!["GetFee"] as? [String: AnyObject])?["message"] as? String ??
                                                "overQuota".localize()
                                )))
                        return
                    }
                }
                self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.FEE, orderTransaction: orderTransaction))
            } else {
                self.onError(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject,
                              "message": (data["Utility"]["GetFee"]["message"].string ?? "hasError".localize()) as AnyObject])
                self.onPaymeError(data["Utility"]["GetFee"]["message"].string ?? "hasError".localize())
            }
        }, onError: { error in
            if let code = error["code"] as? Int {
                if (code == 401) {
                    self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.ERROR, error: ResponseError(code: ResponseErrorCode.EXPIRED)))
                }
            }
            self.onError(error)
        }, onPaymeError: onPaymeError)
    }

    func getTransactionInfo(
            transactionInfo: TransactionInformation, orderTransaction: OrderTransaction, isAcceptPending: Bool = false
    ) -> URLSessionDataTask? {
        request.getTransactionInfo(transaction: transactionInfo.transaction,
                onSuccess: { response in
                    let payment = response["OpenEWallet"]!["Payment"] as! [String: AnyObject]
                    if let transInfo = payment["GetTransactionInfo"] as? [String: AnyObject] {
                        let state = transInfo["state"] as? String ?? ""
                        let message = transInfo["message"] as? String
                        if let total: Int = transInfo["total"] as? Int {
                            orderTransaction.total = total
                        }
                        if let fee = transInfo["fee"] as? Int {
                            orderTransaction.paymentMethod?.fee = fee
                        }

                        let result: Result? = {
                            print("minh khoa")
                            print(state)
                            if state == "PENDING" {
                                if isAcceptPending {
                                    let responseError = ["code": PayME.ResponseCode.PAYMENT_PENDING as AnyObject] as [String: AnyObject]
                                    let textPending = "Cần thời gian thêm để xử lý. Vui lòng không thực hiện lại tránh bị trùng. Liên hệ CSKH để hỗ trợ 1900 88 66 65"
                                    return Result(type: ResultType.PENDING, failReasonLabel: textPending, orderTransaction: orderTransaction, transactionInfo: transactionInfo, extraData: responseError)
                                } else {
                                    return nil
                                }
                            } else if state == "SUCCEEDED" {
                                let responseSuccess = [
                                    "payment": ["transaction": transInfo["transaction"] as? String]
                                ] as [String: AnyObject]
                                return Result(type: ResultType.SUCCESS, orderTransaction: orderTransaction, transactionInfo: transactionInfo, extraData: responseSuccess)
                            } else {
                                let responseError = ["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject,
                                                     "message": (transInfo["reason"] as? String ?? "hasError".localize()) as AnyObject] as [String: AnyObject]
                                return Result(type: ResultType.FAIL, failReasonLabel: transInfo["reason"] as? String ?? "",
                                        orderTransaction: orderTransaction, transactionInfo: transactionInfo, extraData: responseError)
                            }
                        }()
                        if result != nil {
                            self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.RESULT, result: result))
                        }
                    }
                },
                onError: { error in
                    if let code = error["code"] as? Int {
                        if (code == 401) {
                            self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.ERROR, error: ResponseError(code: ResponseErrorCode.EXPIRED)))
                        }
                    }
                    self.onError(error)
                },
                onPaymeError: onPaymeError)
    }

    func getListBankManual(orderTransaction: OrderTransaction, listSettingBank: [Bank]) {
        request.getListBankManual(
                storeId: orderTransaction.storeId, orderId: orderTransaction.orderId, amount: orderTransaction.amount,
                onSuccess: { response in
                    guard let payInfo = (response["OpenEWallet"]!["Payment"] as? [String: AnyObject])?["Pay"]
                            as? [String: AnyObject] else {
                        self.onError(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": "hasError".localize() as AnyObject])
                        return
                    }
                    guard let isSucceed = payInfo["succeeded"] as? Bool else {
                        self.onError(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": (payInfo["message"] as? String ?? "hasError".localize()) as AnyObject])
                        return
                    }
                    if (isSucceed == false) {
                        if let message = payInfo["message"] as? String {
                            self.onError(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": message as AnyObject])
                            self.onPaymeError(message)
                        } else {
                            self.onError(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": "hasError".localize() as AnyObject])
                            self.onPaymeError("hasError".localize())
                        }
                        return
                    }
                    guard let payment = payInfo["payment"] as? [String: AnyObject] else {
                        if let message = payInfo["message"] as? String {
                            self.onError(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": message as AnyObject])
                            self.onPaymeError(message)
                        } else {
                            self.onError(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": "hasError".localize() as AnyObject])
                            self.onPaymeError("hasError".localize())
                        }
                        return
                    }
                    guard let bankList = payment["bankList"] as? [[String: AnyObject]] else {
                        self.onError(["code": PayME.ResponseCode.SYSTEM as AnyObject,
                                      "message": (payment["message"] as? String ?? "hasError".localize()) as AnyObject])
                        return
                    }
                    if bankList.count > 0 {
                        var listBank: [BankManual] = []
                        for bank in bankList {
                            listBank.append(BankManual(
                                    bankAccountName: bank["bankAccountName"] as? String ?? "",
                                    bankAccountNumber: bank["bankAccountNumber"] as? String ?? "",
                                    bankBranch: bank["bankBranch"] as? String ?? "",
                                    bankCity: bank["bankCity"] as? String ?? "",
                                    bankName: bank["bankName"] as? String ?? "",
                                    content: bank["content"] as? String ?? "",
                                    swiftCode: bank["swiftCode"] as? String ?? "",
                                    qrCode: bank["qrContent"] as? String ?? "",
                                    qrImage: bank["qrImage"] as? String ?? ""
                            ))
                        }
                        orderTransaction.paymentMethod?.dataBankTransfer = listBank[0]
                        self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.BANK_TRANSFER, banks: listSettingBank, listBankManual: listBank, orderTransaction: orderTransaction))
                    } else {
                        self.onPaymeError("")
                        PayME.currentVC!.dismiss(animated: true) {
                            self.onError(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": "manualBankNotFound".localize() as AnyObject])
                        }
                    }
                },
                onError: { error in
                    if let code = error["code"] as? Int {
                        if (code == 401) {
                            self.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.ERROR, error: ResponseError(code: ResponseErrorCode.EXPIRED)))
                        }
                    }
                    self.onError(error)
                },
                onPaymeError: onPaymeError
        )
    }
}