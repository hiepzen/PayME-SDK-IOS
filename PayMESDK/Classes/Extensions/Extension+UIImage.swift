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

extension UIImageView {
    func load(url: String) {
        let tempUrl = URL(string: url)
        DispatchQueue.global().async { [weak self] in
            if let unwrappedUrl = tempUrl as? URL {
                if let data = try? Data(contentsOf: unwrappedUrl) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.image = image
                        }
                    }
                }
            }

        }
    }
}
