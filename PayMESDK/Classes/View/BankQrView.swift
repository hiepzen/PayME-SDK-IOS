//
//  BankQrView.swift
//  PayMESDK
//
//  Created by Nam Phan Thanh on 05/07/2021.
//

import Foundation
import SVGKit

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
            let logo = UIImage(for: BankQrView.self, named: "logoVietQr")?.resize(newSize: CGSize(width: 8, height: 8))
            if let qrImage = bank.qrCode.generateQRImage(withLogo: logo) {
                qrImageView.image = qrImage
            }
        }
        hStack.addArrangedSubview(vStack)
        vStack.addArrangedSubview(noteLabel)
        vStack.addArrangedSubview(logoStack)

        hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        hStack.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        hStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true

        qrContainer.heightAnchor.constraint(equalToConstant: 130).isActive = true
        qrContainer.widthAnchor.constraint(equalToConstant: 130).isActive = true

        if qrImageView.isDescendant(of: qrContainer) {
            qrImageView.topAnchor.constraint(equalTo: qrContainer.topAnchor, constant: 4).isActive = true
            qrImageView.bottomAnchor.constraint(equalTo: qrContainer.bottomAnchor, constant: -4).isActive = true
            qrImageView.leadingAnchor.constraint(equalTo: qrContainer.leadingAnchor, constant: 4).isActive = true
            qrImageView.trailingAnchor.constraint(equalTo: qrContainer.trailingAnchor, constant: -4).isActive = true
        }
        logoStack.addArrangedSubview(napasLogo)
        logoStack.addArrangedSubview(seperator)
        logoStack.addArrangedSubview(bankLogo)

        napasLogo.widthAnchor.constraint(equalToConstant: 74).isActive = true
        napasLogo.heightAnchor.constraint(equalToConstant: 49).isActive = true
        seperator.widthAnchor.constraint(equalToConstant: 1).isActive = true
        seperator.heightAnchor.constraint(equalToConstant: 23).isActive = true
        bankLogo.heightAnchor.constraint(equalToConstant: 32).isActive = true

        bankLogo.load(url: "https://firebasestorage.googleapis.com/v0/b/vn-mecorp-payme-wallet.appspot.com/o/image_bank%2Ficon_banks%2Ficon\(bank.swiftCode)%402x.png?alt=media&token=0c6cd79a-9a4f-4ea2-b178-94e0b4731ac2")
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
        stack.spacing = 24
        return stack
    }()
    let qrContainer: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = UIColor(255, 255, 255)
        containerView.layer.borderColor = UIColor(36, 76, 127).cgColor
        containerView.layer.borderWidth = 1
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
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    let logoStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 14
        return stack
    }()
    let napasLogo: UIImageView = {
        var logo = UIImageView(image: UIImage(for: BankQrView.self, named: "napasLogo"))
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.contentMode = .scaleAspectFit
        return logo
    }()
    let seperator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(164, 174, 184)
        return view
    }()
    let bankLogo: UIImageView = {
        var image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()
}