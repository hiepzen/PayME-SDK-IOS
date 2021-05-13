//
//  File.swift
//  PayMESDK
//
//  Created by HuyOpen on 11/6/20.
//

import UIKit
import Lottie
import RxSwift


class ATMModal: UIViewController, PanModalPresentable, UITextFieldDelegate {
    let screenSize: CGRect = UIScreen.main.bounds
    var atmView = ATMView()
    var keyboardHeight: CGFloat = 0
    var listBank: [Bank] = []
    var bankDetect: Bank?
    var onError: (([String: AnyObject]) -> ())? = nil
    var onSuccess: (([String: AnyObject]) -> ())? = nil
    var bankName: String = ""
    let resultView = ResultView()
    var result = false
    let payMEFunction: PayMEFunction
    let orderTransaction: OrderTransaction
    let isShowResultUI: Bool

    public let resultSubject : PublishSubject<Result> = PublishSubject()
    private let disposeBag = DisposeBag()

    init(payMEFunction: PayMEFunction, listBank: [Bank] = [], orderTransaction: OrderTransaction, isShowResult: Bool,
         onSuccess: (([String: AnyObject]) -> ())? = nil, onError: (([String: AnyObject]) -> ())? = nil) {
        self.payMEFunction = payMEFunction
        self.listBank = listBank
        self.onSuccess = onSuccess
        self.onError = onError
        self.orderTransaction = orderTransaction
        self.isShowResultUI = isShowResult

        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        PaymentModalController.isShowCloseModal = true
        view.backgroundColor = .white
        atmView.price.text = "\(formatMoney(input: orderTransaction.amount)) đ"
        contentLabel.text = "Nội dung"
        if (orderTransaction.note == "") {
            atmView.memoLabel.text = "Không có nội dung"
        } else {
            atmView.memoLabel.text = orderTransaction.note
        }

        view.addSubview(scrollView)
        scrollView.backgroundColor = .white
        atmView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(atmView)

        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.heightAnchor.constraint(equalToConstant: 500).isActive = true

        atmView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        atmView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        atmView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        atmView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        // this is important for scrolling
        atmView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

        atmView.cardNumberField.delegate = self
        atmView.dateField.delegate = self

        atmView.button.addTarget(self, action: #selector(payATM), for: .touchUpInside)
        atmView.closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)


        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(onAppEnterBackground), name: UIScene.willDeactivateNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(onAppEnterBackground), name: UIApplication.willResignActiveNotification, object: nil)
        }

        setupBinding()
    }

    private func setupBinding() {
        resultSubject.observe(on: MainScheduler.instance).bind(to: resultView.resultSubject).disposed(by: disposeBag)
    }

    override func viewDidLayoutSubviews() {
        let topPoint = CGPoint(x: atmView.detailView.bounds.minX - 10, y: atmView.detailView.bounds.midY + 15)
        let bottomPoint = CGPoint(x: atmView.detailView.bounds.maxX, y: atmView.detailView.bounds.midY + 15)
        atmView.detailView.createDashedLine(from: topPoint, to: bottomPoint, color: UIColor(203, 203, 203), strokeLength: 3, gapLength: 4, width: 0.5)

        let primaryColor = payMEFunction.configColor[0]
        let secondaryColor = payMEFunction.configColor.count > 1 ? payMEFunction.configColor[1] : primaryColor
        atmView.detailView.applyGradient(colors: [UIColor(hexString: primaryColor).cgColor, UIColor(hexString: secondaryColor).cgColor], radius: 0)
        atmView.button.applyGradient(colors: [UIColor(hexString: primaryColor).cgColor, UIColor(hexString: secondaryColor).cgColor], radius: 10)
        resultView.button.applyGradient(colors: [UIColor(hexString: primaryColor).cgColor, UIColor(hexString: secondaryColor).cgColor], radius: 10)
    }

    func panModalDidDismiss() {
        if (PaymentModalController.isShowCloseModal == true) {
            onError!(["code": PayME.ResponseCode.USER_CANCELLED as AnyObject, "message": "Đóng modal thanh toán" as AnyObject])
        }
    }

    @objc func closeAction() {
        dismiss(animated: true, completion: nil)

    }

    @objc func payATM() {
        let cardNumber = atmView.cardNumberField.text
        let cardHolder = atmView.nameField.text
        let issuedAt = atmView.dateField.text
        if (bankDetect != nil) {
            if (cardNumber!.count != bankDetect!.cardNumberLength) {
                toastMessError(title: "Lỗi", message: "Vui lòng nhập mã thẻ đúng định dạng")
                return
            }
        } else {
            toastMessError(title: "Lỗi", message: "Vui lòng nhập mã thẻ đúng định dạng")
            return
        }
        if (cardHolder == nil) {
            toastMessError(title: "Lỗi", message: "Vui lòng nhập họ tên chủ thẻ")
            return
        } else {
            if (cardHolder!.count == 0) {
                toastMessError(title: "Lỗi", message: "Vui lòng nhập họ tên chủ thẻ")
                return
            }
        }
        if (issuedAt!.count != 5) {
            toastMessError(title: "Lỗi", message: "Vui lòng nhập ngày phát hành thẻ")
            return
        } else {
            let dateArr = issuedAt!.components(separatedBy: "/")
            let month = Int(dateArr[0]) ?? 0
            let year = Int(dateArr[1]) ?? 0
            if (month == 0 || year == 0 || month > 12 || year > 21 || month <= 0) {
                toastMessError(title: "Lỗi", message: "Vui lòng nhập ngày phát hành thẻ hợp lệ")
                return
            }
            let date = "20" + dateArr[1] + "-" + dateArr[0] + "-01T00:00:00.000Z"
            showSpinner(onView: view)
            payMEFunction.request.transferATM(
                    storeId: orderTransaction.storeId, orderId: orderTransaction.orderId, extraData: orderTransaction.extraData, note: orderTransaction.note,
                    cardNumber: cardNumber!, cardHolder: cardHolder!, issuedAt: date, amount: orderTransaction.amount,
                    onSuccess: { success in
                        print(success)
                        let payment = success["OpenEWallet"]!["Payment"] as! [String: AnyObject]
                        if let payInfo = payment["Pay"] as? [String: AnyObject] {
                            var formatDate = ""
                            var transactionNumber = ""
                            var cardNumber = ""
                            if let history = payInfo["history"] as? [String: AnyObject] {
                                if let createdAt = history["createdAt"] as? String {
                                    if let date = toDate(dateString: createdAt) {
                                        formatDate = toDateString(date: date)
                                    }
                                }
                                if let payment = history["payment"] as? [String: AnyObject] {
                                    if let transaction = payment["transaction"] as? String {
                                        transactionNumber = transaction
                                    }
                                    if let description = payment["description"] as? String {
                                        cardNumber = description
                                    }
                                }
                            }
                            let succeeded = payInfo["succeeded"] as! Bool
                            if (succeeded == true) {
                                let paymentInfo = payInfo["history"]!["payment"] as! [String: AnyObject]
                                let responseSuccess = [
                                    "payment": ["transaction": paymentInfo["transaction"] as? String]
                                ] as [String: AnyObject]
                                DispatchQueue.main.async {
                                    self.onSuccess!(responseSuccess)
                                    self.removeSpinner()
                                    let result = Result(
                                            type: ResultType.SUCCESS,
                                            orderTransaction: self.orderTransaction,
                                            transactionInfo: TransactionInformation(transaction: transactionNumber, transactionTime: formatDate, cardNumber: cardNumber)
                                    )
                                    self.setupResult(result: result)
                                }
                            } else {
                                let statePay = payInfo["payment"] as? [String: AnyObject]
                                if (statePay == nil) {
                                    let message = payInfo["message"] as? String
                                    self.onError!(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": (message ?? "Có lỗi xảy ra") as AnyObject])
                                    let result = Result(
                                            type: ResultType.FAIL,
                                            failReasonLabel: message ?? "Có lỗi xảy ra",
                                            orderTransaction: self.orderTransaction,
                                            transactionInfo: TransactionInformation(transaction: transactionNumber, transactionTime: formatDate, cardNumber: cardNumber)
                                    )
                                    self.setupResult(result: result)
                                    self.removeSpinner()
                                    return
                                }
                                let state = statePay!["state"] as! String
                                if (state == "REQUIRED_VERIFY") {
                                    let html = statePay!["html"] as? String
                                    if (html != nil) {
                                        self.removeSpinner()
                                        let webViewController = WebViewController(payMEFunction: nil, nibName: "WebView", bundle: nil)
                                        webViewController.form = html!
                                        webViewController.setOnSuccessWebView(onSuccessWebView: { responseFromWebView in
                                            webViewController.dismiss(animated: true)
                                            let paymentInfo = payInfo["history"]!["payment"] as! [String: AnyObject]
                                            let responseSuccess = [
                                                "payment": ["transaction": paymentInfo["transaction"] as? String]
                                            ] as [String: AnyObject]
                                            self.onSuccess!(responseSuccess)
                                            let result = Result(
                                                    type: ResultType.SUCCESS,
                                                    orderTransaction: self.orderTransaction,
                                                    transactionInfo: TransactionInformation(transaction: transactionNumber, transactionTime: formatDate, cardNumber: cardNumber)
                                            )
                                            self.setupResult(result: result)
                                        })
                                        webViewController.setOnFailWebView(onFailWebView: { responseFromWebView in
                                            webViewController.dismiss(animated: true)
                                            self.removeSpinner()
                                            let paymentInfo = payInfo["history"]!["payment"] as! [String: AnyObject]
                                            let responseSuccess = [
                                                "payment": ["transaction": paymentInfo["transaction"] as? String]
                                            ] as [String: AnyObject]
                                            self.onError!(responseSuccess)
                                            let result = Result(
                                                    type: ResultType.FAIL,
                                                    failReasonLabel: responseFromWebView,
                                                    orderTransaction: self.orderTransaction,
                                                    transactionInfo: TransactionInformation(transaction: transactionNumber, transactionTime: formatDate, cardNumber: cardNumber)
                                            )
                                            self.setupResult(result: result)
                                        })
                                        self.presentPanModal(webViewController)
                                    }
                                } else {
                                    let message = statePay!["message"] as? String
                                    self.onError!(["code": PayME.ResponseCode.PAYMENT_ERROR as AnyObject, "message": (message ?? "Có lỗi xảy ra") as AnyObject])
                                    let result = Result(
                                            type: ResultType.FAIL,
                                            failReasonLabel: message ?? "Có lỗi xảy ra",
                                            orderTransaction: self.orderTransaction,
                                            transactionInfo: TransactionInformation(transaction: transactionNumber, transactionTime: formatDate, cardNumber: cardNumber)
                                    )
                                    self.setupResult(result: result)
                                    self.removeSpinner()
                                }
                            }
                        } else {
                            self.onError!(["code": PayME.ResponseCode.SYSTEM as AnyObject, "message": "Có lỗi xảy ra" as AnyObject])
                        }
                    }, onError: { error in
                self.onError!(error)
                self.removeSpinner()
                if let code = error["code"] as? Int {
                    if (code == 401) {
                        self.payMEFunction.resetInitState()
                        PaymentModalController.isShowCloseModal = false
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            })
        }
    }

    func setupResult(result: Result) {
        resultSubject.onNext(result)
        PaymentModalController.isShowCloseModal = false
        if (isShowResultUI == true) {
            scrollView.removeFromSuperview()
            self.result = true
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
            panModalTransition(to: .shortForm)
            resultView.animationView.play()
        } else {
            dismiss(animated: true)
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {

        guard let userInfo = notification.userInfo else {
            return
        }
        var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = view.convert(keyboardFrame, from: nil)

        let contentInset: UIEdgeInsets = scrollView.contentInset

        if (contentInset.bottom < 625 + keyboardFrame.size.height - screenSize.height) {
            scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 625 + keyboardFrame.size.height - screenSize.height, right: 0.0)
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom)
            scrollView.setContentOffset(bottomOffset, animated: true)
        }
        keyboardHeight = keyboardFrame.size.height
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        keyboardHeight = 0
        let contentInset: UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
    }

    @objc func onAppEnterBackground(notification: NSNotification) {
        view.endEditing(false)
    }

    func toastMessError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }


    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    let detailView: UIView = {
        let detailView = UIView()
        detailView.translatesAutoresizingMaskIntoConstraints = false
        return detailView
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
        label.textColor = UIColor(26, 26, 26)
        label.backgroundColor = .clear
        label.font = UIFont(name: "Lato-SemiBold", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let containerView: UIView = {
        let containerView = UIView()
        containerView.layer.cornerRadius = 15.0
        containerView.layer.borderColor = UIColor(203, 203, 203).cgColor
        containerView.layer.borderWidth = 0.5
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()

    let bankNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(9, 9, 9)
        label.font = label.font.withSize(16)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let bankContentLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(98, 98, 98)
        label.backgroundColor = .clear
        label.font = label.font.withSize(12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let walletMethodImage: UIImageView = {
        var bgImage = UIImageView(image: UIImage(for: Method.self, named: "ptAtm"))
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()

    let cardNumberField: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.init(hexString: "#cbcbcb").cgColor
        textField.layer.borderWidth = 0.5
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Nhập số thẻ"
        textField.setLeftPaddingPoints(20)
        textField.keyboardType = .numberPad
        textField.layer.cornerRadius = 15
        return textField
    }()

    let dateField: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.init(hexString: "#cbcbcb").cgColor
        textField.layer.borderWidth = 0.5
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Ngày phát hành (MM/YY)"
        textField.setLeftPaddingPoints(20)
        textField.keyboardType = .numberPad
        textField.layer.cornerRadius = 15
        return textField
    }()

    let nameField: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.init(hexString: "#cbcbcb").cgColor
        textField.layer.borderWidth = 0.5
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Họ tên chủ thẻ"
        textField.setLeftPaddingPoints(20)
        textField.layer.cornerRadius = 15
        return textField
    }()

    let guideTxt: UILabel = {
        let confirmTitle = UILabel()
        confirmTitle.textColor = UIColor(11, 11, 11)
        confirmTitle.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        confirmTitle.translatesAutoresizingMaskIntoConstraints = false
        confirmTitle.textAlignment = .left
        confirmTitle.lineBreakMode = .byWordWrapping
        confirmTitle.numberOfLines = 0
        confirmTitle.text = "Nhập số thẻ ở mặt trước thẻ"
        return confirmTitle
    }()


    var allowsExtendedPanScrolling: Bool {
        true
    }

    var panScrollable: UIScrollView? {
        nil
    }

    var longFormHeight: PanModalHeight {
        if (keyboardHeight != 0) {
            return .maxHeightWithTopInset(40)
        }
        if (result == true) {
            return .intrinsicHeight
        }
        return .contentHeight(500)
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


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == atmView.dateField {
            let allowedCharacters = CharacterSet(charactersIn: "+0123456789 ")//Here change this characters based on your requirement
            let characterSet = CharacterSet(charactersIn: string)
            if (atmView.dateField.text?.count == 2) {
                if !(string == "") {
                    atmView.dateField.text = (atmView.dateField.text)! + "/"
                }
            }
            return allowedCharacters.isSuperset(of: characterSet) && !(textField.text!.count > 4 && (string.count) > range.length)
        }
        if textField == atmView.cardNumberField {
            let allowedCharacters = CharacterSet(charactersIn: "+0123456789 ")//Here change this characters based on your requirement
            let characterSet = CharacterSet(charactersIn: string)
            if (atmView.cardNumberField.text!.count >= 5) {
                if !(string == "") {
                    print(string)
                    let stringToCompare = (atmView.cardNumberField.text)! + string
                    for bank in listBank {
                        bankDetect = nil
                        if (stringToCompare.contains(bank.cardPrefix)) {
                            bankDetect = bank
                            atmView.guideTxt.textColor = UIColor(11, 11, 11)
                            atmView.guideTxt.text = bank.shortName
                            break
                        }
                    }
                    if (bankDetect == nil) {
                        atmView.guideTxt.text = "Thẻ không đúng định dạng"
                        atmView.guideTxt.textColor = .red

                    }
                } else {
                    atmView.guideTxt.text = "Nhập số thẻ ở mặt trước thẻ"
                    atmView.guideTxt.textColor = UIColor(11, 11, 11)
                    bankDetect = nil

                }
            } else {
                atmView.guideTxt.text = "Nhập số thẻ ở mặt trước thẻ"
                atmView.guideTxt.textColor = UIColor(11, 11, 11)
                bankDetect = nil
            }
            if (bankDetect != nil) {
                if (textField.text!.count + 1 == bankDetect!.cardNumberLength) {
                    payMEFunction.request.getBankName(swiftCode: bankDetect!.swiftCode, cardNumber: textField.text! + string, onSuccess: { response in
                        let bankNameRes = response["Utility"]!["GetBankName"] as! [String: AnyObject]
                        let succeeded = bankNameRes["succeeded"] as! Bool
                        if (succeeded == true) {
                            let name = bankNameRes["accountName"] as! String
                            self.bankName = name
                            self.atmView.nameField.text = name
                        } else {
                            self.bankName = ""
                            self.atmView.nameField.text = ""
                        }
                    }, onError: { error in
                        print(error)
                    })
                    print(textField.text! + string)
                }
            }

            if (bankDetect != nil) {
                return allowedCharacters.isSuperset(of: characterSet) && textField.text!.count + 1 <= bankDetect!.cardNumberLength
            }
            return allowedCharacters.isSuperset(of: characterSet) && !(textField.text!.count > 19 && (string.count) > range.length)

        }
        return true
    }
}
