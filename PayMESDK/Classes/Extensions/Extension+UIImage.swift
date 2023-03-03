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

  func resize(newSize: CGSize) -> UIImage {
    let image = UIGraphicsImageRenderer(size: newSize).image { _ in
      draw(in: CGRect(origin: .zero, size: newSize))
    }

    return image.withRenderingMode(renderingMode)
  }
}

extension UIImageView {
  func load(url: String) {
    let tempUrl = URL(string: url)
    DispatchQueue.global().async { [weak self] in
      guard let unwrappedUrl = tempUrl else { return }
      if url.contains(".svg") {
        DispatchQueue.main.async {
          self?.image = SVGKImage(contentsOf: unwrappedUrl).uiImage
        }
        return
      }
      guard let data = try? Data(contentsOf: unwrappedUrl), let image = UIImage(data: data) else { return }
      DispatchQueue.main.async {
        self?.image = image
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

  private func fillColorForSubLayer(layer: CALayer, color: UIColor, opacity: Float, defaultColor: String = "#6756D6") {
    if layer is CAShapeLayer {
      let shapeLayer = layer as! CAShapeLayer
      if shapeLayer.fillColor != nil {
//                print("minh khoa")
//                print(hexStringFromColor(color: UIColor(cgColor: shapeLayer.fillColor!)))
        if hexStringFromColor(color: UIColor(cgColor: shapeLayer.fillColor!)) == defaultColor {
          shapeLayer.fillColor = color.cgColor
          shapeLayer.opacity = opacity
        }
      }
    }

    if let sublayers = layer.sublayers {
      for subLayer in sublayers {
        fillColorForSubLayer(layer: subLayer, color: color, opacity: opacity, defaultColor: defaultColor)
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

    let hexString = String(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
    return hexString
  }

  func fillColor(color: UIColor, opacity: Float, defaultColor: String = "#6756D6") {
    if let layer = caLayerTree {
      fillColorForSubLayer(layer: layer, color: color, opacity: opacity, defaultColor: defaultColor)
    }
  }

  func fillOutterLayerColor(color: UIColor, opacity: Float) {
    if let layer = caLayerTree {
      fillColorForOutter(layer: layer, color: color, opacity: opacity)
    }
  }
}

extension CIImage {
  func combined(with image: CIImage) -> CIImage? {
    guard let combinedFilter = CIFilter(name: "CISourceOverCompositing") else { return nil }
    let centerTransform = CGAffineTransform(translationX: extent.midX - (image.extent.size.width / 2), y: extent.midY - (image.extent.size.height / 2))
    combinedFilter.setValue(image.transformed(by: centerTransform), forKey: "inputImage")
    combinedFilter.setValue(self, forKey: "inputBackgroundImage")
    return combinedFilter.outputImage!
  }
}
