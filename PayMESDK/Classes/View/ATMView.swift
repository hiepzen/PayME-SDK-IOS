//
//  SuccessView.swift
//  PayMESDK
//
//  Created by HuyOpen on 1/11/21.
//

import Foundation

class ATMView: UIView {
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

    let cardInputContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(239, 242, 247)
        view.layer.cornerRadius = 13
        return view
    }()

    let cardInputTitle: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(165, 174, 184)
        label.text = "NHẬP SỐ THẺ"
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()

    let dateInputContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(239, 242, 247)
        view.layer.cornerRadius = 13
        return view
    }()

    let dateInputTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(165, 174, 184)
        label.text = "NGÀY PHÁT HÀNH"
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()

    let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.backgroundColor = .blue
        return button
    }()

    let walletMethodImage: UIImageView = {
        var bgImage = UIImageView(image: UIImage(for: Method.self, named: "ptAtm"))
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()

    let cardNumberField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Số thẻ"
        textField.keyboardType = .numberPad
        textField.font = .systemFont(ofSize: 16, weight: .medium)
        textField.textColor = UIColor(11, 11, 11)
        return textField
    }()

    let dateField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "MM/YY"
        textField.keyboardType = .numberPad
        textField.font = .systemFont(ofSize: 16, weight: .medium)
        textField.textColor = UIColor(11, 11, 11)
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

    let methodView: MethodView = MethodView(type: .BANK_CARD, title: "Thẻ ATM nội địa", buttonTitle: "Thay đổi")


    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = .white

        addSubview(methodView)
        addSubview(button)
        addSubview(vStack)

        vStack.addArrangedSubview(cardInputContainer)
        vStack.addArrangedSubview(dateInputContainer)
//        self.addSubview(nameField)

        button.setTitle("Thanh toán", for: .normal)

        methodView.image.image = UIImage(for: Method.self, named: "fill1")
        methodView.topAnchor.constraint(equalTo: self.topAnchor, constant: 14).isActive = true
//        methodView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        methodView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        methodView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true

        vStack.topAnchor.constraint(equalTo: methodView.bottomAnchor, constant: 14).isActive = true
        vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true

        cardInputContainer.heightAnchor.constraint(equalToConstant: 56).isActive = true
        cardInputContainer.addSubview(cardInputTitle)
        cardInputContainer.addSubview(cardNumberField)
        cardInputTitle.leadingAnchor.constraint(equalTo: cardInputContainer.leadingAnchor, constant: 16).isActive = true
        cardInputTitle.topAnchor.constraint(equalTo: cardInputContainer.topAnchor, constant: 8).isActive = true
        cardNumberField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        cardNumberField.leadingAnchor.constraint(equalTo: cardInputContainer.leadingAnchor, constant: 16).isActive = true
        cardNumberField.topAnchor.constraint(equalTo: cardInputTitle.bottomAnchor).isActive = true
        cardNumberField.trailingAnchor.constraint(equalTo: cardInputContainer.trailingAnchor, constant: -16).isActive = true

        dateInputContainer.heightAnchor.constraint(equalToConstant: 56).isActive = true
        dateInputContainer.addSubview(dateInputTitle)
        dateInputContainer.addSubview(dateField)
        dateInputTitle.leadingAnchor.constraint(equalTo: dateInputContainer.leadingAnchor, constant: 16).isActive = true
        dateInputTitle.topAnchor.constraint(equalTo: dateInputContainer.topAnchor, constant: 8).isActive = true
        dateField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        dateField.leadingAnchor.constraint(equalTo: dateInputContainer.leadingAnchor, constant: 16).isActive = true
        dateField.topAnchor.constraint(equalTo: dateInputTitle.bottomAnchor).isActive = true
        dateField.trailingAnchor.constraint(equalTo: dateInputContainer.trailingAnchor, constant: -16).isActive = true

        button.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        button.topAnchor.constraint(equalTo: vStack.bottomAnchor, constant: 16).isActive = true
        button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        button.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        button.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension ATMView: UITextFieldDelegate {
    // when user select a textfield, this method will be called
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // set the activeTextField to the selected textfield
        self.activeTextField = textField
    }

    // when user click 'done' or dismiss the keyboard
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }
}

