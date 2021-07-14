//
//  ExtensionController.swift
//  PayMESDK
//
//  Created by HuyOpen on 12/8/20.
//
import Lottie
class ExtensionController: UIViewController {

}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
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

        let bundle = Bundle(for: ResultView.self)
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
    func showSpinner(onView : UIView, alpha: CGFloat = 0.5, color: UIColor? = nil) {
        if vSpinner != nil {
            removeSpinner()
        }
        let currentWindow: UIWindow? = UIApplication.shared.keyWindow
        let spinnerView = UIView.init(frame: currentWindow!.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: alpha)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        if color != nil {
            ai.color = color
        }
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

        let bundle = Bundle(for: ResultView.self)
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

extension String {
    var fixedBase64Format: Self {
        let offset = count % 4
        guard offset != 0 else { return self }
        return padding(toLength: count + 4 - offset, withPad: "=", startingAt: 0)
    }
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: fixedBase64Format) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

    func stringByReplacingFirstOccurrenceOfString(
            target: String, withString replaceString: String) -> String
    {
        if let range = self.range(of: target) {
            return self.replacingCharacters(in: range, with: replaceString)
        }
        return self
    }
    func replaceAll(target: String, withString: String) -> String
    {
        let regex = try! NSRegularExpression(pattern: target, options: NSRegularExpression.Options.caseInsensitive)
        let range = NSMakeRange(0, self.count)
        let modString = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: withString)
        return modString
    }

}



extension UIView {

    func createDashedLine(from point1: CGPoint, to point2: CGPoint, color: UIColor, strokeLength: NSNumber, gapLength: NSNumber, width: CGFloat) {
        let shapeLayer = CAShapeLayer()

        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = width
        shapeLayer.lineDashPattern = [strokeLength, gapLength]

        let path = CGMutablePath()
        path.addLines(between: [point1, point2])
        shapeLayer.path = path
        layer.addSublayer(shapeLayer)
    }

    @discardableResult
    func addLineDashedStroke(pattern: [NSNumber]?, radius: CGFloat, color: CGColor, width: CGFloat = 0.5) -> CALayer {
        let borderLayer = CAShapeLayer()

        borderLayer.strokeColor = color
        borderLayer.lineDashPattern = pattern
        borderLayer.lineWidth = width
        borderLayer.frame = bounds
        borderLayer.fillColor = nil
        borderLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
        layer.addSublayer(borderLayer)
        return borderLayer
    }

    func applyGradient(colors: [CGColor], radius : CGFloat)
    {
        removeGradient()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = radius
        self.layer.insertSublayer(gradientLayer, at: 0)
    }

    func removeGradient() {
        for subLayer in (layer.sublayers ?? []) {
            if subLayer is CAGradientLayer {
                subLayer.removeFromSuperlayer()
            }
        }
    }
    func removeDashedLines() {
        for subLayer in (layer.sublayers ?? []) {
            if subLayer is CAShapeLayer {
                subLayer.removeFromSuperlayer()
            }
        }
    }

    func startLoading() {
        let activityIndicator: UIActivityIndicatorView = {
            let indicator = UIActivityIndicatorView(style: .white)
            indicator.color = UIColor(hexString: PayME.configColor[0])
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.backgroundColor = .white
            return indicator
        }()
        addSubview(activityIndicator)
        activityIndicator.topAnchor.constraint(equalTo: topAnchor).isActive = true
        activityIndicator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        activityIndicator.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        activityIndicator.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bringSubviewToFront(activityIndicator)
        updateConstraints()
        layoutIfNeeded()
        activityIndicator.startAnimating()
    }

    func endLoading() {
        for subview in subviews {
            if subview is UIActivityIndicatorView {
                (subview as! UIActivityIndicatorView).stopAnimating()
                subview.removeFromSuperview()
            }
        }
    }
}
extension UIImage {
    // Crops an input image (self) to a specified rect
    func cropToRect(rect: CGRect!) -> UIImage? {
        // Correct rect size based on the device screen scale
        let scaledRect = CGRect(x: rect.origin.x * self.scale, y: rect.origin.y * self.scale, width: rect.size.width * self.scale, height: rect.size.height * self.scale);
        // New CGImage reference based on the input image (self) and the specified rect
        let imageRef = self.cgImage!.cropping(to: scaledRect);
        // Gets an UIImage from the CGImage
        let result = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        // Returns the final image, or NULL on error
        return result;
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(rgb: Int) {
        self.init(
                red: (rgb >> 16) & 0xFF,
                green: (rgb >> 8) & 0xFF,
                blue: rgb & 0xFF
        )
    }
    convenience init(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1)
    }
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }

}

extension URL {
    public var queryParameters: [String: String]? {
        guard
                let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
                let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}
extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}
extension UINavigationController {
    public func pushViewController(
            _ viewController: UIViewController,
            animated: Bool,
            completion: @escaping () -> Void)
    {
        pushViewController(viewController, animated: animated)

        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion() }
            return
        }

        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }

    func popViewController(
            animated: Bool,
            completion: @escaping () -> Void)
    {
        popViewController(animated: animated)

        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion() }
            return
        }

        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
}
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
