//
//  KYCStore.swift
//  PayMESDK
//
//  Created by HuyOpen on 11/23/20.
//

import UIKit

class AvatarConfirm: UIViewController {
    public var avatarImage: UIImage?
    let screenSize: CGRect = UIScreen.main.bounds
    internal var onSuccessCapture: ((UIImage) -> ())? = nil

    let imageView: UIImageView = {
        let bundle = Bundle(for: KYCFrontController.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let image = UIImage(named: "fails", in: resourceBundle, compatibleWith: nil)
        var bgImage = UIImageView(image: nil)
        bgImage.layer.masksToBounds = true
        bgImage.layer.borderWidth = 7
        bgImage.layer.borderColor = UIColor(226, 226, 226).cgColor

        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()

    let confirmTitle: UILabel = {
        let confirmTitle = UILabel()
        confirmTitle.textColor = UIColor(24, 26, 65)
        confirmTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        confirmTitle.translatesAutoresizingMaskIntoConstraints = false
        confirmTitle.textAlignment = .center
        confirmTitle.lineBreakMode = .byWordWrapping
        confirmTitle.numberOfLines = 0
        confirmTitle.text = "Vui lòng xác nhận ảnh đã rõ nét, gương mặt của bạn đã có trong khung hình."
        return confirmTitle
    }()

    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor(24, 26, 65)
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.text = "Xác nhận ảnh"
        return titleLabel
    }()

    let backButton: UIButton = {
        let button = UIButton()
        let bundle = Bundle(for: KYCFrontController.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let image = UIImage(named: "32Px", in: resourceBundle, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let captureAgain: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.setTitle("LÀM LẠI", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(UIColor(10, 146, 32), for: .normal)
        return button
    }()

    let confirm: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.setTitle("HOÀN TẤT", for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(backButton)
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(captureAgain)
        view.addSubview(confirm)
        view.addSubview(confirmTitle)
        view.backgroundColor = .white
        imageView.image = avatarImage
        imageView.layer.cornerRadius = (screenSize.width - 32) / 2

        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                backButton.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0),
                titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.4),
                captureAgain.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -18),
                confirm.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -18)
            ])
        } else {
            let standardSpacing: CGFloat = 8.0
            NSLayoutConstraint.activate([
                backButton.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing),
                titleLabel.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing + 5),
                captureAgain.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: -standardSpacing),
                confirm.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: -standardSpacing)
            ])
        }
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        captureAgain.heightAnchor.constraint(equalToConstant: 50).isActive = true
        captureAgain.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        captureAgain.widthAnchor.constraint(equalToConstant: (screenSize.width / 2) - 20).isActive = true

        confirm.heightAnchor.constraint(equalToConstant: 50).isActive = true
        confirm.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        confirm.widthAnchor.constraint(equalToConstant: (screenSize.width / 2) - 20).isActive = true

        imageView.widthAnchor.constraint(equalToConstant: screenSize.width - 32).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: screenSize.width - 32).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 70).isActive = true

        confirmTitle.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 21).isActive = true
        confirmTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        confirmTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true

        backButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true

        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        captureAgain.addTarget(self, action: #selector(back), for: .touchUpInside)
        confirm.addTarget(self, action: #selector(capture), for: .touchUpInside)
    }

    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func capture() {
        KYCController.imageAvatar = avatarImage!
        if (KYCController.flowKYC!["kycVideo"] == true) {
            let popupKYC = PopupKYC()
            popupKYC.active = 2
            PayME.currentVC?.present(popupKYC, animated: true)
        } else {
            KYCController.uploadKYC()
        }
    }

    override func viewDidLayoutSubviews() {
        let colorButton = [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor]
        captureAgain.applyGradient(colors: colorButton, radius: 10)
        captureAgain.setTitleColor(.white, for: .normal)
        confirm.applyGradient(colors: colorButton, radius: 10)
        confirm.setTitleColor(.white, for: .normal)
    }
}
