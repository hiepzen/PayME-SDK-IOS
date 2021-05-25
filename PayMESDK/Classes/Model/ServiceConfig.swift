//
//  ServiceConfig.swift
//  PayMESDK
//
//  Created by Minh Khoa on 3/10/21.
//

import Foundation

public class ServiceConfig {
    internal var code: String = ""
    internal var description: String = ""

    public init(_ code: String, _ description: String) {
        self.code = code
        self.description = description
    }
    public func getCode() -> String {
        code
    }
    public func getDescription() -> String {
        description
    }
}
