import UIKit
import CommonCrypto
import RxSwift

class PaymentModalController: UINavigationController, PanModalPresentable, UITableViewDelegate, UITableViewDataSource, KAPinFieldDelegate, OTPInputDelegate {
    func pinField(_ field: OTPInput, didFinishWith code: String) {
        if (field == otpView.otpView) {
            showSpinner(onView: view)
            otpView.txtErrorMessage.isHidden = true
            paymentPresentation.transferByLinkedBank(transaction: transaction, orderTransaction: orderTransaction, linkedId: (getMethodSelected().dataLinked?.linkedId)!, OTP: code)
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
    static var minAmount: Int = 10000
    static var maxAmount: Int = 100000000

    var listBank: [Bank] = []
    let otpView = OTPView()
    let securityCode = SecurityCode()
    let atmController: ATMModal
    let confirmationView = ConfirmationModal()
    let resultView = ResultView()
    var keyBoardHeight: CGFloat = 0
    let screenSize: CGRect = UIScreen.main.bounds
    static var isShowCloseModal: Bool = true
    let methodsView = UIView()
    let placeholderView = UIView()
    let activityIndicator = UIActivityIndicatorView(style: .white)

    let payMEFunction: PayMEFunction
    let orderTransaction: OrderTransaction
    let paymentPresentation: PaymentPresentation
    private let disposeBag: DisposeBag
    private var modalHeight: CGFloat? = UIScreen.main.bounds.height

    private var atmHeightConstraint: NSLayoutConstraint?

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
                accessToken: payMEFunction.accessToken, kycState: payMEFunction.kycState,
                onSuccess: onSuccess, onError: onError
        )
        atmController = ATMModal(
                payMEFunction: self.payMEFunction, orderTransaction: self.orderTransaction, isShowResult: self.isShowResultUI,
                paymentPresentation: paymentPresentation, onSuccess: self.onSuccess, onError: self.onError
        )
        disposeBag = DisposeBag()
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        paymentPresentation.onNetworkError = {
            self.removeSpinner()
        }
        view.backgroundColor = .white
        PaymentModalController.isShowCloseModal = true

        setupUI()
        if paymentMethodID != nil {
            setupTargetMethod()
        } else {
            setupMethods()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(PaymentModalController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PaymentModalController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(onAppEnterForeground), name: UIScene.willEnterForegroundNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(onAppEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        }

        setupSubscription()
    }

    private func setupSubscription() {
        payMEFunction.paymentViewModel.paymentSubject
                .observe(on: MainScheduler.asyncInstance)
                .subscribe(onNext: { paymentState in
                    if paymentState.state == State.RESULT {
                        self.setupResult(paymentState.result!)
                    }
                    if paymentState.state == State.CONFIRMATION {
                        self.setupUIConfirmation()
                        self.updateConfirmationInfo(order: paymentState.orderTransaction)
                    }
                    if paymentState.state == State.METHODS {
                        self.showMethods(paymentState.methods ?? self.data)
                    }
                    if paymentState.state == State.ATM {
                        self.setupUIATM(banks: paymentState.banks ?? self.listBank)
                    }
                    if paymentState.state == State.ERROR {
                        self.removeSpinner()
                        let responseError = paymentState.error!
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
                        if responseError.code == ResponseErrorCode.INVALID_OTP {
                            self.otpView.otpView.text = ""
                            self.otpView.otpView.reloadAppearance()
                            self.otpView.txtErrorMessage.text = responseError.message
                            self.otpView.txtErrorMessage.isHidden = false
                            self.panModalSetNeedsLayoutUpdate()
                            self.panModalTransition(to: .longForm)
                        }
                        if responseError.code == ResponseErrorCode.REQUIRED_OTP {
                            self.transaction = responseError.transaction
                            self.methodsView.removeFromSuperview()
                            self.setupOTP()
                        }
                        if responseError.code == ResponseErrorCode.REQUIRED_VERIFY {
                            self.setupWebview(responseError)
                        }
                    }
                }).disposed(by: disposeBag)
    }

    private func setupResult(_ result: Result) {
        removeSpinner()
        setupResultView(result: result)
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
            self.setupResult(result)
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
            self.setupResult(result)
        })
        presentPanModal(webViewController)
    }

    func setupUI() {
        view.addSubview(methodsView)

        methodsView.backgroundColor = .white
        methodsView.translatesAutoresizingMaskIntoConstraints = false
        methodsView.widthAnchor.constraint(equalToConstant: screenSize.width).isActive = true
        methodsView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        methodsView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true

        methodsView.addSubview(closeButton)
        methodsView.addSubview(buttonBack)
        methodsView.addSubview(txtLabel)
        methodsView.addSubview(detailView)
        methodsView.addSubview(methodTitleStamp)
        methodsView.addSubview(methodTitle)
        methodsView.addSubview(tableView)

        atmHeightConstraint = atmController.view.heightAnchor.constraint(equalToConstant: .greatestFiniteMagnitude)
        atmHeightConstraint!.isActive = true

        if !(atmController.view.isHidden) {
            atmController.view.isHidden = true
        }
        UIView.transition(with: methodsView, duration: 0.5, options: [.transitionCrossDissolve, .showHideTransitionViews], animations: {
            self.tableView.isHidden = false
        })

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
        detailView.topAnchor.constraint(equalTo: txtLabel.bottomAnchor, constant: 16).isActive = true

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

        buttonBack.topAnchor.constraint(equalTo: methodsView.topAnchor, constant: 16).isActive = true
        buttonBack.leadingAnchor.constraint(equalTo: methodsView.leadingAnchor, constant: 16).isActive = true
        buttonBack.widthAnchor.constraint(equalToConstant: 24).isActive = true
        buttonBack.heightAnchor.constraint(equalToConstant: 24).isActive = true
        buttonBack.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        buttonBack.isHidden = true

        methodsView.addSubview(confirmationView)
        confirmationView.translatesAutoresizingMaskIntoConstraints = false
        confirmationView.topAnchor.constraint(equalTo: txtLabel.bottomAnchor).isActive = true
        confirmationView.trailingAnchor.constraint(equalTo: methodsView.trailingAnchor).isActive = true
        confirmationView.leadingAnchor.constraint(equalTo: methodsView.leadingAnchor).isActive = true
        confirmationView.isHidden = true

        methodsView.addSubview(atmController.view)
        atmController.view.translatesAutoresizingMaskIntoConstraints = false
        atmController.view.topAnchor.constraint(equalTo: methodTitle.bottomAnchor).isActive = true
        atmController.view.leadingAnchor.constraint(equalTo: methodsView.leadingAnchor).isActive = true
        atmController.view.trailingAnchor.constraint(equalTo: methodsView.trailingAnchor).isActive = true
        atmController.view.isHidden = true

        activityIndicator.color = UIColor(hexString: PayME.configColor[0])
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        methodsView.addSubview(activityIndicator)
        activityIndicator.topAnchor.constraint(equalTo: methodTitle.bottomAnchor, constant: 10).isActive = true
        activityIndicator.leadingAnchor.constraint(equalTo: methodsView.leadingAnchor, constant: 16).isActive = true
        activityIndicator.trailingAnchor.constraint(equalTo: methodsView.trailingAnchor, constant: -16).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 20).isActive = true

        updateViewConstraints()
        view.layoutIfNeeded()
        let viewHeight = txtLabel.bounds.size.height
                + detailView.bounds.size.height
                + methodTitle.bounds.size.height
                + (bottomLayoutGuide.length == 0 ? 16 : 0)
                + 100
        modalHeight = viewHeight
    }

    func setupTargetMethod() {
        getListMethodsAndExecution { methods in
            guard let method = methods.first(where: { $0.methodId == self.paymentMethodID }) else {
                self.onError(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": ("Không tìm thấy phương thức") as AnyObject])
                return
            }
            self.orderTransaction.paymentMethod = method
            self.onPressMethod(method)
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
        getListMethodsAndExecution { methods in
            self.payMEFunction.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.METHODS, methods: methods))
        }
    }

    func getListMethodsAndExecution(execution: (([PaymentMethod]) -> Void)? = nil) {
        paymentPresentation.getListMethods(onSuccess: { paymentMethods in
            self.activityIndicator.removeFromSuperview()
            self.data = paymentMethods
            execution?(paymentMethods)
        }, onError: { error in
            self.removeSpinner()
            PaymentModalController.isShowCloseModal = false
            self.dismiss(animated: true, completion: { self.onError(error) })
        })
    }

    func setupUIATM(banks: [Bank]) {
        confirmationView.isHidden = true
        buttonBack.isHidden = true
        tableView.isHidden = false
        atmController.view.isHidden = false
        detailView.isHidden = false
        methodTitle.isHidden = false
        methodTitleStamp.isHidden = false
        methodsView.backgroundColor = .white
        txtLabel.text = "Thanh toán"
        atmController.atmView.methodView.buttonTitle = paymentMethodID != nil ? nil : "Thay đổi"
        atmController.atmView.methodView.updateUI()

        listBank = banks
        atmController.setListBank(listBank: banks)
        tableView.isHidden = true
        UIScrollView.transition(with: methodsView, duration: 0.5, options: [.transitionCrossDissolve, .showHideTransitionViews], animations: {
            self.atmController.view.isHidden = false
        })

        let realATMViewHeight = min(screenSize.size.height - (topLayoutGuide.length + detailView.bounds.size.height
                + txtLabel.bounds.size.height
                + methodTitle.bounds.size.height + 50
                + (bottomLayoutGuide.length == 0 ? 16 : 0)), atmController.atmView.contentSize.height)
        let viewHeight = realATMViewHeight
                + detailView.bounds.size.height
                + txtLabel.bounds.size.height
                + methodTitle.bounds.size.height + 50
                + (bottomLayoutGuide.length == 0 ? 16 : 0)
        modalHeight = viewHeight
        atmHeightConstraint?.constant = realATMViewHeight
        updateViewConstraints()
        view.layoutIfNeeded()
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
    }

    func showMethods(_ methods: [PaymentMethod]) {
        view.endEditing(false)
        confirmationView.isHidden = true
        atmController.view.isHidden = true
        buttonBack.isHidden = true
        UIView.transition(with: methodsView, duration: 0.5, options: [.transitionCrossDissolve, .showHideTransitionViews]) {
            self.tableView.isHidden = false
            self.detailView.isHidden = false
            self.methodTitle.isHidden = false
            self.methodTitleStamp.isHidden = false
        }
        methodsView.backgroundColor = .white
        txtLabel.text = "Thanh toán"
        tableView.heightAnchor.constraint(equalToConstant: CGFloat.greatestFiniteMagnitude).isActive = true
        tableView.reloadData()
        tableView.layoutIfNeeded()
        let tableViewHeight = min(tableView.contentSize.height, screenSize.height - (topLayoutGuide.length + detailView.bounds.size.height
                + txtLabel.bounds.size.height
                + methodTitle.bounds.size.height + 100))
        tableView.heightAnchor.constraint(equalToConstant: tableViewHeight).isActive = true
        tableView.alwaysBounceVertical = false
        tableView.isScrollEnabled = true
        updateViewConstraints()
        view.layoutIfNeeded()
        let viewHeight = tableView.bounds.size.height
                + detailView.bounds.size.height
                + txtLabel.bounds.size.height
                + methodTitle.bounds.size.height + 50
                + (bottomLayoutGuide.length == 0 ? 16 : 0)
        modalHeight = viewHeight
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
    }

    func setupUIConfirmation() {
        view.endEditing(false)

        UIView.transition(with: confirmationView, duration: 0.5, options: [.transitionCrossDissolve, .showHideTransitionViews], animations: {
            self.confirmationView.isHidden = false
        })
        tableView.isHidden = true
        atmController.view.isHidden = true
        detailView.isHidden = true
        methodTitle.isHidden = true
        methodTitleStamp.isHidden = true
        methodsView.backgroundColor = UIColor(239, 242, 247)
        txtLabel.text = "Xác nhận thanh toán"
        buttonBack.isHidden = paymentMethodID != nil ? true : false
    }

    func updateConfirmationInfo(order: OrderTransaction?) {
        confirmationView.reset()
        if let orderTransaction = order {
            confirmationView.setPaymentInfo(paymentInfo: [
                ["key": "Dịch vụ", "value": "\(orderTransaction.storeName)"],
                ["key": "Số tiền thanh toán", "value": "\(formatMoney(input: orderTransaction.amount)) đ", "color": UIColor(12, 170, 38)],
                ["key": "Nội dung", "value": orderTransaction.note]
            ])
            switch (orderTransaction.paymentMethod?.type) {
            case MethodType.WALLET.rawValue:
                confirmationView.setServiceInfo(serviceInfo: [
                    ["key": "Phương thức", "value": "Số dư ví"],
                    ["key": "Phí", "value": (orderTransaction.paymentMethod?.fee ?? 0) > 0 ? "\(String(describing: formatMoney(input: orderTransaction.paymentMethod?.fee ?? 0))) đ" : "Miễn phí"],
                    ["key": "Tổng thanh toán", "value": "\(String(describing: formatMoney(input: orderTransaction.total ?? 0))) đ", "font": UIFont.systemFont(ofSize: 20, weight: .medium), "color": UIColor.red]
                ])
                confirmationView.onPressConfirm = {
                    if (orderTransaction.paymentMethod?.dataWallet?.balance ?? 0) < orderTransaction.amount {
                        PaymentModalController.isShowCloseModal = false
                        self.dismiss(animated: true, completion: {
                            self.onError(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": "Số dư tài khoản không đủ. Vui lòng kiểm tra lại" as AnyObject])
                        })
                        return
                    }
                    self.setupSecurity()
                }
                break
            case MethodType.LINKED.rawValue:
                confirmationView.setServiceInfo(serviceInfo: [
                    ["key": "Phương thức", "value": "Tài khoản liên kết"],
                    ["key": "Số tài khoản", "value": "\(String(describing: orderTransaction.paymentMethod?.title ?? ""))-\(String(describing: orderTransaction.paymentMethod!.label.suffix(4)))"],
                    ["key": "Phí", "value": (orderTransaction.paymentMethod?.fee ?? 0) > 0 ? "\(String(describing: formatMoney(input: orderTransaction.paymentMethod?.fee ?? 0))) đ" : "Miễn phí"],
                    ["key": "Số tiền trừ ví", "value": "\(String(describing: formatMoney(input: orderTransaction.total ?? 0))) đ", "font": UIFont.systemFont(ofSize: 20, weight: .medium), "color": UIColor.red]
                ])
                confirmationView.onPressConfirm = {
                    if (self.payMEFunction.appEnv.isEqual("SANDBOX")) {
                        PaymentModalController.isShowCloseModal = false
                        self.dismiss(animated: true) {
                            self.onError(["code": PayME.ResponseCode.LIMIT as AnyObject, "message": "Chức năng chỉ có thể thao tác môi trường production" as AnyObject])
                        }
                        return
                    }
                    self.setupSecurity()
                }
                break
            case MethodType.BANK_CARD.rawValue:
                confirmationView.setServiceInfo(serviceInfo: [
                    ["key": "Phương thức", "value": "Thẻ ATM nội địa"],
                    ["key": "Ngân hàng", "value": String(describing: orderTransaction.paymentMethod?.dataBank?.bank?.shortName ?? "N/A")],
                    ["key": "Số thẻ ATM", "value": String(describing: orderTransaction.paymentMethod?.dataBank?.cardNumberFormatted() ?? "N/A")],
                    ["key": "Họ tên chủ thẻ", "value": String(describing: orderTransaction.paymentMethod?.dataBank?.cardHolder ?? "N/A")],
                    ["key": "Phí", "value": (orderTransaction.paymentMethod?.fee ?? 0) > 0 ? "\(String(describing: formatMoney(input: orderTransaction.paymentMethod?.fee ?? 0))) đ" : "Miễn phí"],
                    ["key": "Số tiền trừ ví", "value": "\(String(describing: formatMoney(input: orderTransaction.total ?? 0))) đ", "font": UIFont.systemFont(ofSize: 20, weight: .medium), "color": UIColor.red]
                ])
                confirmationView.onPressConfirm = {
                    self.showSpinner(onView: self.view)
                    self.paymentPresentation.payATM(orderTransaction: orderTransaction)
                }
            default: break
            }
            updateViewConstraints()
            view.layoutIfNeeded()
            let viewHeight = txtLabel.bounds.size.height
                    + confirmationView.bounds.size.height
                    + (bottomLayoutGuide.length == 0 ? 16 : 0)
            modalHeight = viewHeight
            panModalSetNeedsLayoutUpdate()
            panModalTransition(to: .longForm)
        }
    }

    func setupOTP() {
        view.addSubview(otpView)

        otpView.updateBankName(name: orderTransaction.paymentMethod?.title ?? "")
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
        otpView.otpView.properties.delegate = self
        otpView.otpView.becomeFirstResponder()
        otpView.startCountDown(from: 60)
        otpView.onPressSendOTP = {
            print("HIHIHIHIHIHIHIHI")
            self.otpView.startCountDown(from: 120)
        }
    }

    func setupSecurity() {
        methodsView.isHidden = true
        view.addSubview(securityCode)

        securityCode.translatesAutoresizingMaskIntoConstraints = false
        securityCode.widthAnchor.constraint(equalToConstant: screenSize.width).isActive = true
        securityCode.heightAnchor.constraint(equalTo: methodsView.heightAnchor).isActive = true
        securityCode.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        securityCode.closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        updateViewConstraints()
        view.layoutIfNeeded()
        securityCode.otpView.properties.delegate = self
        securityCode.otpView.becomeFirstResponder()
        securityCode.onPressForgot = {
            PayME.currentVC!.dismiss(animated: true)
            self.payMEFunction.openWallet(
                    false, PayME.currentVC!, PayME.Action.FORGOT_PASSWORD, nil, nil,
                    nil, "", false, { dictionary in },
                    { dictionary in }
            )
        }
        let contentRect: CGRect = securityCode.subviews.reduce(into: .zero) { rect, view in
            rect = rect.union(view.frame)
        }
        modalHeight = screenSize.height / 3 + contentRect.height
        updateViewConstraints()
        view.layoutIfNeeded()
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
    }

    func setupResultView(result: Result) {
        view.endEditing(false)
        PaymentModalController.isShowCloseModal = false
        if (isShowResultUI == true) {
            view.addSubview(resultView)
            resultView.translatesAutoresizingMaskIntoConstraints = false
            resultView.widthAnchor.constraint(equalToConstant: screenSize.width).isActive = true
            resultView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
            resultView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            resultView.button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
//            resultView.closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
            resultView.adaptView(result: result)
            modalHeight = resultView.frame.size.height
            updateViewConstraints()
            view.layoutIfNeeded()
            panModalSetNeedsLayoutUpdate()
            panModalTransition(to: .longForm)
            resultView.animationView.play()
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
        confirmationView.button.applyGradient(colors: [UIColor(hexString: primaryColor).cgColor, UIColor(hexString: secondaryColor).cgColor], radius: 10)
    }

    func panModalDidDismiss() {
        if (PaymentModalController.isShowCloseModal == true) {
            onError(["code": PayME.ResponseCode.USER_CANCELLED as AnyObject, "message": "Đóng modal thanh toán" as AnyObject])
        }
    }

    @objc func closeAction(button: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @objc func goBack() {
        if (orderTransaction.paymentMethod?.type == MethodType.BANK_CARD.rawValue) {
            payMEFunction.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.ATM))
        } else {
            payMEFunction.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.METHODS))
        }
    }

    private func openWallet(action: PayME.Action, amount: Int? = nil, payMEFunction: PayMEFunction, orderTransaction: OrderTransaction) {
        PayME.currentVC!.dismiss(animated: true)
        payMEFunction.openWallet(
                false, PayME.currentVC!, action, amount, orderTransaction.note,
                orderTransaction.extraData, "", false, { dictionary in },
                { dictionary in }
        )
    }

    func onPressMethod(_ method: PaymentMethod) {
        print("\(method.type)")
        switch method.type {
        case MethodType.WALLET.rawValue:
            if payMEFunction.accessToken == "" {
                openWallet(action: PayME.Action.OPEN, payMEFunction: payMEFunction, orderTransaction: orderTransaction)
            } else if payMEFunction.kycState != "APPROVED" {
                PayME.currentVC?.dismiss(animated: true) {
                    self.payMEFunction.KYC(PayME.currentVC!, { dictionary in }, { dictionary in })
                }
            } else {
                let balance = method.dataWallet?.balance ?? 0
                if balance < orderTransaction.amount {
                    openWallet(action: PayME.Action.DEPOSIT, amount: orderTransaction.amount - balance, payMEFunction: payMEFunction, orderTransaction: orderTransaction)
                } else {
                    paymentPresentation.getFee(orderTransaction: orderTransaction)
                }
            }
            break
        case MethodType.LINKED.rawValue:
            paymentPresentation.getFee(orderTransaction: orderTransaction)
            break
        case MethodType.BANK_CARD.rawValue:
            if (payMEFunction.appEnv.isEqual("SANDBOX")) {
                onError(["message": "Chức năng chỉ có thể thao tác môi trường production" as AnyObject])
                return
            }
            paymentPresentation.getLinkBank()
            break
        default:
            toastMessError(title: "", message: "Tính năng đang được xây dựng.") { [self] alertAction in
                if paymentMethodID != nil {
                    dismiss(animated: true)
                }
            }
        }
    }

    @objc func onAppEnterForeground(notification: NSNotification) {
        if securityCode.isDescendant(of: view) && !resultView.isDescendant(of: view) {
            securityCode.otpView.becomeFirstResponder()
        }
        if otpView.isDescendant(of: view) && !resultView.isDescendant(of: view) {
            otpView.otpView.becomeFirstResponder()
        }
        if !atmController.view.isHidden {
            atmController.atmView.cardInput.textInput.becomeFirstResponder()
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        if otpView.isDescendant(of: view) {
            let contentRect: CGRect = otpView.subviews.reduce(into: .zero) { rect, view in
                rect = rect.union(view.frame)
            }

            modalHeight = keyboardSize.height + 10 + contentRect.height
        }
        if securityCode.isDescendant(of: view) {
            let contentRect: CGRect = securityCode.subviews.reduce(into: .zero) { rect, view in
                rect = rect.union(view.frame)
            }
            modalHeight = keyboardSize.height + 10 + contentRect.height
        }
        if methodsView.isDescendant(of: view) && atmController.view.isDescendant(of: methodsView) {
            let contentRect: CGRect = methodsView.subviews.reduce(into: .zero) { rect, view in
                rect = rect.union(view.frame)
            }

            var newATMHeight: CGFloat = 0
            if #available(iOS 11.0, *) {
                modalHeight = min(keyboardSize.height + 10 + contentRect.height, view.safeAreaLayoutGuide.layoutFrame.height)
                newATMHeight = min(modalHeight! - (detailView.bounds.size.height
                        + txtLabel.bounds.size.height
                        + methodTitle.bounds.size.height + 40
                        + keyboardSize.height + 10
                        + (bottomLayoutGuide.length == 0 ? 16 : 0)), atmController.atmView.contentSize.height)

            } else {
                modalHeight = min(keyboardSize.height + 10 + contentRect.height, screenSize.height)
                newATMHeight = min(modalHeight! - (detailView.bounds.size.height
                        + txtLabel.bounds.size.height
                        + methodTitle.bounds.size.height + 70
                        + keyboardSize.height + 10
                        + (bottomLayoutGuide.length == 0 ? 16 : 0)), atmController.atmView.contentSize.height)
            }
            atmHeightConstraint?.constant = newATMHeight
        }
        updateViewConstraints()
        view.layoutIfNeeded()
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if securityCode.isDescendant(of: view) {
            let contentRect: CGRect = securityCode.subviews.reduce(into: .zero) { rect, view in
                rect = rect.union(view.frame)
            }
            modalHeight = contentRect.height
        }
        if otpView.isDescendant(of: view) {
            let contentRect: CGRect = otpView.subviews.reduce(into: .zero) { rect, view in
                rect = rect.union(view.frame)
            }
            modalHeight = contentRect.height
        }
        if methodsView.isDescendant(of: view) && atmController.view.isDescendant(of: methodsView) {
        }
        updateViewConstraints()
        view.layoutIfNeeded()
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .shortForm)
    }

    func toastMessError(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: handler))
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

    let buttonBack: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(for: PaymentModalController.self, named: "32Px"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
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
        if modalHeight == nil {
            return PanModalHeight.intrinsicHeight
        }
        return .contentHeight(modalHeight!)
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

    var cornerRadius: CGFloat {
        26
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
        cell.contentView.isUserInteractionEnabled = false
        cell.configure(with: data[indexPath.row], payMEFunction: payMEFunction, orderTransaction: orderTransaction)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        active = indexPath.row
        orderTransaction.paymentMethod = getMethodSelected()
        onPressMethod(data[indexPath.row])
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


