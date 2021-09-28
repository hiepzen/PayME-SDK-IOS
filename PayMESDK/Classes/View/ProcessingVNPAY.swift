//
//  ProcessingVNPAY.swift
//  PayMESDK
//
//  Created by Minh Khoa on 28/09/2021.
//

import Foundation
import UIKit

class ProcessingVNPAY : UIView {
    var onPressBack: () -> () = {}

    init() {
        super.init(frame: .zero)
        setupUI()
    }

    func setupUI() {
        backgroundColor = .white
        addSubview(vStack)

        vStack.addArrangedSubview(label)
        vStack.addArrangedSubview(activityIndicator)
        vStack.addArrangedSubview(button)

        vStack.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true

        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        button.addTarget(self, action: #selector(onBackTransferBank), for: .touchUpInside)
        bottomAnchor.constraint(equalTo: vStack.bottomAnchor, constant: 33).isActive = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let colorButton = [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor]
        button.layer.borderWidth = 1
        button.layer.borderColor = colorButton[0]
        button.setTitleColor(UIColor(hexString: PayME.configColor[0]), for: .normal)
        button.layer.cornerRadius = 22
    }

    @objc func onBackTransferBank() {
        onPressBack()
    }

    let vStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .equalSpacing
        stack.axis = .vertical
        stack.spacing = 26
        return stack
    }()

    let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator.color = UIColor(hexString: PayME.configColor[0])
        activityIndicator.startAnimating()
        return activityIndicator
    }()

    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = UIColor(0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.text = "processingTransaction".localize()
        return label
    }()

    let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.setTitle("cancelTransaction".localize(), for: .normal)
        return button
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
