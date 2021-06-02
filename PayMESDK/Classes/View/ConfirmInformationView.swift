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
    var keyColor: UIColor
    var keyFont: UIFont


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

    
    init(key: String, value: String, color: UIColor?  = UIColor(4, 4, 4), font: UIFont? = .systemFont(ofSize: 15, weight: .medium),
         keyColor: UIColor? = UIColor(100, 112, 129), keyFont: UIFont? = .systemFont(ofSize: 15, weight: .light)){
        self.key = key
        self.value = value
        self.color = color ?? UIColor(4, 4, 4)
        self.font = font ?? .systemFont(ofSize: 15, weight: .medium)
        self.keyFont = keyFont ?? .systemFont(ofSize: 15, weight: .light)
        self.keyColor = keyColor ?? UIColor(100, 112, 129)
        super.init(frame: CGRect.zero)
        setUpUI()
    }
    func setUpUI() {
        backgroundColor = .clear
        axis = .horizontal
        spacing = 8
        translatesAutoresizingMaskIntoConstraints = false
        valueLabel.textColor = color
        valueLabel.font = font
        keyLabel.textColor = keyColor
        keyLabel.font = keyFont
        valueLabel.text = value
        keyLabel.text = key

        addArrangedSubview(keyLabel)
        addArrangedSubview(valueLabel)

        valueLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        keyLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
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
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 15
        backgroundColor = .white
        addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if stackView.isDescendant(of: self) && stackView.subviews.count == 0 {
            for (idx, info) in data.enumerated() {
                guard let key = info["key"] as? String else {
                    continue
                }
                guard let value = info["value"] as? String else {
                    continue
                }
                if (idx > 0) {
                    let seperator = UIView()
                    stackView.addArrangedSubview(seperator)
                    seperator.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
                    seperator.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
                    seperator.createDashedLine( from: CGPoint(x: 0, y: 0), to: CGPoint(x: stackView.frame.size.width, y: 0), color: UIColor(203, 203, 203), strokeLength: 4, gapLength: 4, width: 1)
                }
                let row = InformationRow(key: key, value: value, color: info["color"] as? UIColor, font: info["font"] as? UIFont)
                stackView.addArrangedSubview(row)
            }
        }
    }
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
