//
//  PaymentModalController.swift
//  PayMESDK
//
//  Created by HuyOpen on 10/28/20.
//

import UIKit
import CommonCrypto
import RxSwift

class PaymentModalController: UINavigationController, PanModalPresentable, UITableViewDelegate, UITableViewDataSource, KAPinFieldDelegate, OTPInputDelegate {
    func pinField(_ field: OTPInput, didFinishWith code: String) {
        if (field == otpView.otpView) {
            showSpinner(onView: view)
            paymentPresentation.transferByLinkedBank(transaction: transaction, orderTransaction: orderTransaction, linkedId: (data[active!].dataLinked?.linkedId)!, OTP: code)
        }
    }

    func pinField(_ field: KAPinField, didFinishWith code: String) {
        if (field == securityCode.otpView) {
            showSpinner(onView: view)
            securityCode.txtErrorMessage.isHidden = true
            paymentPresentation.createSecurityCode(password: sha256(string: code)!, orderTransaction: orderTransaction)
        }
    }

    var bankName: String = ""
    var data: [PaymentMethod] = []
    var paymentMethodID: Int? = nil
    var isShowResultUI: Bool = true
    var transaction: String = ""
    private var active: Int?
    private var bankDetect: Bank?
    private let onError: ([String: AnyObject]) -> ()
    private let onSuccess: ([String: AnyObject]) -> ()
    static var min: Int = 10000
    static var max: Int = 100000000

    var listBank: [Bank] = []
    let otpView = OTPView()
    let securityCode = SecurityCode()
    let atmController: ATMModal
    let resultView = ResultView()
    var keyBoardHeight: CGFloat = 0
    let screenSize: CGRect = UIScreen.main.bounds
    static var isShowCloseModal: Bool = true
    let methodsView = UIView()
    let placeholderView = UIView()

    let payMEFunction: PayMEFunction
    let orderTransaction: OrderTransaction
    let paymentPresentation: PaymentPresentation

    let paymentSubject: PublishSubject<PaymentState> = PublishSubject()
    private let disposeBag = DisposeBag()

    init(
            payMEFunction: PayMEFunction, orderTransaction: OrderTransaction, paymentMethodID: Int?, isShowResultUI: Bool,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> ()
    ) {
        self.payMEFunction = payMEFunction
        self.orderTransaction = orderTransaction
        self.paymentMethodID = paymentMethodID
        self.isShowResultUI = isShowResultUI
        self.onSuccess = onSuccess
        self.onError = onError
        paymentPresentation = PaymentPresentation(
                request: payMEFunction.request, paymentViewModel: payMEFunction.paymentViewModel,
                onSuccess: onSuccess, onError: onError
        )
        atmController = ATMModal(
                payMEFunction: self.payMEFunction, orderTransaction: self.orderTransaction,
                isShowResult: self.isShowResultUI, onSuccess: self.onSuccess, onError: self.onError
        )
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        PaymentModalController.isShowCloseModal = true

        if paymentMethodID != nil {
            setupTargetMethod()
        } else {
            setupMethods()
        }

        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(onAppEnterForeground), name: UIScene.willEnterForegroundNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(onAppEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        }

        setupSubcription()
    }

    private func setupSubcription() {
        payMEFunction.paymentViewModel.paymentSubject
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { paymentState in
                    if paymentState.state == State.RESULT {
                        self.removeSpinner()
                        self.view.subviews.forEach {
                            $0.removeFromSuperview()
                        }
                        self.setupResult(result: paymentState.result!)
                    }
                    if paymentState.state == State.METHODS {

                    }
                    if paymentState.state == State.ATM {
                        self.atmController.setListBank(listBank: paymentState.banks!)
                        let atmView = self.atmController.view!
                        self.tableView.removeFromSuperview()
                        self.view.addSubview(atmView)
                        atmView.translatesAutoresizingMaskIntoConstraints = false
                        atmView.topAnchor.constraint(equalTo: self.methodTitle.bottomAnchor).isActive = true
                        atmView.leadingAnchor.constraint(equalTo: self.methodsView.leadingAnchor).isActive = true
                        atmView.trailingAnchor.constraint(equalTo: self.methodsView.trailingAnchor).isActive = true
                    }
                }, onError: { error in
                    self.removeSpinner()
                    let responseError = error as! ResponseError
                    if responseError.code == ResponseErrorCode.EXPIRED {
                        self.payMEFunction.resetInitState()
                        PaymentModalController.isShowCloseModal = false
                        self.dismiss(animated: true, completion: nil)
                    }
                    if responseError.code == ResponseErrorCode.PASSWORD_INVALID {
                        self.securityCode.otpView.text = ""
                        self.securityCode.otpView.reloadAppearance()
                        self.securityCode.txtErrorMessage.text = responseError.message
                        self.securityCode.txtErrorMessage.isHidden = false
                        self.panModalSetNeedsLayoutUpdate()
                        self.panModalTransition(to: .longForm)
                    }
                    if responseError.code == ResponseErrorCode.REQUIRED_OTP {
                        self.methodsView.removeFromSuperview()
                        self.setupOTP()
                    }
                    if responseError.code == ResponseErrorCode.REQUIRED_VERIFY {
                        self.setupWebview(responseError)
                    }
                }).disposed(by: disposeBag)
    }

    private func setupWebview(_ responseError: ResponseError) {
        let webViewController = WebViewController(payMEFunction: nil, nibName: "WebView", bundle: nil)
        webViewController.form = responseError.html
        webViewController.setOnSuccessWebView(onSuccessWebView: { responseFromWebView in
            webViewController.dismiss(animated: true)
            let paymentInfo = responseError.paymentInformation!["history"]!["payment"] as! [String: AnyObject]
            let responseSuccess = [
                "payment": ["transaction": paymentInfo["transaction"] as? String]
            ] as [String: AnyObject]
            self.onSuccess(responseSuccess)
            let result = Result(
                    type: ResultType.SUCCESS,
                    orderTransaction: self.orderTransaction,
                    transactionInfo: responseError.transactionInformation!
            )
            self.payMEFunction.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.RESULT, result: result))
        })
        webViewController.setOnFailWebView(onFailWebView: { responseFromWebView in
            webViewController.dismiss(animated: true)
            let failWebview: [String: AnyObject] = ["OpenEWallet": [
                "Payment": [
                    "Pay": [
                        "success": true as AnyObject,
                        "message": responseFromWebView as AnyObject,
                        "history": responseError.paymentInformation!["history"] as AnyObject
                    ]
                ]
            ] as AnyObject]
            self.onError(failWebview)
            let result = Result(
                    type: ResultType.FAIL,
                    failReasonLabel: responseFromWebView as String,
                    orderTransaction: self.orderTransaction,
                    transactionInfo: responseError.transactionInformation!
            )
            self.payMEFunction.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.RESULT, result: result))
        })
        presentPanModal(webViewController)
    }

    func setupTargetMethod() {
        view.addSubview(placeholderView)
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true

        getListMethodsAndExecution { methods in
            guard let method = methods.first(where: { $0.methodId == self.paymentMethodID }) else {
                self.onError(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": ("Không tìm thấy phương thức") as AnyObject])
                return
            }
            self.pay(method)
        }
    }

    func getMethodSelected() -> PaymentMethod {
        if paymentMethodID != nil {
            if let method = data.first(where: { $0.methodId == paymentMethodID }) {
                return method
            }
        }
        return data[active!]
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
        methodsView.addSubview(methodTitleStamp)
        methodsView.addSubview(methodTitle)
        methodsView.addSubview(tableView)

        detailView.backgroundColor = UIColor(8, 148, 31)
        detailView.addSubview(price)
        detailView.addSubview(contentLabel)
        detailView.addSubview(memoLabel)
        txtLabel.text = "Thanh toán"
        price.text = "\(formatMoney(input: orderTransaction.amount)) đ"
        contentLabel.text = "Nội dung"
        memoLabel.text = orderTransaction.note == "" ? "Không có nội dung" : orderTransaction.note
        methodTitle.text = "Nguồn thanh toán"
        tableView.register(Method.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self

        detailView.leadingAnchor.constraint(equalTo: methodsView.leadingAnchor).isActive = true
        detailView.trailingAnchor.constraint(equalTo: methodsView.trailingAnchor).isActive = true
        detailView.heightAnchor.constraint(equalToConstant: 118.0).isActive = true
        detailView.centerXAnchor.constraint(equalTo: methodsView.centerXAnchor).isActive = true
        detailView.topAnchor.constraint(equalTo: txtLabel.bottomAnchor, constant: 16.0).isActive = true

        price.topAnchor.constraint(equalTo: detailView.topAnchor, constant: 16).isActive = true
        price.centerXAnchor.constraint(equalTo: detailView.centerXAnchor).isActive = true

        contentLabel.bottomAnchor.constraint(equalTo: detailView.bottomAnchor, constant: -15).isActive = true
        contentLabel.leadingAnchor.constraint(equalTo: detailView.leadingAnchor, constant: 16).isActive = true
        contentLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .horizontal)
        contentLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        memoLabel.bottomAnchor.constraint(equalTo: detailView.bottomAnchor, constant: -15).isActive = true
        memoLabel.leadingAnchor.constraint(equalTo: contentLabel.trailingAnchor, constant: 30).isActive = true
        memoLabel.trailingAnchor.constraint(equalTo: detailView.trailingAnchor, constant: -30).isActive = true
        memoLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 250), for: .horizontal)
        memoLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        methodTitleStamp.leadingAnchor.constraint(equalTo: methodsView.leadingAnchor, constant: 16).isActive = true
        methodTitleStamp.topAnchor.constraint(equalTo: detailView.bottomAnchor, constant: 16).isActive = true
        methodTitleStamp.heightAnchor.constraint(equalToConstant: 16).isActive = true
        methodTitleStamp.widthAnchor.constraint(equalToConstant: 3).isActive = true
        methodTitle.topAnchor.constraint(equalTo: detailView.bottomAnchor, constant: 16).isActive = true
        methodTitle.leadingAnchor.constraint(equalTo: methodTitleStamp.trailingAnchor, constant: 8).isActive = true

        txtLabel.topAnchor.constraint(equalTo: methodsView.topAnchor, constant: 18).isActive = true
        txtLabel.centerXAnchor.constraint(equalTo: methodsView.centerXAnchor).isActive = true

        tableView.topAnchor.constraint(equalTo: methodTitle.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: methodsView.leadingAnchor, constant: 16).isActive = true
        tableView.trailingAnchor.constraint(equalTo: methodsView.trailingAnchor, constant: -16).isActive = true
        tableView.alwaysBounceVertical = false

        closeButton.topAnchor.constraint(equalTo: methodsView.topAnchor, constant: 19).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: methodsView.trailingAnchor, constant: -30).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)

        getListMethodsAndExecution { methods in
            self.showMethods(methods)
        }
    }

    func getListMethodsAndExecution(execution: (([PaymentMethod]) -> Void)? = nil) {
        showSpinner(onView: view)
        paymentPresentation.getListMethods(onSuccess: { paymentMethods in
            self.removeSpinner()
            self.data = paymentMethods
            execution?(paymentMethods)
        }, onError: { error in
            self.removeSpinner()
            PaymentModalController.isShowCloseModal = false
            self.dismiss(animated: true, completion: { self.onError(error) })
        })
    }

    func showMethods(_ methods: [PaymentMethod]) {
        tableView.reloadData()
        tableView.heightAnchor.constraint(equalToConstant: tableView.contentSize.height).isActive = true
        tableView.alwaysBounceVertical = false
        tableView.isScrollEnabled = true
        updateViewConstraints()
        view.layoutIfNeeded()
        if bottomLayoutGuide.length == 0 {
            bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: tableView.bottomAnchor, constant: 10).isActive = true
        } else {
            let viewHeight = tableView.bounds.size.height
                    + detailView.bounds.size.height
                    + txtLabel.bounds.size.height
                    + methodTitle.bounds.size.height
                    + bottomLayoutGuide.length
            bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: viewHeight).isActive = true
        }
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
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
        NotificationCenter.default.addObserver(self, selector: #selector(PaymentModalController.keyboardWillShowOtp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PaymentModalController.keyboardWillHideOtp), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: securityCode.txtErrorMessage.bottomAnchor, constant: 10).isActive = true
        updateViewConstraints()
        view.layoutIfNeeded()
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .shortForm)
        NotificationCenter.default.addObserver(self, selector: #selector(PaymentModalController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PaymentModalController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        securityCode.otpView.properties.delegate = self
        securityCode.otpView.becomeFirstResponder()
    }

    func setupResult(result: Result) {
        PaymentModalController.isShowCloseModal = false
        if (isShowResultUI == true) {
            view.addSubview(resultView)
            resultView.translatesAutoresizingMaskIntoConstraints = false
            resultView.widthAnchor.constraint(equalToConstant: screenSize.width).isActive = true
            resultView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
            resultView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            resultView.button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
            resultView.closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
            bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: resultView.button.bottomAnchor, constant: 10).isActive = true
            updateViewConstraints()
            view.layoutIfNeeded()
            panModalSetNeedsLayoutUpdate()
            panModalTransition(to: .longForm)
            resultView.animationView.play()
            resultView.adaptView(result: result)
        } else {
            dismiss(animated: true)
        }
    }

    override func viewDidLayoutSubviews() {
        let primaryColor = payMEFunction.configColor[0]
        let secondaryColor = payMEFunction.configColor.count > 1 ? payMEFunction.configColor[1] : primaryColor

        button.applyGradient(colors: [UIColor(hexString: primaryColor).cgColor, UIColor(hexString: secondaryColor).cgColor], radius: 10)
        detailView.applyGradient(colors: [UIColor(hexString: primaryColor).cgColor, UIColor(hexString: secondaryColor).cgColor], radius: 0)
        resultView.button.applyGradient(colors: [UIColor(hexString: primaryColor).cgColor, UIColor(hexString: secondaryColor).cgColor], radius: 10)
        atmController.atmView.button.applyGradient(colors: [UIColor(hexString: primaryColor).cgColor, UIColor(hexString: secondaryColor).cgColor], radius: 10)
    }

    func panModalDidDismiss() {
        if (PaymentModalController.isShowCloseModal == true) {
            onError(["code": PayME.ResponseCode.USER_CANCELLED as AnyObject, "message": "Đóng modal thanh toán" as AnyObject])
        }
    }

    @objc func closeAction(button: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    func pay(_ method: PaymentMethod) {
        if (method.type == "WALLET") {
            if ((method.dataWallet?.balance ?? 0) < orderTransaction.amount) {
                PaymentModalController.isShowCloseModal = false
                dismiss(animated: true, completion: {
                    self.onError(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": "Số dư tài khoản không đủ. Vui lòng kiểm tra lại" as AnyObject])
                })
                return
            }
            view.subviews.forEach {
                $0.removeFromSuperview()
            }
            setupSecurity()
        }
        if (method.type == "LINKED") {
            if (payMEFunction.appEnv.isEqual("SANDBOX")) {
                PaymentModalController.isShowCloseModal = false
                dismiss(animated: true) {
                    self.onError(["code": PayME.ResponseCode.LIMIT as AnyObject, "message": "Chức năng chỉ có thể thao tác môi trường production" as AnyObject])
                }
                return
            }
            view.subviews.forEach {
                $0.removeFromSuperview()
            }
            setupSecurity()
        }
        if (method.type == "BANK_CARD") {
            if (payMEFunction.appEnv.isEqual("SANDBOX")) {
                onError(["message": "Chức năng chỉ có thể thao tác môi trường production" as AnyObject])
                return
            }
            paymentPresentation.getLinkBank()
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

    @objc func onAppEnterForeground(notification: NSNotification) {
        securityCode.otpView.becomeFirstResponder()
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        if securityCode.isDescendant(of: view) {
            bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: securityCode.txtErrorMessage.bottomAnchor, constant: keyboardSize.height + 10).isActive = true
            updateViewConstraints()
            view.layoutIfNeeded()
        }
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if securityCode.isDescendant(of: view) {
            bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: securityCode.txtErrorMessage.bottomAnchor).isActive = true
            updateViewConstraints()
            view.layoutIfNeeded()
        }
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
        price.font = UIFont.systemFont(ofSize: 32, weight: .semibold)
        price.translatesAutoresizingMaskIntoConstraints = false
        return price
    }()

    let memoLabel: UILabel = {
        let memoLabel = UILabel()
        memoLabel.textColor = .white
        memoLabel.backgroundColor = .clear
        memoLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        memoLabel.translatesAutoresizingMaskIntoConstraints = false
        memoLabel.textAlignment = .right
        return memoLabel
    }()

    let methodTitleStamp: UIView = {
        let stamp = UIView(frame: CGRect(x: 0, y: 0, width: 3, height: 16))
        stamp.translatesAutoresizingMaskIntoConstraints = false
        stamp.backgroundColor = UIColor(45, 187, 84)
        return stamp
    }()
    let methodTitle: UILabel = {
        let methodTitle = UILabel()
        methodTitle.textColor = UIColor(11, 11, 11)
        methodTitle.backgroundColor = .clear
        methodTitle.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        methodTitle.translatesAutoresizingMaskIntoConstraints = false
        return methodTitle
    }()

    let contentLabel: UILabel = {
        let contentLabel = UILabel()
        contentLabel.textColor = .white
        contentLabel.backgroundColor = .clear
        contentLabel.font = UIFont.systemFont(ofSize: 15, weight: .light)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        return contentLabel
    }()

    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(for: QRNotFound.self, named: "16Px"), for: .normal)
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
        label.textColor = UIColor(11, 11, 11)
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
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
        cell.configure(with: data[indexPath.row], payMEFunction: payMEFunction, orderTransaction: orderTransaction)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        active = indexPath.row
        orderTransaction.paymentMethod = getMethodSelected()
        pay(data[indexPath.row])
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


