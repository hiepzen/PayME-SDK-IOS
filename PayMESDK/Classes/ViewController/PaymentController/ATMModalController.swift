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
        atmView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true

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

    func formatCardNumber(_ cardNumber: String, _ maxLength: Int = 16) -> String {
        let tempCard = cardNumber.filter("0123456789".contains)
        if (maxLength == 16) {
            return String(tempCard.enumerated().map { $0 > 0 && $0 % 4 == 0 ? ["-", $1] : [$1] }.joined())
        }
        if (maxLength == 19) {
            return String(tempCard.enumerated().map { $0 > 0 && $0 % 8 == 0 ? ["-", $1] : [$1] }.joined())
        }
        return cardNumber
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
            if (atmView.cardNumberField.text!.count >= 5) && !(string == "") {
                let stringToCompare = (atmView.cardNumberField.text)! + string
                for bank in listBank {
                    bankDetect = nil
                    if (stringToCompare.contains(bank.cardPrefix)) {
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
                if (textField.text!.count + 1 == bankDetect!.cardNumberLength) {
                    payMEFunction.request.getBankName(swiftCode: bankDetect!.swiftCode, cardNumber: textField.text! + string, onSuccess: { response in
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

            if (bankDetect != nil) {
                return allowedCharacters.isSuperset(of: characterSet) && textField.text!.count + 1 <= bankDetect!.cardNumberLength
            }
            return allowedCharacters.isSuperset(of: characterSet) && !(textField.text!.count > 19 && (string.count) > range.length)

        }
        return true
    }
}
