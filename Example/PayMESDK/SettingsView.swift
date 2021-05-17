import UIKit

class SettingsView: UIViewController, UIScrollViewDelegate{
    lazy var container: UIScrollView = {
       let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isScrollEnabled = true
        view.isPagingEnabled = false
        view.showsVerticalScrollIndicator = true
        view.showsHorizontalScrollIndicator = false
        view.bounces = false
        return view
    }()
    
    let contentView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.sizeToFit()
        return view
    }()
    
    let appToken: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(16)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "App Token"
        return label
    }()
    let appTokenTextField: UITextView = {
        let textField = UITextView()
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.sizeToFit()
        textField.font = .systemFont(ofSize: 14)
        textField.isEditable = true
        textField.isScrollEnabled = false
        return textField
    }()
    
    let appPrivateKey: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(16)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "App Private Key (RSA)"
        return label
    }()
    let appSKTextField: UITextView = {
        let textField = UITextView()
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.sizeToFit()
        textField.font = .systemFont(ofSize: 14)
        textField.isEditable = true
        textField.isScrollEnabled = false
//        textField.setLeftPaddingPoints(10)
        return textField
    }()
    
    let appPublicKey: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(16)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "PayME Public Key (RSA)"
        return label
    }()
    let appPKTextField: UITextView = {
        let textField = UITextView()
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.sizeToFit()
        textField.font = .systemFont(ofSize: 14)
        textField.isEditable = true
        textField.isScrollEnabled = false
//        textField.setLeftPaddingPoints(10)
        return textField
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 15
        button.setTitle("Save", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let checkBox: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let showLogLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(16)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Show Console log"
        return label
    }()
    
    let restoreButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 15
        button.setTitle("Restore default", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let secretKey: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(16)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Secret key (AES)"
        return label
    }()
    let secretKeyTextField: UITextView = {
        let textField = UITextView()
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.sizeToFit()
        textField.font = .systemFont(ofSize: 14)
        textField.isEditable = true
        textField.isScrollEnabled = false
        return textField
    }()
    
    var isShowLog: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.title = "Settings"
        self.view.backgroundColor = .white
        
        container.delegate = self
        
        self.view.addSubview(container)
        self.view.addSubview(saveButton)
        
        container.addSubview(contentView)
        
        contentView.addSubview(appToken)
        contentView.addSubview(appTokenTextField)
        contentView.addSubview(appPrivateKey)
        contentView.addSubview(appSKTextField)
        contentView.addSubview(appPublicKey)
        contentView.addSubview(appPKTextField)
        contentView.addSubview(checkBox)
        contentView.addSubview(showLogLabel)
        contentView.addSubview(restoreButton)
        contentView.addSubview(secretKey)
        contentView.addSubview(secretKeyTextField)
        
        let isShow = UserDefaults.standard.bool(forKey: "isShowLog")
        setShowLog(showLog: isShow)

        saveButton.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor).isActive = true
        saveButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        saveButton.addTarget(self, action: #selector(onPressSave(_:)), for: .touchUpInside)
        
        container.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        container.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        container.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        container.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -20).isActive = true
        
        contentView.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        contentView.heightAnchor.constraint(equalTo: self.view.heightAnchor, constant: 100).isActive = true
        
        secretKey.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30).isActive = true
        secretKey.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30).isActive = true
        
        secretKeyTextField.topAnchor.constraint(equalTo: secretKey.bottomAnchor, constant: 5).isActive = true
        secretKeyTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30).isActive = true
        secretKeyTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30).isActive = true
        secretKeyTextField.text = EnvironmentSettings.standard.secretKey
        
        appToken.topAnchor.constraint(equalTo: secretKeyTextField.bottomAnchor, constant: 40).isActive = true
        appToken.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30).isActive = true
        
        appTokenTextField.topAnchor.constraint(equalTo: appToken.bottomAnchor, constant: 5).isActive = true
        appTokenTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30).isActive = true
        appTokenTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30).isActive = true
        appTokenTextField.text = EnvironmentSettings.standard.appToken
        
        appPrivateKey.topAnchor.constraint(equalTo: appTokenTextField.bottomAnchor, constant: 20).isActive = true
        appPrivateKey.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30).isActive = true
        
        appSKTextField.topAnchor.constraint(equalTo: appPrivateKey.bottomAnchor, constant: 5).isActive = true
        appSKTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30).isActive = true
        appSKTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30).isActive = true
        appSKTextField.text = EnvironmentSettings.standard.privateKey
        
        appPublicKey.topAnchor.constraint(equalTo: appSKTextField.bottomAnchor, constant: 20).isActive = true
        appPublicKey.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30).isActive = true
        
        appPKTextField.topAnchor.constraint(equalTo: appPublicKey.bottomAnchor, constant: 5).isActive = true
        appPKTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30).isActive = true
        appPKTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30).isActive = true
        appPKTextField.text = EnvironmentSettings.standard.publicKey
        
        checkBox.topAnchor.constraint(equalTo: appPKTextField.bottomAnchor, constant: 20).isActive = true
        checkBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30).isActive = true
        checkBox.heightAnchor.constraint(equalToConstant: 20).isActive = true
        checkBox.widthAnchor.constraint(equalToConstant: 20).isActive = true
        checkBox.addTarget(self, action: #selector(onPressCheckbox(_:)), for: .touchUpInside)

        showLogLabel.topAnchor.constraint(equalTo: appPKTextField.bottomAnchor, constant: 20).isActive = true
        showLogLabel.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 10).isActive = true
        
        restoreButton.topAnchor.constraint(equalTo: checkBox.bottomAnchor, constant: 20).isActive = true
//        restoreButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20).isActive = true
        restoreButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        restoreButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30).isActive = true
        restoreButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30).isActive = true
        restoreButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        restoreButton.addTarget(self, action: #selector(onPressRestore(_:)), for: .touchUpInside)
    }
    
    func setShowLog(showLog: Bool) {
        isShowLog = showLog
        if (showLog) {
            checkBox.setImage(UIImage(named: "checked.svg"), for: .normal)
        } else {
            checkBox.setImage(UIImage(named: "uncheck.svg"), for: .normal)
        }
    }
    
    @IBAction func onPressCheckbox(_ sender: UIButton){
        setShowLog(showLog: !isShowLog)
    }
    
    @IBAction func onPressSave(_ sender: UIButton){
        EnvironmentSettings.standard.changeSettings(newAppToken: self.appTokenTextField.text, newPrivateKey: self.appSKTextField.text, newPublicKey: self.appPKTextField.text, newSecretKey: self.secretKeyTextField.text)
        UserDefaults.standard.set(self.isShowLog, forKey: "isShowLog")
        navigationController?.popToRootViewController(animated: true)
//
//        let alert = UIAlertController(title: "Saved", message: "Đã lưu cài đặt!", preferredStyle: UIAlertController.Style.alert)
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onPressRestore(_ sender: UIButton){
        EnvironmentSettings.standard.restoreDefault()
        self.appTokenTextField.text = EnvironmentSettings.standard.appToken
        self.appSKTextField.text = EnvironmentSettings.standard.privateKey
        self.appPKTextField.text = EnvironmentSettings.standard.publicKey
        self.secretKeyTextField.text = EnvironmentSettings.standard.secretKey
        self.setShowLog(showLog: false)
    }
}

