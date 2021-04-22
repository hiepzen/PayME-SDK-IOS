//
//  LinkedMethodInfo.swift
//  PayMESDK
//
//  Created by HuyOpen on 1/11/21.
//

import Foundation

public class LinkedMethodInfo : Codable {
    internal var swiftCode: String!
    internal var linkedId: Int!
    
    public init(swiftCode : String, linkedId: Int) {
        self.swiftCode = swiftCode
        self.linkedId = linkedId
    }
}
