//
//  MethodTableCell.swift
//  PayMESDK
//
//  Created by HuyOpen on 10/28/20.
//

import UIKit

class Method: UITableViewCell {
    struct Constants {
        static let contentInsets = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0)
        static let avatarSize = CGSize(width: 36.0, height: 36.0)
    }

    var methodView: MethodView = MethodView(type: .WALLET, title: "")

//    let uncheckImage: UIImageView = {
//        var bgImage = UIImageView(image: UIImage(for: Method.self, named: "uncheck"))
//        bgImage.translatesAutoresizingMaskIntoConstraints = false
//        return bgImage
//    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        isAccessibilityElement = true
        self.addSubview(methodView)
        methodView.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        methodView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        methodView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        methodView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        let backgroundView = UIView()
        backgroundView.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.8235294118, blue: 0.8274509804, alpha: 1).withAlphaComponent(0.11)
        selectedBackgroundView = backgroundView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func openWallet(action: PayME.Action, amount: Int? = nil, payMEFunction: PayMEFunction, orderTransaction: OrderTransaction) {
        PayME.currentVC!.dismiss(animated: true)
        payMEFunction.openWallet(
                false, PayME.currentVC!, action, amount, orderTransaction.note,
                orderTransaction.extraData, "", { dictionary in },
                { dictionary in }
        )
    }

    func configure(with presentable: PaymentMethod, payMEFunction: PayMEFunction, orderTransaction: OrderTransaction) {
        if (presentable.type == MethodType.WALLET.rawValue) {
            methodView.title = "Số dư ví"
            methodView.image.image = UIImage(for: PaymentModalController.self, named: "iconWallet")
            if payMEFunction.accessToken == "" {
                methodView.buttonTitle = "Kích hoạt ngay"
                methodView.note = "(*) Vui lòng kích hoạt tài khoản ví trước khi sử dụng"
                methodView.onPress = {
                    self.openWallet(action: PayME.Action.OPEN, payMEFunction: payMEFunction, orderTransaction: orderTransaction)
                }
            } else if payMEFunction.kycState != "APPROVED" {
                methodView.buttonTitle = "Định danh ngay"
                methodView.note = "(*) Vui lòng định danh tài khoản ví trước khi sử dụng"
                methodView.onPress = {
                    self.openWallet(action: PayME.Action.OPEN, payMEFunction: payMEFunction, orderTransaction: orderTransaction)
                }
            } else {
                let balance = presentable.dataWallet?.balance ?? 0
                methodView.content = "(\(formatMoney(input: balance))đ)"
                if balance < orderTransaction.amount {
                    methodView.buttonTitle = "Nạp tiền"
                    methodView.note = "(*) Chọn phương thức khác hoặc nạp thêm để thanh toán"
                    methodView.onPress = {
                        self.openWallet(action: PayME.Action.DEPOSIT, amount: orderTransaction.amount - balance, payMEFunction: payMEFunction, orderTransaction: orderTransaction
                        )
                    }
                } else {
                    methodView.buttonTitle = nil
                    methodView.note = nil
                }
            }
        } else {
            methodView.title = presentable.title
            methodView.content = presentable.label
            methodView.buttonTitle = nil
            methodView.note = nil
            if (presentable.type.isEqual(MethodType.LINKED.rawValue) && presentable.dataLinked != nil) {
                let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/vn-mecorp-payme-wallet.appspot.com/o/image_bank%2Fimage_method%2Fmethod\(presentable.dataLinked!.swiftCode!).png?alt=media&token=28cdb30e-fa9b-430c-8c0e-5369f500612e")
                DispatchQueue.global().async {
                    if let sureURL = url as URL? {
                        let data = try? Data(contentsOf: sureURL)
                        DispatchQueue.main.async {
                            self.methodView.image.image = UIImage(data: data!)
                        }
                    }
                }
            } else if (presentable.type.isEqual(MethodType.BANK_CARD.rawValue)) {
                methodView.image.image = UIImage(for: Method.self, named: "fill1")
            } else {
                methodView.image.image = UIImage(for: Method.self, named: "iconWallet")
            }
        }
        methodView.updateUI()
    }
}

