//
//  BankItemView.swift
//  PayMESDK
//
//  Created by Nam Phan Thanh on 16/06/2021.
//

import Foundation

class BankItem: UICollectionViewCell {
//    let bank: BankManual

    override init(frame: CGRect) {
//        self.bank = bank
        super.init(frame: .zero)
        setUpUI()
    }

    func setUpUI() {
        addSubview(imageView)
        layer.cornerRadius = 15
        layer.borderColor = UIColor(203, 203, 203).cgColor
        layer.borderWidth = 0.5

        heightAnchor.constraint(equalToConstant: 104).isActive = true
//        widthAnchor.constraint(equalToConstant: 84).isActive = true

        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    func config(bank: BankManual) {
        imageView.load(url: "https://firebasestorage.googleapis.com/v0/b/vn-mecorp-payme-wallet.appspot.com/o/image_bank%2Ficon_banks%2Ficon\(bank.swiftCode)%402x.png?alt=media&token=0c6cd79a-9a4f-4ea2-b178-94e0b4731ac2")
    }

    let imageView: UIImageView = {
       var image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}