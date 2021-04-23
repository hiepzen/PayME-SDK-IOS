//
//  SuccessView.swift
//  PayMESDK
//
//  Created by HuyOpen on 1/11/21.
//

import Foundation

internal class ATMView: UIView {
    var activeTextField: UITextField? = nil

    let detailView: UIView = {
        let detailView = UIView()
        detailView.translatesAutoresizingMaskIntoConstraints = false
        return detailView
    }()

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .red
        tableView.separatorStyle = .none

        return tableView
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
        button.backgroundColor = .blue
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


    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = .white

        self.addSubview(closeButton)
        self.addSubview(txtLabel)
        self.addSubview(detailView)
        self.addSubview(methodTitle)
        self.addSubview(containerView)
        self.addSubview(button)
        self.addSubview(cardNumberField)
        self.addSubview(dateField)
        self.addSubview(nameField)
        self.addSubview(guideTxt)

        button.setTitle("THANH TOÁN", for: .normal)
        bankNameLabel.text = "Thẻ ATM nội địa"

        containerView.addSubview(walletMethodImage)
        containerView.addSubview(bankNameLabel)
        containerView.addSubview(bankContentLabel)
        // contentView.addSubview(walletMethodImage)

        detailView.addSubview(price)
        detailView.backgroundColor = UIColor(8, 148, 31)
        detailView.addSubview(contentLabel)
        detailView.addSubview(memoLabel)
        txtLabel.text = "Xác nhận thanh toán"
        price.text = "\(formatMoney(input: PayME.amount)) đ"
        contentLabel.text = "Nội dung"
        if (PayME.description == "") {
            memoLabel.text = "Không có nội dung"
        } else {
            memoLabel.text = PayME.description
        }
        methodTitle.text = "Nguồn thanh toán"

        txtLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 19).isActive = true
        txtLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true


        detailView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        detailView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        detailView.heightAnchor.constraint(equalToConstant: 118.0).isActive = true
        detailView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        detailView.topAnchor.constraint(equalTo: txtLabel.bottomAnchor, constant: 16.0).isActive = true

        price.topAnchor.constraint(equalTo: detailView.topAnchor, constant: 15).isActive = true
        price.centerXAnchor.constraint(equalTo: detailView.centerXAnchor).isActive = true


        closeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 19).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 20).isActive = true

        contentLabel.bottomAnchor.constraint(equalTo: detailView.bottomAnchor, constant: -15).isActive = true
        contentLabel.leadingAnchor.constraint(equalTo: detailView.leadingAnchor, constant: 30).isActive = true
        contentLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .horizontal)
        contentLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        memoLabel.bottomAnchor.constraint(equalTo: detailView.bottomAnchor, constant: -15).isActive = true
        memoLabel.leadingAnchor.constraint(equalTo: contentLabel.trailingAnchor, constant: 30).isActive = true
        memoLabel.trailingAnchor.constraint(equalTo: detailView.trailingAnchor, constant: -30).isActive = true
        memoLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 250), for: .horizontal)
        memoLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        methodTitle.topAnchor.constraint(equalTo: detailView.bottomAnchor, constant: 10).isActive = true
        methodTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30).isActive = true


        containerView.topAnchor.constraint(equalTo: methodTitle.bottomAnchor, constant: 10).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30).isActive = true
        containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30).isActive = true

        walletMethodImage.heightAnchor.constraint(equalToConstant: 26).isActive = true
        walletMethodImage.widthAnchor.constraint(equalToConstant: 26).isActive = true
        walletMethodImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
        walletMethodImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true

        bankNameLabel.leadingAnchor.constraint(equalTo: walletMethodImage.trailingAnchor, constant: 10).isActive = true
        bankNameLabel.trailingAnchor.constraint(equalTo: bankContentLabel.leadingAnchor, constant: -5).isActive = true
        bankNameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true

        bankContentLabel.leadingAnchor.constraint(equalTo: bankNameLabel.trailingAnchor, constant: 5).isActive = true
        bankContentLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true

        cardNumberField.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 10).isActive = true
        cardNumberField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cardNumberField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30).isActive = true
        cardNumberField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30).isActive = true

        guideTxt.topAnchor.constraint(equalTo: self.cardNumberField.bottomAnchor, constant: 10).isActive = true
        guideTxt.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30).isActive = true
        guideTxt.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50).isActive = true

        nameField.topAnchor.constraint(equalTo: self.guideTxt.bottomAnchor, constant: 10).isActive = true
        nameField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        nameField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30).isActive = true
        nameField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30).isActive = true

        dateField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 10).isActive = true
        dateField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        dateField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30).isActive = true
        dateField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30).isActive = true

        button.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        button.topAnchor.constraint(equalTo: dateField.bottomAnchor, constant: 20).isActive = true
        button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30).isActive = true
        button.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30).isActive = true
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

