//
//  ViewController.swift
//  PayMESDK
//
//  Created by HuyOpen on 10/19/2020.
//  Copyright (c) 2020 HuyOpen. All rights reserved.
//

import UIKit
import PayMESDK
import WebKit

class ViewController: UIViewController {
    private let PUBLIC_KEY: String = "MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAKWcehEELB4GdQ4cTLLQroLqnD3AhdKi\nwIhTJpAi1XnbfOSrW/Ebw6h1485GOAvuG/OwB+ScsfPJBoNJeNFU6J0CAwEAAQ==\n"
    private let PRIVATE_KEY: String = "MIIBPAIBAAJBAKWcehEELB4GdQ4cTLLQroLqnD3AhdKiwIhTJpAi1XnbfOSrW/Eb\nw6h1485GOAvuG/OwB+ScsfPJBoNJeNFU6J0CAwEAAQJBAJSfTrSCqAzyAo59Ox+m\nQ1ZdsYWBhxc2084DwTHM8QN/TZiyF4fbVYtjvyhG8ydJ37CiG7d9FY1smvNG3iDC\ndwECIQDygv2UOuR1ifLTDo4YxOs2cK3+dAUy6s54mSuGwUeo4QIhAK7SiYDyGwGo\nCwqjOdgOsQkJTGoUkDs8MST0MtmPAAs9AiEAjLT1/nBhJ9V/X3f9eF+g/bhJK+8T\nKSTV4WE1wP0Z3+ECIA9E3DWi77DpWG2JbBfu0I+VfFMXkLFbxH8RxQ8zajGRAiEA\n8Ly1xJ7UW3up25h9aa9SILBpGqWtJlNQgfVKBoabzsU=\n"
    @IBAction func click(_ sender: Any) {
        print("abc")
        var payME = PayME(appID: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6MX0.wNtHVZ-olKe7OAkgLigkTSsLVQKv_YL9fHKzX9mn9II", publicKey: PUBLIC_KEY, connectToken: "U2FsdGVkX1+0GEZ1n1pGQzYdSFjrqXQa8Ys8syosEEgBycvgRbZ/5ZJLxCtrDfzrqMr0ot1TfYWOAQhTLytC21fYVoydyaWponQoGOQMOVEqhkldTiQS7xUV2VrogtXou0WEMSDieyICUsAZ3SE0wA==", appPrivateKey: PRIVATE_KEY, env:"sandbox", configColor: ["#75255b"])
        payME.openWallet(currentVC: self, action: "open", amount: nil, description: nil, extraData: nil, onSuccess: {a in }, onError: {a in})
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
}

