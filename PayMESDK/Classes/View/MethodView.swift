//
//  MethodView.swift
//  PayMESDK
//
//  Created by Nam Phan Thanh on 14/05/2021.
//
import Foundation
import SVGKit

class MethodView: UIView {
  var content: String?
  var title: String = ""
  var buttonTitle: String?
  var note: String?
  var methodDescription: String?
  var onPress: (() -> ())?
  var isSelectable = true

  let vStack: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .vertical
    stack.spacing = 8
    stack.distribution = .equalSpacing
    return stack
  }()

  let containerInfo: UIView = {
    let container = UIView()
    container.backgroundColor = .clear
    container.translatesAutoresizingMaskIntoConstraints = false
    return container
  }()

  let image: UIImageView = {
    var bgImage = UIImageView()
    bgImage.translatesAutoresizingMaskIntoConstraints = false
    bgImage.contentMode = .scaleAspectFit
    return bgImage
  }()

  let titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = UIColor(11, 11, 11)
    label.font = .systemFont(ofSize: 15, weight: .bold)
    label.backgroundColor = .clear
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .left
    return label
  }()

  let contentLabel: UILabel = {
    let label = UILabel()
    label.textColor = UIColor(124, 124, 124)
    label.backgroundColor = .clear
    label.font = .systemFont(ofSize: 14, weight: .semibold)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .left
    return label
  }()

  let button: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.layer.cornerRadius = 12
    button.layer.borderColor = UIColor(hexString: PayME.configColor[0]).cgColor
    button.setTitleColor(UIColor(hexString: PayME.configColor[0]), for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    return button
  }()

  let seperator: UIView = {
    let sepe = UIView()
    sepe.backgroundColor = UIColor(252, 252, 252)
    sepe.translatesAutoresizingMaskIntoConstraints = false
    return sepe
  }()

  let noteLabel: UILabel = {
    let label = UILabel()
    label.textColor = UIColor(255, 0, 0)
    label.backgroundColor = .clear
    label.font = .systemFont(ofSize: 12, weight: .regular)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .left
    return label
  }()

  let imageNext: UIImageView = {
    var bgImage = UIImageView()
    bgImage.translatesAutoresizingMaskIntoConstraints = false
    return bgImage
  }()

  let infoVStack: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .vertical
    return stack
  }()

//    let methodDescriptionLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = UIColor(100, 112, 129)
//        label.backgroundColor = .clear
//        label.font = .systemFont(ofSize: 11, weight: .regular)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textAlignment = .left
//        return label
//    }()

  let infoHStack: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.spacing = 6
    return stack
  }()

  init(title: String = "", content: String? = nil, buttonTitle: String? = nil, note: String? = nil, methodDescription: String? = nil,
       isSelectable: Bool = true)
  {
    self.title = title
    self.content = content ?? nil
    self.buttonTitle = buttonTitle ?? nil
    self.note = note ?? nil
    self.methodDescription = methodDescription ?? nil
    self.isSelectable = isSelectable
    super.init(frame: CGRect.zero)
    setUpUI()
    if isSelectable == true {
      imageNext.isHidden = false
      updateSelectState(isSelected: false)
    } else {
      imageNext.isHidden = true
    }
  }

  func setUpUI() {
    translatesAutoresizingMaskIntoConstraints = false

    addSubview(vStack)

    vStack.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
    vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
    vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
    vStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true

    vStack.addArrangedSubview(containerInfo)
    containerInfo.heightAnchor.constraint(equalToConstant: 34).isActive = true

    containerInfo.addSubview(image)
    if isSelectable {
      image.heightAnchor.constraint(equalToConstant: 34).isActive = true
      image.widthAnchor.constraint(equalToConstant: 34).isActive = true
    } else {
      image.heightAnchor.constraint(equalToConstant: 22).isActive = true
      image.widthAnchor.constraint(equalToConstant: 22).isActive = true
    }
    image.centerYAnchor.constraint(equalTo: containerInfo.centerYAnchor).isActive = true
    image.leadingAnchor.constraint(equalTo: containerInfo.leadingAnchor).isActive = true

    containerInfo.addSubview(infoVStack)
    infoVStack.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 12).isActive = true
    infoVStack.centerYAnchor.constraint(equalTo: containerInfo.centerYAnchor).isActive = true

    infoVStack.addArrangedSubview(infoHStack)
    infoHStack.addArrangedSubview(titleLabel)
    infoHStack.addArrangedSubview(contentLabel)

    containerInfo.addSubview(button)
    button.trailingAnchor.constraint(equalTo: containerInfo.trailingAnchor).isActive = true
    button.heightAnchor.constraint(equalTo: containerInfo.heightAnchor).isActive = true
    button.addTarget(self, action: #selector(onPressFunction), for: .touchUpInside)

    containerInfo.addSubview(imageNext)
    imageNext.heightAnchor.constraint(equalToConstant: 20).isActive = true
    imageNext.widthAnchor.constraint(equalToConstant: 20).isActive = true
    imageNext.trailingAnchor.constraint(equalTo: containerInfo.trailingAnchor).isActive = true
    imageNext.centerYAnchor.constraint(equalTo: containerInfo.centerYAnchor).isActive = true

    vStack.addArrangedSubview(seperator)
    seperator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    vStack.addArrangedSubview(noteLabel)
    updateUI()
  }

  func updateUI(isOpenWallet: Bool = false) {
    titleLabel.text = title
    contentLabel.text = content ?? ""
    noteLabel.text = note ?? ""
//        methodDescriptionLabel.text = methodDescription ?? ""
    if isOpenWallet == true {
      button.layer.borderWidth = 1
    } else {
      button.layer.borderWidth = 0
    }

    if buttonTitle != nil {
      button.isHidden = false
      imageNext.isHidden = true
      button.setTitle(buttonTitle, for: .normal)
    } else {
      button.isHidden = true
      imageNext.isHidden = false
    }

    if note != nil {
      seperator.isHidden = false
      noteLabel.isHidden = false
    } else {
      seperator.isHidden = true
      noteLabel.isHidden = true
    }

//        if (methodDescription != nil && methodDescription != "") {
//            methodDescriptionLabel.isHidden = false
//        } else {
//            methodDescriptionLabel.isHidden = true
//        }
  }

  func updateSelectState(isSelected: Bool = false) {
    if isSelected == true {
      let imageSVG = SVGKImage(for: MethodView.self, named: "iconCheck")
      imageSVG?.fillColor(color: UIColor(hexString: PayME.configColor[0]), opacity: 1)
      imageNext.image = imageSVG?.uiImage
    } else {
      let imageSVG = SVGKImage(for: MethodView.self, named: "iconUncheck")
      imageNext.image = imageSVG?.uiImage
    }
  }

  @objc func onPressFunction() {
    (onPress ?? {})()
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
