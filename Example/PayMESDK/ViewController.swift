//
//  ViewController.swift
//  PayMESDK
//
//  Created by HuyOpen on 10/19/2020.
//  Copyright (c) 2020 HuyOpen. All rights reserved.
//

import UIKit
import PayMESDK

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var payME : PayME?
    var activeTextField : UITextField? = nil
    let envData : Dictionary = ["dev": PayME.Env.DEV, "sandbox": PayME.Env.SANDBOX, "production": PayME.Env.PRODUCTION]
    
    let environment: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(16)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Environment"
        return label
    }()
    let dropDown: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.setTitleColor(UIColor.black, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let envList: UIPickerView = {
        let list = UIPickerView()
        list.layer.borderColor = UIColor.black.cgColor
        list.layer.borderWidth = 0.5
        list.backgroundColor = .white
        list.translatesAutoresizingMaskIntoConstraints = false
        return list
    }()
    let settingButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "setting.svg"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let userIDLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(16)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "UserID"
        return label
    }()
    let userIDTextField: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setLeftPaddingPoints(10)
        textField.keyboardType = .numberPad
        return textField
    }()
    
    let phoneLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(16)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Phone number"
        return label
    }()
    let phoneTextField: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setLeftPaddingPoints(10)
        textField.keyboardType = .numberPad
        return textField
    }()
    
    let loginButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 15
        button.setTitle("Login", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let logoutButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 15
        button.setTitle("Logout", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let sdkContainer: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor.lightGray
        container.isHidden = true
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    let balance: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(14)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Balance"
        return label
    }()
    let priceLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(16)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0"
        return label
    }()
    let refreshButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "refresh.png"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let openWalletButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.white
        button.setTitle("Open Wallet", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let depositButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.white
        button.setTitle("Nạp tiền ví", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let moneyDeposit: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.backgroundColor = UIColor.white
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Nhập số tiền"
        textField.text = "10000"
        textField.setLeftPaddingPoints(10)
        textField.keyboardType = .numberPad
        return textField
    }()
    
    let withDrawButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.white
        button.setTitle("Rút tiền ví", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let moneyWithDraw: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.backgroundColor = UIColor.white
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Nhập số tiền"
        textField.text = "10000"
        textField.setLeftPaddingPoints(10)
        textField.keyboardType = .numberPad
        return textField
    }()
    
    let payButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.white
        button.setTitle("Thanh toán", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let moneyPay: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.backgroundColor = UIColor.white
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Nhập số tiền"
        textField.text = "10000"
        textField.setLeftPaddingPoints(10)
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private let PUBLIC_KEY: String = "MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAKWcehEELB4GdQ4cTLLQroLqnD3AhdKi\nwIhTJpAi1XnbfOSrW/Ebw6h1485GOAvuG/OwB+ScsfPJBoNJeNFU6J0CAwEAAQ=="
    private let PRIVATE_KEY: String = "MIIBPAIBAAJBAKWcehEELB4GdQ4cTLLQroLqnD3AhdKiwIhTJpAi1XnbfOSrW/Eb\nw6h1485GOAvuG/OwB+ScsfPJBoNJeNFU6J0CAwEAAQJBAJSfTrSCqAzyAo59Ox+m\nQ1ZdsYWBhxc2084DwTHM8QN/TZiyF4fbVYtjvyhG8ydJ37CiG7d9FY1smvNG3iDC\ndwECIQDygv2UOuR1ifLTDo4YxOs2cK3+dAUy6s54mSuGwUeo4QIhAK7SiYDyGwGo\nCwqjOdgOsQkJTGoUkDs8MST0MtmPAAs9AiEAjLT1/nBhJ9V/X3f9eF+g/bhJK+8T\nKSTV4WE1wP0Z3+ECIA9E3DWi77DpWG2JbBfu0I+VfFMXkLFbxH8RxQ8zajGRAiEA\n8Ly1xJ7UW3up25h9aa9SILBpGqWtJlNQgfVKBoabzsU="
    private let APP_ID: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6MX0.wNtHVZ-olKe7OAkgLigkTSsLVQKv_YL9fHKzX9mn9II"
    private var connectToken: String = ""
    private var currentEnv: PayME.Env = PayME.Env.DEV
    
    // generate token ( demo, don't apply this to your code, generate from your server)
    @objc func submit(sender: UIButton!) {
        //PayME.showKYCCamera(currentVC: self)
        if (userIDTextField.text != "") {
            if (self.currentEnv == PayME.Env.PRODUCTION) {
                let alert = UIAlertController(title: "Lỗi", message: "Chưa hỗ trợ môi trường này!", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
            self.setConnectToken(token: PayME.genConnectToken(userId: userIDTextField.text!, phone: phoneTextField.text!))
            self.payME = PayME(
                appID: UserDefaults.standard.string(forKey: "appToken") ?? "",
                publicKey: UserDefaults.standard.string(forKey: "publicKey") ?? "",
                connectToken: self.connectToken,
                appPrivateKey: UserDefaults.standard.string(forKey: "secretKey") ?? "",
                env: self.currentEnv,
                configColor: ["#75255b", "#a81308"])
            
            let alert = UIAlertController(title: "Success", message: "Tạo token thành công", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.loginButton.backgroundColor = UIColor.gray
            self.logoutButton.backgroundColor = UIColor.white
            }
        } else {
           let alert = UIAlertController(title: "Success", message: "Vui lòng nhập userID", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func setConnectToken(token: String!) {
        self.connectToken = token
        UserDefaults.standard.set(token, forKey: "connectToken")
        if (token == ""){
            self.sdkContainer.isHidden = true
            self.userIDTextField.isEnabled = true
            self.phoneTextField.isEnabled = true
        } else {
            UserDefaults.standard.set(self.userIDTextField.text, forKey: "userID")
            UserDefaults.standard.set(self.phoneTextField.text, forKey: "phone")
            self.sdkContainer.isHidden = false
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return envData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(envData.keys)[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       setEnv(env: envData[Array(envData.keys)[row]], text: Array(envData.keys)[row])
        pickerView.isHidden = true
    }
    
    @objc func logout(sender: UIButton!) {
        self.setConnectToken(token: "")
        UserDefaults.standard.set("", forKey: "userID")
        UserDefaults.standard.set("", forKey: "phone")
        self.loginButton.backgroundColor = UIColor.white
        self.logoutButton.backgroundColor = UIColor.gray
    }
    

    @objc func openWalletAction(sender: UIButton!) {
        if (self.connectToken != "") {
            payME!.openWallet(currentVC: self, action: PayME.Action.OPEN, amount: nil, description: nil, extraData: nil, onSuccess: {a in }, onError: {a in print(a)})
        } else {
            let alert = UIAlertController(title: "Lỗi", message: "Vui lòng tạo connect token trước", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @objc func depositAction(sender: UIButton!) {
        if (self.connectToken != "") {
            if (moneyDeposit.text != "") {
                let amount = Int(moneyDeposit.text!)
                if (amount! >= 10000){
                    let amountDeposit = amount!
                    self.payME!.deposit(currentVC: self, amount: amountDeposit, description: "", extraData: nil, onSuccess: {a in print(a)}, onError: {a in print(a)})

                } else {
                    let alert = UIAlertController(title: "Lỗi", message: "Vui lòng nạp hơn 10.000VND", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "Lỗi", message: "Vui lòng nạp hơn 10.000VND", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Lỗi", message: "Vui lòng tạo connect token trước", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func withDrawAction(sender: UIButton!) {
        if (self.connectToken != "") {
            if (moneyWithDraw.text != "") {
                let amount = Int(moneyWithDraw.text!)
                if (amount! >= 10000){
                    let amountWithDraw = amount!
                    self.payME!.withdraw(currentVC: self, amount: amountWithDraw, description: "", extraData: nil, onSuccess: {a in print(a)}, onError: {a in print(a)})
                } else {
                    let alert = UIAlertController(title: "Lỗi", message: "Vui lòng rút hơn 10.000VND", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "Lỗi", message: "Vui lòng rút hơn 10.000VND", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Lỗi", message: "Vui lòng tạo connect token trước", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    @objc func payAction(sender: UIButton!) {
        if (self.connectToken != "") {
            if (moneyPay.text != "") {
                let amount = Int(moneyPay.text!)
                if (amount! >= 10000){
                    let amountPay = amount!
                    self.payME!.pay(currentVC: self, storeId: 1, orderId: 1, amount: amountPay, note : "Nội dung đơn hàng" , extraData: nil, onSuccess: {success in}, onError: {error in
                        let message = error["message"] as? String
                        let alert = UIAlertController(title: "Lỗi", message: message ?? "Có lỗi xảy ra", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    )
                } else {
                    let alert = UIAlertController(title: "Lỗi", message: "Vui lòng thanh toán hơn 10.000VND", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "Lỗi", message: "Vui lòng thanh toán hơn 10.000VND", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            
        } else {
            let alert = UIAlertController(title: "Lỗi", message: "Vui lòng tạo connect token trước", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func getBalance(_ sender: Any) {
        if (self.connectToken != "") {
            PayME.getWalletInfo(onSuccess: {a in
                print(a)
                var str = ""
                if let v = a["Wallet"]!["balance"]! {
                   str = "\(v)"
                }
                let alert = UIAlertController(title: "Thành công", message: "Lấy balance thành công", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: {
                    self.priceLabel.text = str
                })
            }, onError: {error in
                print(error)
                let message = error["message"] as? String
                let alert = UIAlertController(title: "Lỗi", message: message ?? "Có lỗi xảy ra", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.priceLabel.text = "0"
                self.present(alert, animated: true, completion: nil)
            })
        }
        else {
            let alert = UIAlertController(title: "Lỗi", message: "Vui lòng tạo connect token trước", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //For mobile numer validation
        if textField == phoneTextField || textField == moneyDeposit || textField == moneyWithDraw || textField == moneyPay {
            let allowedCharacters = CharacterSet(charactersIn:"+0123456789 ")//Here change this characters based on your requirement
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {

          // if keyboard size is not available for some reason, dont do anything
          return
        }

        var shouldMoveViewUp = false

        // if active text field is not nil
        if let activeTextField = activeTextField {

          let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: self.view).maxY;
          
          let topOfKeyboard = self.view.frame.height - keyboardSize.height

          // if the bottom of Textfield is below the top of keyboard, move up
          if bottomOfTextField > topOfKeyboard {
            shouldMoveViewUp = true
          }
        }

        if(shouldMoveViewUp) {
          self.view.frame.origin.y = 0 - keyboardSize.height
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
      // move back the root view origin to zero
      self.view.frame.origin.y = 0
    }
    
    @IBAction func onPressSetting(_ sender: UIButton){
        let vc =  SettingsView()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onPressDropDown(_ sender: UIButton){
        self.envList.isHidden = !self.envList.isHidden
    }
    
    func setEnv(env: PayME.Env!, text: String!){
        self.currentEnv = env
        UserDefaults.standard.set(text, forKey: "env")
        self.dropDown.setTitle(text, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appToken = UserDefaults.standard.string(forKey: "appToken") ?? ""
        if (appToken == ""){
            UserDefaults.standard.set(APP_ID, forKey: "appToken")
        }
        let secretKey = UserDefaults.standard.string(forKey: "secretKey") ?? ""
        if (secretKey == ""){
            UserDefaults.standard.set(PRIVATE_KEY, forKey: "secretKey")
        }
        let publicKey = UserDefaults.standard.string(forKey: "publicKey") ?? ""
        if (publicKey == ""){
            UserDefaults.standard.set(PUBLIC_KEY, forKey: "publicKey")
        }
        
        let connectToken = UserDefaults.standard.string(forKey: "connectToken") ?? ""
        if (connectToken != "") {
            self.setConnectToken(token: connectToken)
            self.loginButton.backgroundColor = UIColor.gray
            self.logoutButton.backgroundColor = UIColor.white
        } else {
            self.connectToken = ""
            self.loginButton.backgroundColor = UIColor.white
            self.logoutButton.backgroundColor = UIColor.gray
        }
        
        let env = UserDefaults.standard.string(forKey: "env") ?? ""
        if (env == ""){
            self.setEnv(env: PayME.Env.DEV, text: "dev")
        } else {
            envList.selectRow(Array(envData.keys).index(of: env)!, inComponent: 0, animated: true)
            self.setEnv(env: envData[env], text: env)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.view.addSubview(environment)
        self.view.addSubview(dropDown)
        self.view.addSubview(envList)
        self.view.addSubview(settingButton)
        self.view.addSubview(userIDLabel)
        self.view.addSubview(userIDTextField)
        self.view.addSubview(phoneLabel)
        self.view.addSubview(phoneTextField)
        self.view.addSubview(loginButton)
        self.view.addSubview(logoutButton)
        self.view.addSubview(sdkContainer)
        
        sdkContainer.addSubview(balance)
        sdkContainer.addSubview(priceLabel)
        sdkContainer.addSubview(refreshButton)
        sdkContainer.addSubview(openWalletButton)
        sdkContainer.addSubview(depositButton)
        sdkContainer.addSubview(moneyDeposit)
        sdkContainer.addSubview(withDrawButton)
        sdkContainer.addSubview(moneyWithDraw)
        sdkContainer.addSubview(payButton)
        sdkContainer.addSubview(moneyPay)
        
        self.view.bringSubview(toFront: envList)
        
        phoneTextField.delegate = self
        moneyDeposit.delegate = self
        moneyWithDraw.delegate = self
        moneyPay.delegate = self
        envList.delegate = self
        
        environment.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 10).isActive = true
        environment.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        
        dropDown.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 10).isActive = true
        dropDown.leadingAnchor.constraint(equalTo: environment.trailingAnchor, constant: 30).isActive = true
        dropDown.heightAnchor.constraint(equalToConstant: 30).isActive = true
        dropDown.widthAnchor.constraint(equalToConstant: 150).isActive = true
        dropDown.addTarget(self, action: #selector(onPressDropDown(_:)), for: .touchUpInside)
        
        envList.isHidden = true
        envList.topAnchor.constraint(equalTo: dropDown.bottomAnchor).isActive = true
        envList.centerXAnchor.constraint(equalTo: dropDown.centerXAnchor).isActive = true
        envList.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        
        settingButton.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 10).isActive = true
        settingButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
        settingButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        settingButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        settingButton.addTarget(self, action: #selector(onPressSetting(_:)), for: .touchUpInside)
        
        userIDLabel.topAnchor.constraint(equalTo: environment.bottomAnchor, constant: 20).isActive = true
        userIDLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        
        userIDTextField.topAnchor.constraint(equalTo: userIDLabel.bottomAnchor, constant: 5).isActive = true
        userIDTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        userIDTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
        userIDTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        userIDTextField.text = UserDefaults.standard.string(forKey: "userID") ?? ""
        
        
        phoneLabel.topAnchor.constraint(equalTo: userIDTextField.bottomAnchor, constant: 20).isActive = true
        phoneLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        
        phoneTextField.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 5).isActive = true
        phoneTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        phoneTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
        phoneTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        phoneTextField.text = UserDefaults.standard.string(forKey: "phone") ?? ""
        
        loginButton.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 20).isActive = true
        loginButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        loginButton.trailingAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -5).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loginButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
        
        logoutButton.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 20).isActive = true
        logoutButton.leadingAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 5).isActive = true
        logoutButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        
        sdkContainer.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20).isActive = true
        sdkContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        sdkContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
        sdkContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50).isActive = true
        
        balance.topAnchor.constraint(equalTo: sdkContainer.topAnchor, constant: 20).isActive = true
        balance.leadingAnchor.constraint(equalTo: sdkContainer.leadingAnchor, constant: 10).isActive = true
        
        refreshButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        refreshButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        refreshButton.topAnchor.constraint(equalTo: sdkContainer.topAnchor, constant: 20).isActive = true
        refreshButton.trailingAnchor.constraint(equalTo: sdkContainer.trailingAnchor, constant: -10).isActive = true
        refreshButton.addTarget(self, action: #selector(getBalance(_:)), for: .touchUpInside)
        
        priceLabel.topAnchor.constraint(equalTo: sdkContainer.topAnchor, constant: 20).isActive = true
        priceLabel.trailingAnchor.constraint(equalTo: refreshButton.leadingAnchor, constant: -30).isActive = true
        
        openWalletButton.topAnchor.constraint(equalTo: refreshButton.bottomAnchor, constant: 30).isActive = true
        openWalletButton.leadingAnchor.constraint(equalTo: sdkContainer.leadingAnchor, constant: 10).isActive = true
        openWalletButton.trailingAnchor.constraint(equalTo: sdkContainer.trailingAnchor, constant: -10).isActive = true
        openWalletButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        openWalletButton.addTarget(self, action: #selector(openWalletAction), for: .touchUpInside)
        
        depositButton.topAnchor.constraint(equalTo: openWalletButton.bottomAnchor, constant: 20).isActive = true
        depositButton.leadingAnchor.constraint(equalTo: sdkContainer.leadingAnchor, constant: 10).isActive = true
        depositButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        depositButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        depositButton.addTarget(self, action: #selector(depositAction), for: .touchUpInside)
        
        moneyDeposit.topAnchor.constraint(equalTo: openWalletButton.bottomAnchor, constant: 20).isActive = true
        moneyDeposit.leadingAnchor.constraint(equalTo: depositButton.trailingAnchor, constant: 10).isActive = true
        moneyDeposit.trailingAnchor.constraint(equalTo: sdkContainer.trailingAnchor, constant: -10).isActive = true
        moneyDeposit.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        withDrawButton.topAnchor.constraint(equalTo: depositButton.bottomAnchor, constant: 10).isActive = true
        withDrawButton.leadingAnchor.constraint(equalTo: sdkContainer.leadingAnchor, constant: 10).isActive = true
        withDrawButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        withDrawButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        withDrawButton.addTarget(self, action: #selector(withDrawAction), for: .touchUpInside)
        
        moneyWithDraw.topAnchor.constraint(equalTo: depositButton.bottomAnchor, constant: 10).isActive = true
        moneyWithDraw.leadingAnchor.constraint(equalTo: depositButton.trailingAnchor, constant: 10).isActive = true
        moneyWithDraw.trailingAnchor.constraint(equalTo: sdkContainer.trailingAnchor, constant: -10).isActive = true
        moneyWithDraw.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        
        payButton.topAnchor.constraint(equalTo: withDrawButton.bottomAnchor, constant: 10).isActive = true
        payButton.leadingAnchor.constraint(equalTo: sdkContainer.leadingAnchor, constant: 10).isActive = true
        payButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        payButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        payButton.addTarget(self, action: #selector(payAction), for: .touchUpInside)
        
        moneyPay.topAnchor.constraint(equalTo: withDrawButton.bottomAnchor, constant: 10).isActive = true
        moneyPay.leadingAnchor.constraint(equalTo: depositButton.trailingAnchor, constant: 10).isActive = true
        moneyPay.trailingAnchor.constraint(equalTo: sdkContainer.trailingAnchor, constant: -10).isActive = true
        moneyPay.heightAnchor.constraint(equalToConstant: 30).isActive = true

        
    }
    
}
extension ViewController : UITextFieldDelegate {
  // when user select a textfield, this method will be called
  func textFieldDidBeginEditing(_ textField: UITextField) {
    // set the activeTextField to the selected textfield
    self.activeTextField = textField
  }
    
  // when user click 'done' or dismiss the keyboard
  func textFieldDidEndEditing(_ textField: UITextField) {
    self.activeTextField = nil
  }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
