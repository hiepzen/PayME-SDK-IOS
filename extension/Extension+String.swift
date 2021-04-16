//
//  Extension+String.swift
//  Pods
//
//  Created by Minh Khoa on 4/16/21.
//
//

import Foundation

extension String {
    var fixedBase64Format: Self {
        let offset = count % 4
        guard offset != 0 else {
            return self
        }
        return padding(toLength: count + 4 - offset, withPad: "=", startingAt: 0)
    }

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: fixedBase64Format) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

    func stringByReplacingFirstOccurrenceOfString(target: String, withString replaceString: String) -> String {
        if let range = self.range(of: target) {
            return self.replacingCharacters(in: range, with: replaceString)
        }
        return self
    }

    func replaceAll(target: String, withString: String) -> String {
        let regex = try! NSRegularExpression(pattern: target, options: NSRegularExpression.Options.caseInsensitive)
        let range = NSMakeRange(0, self.count)
        let modString = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: withString)
        return modString
    }
}