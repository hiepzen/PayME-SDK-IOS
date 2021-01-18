import UIKit

class ModalController: UIViewController {
    let logLabel : UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 30)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Log"
        return label
    }()
   
    let closeButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "close.svg"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let logContainer: UIView = {
       let view = UIView()
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(logLabel)
        self.view.addSubview(closeButton)
        self.view.addSubview(logContainer)
        
        logLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50).isActive = true
        logLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true

        closeButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50).isActive = true
        closeButton.addTarget(self, action: #selector(onPressClose), for: .touchUpInside)
        
        logContainer.topAnchor.constraint(equalTo: logLabel.bottomAnchor, constant: 20).isActive = true
        logContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        logContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        logContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50).isActive = true


    }
    
    @objc func onPressClose(){
        self.dismiss(animated: true, completion: nil)
    }
}

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
