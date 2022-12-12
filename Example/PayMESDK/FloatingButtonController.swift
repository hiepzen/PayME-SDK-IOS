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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(note:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    private let window = FloatingButtonWindow()
    
    
    let logButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.black
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(logButton)
        
        logButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        logButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        logButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40).isActive = true
        logButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        logButton.addTarget(self, action: #selector(onPressLog), for: .touchUpInside)
        
        
    }
    
    @objc func keyboardDidShow(note: NSNotification) {
        window.windowLevel = UIWindow.Level(0)
        window.windowLevel = UIWindow.Level(CGFloat.greatestFiniteMagnitude)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        window.button = logButton
        window.disableMainView = false
    }
    
    @objc func onPressLog(){
        window.disableMainView = true
        let vc = ModalController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func hideWindow() {
        window.windowLevel = UIWindow.Level(-1)
    }
    func showWindow() {
        window.windowLevel = UIWindow.Level(CGFloat.greatestFiniteMagnitude)
    }
}

private class FloatingButtonWindow: UIWindow {
    
    var button: UIButton?
    var disableMainView: Bool = false
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    fileprivate override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if (disableMainView == true) {
            return true
        } else {
            guard let button = button else { return false }
            let buttonPoint = convert(point, to: button)
            return button.point(inside: buttonPoint, with: event)
        }
    }
    
}
