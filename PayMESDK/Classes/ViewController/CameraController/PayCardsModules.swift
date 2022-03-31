//
//  PayCardsModules.swift
//  PayMESDK
//
//  Created by Nam Phan Thanh on 24/03/2022.
//

import Foundation
import UIKit
import PayCardsRecognizer

class PayCardsModules : UIViewController, PayCardsRecognizerPlatformDelegate {
  var delegate: PayCardsModulesDelegate?

  func payCardsRecognizer(_ payCardsRecognizer: PayCardsRecognizer, didRecognize result: PayCardsRecognizerResult) {
    if !flag {
      flag = true
      print("DEBUG_CARDD")
      print([
        "cardNumber": result.recognizedNumber ?? "",
        "cardHolder": result.recognizedHolderName ?? "",
        "cardExpitedDate": "\(result.recognizedExpireDateMonth ?? "")/\(result.recognizedExpireDateYear ?? "")"
      ])
      delegate?.onCloseModule(self)
      dismiss(animated: true) {
        self.onSuccess([
          "cardNumber": result.recognizedNumber ?? "",
          "cardHolder": result.recognizedHolderName ?? "",
          "cardExpitedDate": "\(result.recognizedExpireDateMonth ?? "")/\(result.recognizedExpireDateYear ?? "")"
        ])
      }
    }
  }

  var recognizer: PayCardsRecognizer!
  var onSuccess: ([String : String]) -> ()
  var onFailed: ([String : String]) -> ()
  var flag = false

  init(onSuccess: @escaping ([String : String]) -> (),
       onFailed: @escaping ([String : String]) -> ()) {
    self.onSuccess = onSuccess
    self.onFailed = onFailed
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black
    view.addSubview(backButton)
    view.addSubview(cameraView)
    recognizer = PayCardsRecognizer(delegate: self, resultMode: .async, container: cameraView, frameColor: .green)
    if #available(iOS 11, *) {
      let guide = view.safeAreaLayoutGuide
      backButton.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0).isActive = true
    } else {
      backButton.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 8).isActive = true
    }
    backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
    backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
    backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
    cameraView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 8).isActive = true
    cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    recognizer.startCamera(with: .portrait)
  }

  @objc func back() {
    recognizer.stopCamera()
    delegate?.onCloseModule(self)
//    vc.dismiss(animated: true)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    recognizer.stopCamera()
    removeFromParent()
  }

  let backButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(for: PayCardsModules.self, named: "icSetArrowBack32Px"), for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  let cameraView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
}

protocol PayCardsModulesDelegate {
  func onCloseModule(_ viewController: PayCardsModules)
}

extension PayCardsModulesDelegate where Self: UIViewController {
  func onCloseModule(_ viewController: PayCardsModules) {
    viewController.dismiss(animated: true)
  }
}