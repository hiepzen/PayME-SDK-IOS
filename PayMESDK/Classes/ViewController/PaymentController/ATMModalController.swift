//
//  File.swift
//  PayMESDK
//
//  Created by HuyOpen on 11/6/20.
//

import UIKit
import Lottie
import RxSwift


class ConfirmationModal: UIViewController {
    let screenSize: CGRect = UIScreen.main.bounds
    var atmView = ATMView()
    var keyboardHeight: CGFloat = 0
    var listBank: [Bank] = []
    var bankDetect: Bank?
    var issuerCreditDetect: String?
    var onError: (([String: AnyObject]) -> ())? = nil
    var onSuccess: (([String: AnyObject]) -> ())? = nil
    var result = false
    let payMEFunction: PayMEFunction
    let orderTransaction: OrderTransaction
    let isShowResultUI: Bool
    let paymentPresentation: PaymentPresentation

    var payActionByMethod = {}
    let orderView: OrderView

    init(payMEFunction: PayMEFunction, orderTransaction: OrderTransaction, isShowResult: Bool, paymentPresentation: PaymentPresentation,
         onSuccess: (([String: AnyObject]) -> ())? = nil, onError: (([String: AnyObject]) -> ())? = nil) {
        self.payMEFunction = payMEFunction
        self.onSuccess = onSuccess
        self.onError = onError
        self.orderTransaction = orderTransaction
        self.paymentPresentation = paymentPresentation
        isShowResultUI = isShowResult
        if orderTransaction.isShowHeader {
            orderView = OrderView(amount: self.orderTransaction.amount, storeName: self.orderTransaction.storeName,
                    serviceCode: self.orderTransaction.orderId,
                    note: orderTransaction.note == "" ? "noContent".localize() : self.orderTransaction.note,
                    logoUrl: self.orderTransaction.storeImage, isFullInfo: true)
        } else {
            orderView = OrderView(amount: self.orderTransaction.amount, storeName: self.orderTransaction.storeName,
                    serviceCode: self.orderTransaction.orderId,
                    note: orderTransaction.note == "" ? "noContent".localize() : self.orderTransaction.note,
                    logoUrl: nil, isFullInfo: false)
        }
        super.init(nibName: nil, bundle: nil)
    }

    func setListBank(listBank: [Bank] = []) {
        self.listBank = listBank
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        PaymentModalController.isShowCloseModal = true
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(orderView)
        scrollView.addSubview(atmView)
//        atmView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        orderView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        orderView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        orderView.widthAnchor.constraint(equalToConstant: screenSize.width).isActive = true
//        orderView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true

        atmView.topAnchor.constraint(equalTo: orderView.bottomAnchor).isActive = true
        atmView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        atmView.widthAnchor.constraint(equalToConstant: screenSize.width).isActive = true
//        atmView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true

        atmView.cardInput.textInput.delegate = self
        atmView.dateInput.textInput.delegate = self
        atmView.nameInput.textInput.delegate = self
        atmView.cvvInput.textInput.delegate = self

        atmView.button.addTarget(self, action: #selector(payAction), for: .touchUpInside)
        atmView.methodView.onPress = {}
        atmView.contentView.onPressSearch = {
            self.payMEFunction.paymentViewModel.paymentSubject.onNext(PaymentState(state: .BANK_SEARCH, orderTransaction: self.orderTransaction))
        }
        atmView.contentView.onPressOpenVietQRBanks = {
            self.payMEFunction.paymentViewModel.paymentSubject.onNext(PaymentState(state: .BANK_VIETQR, banks: self.listBank, orderTransaction: self.orderTransaction))
        }

        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(onAppEnterBackground), name: UIScene.willDeactivateNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(onAppEnterBackground), name: UIApplication.willResignActiveNotification, object: nil)
        }

        atmView.cardInput.textInput.addTarget(self, action: #selector(reformatAsCardNumber), for: .editingChanged)
    }

    override func viewDidLayoutSubviews() {
        let primaryColor = payMEFunction.configColor[0]
        let secondaryColor = payMEFunction.configColor.count > 1 ? payMEFunction.configColor[1] : primaryColor

        orderView.applyGradient(colors: [UIColor(hexString: primaryColor).cgColor, UIColor(hexString: secondaryColor).cgColor], radius: 0)
    }

    @objc func closeAction() {
        dismiss(animated: true, completion: nil)
    }

    @objc func payAction() {
        if (orderTransaction.paymentMethod?.type == MethodType.BANK_CARD.rawValue) {
            payATM()
            return
        }
        if (orderTransaction.paymentMethod?.type == MethodType.CREDIT_CARD.rawValue) {
            payCreditCard()
            return
        }
        if (orderTransaction.paymentMethod?.type == MethodType.BANK_TRANSFER.rawValue) {
            paymentPresentation.payBankTransfer(orderTransaction: orderTransaction)
            return
        }
        payActionByMethod()
    }

    func payCreditCard() {
        let cardNumber = atmView.cardInput.textInput.text?.filter("0123456789".contains)
        let cardHolder = atmView.nameInput.textInput.text
        let expiredAt = atmView.dateInput.textInput.text
        let cvv = atmView.cvvInput.textInput.text
        if cardNumber == nil || (cardNumber?.count ?? 0) < 7 {
            atmView.cardInput.errorMessage = "wrongCardNumberContent".localize()
            atmView.cardInput.updateState(state: .error)
            return
        }
        if cardHolder == nil || cardHolder!.count == 0 {
            atmView.nameInput.errorMessage = "emptyFullNameCardHolder".localize()
            atmView.nameInput.updateState(state: .error)
            return
        }
        if (expiredAt?.count ?? 0) != 5 {
            atmView.dateInput.errorMessage = "emptyDateCardContent".localize() + "expiredDate".localize().lowercased()
            atmView.dateInput.updateState(state: .error)
            return
        }
        let dateArr = expiredAt!.components(separatedBy: "/")
        let month = Int(dateArr[0]) ?? 0
        let year = Int(dateArr[1]) ?? 0
        if (month == 0 || year == 0 || month > 12 || month <= 0) {
            atmView.dateInput.errorMessage = "wrongExpiredDateCardContent".localize()
            atmView.dateInput.updateState(state: .error)
            return
        }
        if (cvv?.count ?? 0) != 3 {
            atmView.cvvInput.errorMessage = "emptyCVVContent".localize()
            atmView.cvvInput.updateState(state: .error)
            return
        }
        orderTransaction.paymentMethod?.dataCreditCard = CreditCardInfomation(cardNumber: cardNumber!, cardHolder: cardHolder!, expiredAt: expiredAt!, cvv: cvv!,
                issuer: issuerCreditDetect ?? "")
        showSpinner(onView: view)
        paymentPresentation.authenCreditCard(orderTransaction: orderTransaction)
    }

    func payATM() {
        let cardNumber = atmView.cardInput.textInput.text?.filter("0123456789".contains)
        let cardHolder = atmView.nameInput.textInput.text
        let issuedAt = atmView.dateInput.textInput.text
        if bankDetect == nil || cardNumber!.count != bankDetect?.cardNumberLength {
            atmView.cardInput.errorMessage = "wrongCardNumberContent".localize()
            atmView.cardInput.updateState(state: .error)
            return
        }
        if cardHolder == nil || cardHolder!.count == 0 {
            atmView.nameInput.errorMessage = "emptyFullNameCardHolder".localize()
            atmView.nameInput.updateState(state: .error)
            return
        }
        if (issuedAt!.count != 5) {
            atmView.dateInput.errorMessage = "emptyDateCardContent".localize() + bankDetect!.requiredDateString.lowercased()
            atmView.dateInput.updateState(state: .error)
            return
        } else {
            let dateArr = issuedAt!.components(separatedBy: "/")
            let month = Int(dateArr[0]) ?? 0
            let year = Int(dateArr[1]) ?? 0
            if (month == 0 || year == 0 || month > 12 || month <= 0) {
                atmView.dateInput.errorMessage = "wrongReleaseDateCardContent".localize()
                atmView.dateInput.updateState(state: .error)
                return
            }
            let date = "20" + dateArr[1] + "-" + dateArr[0] + "-01T00:00:00.000Z"
            orderTransaction.paymentMethod?.dataBank = BankInformation(cardNumber: cardNumber!, cardHolder: cardHolder!, issueDate: date, bank: bankDetect)
            showSpinner(onView: view)
            paymentPresentation.payATM(orderTransaction: orderTransaction)
        }
    }

    @objc func onAppEnterBackground(notification: NSNotification) {
        view.endEditing(false)
    }

    func toastMessError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private var previousTextFieldContent: String?
    private var previousSelection: UITextRange?

    @objc func reformatAsCardNumber(textField: UITextField) {
        var targetCursorPosition = 0
        if let startPosition = textField.selectedTextRange?.start {
            targetCursorPosition = textField.offset(from: textField.beginningOfDocument, to: startPosition)
        }
        var cardNumberWithoutSpaces = ""
        if let text = textField.text {
            cardNumberWithoutSpaces = removeNonDigits(string: text, andPreserveCursorPosition: &targetCursorPosition)
        }
        if cardNumberWithoutSpaces.count > bankDetect?.cardNumberLength ?? 19 {
            textField.text = previousTextFieldContent
            textField.selectedTextRange = previousSelection
            return
        } else {
            if orderTransaction.paymentMethod?.type == MethodType.BANK_CARD.rawValue {
                detectBank(cardNumberWithoutSpaces)
            } else if orderTransaction.paymentMethod?.type == MethodType.CREDIT_CARD.rawValue {
                detectCreditCard(cardNumberWithoutSpaces)
            }
        }

        textField.text = insertCreditCardSpaces(cardNumberWithoutSpaces, preserveCursorPosition: &targetCursorPosition)

        if let targetPosition = textField.position(from: textField.beginningOfDocument, offset: targetCursorPosition) {
            textField.selectedTextRange = textField.textRange(from: targetPosition, to: targetPosition)
        }
    }

    func removeNonDigits(string: String, andPreserveCursorPosition cursorPosition: inout Int) -> String {
        var digitsOnlyString = ""
        let originalCursorPosition = cursorPosition
        for i in Swift.stride(from: 0, to: string.count, by: 1) {
            let characterToAdd = string[string.index(string.startIndex, offsetBy: i)]
            if characterToAdd >= "0" && characterToAdd <= "9" {
                digitsOnlyString.append(characterToAdd)
            } else if i < originalCursorPosition {
                cursorPosition -= 1
            }
        }
        return digitsOnlyString
    }

    func insertCreditCardSpaces(_ string: String, preserveCursorPosition cursorPosition: inout Int) -> String {
        var is883, is4444: Bool
        if bankDetect != nil {
            is883 = bankDetect?.cardNumberLength == 19 ? true : false
            is4444 = bankDetect?.cardNumberLength == 16 ? true : false
        } else {
            is4444 = true
            is883 = false
        }

        var stringWithAddedSpaces = ""
        let cursorPositionInSpacelessString = cursorPosition

        for i in 0..<string.count {
            let needs883Spacing = (is883 && i > 0 && (i % 8) == 0)
            let needs4444Spacing = (is4444 && i > 0 && (i % 4) == 0)
            if needs4444Spacing || needs883Spacing {
                stringWithAddedSpaces.append("-")
                if i < cursorPositionInSpacelessString {
                    cursorPosition += 1
                }
            }
            let characterToAdd = string[string.index(string.startIndex, offsetBy: i)]
            stringWithAddedSpaces.append(characterToAdd)
        }
        return stringWithAddedSpaces
    }

    private func detectCreditCard(_ card: String) {
        if card != "" && card.count >= 4 {
            if issuerCreditDetect == nil {
                let patterns = [
                    "VISA": ["4"],
                    "MASTERCARD": ["51", "52", "53", "54", "55", "2221", "2229", "223", "229", "23", "26", "270", "271", "2720"],
                    "JCB": ["2131", "1800", "35"]
                ]
                for (issuer, cardPattern) in patterns {
                    for cardPrefix in cardPattern {
                        if card.hasPrefix(cardPrefix) {
                            issuerCreditDetect = issuer
//                            orderTransaction.paymentMethod?.dataCreditCard?.issuer = issuer
                            atmView.cardInput.updateExtraInfo(url: "https://firebasestorage.googleapis.com/v0/b/vn-mecorp-payme-wallet.appspot.com/o/image_bank%2Fimage_method%2Fmethod\(issuer).png?alt=media&token=28cdb30e-fa9b-430c-8c0e-5369f500612e")
                        }
                    }
                }
            }
        } else {
            issuerCreditDetect = nil
            atmView.cardInput.resetExtraInfo()
        }
    }

    func updateContentSize() {
        view.updateConstraints()
        view.layoutIfNeeded()
        let contentRect: CGRect = scrollView.subviews.reduce(into: .zero) { rect, view in
            rect = rect.union(view.frame)
        }
        scrollView.contentSize.height = contentRect.size.height
    }

    private func detectBank(_ string: String) {
        if string != "" && string.count > 5 {
            if bankDetect == nil {
                for bank in listBank {
                    if (string.contains(bank.cardPrefix)) {
                        bankDetect = bank
                        atmView.dateInput.updateTitle(bank.requiredDateString.uppercased())
                        atmView.cardInput.updateExtraInfo(url: "https://firebasestorage.googleapis.com/v0/b/vn-mecorp-payme-wallet.appspot.com/o/image_bank%2Fimage_method%2Fmethod\(bank.swiftCode).png?alt=media&token=28cdb30e-fa9b-430c-8c0e-5369f500612e")
                        break
                    }
                }
                if bankDetect == nil {
                    atmView.cardInput.errorMessage = "wrongCardNumberContentNoti".localize()
                    atmView.cardInput.updateState(state: .error)
                }
            }
        } else {
            bankDetect = nil
            atmView.dateInput.updateTitle("releaseDate".localize().uppercased())
            atmView.cardInput.updateExtraInfo(data: "")
            atmView.cardInput.updateState(state: .focus)
        }
        if (bankDetect != nil) && (string.count == bankDetect!.cardNumberLength) {
            payMEFunction.request.getBankName(swiftCode: bankDetect!.swiftCode, cardNumber: string, onSuccess: { response in
                let bankNameRes = response["Utility"]!["GetBankName"] as! [String: AnyObject]
                let succeeded = bankNameRes["succeeded"] as! Bool
                if (succeeded == true) {
                    let name = bankNameRes["accountName"] as! String
                    self.atmView.nameInput.textInput.text = name
                    self.updateContentSize()
                } else {
                    self.atmView.nameInput.textInput.text = ""
                    self.updateContentSize()
                }
            }, onError: { error in
                self.atmView.nameInput.textInput.text = ""
                self.updateContentSize()
                print(error)
            })
        } else {
            atmView.nameInput.textInput.text = ""
        }

    }

    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .white
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.isScrollEnabled = true
        sv.isPagingEnabled = false
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.bounces = false
        return sv
    }()
}

extension ConfirmationModal: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == atmView.dateInput.textInput {
            let allowedCharacters = CharacterSet(charactersIn: "+0123456789 ")//Here change this characters based on your requirement
            let characterSet = CharacterSet(charactersIn: string)
            if (atmView.dateInput.textInput.text?.count == 2) {
                if !(string == "") {
                    atmView.dateInput.textInput.text = (atmView.dateInput.textInput.text)! + "/"
                }
            }
            return allowedCharacters.isSuperset(of: characterSet) && !(textField.text!.count > 4 && (string.count) > range.length)
        }
        if textField == atmView.cvvInput.textInput {
            let allowedCharacters = CharacterSet(charactersIn: "+0123456789 ")//Here change this characters based on your requirement
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet) && !(textField.text!.count >= 3 && (string.count) > range.length)
        }
        if textField == atmView.cardInput.textInput {
            previousTextFieldContent = textField.text
            previousSelection = textField.selectedTextRange
        }
        if textField == atmView.nameInput.textInput {
            return textField.text!.count + string.count <= 50
        }
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case atmView.cardInput.textInput:
            atmView.cardInput.updateState(state: .focus)
            break
        case atmView.nameInput.textInput:
            atmView.nameInput.updateState(state: .focus)
            break
        case atmView.dateInput.textInput:
            atmView.dateInput.updateState(state: .focus)
            break
        case atmView.cvvInput.textInput:
            atmView.cvvInput.updateState(state: .focus)
        default: break
        }
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case atmView.cardInput.textInput:
            atmView.cardInput.updateState(state: .normal)
            break
        case atmView.nameInput.textInput:
            atmView.nameInput.updateState(state: .normal)
            break
        case atmView.dateInput.textInput:
            atmView.dateInput.updateState(state: .normal)
            break
        case atmView.cvvInput.textInput:
            atmView.cvvInput.updateState(state: .normal)
        default: break
        }
    }
}
