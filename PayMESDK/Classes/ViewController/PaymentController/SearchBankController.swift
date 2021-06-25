//
//  SearchBankController.swift
//  PayMESDK
//
//  Created by Nam Phan Thanh on 16/06/2021.
//

import Foundation
import SVGKit

class SearchBankController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var orderTransaction: OrderTransaction
    var listBank: [BankManual]
    private var collectionListBank: [BankManual]
    let payMEFunction: PayMEFunction

    init(payMEFunction: PayMEFunction, orderTransaction: OrderTransaction, listBank: [BankManual] = []) {
        self.payMEFunction = payMEFunction
        self.orderTransaction = orderTransaction
        self.listBank = listBank
        collectionListBank = listBank
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BankItem.self, forCellWithReuseIdentifier: "cell")

        let imageSVG = SVGKImage(for: SearchBankController.self, named: "iconSearch")
        imageSVG?.fillColor(color: UIColor(hexString: PayME.configColor[0]), opacity: 1)
        let svgImageView = UIImageView(frame: CGRect(x: 14, y: 11, width: 18, height: 18))
        svgImageView.contentMode = .scaleAspectFit
        svgImageView.image = imageSVG?.uiImage
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        paddingView.addSubview(svgImageView)
        svgImageView.trailingAnchor.constraint(equalTo: paddingView.trailingAnchor, constant: -8).isActive = true
        searchBar.leftViewMode = .always
        searchBar.leftView = paddingView

        view.backgroundColor = .white
        view.addSubview(headerStack)
        view.addSubview(collectionView)
        view.addSubview(searchBar)

        headerStack.addArrangedSubview(backButton)
        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(closeButton)

        headerStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true

        searchBar.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 20).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 40).isActive = true

        collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 14).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        backButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        closeButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        backButton.addTarget(self, action: #selector(onPressBack), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(onPressClose), for: .touchUpInside)
        searchBar.addTarget(self, action: #selector(onChangeSearch), for: .editingChanged)
    }

    @objc func onPressBack(){
        searchBar.text = ""
        payMEFunction.paymentViewModel.paymentSubject.onNext(PaymentState(state: .BANK_TRANSFER, orderTransaction: orderTransaction))
    }

    @objc func onPressClose(){
        PayME.currentVC!.dismiss(animated: true)
    }

    @objc func onChangeSearch() {
        guard let searchContent = searchBar.text else { return }
        if (searchContent == "") {
            collectionListBank = listBank
        } else {
            collectionListBank = listBank.filter{ $0.bankName.localizedCaseInsensitiveContains(searchContent) }
        }
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionListBank.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? BankItem else {
            return UICollectionViewCell()
        }
        cell.config(bank: collectionListBank[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        orderTransaction.paymentMethod?.dataBankTransfer = collectionListBank[indexPath.row]
        searchBar.text = ""
        payMEFunction.paymentViewModel.paymentSubject.onNext(PaymentState(state: .BANK_TRANSFER, orderTransaction: orderTransaction))
    }

    func updateListBank(_ list: [BankManual]) {
        listBank = list
        collectionListBank = list
        collectionView.reloadData()
    }

    func updateSizeHeight() -> CGFloat {
        CGFloat(50) + headerStack.frame.size.height + searchBar.frame.size.height + collectionView.contentSize.height
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
    let searchBar: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "search".localize()
        textField.backgroundColor = UIColor(239, 242, 247)
        textField.layer.cornerRadius = 15
        return textField
    }()


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}