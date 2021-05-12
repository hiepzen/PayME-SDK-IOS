//
//  ConfirmInformationView.swift
//  PayMESDK
//
//  Created by Bui Tri Hieu on 5/11/21.
//

import Foundation
class InformationRow: UIStackView {
    var key: String
    var value: String
    var color: UIColor
    var font: UIFont
    let keyLabel: UILabel = {
        let keyLabel = UILabel()
        keyLabel.textColor = UIColor(100, 112, 129)
        keyLabel.backgroundColor = .clear
        keyLabel.font = UIFont.systemFont(ofSize: 15, weight: .light)
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        keyLabel.textAlignment = .left
        return keyLabel
    }()
    
    let valueLabel: UILabel = {
        let valueLabel = UILabel()
        valueLabel.backgroundColor = .clear
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.textAlignment = .right
        valueLabel.lineBreakMode = .byWordWrapping
        valueLabel.numberOfLines = 0
        return valueLabel
    }()

    
    init(key: String, value: String, color: UIColor?  = UIColor(4, 4, 4), font: UIFont? = .systemFont(ofSize: 15, weight: .medium)){
        self.key = key
        self.value = value
        self.color = color ?? UIColor(4, 4, 4)
        self.font = font ?? UIFont.systemFont(ofSize: 15, weight: .medium)
        super.init(frame: CGRect.zero)
        setUpUI()
    }
    func setUpUI() {
        self.backgroundColor = .clear
        self.axis = .horizontal
        self.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.textColor = self.color
        valueLabel.font = self.font
        valueLabel.text = self.value
        keyLabel.text = self.key
        
        self.addArrangedSubview(keyLabel)
        self.addArrangedSubview(valueLabel)
        
        keyLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        keyLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        
        valueLabel.leadingAnchor.constraint(equalTo: keyLabel.trailingAnchor, constant: 8).isActive = true
        valueLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        valueLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class InformationView: UIView{
    var data: [Dictionary<String, Any>] = []
    
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .white
        stack.distribution = .equalSpacing
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    init(data: [Dictionary<String, Any>]) {
        self.data = data
        super.init(frame: CGRect.zero)
        setUpUI()
    }
    
    func setUpUI() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 15
        self.backgroundColor = .white
        self.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if stackView.isDescendant(of: self) && stackView.subviews.count == 0 {
            for (idx, info) in self.data.enumerated() {
                guard let key = info["key"] as? String else {
                    continue
                }
                guard let value = info["value"] as? String else {
                    continue
                }
                let row = InformationRow(key: key, value: value, color: info["color"] as? UIColor, font: info["font"] as? UIFont)
                stackView.addArrangedSubview(row)
                if (idx < self.data.endIndex - 1) {
                    let seperator = UIView()
                    stackView.addArrangedSubview(seperator)
                    seperator.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
                    seperator.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
                    print("HKJDHKJDHJK \(seperator.frame.size.width)")
                    seperator.createDashedLine( from: CGPoint(x: 0, y: 0), to: CGPoint(x: stackView.frame.size.width, y: 0), color: UIColor(203, 203, 203), strokeLength: 4, gapLength: 4, width: 1)
                }
            }
        }
    }
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
