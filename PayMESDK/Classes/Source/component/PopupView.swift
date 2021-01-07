//
//  ViewController.swift
//  UI kit
//
//  Created by Bui Tri Hieu on 1/5/21.
//

import UIKit

class PopupView: UIViewController {
    let rootView = UIStackView()
    let screenSize:CGRect = UIScreen.main.bounds

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(18)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Chụp ảnh xác thực khuôn mặt"
        return label
    }()
    
    let hint1Label: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(14)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Vui lòng giữ gương mặt ở trong khung tròn"
        return label
    }()
    
    let hint2Label: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(14)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Giữ cho ảnh sắc nét không bị nhoè"
        return label
    }()
    
    
    let continueButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(red: 14/255, green: 182/255, blue: 42/255, alpha: 1)
        button.setTitle("TIẾP TỤC", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1), for: UIControl.State.normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    let imageView = UIImageView(image: UIImage(named: "img"))
    let iconChecked1 = UIImageView(image: UIImage(named: "iconChecked"))
    
    let iconChecked2 = UIImageView(image: UIImage(named: "iconChecked"))
    let hint1 = UIStackView()
    let hint2 = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .red
        self.view.addSubview(rootView)
        self.rootView.addSubview(titleLabel)
        self.rootView.addSubview(continueButton)
        self.rootView.addSubview(imageView)
        self.rootView.addSubview(hint1)
        self.rootView.addSubview(hint2)
        self.hint1.addSubview(hint1Label)
        self.hint1.addSubview(iconChecked1)
        self.hint2.addSubview(hint2Label)
        self.hint2.addSubview(iconChecked2)

        self.rootView.translatesAutoresizingMaskIntoConstraints = false
        self.rootView.axis = .vertical
        self.rootView.alignment = .center
        
        self.hint1.translatesAutoresizingMaskIntoConstraints = false
        self.hint1.axis = .horizontal
        self.hint1.alignment = .leading
        self.hint2.translatesAutoresizingMaskIntoConstraints = false
        self.hint2.axis = .horizontal
        self.hint2.alignment = .leading

        imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 40).isActive = true
        
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10).isActive = true
        
        hint1.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 40).isActive = true
        hint1.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor, constant: 20).isActive = true
        hint2.topAnchor.constraint(equalTo: hint1.bottomAnchor, constant: 30).isActive = true
        hint2.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor, constant: 20).isActive = true
        
        hint1Label.leadingAnchor.constraint(equalTo: iconChecked1.trailingAnchor, constant: 14).isActive = true
        hint2Label.leadingAnchor.constraint(equalTo: iconChecked2.trailingAnchor, constant: 14).isActive = true
        

        continueButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        continueButton.widthAnchor.constraint(equalTo: self.view.layoutMarginsGuide.widthAnchor, multiplier: 1, constant: -18).isActive = true
        continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        continueButton.topAnchor.constraint(equalTo: hint2Label.bottomAnchor, constant: 24).isActive = true
        
    
    }


}

