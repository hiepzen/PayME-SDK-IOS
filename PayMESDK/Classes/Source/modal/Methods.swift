//
//  Methods.swift
//  PayMESDK
//
//  Created by HuyOpen on 10/28/20.
//

import UIKit
import CommonCrypto



class Methods: UINavigationController, PanModalPresentable, UITableViewDelegate,  UITableViewDataSource, KAPinFieldDelegate {
    
    func pinField(_ field: KAPinField, didFinishWith code: String) {
        self.showSpinner(onView: self.view)
        if (field == securityCode.otpView) {
            API.createSecurityCode(password: sha256(string: code)!, onSuccess: {securityInfo in
                let account = securityInfo["Account"]!["SecurityCode"] as! [String:AnyObject]
                let securityResponse = account["CreateCodeByPassword"] as! [String:AnyObject]
                let securtiySucceeded = securityResponse ["succeeded"] as! Bool
                if (securtiySucceeded == true) {
                    let securityCode = securityResponse["securityCode"] as! String
                    API.transferWallet(storeId: Methods.storeId, orderId: Methods.orderId, securityCode: securityCode, extraData: Methods.extraData, note: Methods.note, amount: Methods.amount, onSuccess: { response in
                        print(response)
                        self.onSuccess!(response)
                        let paymentInfo = response["OpenEWallet"]!["Payment"] as! [String:AnyObject]
                        let payInfo = paymentInfo["Pay"] as! [String:AnyObject]
                        let message = payInfo["message"] as! String
                        let succeeded = payInfo["succeeded"] as! Bool
                        if (succeeded == true) {
                                self.securityCode.removeFromSuperview()
                                self.setupSuccess()
                            
                        } else {
                                self.securityCode.removeFromSuperview()
                                self.failView.failLabel.text = message
                                self.setupFail()
                            
                        }
                        self.removeSpinner()
                        
                    }, onError: { error in
                        self.onError!(error)
                        self.removeSpinner()
                        self.dismiss(animated: true, completion: {
                            self.toastMessError(title: "Lỗi", message: error["message"] as! String)
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
                        self.failView.failLabel.text = message
                        self.setupFail()
                    }
                    
                }
                
            }, onError: {errorSecurity in
                self.onError!(errorSecurity)
                self.removeSpinner()
                self.dismiss(animated: true, completion: {
                    self.toastMessError(title: "Lỗi", message: errorSecurity["message"] as! String)
                })
            })
        } else if(field == otpView.otpView) {
            API.transferByLinkedBank(transaction: transaction, storeId: Methods.storeId, orderId: Methods.orderId, linkedId: (data[active!].dataLinked?.linkedId)!, extraData: Methods.extraData, note: Methods.note, otp: code, amount: Methods.amount, onSuccess: { response in
                self.onSuccess!(response)
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
                        self.failView.failLabel.text = message
                        self.setupFail()
                    }
                }
                self.removeSpinner()
            }, onError: { error in
                self.onError!(error)
                self.removeSpinner()
                self.dismiss(animated: true, completion: {
                    self.toastMessError(title: "Lỗi", message: error["message"] as! String)
                })
            })
        }
    }
    
    var bankName : String = ""
    var data : [MethodInfo] = []
    static var storeId : Int = 0
    static var orderId : String = ""
    static var amount : Int = 10000
    static var note : String = ""
    static var extraData : String = ""
    var transaction : String = ""
    private var active : Int?
    private var bankDetect : Bank?
    var onError : (([String:AnyObject]) -> ())? = nil
    var onSuccess : (([String:AnyObject]) -> ())? = nil
    var appENV : String?

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
    var keyBoardHeight : CGFloat = 0
    let screenSize:CGRect = UIScreen.main.bounds

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.view.addSubview(methodsView)
        setupMethods()
        

    }
    
    func setupMethods() {
        methodsView.backgroundColor = .white
            
        methodsView.translatesAutoresizingMaskIntoConstraints = false
        methodsView.widthAnchor.constraint(equalToConstant: screenSize.width).isActive = true
        methodsView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        methodsView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
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
        price.text = "\(formatMoney(input: Methods.amount)) đ"
        contentLabel.text = "Nội dung"
        if (Methods.note == "") {
            memoLabel.text = "Không có nội dung"
        } else {
            memoLabel.text = Methods.note
        }
        methodTitle.text = "Chọn nguồn thanh toán"
        tableView.register(Method.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
        methodsView.widthAnchor.constraint(equalToConstant: screenSize.width).isActive = true
        
        detailView.leadingAnchor.constraint(equalTo: methodsView.leadingAnchor).isActive = true
        detailView.trailingAnchor.constraint(equalTo: methodsView.trailingAnchor).isActive = true
        detailView.heightAnchor.constraint(equalToConstant: 118.0).isActive = true
        detailView.centerXAnchor.constraint(equalTo: methodsView.centerXAnchor).isActive = true
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
        methodTitle.leadingAnchor.constraint(equalTo: methodsView.leadingAnchor, constant: 30).isActive = true
        
        txtLabel.topAnchor.constraint(equalTo: methodsView.topAnchor, constant: 19).isActive = true
        txtLabel.centerXAnchor.constraint(equalTo: methodsView.centerXAnchor).isActive = true
        
        /*
        tableView.topAnchor.constraint(equalTo: methodTitle.topAnchor, constant: 10).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        */

        tableView.topAnchor.constraint(equalTo: methodTitle.bottomAnchor, constant: 10).isActive = true
        tableView.leadingAnchor.constraint(equalTo: methodsView.leadingAnchor, constant: 30).isActive = true
        tableView.trailingAnchor.constraint(equalTo: methodsView.trailingAnchor, constant: -30).isActive = true
        tableView.alwaysBounceVertical = false

        closeButton.topAnchor.constraint(equalTo: methodsView.topAnchor, constant: 19).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: methodsView.trailingAnchor, constant: -30).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
                
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: tableView.bottomAnchor, constant: 10).isActive = true

        self.showSpinner(onView: self.view)
        API.getWalletInfo(
            onSuccess: {walletInfo in
                let wallet = walletInfo["Wallet"] as! [String:AnyObject]
                let balance = wallet["balance"] as! Int
                API.getTransferMethods(onSuccess: {response in
                           // Update UI
                    let methodsReponse = response["Utility"]!["GetPaymentMethod"] as! [String:AnyObject]
                    let items = methodsReponse["methods"] as! [[String:AnyObject]]
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
                        self.tableView.heightAnchor.constraint(equalToConstant: self.tableView.contentSize.height+10).isActive = true
                        self.tableView.alwaysBounceVertical = false
                        self.tableView.isScrollEnabled = false
                        self.bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: self.tableView.bottomAnchor, constant: 20).isActive = true
                        self.view.layoutIfNeeded()
                        self.panModalSetNeedsLayoutUpdate()
                        self.panModalTransition(to: .longForm)
                    }
            },onError: {error in
                self.removeSpinner()
                self.onError!(error)
                self.dismiss(animated: true, completion: {
                    self.onError!(error)
                })
           })
        }, onError: {error in
            self.removeSpinner()
            self.dismiss(animated: true, completion: {
                self.onError!(error)
            })
            
        })
    }
    
    func setupOTP() {
        view = otpView
        otpView.translatesAutoresizingMaskIntoConstraints = false
        otpView.widthAnchor.constraint(equalToConstant: screenSize.width).isActive = true
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
        
        securityCode.translatesAutoresizingMaskIntoConstraints = false
        securityCode.widthAnchor.constraint(equalToConstant: screenSize.width).isActive = true
        securityCode.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        securityCode.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
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
        
        failView.translatesAutoresizingMaskIntoConstraints = false
        failView.widthAnchor.constraint(equalToConstant: screenSize.width).isActive = true
        failView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        failView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        failView.roleLabel.text = formatMoney(input: Methods.amount)
        
        if (Methods.note == "") {
            failView.memoLabel.text = "Không có nội dung"
        } else {
            failView.memoLabel.text = Methods.note
        }
        failView.button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        failView.closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: failView.button.bottomAnchor, constant: 10).isActive = true
        self.updateViewConstraints()
        self.view.layoutIfNeeded()
        self.panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
    }
    
    func setupSuccess() {
        view.addSubview(successView)
        
        successView.translatesAutoresizingMaskIntoConstraints = false
        
        successView.translatesAutoresizingMaskIntoConstraints = false
        successView.widthAnchor.constraint(equalToConstant: screenSize.width).isActive = true
        successView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        successView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        successView.roleLabel.text = formatMoney(input: Methods.amount)
        successView.button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        successView.closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        successView.roleLabel.text = formatMoney(input: Methods.amount)
        if (Methods.note == "") {
            successView.memoLabel.text = "Không có nội dung"
        } else {
            successView.memoLabel.text = Methods.note
        }
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: successView.button.bottomAnchor, constant: 10).isActive = true
        self.updateViewConstraints()
        self.view.layoutIfNeeded()
        self.panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
        
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
            if (data[indexPath.row].amount! < Methods.amount) {
                self.dismiss(animated: true, completion: {
                    self.onError!(["message" : "Vui lòng kiểm tra lại số dư tài khoản" as AnyObject])
                })
                return
            }
            methodsView.removeFromSuperview()
            setupSecurity()
        }
        if (data[indexPath.row].type == "LINKED") {
            if (appENV!.isEqual("SANDBOX")) {
                self.dismiss(animated: true, completion: {
                    self.onError!(["message" : "Chức năng chỉ có thể thao tác môi trường production" as AnyObject])
                })
                return
            }
            self.showSpinner(onView: self.view)
            API.checkFlowLinkedBank(storeId: Methods.storeId, orderId: Methods.orderId, linkedId: data[indexPath.row].dataLinked!.linkedId, extraData: Methods.extraData, note: Methods.note, amount: Methods.amount, onSuccess: { flow in
                print(flow)
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
                                self.failView.failLabel.text = responseFromWebView
                                self.setupFail()
                            })
                            self.presentPanModal(webViewController)
                        }
                    } else {
                        self.removeSpinner()
                        self.methodsView.removeFromSuperview()
                        let message = payment["message"] as? String
                        self.failView.failLabel.text = message ?? "Có lỗi xảy ra"
                        self.setupFail()
                        
                    }
                }
            }, onError: { flowError in
                self.onError!(flowError)
                self.removeSpinner()
                self.dismiss(animated: true, completion: {
                    self.toastMessError(title: "Lỗi", message: flowError["message"] as! String)
                })
            })
        }
        if (data[indexPath.row].type == "BANK_CARD") {
            if (appENV!.isEqual("SANDBOX")) {
                self.onError!(["message" : "Chức năng chỉ có thể thao tác môi trường production" as AnyObject])
                return
            }
            self.showSpinner(onView: self.view)
            API.getBankList(onSuccess: { bankListResponse in
                let banks = bankListResponse["Setting"]!["banks"] as! [[String:AnyObject]]
                var listBank : [Bank] = []
                for bank in banks{
                    let temp = Bank(id: bank["id"] as! Int, cardNumberLength: bank["cardNumberLength"] as! Int, cardPrefix: bank[ "cardPrefix"] as! String, enName: bank["enName"] as! String, viName: bank["viName"] as! String, shortName: bank["shortName"] as! String, swiftCode: bank["swiftCode"] as! String)
                    listBank.append(temp)
                }
                let atmModal = ATMModal()
                atmModal.listBank = listBank
                atmModal.onSuccess = self.onSuccess
                atmModal.onError = self.onError
                self.dismiss(animated: true, completion: {
                    PayME.currentVC!.presentPanModal(atmModal)
                })
                self.removeSpinner()

            }, onError: { bankListError in
                self.onError!(bankListError)
                self.removeSpinner()
                print(bankListError)
                
            })
            
        }
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
        
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: securityCode.otpView.bottomAnchor, constant: keyboardSize.height + 10).isActive = true
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

    func toastMessError(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    
    
    let detailView : UIView = {
        let detailView  = UIView()
        detailView.translatesAutoresizingMaskIntoConstraints = false
        return detailView
    }()
    
    let tableView : UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
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


