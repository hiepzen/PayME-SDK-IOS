//
//  Extension+UIImage.swift
//  PayMESDK
//
//  Created by Minh Khoa on 4/23/21.
//

import Foundation
import SVGKit

extension UIImage {
    convenience init?(for aClass: AnyClass, named: String) {
        let bundle = Bundle(for: aClass)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        self.init(named: named, in: resourceBundle, compatibleWith: nil)
    }
}

extension UIImageView {
    func load(url: String) {
        let tempUrl = URL(string: url)
        DispatchQueue.global().async { [weak self] in
            if let unwrappedUrl = tempUrl as? URL {
                if let data = try? Data(contentsOf: unwrappedUrl) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.image = image
                        }
                    }
                }
            }

        }
    }
}

extension SVGKImage {
    convenience init?(for aClass: AnyClass, named: String) {
        let bundle = Bundle(for: aClass)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        self.init(named: named, in: resourceBundle)
    }

    private func fillColorForSubLayer(layer: CALayer, color: UIColor, opacity: Float) {
        if layer is CAShapeLayer {
            let shapeLayer = layer as! CAShapeLayer
            if shapeLayer.fillColor != nil {
                if hexStringFromColor(color: UIColor(cgColor: shapeLayer.fillColor!)) == "#6756D6" {
                    shapeLayer.fillColor = color.cgColor
                    shapeLayer.opacity = opacity
                }
            }
        }

        if let sublayers = layer.sublayers {
            for subLayer in sublayers {
                fillColorForSubLayer(layer: subLayer, color: color, opacity: opacity)
            }
        }
    }

    private func fillColorForOutter(layer: CALayer, color: UIColor, opacity: Float) {
        if let shapeLayer = layer.sublayers?.first as? CAShapeLayer {
            shapeLayer.fillColor = color.cgColor
            shapeLayer.opacity = opacity
        }
    }

    private func hexStringFromColor(color: UIColor) -> String {
        let components = color.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0

        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        return hexString
    }

    func fillColor(color: UIColor, opacity: Float) {
        if let layer = caLayerTree {
            fillColorForSubLayer(layer: layer, color: color, opacity: opacity)
        }
    }

    func fillOutterLayerColor(color: UIColor, opacity: Float) {
        if let layer = caLayerTree {
            fillColorForOutter(layer: layer, color: color, opacity: opacity)
        }
    }
}
