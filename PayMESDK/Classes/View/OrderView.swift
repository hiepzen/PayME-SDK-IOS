//
//  OrderView.swift
//  PayMESDK
//
//  Created by Nam Phan Thanh on 02/06/2021.
//

import Foundation

class OrderView: UIView {
    let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let logoView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.backgroundColor = .white
        image.layer.cornerRadius = 28
        image.layer.masksToBounds = true
        return image
    }()

    let vStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .equalSpacing
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill
        return stack
    }()

    let hStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()

    let amountStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.sizeToFit()
        stack.spacing = 8
        return stack
    }()

    let amountTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .white
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "paymentAmount".localize()
        return label
    }()

    let amountInput: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .systemFont(ofSize: 28, weight: .bold)
        textField.textColor = .white
        textField.tintColor = .white
        textField.attributedPlaceholder = NSAttributedString(
                string: "Nhập số tiền thanh toán",
                attributes: [
                    NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.3),
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 28, weight: .regular)
                ])
        textField.textAlignment = .center
        return textField
    }()

    let seperator = UIView()
    var storeNameRow: InformationRow!
    var serviceRow: InformationRow!
    var noteRow: InformationRow!

    init(amount: Int = 0, storeName: String = "", serviceCode: String = "", note: String = "", logoUrl: String? = nil, isFullInfo: Bool = false) {
        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        amountLabel.text = "\(formatMoney(input: amount)) đ"

        addSubview(vStack)

        vStack.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true

        storeNameRow = InformationRow(key: "receiveName".localize(), value: storeName, color: .white, font: .systemFont(ofSize: 14, weight: .bold),
                keyColor: .white, keyFont: .systemFont(ofSize: 14, weight: .regular))
        serviceRow = InformationRow(key: "serviceCode".localize(), value: serviceCode, color: .white, font: .systemFont(ofSize: 14, weight: .regular),
                keyColor: .white, keyFont: .systemFont(ofSize: 14, weight: .regular))
        noteRow = InformationRow(key: "content".localize(), value: note, color: .white, font: .systemFont(ofSize: 14, weight: .regular),
                keyColor: .white, keyFont: .systemFont(ofSize: 14, weight: .regular))
        if logoUrl != nil && logoUrl != "" {
            logoView.load(url: logoUrl!)
            hStack.addArrangedSubview(logoView)
            logoView.heightAnchor.constraint(equalToConstant: 56).isActive = true
            logoView.widthAnchor.constraint(equalToConstant: 56).isActive = true
        } else {
            amountTitle.textAlignment = .center
            amountLabel.textAlignment = .center
        }
        hStack.addArrangedSubview(amountStack)
        amountStack.addArrangedSubview(amountTitle)
        amountStack.addArrangedSubview(amountLabel)
//        amountStack.addArrangedSubview(amountInput)
        vStack.addArrangedSubview(hStack)
        vStack.addArrangedSubview(seperator)
        vStack.addArrangedSubview(storeNameRow)
        vStack.addArrangedSubview(serviceRow)
        vStack.addArrangedSubview(noteRow)

        bottomAnchor.constraint(equalTo: vStack.bottomAnchor, constant: 16).isActive = true
        if (isFullInfo == false) {
            seperator.isHidden = true
            storeNameRow.isHidden = true
            serviceRow.isHidden = true
            noteRow.isHidden = true
        }
//        amountLabel.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if vStack.isDescendant(of: self) && seperator.isDescendant(of: vStack) {
            seperator.createDashedLine(from: CGPoint(x: 0, y: 0), to: CGPoint(x: vStack.frame.size.width, y: 0), color: UIColor(203, 203, 203), strokeLength: 2, gapLength: 2, width: 1)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}