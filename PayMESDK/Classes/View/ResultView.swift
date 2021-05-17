//
//  ResultView.swift
//  PayMESDK
//
//  Created by Minh Khoa on 5/4/21.
//

import Foundation
import Lottie
import RxSwift


class ResultView: UIView {
    public let resultSubject : PublishSubject<Result> = PublishSubject()
    private let disposeBag = DisposeBag()

    let animationView = AnimationView()
    let screenSize: CGRect = UIScreen.main.bounds

    let containerView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    let topView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(for: ResultView.self, named: "16Px"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let image: UIImageView = {
        var bgImage = UIImageView(image: UIImage(for: ResultView.self, named: "success"))
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(24, 26, 65)
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let roleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(45, 187, 84)
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 36, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let failLabel: UILabel = {
        let failLabel = UILabel()
        failLabel.textColor = UIColor(241, 49, 45)
        failLabel.backgroundColor = .clear
        failLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        failLabel.lineBreakMode = .byWordWrapping
        failLabel.numberOfLines = 0
        failLabel.textAlignment = .center
        failLabel.translatesAutoresizingMaskIntoConstraints = false

        return failLabel
    }()

    let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(8, 148, 31)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        return button
    }()

    let detailView: UIView = {
        let detailView = UIView()
        detailView.translatesAutoresizingMaskIntoConstraints = false
        detailView.layer.cornerRadius = 15
        return detailView
    }()

    let methodView: UIView = {
        let methodView = UIView()
        methodView.translatesAutoresizingMaskIntoConstraints = false
        methodView.layer.cornerRadius = 15
        return methodView
    }()

    let methodLabel: UILabel = {
        let methodLabel = UILabel()
        methodLabel.textColor = UIColor(4, 4, 4)
        methodLabel.backgroundColor = .clear
        methodLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        methodLabel.translatesAutoresizingMaskIntoConstraints = false
        methodLabel.textAlignment = .left
        return methodLabel
    }()

    let cardNumberLabel: UILabel = {
        let cardNumberLabel = UILabel()
        cardNumberLabel.textColor = UIColor(4, 4, 4)
        cardNumberLabel.backgroundColor = .clear
        cardNumberLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        cardNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        cardNumberLabel.textAlignment = .left
        return cardNumberLabel
    }()

    let methodContent: UILabel = {
        let methodContent = UILabel()
        methodContent.textColor = UIColor(4, 4, 4)
        methodContent.backgroundColor = .clear
        methodContent.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        methodContent.translatesAutoresizingMaskIntoConstraints = false
        methodContent.textAlignment = .right
        return methodContent
    }()

    let cardNumberContent: UILabel = {
        let cardNumberContent = UILabel()
        cardNumberContent.textColor = UIColor(4, 4, 4)
        cardNumberContent.backgroundColor = .clear
        cardNumberContent.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        cardNumberContent.translatesAutoresizingMaskIntoConstraints = false
        cardNumberContent.textAlignment = .right
        return cardNumberContent
    }()


    init(type: Int = 0) {
        super.init(frame: CGRect.zero)
        setupUI()
    }

    func setupUI() {
        backgroundColor = UIColor(242, 244, 243)
        topView.backgroundColor = .white
        detailView.backgroundColor = .white
        methodView.backgroundColor = .white


        containerView.bounces = false


        addSubview(containerView)
        addSubview(button)
        addSubview(closeButton)

        containerView.addSubview(topView)
        containerView.addSubview(detailView)
        containerView.addSubview(methodView)

        topView.addSubview(animationView)
        topView.addSubview(nameLabel)
        topView.addSubview(roleLabel)
        topView.addSubview(failLabel)

        methodView.addSubview(methodLabel)
        methodView.addSubview(methodContent)

        // Semi-transparent background
        closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 19).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30).isActive = true

        containerView.heightAnchor.constraint(equalToConstant: 570).isActive = true
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true

        topView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        topView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        topView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.topAnchor.constraint(equalTo: topView.topAnchor, constant: 30).isActive = true
        animationView.heightAnchor.constraint(equalToConstant: 168).isActive = true
        animationView.widthAnchor.constraint(equalToConstant: 168).isActive = true
        animationView.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        animationView.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)

        nameLabel.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 16).isActive = true

        roleLabel.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4.0).isActive = true
        roleLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -30).isActive = true
        roleLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 30).isActive = true
        roleLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -24).isActive = true
        roleLabel.lineBreakMode = .byWordWrapping
        roleLabel.numberOfLines = 0
        roleLabel.textAlignment = .center

        failLabel.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 4.0).isActive = true
        failLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -30).isActive = true
        failLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 30).isActive = true
        failLabel.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true

        //detailView - bottomView
        detailView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 20).isActive = true
        detailView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        detailView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true

        //methodView
        methodView.topAnchor.constraint(equalTo: detailView.bottomAnchor, constant: 10).isActive = true
        methodView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 17).isActive = true
        methodView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -17).isActive = true
        methodView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true

        methodLabel.topAnchor.constraint(equalTo: methodView.topAnchor, constant: 14).isActive = true
        methodLabel.leadingAnchor.constraint(equalTo: methodView.leadingAnchor, constant: 15).isActive = true

        methodContent.topAnchor.constraint(equalTo: methodView.topAnchor, constant: 14).isActive = true
        methodContent.trailingAnchor.constraint(equalTo: methodView.trailingAnchor, constant: -15).isActive = true

        button.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        button.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 20).isActive = true
        button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -17).isActive = true
        button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 17).isActive = true


        let bundle = Bundle(for: ResultView.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let animation = Animation.named("Result_Thanh_Cong", bundle: resourceBundle!)

        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        methodLabel.text = "Phương thức"
        button.setTitle("HOÀN TẤT", for: .normal)
        cardNumberLabel.text = "Số tài khoản"
        methodContent.text = "N/A"
        cardNumberContent.text = "N/A"
    }

    func adaptView(result: Result) {
        nameLabel.text = result.titleLabel
        roleLabel.text = "\(formatMoney(input: result.orderTransaction.amount)) đ"
        if result.type == ResultType.SUCCESS {
            failLabel.isHidden = true
        } else {
            failLabel.text = result.failReasonLabel
        }
//        if (result.orderTransaction.note != "") {
//            memoLabel.text = result.orderTransaction.note
//        }
        let transactionView = TransactionInformationView(id: result.transactionInfo.transaction, time: result.transactionInfo.transactionTime)
        detailView.addSubview(transactionView)
        transactionView.topAnchor.constraint(equalTo: detailView.topAnchor).isActive = true
        transactionView.leadingAnchor.constraint(equalTo: detailView.leadingAnchor).isActive = true
        transactionView.trailingAnchor.constraint(equalTo: detailView.trailingAnchor).isActive = true
        transactionView.bottomAnchor.constraint(equalTo: detailView.bottomAnchor).isActive = true

        methodContent.text = getMethodText(method: result.orderTransaction.paymentMethod!.type)

        if (result.orderTransaction.paymentMethod!.type != "WALLET") {
            methodView.addSubview(cardNumberLabel)
            methodView.addSubview(cardNumberContent)
            cardNumberLabel.topAnchor.constraint(equalTo: methodLabel.bottomAnchor, constant: 10).isActive = true
            cardNumberLabel.leadingAnchor.constraint(equalTo: methodView.leadingAnchor, constant: 15).isActive = true
            cardNumberLabel.bottomAnchor.constraint(equalTo: methodView.bottomAnchor, constant: -15).isActive = true
            cardNumberContent.topAnchor.constraint(equalTo: methodContent.bottomAnchor, constant: 10).isActive = true
            cardNumberContent.trailingAnchor.constraint(equalTo: methodView.trailingAnchor, constant: -15).isActive = true
            cardNumberContent.bottomAnchor.constraint(equalTo: methodView.bottomAnchor, constant: -15).isActive = true
            cardNumberLabel.text = result.orderTransaction.paymentMethod!.type == "BANK_CARD" ? "Số thẻ" : "Số tài khoản"
            cardNumberContent.text = result.transactionInfo.cardNumber
        } else {
            methodContent.bottomAnchor.constraint(equalTo: methodView.bottomAnchor, constant: -15).isActive = true
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
