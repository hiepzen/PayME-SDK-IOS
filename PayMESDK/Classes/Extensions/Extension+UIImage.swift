//
//  Extension+UIImage.swift
//  PayMESDK
//
//  Created by Minh Khoa on 4/23/21.
//

import Foundation

extension UIImage {
    convenience init?(for aClass: AnyClass, named: String) {
        let bundle = Bundle(for: aClass)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        self.init(named: named, in: resourceBundle, compatibleWith: nil)
    }
}
