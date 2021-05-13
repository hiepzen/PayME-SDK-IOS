//
//  PaymentPresentation.swift
//  PayMESDK
//
//  Created by Minh Khoa on 5/13/21.
//

import Foundation

class PaymentPresentation {
    private let resultViewModel: ResultViewModel
    private let request: API

    init(request: API, resultViewModel: ResultViewModel) {
        self.request = request
        self.resultViewModel = resultViewModel
    }


}