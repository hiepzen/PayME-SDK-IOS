import UIKit

class SettingsView: UIViewController{
    let appToken: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(16)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "App Token"
        return label
    }()
    let appTokenTextField: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setLeftPaddingPoints(10)
        return textField
    }()
    
    let appSecretKey: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(16)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "App Secret Key"
        return label
    }()
    let appSKTextField: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setLeftPaddingPoints(10)
        return textField
    }()
    
    let appPublicKey: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(16)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "App Secret Key"
        return label
    }()
    let appPKTextField: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setLeftPaddingPoints(10)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        self.view.backgroundColor = .white
       
        
        self.view.addSubview(appToken)
        self.view.addSubview(appTokenTextField)
        self.view.addSubview(appSecretKey)
        self.view.addSubview(appSKTextField)
        self.view.addSubview(appPublicKey)
        self.view.addSubview(appPKTextField)
        self.view.addSubview(saveButton)
        
        appToken.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 30).isActive = true
        appToken.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        
        appTokenTextField.topAnchor.constraint(equalTo: appToken.bottomAnchor, constant: 5).isActive = true
        appTokenTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        appTokenTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
        appTokenTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        appTokenTextField.text = UserDefaults.standard.string(forKey: "appToken") ?? ""
        
        appSecretKey.topAnchor.constraint(equalTo: appTokenTextField.bottomAnchor, constant: 20).isActive = true
        appSecretKey.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        
        appSKTextField.topAnchor.constraint(equalTo: appSecretKey.bottomAnchor, constant: 5).isActive = true
        appSKTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        appSKTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
        appSKTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        appSKTextField.text = UserDefaults.standard.string(forKey: "secretKey") ?? ""
        
        appPublicKey.topAnchor.constraint(equalTo: appSKTextField.bottomAnchor, constant: 20).isActive = true
        appPublicKey.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        
        appPKTextField.topAnchor.constraint(equalTo: appPublicKey.bottomAnchor, constant: 5).isActive = true
        appPKTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        appPKTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
        appPKTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        appPKTextField.text = UserDefaults.standard.string(forKey: "publicKey") ?? ""
        
        
        saveButton.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor, constant: -30).isActive = true
        saveButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        saveButton.addTarget(self, action: #selector(onPressSave(_:)), for: .touchUpInside)

    }
    
    @IBAction func onPressSave(_ sender: UIButton){
        UserDefaults.standard.set(self.appTokenTextField.text, forKey: "appToken")
        UserDefaults.standard.set(self.appSKTextField.text, forKey: "secretKey")
        UserDefaults.standard.set(self.appPKTextField.text, forKey: "publicKey")
        let alert = UIAlertController(title: "Saved", message: "Đã lưu cài đặt!", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

