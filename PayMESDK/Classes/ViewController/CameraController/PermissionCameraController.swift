//
//  QRScannerController.swift
//  PayMESDK
//
//  Created by HuyOpen on 11/8/20.
//

import UIKit
import AVFoundation

class PermissionCamera: UIViewController {
    private var onSuccess: ((String) -> ())? = nil

    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(for: KYCFrontController.self, named: "icSetArrowBack32Px"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let confirm: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 15
        button.setTitle("CHO PHÉP", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .green
        return button
    }()

    let containerView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    let contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(115, 115, 115)
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    let iconNullCamera: UIImageView = {
        var bgImage = UIImageView(image: UIImage(for: QRScannerController.self, named: "iconArtNullNoCameraAccess"))
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()

    public func setOnSuccess(onSuccess: @escaping (String) -> ()) {
        self.onSuccess = onSuccess
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(29, 29, 39)

        view.addSubview(backButton)
        view.addSubview(containerView)

        containerView.addSubview(iconNullCamera)
        containerView.addSubview(titleLabel)
        containerView.addSubview(contentLabel)
        containerView.addSubview(confirm)

        titleLabel.text = "permissionContent".localize()
        contentLabel.text = "permissionContent1".localize()

        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                backButton.topAnchor.constraint(equalTo: guide.topAnchor, constant: 18),
            ])
        } else {
            NSLayoutConstraint.activate([
                backButton.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 18),
            ])
        }

        NSLayoutConstraint.activate([

            backButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            backButton.heightAnchor.constraint(equalToConstant: 32),
            backButton.widthAnchor.constraint(equalToConstant: 32),

            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            iconNullCamera.topAnchor.constraint(equalTo: containerView.topAnchor),
            iconNullCamera.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconNullCamera.widthAnchor.constraint(equalToConstant: 256),
            iconNullCamera.heightAnchor.constraint(equalToConstant: 256),

            titleLabel.topAnchor.constraint(equalTo: iconNullCamera.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 36),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -36),

            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            contentLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 36),
            contentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -36),

            confirm.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            confirm.heightAnchor.constraint(equalToConstant: 45),
            confirm.widthAnchor.constraint(equalToConstant: 225),
            confirm.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 19),
            confirm.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

        ])


        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        confirm.addTarget(self, action: #selector(proceedWithCameraAccess), for: .touchUpInside)

        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.authorized {
            self.navigationController?.popViewController(animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func back() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == AVAuthorizationStatus.denied {
            if PayME.isRecreateNavigationController {
                PayME.currentVC?.dismiss(animated: true)
            } else {
                var navigationArray = navigationController!.viewControllers
                navigationArray.remove(at: navigationArray.count - 2)
                navigationController?.viewControllers = navigationArray
            }
        }
        navigationController?.popViewController(animated: true)
    }

    @objc func proceedWithCameraAccess() {
        // handler in .requestAccess is needed to process user's answer to our request
        AVCaptureDevice.requestAccess(for: .video) { success in
            if success { // if request is granted (success is true)
                self.navigationController?.popViewController(animated: true)
            } else { // if request is denied (success is false)
                DispatchQueue.main.async {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
            }
        }
    }

    override func viewDidLayoutSubviews() {
        confirm.applyGradient(colors: [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor], radius: 15)
        confirm.setTitleColor(.white, for: .normal)
    }
}

