//
//  Methods.swift
//  PayMESDK
//
//  Created by HuyOpen on 10/28/20.
//

import UIKit
import CommonCrypto



class Methods: UINavigationController, PanModalPresentable, UITableViewDelegate,  UITableViewDataSource, KAPinFieldDelegate, UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //Format Date of Birth dd-MM-yyyy

        //initially identify your textfield

        if textField == atmView.dateField {

            // check the chars length dd -->2 at the same time calculate the dd-MM --> 5
            if (atmView.dateField.text?.count == 2) {
                //Handle backspace being pressed
                if !(string == "") {
                    // append the text
                    atmView.dateField.text = (atmView.dateField.text)! + "/"
                }
            }
            // check the condition not exceed 9 chars
            return !(textField.text!.count > 4 && (string.count ) > range.length)
        }
        else {
            if (atmView.cardNumberField.text!.count >= 5) {
                if !(string == "") {
                    print(string)
                    // append the text
                    let stringToCompare = (atmView.cardNumberField.text)! + string
                    for bank in listBank {
                        self.bankDetect = nil
                        if (stringToCompare.contains(bank.cardPrefix)) {
                            self.bankDetect = bank
                            //atmView.cardNumberField
                            print(bankDetect!.shortName)
                            break
                        }
                    }
                } else {
                    self.bankDetect = nil
                    
                }
            } else {
                self.bankDetect = nil

            }
            var detect = true
            if (bankDetect != nil) {
                if (textField.text!.count + 1 >= bankDetect!.cardNumberLength) {
                    print("Hello")
                    detect = false
                }
            }
            print(detect)
            
            

            return (detect) && textField.text!.count <= 19
        }
    }
    
    func pinField(_ field: KAPinField, didFinishWith code: String) {
        self.showSpinner(onView: self.view)
        if (field == securityCode.otpView) {
            API.createSecurityCode(password: sha256(string: code)!, onSuccess: {securityInfo in
                let account = securityInfo["Account"]!["SecurityCode"] as! [String:AnyObject]
                let securityResponse = account["CreateCodeByPassword"] as! [String:AnyObject]
                let securtiySucceeded = securityResponse ["succeeded"] as! Bool
                if (securtiySucceeded == true) {
                    let securityCode = securityResponse["securityCode"] as! String
                    API.transferWallet(storeId: 1, orderId: 1, securityCode: securityCode, extraData: "", note: PayME.description, onSuccess: { response in
                        let paymentInfo = response["OpenEWallet"]!["Payment"] as! [String:AnyObject]
                        let payInfo = paymentInfo["Pay"] as! [String:AnyObject]
                        let message = payInfo["message"] as! String
                        let succeeded = payInfo["succeeded"] as! Bool
                        if (succeeded == true) {
                            DispatchQueue.main.async {
                                self.securityCode.removeFromSuperview()
                                self.setupSuccess()
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.securityCode.removeFromSuperview()
                                self.setupFail()
                                self.failView.failLabel.text = message
                            }
                        }
                        self.removeSpinner()
                        
                    }, onError: { error in
                        self.removeSpinner()
                        self.dismiss(animated: true, completion: {
                            toastMess(title: "Lỗi", message: error["message"] as! String)
                        })
                    })
                } else {
                    self.removeSpinner()
                    let message = securityResponse ["message"] as! String
                    if (message == "Mật khẩu không chính xác") {
                        let alert = UIAlertController(title: "Lỗi", message: message, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: {
                            self.securityCode.otpView.text = ""
                            self.securityCode.otpView.reloadAppearance()

                        })
                    } else {
                        self.securityCode.removeFromSuperview()
                        self.setupFail()
                        self.failView.failLabel.text = message
                    }
                    
                }
                
            }, onError: {errorSecurity in
                self.removeSpinner()
                self.dismiss(animated: true, completion: {
                    toastMess(title: "Lỗi", message: errorSecurity["message"] as! String)
                })
            })
        } else if(field == otpView.otpView) {
            API.transferByLinkedBank(transaction: transaction, storeId: storeId, orderId: orderId, linkedId: (data[active!].dataLinked?.linkedId)!, extraData: "", note: PayME.description, otp: code, onSuccess: { response in
                let paymentInfo = response["OpenEWallet"]!["Payment"] as! [String:AnyObject]
                let payInfo = paymentInfo["Pay"] as! [String:AnyObject]
                let message = payInfo["message"] as! String
                let succeeded = payInfo["succeeded"] as! Bool
                if (succeeded == true) {
                    DispatchQueue.main.async {
                        self.otpView.removeFromSuperview()
                        self.setupSuccess()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.otpView.removeFromSuperview()
                        self.setupFail()
                        self.failView.failLabel.text = message
                    }
                }
                self.removeSpinner()
            }, onError: { error in
                self.removeSpinner()
                self.dismiss(animated: true, completion: {
                    toastMess(title: "Lỗi", message: error["message"] as! String)
                })
            })
        }
    }
    
    var data : [MethodInfo] = []
    var storeId : Int = 1
    var orderId : Int = 193
    var transaction : String = ""
    private var active : Int?
    private var bankDetect : Bank?
    
    let methodsView : UIView = {
        let methodsView  = UIView()
        methodsView.translatesAutoresizingMaskIntoConstraints = false
        return methodsView
    }()
    var listBank : [Bank] = []
    let atmView = ATMView()
    let otpView = OTPView()
    let securityCode = SecurityCode()
    let successView = SuccessView()
    let failView = FailView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(methodsView)
        setupMethods()
    }
    
    func setupOTP() {
        view.addSubview(otpView)
        otpView.translatesAutoresizingMaskIntoConstraints = false
        otpView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        otpView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        otpView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        otpView.heightAnchor.constraint(equalTo: self.view.heightAnchor, constant: 0).isActive = true
        otpView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: 0).isActive = true
        otpView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        otpView.closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: otpView.otpView.bottomAnchor, constant: 10).isActive = true
        self.updateViewConstraints()
        self.view.layoutIfNeeded()
        self.panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .shortForm)
        NotificationCenter.default.addObserver(self, selector: #selector(Methods.keyboardWillShowOtp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Methods.keyboardWillHideOtp), name: UIResponder.keyboardWillHideNotification, object: nil)
        otpView.otpView.properties.delegate = self
        otpView.otpView.becomeFirstResponder()
    }
    
    func setupSecurity() {
        view.addSubview(securityCode)
        securityCode.translatesAutoresizingMaskIntoConstraints = false
        securityCode.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        securityCode.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        securityCode.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        securityCode.heightAnchor.constraint(equalTo: self.view.heightAnchor, constant: 0).isActive = true
        securityCode.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: 0).isActive = true
        securityCode.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        securityCode.closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: securityCode.otpView.bottomAnchor, constant: 10).isActive = true
        self.updateViewConstraints()
        self.view.layoutIfNeeded()
        self.panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .shortForm)
        NotificationCenter.default.addObserver(self, selector: #selector(Methods.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Methods.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        securityCode.otpView.properties.delegate = self
        securityCode.otpView.becomeFirstResponder()
    }
    
    func setupFail() {
        view.addSubview(failView)
        failView.translatesAutoresizingMaskIntoConstraints = false
        failView.isUserInteractionEnabled = true
        failView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        failView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        failView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        failView.heightAnchor.constraint(equalTo: self.view.heightAnchor, constant: 0).isActive = true
        failView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: 0).isActive = true
        failView.button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        failView.closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: failView.button.bottomAnchor, constant: 10).isActive = true
        self.updateViewConstraints()
        self.view.layoutIfNeeded()
        self.panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .shortForm)
    }
    
    func setupSuccess() {
        view.addSubview(successView)
        successView.translatesAutoresizingMaskIntoConstraints = false
        successView.isUserInteractionEnabled = true
        successView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        successView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        successView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        successView.heightAnchor.constraint(equalTo: self.view.heightAnchor, constant: 0).isActive = true
        successView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: 0).isActive = true
        successView.button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        successView.closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: successView.button.bottomAnchor, constant: 10).isActive = true
        self.updateViewConstraints()
        self.view.layoutIfNeeded()
        self.panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .shortForm)
        
    }
    
    func setupMethods() {
        methodsView.backgroundColor = .white
        methodsView.isUserInteractionEnabled = true
        methodsView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        methodsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        methodsView.heightAnchor.constraint(equalTo: self.view.heightAnchor, constant: 0).isActive = true
        methodsView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: 0).isActive = true
        
        methodsView.addSubview(closeButton)
        methodsView.addSubview(txtLabel)
        methodsView.addSubview(detailView)
        methodsView.addSubview(methodTitle)
        methodsView.addSubview(tableView)
        
        detailView.addSubview(price)
        detailView.backgroundColor = UIColor(8,148,31)
        detailView.addSubview(contentLabel)
        detailView.addSubview(memoLabel)
        txtLabel.text = "Xác nhận thanh toán"
        price.text = "\(formatMoney(input: PayME.amount)) đ"
        contentLabel.text = "Nội dung"
        if (PayME.description == "") {
            memoLabel.text = "Không có nội dung"
        } else {
            memoLabel.text = PayME.description
        }
        methodTitle.text = "Chọn nguồn thanh toán"
        tableView.register(Method.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
        detailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        detailView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        detailView.heightAnchor.constraint(equalToConstant: 118.0).isActive = true
        detailView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        detailView.topAnchor.constraint(equalTo: txtLabel.bottomAnchor, constant: 16.0).isActive = true
        
        price.topAnchor.constraint(equalTo: detailView.topAnchor, constant: 15).isActive = true
        price.centerXAnchor.constraint(equalTo: detailView.centerXAnchor).isActive = true
        
        contentLabel.bottomAnchor.constraint(equalTo: detailView.bottomAnchor, constant: -15).isActive = true
        contentLabel.leadingAnchor.constraint(equalTo: detailView.leadingAnchor, constant: 30).isActive = true
        contentLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .horizontal)
        contentLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        memoLabel.bottomAnchor.constraint(equalTo: detailView.bottomAnchor, constant: -15).isActive = true
        memoLabel.leadingAnchor.constraint(equalTo: contentLabel.trailingAnchor, constant: 30).isActive = true
        memoLabel.trailingAnchor.constraint(equalTo: detailView.trailingAnchor, constant: -30).isActive = true
        memoLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 250), for: .horizontal)
        memoLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        methodTitle.topAnchor.constraint(equalTo: detailView.bottomAnchor, constant: 10).isActive = true
        methodTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        
        txtLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 19).isActive = true
        txtLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        /*
        tableView.topAnchor.constraint(equalTo: methodTitle.topAnchor, constant: 10).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        */

        tableView.topAnchor.constraint(equalTo: methodTitle.bottomAnchor, constant: 10).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        tableView.alwaysBounceVertical = false

        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 19).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: tableView.bottomAnchor, constant: 10).isActive = true

        self.showSpinner(onView: PayME.currentVC!.view)
        PayME.getWalletInfo(
            onSuccess: {walletInfo in
                let wallet = walletInfo["Wallet"] as! [String:AnyObject]
                let balance = wallet["balance"] as! Int
                API.getTransferMethods(onSuccess: {response in
                           // Update UI
                    let methodsReponse = response["Utility"]!["GetPaymentMethod"] as! [String:AnyObject]
                    let items = methodsReponse["methods"] as! [[String:AnyObject]]
                    print(items)
                    var responseData : [MethodInfo] = []
                    for i in 0..<items.count {
                        let temp = MethodInfo(methodId: items[i]["methodId"] as! Int, type: items[i]["type"] as! String, title: items[i]["title"] as! String, label: items[i]["label"] as! String,  amount: nil, fee: items[i]["fee"] as! Int, minFee: items[i]["minFee"] as! Int, dataWallet: nil, dataLinked: nil, active: false)
                        if (i == 0) {
                           temp.active = true
                        }
                        if (temp.type == "WALLET"){
                            temp.amount = balance
                        }
                        if (!(items[i]["data"] is NSNull)) {
                            let data = items[i]["data"] as! [String:AnyObject]
                            let accountId = data["accountId"] as? Int
                            if (accountId != nil) {
                                let walletMethod = WalletMethodInfo(accountId: accountId!)
                                temp.dataWallet = walletMethod
                            } else {
                                let data = items[i]["data"] as! [String:AnyObject]
                                let swiftCode = data["swiftCode"] as! String
                                let linkedId = data["linkedId"] as! Int
                                let linkedMethod = LinkedMethodInfo(swiftCode: swiftCode, linkedId: linkedId)
                                temp.dataLinked = linkedMethod
                            }
                        }
                        responseData.append(temp)
                    }
                    DispatchQueue.main.async {
                        self.removeSpinner()
                        self.data = responseData
                        self.tableView.reloadData()
                        self.tableView.heightAnchor.constraint(equalToConstant: self.tableView.contentSize.height).isActive = true
                        self.tableView.alwaysBounceVertical = false
                        self.tableView.isScrollEnabled = false
                        self.view.layoutIfNeeded()
                        self.panModalSetNeedsLayoutUpdate()
                        self.panModalTransition(to: .shortForm)
                    }
            },onError: {error in
               self.removeSpinner()
               print(error)
           })
        }, onError: {error in
            self.removeSpinner()
            print(error)
        })
    }
    
    override func viewDidLayoutSubviews() {
        let topPoint = CGPoint(x: detailView.frame.minX+10, y: detailView.bounds.midY + 15)
        let bottomPoint = CGPoint(x: detailView.frame.maxX-10, y: detailView.bounds.midY + 15)
        detailView.createDashedLine(from: topPoint, to: bottomPoint, color: UIColor(203,203,203), strokeLength: 3, gapLength: 4, width: 0.5)
        button.applyGradient(colors: [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor], radius: 10)
        detailView.applyGradient(colors: [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor], radius: 0)
        successView.button.applyGradient(colors: [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor], radius: 10)
        failView.button.applyGradient(colors: [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor], radius: 10)
        
        atmView.detailView.createDashedLine(from: topPoint, to: bottomPoint, color: UIColor(203,203,203), strokeLength: 3, gapLength: 4, width: 0.5)
        atmView.detailView.applyGradient(colors: [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor], radius: 0)

        atmView.button.applyGradient(colors: [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor], radius: 10)

    }
    
    @objc
    func closeAction(button:UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (data[indexPath.row].type == "WALLET"){
            methodsView.removeFromSuperview()
            setupSecurity()
        }
        if (data[indexPath.row].type == "LINKED") {
            self.showSpinner(onView: self.view)
            API.checkFlowLinkedBank(storeId: self.storeId, orderId: self.orderId, linkedId: data[indexPath.row].dataLinked!.linkedId, extraData: "", note: PayME.description, onSuccess: { flow in
                let pay = flow["OpenEWallet"]!["Payment"] as! [String:AnyObject]
                let succeeded = pay["Pay"]!["succeeded"] as! Bool
                if (succeeded == true) {
                    self.removeSpinner()
                    self.methodsView.removeFromSuperview()
                    self.setupSuccess()
                } else {
                    let payment = pay["Pay"]!["payment"] as! [String:AnyObject]
                    let state = payment["state"] as! String
                    if (state == "REQUIRED_OTP") {
                        self.transaction = payment["transaction"] as! String
                        self.removeSpinner()
                        self.methodsView.removeFromSuperview()
                        self.setupOTP()
                        self.active = indexPath.row
                    } else if(state == "REQUIRED_VERIFY"){
                        let html = payment["html"] as? String
                        if (html != nil) {
                            self.removeSpinner()
                            let webViewController = WebViewController()
                            webViewController.form = html!
                            webViewController.setOnSuccessWebView(onSuccessWebView: { responseFromWebView in
                                webViewController.dismiss(animated: true)
                                self.methodsView.removeFromSuperview()
                                self.setupSuccess()
                            })
                            webViewController.setOnFailWebView(onFailWebView: { responseFromWebView in
                                webViewController.dismiss(animated: true)
                                self.methodsView.removeFromSuperview()
                                self.setupFail()
                                self.failView.failLabel.text = responseFromWebView
                            })
                            self.presentPanModal(webViewController)
                        }
                    }
                }
            }, onError: { flowError in
                self.removeSpinner()
                self.dismiss(animated: true, completion: {
                    toastMess(title: "Lỗi", message: flowError["message"] as! String)
                })
            })
        }
        if (data[indexPath.row].type == "BANK_CARD") {
            self.showSpinner(onView: self.view)
            API.getBankList(onSuccess: { bankListResponse in
                self.methodsView.removeFromSuperview()
                let banks = bankListResponse["Setting"]!["banks"] as! [[String:AnyObject]]
                var listBank : [Bank] = []
                for bank in banks{
                    let temp = Bank(id: bank["id"] as! Int, cardNumberLength: bank["cardNumberLength"] as! Int, cardPrefix: bank[ "cardPrefix"] as! String, enName: bank["enName"] as! String, viName: bank["viName"] as! String, shortName: bank["shortName"] as! String, swiftCode: bank["swiftCode"] as! String)
                    listBank.append(temp)
                }
                self.listBank = listBank
                self.setupATMView()
                self.removeSpinner()

            }, onError: { bankListError in
                self.removeSpinner()
                print(bankListError)
                
            })
            
        }
    }
    
    func setupATMView(){
        view.addSubview(atmView)
        atmView.translatesAutoresizingMaskIntoConstraints = false
        atmView.isUserInteractionEnabled = true
        atmView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        atmView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        atmView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        atmView.heightAnchor.constraint(equalTo: self.view.heightAnchor, constant: 0).isActive = true
        atmView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: 0).isActive = true
        // atmView.button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        atmView.closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: atmView.button.bottomAnchor, constant: 10).isActive = true
        self.atmView.dateField.delegate = self
        self.atmView.cardNumberField.delegate = self
        self.updateViewConstraints()
        self.view.layoutIfNeeded()
        self.panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .shortForm)
        NotificationCenter.default.addObserver(self, selector: #selector(Methods.keyboardWillShowATM), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Methods.keyboardWillHideATM), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    @objc func keyboardWillShowATM(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            
          // if keyboard size is not available for some reason, dont do anything
          return
        }
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: atmView.button.bottomAnchor, constant: keyboardSize.height).isActive = true
        self.view.layoutIfNeeded()
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
    }
    @objc func keyboardWillHideATM(notification: NSNotification) {
        atmView.removeFromSuperview()
        view.addSubview(atmView)
        atmView.translatesAutoresizingMaskIntoConstraints = false
        atmView.isUserInteractionEnabled = true
        atmView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        atmView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        atmView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        atmView.heightAnchor.constraint(equalTo: self.view.heightAnchor, constant: 0).isActive = true
        atmView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: 0).isActive = true
        // atmView.button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        atmView.closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: atmView.button.bottomAnchor, constant: 10).isActive = true
        self.updateViewConstraints()
        self.view.layoutIfNeeded()
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .shortForm)
    }
    
    @objc func keyboardWillShowOtp(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {

          // if keyboard size is not available for some reason, dont do anything
          return
        }
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: otpView.otpView.bottomAnchor, constant: keyboardSize.height).isActive = true
        self.view.layoutIfNeeded()
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
        
    }
    
    @objc func keyboardWillHideOtp(notification: NSNotification) {
      // move back the root view origin to zero
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: otpView.otpView.bottomAnchor).isActive = true
        self.updateViewConstraints()
        self.view.layoutIfNeeded()
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .shortForm)

    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {

          // if keyboard size is not available for some reason, dont do anything
          return
        }
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: securityCode.otpView.bottomAnchor, constant: keyboardSize.height).isActive = true
        self.view.layoutIfNeeded()
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
        
    }
    @objc func keyboardWillHide(notification: NSNotification) {
      // move back the root view origin to zero
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: securityCode.otpView.bottomAnchor).isActive = true
        self.updateViewConstraints()
        self.view.layoutIfNeeded()
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .shortForm)

    }

    
    
    let detailView : UIView = {
        let detailView  = UIView()
        detailView.translatesAutoresizingMaskIntoConstraints = false
        return detailView
    }()
    
    let tableView : UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .red
        tableView.separatorStyle = .none
        
        return tableView
    }()

    let price : UILabel = {
        let price = UILabel()
        price.textColor = .white
        price.backgroundColor = .clear
        price.font = UIFont(name: "Arial", size: 32)
        price.translatesAutoresizingMaskIntoConstraints = false
        return price
    }()
    
    let memoLabel : UILabel = {
        let memoLabel = UILabel()
        memoLabel.textColor = .white
        memoLabel.backgroundColor = .clear
        memoLabel.font = UIFont(name: "Arial", size: 16)
        memoLabel.translatesAutoresizingMaskIntoConstraints = false
        memoLabel.textAlignment = .right
        return memoLabel
    }()
    
    let methodTitle : UILabel = {
        let methodTitle = UILabel()
        methodTitle.textColor = UIColor(114,129,144)
        methodTitle.backgroundColor = .clear
        methodTitle.font = UIFont(name: "Arial", size: 16)
        methodTitle.translatesAutoresizingMaskIntoConstraints = false
        return methodTitle
    }()
    
    let contentLabel : UILabel = {
        let contentLabel = UILabel()
        contentLabel.textColor = .white
        contentLabel.backgroundColor = .clear
        contentLabel.font = UIFont(name: "Arial", size: 16)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        return contentLabel
    }()
    
    let closeButton : UIButton = {
        let button = UIButton()
        let bundle = Bundle(for: QRNotFound.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let image = UIImage(named: "16Px", in: resourceBundle, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    
    let button : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        return button
    }()
    
    let txtLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor(26,26,26)
        label.backgroundColor = .clear
        label.font = UIFont(name: "Lato-SemiBold", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    var panScrollable: UIScrollView? {
        return (topViewController as? PanModalPresentable)?.panScrollable
    }

    var longFormHeight: PanModalHeight {
        return .intrinsicHeight
    }

    var shortFormHeight: PanModalHeight {
        return longFormHeight
    }

    var anchorModalToLongForm: Bool {
        return false
    }

    var shouldRoundTopCorners: Bool {
        return true
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func sha256(string: String) -> String? {
        guard let messageData = string.data(using:String.Encoding.utf8) else { return nil }
        var digestData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))

        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_SHA256(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        let result = digestData.map { String(format: "%02hhx", $0) }.joined()
        return result
    }
}
extension Methods{
    func numberOfSectionsInTableView(_tableView: UITableView) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? Method
            else { return UITableViewCell() }
        cell.configure(with: data[indexPath.row])

        return cell
    }
}


