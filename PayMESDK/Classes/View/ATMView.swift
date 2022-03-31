//
//  SuccessView.swift
//  PayMESDK
//
//  Created by HuyOpen on 1/11/21.
//

import Foundation
import SVGKit

protocol ATMViewDelegate {
    func isShowScan() -> Bool
    func onPressScanCard()
}

class ATMView: UIView {
    var delegate: ATMViewDelegate?
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

        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)

        methodView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        methodView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        methodView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true

        vStack.topAnchor.constraint(equalTo: methodView.bottomAnchor).isActive = true
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

//        button.setImage(UIImage(for: ATMView.self, named: "iconLock"), for: .normal)

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
        button.setTitle("confirm".localize(), for: .normal)
        guard let method = orderTransaction.paymentMethod else { return }
        cardInput.isHidden = true
        dateInput.isHidden = true
        nameInput.isHidden = true
        cvvInput.isHidden = true
        contentView.isHidden = true
        methodView.title = method.title
        methodView.content = method.label
        methodView.note = nil
        methodView.methodDescription = method.feeDescription
        if delegate != nil {
            if delegate!.isShowScan() == true {
                let imageSVG = SVGKImage(for: ATMView.self, named: "iconScanCard")
                imageSVG?.fillColor(color: UIColor(hexString: PayME.configColor[0]), opacity: 1)
                cardInput.updateExtraIcon(iconImage: imageSVG?.uiImage, onPress: {
                    self.delegate?.onPressScanCard()
                })
            }
        }
        switch method.type {
        case MethodType.WALLET.rawValue:
            methodView.title = "walletBalance".localize()
            methodView.image.image = UIImage(for: PaymentModalController.self, named: "iconWallet")
            let balance = method.dataWallet?.balance ?? 0
            methodView.content = "(\(formatMoney(input: balance))đ)"
            break
        case MethodType.LINKED.rawValue:
            if method.dataLinked != nil {
                let url = URL(string: "https://static.payme.vn/image_bank/image_method/method\(method.dataLinked!.swiftCode ?? method.dataLinked!.issuer)@2x.png")
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
            nameInput.isHidden = false
            methodView.image.image = UIImage(for: MethodView.self, named: "iconAtm")
            dateInput.updateTitle("releaseDate".localize().uppercased())
            break
        case MethodType.BANK_QR_CODE.rawValue:
            methodView.image.image = UIImage(for: MethodView.self, named: "iconQRBank")
            break
        case MethodType.BANK_TRANSFER.rawValue:
            button.setTitle("confirmBankTransfer".localize(), for: .normal)
            contentView.isHidden = false
            methodView.image.image = UIImage(for: Method.self, named: "iconBankTransfer")
            contentView.updateInfo(bank: method.dataBankTransfer, orderTransaction: orderTransaction)
            break
        case MethodType.CREDIT_CARD.rawValue:
            cardInput.isHidden = false
            nameInput.isHidden = false
            dateInput.isHidden = false
            cvvInput.isHidden = false
            methodView.image.image = UIImage(for: Method.self, named: "iconCreditCard")
            dateInput.updateTitle("expiredDate".localize().uppercased())
        default:
            methodView.image.image = UIImage(for: MethodView.self, named: "iconWallet")
            break
        }
        methodView.updateUI()
        updateConstraints()
        layoutIfNeeded()
    }

    let vStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
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

    let scanCardButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        return button
    }()

    let cardInput = InputView(title: "fillCardNumberUpper".localize(), placeholder: "inputCardNumber".localize(), keyboardType: .numberPad)
    let nameInput = InputView(title: "fillFullNameCardHolderUpper".localize(), placeholder: "fullnameCardHolder".localize(), isAutoCapitalization: true)
    let dateInput = InputView(title: "releaseDate".localize().uppercased(), placeholder: "MM/YY", keyboardType: .numberPad)
    let cvvInput = InputView(title: "cvvUppercase".localize(), placeholder: "CVV/CVC", keyboardType: .numberPad)
    let methodView: MethodView = MethodView(isSelectable: false)

    var contentView = BankTransferView()
}


