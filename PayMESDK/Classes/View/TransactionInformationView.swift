//
//  TransactionInfomation.swift
//  PayMESDK
//
//  Created by Nam Phan Thanh on 13/05/2021.
//

import Foundation

class InformationColumn: UIStackView {
    var key: String?
    var value: String?
    var textAlign: NSTextAlignment


    let keyLabel: UILabel = {
        let keyLabel = UILabel()
        keyLabel.textColor = UIColor(111, 132, 150)
        keyLabel.backgroundColor = .clear
        keyLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        return keyLabel
    }()

    let valueLabel: UILabel = {
        let valueLabel = UILabel()
        valueLabel.textColor = UIColor(11, 11, 11)
        valueLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        valueLabel.backgroundColor = .clear
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.lineBreakMode = .byWordWrapping
        valueLabel.numberOfLines = 0
        return valueLabel
    }()


    init(key: String, value: String, textAlign: NSTextAlignment = NSTextAlignment.left) {
        self.key = key
        self.value = value
        self.textAlign = textAlign
        super.init(frame: CGRect.zero)
        setUpUI()
    }
    func setUpUI() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.distribution = .equalSpacing
        self.axis = .vertical
        self.spacing = 8

        valueLabel.text = value
        valueLabel.textAlignment = textAlign
        keyLabel.text = key
        keyLabel.textAlignment = textAlign

        self.addArrangedSubview(keyLabel)
        self.addArrangedSubview(valueLabel)

        keyLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        keyLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true

        valueLabel.topAnchor.constraint(equalTo: keyLabel.bottomAnchor, constant: 8).isActive = true
        valueLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TransactionInformationView: UIView {
    var id: String?
    var timeStamp: String?

    let hStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .clear
        stack.distribution = .equalSpacing
        stack.axis = .horizontal
        return stack
    }()

    init(id: String?, time: String?) {
        self.id = id
        timeStamp = time
        super.init(frame: CGRect.zero)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUpUI(){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        self.layer.cornerRadius = 15
        self.addSubview(hStack)
        hStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        hStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        hStack.topAnchor.constraint(equalTo: self.topAnchor, constant: 16).isActive = true
        hStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16).isActive = true

        let vStackId = InformationColumn(key: "transactionCode".localize(), value: id ?? "N/A", textAlign: .left)
        let vStackTime = InformationColumn(key: "transactionTime".localize(), value: timeStamp ?? "N/A", textAlign: .right)

        hStack.addArrangedSubview(vStackId)
        hStack.addArrangedSubview(vStackTime)

        vStackId.topAnchor.constraint(equalTo: hStack.topAnchor).isActive = true
        vStackId.leadingAnchor.constraint(equalTo: hStack.leadingAnchor).isActive = true
        vStackId.bottomAnchor.constraint(equalTo: hStack.bottomAnchor).isActive = true

        vStackTime.topAnchor.constraint(equalTo: hStack.topAnchor).isActive = true
        vStackTime.trailingAnchor.constraint(equalTo: hStack.trailingAnchor).isActive = true
        vStackTime.bottomAnchor.constraint(equalTo: hStack.bottomAnchor).isActive = true
    }

}
