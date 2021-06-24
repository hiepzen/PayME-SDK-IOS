//
//  Extension+String.swift
//  PayMESDK
//
//  Created by Minh Khoa on 24/06/2021.
//

import Foundation

extension String {
    func localize() -> String {
        let bundle = Bundle(for: PayME.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let path = resourceBundle?.path(forResource: PayMEFunction.language, ofType: "lproj")
        let bundleLocalize = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundleLocalize!, value: "", comment: "")
    }
}