//
//  ConfirmationModal.swift
//  PayMESDK
//
//  Created by Bui Tri Hieu on 5/12/21.
//

import Foundation
class ConfirmationModal: UIView {
    var serviceInfoData: [Dictionary<String, Any>]?
    var paymentInfoData: [Dictionary<String, Any>]?
    var onPressConfirm: () -> ()
    
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .equalSpacing
        stack.axis = .vertical
        stack.spacing = 8
        stack.backgroundColor = UIColor(239,242, 247)
        return stack
    }()

    let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(8, 148, 31)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.setTitle("Xác nhận", for: .normal)
        return button
    }()

    func setServiceInfo(serviceInfo: [Dictionary<String, Any>]?) {
        serviceInfoData = serviceInfo
        if let serviceInfoData = serviceInfoData {
            let serviceInfoView = InformationView(data: serviceInfoData)
            stackView.addArrangedSubview(serviceInfoView)
            serviceInfoView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
            serviceInfoView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        }
    }

    func setPaymentInfo(paymentInfo: [Dictionary<String, Any>]?) {
        paymentInfoData = paymentInfo
        if let paymentInfoData = paymentInfoData {
            let paymentInfoView = InformationView(data: paymentInfoData)
            stackView.addArrangedSubview(paymentInfoView)
            paymentInfoView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
            paymentInfoView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        }
    }

    init(serviceInfo: [Dictionary<String, Any>]? = nil, paymentInfo: [Dictionary<String, Any>]? = nil, onPressConfirm: @escaping () -> () = {}){
        serviceInfoData = serviceInfo ?? nil
        paymentInfoData = paymentInfo ?? nil
        self.onPressConfirm = onPressConfirm
        super.init(frame: CGRect.zero)
        setupUI()
    }
    
    func setupUI(){
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        addSubview(button)

        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true

        if let serviceInfoData = serviceInfoData {
            let serviceInfoView = InformationView(data: serviceInfoData)
            stackView.addArrangedSubview(serviceInfoView)
            serviceInfoView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
            serviceInfoView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true

        }

        if let paymentInfoData = paymentInfoData {
            let paymentInfoView = InformationView(data: paymentInfoData)
            stackView.addArrangedSubview(paymentInfoView)
            paymentInfoView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
            paymentInfoView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        }

        button.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        button.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16).isActive = true
        button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        button.addTarget(self, action: #selector(onPressFunction), for: .touchUpInside)

        bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: 16).isActive = true
    }

    @objc func onPressFunction() {
        (onPressConfirm ?? {})()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
