//
//  SuccessView.swift
//  PayMESDK
//
//  Created by HuyOpen on 1/11/21.
//

import Foundation
import SVGKit
import WebKit

class SecurityCode: UIView {
    var onPressForgot: () -> () = {}

    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(for: QRNotFound.self, named: "16Px"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let roleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(11, 11, 11)
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let txtLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(11, 11, 11)
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let txtErrorMessage: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let otpView: KAPinField = {
        let pinField = KAPinField()
        pinField.layer.cornerRadius = 15
        pinField.clipsToBounds = true
        pinField.translatesAutoresizingMaskIntoConstraints = false
        pinField.backgroundColor = UIColor(239, 242, 247)
        pinField.appearance.font = .menloBold(40) // Default to appearance.MonospacedFont.menlo(40)
        pinField.appearance.kerning = 14 // Space between characters, default to 16
        pinField.appearance.tokenColor = UIColor(166, 166, 166) // token color, default to text color
        pinField.properties.animateFocus = false
        pinField.appearance.backOffset = 0 // Backviews spacing between each other
        pinField.appearance.backColor = UIColor(239, 242, 247)
        pinField.appearance.backActiveColor = UIColor(239, 242, 247)
        pinField.appearance.keyboardType = UIKeyboardType.numberPad // Specify keyboard type
        pinField.appearance.backCornerRadius = 15
        pinField.appearance.backBorderWidth = 0
        pinField.appearance.backBorderColor = UIColor(239, 242, 247)
        pinField.appearance.backFocusColor = UIColor(239, 242, 247)
        pinField.appearance.backBorderFocusColor = UIColor(239, 242, 247)
        pinField.appearance.backBorderActiveColor = UIColor(239, 242, 247)
        return pinField
    }()

    let forgotPassButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(NSAttributedString(string: "Quên mật khẩu",
        attributes: [
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            .foregroundColor: UIColor(hexString: PayME.configColor[0]),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]), for: .normal)
        return button
    }()

    init() {
        super.init(frame: CGRect.zero)

        let imageSVG = SVGKImage(for: SecurityCode.self, named: "bigIconsV160")
        imageSVG?.fillColor(color: UIColor(hexString: PayME.configColor[0]), opacity: 1)
        let svgImageView = UIImageView()
        svgImageView.translatesAutoresizingMaskIntoConstraints = false
        svgImageView.image = imageSVG?.uiImage

        backgroundColor = .white
        addSubview(roleLabel)
        addSubview(svgImageView)
        addSubview(closeButton)
        addSubview(txtLabel)
        addSubview(otpView)
        addSubview(txtErrorMessage)
        addSubview(forgotPassButton)

        txtLabel.text = "Xác thực giao dịch"
        roleLabel.text = "Nhập mật khẩu ví PayME  để xác thực"
        txtErrorMessage.text = "Mật khẩu không chính xác"
        txtErrorMessage.isHidden = true
        txtErrorMessage.lineBreakMode = .byWordWrapping
        txtErrorMessage.numberOfLines = 0
        txtErrorMessage.textAlignment = .center
        roleLabel.lineBreakMode = .byWordWrapping
        roleLabel.numberOfLines = 0
        roleLabel.textAlignment = .center

        txtLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        txtLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true

        closeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30).isActive = true

        svgImageView.topAnchor.constraint(equalTo: txtLabel.bottomAnchor, constant: 22).isActive = true
        svgImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        roleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        roleLabel.topAnchor.constraint(equalTo: svgImageView.bottomAnchor, constant: 16).isActive = true
        roleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30).isActive = true
        roleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30).isActive = true

        otpView.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 14).isActive = true
        otpView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        otpView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        otpView.heightAnchor.constraint(equalToConstant: 64).isActive = true

        txtErrorMessage.topAnchor.constraint(equalTo: otpView.bottomAnchor, constant: 8).isActive = true
        txtErrorMessage.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        txtErrorMessage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30).isActive = true
        txtErrorMessage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30).isActive = true

        forgotPassButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        forgotPassButton.topAnchor.constraint(equalTo: txtErrorMessage.bottomAnchor, constant: 8).isActive = true
        forgotPassButton.addTarget(self, action: #selector(onPressForgotPass), for: .touchUpInside)

        bottomAnchor.constraint(equalTo: forgotPassButton.bottomAnchor, constant: 22).isActive = true
    }

    @objc func onPressForgotPass() {
        onPressForgot()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
