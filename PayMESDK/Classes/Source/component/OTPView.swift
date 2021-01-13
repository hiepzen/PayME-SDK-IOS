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
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(24,26,65)
        label.font = UIFont(name: "Lato-Bold", size: 25)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let roleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(115,115,115)
        label.backgroundColor = .clear
        label.font = UIFont(name: "Lato-Regular", size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let button : UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(8,148,31)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        return button
    }()
    
    let txtLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor(26,26,26)
        label.backgroundColor = .clear
        label.font = UIFont(name: "Lato-SemiBold", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let otpView : KAPinField = {
        let pinField = KAPinField()
        pinField.layer.cornerRadius = 10
        pinField.clipsToBounds = true
        pinField.translatesAutoresizingMaskIntoConstraints = false
        pinField.backgroundColor = UIColor.init(242,244,243)
        pinField.appearance.font = .menloBold(40) // Default to appearance.MonospacedFont.menlo(40)
        pinField.appearance.kerning = 20 // Space between characters, default to 16
        pinField.appearance.tokenColor = UIColor.black.withAlphaComponent(0.3) // token color, default to text color
        pinField.properties.animateFocus = false
        pinField.appearance.backOffset = 0 // Backviews spacing between each other
        pinField.appearance.backColor = UIColor.init(242,244,243)
        pinField.appearance.backActiveColor = UIColor.white
        pinField.appearance.keyboardType = UIKeyboardType.numberPad // Specify keyboard type
        pinField.appearance.backCornerRadius = 0
        return pinField
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        
        backgroundColor = .white
        self.addSubview(nameLabel)
        self.addSubview(roleLabel)
        self.addSubview(image)
        self.addSubview(closeButton)
        self.addSubview(txtLabel)
        self.addSubview(otpView)

        
        txtLabel.text = "Xác thực OTP"
        roleLabel.text = "OTP đã được gửi tới SDT của bạn."
        roleLabel.lineBreakMode = .byWordWrapping
        roleLabel.numberOfLines = 0
        roleLabel.textAlignment = .center
        // txtField.becomeFirstResponder()
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
        
        otpView.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 10).isActive = true
        otpView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50).isActive = true
        otpView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
