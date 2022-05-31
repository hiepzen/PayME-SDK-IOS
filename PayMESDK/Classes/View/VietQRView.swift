//
//  VietQRView.swift
//  PayMESDK
//
//  Created by Nam Phan Thanh on 06/05/2022.
//

import Foundation

class VietQRBankItem: UICollectionViewCell {
  override init(frame: CGRect) {
    super.init(frame: .zero)
    setUpUI()
  }

  func setUpUI() {
    addSubview(imageView)
    imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
  }

  func config(swiftCode: String) {
    imageView.load(url: "https://static.payme.vn/image_bank/icon_banks/icon\(swiftCode)@2x.png")
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

class VietQRView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
  var supportedBanks: [String] = []
  var listHeight: NSLayoutConstraint? = nil
  var qrImage: UIImage? = nil
  var onSaveImage: (Bool) -> () = { param in }

  init () {
    super.init(frame: .zero)
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(VietQRBankItem.self, forCellWithReuseIdentifier: "cell")
    setupUI()
  }

  func setupUI() {
    addSubview(vStackContainer)
    vStackContainer.addArrangedSubview(seperator)
    vStackContainer.addArrangedSubview(titleLabel)
    vStackContainer.addArrangedSubview(qrContainer)
    vStackContainer.addArrangedSubview(downloadQrButton)
    vStackContainer.addArrangedSubview(UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 16)))
    vStackContainer.addArrangedSubview(contentLabel)
    vStackContainer.addArrangedSubview(collectionView)

    qrContainer.addSubview(qrImageView)

    vStackContainer.topAnchor.constraint(equalTo: topAnchor).isActive = true
    vStackContainer.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    vStackContainer.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

    qrContainer.heightAnchor.constraint(equalToConstant: 130).isActive = true
    qrImageView.topAnchor.constraint(equalTo: qrContainer.topAnchor, constant: 4).isActive = true
    qrImageView.bottomAnchor.constraint(equalTo: qrContainer.bottomAnchor, constant: -4).isActive = true
    qrImageView.widthAnchor.constraint(equalToConstant: 126).isActive = true
    qrImageView.centerXAnchor.constraint(equalTo: qrContainer.centerXAnchor).isActive = true

    downloadQrButton.addTarget(self, action: #selector(onPressDownloadQr), for: .touchUpInside)

    if (listHeight?.constant == nil) {
      listHeight = collectionView.heightAnchor.constraint(equalToConstant: .greatestFiniteMagnitude)
      listHeight?.isActive = true
    }

    bottomAnchor.constraint(equalTo: vStackContainer.bottomAnchor).isActive = true
  }

  func updateInfo(data: VietQRInformation?, orderTransaction: OrderTransaction) {
    guard let qrCode = data?.qrContent else { return }
    if qrCode != "" {
      let logo = UIImage(for: BankQrView.self, named: "logoVietQr")?.resize(newSize: CGSize(width: 264, height: 264))
      if let qrImage = qrCode.generateQRImage(withLogo: logo) {
        qrImageView.image = qrImage
        self.qrImage = qrImage
      }
    }

    if let supportedBanks = data?.banks {
      self.supportedBanks = supportedBanks
      collectionView.reloadData()
      listHeight?.constant = collectionView.collectionViewLayout.collectionViewContentSize.height
      layoutIfNeeded()
    }
    downloadQrButton.isHidden = (qrImage == nil)
    updateConstraints()
    layoutIfNeeded()
    seperator.createDashedLine( from: CGPoint(x: 0, y: 0), to: CGPoint(x: seperator.frame.size.width, y: 0), color: UIColor(142, 142, 142), strokeLength: 2, gapLength: 2, width: 1)
  }

  @objc func onPressDownloadQr() {
    guard let qrImageToSave = qrImage else { return }
    UIImageWriteToSavedPhotosAlbum(qrImageToSave, self, #selector(onSaved), nil)
  }

  @objc func onSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
      onSaveImage((error == nil))
  }

  var qrView: BankQrView? = nil

  let vStackContainer: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .vertical
    stack.distribution = .equalSpacing
    stack.spacing = 12
    return stack
  }()

  let bankContainer: UIView = {
    let container = UIView()
    container.backgroundColor = UIColor(242, 246, 247)
    container.layer.cornerRadius = 13
    container.translatesAutoresizingMaskIntoConstraints = false
    return container
  }()

  let titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = UIColor(0, 0, 0)
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 14, weight: .semibold)
    label.text = "scanVietQRDescription".localize()
    return label
  }()

  let contentLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = UIColor(0, 0, 0)
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 12, weight: .regular)
    label.text = "openVietQRBankList".localize()
    return label
  }()

  let downloadQrButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setAttributedTitle(NSAttributedString(string: "downloadQr".localize(),
            attributes: [
              .font: UIFont.systemFont(ofSize: 14, weight: .regular),
              .foregroundColor: UIColor(hexString: PayME.configColor[0]),
              .underlineStyle: NSUnderlineStyle.single.rawValue
            ]), for: .normal)
    return button
  }()

  let seperator = UIView()

  let bankLogo: UIImageView = {
    var image = UIImageView()
    image.translatesAutoresizingMaskIntoConstraints = false
    image.contentMode = .scaleAspectFit
    return image
  }()

  let hStack: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.backgroundColor = .clear
    stack.alignment = .center
    stack.axis = .horizontal
    return stack
  }()

  let qrImageView: UIImageView = {
    var image = UIImageView()
    image.translatesAutoresizingMaskIntoConstraints = false
    image.contentMode = .scaleAspectFit
    return image
  }()

  let collectionView: UICollectionView = {
    let screenSize: CGRect = UIScreen.main.bounds
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 0, left: 32, bottom: 16, right: 32)
    layout.itemSize = CGSize(width: (screenSize.width - 96) / 4, height: 63)
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
    let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collection.translatesAutoresizingMaskIntoConstraints = false
    collection.isScrollEnabled = true
    collection.showsHorizontalScrollIndicator = false
    collection.showsVerticalScrollIndicator = true
    collection.backgroundColor = .clear
    return collection
}()

  let qrContainer: UIView = {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    return containerView
  }()

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension VietQRView {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    supportedBanks.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? VietQRBankItem else {
      return UICollectionViewCell()
    }
    cell.config(swiftCode: supportedBanks[indexPath.row])
    return cell
  }
}
