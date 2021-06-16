//
//  BankTransferView.swift
//  PayMESDK
//
//  Created by Nam Phan Thanh on 15/06/2021.
//

import Foundation

class BankTransferView: UIView {
    var paymeInfo = InformationView(data: [])

    init () {
        super.init(frame: .zero)
        setupUI()
    }

    func setupUI() {
        addSubview(bankContainer)
        addSubview(transferInfo)
        addSubview(note)

        bankContainer.addSubview(titleLabel)
        bankContainer.addSubview(contentLabel)
        bankContainer.addSubview(buttonBank)

        transferInfo.addSubview(vStack)

        let divider = UIView()
        vStack.addArrangedSubview(info)
        vStack.addArrangedSubview(divider)
        vStack.addArrangedSubview(seperator)

        bankContainer.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bankContainer.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bankContainer.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        titleLabel.topAnchor.constraint(equalTo: bankContainer.topAnchor, constant: 8).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: bankContainer.leadingAnchor, constant: 16).isActive = true

        contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
        contentLabel.leadingAnchor.constraint(equalTo: bankContainer.leadingAnchor, constant: 16).isActive = true
        contentLabel.trailingAnchor.constraint(equalTo: buttonBank.leadingAnchor, constant: -4).isActive = true

        buttonBank.centerYAnchor.constraint(equalTo: bankContainer.centerYAnchor).isActive = true
        buttonBank.trailingAnchor.constraint(equalTo: bankContainer.trailingAnchor, constant: -16).isActive = true
        buttonBank.widthAnchor.constraint(equalToConstant: 60).isActive = true

        bankContainer.bottomAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 8).isActive = true

        transferInfo.topAnchor.constraint(equalTo: bankContainer.bottomAnchor, constant: 8).isActive = true
        transferInfo.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        transferInfo.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        vStack.topAnchor.constraint(equalTo: transferInfo.topAnchor, constant: 10).isActive = true
        vStack.leadingAnchor.constraint(equalTo: transferInfo.leadingAnchor).isActive = true
        vStack.trailingAnchor.constraint(equalTo: transferInfo.trailingAnchor).isActive = true

        info.leadingAnchor.constraint(equalTo: vStack.leadingAnchor, constant: 16).isActive = true
        info.trailingAnchor.constraint(equalTo: vStack.trailingAnchor, constant: -16).isActive = true
        divider.heightAnchor.constraint(equalToConstant: 12).isActive = true
        seperator.leadingAnchor.constraint(equalTo: vStack.leadingAnchor, constant: 16).isActive = true
        seperator.trailingAnchor.constraint(equalTo: vStack.trailingAnchor, constant: -16).isActive = true

        transferInfo.bottomAnchor.constraint(equalTo: vStack.bottomAnchor, constant: 6).isActive = true

        note.topAnchor.constraint(equalTo: transferInfo.bottomAnchor, constant: 10).isActive = true
        note.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        note.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        bottomAnchor.constraint(equalTo: note.bottomAnchor).isActive = true
    }
    func updateInfo(bank: BankManual?, orderTransaction: OrderTransaction) {
        guard let paymeBank = bank else { return }
        contentLabel.text = paymeBank.bankName
        paymeInfo.removeFromSuperview()
        paymeInfo = InformationView(data: [
            ["key": "Số tài khoản",
             "value": paymeBank.bankAccountNumber,
             "keyColor": UIColor(100, 112, 129),
             "keyFont": UIFont.systemFont(ofSize: 14, weight: .regular),
             "color": UIColor(0, 0, 0),
             "font": UIFont.systemFont(ofSize: 14, weight: .regular)
            ],
            ["key": "Chủ tài khoản",
             "value": paymeBank.bankAccountName,
             "keyColor": UIColor(100, 112, 129),
             "keyFont": UIFont.systemFont(ofSize: 14, weight: .regular),
             "color": UIColor(0, 0, 0),
             "font": UIFont.systemFont(ofSize: 14, weight: .regular)
            ],
            ["key": "Nội dung",
             "value": paymeBank.content,
             "keyColor": UIColor(100, 112, 129),
             "keyFont": UIFont.systemFont(ofSize: 14, weight: .regular),
             "color": UIColor(0, 0, 0),
             "font": UIFont.systemFont(ofSize: 14, weight: .regular)
            ],
        ])

        normalText1.append(NSMutableAttributedString(string: "\(formatMoney(input: orderTransaction.total ?? 0)) đ ", attributes: [
            .font: UIFont.systemFont(ofSize: 14, weight: .bold),
            .foregroundColor: UIColor(236, 42, 42)
        ]))
        normalText1.append(normalText2)
        info.attributedText = normalText1

        vStack.addArrangedSubview(paymeInfo)
        paymeInfo.leadingAnchor.constraint(equalTo: vStack.leadingAnchor).isActive = true
        layoutIfNeeded()
        seperator.createDashedLine( from: CGPoint(x: 0, y: 0), to: CGPoint(x: seperator.frame.size.width, y: 0), color: UIColor(142, 142, 142), strokeLength: 4, gapLength: 4, width: 1)
        transferInfo.addLineDashedStroke(pattern: [4, 4], radius: 16, color: UIColor(142, 142, 142).cgColor)
    }

    let bankContainer: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor(242, 246, 247)
        container.layer.cornerRadius = 13
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(165, 174, 184)
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.text = "NGÂN HÀNG"
        return label
    }()

    let buttonBank: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(hexString: PayME.configColor[0]), for: .normal)
        button.setTitle("Thay đổi", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        return button
    }()

    let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(0, 0, 0)
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }()

    let transferInfo: UIView = {
       let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        return view
    }()
    let vStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        return stack
    }()
    let info: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()

    let normalText1 = NSMutableAttributedString(string: "Vui lòng chuyển khoản ", attributes: [
        .font: UIFont.systemFont(ofSize: 14, weight: .regular),
        .foregroundColor: UIColor(0, 0, 0)
    ])
    let normalText2 = NSMutableAttributedString(string: "tới thông tin tài khoản bên dưới:", attributes: [
        .font: UIFont.systemFont(ofSize: 14, weight: .regular),
        .foregroundColor: UIColor(0, 0, 0)
    ])

    let seperator = UIView()

    let note: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(100, 112, 129)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.text = "(*) Giao dịch sẽ được thực hiện ngay sau khi xác nhận chuyển khoản"
        return label
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}