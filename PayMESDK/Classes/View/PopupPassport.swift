//
//  PopupPassport.swift
//  PayMESDK
//
//  Created by Minh Khoa on 07/06/2021.
//

import Foundation
import Lottie
import SVGKit

class PopupPassport: UIView {
    let rootView = UIStackView()
    let screenSize: CGRect = UIScreen.main.bounds

    let icon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor(24, 26, 65)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hộ chiếu chỉ dùng để cung cấp định danh cho người nước ngoài"
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        return label

    }()

    let continueButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hexString: PayME.configColor[0])
        button.setTitle("Đồng ý", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1), for: UIControl.State.normal)
        button.layer.cornerRadius = 20
        return button
    }()

    let cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hexString: PayME.configColor[0])
        button.setTitle("Thay đổi", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1), for: UIControl.State.normal)
        button.layer.cornerRadius = 20
        return button
    }()

    let imageView: UIImageView = {
        var bgImage = UIImageView(image: UIImage(for: QRScannerController.self, named: "scanCmnd"))
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()

    let buttonContainer = UIStackView()

    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = .white
        layer.cornerRadius = 15

        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.spacing = 8
        buttonContainer.axis = .horizontal
        buttonContainer.alignment = .fill
        buttonContainer.distribution = .fillEqually

        addSubview(rootView)

        rootView.addSubview(buttonContainer)
        buttonContainer.addArrangedSubview(continueButton)
        buttonContainer.addArrangedSubview(cancelButton)
        rootView.addSubview(titleLabel)
        rootView.addSubview(icon)

        let imageSVG = SVGKImage(for: PopupPassport.self, named: "artHochieu")
        imageSVG?.fillColor(color: UIColor(hexString: PayME.configColor[0]), opacity: 1, defaultColor: "#0AB822")
        icon.image = imageSVG?.uiImage

        rootView.translatesAutoresizingMaskIntoConstraints = false
        rootView.axis = .vertical
        rootView.alignment = .center

        rootView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        rootView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        rootView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        rootView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        icon.widthAnchor.constraint(equalToConstant: 200).isActive = true
        icon.heightAnchor.constraint(equalToConstant:  180).isActive = true
        icon.topAnchor.constraint(equalTo: rootView.topAnchor, constant: 30).isActive = true
        icon.centerXAnchor.constraint(equalTo: rootView.centerXAnchor).isActive = true

        titleLabel.centerXAnchor.constraint(equalTo: rootView.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 20).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 20).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -20).isActive = true

        buttonContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24).isActive = true
        buttonContainer.centerXAnchor.constraint(equalTo: rootView.centerXAnchor).isActive = true
        buttonContainer.heightAnchor.constraint(equalToConstant: 45).isActive = true
        buttonContainer.widthAnchor.constraint(equalTo: rootView.widthAnchor, constant: -34).isActive = true
        buttonContainer.bottomAnchor.constraint(equalTo: rootView.bottomAnchor, constant: -20).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
