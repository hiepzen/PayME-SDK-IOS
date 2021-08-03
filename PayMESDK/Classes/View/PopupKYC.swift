//
//  PopUpWindow.swift
//  PopUpWindowExample
//
//  Created by John Codeos on 1/18/20.
//  Copyright © 2020 John Codeos. All rights reserved.
//

import Foundation
import UIKit
import Lottie

class PopupKYC: UIViewController, PanModalPresentable {
    var panScrollable: UIScrollView? {
        nil
    }

    var longFormHeight: PanModalHeight {
        .intrinsicHeight
    }

    var shortFormHeight: PanModalHeight {
        .intrinsicHeight
    }

    var anchorModalToLongForm: Bool {
        false
    }

    var shouldRoundTopCorners: Bool {
        true
    }

    var cornerRadius: CGFloat {
        26
    }

    var active: Int!

    private let popupFace: PopupFace = {
        let popUpWindowView = PopupFace()
        popUpWindowView.translatesAutoresizingMaskIntoConstraints = false
        return popUpWindowView
    }()

    private let popupVideo: PopupVideo = {
        let popUpWindowView = PopupVideo()
        popUpWindowView.translatesAutoresizingMaskIntoConstraints = false
        return popUpWindowView
    }()

    private let popupDocument: PopupDocument = {
        let popUpWindowView = PopupDocument()
        popUpWindowView.translatesAutoresizingMaskIntoConstraints = false
        return popUpWindowView
    }()
    var safeAreaInset: UIEdgeInsets?

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            safeAreaInset = UIApplication.shared.keyWindow?.safeAreaInsets
        } else {
            safeAreaInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }

        view.backgroundColor = .white
        if (active! == 1) {
            view.addSubview(popupFace)
            setupViewFace()
        } else if (active! == 2) {
            view.addSubview(popupVideo)
            setupViewVideo()
        } else {
            view.addSubview(popupDocument)
            setupViewDocument()
        }
    }

    func setupViewDocument() {
        popupDocument.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        popupDocument.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        popupDocument.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        popupDocument.continueButton.addTarget(self, action: #selector(goToCamera), for: .touchUpInside)
        let paddingBottom = ((safeAreaInset?.bottom ?? 0 == 0) ? 16 : 0) as CGFloat
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: popupDocument.continueButton.bottomAnchor, constant: paddingBottom).isActive = true
    }

    func setupViewFace() {
        popupFace.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        popupFace.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        popupFace.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        popupFace.continueButton.addTarget(self, action: #selector(goToCamera), for: .touchUpInside)
        let paddingBottom = ((safeAreaInset?.bottom ?? 0 == 0) ? 16 : 0) as CGFloat
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: popupFace.continueButton.bottomAnchor, constant: paddingBottom).isActive = true
    }

    func setupViewVideo() {
        popupVideo.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        popupVideo.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        popupVideo.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        popupVideo.continueButton.addTarget(self, action: #selector(goToCamera), for: .touchUpInside)
        let paddingBottom = ((safeAreaInset?.bottom ?? 0 == 0) ? 16 : 0) as CGFloat
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: popupVideo.continueButton.bottomAnchor, constant: paddingBottom).isActive = true
    }

    @objc func goToCamera() {
        close()
        if (active == 1) {
            let avatarController = AvatarController()
            if PayME.currentVC?.navigationController != nil {
                PayME.currentVC?.navigationController?.pushViewController(avatarController, animated: true)
            } else {
                PayME.currentVC?.present(avatarController, animated: true, completion: nil)
            }
        } else if (active == 2) {
            let videoController = VideoController()
            if PayME.currentVC?.navigationController != nil {
                PayME.currentVC?.navigationController?.pushViewController(videoController, animated: true)
            } else {
                PayME.currentVC?.present(videoController, animated: true, completion: nil)
            }
        } else {
            let kycDocument = KYCCameraController()
            if PayME.currentVC?.navigationController != nil {
                PayME.currentVC?.navigationController?.pushViewController(kycDocument, animated: true)
            } else {
                PayME.currentVC?.present(kycDocument, animated: true, completion: nil)
            }
        }
    }


    func close() {
        dismiss(animated: true, completion: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        let touch = touches.first
        guard let location = touch?.location(in: view) else {
            return
        }
        if (active == 1) {
            if !popupFace.frame.contains(location) {
                close()
            }
        } else if (active == 2) {
            if !popupVideo.frame.contains(location) {
                close()
            }
        } else {
            if !popupDocument.frame.contains(location) {
                close()
            }
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

}

private class PopupDocument: UIView {
    let rootView = UIStackView()
    let screenSize: CGRect = UIScreen.main.bounds
    let animationView = AnimationView()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor(24, 26, 65)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "kycContent7".localize()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        return label

    }()

    let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(hexString: PayME.configColor[0])
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "kycContent8".localize()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        return label

    }()

    let hint1Label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(38, 46, 52)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "1. " + "kycContent9".localize()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()

    let hint2Label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(38, 46, 52)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "2. " + "kycContent10".localize()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()

    let hint3Label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(38, 46, 52)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "3. " + "kycContent11".localize()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()


    let continueButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hexString: PayME.configColor[0])
        button.setTitle("continue".localize(), for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1), for: UIControl.State.normal)
        button.layer.cornerRadius = 20
        return button
    }()

    let hint1 = UIStackView()
    let hint2 = UIStackView()
    let hint3 = UIStackView()
    let contentContainer = UIStackView()

    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = .white
        layer.cornerRadius = 15

        addSubview(rootView)

        rootView.addSubview(titleLabel)
        rootView.addSubview(continueButton)
        rootView.addSubview(animationView)
        rootView.addSubview(contentContainer)
        rootView.addSubview(hint1)
        rootView.addSubview(hint2)
        rootView.addSubview(hint3)

        hint1.addArrangedSubview(hint1Label)
        hint2.addArrangedSubview(hint2Label)
        hint3.addArrangedSubview(hint3Label)
        contentContainer.addArrangedSubview(contentLabel)

        hint1.translatesAutoresizingMaskIntoConstraints = false
        hint1.axis = .horizontal
        hint1.alignment = .leading

        hint2.translatesAutoresizingMaskIntoConstraints = false
        hint2.axis = .horizontal
        hint2.alignment = .leading

        hint3.translatesAutoresizingMaskIntoConstraints = false
        hint3.axis = .horizontal
        hint3.alignment = .leading

        rootView.translatesAutoresizingMaskIntoConstraints = false
        rootView.axis = .vertical
        rootView.alignment = .center

        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.axis = .vertical
        contentContainer.alignment = .center
        contentContainer.backgroundColor = UIColor(hexString: "#6756d6").lighter(by: 50)
        contentContainer.layer.cornerRadius = 14
        contentContainer.isLayoutMarginsRelativeArrangement = true
        contentContainer.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        rootView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        rootView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        rootView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        rootView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        titleLabel.centerXAnchor.constraint(equalTo: rootView.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: rootView.topAnchor, constant: 14).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 20).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -20).isActive = true

        contentContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 11).isActive = true
        contentContainer.centerXAnchor.constraint(equalTo: rootView.centerXAnchor).isActive = true
        contentContainer.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 20).isActive = true
        contentContainer.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -20).isActive = true

        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.widthAnchor.constraint(equalToConstant: 193).isActive = true
        animationView.heightAnchor.constraint(equalToConstant: 195).isActive = true
        animationView.topAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: 10).isActive = true
        animationView.centerXAnchor.constraint(equalTo: rootView.centerXAnchor).isActive = true
        animationView.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)

        hint1.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 40).isActive = true
        hint1.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 20).isActive = true
        hint1.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -20).isActive = true

        hint2.topAnchor.constraint(equalTo: hint1.bottomAnchor, constant: 10).isActive = true
        hint2.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 20).isActive = true
        hint2.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -20).isActive = true

        hint3.topAnchor.constraint(equalTo: hint2.bottomAnchor, constant: 10).isActive = true
        hint3.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 20).isActive = true
        hint3.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -20).isActive = true

        continueButton.topAnchor.constraint(equalTo: hint3.bottomAnchor, constant: 24).isActive = true
        continueButton.centerXAnchor.constraint(equalTo: rootView.centerXAnchor).isActive = true
        continueButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        continueButton.widthAnchor.constraint(equalTo: rootView.widthAnchor, constant: -34).isActive = true
        continueButton.bottomAnchor.constraint(equalTo: rootView.bottomAnchor, constant: -20).isActive = true

        let bundle = Bundle(for: ResultView.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let animation = Animation.named("Chup_CMNN", bundle: resourceBundle!)
        animationView.animation = animation

        let color = ColorValueProvider(UIColor(hexString: PayME.configColor[0]).lottieColorValue)
        let keyPath = AnimationKeypath(keypath: "CMNN Outlines.Group 1.**.Color")
        let keyPath1 = AnimationKeypath(keypath: "CMNN Outlines.Group 2.**.Color")
        let keyPath2 = AnimationKeypath(keypath: "CMNN Outlines.Group 14.**.Color")
        let keyPath3 = AnimationKeypath(keypath: "Chup_xanh.**.Fill 1.Color")
        let keyPath4 = AnimationKeypath(keypath: "Focus_xanh.**.Fill 1.Color")
        let keyPath5 = AnimationKeypath(keypath: "CMNN_xanh.**.Fill 1.Color")
        let keyPath6 = AnimationKeypath(keypath: "CMNN_2_xanh.**.Fill 1.Color")
        let keyPath7 = AnimationKeypath(keypath: "Bo_xanh.**.Stroke 1.Color")
        animationView.setValueProvider(color, keypath: keyPath)
        animationView.setValueProvider(color, keypath: keyPath1)
        animationView.setValueProvider(color, keypath: keyPath2)
        animationView.setValueProvider(color, keypath: keyPath3)
        animationView.setValueProvider(color, keypath: keyPath4)
        animationView.setValueProvider(color, keypath: keyPath5)
        animationView.setValueProvider(color, keypath: keyPath6)
        animationView.setValueProvider(color, keypath: keyPath7)

//        print(animationView.logHierarchyKeypaths())

        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class PopupFace: UIView {

    let rootView = UIStackView()
    let screenSize: CGRect = UIScreen.main.bounds
    let animationView = AnimationView()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor(24, 26, 65)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "kycContent12".localize()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        return label

    }()

    let hint1Label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(38, 46, 52)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "1. " + "kycContent13".localize()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0

        return label
    }()

    let hint2Label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(38, 46, 52)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "2. " + "kycContent14".localize()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()


    let continueButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hexString: PayME.configColor[0])
        button.setTitle("continue".localize(), for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1), for: UIControl.State.normal)
        button.layer.cornerRadius = 20
        return button
    }()

    let hint1 = UIStackView()
    let hint2 = UIStackView()

    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = .white
        layer.cornerRadius = 15

        addSubview(rootView)

        rootView.addSubview(continueButton)
        rootView.addSubview(animationView)
        rootView.addSubview(titleLabel)
        rootView.addSubview(hint1)
        rootView.addSubview(hint2)

        hint1.addArrangedSubview(hint1Label)
        hint2.addArrangedSubview(hint2Label)

        hint1.translatesAutoresizingMaskIntoConstraints = false
        hint1.axis = .horizontal
        hint1.alignment = .leading
        hint2.translatesAutoresizingMaskIntoConstraints = false
        hint2.axis = .horizontal
        hint2.alignment = .leading

        rootView.translatesAutoresizingMaskIntoConstraints = false
        rootView.axis = .vertical
        rootView.alignment = .center

        rootView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        rootView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        rootView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        rootView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        titleLabel.centerXAnchor.constraint(equalTo: rootView.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: rootView.topAnchor, constant: 14).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 20).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -20).isActive = true

        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.widthAnchor.constraint(equalToConstant: 193).isActive = true
        animationView.heightAnchor.constraint(equalToConstant: 193).isActive = true
        animationView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        animationView.centerXAnchor.constraint(equalTo: rootView.centerXAnchor).isActive = true
        animationView.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)

        hint1.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 10).isActive = true
        hint1.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 20).isActive = true
        hint1.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -20).isActive = true

        hint2.topAnchor.constraint(equalTo: hint1.bottomAnchor, constant: 10).isActive = true
        hint2.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 20).isActive = true
        hint2.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -20).isActive = true

        continueButton.topAnchor.constraint(equalTo: hint2.bottomAnchor, constant: 24).isActive = true
        continueButton.centerXAnchor.constraint(equalTo: rootView.centerXAnchor).isActive = true
        continueButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        continueButton.widthAnchor.constraint(equalTo: rootView.widthAnchor, constant: -34).isActive = true
        continueButton.bottomAnchor.constraint(equalTo: rootView.bottomAnchor, constant: -20).isActive = true

        let bundle = Bundle(for: ResultView.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let animation = Animation.named("take_face", bundle: resourceBundle!)
        animationView.animation = animation

        let color = ColorValueProvider(UIColor(hexString: PayME.configColor[0]).lottieColorValue)
        let keyPath = AnimationKeypath(keypath: "Focus.**.Color")
        let keyPath1 = AnimationKeypath(keypath: "Mat.**.Fill 1.Color")
        animationView.setValueProvider(color, keypath: keyPath)
        animationView.setValueProvider(color, keypath: keyPath1)

        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
    }

    func setupAnimation() {
        let bundle = Bundle(for: ResultView.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let animation = Animation.named("take_face", bundle: resourceBundle!)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.translatesAutoresizingMaskIntoConstraints = false
        rootView.addSubview(animationView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private class PopupVideo: UIView {
    let rootView = UIStackView()
    let screenSize: CGRect = UIScreen.main.bounds

    let animationView = AnimationView()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor(24, 26, 65)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "kycContent15".localize()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    let hint1Label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(38, 46, 52)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "1. " + "kycContent16".localize()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()

    let hint2Label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(38, 46, 52)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "2. " + "kycContent17".localize()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()

    let continueButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hexString: PayME.configColor[0])
        button.setTitle("continue".localize(), for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1), for: UIControl.State.normal)
        button.layer.cornerRadius = 20
        return button
    }()

    let hint1 = UIStackView()
    let hint2 = UIStackView()

    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = .white
        layer.cornerRadius = 15


        addSubview(rootView)

        rootView.addSubview(continueButton)
        rootView.addSubview(titleLabel)
        rootView.addSubview(hint1)
        rootView.addSubview(hint2)
        rootView.addSubview(animationView)

        hint1.addArrangedSubview(hint1Label)
        hint2.addArrangedSubview(hint2Label)

        hint1.translatesAutoresizingMaskIntoConstraints = false
        hint1.axis = .horizontal
        hint1.alignment = .leading
        hint2.translatesAutoresizingMaskIntoConstraints = false
        hint2.axis = .horizontal
        hint2.alignment = .leading

        rootView.translatesAutoresizingMaskIntoConstraints = false
        rootView.axis = .vertical
        rootView.alignment = .center

        rootView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        rootView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        rootView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        rootView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        titleLabel.centerXAnchor.constraint(equalTo: rootView.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: rootView.topAnchor, constant: 20).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 20).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -20).isActive = true

        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.widthAnchor.constraint(equalToConstant: 193).isActive = true
        animationView.heightAnchor.constraint(equalToConstant: 193).isActive = true
        animationView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 22).isActive = true
        animationView.centerXAnchor.constraint(equalTo: rootView.centerXAnchor).isActive = true
        animationView.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)

        hint1.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 40).isActive = true
        hint1.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 20).isActive = true
        hint1.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -20).isActive = true

        hint2.topAnchor.constraint(equalTo: hint1.bottomAnchor, constant: 10).isActive = true
        hint2.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 20).isActive = true
        hint2.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -20).isActive = true

        continueButton.topAnchor.constraint(equalTo: hint2.bottomAnchor, constant: 24).isActive = true
        continueButton.centerXAnchor.constraint(equalTo: rootView.centerXAnchor).isActive = true
        continueButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        continueButton.widthAnchor.constraint(equalTo: rootView.widthAnchor, constant: -34).isActive = true
        continueButton.bottomAnchor.constraint(equalTo: rootView.bottomAnchor, constant: -20).isActive = true

        let bundle = Bundle(for: ResultView.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let animation = Animation.named("take_video", bundle: resourceBundle!)
        animationView.animation = animation

        let color = ColorValueProvider(UIColor(hexString: PayME.configColor[0]).lottieColorValue)
        let keyPath = AnimationKeypath(keypath: "Focus.**.Fill 1.Color")
        let keyPath1 = AnimationKeypath(keypath: "CMNN_bg.Group 6.**.Fill 1.Color")
        animationView.setValueProvider(color, keypath: keyPath)
        animationView.setValueProvider(color, keypath: keyPath1)

        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
