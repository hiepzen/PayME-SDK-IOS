//
//  ResultViewModel.swift
//  PayMESDK
//
//  Created by Minh Khoa on 4/28/21.
//

import Foundation
import RxSwift

class ResultViewModel {
    public let resultSubject : PublishSubject<Result> = PublishSubject()

    public func setResult(result: Result) {
        resultSubject.onNext(result)
    }
}