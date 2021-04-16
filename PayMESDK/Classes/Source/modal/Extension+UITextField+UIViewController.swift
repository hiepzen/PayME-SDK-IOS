//
//  Extension+UITextField+UIViewController.swift
//  PayMESDK
//
//  Created by HuyOpen on 12/8/20.
//
import Lottie

var vSpinner : UIView?
let animationView = AnimationView()

extension UITextField {
    func showSpinner(onView : UIView) {
        let currentWindow: UIWindow? = UIApplication.shared.keyWindow
        let spinnerView = UIView.init(frame: currentWindow!.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        DispatchQueue.main.async {
            spinnerView.layer.zPosition = 1000
            spinnerView.addSubview(ai)
            currentWindow!.addSubview(spinnerView)
        }
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
    
    func showSpinnerAnimation(onView : UIView) {
        let currentWindow: UIWindow? = UIApplication.shared.keyWindow
        let spinnerView = UIView.init(frame: currentWindow!.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        
        let bundle = Bundle(for: Failed.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let animation = Animation.named("Loading_final", bundle: resourceBundle!)
        
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        
        spinnerView.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.centerXAnchor.constraint(equalTo: spinnerView.centerXAnchor).isActive = true
        animationView.centerYAnchor.constraint(equalTo: spinnerView.centerYAnchor).isActive = true
        animationView.heightAnchor.constraint(equalToConstant: spinnerView.bounds.width/4).isActive = true
        animationView.play()

        DispatchQueue.main.async {
            spinnerView.layer.zPosition = 1000
            currentWindow!.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinnerAnimation() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}

extension UIViewController {
    func showSpinner(onView : UIView) {
        let currentWindow: UIWindow? = UIApplication.shared.keyWindow
        let spinnerView = UIView.init(frame: currentWindow!.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        DispatchQueue.main.async {
            spinnerView.layer.zPosition = 1000
            spinnerView.addSubview(ai)
            currentWindow!.addSubview(spinnerView)
        }
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        vSpinner?.removeFromSuperview()
        vSpinner = nil
    }
    
    func showSpinnerAnimation(onView : UIView) {
        let currentWindow: UIWindow? = UIApplication.shared.keyWindow
        let spinnerView = UIView.init(frame: currentWindow!.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        
        let bundle = Bundle(for: Failed.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let animation = Animation.named("Loading_final", bundle: resourceBundle!)
        
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        
        spinnerView.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.centerXAnchor.constraint(equalTo: spinnerView.centerXAnchor).isActive = true
        animationView.centerYAnchor.constraint(equalTo: spinnerView.centerYAnchor).isActive = true
        animationView.heightAnchor.constraint(equalToConstant: spinnerView.bounds.width/4).isActive = true
        animationView.play()

        DispatchQueue.main.async {
            let currentWindow: UIWindow? = UIApplication.shared.keyWindow
            spinnerView.layer.zPosition = 1000
            currentWindow!.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinnerAnimation() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}
