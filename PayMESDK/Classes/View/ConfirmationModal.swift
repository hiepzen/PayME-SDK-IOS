//
//  ConfirmationModal.swift
//  PayMESDK
//
//  Created by Bui Tri Hieu on 5/12/21.
//

import Foundation
class ConfirmationModal: UIView {
//    var title: String?
    var serviceInfoData: [Dictionary<String, Any>]?
    var paymentInfoData: [Dictionary<String, Any>]?
    
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .equalSpacing
        stack.axis = .vertical
        stack.spacing = 8
        stack.backgroundColor = UIColor(239,242, 247)
        return stack
    }()
    
    init(serviceInfo: [Dictionary<String, Any>]?, paymentInfo: [Dictionary<String, Any>]? ){
        self.serviceInfoData = serviceInfo ?? nil
        self.paymentInfoData = paymentInfo ?? nil
        super.init(frame: CGRect.zero)
        setUpUI()
    }
    
    func setUpUI(){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16).isActive = true
        
        if let serviceInfoData = self.serviceInfoData {
            let serviceInfoView = InformationView(data: serviceInfoData)
            stackView.addArrangedSubview(serviceInfoView)
            serviceInfoView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
            serviceInfoView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true

        }
        if let paymentInfoData = self.paymentInfoData {
            let paymentInfoView = InformationView(data: paymentInfoData)
            stackView.addArrangedSubview(paymentInfoView)
            paymentInfoView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
            paymentInfoView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
