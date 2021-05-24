//
//  File.swift
//  PayMESDK
//
//  Created by HuyOpen on 11/6/20.
//

import UIKit
import Lottie
import RxSwift


class ATMModal: UIViewController, UITextFieldDelegate {
    let screenSize: CGRect = UIScreen.main.bounds
    var atmView = ATMView()
    var keyboardHeight: CGFloat = 0
    var listBank: [Bank] = []
    var bankDetect: Bank?
    var onError: (([String: AnyObject]) -> ())? = nil
    var onSuccess: (([String: AnyObject]) -> ())? = nil
    var result = false
    let payMEFunction: PayMEFunction
    let orderTransaction: OrderTransaction
    let isShowResultUI: Bool
    let paymentPresentation: PaymentPresentation

    init(payMEFunction: PayMEFunction, orderTransaction: OrderTransaction, isShowResult: Bool, paymentPresentation: PaymentPresentation,
         onSuccess: (([String: AnyObject]) -> ())? = nil, onError: (([String: AnyObject]) -> ())? = nil) {
        self.payMEFunction = payMEFunction
        self.onSuccess = onSuccess
        self.onError = onError
        self.orderTransaction = orderTransaction
        self.paymentPresentation = paymentPresentation
        isShowResultUI = isShowResult
        super.init(nibName: nil, bundle: nil)
    }

    func setListBank(listBank: [Bank] = []) {
        self.listBank = listBank
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        PaymentModalController.isShowCloseModal = true
        view.backgroundColor = .white

        view.addSubview(atmView)
        atmView.translatesAutoresizingMaskIntoConstraints = false

        atmView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        atmView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        atmView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        atmView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        atmView.cardNumberField.delegate = self
        atmView.dateField.delegate = self

        atmView.button.addTarget(self, action: #selector(payATM), for: .touchUpInside)
        atmView.methodView.onPress = {
            self.payMEFunction.paymentViewModel.paymentSubject.onNext(PaymentState(state: State.METHODS))
        }

        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(onAppEnterBackground), name: UIScene.willDeactivateNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(onAppEnterBackground), name: UIApplication.willResignActiveNotification, object: nil)
        }

        atmView.cardNumberField.addTarget(self, action: #selector(reformatAsCardNumber), for: .editingChanged)
    }

    @objc func closeAction() {
        dismiss(animated: true, completion: nil)
    }

    @objc func payATM() {
        let cardNumber = atmView.cardNumberField.text?.filter("0123456789".contains)
        let cardHolder = atmView.nameField.text
        let issuedAt = atmView.dateField.text
        if bankDetect != nil && cardNumber!.count != bankDetect!.cardNumberLength {
            toastMessError(title: "Lỗi", message: "Vui lòng nhập mã thẻ đúng định dạng")
            return
        }
        if cardHolder == nil || cardHolder!.count == 0 {
            toastMessError(title: "Lỗi", message: "Vui lòng nhập họ tên chủ thẻ")
            return
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
            orderTransaction.paymentMethod?.dataBank = BankInformation(cardNumber: cardNumber!, cardHolder: cardHolder!, issueDate: date, bank: bankDetect)
            paymentPresentation.getFee(orderTransaction: orderTransaction)
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
            detectBank(cardNumberWithoutSpaces)
        }
        if bankDetect != nil {
            textField.text = insertCreditCardSpaces(cardNumberWithoutSpaces, preserveCursorPosition: &targetCursorPosition)
        } else {
            textField.text = cardNumberWithoutSpaces
        }

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
        let is883: Bool = bankDetect?.cardNumberLength == 19 ? true : false
        let is4444: Bool = bankDetect?.cardNumberLength == 16 ? true : false

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
            previousTextFieldContent = textField.text
            previousSelection = textField.selectedTextRange
        }
        return true
    }

    private func detectBank(_ string: String) {
        if string != "" && string.count > 5 {
            for bank in listBank {
                bankDetect = nil
                if (string.contains(bank.cardPrefix)) {
                    bankDetect = bank
                    break
                }
            }
            if (bankDetect == nil) {
                atmView.nameLabel.text = ""
            }
        } else {
            bankDetect = nil
            atmView.nameLabel.text = ""
        }
        if (bankDetect != nil) {
            if (string.count == bankDetect!.cardNumberLength) {
                payMEFunction.request.getBankName(swiftCode: bankDetect!.swiftCode, cardNumber: string, onSuccess: { response in
                    let bankNameRes = response["Utility"]!["GetBankName"] as! [String: AnyObject]
                    let succeeded = bankNameRes["succeeded"] as! Bool
                    if (succeeded == true) {
                        let name = bankNameRes["accountName"] as! String
                        self.atmView.nameLabel.text = name
                        self.atmView.nameInputContainer.isHidden = true
                        self.atmView.nameField.text = name
                    } else {
                        self.atmView.nameLabel.text = ""
                        self.atmView.nameInputContainer.isHidden = false
                        self.atmView.nameField.text = ""
                    }
                }, onError: { error in
                    print(error)
                })
            }
        }
    }
}
