//
//  LoadingKYC.swift
//  PayMESDK
//
//  Created by Minh Khoa on 15/07/2021.
//

import Foundation
import UIKit
import Lottie

class LoadingKYC : UIViewController {
    let animationView = AnimationView()

    override func viewDidLoad() {
        view.backgroundColor = UIColor(hexString: PayME.configColor[1])
        
        let bundle = Bundle(for: LoadingKYC.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let animation = Animation.named("Proccessing_Upload", bundle: resourceBundle!)
        animationView.animation = animation

        view.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
        animationView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true

        let color = ColorValueProvider(UIColor(hexString: PayME.configColor[0]).lottieColorValue)
        let keyPath = AnimationKeypath(keypath: "Proccessing_Upload.Pre-comp 1.Bg.**.Color")
        let keyPath1 = AnimationKeypath(keypath: "Proccessing_Upload.Pre-comp 1.Shadow.**.Color")
        let keyPath2 = AnimationKeypath(keypath: "Proccessing_Upload.Pre-comp 1.Muiten.**.Color")
        animationView.setValueProvider(color, keypath: keyPath)
        animationView.setValueProvider(color, keypath: keyPath1)
        animationView.setValueProvider(color, keypath: keyPath2)

        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()

        super.viewDidLoad()
    }
}
