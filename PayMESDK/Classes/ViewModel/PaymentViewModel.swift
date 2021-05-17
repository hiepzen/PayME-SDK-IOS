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
    case CONFIRMATION
    case VALIDATION
    case RESULT
}

struct PaymentState {
    let state: State
    let methods: [PaymentMethod]?
    let orderTransaction: OrderTransaction?
    let result: Result?

    init(state: State, methods: [PaymentMethod]? = nil, orderTransaction: OrderTransaction? = nil, result: Result? = nil) {
        self.state = state
        self.methods = methods
        self.orderTransaction = orderTransaction
        self.result = result
    }
}

class PaymentViewModel {
    let paymentSubject: PublishSubject<PaymentState> = PublishSubject()
}