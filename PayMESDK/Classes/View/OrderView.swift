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

//    let logoView: UIImageView = {
//        let image  =
//    }

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
        return stack
    }()

    let amountStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.sizeToFit()
        return stack
    }()

    let amountTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .white
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Số tiền thanh toán"
        return label
    }()

    let seperator = UIView()

    init(amount: Int, storeName: String, serviceCode: String, note: String, logoUrl: String? = nil) {
        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        amountLabel.text = "\(formatMoney(input: amount)) đ"

        addSubview(vStack)

        vStack.topAnchor.constraint(equalTo: self.topAnchor, constant: 16).isActive = true
        vStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        vStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true

        let storeNameRow = InformationRow(key: "Người nhận", value: storeName, color: .white, font: .systemFont(ofSize: 14, weight: .bold),
                keyColor: .white, keyFont: .systemFont(ofSize: 14, weight: .regular))
        let serviceRow = InformationRow(key: "Mã dịch vụ", value: "123456789", color: .white, font: .systemFont(ofSize: 14, weight: .regular),
                keyColor: .white, keyFont: .systemFont(ofSize: 14, weight: .regular))
        let noteRow = InformationRow(key: "Nội dung", value: note, color: .white, font: .systemFont(ofSize: 14, weight: .regular),
                keyColor: .white, keyFont: .systemFont(ofSize: 14, weight: .regular))
        if logoUrl != nil && logoUrl != "" {

        } else {
            amountTitle.textAlignment = .center
            amountLabel.textAlignment = .center
        }
        hStack.addArrangedSubview(amountStack)
        amountStack.addArrangedSubview(amountTitle)
        amountStack.addArrangedSubview(amountLabel)
        vStack.addArrangedSubview(hStack)
        vStack.addArrangedSubview(seperator)
        vStack.addArrangedSubview(storeNameRow)
        vStack.addArrangedSubview(serviceRow)
        vStack.addArrangedSubview(noteRow)

        bottomAnchor.constraint(equalTo: vStack.bottomAnchor, constant: 16).isActive = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if vStack.isDescendant(of: self) && seperator.isDescendant(of: vStack) {
            print("aksjhfkdsahjfasdkjjfaslokjfadslkdjf")
            seperator.createDashedLine(from: CGPoint(x: 0, y: 0), to: CGPoint(x: vStack.frame.size.width, y: 0), color: UIColor(203, 203, 203), strokeLength: 2, gapLength: 2, width: 1)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}