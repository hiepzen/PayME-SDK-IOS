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
    
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var priceBalance: UILabel!
    
    private let PUBLIC_KEY: String = "MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAKWcehEELB4GdQ4cTLLQroLqnD3AhdKi\nwIhTJpAi1XnbfOSrW/Ebw6h1485GOAvuG/OwB+ScsfPJBoNJeNFU6J0CAwEAAQ==\n"
    private let PRIVATE_KEY: String = "MIIBPAIBAAJBAKWcehEELB4GdQ4cTLLQroLqnD3AhdKiwIhTJpAi1XnbfOSrW/Eb\nw6h1485GOAvuG/OwB+ScsfPJBoNJeNFU6J0CAwEAAQJBAJSfTrSCqAzyAo59Ox+m\nQ1ZdsYWBhxc2084DwTHM8QN/TZiyF4fbVYtjvyhG8ydJ37CiG7d9FY1smvNG3iDC\ndwECIQDygv2UOuR1ifLTDo4YxOs2cK3+dAUy6s54mSuGwUeo4QIhAK7SiYDyGwGo\nCwqjOdgOsQkJTGoUkDs8MST0MtmPAAs9AiEAjLT1/nBhJ9V/X3f9eF+g/bhJK+8T\nKSTV4WE1wP0Z3+ECIA9E3DWi77DpWG2JbBfu0I+VfFMXkLFbxH8RxQ8zajGRAiEA\n8Ly1xJ7UW3up25h9aa9SILBpGqWtJlNQgfVKBoabzsU=\n"
    public let connectToken: String = "U2FsdGVkX1/aYKFSjbcpgUnuVNany+LToWbLZ1CkTUktDjDoN5pFYMtfxG9l5lBmlQkekaQpyyfzhgm8DgYEif0rS6PyXgATxgminv6s41bZpSDdmXqO9ukKYCwB6Qg4nz+bae77RZROkM89SAmBGA=="
    
    @IBAction func getBalance(_ sender: Any) {
        var payME = PayME(appID: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6MX0.wNtHVZ-olKe7OAkgLigkTSsLVQKv_YL9fHKzX9mn9II", publicKey: PUBLIC_KEY, connectToken: self.connectToken, appPrivateKey: PRIVATE_KEY, env:"sandbox", configColor: ["#75255b"])
        payME.getWalletInfo(onSuccess: {a in
            var str = ""
            if let v = a["walletBalance"]!["balance"]! {
               str = "\(v)"
            }
            self.priceBalance.text = str

        }, onError: {a in})
    }
    @IBAction func click(_ sender: Any) {
        var payME = PayME(appID: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6MX0.wNtHVZ-olKe7OAkgLigkTSsLVQKv_YL9fHKzX9mn9II", publicKey: PUBLIC_KEY, connectToken: self.connectToken, appPrivateKey: PRIVATE_KEY, env:"sandbox", configColor: ["#75255b"])
        //payME.openCamera(currentVC: self)
        //payME.showModal(currentVC: self)
        //payME.openWallet(currentVC: self, action: "OPEN", amount: nil, description: nil, extraData: nil, onSuccess: {a in }, onError: {a in})
    }
    
    @IBAction func test(_ sender: Any) {
        var payME = PayME(appID: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6MX0.wNtHVZ-olKe7OAkgLigkTSsLVQKv_YL9fHKzX9mn9II", publicKey: PUBLIC_KEY, connectToken: self.connectToken, appPrivateKey: PRIVATE_KEY, env:"sandbox", configColor: ["#75255b"])
        /*
        payME.goToTest(currentVC: self, amount: 10, description: "ABC", extraData: nil, onSuccess: {a in print(a)}, onError: {a in})
        */
        //payME.pay(currentVC: self, amount: 10000 , description: "Tui la tran quang huy, la vi vua cuoi cung cua nha tran")
        //payME.pay(currentVC: self, amount: 2500000, description: "")
        payME.openQRCode(currentVC: self)
    }
    @IBAction func deposit(_ sender: Any) {
        var payME = PayME(appID: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6MX0.wNtHVZ-olKe7OAkgLigkTSsLVQKv_YL9fHKzX9mn9II", publicKey: PUBLIC_KEY, connectToken: self.connectToken, appPrivateKey: PRIVATE_KEY, env:"sandbox", configColor: ["#75255b"])
        payME.deposit(currentVC: self, amount: 10, description: "ABC", extraData: nil, onSuccess: {a in print(a)}, onError: {a in print(a)})
    }
    
    @IBAction func withdraw(_ sender: Any) {
        var payME = PayME(appID: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6MX0.wNtHVZ-olKe7OAkgLigkTSsLVQKv_YL9fHKzX9mn9II", publicKey: PUBLIC_KEY, connectToken: self.connectToken, appPrivateKey: PRIVATE_KEY, env:"sandbox", configColor: ["#75255b"])
        payME.withdraw(currentVC: self, amount: 10, description: "ABC", extraData: nil, onSuccess: {a in print(a)}, onError: {a in print(a)})
    }
    override func viewDidLoad() {
        super.viewDidLoad()


        // Do any additional setup after loading the view.
        
    }
}

