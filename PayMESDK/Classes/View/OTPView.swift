//
//  SuccessView.swift
//  PayMESDK
//
//  Created by HuyOpen on 1/11/21.
//

import Foundation

internal class OTPView: UIView {
    var onPressSendOTP: () -> () = {}

    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(for: QRNotFound.self, named: "16Px"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let image: UIImageView = {
        var bgImage = UIImageView(image: UIImage(for: QRNotFound.self, named: "iconNoticeVerifyPass"))
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()

    let roleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(11, 11, 11)
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let txtLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(26, 26, 26)
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

    let otpView: OTPInput = {
        let pinField = OTPInput()
        pinField.layer.cornerRadius = 10
        pinField.clipsToBounds = true
        pinField.translatesAutoresizingMaskIntoConstraints = false
        pinField.backgroundColor = .clear
        pinField.properties.numberOfCharacters = 6
        pinField.appearance.font = .menloBold(26) // Default to appearance.MonospacedFont.menlo(40)
        pinField.appearance.kerning = 35 // Space between characters, default to 16
        pinField.appearance.tokenColor = .clear // token color, default to text color
        pinField.appearance.textColor = UIColor(11, 11, 11)
        pinField.properties.animateFocus = false
        pinField.appearance.backOffset = 10 // Backviews spacing between each other
        pinField.appearance.backColor = UIColor(242, 244, 243)
        pinField.appearance.backBorderWidth = 1
        pinField.appearance.backBorderColor = .clear
        pinField.appearance.backCornerRadius = 15
        pinField.appearance.backFocusColor = UIColor.clear
        pinField.appearance.backBorderFocusColor = UIColor(10, 146, 32)
        pinField.appearance.backActiveColor = UIColor(242, 244, 243)
        pinField.appearance.backBorderActiveColor = UIColor.clear
        pinField.appearance.backRounded = false
        return pinField
    }()
    let sendOtpButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Gửi lại OTP", for: .normal)
        button.setTitleColor(UIColor(130, 130, 130), for: .normal)
        return button
    }()

    init() {
        super.init(frame: CGRect.zero)

        backgroundColor = .white
        self.addSubview(roleLabel)
        self.addSubview(image)
        self.addSubview(closeButton)
        self.addSubview(txtLabel)
        self.addSubview(otpView)
        addSubview(txtErrorMessage)
        self.addSubview(sendOtpButton)

        txtErrorMessage.text = "OTP không chính xác"
        txtErrorMessage.isHidden = true
        txtErrorMessage.lineBreakMode = .byWordWrapping
        txtErrorMessage.numberOfLines = 0
        txtErrorMessage.textAlignment = .center

        txtLabel.text = "Xác thực OTP"
        roleLabel.text = "Nhập mã OTP đã được gửi qua số điện thoại đăng ký thẻ"
        roleLabel.lineBreakMode = .byWordWrapping
        roleLabel.numberOfLines = 0
        roleLabel.textAlignment = .center
        // txtField.becomeFirstResponder().
        // self.hideKeyboardWhenTappedAround()


        txtLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        txtLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true

        closeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30).isActive = true

        image.topAnchor.constraint(equalTo: txtLabel.bottomAnchor, constant: 22).isActive = true
        image.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true

        roleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        roleLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 16).isActive = true
        roleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30).isActive = true
        roleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30).isActive = true

        otpView.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 20).isActive = true
        otpView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        otpView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        otpView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        txtErrorMessage.topAnchor.constraint(equalTo: otpView.bottomAnchor, constant: 8).isActive = true
        txtErrorMessage.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        txtErrorMessage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30).isActive = true
        txtErrorMessage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30).isActive = true

        sendOtpButton.topAnchor.constraint(equalTo: txtErrorMessage.bottomAnchor, constant: 8).isActive = true
        sendOtpButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        sendOtpButton.addTarget(self, action: #selector(onPress), for: .touchUpInside)

        bottomAnchor.constraint(equalTo: sendOtpButton.bottomAnchor, constant: 22).isActive = true
    }

    var countdownValue = 0

    func startCountDown(from: Int = 0) {
        if (countdownValue == 0) {
            countdownValue = from
            sendOtpButton.setTitle("Gửi lại OTP (\(String(format: "%02d", countdownValue / 60)):\(String(format: "%02d", countdownValue % 60)))", for: .disabled)
            sendOtpButton.isEnabled = false
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                if (self.countdownValue > 0) {
                    self.sendOtpButton.setTitle("Gửi lại OTP (\(String(format: "%02d", self.countdownValue / 60)):\(String(format: "%02d", self.countdownValue % 60)))", for: .disabled)
                    self.sendOtpButton.setTitleColor(UIColor(130, 130, 130), for: .disabled)
                    self.countdownValue -= 1
                } else {
                    self.sendOtpButton.setTitle("Gửi lại OTP", for: .normal)
                    self.sendOtpButton.setTitleColor(UIColor(0, 165, 0), for: .normal)
                    self.sendOtpButton.isEnabled = true
                    timer.invalidate()
                }
            }
        }
    }

    @objc func onPress() {
        onPressSendOTP()
    }

    func updateBankName(name: String) {

        roleLabel.text = "Nhập mã OTP \(name ?? "") đã được gửi qua số điện thoại đăng ký thẻ"
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
