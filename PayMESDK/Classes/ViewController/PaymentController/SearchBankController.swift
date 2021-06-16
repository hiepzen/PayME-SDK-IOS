//
//  SearchBankController.swift
//  PayMESDK
//
//  Created by Nam Phan Thanh on 16/06/2021.
//

import Foundation

class SearchBankController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var orderTransaction: OrderTransaction
    var listBank: [BankManual]
    let payMEFunction: PayMEFunction

    init(payMEFunction: PayMEFunction, orderTransaction: OrderTransaction, listBank: [BankManual] = []) {
        self.payMEFunction = payMEFunction
        self.orderTransaction = orderTransaction
        self.listBank = listBank
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BankItem.self, forCellWithReuseIdentifier: "cell")

        view.backgroundColor = .white
        view.addSubview(headerStack)
        view.addSubview(collectionView)

        headerStack.addArrangedSubview(backButton)
        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(closeButton)

        headerStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true

        collectionView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 14).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        backButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        closeButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        backButton.addTarget(self, action: #selector(onPressBack), for: .touchUpInside)
    }

    @objc func onPressBack(){
        payMEFunction.paymentViewModel.paymentSubject.onNext(PaymentState(state: .BANK_TRANSFER, orderTransaction: orderTransaction))
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        listBank.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? BankItem else {
            return UICollectionViewCell()
        }
        cell.config(bank: listBank[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        orderTransaction.paymentMethod?.dataBankTransfer = listBank[indexPath.row]
        payMEFunction.paymentViewModel.paymentSubject.onNext(PaymentState(state: .BANK_TRANSFER, orderTransaction: orderTransaction))
    }

    func updateListBank(_ list: [BankManual]) {
        listBank = list
        collectionView.reloadData()
    }

    func updateSizeHeight() -> CGFloat {
        CGFloat(16 + 14) + headerStack.frame.size.height + collectionView.contentSize.height
    }

    let headerStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        return stack
    }()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Chọn ngân hàng"
        label.textAlignment = .center
        return label
    }()
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(for: SearchBankController.self, named: "32Px"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(for: SearchBankController.self, named: "16Px"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let collectionView: UICollectionView = {
        let screenSize: CGRect = UIScreen.main.bounds
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        layout.itemSize = CGSize(width: (screenSize.width - 64) / 3, height: 84)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.isScrollEnabled = true
        collection.showsHorizontalScrollIndicator = false
        collection.showsVerticalScrollIndicator = false
        collection.backgroundColor = .clear
        return collection
    }()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}