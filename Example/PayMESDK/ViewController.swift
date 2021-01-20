//
//  ViewController.swift
//  PayMESDK
//
//  Created by HuyOpen on 10/19/2020.
//  Copyright (c) 2020 HuyOpen. All rights reserved.
//

import UIKit
import PayMESDK
import CryptoSwift

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var floatingButtonController: FloatingButtonController = FloatingButtonController()
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
    

    private let PUBLIC_KEY: String =
    """
    -----BEGIN PUBLIC KEY-----
    MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAKWcehEELB4GdQ4cTLLQroLqnD3AhdKi
    wIhTJpAi1XnbfOSrW/Ebw6h1485GOAvuG/OwB+ScsfPJBoNJeNFU6J0CAwEAAQ==
    -----END PUBLIC KEY-----
    """
    
    private let PRIVATE_KEY: String =
    """
    -----BEGIN RSA PRIVATE KEY-----
    MIIBOwIBAAJBAOkNeYrZOhKTS6OcPEmbdRGDRgMHIpSpepulZJGwfg1IuRM+ZFBm
    F6NgzicQDNXLtaO5DNjVw1o29BFoK0I6+sMCAwEAAQJAVCsGq2vaulyyI6vIZjkb
    5bBId8164r/2xQHNuYRJchgSJahHGk46ukgBdUKX9IEM6dAQcEUgQH+45ARSSDor
    mQIhAPt81zvT4oK1txaWEg7LRymY2YzB6PihjLPsQUo1DLf3AiEA7Tv005jvNbNC
    pRyXcfFIy70IHzVgUiwPORXQDqJhWJUCIQDeDiZR6k4n0eGe7NV3AKCOJyt4cMOP
    vb1qJOKlbmATkwIhALKSJfi8rpraY3kLa4fuGmCZ2qo7MFTKK29J1wGdAu99AiAQ
    dx6DtFyY8hoo0nuEC/BXQYPUjqpqgNOx33R4ANzm9w==
    -----END RSA PRIVATE KEY-----
    """
    
    private let SECRET_KEY: String = "zfQpwE6iHbOeAfgX"
        
    private let APP_TOKEN: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6Njg2OH0.JyIdhQEX_Lx9CXRH4iHM8DqamLrMQJk5rhbslNW4GzY"
    private var connectToken: String = ""
    private var currentEnv: PayME.Env = PayME.Env.DEV
    
    func genConnectToken(userId: String, phone: String) -> String {
        let secretKey = UserDefaults.standard.string(forKey: "secretKey") ?? ""
        Log.custom.push(title: "Secret key login", message: secretKey)
        let data : [String: Any] = ["timestamp": (Date().timeIntervalSince1970), "userId" : "\(userId)", "phone" : "\(phone)"]
        let params = try? JSONSerialization.data(withJSONObject: data)
        let aes = try? AES(key: Array(secretKey.utf8), blockMode: CBC(iv: [UInt8](repeating: 0, count: 16)), padding: .pkcs5)
        let dataEncrypted = try? aes!.encrypt(Array(String(data: params!, encoding: .utf8)!.utf8))
        print(dataEncrypted!.toBase64()!)
        return dataEncrypted!.toBase64()!
    }
    // generate token ( demo, don't apply this to your code, generate from your server)
    @objc func submit(sender: UIButton!) {
        //PayME.showKYCCamera(currentVC: self)
        // Getting
        if (userIDTextField.text != "") {
            if (self.currentEnv == PayME.Env.PRODUCTION) {
                let alert = UIAlertController(title: "Lỗi", message: "Chưa hỗ trợ môi trường này!", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                let newConnectToken = self.genConnectToken(userId: userIDTextField.text!, phone: phoneTextField.text!)
                Log.custom.push(title: "Connect Token Generator", message: newConnectToken)
                self.setConnectToken(token: newConnectToken)
                self.payME = PayME(
                    appToken: self.APP_TOKEN,
                    publicKey: self.PUBLIC_KEY,
                    connectToken: self.connectToken,
                    appPrivateKey: UserDefaults.standard.string(forKey: "privateKey") ?? "",
                    env: self.currentEnv,
                    configColor: ["#75255b", "#a81308"])
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
        self.logout(sender: logoutButton)
    }
    
    @objc func logout(sender: UIButton!) {
        self.setConnectToken(token: "")
        UserDefaults.standard.set("", forKey: "userID")
        UserDefaults.standard.set("", forKey: "phone")
        self.loginButton.backgroundColor = UIColor.white
        self.logoutButton.backgroundColor = UIColor.gray
        Log.custom.push(title: "Log out", message: "Success")
    }
    
    
    @objc func openWalletAction(sender: UIButton!) {
        if (self.connectToken != "") {
            payME!.openWallet(currentVC: self, action: PayME.Action.OPEN, amount: nil, description: nil, extraData: nil,
                              onSuccess: { success in
                                Log.custom.push(title: "Open wallet", message: success)
                              }, onError: {error in
                                Log.custom.push(title: "Open wallet", message: error)
                                let message = error["message"] as? String
                                self.toastMess(title: "Lỗi", value: message)
                              })
        } else {
            toastMess(title: "Lỗi", value: "Vui lòng tạo connect token trước")
        }
    }
    @objc func depositAction(sender: UIButton!) {
        if (self.connectToken != "") {
            if (moneyDeposit.text != "") {
                let amount = Int(moneyDeposit.text!)
                if (amount! >= 10000){
                    let amountDeposit = amount!
                    self.payME!.deposit(currentVC: self, amount: amountDeposit, description: "", extraData: nil, onSuccess: {success in
                        Log.custom.push(title: "deposit", message: success)
                    }, onError: {error in
                        Log.custom.push(title: "deposit", message: error)
                        let message = error["message"] as? String
                        self.toastMess(title: "Lỗi", value: message)
                    })
                    
                } else {
                    toastMess(title: "Lỗi", value: "Vui lòng nạp hơn 10.000VND")
                }
            } else {
                toastMess(title: "Lỗi", value: "Vui lòng nạp hơn 10.000VND")
                
            }
        } else {
            toastMess(title: "Lỗi", value: "Vui lòng tạo connect token trước")
            
        }
    }
    
    @objc func withDrawAction(sender: UIButton!) {
        if (self.connectToken != "") {
            if (moneyWithDraw.text != "") {
                let amount = Int(moneyWithDraw.text!)
                if (amount! >= 10000){
                    let amountWithDraw = amount!
                    self.payME!.withdraw(currentVC: self, amount: amountWithDraw, description: "", extraData: nil,
                                         onSuccess: {success in
                                            Log.custom.push(title: "withdraw", message: success)
                                            
                                         }, onError: {error in
                                            Log.custom.push(title: "withdraw", message: error)
                                            let message = error["message"] as? String
                                            self.toastMess(title: "Lỗi", value: message)
                                         })
                } else {
                    toastMess(title: "Lỗi", value: "Vui lòng rút hơn 10.000VND")
                }
            } else {
                toastMess(title: "Lỗi", value: "Vui lòng rút hơn 10.000VND")
                
            }
        } else {
            toastMess(title: "Lỗi", value: "Vui lòng tạo connect token trước")
            
        }
        
    }
    @objc func payAction(sender: UIButton!) {
        if (self.connectToken != "") {
            if (moneyPay.text != "") {
                let amount = Int(moneyPay.text!)
                if (amount! >= 10000){
                    let amountPay = amount!
                    payME!.pay(currentVC: self, storeId: 6868, orderId: String(Date().timeIntervalSince1970), amount: amountPay, note : "Nội dung đơn hàng" , extraData: nil, onSuccess: {success in
                        Log.custom.push(title: "pay", message: success)
                    }, onError: {error in
                        Log.custom.push(title: "pay", message: error)
                        let message = error["message"] as? String
                        self.toastMess(title: "Lỗi", value: message)
                    }
                    )
                } else {
                    toastMess(title: "Lỗi", value: "Vui lòng thanh toán hơn 10.000VND")
                }
            } else {
                toastMess(title: "Lỗi", value: "Vui lòng thanh toán hơn 10.000VND")
            }
            
            
        } else {
            toastMess(title: "Lỗi", value: "Vui lòng tạo connect token trước")
            
        }
    }
    
    @IBAction func getBalance(_ sender: Any) {
        if (self.connectToken != "") {
            PayME.getWalletInfo(onSuccess: {a in
                Log.custom.push(title: "get Wallet Info", message: a)
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
                Log.custom.push(title: "get Wallet Info", message: error)
                let message = error["message"] as? String
                self.priceLabel.text = "0"
                self.toastMess(title: "Lỗi", value: message)
                
            })
        }
        else {
            toastMess(title: "Lỗi", value: "Vui lòng tạo connect token trước")
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
        navigationController?.isNavigationBarHidden = false
        let isShowLog = UserDefaults.standard.bool(forKey: "isShowLog")
        if (isShowLog) {
            self.floatingButtonController.showWindow()
        } else {
            self.floatingButtonController.hideWindow()
        }
    }
    
    func toastMess(title: String, value: String?) {
        let alert = UIAlertController(title: title, message: value ?? "Có lỗi xảy ra", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
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
        
       
        let appToken = UserDefaults.standard.string(forKey: "appToken") ?? ""
        if (appToken == ""){
            UserDefaults.standard.set(APP_TOKEN, forKey: "appToken")
        }
        let privateKey = UserDefaults.standard.string(forKey: "privateKey") ?? ""
        if (privateKey == ""){
            UserDefaults.standard.set(PRIVATE_KEY, forKey: "privateKey")
        }
        let publicKey = UserDefaults.standard.string(forKey: "publicKey") ?? ""
        if (publicKey == ""){
            UserDefaults.standard.set(PUBLIC_KEY, forKey: "publicKey")
        }
        let secretKey = UserDefaults.standard.string(forKey: "secretKey") ?? ""
        if (secretKey == ""){
            UserDefaults.standard.set(SECRET_KEY, forKey: "secretKey")
        }
        
        let env = UserDefaults.standard.string(forKey: "env") ?? ""
        if (env == ""){
            self.setEnv(env: PayME.Env.DEV, text: "dev")
        } else {
            envList.selectRow(Array(envData.keys).index(of: env)!, inComponent: 0, animated: true)
            self.setEnv(env: envData[env], text: env)
        }
        
        let connectToken = UserDefaults.standard.string(forKey: "connectToken") ?? ""
        if (connectToken != "") {
            self.setConnectToken(token: connectToken)
            self.loginButton.backgroundColor = UIColor.gray
            self.logoutButton.backgroundColor = UIColor.white
            self.submit(sender: self.loginButton)
        } else {
            self.connectToken = ""
            self.loginButton.backgroundColor = UIColor.white
            self.logoutButton.backgroundColor = UIColor.gray
        }
        
       
        
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
