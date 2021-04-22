//
//  SuccessView.swift
//  PayMESDK
//
//  Created by HuyOpen on 1/11/21.
//

import Foundation

internal class OTPView: UIView {
    
    let closeButton : UIButton = {
        let button = UIButton()
        let bundle = Bundle(for: QRNotFound.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let image = UIImage(named: "16Px", in: resourceBundle, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let image: UIImageView = {
        let bundle = Bundle(for: QRNotFound.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let image = UIImage(named: "touchId", in: resourceBundle, compatibleWith: nil)
        var bgImage = UIImageView(image: image)
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()

    let roleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(11,11,11)
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let txtLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor(26,26,26)
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let otpView : OTPInput = {
        let pinField = OTPInput()
        pinField.layer.cornerRadius = 10
        pinField.clipsToBounds = true
        pinField.translatesAutoresizingMaskIntoConstraints = false
        pinField.backgroundColor = .clear
        pinField.properties.numberOfCharacters = 6
        pinField.appearance.font = .menloBold(26) // Default to appearance.MonospacedFont.menlo(40)
        pinField.appearance.kerning = 35 // Space between characters, default to 16
        pinField.appearance.tokenColor = .clear // token color, default to text color
        pinField.appearance.textColor = UIColor(11,11,11)
        pinField.properties.animateFocus = false
        pinField.appearance.backOffset = 10 // Backviews spacing between each other
        pinField.appearance.backColor = UIColor(242,244,243)
        pinField.appearance.backBorderWidth = 1
        pinField.appearance.backBorderColor = .clear
        pinField.appearance.backCornerRadius = 15
        pinField.appearance.backFocusColor = UIColor.clear
        pinField.appearance.backBorderFocusColor = UIColor(10,146,32)
        pinField.appearance.backActiveColor = UIColor(242,244,243)
        pinField.appearance.backBorderActiveColor = UIColor.clear
        pinField.appearance.backRounded = false
        return pinField
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        
        backgroundColor = .white
        self.addSubview(roleLabel)
        self.addSubview(image)
        self.addSubview(closeButton)
        self.addSubview(txtLabel)
        self.addSubview(otpView)

        
        txtLabel.text = "Xác thực OTP"
        roleLabel.text = "Nhập mã OTP PVComBank đã được gửi qua số điện thoại đăng ký thẻ"
        roleLabel.lineBreakMode = .byWordWrapping
        roleLabel.numberOfLines = 0
        roleLabel.textAlignment = .center
        // txtField.becomeFirstResponder().
        // self.hideKeyboardWhenTappedAround()

        
        txtLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 19).isActive = true
        txtLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        closeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 19).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30).isActive = true
        
        image.topAnchor.constraint(equalTo: txtLabel.topAnchor, constant: 30).isActive = true
        image.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        roleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        roleLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 10).isActive = true
        roleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30).isActive = true
        roleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30).isActive = true
        
        otpView.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 20).isActive = true
        otpView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        otpView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15).isActive = true
        otpView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
