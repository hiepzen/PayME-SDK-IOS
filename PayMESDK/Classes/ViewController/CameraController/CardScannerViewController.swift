//
//  CardScannerViewController.swift
//  PayMESDK
//
//  Created by Nam Phan Thanh on 24/03/2022.
//

import Foundation
import UIKit
import AVFoundation

class CardScannerViewController: PayCardsModulesDelegate {
  var currentVC: UIViewController

  init(currentVC: UIViewController) {
    self.currentVC = currentVC
  }

  func onCloseModule(_ viewController: PayCardsModules) {
    currentVC.dismiss(animated: true)
  }

  func startScanner(onSuccess: @escaping ([String: String]) -> (), onFailed: @escaping ([String: String]) -> ()) {
    var hasPermission = false
    let semaphore = DispatchSemaphore(value: 0)
    AVCaptureDevice.requestAccess(for: .video) { success in
      if !success {
        DispatchQueue.main.async {
          let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
          if authStatus == AVAuthorizationStatus.denied {
            let newNav = UINavigationController(rootViewController: PermissionCamera(modalVC: self.currentVC))
            newNav.setNavigationBarHidden(true, animated: true)
            self.currentVC.present(newNav, animated: true)
          }
        }
        hasPermission = false
      } else {
        hasPermission = true
      }
      semaphore.signal()
    }
    semaphore.wait()
    if !hasPermission {
      return
    }
    if #available(iOS 13.0, *) {
      let visionModule = VisionModules(vc: currentVC, onSuccess: onSuccess, onFailed: onFailed)
      visionModule.startScanner()
    } else {
      let payCardController = PayCardsModules(onSuccess: onSuccess, onFailed: onFailed)
      payCardController.delegate = self
      currentVC.presentModal(payCardController)
    }
  }


}
