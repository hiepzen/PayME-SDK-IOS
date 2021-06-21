//
//  BankTransferResultView.swift
//  PayMESDK
//
//  Created by Nam Phan Thanh on 16/06/2021.
//

import Foundation
import Lottie

class BankTransferResultView: UIView {
    var animationView = AnimationView()
    var onPressBack: () -> () = {}
    let image: UIImageView = {
       let image = UIImageView(image: UIImage(for: BankTransferResultView.self, named: "iconBankTransPending"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()
    init() {
        super.init(frame: .zero)
        setupUI()
    }

    func setupUI() {
        backgroundColor = .white
        addSubview(vStack)

        vStack.addArrangedSubview(label)
        vStack.addArrangedSubview(button)


        vStack.topAnchor.constraint(equalTo: topAnchor, constant: 40).isActive = true
        vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true

        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        button.addTarget(self, action: #selector(onBackTransferBank), for: .touchUpInside)


        bottomAnchor.constraint(equalTo: vStack.bottomAnchor, constant: 33).isActive = true
    }

    @objc func onBackTransferBank() {
        onPressBack()
    }

    func updateUI(type: ResultType) {
        let bundle = Bundle(for: BankTransferResultView.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        switch type {
        case .PENDING:
            image.removeFromSuperview()
            button.isHidden = true
            label.text = "Hệ thống đang kiểm tra trạng thái lệnh chuyển tiền của bạn. Vui lòng chờ trong giây lát..."
            vStack.insertArrangedSubview(animationView, at: 0)
            animationView.heightAnchor.constraint(equalToConstant: 140).isActive = true
            let animation = Animation.named("Kiemtralenhchuyentien", bundle: resourceBundle!)
            animationView.animation = animation
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = .loop
            let color = ColorValueProvider(UIColor(hexString: PayME.configColor[0]).lottieColorValue)
            let keyPathLL = AnimationKeypath(keypath: "Muiten.**.Fill 1.Color")
            let keyPathDO = AnimationKeypath(keypath: "D_xanh.Group 3.**.Fill 1.Color")
            animationView.setValueProvider(color, keypath: keyPathLL)
            animationView.setValueProvider(color, keypath: keyPathDO)
            animationView.play()
            break
        case .FAIL:
            animationView.removeFromSuperview()
            button.isHidden = false
            label.text = "Hệ thống vẫn chưa ghi nhận lệnh chuyển tiền của bạn. Giao dịch sẽ được hoàn tất ngay khi hệ thống ghi nhận thành công."
            vStack.insertArrangedSubview(image, at: 0)
            image.heightAnchor.constraint(equalToConstant: 140).isActive = true
            break
        default:
            break
        }
        updateConstraints()
        layoutIfNeeded()
    }

    let vStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .equalSpacing
        stack.axis = .vertical
        stack.spacing = 26
        return stack
    }()

    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()

    let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.setTitle("Đã hiểu", for: .normal)
        return button
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}