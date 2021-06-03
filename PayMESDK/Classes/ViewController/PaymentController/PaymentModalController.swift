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
    private var tableHeightConstraint: NSLayoutConstraint?
    private var methodsBottomConstraint: NSLayoutConstraint?

    let orderView: OrderView

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
        orderView = OrderView(amount: self.orderTransaction.amount, storeName: self.orderTransaction.storeName,
                serviceCode: self.orderTransaction.orderId,
                note: orderTransaction.note == "" ? "Không có nội dung" : self.orderTransaction.note,
                logoUrl: self.orderTransaction.storeImage)
        disposeBag = DisposeBag()
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        paymentPresentation.onNetworkError = {
            self.removeSpinner()
        }
        view.backgroundColor = UIColor(239, 242, 247)
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
                        self.setupUIFee(order: paymentState.orderTransaction)
//                        self.updateConfirmationInfo(order: paymentState.orderTransaction)
                    }
                    if paymentState.state == State.METHODS {
                        self.showMethods(paymentState.methods ?? self.data)
                    }
                    if paymentState.state == State.ATM {
                        self.setupUIConfirm(banks: paymentState.banks ?? self.listBank, order: paymentState.orderTransaction)
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
                        if responseError.code == ResponseErrorCode.OVER_QUOTA {
                            self.toastMessError(title: "Thông báo", message: responseError.message) { [self] alertAction in
                                if paymentMethodID != nil {
                                    dismiss(animated: true)
                                }
                            }
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
        view.addSubview(footer)
        view.addSubview(methodsView)

        methodsView.backgroundColor = .white
        methodsView.translatesAutoresizingMaskIntoConstraints = false

        methodsView.topAnchor.constraint(equalTo:view.topAnchor).isActive = true
        methodsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        methodsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        methodsView.addSubview(orderView)
        methodsView.addSubview(methodTitle)
        methodsView.addSubview(tableView)

        orderView.topAnchor.constraint(equalTo: methodsView.topAnchor).isActive = true
        orderView.leadingAnchor.constraint(equalTo: methodsView.leadingAnchor).isActive = true
        orderView.trailingAnchor.constraint(equalTo: methodsView.trailingAnchor).isActive = true

        methodTitle.text = "Nguồn thanh toán"
        methodTitle.leadingAnchor.constraint(equalTo: methodsView.leadingAnchor, constant: 16).isActive = true
        methodTitle.topAnchor.constraint(equalTo: orderView.bottomAnchor, constant: 12).isActive = true

        tableView.register(Method.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self

        if !(atmController.view.isHidden) {
            atmController.view.isHidden = true
        }
        UIView.transition(with: methodsView, duration: 0.5, options: [.transitionCrossDissolve, .showHideTransitionViews], animations: {
            self.tableView.isHidden = false
        })
        tableView.topAnchor.constraint(equalTo: methodTitle.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: methodsView.leadingAnchor, constant: 16).isActive = true
        tableView.trailingAnchor.constraint(equalTo: methodsView.trailingAnchor, constant: -16).isActive = true
        tableView.alwaysBounceVertical = false

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
        activityIndicator.topAnchor.constraint(equalTo: methodTitle.bottomAnchor, constant: 16).isActive = true
        activityIndicator.leadingAnchor.constraint(equalTo: methodsView.leadingAnchor, constant: 16).isActive = true
        activityIndicator.trailingAnchor.constraint(equalTo: methodsView.trailingAnchor, constant: -16).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 20).isActive = true

        methodsBottomConstraint = methodsView.bottomAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 16)
        methodsBottomConstraint?.isActive = true

        footer.topAnchor.constraint(equalTo: methodsView.bottomAnchor).isActive = true
        footer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        footer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true

        updateViewConstraints()
        view.layoutIfNeeded()

        let viewHeight = methodsView.bounds.size.height
                + footer.bounds.size.height
                + (bottomLayoutGuide.length > 0 ? 0 : 16)
        modalHeight = viewHeight
    }

    func setupTargetMethod() {
        getListMethodsAndExecution { methods in
            guard let method = methods.first(where: { $0.methodId == self.paymentMethodID }) else {
                self.onError(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": ("Không tìm thấy phương thức") as AnyObject])
                return
            }
            self.orderTransaction.paymentMethod = method
            self.onPressMethod(method, isTarget: true)
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

    func setupUIConfirm(banks: [Bank], order: OrderTransaction?) {
        atmController.atmView.methodView.buttonTitle = paymentMethodID != nil ? nil : "Thay đổi"
        if let orderTransaction = order {
            atmController.atmView.updateUIByMethod(orderTransaction.paymentMethod!)
        }
        listBank = banks
        atmController.setListBank(listBank: banks)
        tableView.isHidden = true
        UIScrollView.transition(with: methodsView, duration: 0.5, options: [.transitionCrossDissolve, .showHideTransitionViews], animations: {
            self.atmController.view.isHidden = false
        })

        if (atmHeightConstraint?.constant == nil) {
            atmHeightConstraint = atmController.view.heightAnchor.constraint(equalToConstant: .greatestFiniteMagnitude)
            atmHeightConstraint?.isActive = true
        }
        atmController.view.layoutIfNeeded()
        let atmHeight = min(atmController.atmView.contentSize.height, screenSize.height - (orderView.bounds.size.height + 12
                + methodTitle.bounds.size.height
                + footer.bounds.size.height
                + (bottomLayoutGuide.length != 0 ? bottomLayoutGuide.length : 16)))
        atmHeightConstraint?.constant = atmHeight
        methodsBottomConstraint?.isActive = false
        methodsBottomConstraint = methodsView.bottomAnchor.constraint(equalTo: atmController.view.bottomAnchor, constant: 16)
        methodsBottomConstraint?.isActive = true
        updateViewConstraints()
        view.layoutIfNeeded()
        let viewHeight = methodsView.bounds.size.height
                + footer.bounds.size.height
                + (bottomLayoutGuide.length > 0 ? 0 : 16)
        modalHeight = viewHeight
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
    }

    func showMethods(_ methods: [PaymentMethod]) {
        view.endEditing(false)
        atmController.view.isHidden = true
        UIView.transition(with: methodsView, duration: 0.5, options: [.transitionCrossDissolve, .showHideTransitionViews]) {
            self.tableView.isHidden = false
        }
        if (tableHeightConstraint?.constant == nil) {
            tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: CGFloat.greatestFiniteMagnitude)
            tableHeightConstraint?.isActive = true
            tableView.reloadData()
            tableView.layoutIfNeeded()
            let tableViewHeight = min(tableView.contentSize.height, screenSize.height - (orderView.bounds.size.height + 12
                    + methodTitle.bounds.size.height
                    + footer.bounds.size.height
                    + (bottomLayoutGuide.length != 0 ? bottomLayoutGuide.length : 16)))
            tableHeightConstraint?.constant = tableViewHeight
        }

        methodsBottomConstraint?.isActive = false
        methodsBottomConstraint =  methodsView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16)
        methodsBottomConstraint?.isActive = true

        updateViewConstraints()
        view.layoutIfNeeded()
        let viewHeight = methodsView.bounds.size.height
                + footer.bounds.size.height
                + (bottomLayoutGuide.length > 0 ? 0 : 16)
        modalHeight = viewHeight
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
    }

    func setupUIFee(order: OrderTransaction?) {
        view.endEditing(false)
        if let orderTrans = order {
            atmController.atmView.updatePaymentInfo([
                ["key": "Phí", "value": (orderTrans.paymentMethod?.fee ?? 0) > 0 ? "\(String(describing: formatMoney(input: orderTrans.paymentMethod?.fee ?? 0))) đ" : "Miễn phí"],
                ["key": "Tổng thanh toán", "value": "\(String(describing: formatMoney(input: orderTrans.total ?? 0))) đ", "font": UIFont.systemFont(ofSize: 20, weight: .medium), "color": UIColor.red]
            ])
            atmController.view.layoutIfNeeded()
            let atmHeight = min(atmController.atmView.contentSize.height, screenSize.height - (orderView.bounds.size.height + 12
                    + methodTitle.bounds.size.height
                    + footer.bounds.size.height
                    + (bottomLayoutGuide.length != 0 ? bottomLayoutGuide.length : 16)))
            atmHeightConstraint?.constant = atmHeight
            updateViewConstraints()
            view.layoutIfNeeded()
            let viewHeight = methodsView.bounds.size.height
                    + footer.bounds.size.height
                    + (bottomLayoutGuide.length > 0 ? 0 : 16)
            modalHeight = viewHeight
            panModalSetNeedsLayoutUpdate()
            panModalTransition(to: .longForm)

            switch orderTrans.paymentMethod?.type {
            case MethodType.WALLET.rawValue:
                atmController.payActionByMethod = {
                    self.setupSecurity()
                }
                break
            case MethodType.LINKED.rawValue:
                atmController.payActionByMethod = {
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
            default: break
            }
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

        orderView.applyGradient(colors: [UIColor(hexString: primaryColor).cgColor, UIColor(hexString: secondaryColor).cgColor], radius: 0)
        button.applyGradient(colors: [UIColor(hexString: primaryColor).cgColor, UIColor(hexString: secondaryColor).cgColor], radius: 10)
        resultView.button.applyGradient(colors: [UIColor(hexString: primaryColor).cgColor, UIColor(hexString: secondaryColor).cgColor], radius: 10)
        atmController.atmView.button.applyGradient(colors: [UIColor(hexString: primaryColor).cgColor, UIColor(hexString: secondaryColor).cgColor], radius: 10)
//        confirmationView.button.applyGradient(colors: [UIColor(hexString: primaryColor).cgColor, UIColor(hexString: secondaryColor).cgColor], radius: 10)
    }

    func panModalDidDismiss() {
        if (PaymentModalController.isShowCloseModal == true) {
            onError(["code": PayME.ResponseCode.USER_CANCELLED as AnyObject, "message": "Đóng modal thanh toán" as AnyObject])
        }
    }

    @objc func closeAction(button: UIButton) {
        dismiss(animated: true, completion: nil)
    }

//    @objc func goBack() {
//        if (orderTransaction.paymentMethod?.type == MethodType.BANK_CARD.rawValue) {
//            payMEFunction.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.ATM))
//        } else {
//            payMEFunction.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.METHODS))
//        }
//    }

    private func openWallet(action: PayME.Action, amount: Int? = nil, payMEFunction: PayMEFunction, orderTransaction: OrderTransaction) {
        PayME.currentVC!.dismiss(animated: true)
        payMEFunction.openWallet(
                false, PayME.currentVC!, action, amount, orderTransaction.note,
                orderTransaction.extraData, "", false, { dictionary in },
                { dictionary in }
        )
    }

    func onPressMethod(_ method: PaymentMethod, isTarget: Bool = false) {
        switch method.type {
        case MethodType.WALLET.rawValue:
            if payMEFunction.accessToken == "" {
                if isTarget == true {
                    onError(["code": PayME.ResponseCode.ACCOUNT_NOT_ACTIVATED as AnyObject, "message": "Tài khoản chưa kích hoạt" as AnyObject])
                    dismiss(animated: true, completion: nil)
                    return
                }
                openWallet(action: PayME.Action.OPEN, payMEFunction: payMEFunction, orderTransaction: orderTransaction)
            } else if payMEFunction.kycState != "APPROVED" {
                if isTarget == true {
                    onError(["code": PayME.ResponseCode.ACCOUNT_NOT_KYC as AnyObject, "message": "Tài khoản chưa định danh" as AnyObject])
                    dismiss(animated: true, completion: nil)
                    return
                }
                PayME.currentVC?.dismiss(animated: true) {
                    self.payMEFunction.KYC(PayME.currentVC!, { }, { dictionary in })
                }
            } else {
                let balance = method.dataWallet?.balance ?? 0
                if balance < orderTransaction.amount {
                    if isTarget == true {
                        onError(["code": PayME.ResponseCode.BALANCE_ERROR as AnyObject, "message": "Số dư tài khoản không đủ. Vui lòng kiểm tra lại" as AnyObject])
                        dismiss(animated: true, completion: nil)
                        return
                    }
                    openWallet(action: PayME.Action.DEPOSIT, amount: orderTransaction.amount - balance, payMEFunction: payMEFunction, orderTransaction: orderTransaction)
                } else {
                    payMEFunction.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.ATM, banks: nil, orderTransaction: orderTransaction))
                    paymentPresentation.getFee(orderTransaction: orderTransaction)
                }
            }
            break
        case MethodType.LINKED.rawValue:
            paymentPresentation.getFee(orderTransaction: orderTransaction)
            payMEFunction.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.ATM, banks: nil, orderTransaction: orderTransaction))
            break
        case MethodType.BANK_CARD.rawValue:
            if (payMEFunction.appEnv.isEqual("SANDBOX")) {
                onError(["message": "Chức năng chỉ có thể thao tác môi trường production" as AnyObject])
                return
            }
            paymentPresentation.getLinkBank(orderTransaction: orderTransaction)
            paymentPresentation.getFee(orderTransaction: orderTransaction)
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
            if #available(iOS 11.0, *) {
                modalHeight = min(keyboardSize.height + methodsView.bounds.size.height + footer.bounds.size.height,
                        view.safeAreaLayoutGuide.layoutFrame.height)
            } else {
                modalHeight = min(keyboardSize.height + methodsView.bounds.size.height + footer.bounds.size.height, screenSize.height)
            }
            let newATMHeight = min(atmController.atmView.contentSize.height, modalHeight! - (orderView.bounds.size.height + 12
                    + methodTitle.bounds.size.height
                    + footer.bounds.size.height
                    + keyboardSize.height
                    + (bottomLayoutGuide.length > 0 ? bottomLayoutGuide.length : 16)))
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

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = true
        return tableView
    }()

    let methodTitle: UILabel = {
        let methodTitle = UILabel()
        methodTitle.textColor = UIColor(11, 11, 11)
        methodTitle.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        methodTitle.translatesAutoresizingMaskIntoConstraints = false
        return methodTitle
    }()

    let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        return button
    }()

    let footer = PaymeLogoView()

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


