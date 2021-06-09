//
//  MethodView.swift
//  PayMESDK
//
//  Created by Nam Phan Thanh on 14/05/2021.
//

enum MethodType: String {
    case WALLET = "WALLET"
    case BANK_CARD = "BANK_CARD"
    case BANK_ACCOUNT = "BANK_ACCOUNT"
    case BANK_QR_CODE = "BANK_QR_CODE"
    case BANK_TRANSFER = "BANK_TRANSFER"
    case CREDIT_CARD = "CREDIT_CARD"
    case LINKED = "LINKED"
    case PAYME_CREDIT = "PAYME_CREDIT"
    case BANK_CARD_PG = "BANK_CARD_PG"
    case MOMO_PG = "MOMO_PG"
    case CREDIT_CARD_PG = "CREDIT_CARD_PG"
    case BANK_QR_CODE_PG = "BANK_QR_CODE_PG"
    case ZALOPAY_PG = "ZALOPAY_PG"
}

import Foundation
class MethodView: UIView {
    var content: String?
    var title: String = ""
    var buttonTitle: String?
    var note: String?
    var methodDescription: String?
    var onPress: (() -> ())? = nil

    let vStack: UIStackView = {
       let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .equalSpacing
        return stack
    }()

    let containerInfo: UIView = {
       let container = UIView()
        container.backgroundColor = .clear
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()

    let image: UIImageView = {
        var bgImage = UIImageView()
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(11, 11, 11)
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()

    let contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(124, 124, 124)
        label.backgroundColor = .clear
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()

    let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(hexString: PayME.configColor[0]), for: .normal)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(hexString: PayME.configColor[0]).cgColor
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        return button
    }()

    let seperator: UIView = {
        let sepe = UIView()
        sepe.backgroundColor = UIColor(252, 252, 252)
        sepe.translatesAutoresizingMaskIntoConstraints = false
        return sepe
    }()

    let noteLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(255, 0, 0)
        label.backgroundColor = .clear
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()

    let imageNext: UIImageView = {
        var bgImage = UIImageView(image: UIImage(for: MethodView.self, named: "nextIcoCopy3"))
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()

    let infoVStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        return stack
    }()

    let methodDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(100, 112, 129)
        label.backgroundColor = .clear
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()

    let infoHStack: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.spacing = 6
    return stack
    }()

    init (title: String = "", content: String? = nil, buttonTitle: String? = nil, note: String? = nil, methodDescription: String? = nil){
        self.title = title
        self.content = content ?? nil
        self.buttonTitle = buttonTitle ?? nil
        self.note = note ?? nil
        self.methodDescription = methodDescription ?? nil
        super.init(frame: CGRect.zero)
        setUpUI()
    }

    func setUpUI() {
        self.layer.cornerRadius = 15
        self.backgroundColor = UIColor(239, 242, 247)
        self.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(vStack)

        vStack.topAnchor.constraint(equalTo: self.topAnchor, constant: 12).isActive = true
        vStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        vStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        vStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12).isActive = true

        vStack.addArrangedSubview(containerInfo)
        containerInfo.heightAnchor.constraint(equalToConstant: 34).isActive = true

        containerInfo.addSubview(image)
        image.heightAnchor.constraint(equalToConstant: 34).isActive = true
        image.widthAnchor.constraint(equalToConstant: 34).isActive = true
        image.leadingAnchor.constraint(equalTo: containerInfo.leadingAnchor).isActive = true

        containerInfo.addSubview(infoVStack)
        infoVStack.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 12).isActive = true
        infoVStack.centerYAnchor.constraint(equalTo: containerInfo.centerYAnchor).isActive = true

        infoVStack.addArrangedSubview(infoHStack)
        infoHStack.addArrangedSubview(titleLabel)
        infoHStack.addArrangedSubview(contentLabel)
//        titleLabel.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 8).isActive = true
//        titleLabel.centerYAnchor.constraint(equalTo: containerInfo.centerYAnchor).isActive = true
        infoVStack.addArrangedSubview(methodDescriptionLabel)

//        contentLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 5).isActive = true
//        contentLabel.centerYAnchor.constraint(equalTo: containerInfo.centerYAnchor).isActive = true

        containerInfo.addSubview(button)
        button.trailingAnchor.constraint(equalTo: containerInfo.trailingAnchor).isActive = true
        button.heightAnchor.constraint(equalTo: containerInfo.heightAnchor).isActive = true
        button.addTarget(self, action: #selector(onPressFunction), for: .touchUpInside)


        containerInfo.addSubview(imageNext)
        imageNext.heightAnchor.constraint(equalToConstant: 12).isActive = true
        imageNext.widthAnchor.constraint(equalToConstant: 6).isActive = true
        imageNext.trailingAnchor.constraint(equalTo: containerInfo.trailingAnchor).isActive = true
        imageNext.centerYAnchor.constraint(equalTo: containerInfo.centerYAnchor).isActive = true

        vStack.addArrangedSubview(seperator)
        seperator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        vStack.addArrangedSubview(noteLabel)
        updateUI()
    }

    func updateUI() {
        titleLabel.text = title
        contentLabel.text = content ?? ""
        noteLabel.text = note ?? ""
        methodDescriptionLabel.text = methodDescription ?? ""


        if (buttonTitle != nil) {
            imageNext.isHidden = true
            button.isHidden = false
            button.setTitle(buttonTitle, for: .normal)
        } else {
            button.isHidden = true
            imageNext.isHidden = false
        }

        if (note != nil) {
            seperator.isHidden = false
            noteLabel.isHidden = false
        } else {
            seperator.isHidden = true
            noteLabel.isHidden = true
        }

        if (methodDescription != nil && methodDescription != "") {
            methodDescriptionLabel.isHidden = false
        } else {
            methodDescriptionLabel.isHidden = true
        }
    }

    @objc func onPressFunction() {
        (onPress ?? {})()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}