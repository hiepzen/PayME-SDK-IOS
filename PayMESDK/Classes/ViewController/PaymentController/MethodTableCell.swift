//
//  MethodTableCell.swift
//  PayMESDK
//
//  Created by HuyOpen on 10/28/20.
//

import UIKit

class Method: UITableViewCell {
    struct Constants {
        static let contentInsets = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0)
        static let avatarSize = CGSize(width: 36.0, height: 36.0)
    }

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

    let imageContainer: UIView = {
        let imageContainer = UIView()
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.layer.borderWidth = 1
        imageContainer.layer.borderColor = UIColor(203, 203, 203).cgColor
        imageContainer.layer.cornerRadius = 5
        return imageContainer
    }()

    let walletMethodImage: UIImageView = {
        var bgImage = UIImageView()
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()

    let checkedImage: UIImageView = {
        var bgImage = UIImageView(image: UIImage(for: Method.self, named: "nextIcoCopy3"))
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()

    let uncheckImage: UIImageView = {
        var bgImage = UIImageView(image: UIImage(for: Method.self, named: "uncheck"))
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .white
        isAccessibilityElement = true

        let backgroundView = UIView()
        backgroundView.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.8235294118, blue: 0.8274509804, alpha: 1).withAlphaComponent(0.11)
        selectedBackgroundView = backgroundView
        contentView.addSubview(containerView)
        containerView.addSubview(walletMethodImage)
        containerView.addSubview(bankNameLabel)
        containerView.addSubview(checkedImage)
        containerView.addSubview(bankContentLabel)
        containerView.addSubview(imageContainer)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupConstraints() {
        containerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        containerView.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true

        imageContainer.heightAnchor.constraint(equalToConstant: 24).isActive = true
        imageContainer.widthAnchor.constraint(equalToConstant: 24).isActive = true
        imageContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
        imageContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true

        walletMethodImage.heightAnchor.constraint(equalToConstant: 16).isActive = true
        walletMethodImage.widthAnchor.constraint(equalToConstant: 16).isActive = true
        walletMethodImage.centerXAnchor.constraint(equalTo: imageContainer.centerXAnchor).isActive = true
        walletMethodImage.centerYAnchor.constraint(equalTo: imageContainer.centerYAnchor).isActive = true

        checkedImage.heightAnchor.constraint(equalToConstant: 12).isActive = true
        checkedImage.widthAnchor.constraint(equalToConstant: 6).isActive = true
        checkedImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        checkedImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true

        bankNameLabel.leadingAnchor.constraint(equalTo: walletMethodImage.trailingAnchor, constant: 10).isActive = true
        bankNameLabel.trailingAnchor.constraint(equalTo: bankContentLabel.leadingAnchor, constant: -5).isActive = true
        bankNameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true

        bankContentLabel.leadingAnchor.constraint(equalTo: bankNameLabel.trailingAnchor, constant: 5).isActive = true
        bankContentLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(with presentable: PaymentMethod) {
        if (presentable.type == "WALLET") {
            bankNameLabel.text = "Số dư ví"
            bankContentLabel.text = "(\(formatMoney(input: presentable.amount!))đ)"
        } else {
            bankNameLabel.text = presentable.title
            bankContentLabel.text = presentable.label
        }
        if (presentable.type.isEqual("WALLET")) {
            walletMethodImage.image = UIImage(for: PaymentModalController.self, named: "iconWallet")
        } else if (presentable.type.isEqual("LINKED")) {
            if (presentable.dataLinked != nil) {
                let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/vn-mecorp-payme-wallet.appspot.com/o/image_bank%2Fimage_method%2Fmethod\(presentable.dataLinked!.swiftCode!).png?alt=media&token=28cdb30e-fa9b-430c-8c0e-5369f500612e")
                DispatchQueue.global().async {
                    if let sureURL = url as URL? {
                        let data = try? Data(contentsOf: sureURL)
                        DispatchQueue.main.async {
                            self.walletMethodImage.image = UIImage(data: data!)
                        }
                    }
                }
            }
        } else if (presentable.type.isEqual("BANK_CARD")) {
            walletMethodImage.image = UIImage(for: Method.self, named: "fill1")
        } else {
            walletMethodImage.image = UIImage(for: Method.self, named: "iconWallet")
        }
    }
}

