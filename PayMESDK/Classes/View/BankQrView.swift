//
//  BankQrView.swift
//  PayMESDK
//
//  Created by Nam Phan Thanh on 05/07/2021.
//

import Foundation
import SVGKit

class BankInfoRow: UIStackView {
    var key: String
    var value: String
    var allowCopy: Bool

    init(key: String, value: String, allowCopy: Bool = false) {
        self.key = key
        self.value = value
        self.allowCopy = allowCopy
        super.init(frame: CGRect.zero)
        setUpUI()
    }
    func setUpUI() {
        backgroundColor = .clear
        axis = .horizontal
        spacing = 4
        translatesAutoresizingMaskIntoConstraints = false

        valueLabel.text = key + ": " + value

        addArrangedSubview(valueLabel)
        if allowCopy == true {
            let imageSVG = SVGKImage(for: InformationRow.self, named: "iconCopy")
            imageSVG?.fillColor(color: UIColor(hexString: PayME.configColor[0]), opacity: 1)
            svgImage.image = imageSVG?.uiImage
            let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onPressCopy))
            singleTap.numberOfTapsRequired = 1
            svgImage.addGestureRecognizer(singleTap)
            addArrangedSubview(svgImage)
        }

        valueLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        svgImage.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    @objc func onPressCopy() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = value
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let valueLabel: UILabel = {
        let keyLabel = UILabel()
        keyLabel.textColor = UIColor(0, 0, 0)
        keyLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        keyLabel.textAlignment = .left
        keyLabel.numberOfLines = 0
        keyLabel.lineBreakMode = .byWordWrapping
        return keyLabel
    }()

    let svgImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
}

class BankQrView: UIView {
    var qrString: String = ""
    var bank: BankManual
    init(qrString: String, bank: BankManual) {
        self.qrString = qrString
        self.bank = bank
        super.init(frame: CGRect.zero)
        setUpUI()
    }

    func setUpUI() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 15
        backgroundColor = .white

        addSubview(hStack)

        if bank.qrCode != "" {
            hStack.addArrangedSubview(qrContainer)
            qrContainer.addSubview(qrImageView)
            if let qrImage = bank.qrCode.generateQRImage(withLogo: UIImage(for: BankQrView.self, named: "logoVietQr")) {
                qrImageView.image = qrImage
            }
        }
        hStack.addArrangedSubview(vStack)

        vStack.addArrangedSubview(bankNameLabel)
        if bank.bankAccountNumber != "" {
            let accNum = BankInfoRow(key: "acroAccountNum".localize(), value: bank.bankAccountNumber, allowCopy: true)
            vStack.addArrangedSubview(accNum)
        }
        if bank.bankAccountName != "" {
            let accName = BankInfoRow(key: "acroCardHolder".localize(), value: bank.bankAccountName, allowCopy: false)
            vStack.addArrangedSubview(accName)
        }
        if bank.content != "" {
            let accNum = BankInfoRow(key: "content".localize(), value: bank.content, allowCopy: true)
            vStack.addArrangedSubview(accNum)
        }

        hStack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        hStack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        hStack.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        hStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true

        qrContainer.heightAnchor.constraint(equalToConstant: 80).isActive = true
        qrContainer.widthAnchor.constraint(equalToConstant: 80).isActive = true

        if qrImageView.isDescendant(of: qrContainer) {
            qrImageView.topAnchor.constraint(equalTo: qrContainer.topAnchor, constant: 6).isActive = true
            qrImageView.bottomAnchor.constraint(equalTo: qrContainer.bottomAnchor, constant: -6).isActive = true
            qrImageView.leadingAnchor.constraint(equalTo: qrContainer.leadingAnchor, constant: 6).isActive = true
            qrImageView.trailingAnchor.constraint(equalTo: qrContainer.trailingAnchor, constant: -6).isActive = true
        }

        bankNameLabel.text = bank.bankName
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let hStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 16
        return stack
    }()
    let vStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 6
        return stack
    }()
    let qrContainer: UIView = {
        let containerView = UIView()
        containerView.layer.cornerRadius = 12
        containerView.backgroundColor = UIColor(255, 255, 255)
        containerView.layer.shadowColor = UIColor(0, 0, 0).cgColor
        containerView.layer.shadowOpacity = 0.15
        containerView.layer.shadowOffset = .zero
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    let qrImageView: UIImageView = {
        var image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()
    let noteLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "qrBankDescription".localize()
        label.textColor = UIColor(0, 0, 0)
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    let bankNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(0, 0, 0)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = .systemFont(ofSize: 14, weight: .bold)
        return label
    }()

}