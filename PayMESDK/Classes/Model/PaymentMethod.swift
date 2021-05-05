//
//  UserInfo.swift
//  PayMESDK
//
//  Created by HuyOpen on 9/29/20.
//  Copyright © 2020 PayME. All rights reserved.
//

import Foundation

class PaymentMethod {
    internal var methodId: Int!
    internal var type: String = ""
    internal var title: String = ""
    internal var label: String = ""
    internal var fee: Int!
    internal var minFee: Int!
    internal var amount: Int?
    internal var dataWallet: WalletInformation?
    internal var dataLinked: LinkedInformation?
    internal var active: Bool!

    init(
        methodId: Int?,
        type: String,
        title: String,
        label: String,
        amount: Int?,
        fee: Int,
        minFee: Int,
        dataWallet: WalletInformation?,
        dataLinked: LinkedInformation?,
        active: Bool
    ) {
        self.methodId = methodId
        self.type = type
        self.title = title
        self.label = label
        self.amount = amount
        self.fee = fee
        self.minFee = minFee
        self.dataWallet = dataWallet
        self.dataLinked = dataLinked
        self.active = active
    }
}

