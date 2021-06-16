//
//  ResultViewModel.swift
//  PayMESDK
//
//  Created by Minh Khoa on 4/28/21.
//

import Foundation
import RxSwift

enum State {
    case METHODS
    case ATM
    case BANK_TRANSFER
    case CONFIRMATION
    case VALIDATION
    case RESULT
    case ERROR
    case BANK_SEARCH
    case BANK_TRANS_RESULT
}

struct PaymentState {
    let state: State
    let methods: [PaymentMethod]?
    let banks: [Bank]?
    let listBankManual: [BankManual]?
    let orderTransaction: OrderTransaction?
    let result: Result?
    let bankTransferState: ResultType?
    let error: ResponseError?

    init(state: State,
         methods: [PaymentMethod]? = nil,
         banks: [Bank]? = nil,
         listBankManual: [BankManual]? = nil,
         orderTransaction: OrderTransaction? = nil,
         result: Result? = nil,
         bankTransferState: ResultType? = nil,
         error: ResponseError? = nil) {
        self.state = state
        self.methods = methods
        self.listBankManual = listBankManual
        self.banks = banks
        self.orderTransaction = orderTransaction
        self.result = result
        self.error = error
        self.bankTransferState = bankTransferState
    }
}

class PaymentViewModel {
    let paymentSubject: PublishSubject<PaymentState> = PublishSubject()
}