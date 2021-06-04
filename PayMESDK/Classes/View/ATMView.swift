//
//  SuccessView.swift
//  PayMESDK
//
//  Created by HuyOpen on 1/11/21.
//

import Foundation

class ATMView: UIScrollView {
    let vStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .equalSpacing
        stack.alignment = .fill
        return stack
    }()

    let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.backgroundColor = .blue
        return button
    }()

    let cardInput = InputView(title: "NHẬP SỐ THẺ", placeholder: "Số thẻ", keyboardType: .numberPad)
    let nameInput = InputView(title: "NHẬP HỌ TÊN CHỦ THẺ", placeholder: "Họ tên chủ thẻ")
    let dateInput = InputView(title: "NGÀY PHÁT HÀNH", placeholder: "MM/YY", keyboardType: .numberPad)
    let methodView: MethodView = MethodView(buttonTitle: "Thay đổi")

    var paymentInfo = InformationView(data: [])

    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        isScrollEnabled = true
        isPagingEnabled = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false

        bounces = false

        addSubview(methodView)
        addSubview(button)
        addSubview(vStack)

        vStack.addArrangedSubview(cardInput)
        vStack.addArrangedSubview(nameInput)
        vStack.addArrangedSubview(dateInput)
//        self.addSubview(nameField)

        button.setTitle("Xác nhận", for: .normal)
//        button.setImage(UIImage(named: ""), for: .normal)

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

        cardInput.isHidden = true
        dateInput.isHidden = true
        nameInput.isHidden = true

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateContentSize() {
        updateConstraints()
        layoutIfNeeded()
        let contentRect: CGRect = self.subviews.reduce(into: .zero) { rect, view in
            rect = rect.union(view.frame)
        }
        self.contentSize = contentRect.size
    }

    func updateUIByMethod(_ method: PaymentMethod) {
        cardInput.isHidden = true
        dateInput.isHidden = true
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
        case MethodType.LINKED.rawValue:
            if method.dataLinked != nil {
                let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/vn-mecorp-payme-wallet.appspot.com/o/image_bank%2Fimage_method%2Fmethod\(method.dataLinked!.swiftCode!).png?alt=media&token=28cdb30e-fa9b-430c-8c0e-5369f500612e")
                DispatchQueue.global().async {
                    if let sureURL = url as URL? {
                        let data = try? Data(contentsOf: sureURL)
                        DispatchQueue.main.async {
                            self.methodView.image.image = UIImage(data: data!)
                        }
                    }
                }
            }
            break
        case MethodType.BANK_CARD.rawValue:
            cardInput.isHidden = false
            dateInput.isHidden = false
            methodView.image.image = UIImage(for: MethodView.self, named: "iconAtm")
            break
        case MethodType.BANK_QR_CODE.rawValue:
            methodView.image.image = UIImage(for: MethodView.self, named: "iconQRBank")
        default:
            methodView.image.image = UIImage(for: MethodView.self, named: "iconWallet")
            break
        }
        methodView.updateUI()
        updateContentSize()
    }

    func updatePaymentInfo(_ data: [Dictionary<String, Any>]) {
        paymentInfo.removeFromSuperview()
        paymentInfo = InformationView(data: data)
        vStack.addArrangedSubview(paymentInfo)
        layoutIfNeeded()
        paymentInfo.addLineDashedStroke(pattern: [4, 4], radius: 16, color: UIColor(142, 142, 142).cgColor)
        updateContentSize()
    }

}


