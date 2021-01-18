import UIKit

class FloatingButtonController: UIViewController {

    private(set) var button: UIButton!

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        window.windowLevel = UIWindow.Level(CGFloat.greatestFiniteMagnitude)
        window.isHidden = false
        window.rootViewController = self

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(note:)), name: .UIKeyboardDidShow, object: nil)
    }

    private let window = FloatingButtonWindow()

    let logButton: UIButton = {
        let button = UIButton()
        button.setTitle("Floating", for: .normal)
        button.setTitleColor(UIColor.green, for: .normal)
        button.backgroundColor = UIColor.red
        button.sizeToFit()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        window.button = logButton
        self.view.addSubview(logButton)
        
        logButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50).isActive = true
    }
    
    @objc func keyboardDidShow(note: NSNotification) {
        window.windowLevel = UIWindow.Level(0)
        window.windowLevel = UIWindow.Level(CGFloat.greatestFiniteMagnitude)
    }

}

private class FloatingButtonWindow: UIWindow {

    var button: UIButton?

    init() {
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let button = button else { return false }
        let buttonPoint = convert(point, to: button)
        return button.point(inside: buttonPoint, with: event)
    }
}
