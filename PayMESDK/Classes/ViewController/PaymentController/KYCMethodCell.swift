//
//  MethodTableCell.swift
//  PayMESDK
//
//  Created by HuyOpen on 10/28/20.
//

import UIKit

class KYCMethod: UITableViewCell {
    var presentable = KYCDocument(id: "", name: "", active: false)

    let containerView: UIView = {
        let containerView = UIView()
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

    let checkedImage: UIImageView = {
        var bgImage = UIImageView(image: UIImage(for: Method.self, named: "checked"))
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
        containerView.addSubview(bankNameLabel)
        containerView.addSubview(checkedImage)
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

        checkedImage.heightAnchor.constraint(equalToConstant: 18).isActive = true
        checkedImage.widthAnchor.constraint(equalToConstant: 18).isActive = true
        checkedImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        checkedImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true

        bankNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
        bankNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5).isActive = true
        bankNameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(with presentable: KYCDocument) {
        self.presentable = presentable
        bankNameLabel.text = presentable.name
        if (presentable.active == false) {
            checkedImage.image = UIImage(for: KYCMethod.self, named: "uncheck")
        } else {
            checkedImage.image = UIImage(for: KYCMethod.self, named: "checked")
        }
    }
}

