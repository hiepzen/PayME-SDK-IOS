//
//  Methods.swift
//  PayMESDK
//
//  Created by HuyOpen on 10/28/20.
//

import UIKit
import CommonCrypto


class Methods: UINavigationController, PanModalPresentable, UITableViewDelegate, UITableViewDataSource, KAPinFieldDelegate, OTPInputDelegate {
    func pinField(_ field: OTPInput, didFinishWith code: String) {
        if (field == otpView.otpView) {
            showSpinner(onView: view)
            API.transferByLinkedBank(transaction: transaction, storeId: Methods.storeId, orderId: Methods.orderId, linkedId: (data[active!].dataLinked?.linkedId)!, extraData: Methods.extraData, note: Methods.note, otp: code, amount: Methods.amount, onSuccess: { response in
                self.removeSpinner()
                let paymentInfo = response["OpenEWallet"]!["Payment"] as! [String: AnyObject]
                if let payInfo = paymentInfo["Pay"] as? [String: AnyObject] {
                    let succeeded = payInfo["succeeded"] as! Bool
                    if let history = payInfo["history"] as? [String: AnyObject] {
                        if let createdAt = history["createdAt"] as? String {
                            if let date = toDate(dateString: createdAt) {
                                let formatDate = toDateString(date: date)
                                self.successView.timeTransactionDetail.text = formatDate
                                self.failView.timeTransactionDetail.text = formatDate
                            }
                        }
                        if let payment = history["payment"] as? [String: AnyObject] {
                            if let method = payment["method"] as? String {
                                self.successView.methodContent.text = getMethodText(method: method)
                                self.failView.methodContent.text = getMethodText(method: method)
                            }
                            if let transaction = payment["transaction"] as? String {
                                self.successView.transactionNumber.text = transaction
                                self.failView.transactionNumber.text = transaction
                            }
                            if let description = payment["description"] as? String {
                                self.successView.cardNumberContent.text = description
                                self.failView.cardNumberContent.text = description
                                self.successView.cardNumberLabel.text = "Số tài khoản"
                                self.failView.cardNumberLabel.text = "Số tài khoản"
                            }
                        }
                    }
                    if (succeeded == true) {
                        self.onSuccess!(response)
                        self.otpView.removeFromSuperview()
                        self.setupSuccess()
                    } else {
                        self.otpView.removeFromSuperview()
                        let message = payInfo["message"] as? String
                        self.failView.failLabel.text = message ?? "Có lỗi xảy ra"
                        self.onError!(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": (message ?? "Có lỗi xảy ra") as AnyObject])
                        self.setupFail()
                    }
                } else {
                    self.onError!(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": "Có lỗi xảy ra" as AnyObject])
                }
            }, onError: { error in
                self.removeSpinner()
                if let code = error["code"] as? Int {
                    if (code == 401) {
                        PayME.logoutAction()
                        Methods.isShowCloseModal = false
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                self.onError!(error)
            })
        }
    }

    func pinField(_ field: KAPinField, didFinishWith code: String) {
        if (field == securityCode.otpView) {
            self.showSpinner(onView: self.view)
            self.successView = SuccessView(type: 1)
            self.failView = FailView(type: 1)
            API.createSecurityCode(password: sha256(string: code)!, onSuccess: { securityInfo in
                let account = securityInfo["Account"]!["SecurityCode"] as! [String: AnyObject]
                let securityResponse = account["CreateCodeByPassword"] as! [String: AnyObject]
                let securtiySucceeded = securityResponse["succeeded"] as! Bool
                if (securtiySucceeded == true) {
                    let securityCode = securityResponse["securityCode"] as! String
                    API.transferWallet(storeId: Methods.storeId, orderId: Methods.orderId, securityCode: securityCode, extraData: Methods.extraData, note: Methods.note, amount: Methods.amount, onSuccess: { response in
                        let paymentInfo = response["OpenEWallet"]!["Payment"] as! [String: AnyObject]
                        let payInfo = paymentInfo["Pay"] as! [String: AnyObject]
                        let message = payInfo["message"] as! String
                        let succeeded = payInfo["succeeded"] as! Bool
                        if let history = payInfo["history"] as? [String: AnyObject] {
                            if let createdAt = history["createdAt"] as? String {
                                if let date = toDate(dateString: createdAt) {
                                    print(date)
                                    let formatDate = toDateString(date: date)
                                    self.successView.timeTransactionDetail.text = formatDate
                                    self.failView.timeTransactionDetail.text = formatDate
                                }
                            }
                            if let payment = history["payment"] as? [String: AnyObject] {
                                if let method = payment["method"] as? String {
                                    self.successView.methodContent.text = getMethodText(method: method)
                                    self.failView.methodContent.text = getMethodText(method: method)
                                }
                                if let transaction = payment["transaction"] as? String {
                                    self.successView.transactionNumber.text = transaction
                                    self.failView.transactionNumber.text = transaction
                                }
                            }
                        }

                        if (succeeded == true) {
                            self.onSuccess!(response)
                            self.securityCode.removeFromSuperview()
                            self.setupSuccess()
                        } else {
                            self.onError!(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": message as AnyObject])
                            self.securityCode.removeFromSuperview()
                            self.failView.failLabel.text = message
                            self.setupFail()
                        }
                        self.removeSpinner()

                    }, onError: { error in
                        self.removeSpinner()
                        if let code = error["code"] as? Int {
                            if (code == 401) {
                                PayME.logoutAction()
                                Methods.isShowCloseModal = false
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                        self.onError!(error)

                    })
                } else {
                    self.removeSpinner()
                    let message = securityResponse["message"] as! String
                    if (message == "Mật khẩu không chính xác") {
                        self.toastMessError(title: "Lỗi", message: message)
                        self.onError!(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": message as AnyObject])
                        self.securityCode.otpView.text = ""
                        self.securityCode.otpView.reloadAppearance()

                    } else {
                        self.onError!(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": message as AnyObject])
                        self.securityCode.removeFromSuperview()
                        self.failView.failLabel.text = message
                        self.setupFail()
                    }

                }
            }, onError: { errorSecurity in
                if let code = errorSecurity["code"] as? Int {
                    if (code == 401) {
                        PayME.logoutAction()
                        Methods.isShowCloseModal = false
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                self.onError!(errorSecurity)
                self.removeSpinner()
            })
        }
    }

    var bankName: String = ""
    var data: [MethodInfo] = []
    static var storeId: Int = 0
    static var paymentMethodID: Int? = nil
    static var orderId: String = ""
    static var amount: Int = 10000
    static var note: String = ""
    static var extraData: String = ""
    static var isShowResultUI: Bool = true
    var transaction: String = ""
    private var active: Int?
    private var bankDetect: Bank?
    var onError: (([String: AnyObject]) -> ())? = nil
    var onSuccess: (([String: AnyObject]) -> ())? = nil
    static var min: Int = 10000
    static var max: Int = 100000000

    var listBank: [Bank] = []
    let atmView = ATMView()
    let otpView = OTPView()
    let securityCode = SecurityCode()
    var successView = SuccessView()
    var failView = FailView()
    var keyBoardHeight: CGFloat = 0
    let screenSize: CGRect = UIScreen.main.bounds
    static var isShowCloseModal: Bool = true
    let methodsView = UIView()
    let placeholderView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        Methods.isShowCloseModal = true

        if Methods.paymentMethodID != nil {
            setupTargetMethod()
        } else {
            setupMethods()
        }
    }

    func setupTargetMethod() {
        view.addSubview(placeholderView)
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true

        getListMethodsAndExecution { methods in
            guard let method: MethodInfo = methods.first(where: { $0.methodId == Methods.paymentMethodID }) else {
                self.onError!(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": ("Không tìm thấy phương thức") as AnyObject])
                return
            }
            self.pay(method)
        }
    }

    func setupMethods() {
        view.addSubview(methodsView)

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

        detailView.backgroundColor = UIColor(8, 148, 31)
        detailView.addSubview(price)
        detailView.addSubview(contentLabel)
        detailView.addSubview(memoLabel)
        txtLabel.text = "Xác nhận thanh toán"
        price.text = "\(formatMoney(input: Methods.amount)) đ"
        contentLabel.text = "Nội dung"
        memoLabel.text = Methods.note == "" ? "Không có nội dung" : Methods.note
        methodTitle.text = "Chọn nguồn thanh toán"
        tableView.register(Method.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self

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
        methodTitle.leadingAnchor.constraint(equalTo: methodsView.leadingAnchor, constant: 10).isActive = true

        txtLabel.topAnchor.constraint(equalTo: methodsView.topAnchor, constant: 19).isActive = true
        txtLabel.centerXAnchor.constraint(equalTo: methodsView.centerXAnchor).isActive = true

        tableView.topAnchor.constraint(equalTo: methodTitle.bottomAnchor, constant: 10).isActive = true
        tableView.leadingAnchor.constraint(equalTo: methodsView.leadingAnchor, constant: 10).isActive = true
        tableView.trailingAnchor.constraint(equalTo: methodsView.trailingAnchor, constant: -10).isActive = true
        tableView.alwaysBounceVertical = false

        closeButton.topAnchor.constraint(equalTo: methodsView.topAnchor, constant: 19).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: methodsView.trailingAnchor, constant: -30).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)

        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: tableView.bottomAnchor, constant: 10).isActive = true
        getListMethodsAndExecution { methods in
            self.showMethods(methods)
        }
    }

    func getListMethodsAndExecution(execution: (([MethodInfo]) -> Void)? = nil) {
        showSpinner(onView: view)

        API.getWalletInfo(onSuccess: { walletInformation in
            let balance = (walletInformation["Wallet"] as! [String: AnyObject])["balance"] as! Int
            API.getTransferMethods(onSuccess: { response in
                let items = (response["Utility"]!["GetPaymentMethod"] as! [String: AnyObject])["methods"] as! [[String: AnyObject]]
                var methods: [MethodInfo] = []
                for (index, item) in items.enumerated() {
                    let methodInformation = MethodInfo(
                            methodId: (item["methodId"] as! Int), type: item["type"] as! String,
                            title: item["title"] as! String, label: item["label"] as! String,
                            amount: (item["type"] as! String) == "WALLET" ? balance : nil,
                            fee: item["fee"] as! Int, minFee: item["minFee"] as! Int,
                            dataWallet: nil, dataLinked: nil, active: index == 0 ? true : false
                    )
                    if !(item["data"] is NSNull) {
                        if let accountId = (item["data"] as! [String: AnyObject])["accountId"] as? Int {
                            methodInformation.dataWallet = WalletMethodInfo(accountId: accountId)
                        } else {
                            methodInformation.dataLinked = LinkedMethodInfo(
                                    swiftCode: (item["data"] as! [String: AnyObject])["swiftCode"] as! String,
                                    linkedId: (item["data"] as! [String: AnyObject])["linkedId"] as! Int
                            )
                        }
                    }
                    methods.append(methodInformation)
                    DispatchQueue.main.async {
                        self.removeSpinner()
                        execution?(methods)
                    }
                }
            }, onError: { error in
                self.removeSpinner()
                Methods.isShowCloseModal = false
                self.dismiss(animated: true, completion: { self.onError!(error) })
            })
        }, onError: { error in
            self.removeSpinner()
            Methods.isShowCloseModal = false
            self.dismiss(animated: true, completion: { self.onError!(error) })
        })
    }

    func showMethods(_ methods: [MethodInfo]) {
        data = methods
        tableView.reloadData()
        tableView.heightAnchor.constraint(equalToConstant: tableView.contentSize.height + 4).isActive = true
        tableView.alwaysBounceVertical = false
        tableView.isScrollEnabled = false
        view.layoutIfNeeded()
        self.panModalTransition(to: .shortForm)
        panModalSetNeedsLayoutUpdate()
    }

    func setupOTP() {
        view.addSubview(otpView)

        otpView.translatesAutoresizingMaskIntoConstraints = false
        otpView.widthAnchor.constraint(equalToConstant: screenSize.width).isActive = true
        otpView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        otpView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        otpView.closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: otpView.otpView.bottomAnchor, constant: 10).isActive = true
        updateViewConstraints()
        view.layoutIfNeeded()
        panModalTransition(to: .shortForm)
        panModalSetNeedsLayoutUpdate()
        NotificationCenter.default.addObserver(self, selector: #selector(Methods.keyboardWillShowOtp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Methods.keyboardWillHideOtp), name: UIResponder.keyboardWillHideNotification, object: nil)
        otpView.otpView.properties.delegate = self
        otpView.otpView.becomeFirstResponder()
    }

    func setupSecurity() {
        view.addSubview(securityCode)

        securityCode.translatesAutoresizingMaskIntoConstraints = false
        securityCode.widthAnchor.constraint(equalToConstant: screenSize.width).isActive = true
        securityCode.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        securityCode.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        securityCode.closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: securityCode.otpView.bottomAnchor, constant: 10).isActive = true
        updateViewConstraints()
        view.layoutIfNeeded()
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .shortForm)
        NotificationCenter.default.addObserver(self, selector: #selector(Methods.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Methods.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        securityCode.otpView.properties.delegate = self
        securityCode.otpView.becomeFirstResponder()
    }

    func setupFail() {
        Methods.isShowCloseModal = false
        if (Methods.isShowResultUI == true) {
            view.addSubview(failView)

            failView.translatesAutoresizingMaskIntoConstraints = false
            failView.widthAnchor.constraint(equalToConstant: screenSize.width).isActive = true
            failView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
            failView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            failView.roleLabel.text = formatMoney(input: Methods.amount)

            failView.memoLabel.text = Methods.note == "" ? "Không có nội dung" : Methods.note
            failView.button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
            failView.closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
            bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: failView.button.bottomAnchor, constant: 10).isActive = true
            updateViewConstraints()
            view.layoutIfNeeded()
            self.panModalSetNeedsLayoutUpdate()
            panModalTransition(to: .longForm)
        } else {
            dismiss(animated: true)
        }
    }

    func setupSuccess() {
        Methods.isShowCloseModal = false
        if (Methods.isShowResultUI == true) {
            view.addSubview(successView)
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
            updateViewConstraints()
            view.layoutIfNeeded()
            self.panModalSetNeedsLayoutUpdate()
            panModalTransition(to: .longForm)
        } else {
            dismiss(animated: true)
        }
    }

    override func viewDidLayoutSubviews() {
        let topPoint = CGPoint(x: detailView.frame.minX, y: detailView.bounds.midY + 15)
        let bottomPoint = CGPoint(x: detailView.frame.maxX, y: detailView.bounds.midY + 15)
        detailView.createDashedLine(from: topPoint, to: bottomPoint, color: UIColor(203, 203, 203), strokeLength: 3, gapLength: 4, width: 0.5)
        successView.createDashedLine(from: topPoint, to: bottomPoint, color: UIColor(203, 203, 203), strokeLength: 3, gapLength: 4, width: 0.5)
        failView.createDashedLine(from: topPoint, to: bottomPoint, color: UIColor(203, 203, 203), strokeLength: 3, gapLength: 4, width: 0.5)
        button.applyGradient(colors: [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor], radius: 10)
        detailView.applyGradient(colors: [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor], radius: 0)
        successView.button.applyGradient(colors: [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor], radius: 10)
        failView.button.applyGradient(colors: [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor], radius: 10)

        atmView.detailView.createDashedLine(from: topPoint, to: bottomPoint, color: UIColor(203, 203, 203), strokeLength: 3, gapLength: 4, width: 0.5)
        atmView.detailView.applyGradient(colors: [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor], radius: 0)
        atmView.button.applyGradient(colors: [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor], radius: 10)
    }

    func panModalDidDismiss() {
        if (Methods.isShowCloseModal == true) {
            self.onError!(["code": PayME.ResponseCode.USER_CANCELLED as AnyObject, "message": "Đóng modal thanh toán" as AnyObject])
        }
    }

    @objc
    func closeAction(button: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        active = indexPath.row
        pay(data[indexPath.row])
    }

    func pay(_ method: MethodInfo) {
        if (method.type == "WALLET") {
            if (method.amount! < Methods.amount) {
                Methods.isShowCloseModal = false
                dismiss(animated: true, completion: {
                    self.onError!(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": "Số dư tài khoản không đủ. Vui lòng kiểm tra lại" as AnyObject])
                })
                return
            }
            view.subviews.forEach {
                $0.removeFromSuperview()
            }
            setupSecurity()
        }
        if (method.type == "LINKED") {
            if (PayME.appENV.isEqual("SANDBOX")) {
                Methods.isShowCloseModal = false
                dismiss(animated: true) {
                    self.onError!(["code": PayME.ResponseCode.LIMIT as AnyObject, "message": "Chức năng chỉ có thể thao tác môi trường production" as AnyObject])
                }
                return
            }
            showSpinner(onView: view)
            API.checkFlowLinkedBank(storeId: Methods.storeId, orderId: Methods.orderId, linkedId: method.dataLinked!.linkedId, extraData: Methods.extraData, note: Methods.note, amount: Methods.amount, onSuccess: { flow in
                let pay = flow["OpenEWallet"]!["Payment"] as! [String: AnyObject]
                if let payInfo = pay["Pay"] as? [String: AnyObject] {
                    if let history = payInfo["history"] as? [String: AnyObject] {
                        if let createdAt = history["createdAt"] as? String {
                            if let date = toDate(dateString: createdAt) {
                                let formatDate = toDateString(date: date)
                                self.successView.timeTransactionDetail.text = formatDate
                                self.failView.timeTransactionDetail.text = formatDate
                            }
                        }
                        if let payment = history["payment"] as? [String: AnyObject] {
                            if let method = payment["method"] as? String {
                                self.successView.methodContent.text = getMethodText(method: method)
                                self.failView.methodContent.text = getMethodText(method: method)
                            }
                            if let transaction = payment["transaction"] as? String {
                                self.successView.transactionNumber.text = transaction
                                self.failView.transactionNumber.text = transaction
                            }
                            if let description = payment["description"] as? String {
                                self.successView.cardNumberContent.text = description
                                self.failView.cardNumberContent.text = description
                                self.successView.cardNumberLabel.text = "Số tài khoản"
                                self.failView.cardNumberLabel.text = "Số tài khoản"
                            }
                        }
                    }
                    let succeeded = payInfo["succeeded"] as! Bool
                    if (succeeded == true) {
                        self.onSuccess!(flow)
                        self.removeSpinner()
                        self.methodsView.removeFromSuperview()
                        self.setupSuccess()
                    } else {
                        if let payment = payInfo["payment"] as? [String: AnyObject] {
                            let state = (payment["state"] as? String) ?? ""

                            if (state == "REQUIRED_OTP") {
                                self.transaction = payment["transaction"] as! String
                                self.removeSpinner()
                                self.methodsView.removeFromSuperview()
                                self.setupOTP()
                            } else if (state == "REQUIRED_VERIFY") {
                                let message = payment["message"] as? String
                                let html = payment["html"] as? String
                                if (html != nil) {
                                    self.removeSpinner()
                                    let webViewController = WebViewController()
                                    webViewController.form = html!
                                    webViewController.setOnSuccessWebView(onSuccessWebView: { responseFromWebView in
                                        webViewController.dismiss(animated: true)
                                        self.methodsView.removeFromSuperview()
                                        let successWebview: [String: AnyObject] = ["OpenEWallet": [
                                            "Payment": [
                                                "Pay": [
                                                    "success": true as AnyObject,
                                                    "message": message as AnyObject,
                                                    "history": payInfo["history"] as AnyObject
                                                ]
                                            ]
                                        ] as AnyObject
                                        ]
                                        self.onSuccess!(successWebview)
                                        self.setupSuccess()
                                    })
                                    webViewController.setOnFailWebView(onFailWebView: { responseFromWebView in
                                        webViewController.dismiss(animated: true)
                                        self.methodsView.removeFromSuperview()
                                        self.failView.failLabel.text = responseFromWebView
                                        let failWebview: [String: AnyObject] = ["OpenEWallet": [
                                            "Payment": [
                                                "Pay": [
                                                    "success": true as AnyObject,
                                                    "message": responseFromWebView as AnyObject,
                                                    "history": payInfo["history"] as AnyObject
                                                ]
                                            ]
                                        ] as AnyObject]
                                        self.onError!(failWebview)
                                        self.setupFail()
                                    })
                                    self.presentPanModal(webViewController)
                                }
                            } else {
                                self.removeSpinner()
                                self.methodsView.removeFromSuperview()
                                let message = payment["message"] as? String
                                self.onError!(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": (message ?? "Có lỗi xảy ra") as AnyObject])

                                self.failView.failLabel.text = message ?? "Có lỗi xảy ra"
                                self.setupFail()
                            }
                        } else {
                            self.removeSpinner()
                            self.methodsView.removeFromSuperview()
                            let message = payInfo["message"] as? String
                            self.onError!(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": (message ?? "Có lỗi xảy ra") as AnyObject])
                            self.failView.failLabel.text = message ?? "Có lỗi xảy ra"
                            self.setupFail()
                        }
                    }
                } else {
                    self.onError!(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": "Có lỗi xảy ra" as AnyObject])
                }
            }, onError: { flowError in
                self.onError!(flowError)
                self.removeSpinner()
                if let code = flowError["code"] as? Int {
                    if (code == 401) {
                        PayME.logoutAction()
                        Methods.isShowCloseModal = false
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            })
        }
        if (method.type == "BANK_CARD") {
            if (PayME.appENV.isEqual("SANDBOX")) {
                onError!(["message": "Chức năng chỉ có thể thao tác môi trường production" as AnyObject])
                return
            }
            API.getBankList(onSuccess: { bankListResponse in
                let banks = bankListResponse["Setting"]!["banks"] as! [[String: AnyObject]]
                var listBank: [Bank] = []
                for bank in banks {
                    let temp = Bank(id: bank["id"] as! Int, cardNumberLength: bank["cardNumberLength"] as! Int, cardPrefix: bank["cardPrefix"] as! String, enName: bank["enName"] as! String, viName: bank["viName"] as! String, shortName: bank["shortName"] as! String, swiftCode: bank["swiftCode"] as! String)
                    listBank.append(temp)
                }
                let atmModal = ATMModal()
                atmModal.listBank = listBank
                atmModal.onSuccess = self.onSuccess
                atmModal.onError = self.onError
                Methods.isShowCloseModal = false
                self.dismiss(animated: true) {
                    PayME.currentVC!.presentPanModal(atmModal)
                }
            }, onError: { bankListError in
                self.onError!(bankListError)
                self.toastMessError(title: "Lỗi", message: "Lấy danh sách bank thất bại")
            })

        }
    }

    @objc func keyboardWillShowOtp(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: otpView.otpView.bottomAnchor, constant: keyboardSize.height + 10).isActive = true
        view.layoutIfNeeded()
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
    }

    @objc func keyboardWillHideOtp(notification: NSNotification) {
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: otpView.otpView.bottomAnchor).isActive = true
        updateViewConstraints()
        view.layoutIfNeeded()
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .shortForm)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: securityCode.otpView.bottomAnchor, constant: keyboardSize.height + 10).isActive = true
        view.layoutIfNeeded()
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: securityCode.otpView.bottomAnchor).isActive = true
        updateViewConstraints()
        view.layoutIfNeeded()
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .shortForm)
    }

    func toastMessError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    let detailView: UIView = {
        let detailView = UIView()
        detailView.translatesAutoresizingMaskIntoConstraints = false
        return detailView
    }()

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        return tableView
    }()

    let price: UILabel = {
        let price = UILabel()
        price.textColor = .white
        price.backgroundColor = .clear
        price.font = UIFont(name: "Arial", size: 32)
        price.translatesAutoresizingMaskIntoConstraints = false
        return price
    }()

    let memoLabel: UILabel = {
        let memoLabel = UILabel()
        memoLabel.textColor = .white
        memoLabel.backgroundColor = .clear
        memoLabel.font = UIFont(name: "Arial", size: 16)
        memoLabel.translatesAutoresizingMaskIntoConstraints = false
        memoLabel.textAlignment = .right
        return memoLabel
    }()

    let methodTitle: UILabel = {
        let methodTitle = UILabel()
        methodTitle.textColor = UIColor(114, 129, 144)
        methodTitle.backgroundColor = .clear
        methodTitle.font = UIFont(name: "Arial", size: 16)
        methodTitle.translatesAutoresizingMaskIntoConstraints = false
        return methodTitle
    }()

    let contentLabel: UILabel = {
        let contentLabel = UILabel()
        contentLabel.textColor = .white
        contentLabel.backgroundColor = .clear
        contentLabel.font = UIFont(name: "Arial", size: 16)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        return contentLabel
    }()

    let closeButton: UIButton = {
        let button = UIButton()
        let bundle = Bundle(for: QRNotFound.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let image = UIImage(named: "16Px", in: resourceBundle, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        return button
    }()

    let txtLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(26, 26, 26)
        label.backgroundColor = .clear
        label.font = UIFont(name: "Lato-SemiBold", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    var panScrollable: UIScrollView? {
        nil
    }

    var longFormHeight: PanModalHeight {
        .intrinsicHeight
    }

    var shortFormHeight: PanModalHeight {
        longFormHeight
    }

    var anchorModalToLongForm: Bool {
        false
    }

    var shouldRoundTopCorners: Bool {
        true
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func sha256(string: String) -> String? {
        guard let messageData = string.data(using: String.Encoding.utf8) else {
            return nil
        }
        var digestData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))

        _ = digestData.withUnsafeMutableBytes { digestBytes in
            messageData.withUnsafeBytes { messageBytes in
                CC_SHA256(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        let result = digestData.map {
            String(format: "%02hhx", $0)
        }.joined()
        return result
    }
}

extension Methods {
    func numberOfSectionsInTableView(_tableView: UITableView) -> Int {
        data.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? Method else {
            return UITableViewCell()
        }
        cell.configure(with: data[indexPath.row])
        return cell
    }
}


