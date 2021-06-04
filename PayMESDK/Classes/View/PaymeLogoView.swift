//
//  PaymeLogoView.swift
//  PayMESDK
//
//  Created by Nam Phan Thanh on 02/06/2021.
//

import Foundation

class PaymeLogoView: UIView {
    let hStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()

    let paymeStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 2
        stack.alignment = .center
        return stack
    }()

    let pciStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 2
        stack.alignment = .center
        return stack
    }()

    let poweredLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = UIColor(100, 112, 129)
        label.textAlignment = .left
        label.text = "Powered by "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let securityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .light)
        label.textColor = UIColor(100, 112, 129)
        label.textAlignment = .right
        label.text = "Bảo mật với chứng chỉ "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let imageLogoPayme: UIImageView = {
        var bgImage = UIImageView(image: UIImage(for: PaymeLogoView.self, named: "logoPayMe"))
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()

    let imageLogoPCi: UIImageView = {
        var bgImage = UIImageView(image: UIImage(for: PaymeLogoView.self, named: "logoPCI"))
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()

    init() {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor(239, 242, 247)

        addSubview(hStack)
        hStack.addArrangedSubview(paymeStack)
        hStack.addArrangedSubview(pciStack)
        paymeStack.addArrangedSubview(poweredLabel)
        paymeStack.addArrangedSubview(imageLogoPayme)
        pciStack.addArrangedSubview(securityLabel)
        pciStack.addArrangedSubview(imageLogoPCi)

        hStack.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        imageLogoPayme.widthAnchor.constraint(equalToConstant: 54).isActive = true

        bottomAnchor.constraint(equalTo: hStack.bottomAnchor, constant: 4).isActive = true
    }
}