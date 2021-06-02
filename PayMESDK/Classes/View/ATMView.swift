//
//  SuccessView.swift
//  PayMESDK
//
//  Created by HuyOpen on 1/11/21.
//

import Foundation

class ATMView: UIScrollView {
    var activeTextField: UITextField? = nil

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
    let methodView: MethodView = MethodView(type: .BANK_CARD, title: "Thẻ ATM nội địa", buttonTitle: "Thay đổi")


    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        isScrollEnabled = true
        isPagingEnabled = false
        showsVerticalScrollIndicator = true
        showsHorizontalScrollIndicator = false
        bounces = false

        addSubview(methodView)
        addSubview(button)
        addSubview(vStack)

        vStack.addArrangedSubview(cardInput)
        vStack.addArrangedSubview(nameInput)
        vStack.addArrangedSubview(dateInput)
//        self.addSubview(nameField)

        button.setTitle("Thanh toán", for: .normal)

        methodView.image.image = UIImage(for: Method.self, named: "iconAtm")
        methodView.topAnchor.constraint(equalTo: topAnchor, constant: 14).isActive = true
//        methodView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        methodView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        methodView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true

        vStack.topAnchor.constraint(equalTo: methodView.bottomAnchor, constant: 14).isActive = true
        vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true

        cardInput.heightAnchor.constraint(equalToConstant: 56).isActive = true
        nameInput.heightAnchor.constraint(equalToConstant: 56).isActive = true
        dateInput.heightAnchor.constraint(equalToConstant: 56).isActive = true

        button.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        button.topAnchor.constraint(equalTo: vStack.bottomAnchor, constant: 16).isActive = true
        button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        button.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        button.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        nameInput.isHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


