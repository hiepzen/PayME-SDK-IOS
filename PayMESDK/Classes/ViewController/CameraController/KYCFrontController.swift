//
//  KYCStore.swift
//  PayMESDK
//
//  Created by HuyOpen on 11/23/20.
//

import UIKit

class KYCFrontController: UIViewController {
    var kycImage: UIImage?
    var active: Int?
    let screenSize: CGRect = UIScreen.main.bounds
    var parentVC: KYCCameraController?

    let imageView: UIImageView = {
        var bgImage = UIImageView(image: nil)
        bgImage.layer.cornerRadius = 15
        bgImage.layer.masksToBounds = true
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
        confirmTitle.text = "kycContent3".localize()
        return confirmTitle
    }()

    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor(24, 26, 65)
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.text = "confirmImage".localize()
        return titleLabel
    }()

    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(for: KYCFrontController.self, named: "32Px"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let captureAgain: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.setTitle("captureAgain".localize(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(UIColor(10, 146, 32), for: .normal)
        return button
    }()

    let confirm: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.setTitle("continue".localize(), for: .normal)
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
        imageView.image = self.kycImage

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
        imageView.heightAnchor.constraint(equalToConstant: (screenSize.width - 32) * 0.67).isActive = true
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
        navigationController?.popViewController(animated: true)
    }

    @objc func capture() {
        if (active! != 2) {
            let kycCameraController = KYCCameraController()
            kycCameraController.imageFront = kycImage
            kycCameraController.active = active!
            navigationController?.pushViewController(kycCameraController, animated: true)

        } else {
            KYCController.imageDocument = [self.kycImage!]
            KYCController.active = self.active
            let popupKYC = PopupKYC()
            if (KYCController.flowKYC!["kycFace"] == true) {
                popupKYC.active = 1
                PayME.currentVC?.presentModal(popupKYC, animated: true)

            } else if (KYCController.flowKYC!["kycVideo"] == true) {
                popupKYC.active = 2
                PayME.currentVC?.presentModal(popupKYC, animated: true)
            } else {
                KYCController.uploadKYC()
            }
        }
    }

    override func viewDidLayoutSubviews() {
        let colorButton = [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor]
        captureAgain.layer.borderWidth = 1
        captureAgain.layer.borderColor = colorButton[0]
        captureAgain.setTitleColor(UIColor(hexString: PayME.configColor[0]), for: .normal)
        captureAgain.layer.cornerRadius = 22
        confirm.applyGradient(colors: colorButton, radius: 22)
        confirm.setTitleColor(.white, for: .normal)
    }
}
