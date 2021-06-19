//
//  SuccessView.swift
//  PayMESDK
//
//  Created by HuyOpen on 1/11/21.
//

import Foundation

class ATMView: UIView {
    init() {
        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(methodView)
        addSubview(button)
        addSubview(vStack)

        vStack.addArrangedSubview(cardInput)
        vStack.addArrangedSubview(nameInput)
        vStack.addArrangedSubview(hStack)
        vStack.addArrangedSubview(contentView)
        hStack.addArrangedSubview(dateInput)
        hStack.addArrangedSubview(cvvInput)
        cvvInput.textInput.isSecureTextEntry = true
//        self.addSubview(nameField)

        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)

        methodView.topAnchor.constraint(equalTo: topAnchor, constant: 14).isActive = true
        methodView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        methodView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true

        vStack.topAnchor.constraint(equalTo: methodView.bottomAnchor, constant: 14).isActive = true
        vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true

        cardInput.heightAnchor.constraint(equalToConstant: 56).isActive = true
        nameInput.heightAnchor.constraint(equalToConstant: 56).isActive = true
        dateInput.heightAnchor.constraint(equalToConstant: 56).isActive = true

        button.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        button.topAnchor.constraint(equalTo: vStack.bottomAnchor, constant: 16).isActive = true
        button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        button.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true

        button.setImage(UIImage(for: ATMView.self, named: "iconLock"), for: .normal)

        cardInput.isHidden = true
        dateInput.isHidden = true
        nameInput.isHidden = true
        cvvInput.isHidden = true
        contentView.isHidden = true
        bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: 16).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }



    func updateUIByMethod(orderTransaction: OrderTransaction) {
        button.setTitle("Xác nhận", for: .normal)
        let method = orderTransaction.paymentMethod!
        cardInput.isHidden = true
        dateInput.isHidden = true
        nameInput.isHidden = true
        cvvInput.isHidden = true
        contentView.isHidden = true
        methodView.title = method.title
        methodView.content = method.label
        methodView.note = nil
        methodView.methodDescription = method.feeDescription
        switch method.type {
        case MethodType.WALLET.rawValue:
            methodView.title = "Số dư ví"
            methodView.image.image = UIImage(for: PaymentModalController.self, named: "iconWallet")
            let balance = method.dataWallet?.balance ?? 0
            methodView.content = "(\(formatMoney(input: balance))đ)"
            break
        case MethodType.LINKED.rawValue:
            if method.dataLinked != nil {
                let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/vn-mecorp-payme-wallet.appspot.com/o/image_bank%2Fimage_method%2Fmethod\(method.dataLinked!.swiftCode ?? method.dataLinked!.issuer).png?alt=media&token=28cdb30e-fa9b-430c-8c0e-5369f500612e")
                DispatchQueue.global().async {
                    if let sureURL = url as URL? {
                        if let data = try? Data(contentsOf: sureURL) {
                            DispatchQueue.main.async {
                                self.methodView.image.image = UIImage(data: data)
                            }
                        }
                    }
                }
            }
            break
        case MethodType.BANK_CARD.rawValue:
            cardInput.isHidden = false
            dateInput.isHidden = false
            methodView.image.image = UIImage(for: MethodView.self, named: "iconAtm")
            dateInput.titleLabel.text = "NGÀY PHÁT HÀNH"
            break
        case MethodType.BANK_QR_CODE.rawValue:
            methodView.image.image = UIImage(for: MethodView.self, named: "iconQRBank")
            break
        case MethodType.BANK_TRANSFER.rawValue:
//            button.setTitle("Xác nhận đã chuyển", for: .normal)
            paymentInfo.removeFromSuperview()
            contentView.isHidden = false
            methodView.image.image = UIImage(for: Method.self, named: "iconBankTransfer")
            contentView.updateInfo(bank: method.dataBankTransfer, orderTransaction: orderTransaction)
            break
        case MethodType.CREDIT_CARD.rawValue:
            cardInput.isHidden = false
            dateInput.isHidden = false
            cvvInput.isHidden = false
            methodView.image.image = UIImage(for: Method.self, named: "iconCreditCard")
            dateInput.titleLabel.text = "NGÀY HẾT HẠN"
        default:
            methodView.image.image = UIImage(for: MethodView.self, named: "iconWallet")
            break
        }
        methodView.updateUI()
        updateConstraints()
        layoutIfNeeded()
//        updateContentSize()
    }

    func updatePaymentInfo(_ data: [Dictionary<String, Any>]) {
        paymentInfo.removeFromSuperview()
        paymentInfo = InformationView(data: data)
        vStack.addArrangedSubview(paymentInfo)
        layoutIfNeeded()
        paymentInfo.addLineDashedStroke(pattern: [4, 4], radius: 16, color: UIColor(142, 142, 142).cgColor)
//        updateContentSize()
    }
    let vStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .equalSpacing
        return stack
    }()

    let hStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fillEqually
        return stack
    }()

    let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.backgroundColor = .clear
        return button
    }()

    let cardInput = InputView(title: "NHẬP SỐ THẺ", placeholder: "Số thẻ", keyboardType: .numberPad)
    let nameInput = InputView(title: "NHẬP HỌ TÊN CHỦ THẺ", placeholder: "Họ tên chủ thẻ")
    let dateInput = InputView(title: "NGÀY PHÁT HÀNH", placeholder: "MM/YY", keyboardType: .numberPad)
    let cvvInput = InputView(title: "MÃ BẢO MẬT", placeholder: "CVV/CVC", keyboardType: .numberPad)
    let methodView: MethodView = MethodView(buttonTitle: "Thay đổi")

    var paymentInfo = InformationView(data: [])
    var contentView = BankTransferView()
}


