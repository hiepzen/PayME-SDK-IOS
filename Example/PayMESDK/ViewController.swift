import UIKit
import PayMESDK
import CryptoSwift

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var floatingButtonController: FloatingButtonController = FloatingButtonController()
    var payME: PayME?
    var activeTextField: UITextField? = nil
    let envData: Dictionary = ["dev": PayME.Env.DEV, "sandbox": PayME.Env.SANDBOX, "production": PayME.Env.PRODUCTION, "staging": PayME.Env.STAGING]

    let environment: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(16)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Environment"
        return label
    }()
    let dropDown: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.setTitleColor(UIColor.black, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let envList: UIPickerView = {
        let list = UIPickerView()
        list.layer.borderColor = UIColor.black.cgColor
        list.layer.borderWidth = 0.5
        list.backgroundColor = .white
        list.translatesAutoresizingMaskIntoConstraints = false
        return list
    }()
    let settingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "setting.svg"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let userIDLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(16)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "UserID"
        return label
    }()
    let userIDTextField: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setLeftPaddingPoints(10)
        textField.keyboardType = .numberPad
        return textField
    }()

    let phoneLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(16)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Phone number"
        return label
    }()
    let phoneTextField: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setLeftPaddingPoints(10)
        textField.placeholder = "Optional"
        textField.keyboardType = .numberPad
        return textField
    }()

    let loginButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 15
        button.setTitle("Login", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let logoutButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 15
        button.setTitle("Logout", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .lightGray
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceVertical = false
        scrollView.isHidden = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    let sdkContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()

    let balance: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(14)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Balance"
        return label
    }()
    let priceLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(16)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0"
        return label
    }()
    let refreshButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "refresh.png"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let openWalletButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.white
        button.setTitle("Open Wallet", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let depositButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.white
        button.setTitle("Nạp tiền ví", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let moneyDeposit: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.backgroundColor = UIColor.white
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Nhập số tiền"
        textField.text = "10000"
        textField.setLeftPaddingPoints(10)
        textField.keyboardType = .numberPad
        return textField
    }()

    let withDrawButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.white
        button.setTitle("Rút tiền ví", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let moneyWithDraw: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.backgroundColor = UIColor.white
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Nhập số tiền"
        textField.text = "10000"
        textField.setLeftPaddingPoints(10)
        textField.keyboardType = .numberPad
        return textField
    }()

    let payButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.white
        button.setTitle("Thanh toán", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let moneyPay: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.backgroundColor = UIColor.white
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Nhập số tiền"
        textField.text = "10000"
        textField.setLeftPaddingPoints(10)
        textField.keyboardType = .numberPad
        return textField
    }()

    let transferButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.white
        button.setTitle("Chuyển", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let moneyTransfer: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.backgroundColor = UIColor.white
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Nhập số tiền"
        textField.text = "10000"
        textField.setLeftPaddingPoints(10)
        textField.keyboardType = .numberPad
        return textField
    }()

    let getMethodButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.white
        button.setTitle("Lấy danh sách ID phương thức", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let getServiceButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.white
        button.setTitle("Lấy danh sách dịch vụ", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()


    let kycButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.white
        button.setTitle("Định danh tài khoản", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var connectToken: String = ""
    private var currentEnv: PayME.Env = PayME.Env.SANDBOX

    func genConnectToken(userId: String, phone: String) -> String {
        let secretKey = EnvironmentSettings.standard.secretKey
        Log.custom.push(title: "Secret key login", message: secretKey)
        let iSO8601DateFormatter = ISO8601DateFormatter()
        let isoDate = iSO8601DateFormatter.string(from: Date())
        let data: [String: Any] = ["timestamp": isoDate, "userId": "\(userId)", "phone": "\(phone)"]
        let params = try? JSONSerialization.data(withJSONObject: data)
        let aes = try? AES(key: Array(secretKey.utf8), blockMode: CBC(iv: [UInt8](repeating: 0, count: 16)), padding: .pkcs5)
        let dataEncrypted = try? aes!.encrypt(Array(String(data: params!, encoding: .utf8)!.utf8))
        print(dataEncrypted!.toBase64()!)
        return dataEncrypted!.toBase64()!
    }

    // generate token ( demo, don't apply this to your code, generate from your server)
    @objc func submit() {
        //PayME.showKYCCamera(currentVC: self)
        // Getting
        UserDefaults.standard.set(userIDTextField.text, forKey: "userID")
        UserDefaults.standard.set(phoneTextField.text, forKey: "phone")
        if (userIDTextField.text != "") {
            let newConnectToken = self.genConnectToken(userId: userIDTextField.text!, phone: phoneTextField.text!)
            Log.custom.push(title: "Connect Token Generator", message: newConnectToken)
            self.connectToken = newConnectToken
            Log.custom.push(title: "Environment variables", message: """
                                                                     {
                                                                     appToken: \(EnvironmentSettings.standard.appToken),
                                                                     publicKey: \(EnvironmentSettings.standard.publicKey),
                                                                     connectToken: \(self.connectToken),
                                                                     appPrivateKey: \(EnvironmentSettings.standard.privateKey),
                                                                     env: \(self.currentEnv)
                                                                     }
                                                                     """)
            payME = PayME(
                    appToken: EnvironmentSettings.standard.appToken,
                    publicKey: EnvironmentSettings.standard.publicKey,
                    connectToken: self.connectToken,
                    appPrivateKey: EnvironmentSettings.standard.privateKey,
                    env: currentEnv,
                    configColor: ["#75255b", "#a81308"],
                    showLog: 1
            )
            showSpinner(onView: view)
            payME?.login(onSuccess: { success in
                self.scrollView.isHidden = false
                if success["code"] as! PayME.KYCState == PayME.KYCState.NOT_KYC {
                    self.kycButton.isHidden = false
                }
                self.getBalance(self.refreshButton)
                self.loginButton.backgroundColor = UIColor.gray
                self.logoutButton.backgroundColor = UIColor.white
                self.removeSpinner()
            }, onError: { error in
                self.scrollView.isHidden = true

                self.removeSpinner()
                self.toastMess(title: "Lỗi", value: (error["message"] as? String) ?? "Something went wrong")
            })
        } else {
            let alert = UIAlertController(title: "Success", message: "Vui lòng nhập userID", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return envData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(envData.keys)[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        setEnv(env: envData[Array(envData.keys)[row]], text: Array(envData.keys)[row])
        pickerView.isHidden = true
    }

    @objc func logout(sender: UIButton!) {
        payME?.logout()
        scrollView.isHidden = true
        loginButton.backgroundColor = UIColor.white
        logoutButton.backgroundColor = UIColor.gray
    }


    @objc func openWalletAction(sender: UIButton!) {
        if (self.connectToken != "") {
            payME!.openWallet(currentVC: self, action: PayME.Action.OPEN, amount: nil, description: nil, extraData: nil,
                    onSuccess: { success in
                        Log.custom.push(title: "Open wallet", message: success)
                    }, onError: { error in
                Log.custom.push(title: "Open wallet", message: error)
                if let code = error["code"] as? Int {
                    if (code != PayME.ResponseCode.USER_CANCELLED) {
                        let message = error["message"] as? String
                        self.toastMess(title: "Lỗi", value: message)
                    }
                }
            })
        } else {
            toastMess(title: "Lỗi", value: "Vui lòng tạo connect token trước")
        }
    }

    @objc func depositAction(sender: UIButton!) {
        if (self.connectToken != "") {
            if (moneyDeposit.text != "") {
                let amount = Int(moneyDeposit.text!)
                if (amount! >= 10000) {
                    let amountDeposit = amount!
                    self.payME!.deposit(currentVC: self, amount: amountDeposit, description: "", extraData: nil, closeWhenDone: true, onSuccess: { success in
                        Log.custom.push(title: "deposit", message: success)
                    }, onError: { error in
                        Log.custom.push(title: "deposit", message: error)
                        if let code = error["code"] as? Int {
                            if (code != PayME.ResponseCode.USER_CANCELLED) {
                                let message = error["message"] as? String
                                self.toastMess(title: "Lỗi", value: message)
                            }
                        }
                    })

                } else {
                    toastMess(title: "Lỗi", value: "Vui lòng nạp hơn 10.000VND")
                }
            } else {
                toastMess(title: "Lỗi", value: "Vui lòng nạp hơn 10.000VND")

            }
        } else {
            toastMess(title: "Lỗi", value: "Vui lòng tạo connect token trước")
        }
    }

    @objc func withDrawAction(sender: UIButton!) {
        if (connectToken != "") {
            if (moneyWithDraw.text != "") {
                let amount = Int(moneyWithDraw.text!)
                if (amount! >= 10000) {
                    let amountWithDraw = amount!
                    payME!.withdraw(currentVC: self, amount: amountWithDraw, description: "", extraData: nil,
                            onSuccess: { success in
                                Log.custom.push(title: "withdraw", message: success)

                            }, onError: { error in
                        Log.custom.push(title: "withdraw", message: error)
                        if let code = error["code"] as? Int {
                            if (code != PayME.ResponseCode.USER_CANCELLED) {
                                let message = error["message"] as? String
                                self.toastMess(title: "Lỗi", value: message)
                            }
                        }
                    })
                } else {
                    toastMess(title: "Lỗi", value: "Vui lòng rút hơn 10.000VND")
                }
            } else {
                toastMess(title: "Lỗi", value: "Vui lòng rút hơn 10.000VND")

            }
        } else {
            toastMess(title: "Lỗi", value: "Vui lòng tạo connect token trước")

        }

    }

    @objc func transferAction(sender: UIButton!) {
        if (connectToken != "") {
            if (moneyWithDraw.text != "") {
                let amount = Int(moneyWithDraw.text!)
                if (amount! >= 10000) {
                    let amountWithDraw = amount!
                    payME!.transfer(currentVC: self, amount: amountWithDraw, description: "", extraData: nil, closeWhenDone: true, onSuccess: { success in
                        Log.custom.push(title: "withdraw", message: success)
                    }, onError: { error in
                        Log.custom.push(title: "withdraw", message: error)
                        if let code = error["code"] as? Int {
                            if (code != PayME.ResponseCode.USER_CANCELLED) {
                                let message = error["message"] as? String
                                self.toastMess(title: "Lỗi", value: message)
                            }
                        }
                    })
                } else {
                    toastMess(title: "Lỗi", value: "Vui lòng chuyển hơn 10.000VND")
                }
            } else {
                toastMess(title: "Lỗi", value: "Vui lòng chuyển hơn 10.000VND")
            }
        } else {
            toastMess(title: "Lỗi", value: "Vui lòng tạo connect token trước")
        }

    }

    @objc func getListMethod(sender: UIButton!) {
        var storeId = 6868
        if (currentEnv == PayME.Env.SANDBOX) {
            storeId = 37048160
        }
        if (currentEnv == PayME.Env.PRODUCTION) {
            storeId = 57956431
        }
        payME!.getPaymentMethods(storeId: storeId, onSuccess: { listMethods in
            self.toastMess(title: "Lấy danh sách phương thức thanh toán thành công", value: "\(listMethods)")
        }, onError: { error in
            let message = error["message"] as? String
            self.toastMess(title: "Lỗi", value: message)
        })
    }

    @objc func getListService() {
        payME!.getSupportedServices(onSuccess: { configs in
            var serviceList = ""
            configs.forEach { service in
                serviceList += "[Key: \(service.getCode()) - Name: \(service.getDescription())]"
            }
            self.toastMess(title: "Lấy danh sách dịch vụ thành công", value: "\(serviceList)")
        }, onError: { error in
            let message = error["message"] as? String
            self.toastMess(title: "Lỗi", value: message)
        })
    }

    @objc func onKYC() {
        payME!.openKYC(currentVC: self, onSuccess: {

        }, onError: { dictionary in
            let message = dictionary["message"] as? String
            self.toastMess(title: "Lỗi", value: message)
        })
    }

    @objc func payAction(sender: UIButton!) {
        if (self.connectToken != "") {
            if (moneyPay.text != "") {
                let amount = Int(moneyPay.text!)
                if (amount! >= 10000) {
                    let amountPay = amount!
                    var storeId = 6868
                    if (self.currentEnv == PayME.Env.SANDBOX) {
                        storeId = 37048160
                    }
                    if (self.currentEnv == PayME.Env.PRODUCTION) {
                        storeId = 57956431
                    }
                    payME!.pay(currentVC: self, storeId: storeId, orderId: String(Date().timeIntervalSince1970), amount: amountPay, note: "Nội dung đơn hàng", paymentMethodID: nil, extraData: nil, onSuccess: { success in
                        Log.custom.push(title: "pay", message: success)
                    }, onError: { error in
                        Log.custom.push(title: "pay", message: error)
                        if let code = error["code"] as? Int {
                            if (code != PayME.ResponseCode.USER_CANCELLED) {
                                let message = error["message"] as? String
                                self.toastMess(title: "Lỗi", value: message)
                            }
                        }
                    })
                } else {
                    toastMess(title: "Lỗi", value: "Vui lòng thanh toán hơn 10.000VND")
                }
            } else {
                toastMess(title: "Lỗi", value: "Vui lòng thanh toán hơn 10.000VND")
            }


        } else {
            toastMess(title: "Lỗi", value: "Vui lòng tạo connect token trước")

        }
    }

    @IBAction func getBalance(_ sender: Any) {
        if (self.connectToken != "") {
            payME!.getWalletInfo(onSuccess: { a in
                self.removeSpinner()
                Log.custom.push(title: "get Wallet Info", message: a)
                var str = ""
                if let v = a["Wallet"]!["balance"]! {
                    str = "\(v)"
                }
                let alert = UIAlertController(title: "Thành công", message: "Lấy balance thành công", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: {
                    self.priceLabel.text = str
                })
            }, onError: { error in
                self.removeSpinner()
                Log.custom.push(title: "get Wallet Info", message: error)
                let message = error["message"] as? String
                self.priceLabel.text = "0"
                self.toastMess(title: "Lỗi", value: message)
            })
        } else {
            self.removeSpinner()
            toastMess(title: "Lỗi", value: "Vui lòng tạo connect token trước")
        }

    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //For mobile numer validation
        if textField == phoneTextField || textField == moneyDeposit || textField == moneyWithDraw || textField == moneyPay || textField == moneyTransfer {
            let allowedCharacters = CharacterSet(charactersIn: "+0123456789 ")//Here change this characters based on your requirement
            let characterSet = CharacterSet(charactersIn: string)
            let maxLength = 10
            let currentString: NSString = (textField.text ?? "") as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return allowedCharacters.isSuperset(of: characterSet) && newString.length <= maxLength
        }
        return true
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {

            // if keyboard size is not available for some reason, dont do anything
            return
        }

        var shouldMoveViewUp = false

        // if active text field is not nil
        if let activeTextField = activeTextField {

            let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: self.view).maxY;

            let topOfKeyboard = self.view.frame.height - keyboardSize.height

            // if the bottom of Textfield is below the top of keyboard, move up
            if bottomOfTextField > topOfKeyboard {
                shouldMoveViewUp = true
            }
        }
        if (shouldMoveViewUp) {
            self.view.frame.origin.y = 0 - keyboardSize.height
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        // move back the root view origin to zero
        self.view.frame.origin.y = 0
    }

    @IBAction func onPressSetting(_ sender: UIButton) {
        let vc = SettingsView()
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func onPressDropDown(_ sender: UIButton) {
        self.envList.isHidden = !self.envList.isHidden
    }

    func setEnv(env: PayME.Env!, text: String!) {
        EnvironmentSettings.standard.changeEnvironment(env: text)
        UserDefaults.standard.set(text, forKey: "env")
        self.dropDown.setTitle(text, for: .normal)
        self.currentEnv = env
        self.logout(sender: logoutButton)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        let isShowLog = UserDefaults.standard.bool(forKey: "isShowLog")
        if (isShowLog) {
            self.floatingButtonController.showWindow()
        } else {
            self.floatingButtonController.hideWindow()
        }
    }

    func toastMess(title: String, value: String?) {
        let alert = UIAlertController(title: title, message: value ?? "Có lỗi xảy ra", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        view.addSubview(environment)
        view.addSubview(dropDown)
        view.addSubview(envList)
        view.addSubview(settingButton)
        view.addSubview(userIDLabel)
        view.addSubview(userIDTextField)
        view.addSubview(phoneLabel)
        view.addSubview(phoneTextField)
        view.addSubview(loginButton)
        view.addSubview(logoutButton)
        view.addSubview(scrollView)

        scrollView.addSubview(sdkContainer)

        sdkContainer.addSubview(balance)
        sdkContainer.addSubview(priceLabel)
        sdkContainer.addSubview(refreshButton)
        sdkContainer.addSubview(openWalletButton)
        sdkContainer.addSubview(depositButton)
        sdkContainer.addSubview(moneyDeposit)
        sdkContainer.addSubview(withDrawButton)
        sdkContainer.addSubview(moneyWithDraw)
        sdkContainer.addSubview(payButton)
        sdkContainer.addSubview(moneyPay)
        sdkContainer.addSubview(transferButton)
        sdkContainer.addSubview(moneyTransfer)
        sdkContainer.addSubview(getServiceButton)
        sdkContainer.addSubview(getMethodButton)
        sdkContainer.addSubview(kycButton)

        view.bringSubview(toFront: envList)

        phoneTextField.delegate = self
        moneyDeposit.delegate = self
        moneyWithDraw.delegate = self
        moneyPay.delegate = self
        envList.delegate = self

        environment.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 10).isActive = true
        environment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true

        dropDown.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 10).isActive = true
        dropDown.leadingAnchor.constraint(equalTo: environment.trailingAnchor, constant: 30).isActive = true
        dropDown.heightAnchor.constraint(equalToConstant: 30).isActive = true
        dropDown.widthAnchor.constraint(equalToConstant: 150).isActive = true
        dropDown.addTarget(self, action: #selector(onPressDropDown(_:)), for: .touchUpInside)

        envList.isHidden = true
        envList.topAnchor.constraint(equalTo: dropDown.bottomAnchor).isActive = true
        envList.centerXAnchor.constraint(equalTo: dropDown.centerXAnchor).isActive = true
        envList.heightAnchor.constraint(equalToConstant: 100).isActive = true

        settingButton.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 10).isActive = true
        settingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        settingButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        settingButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        settingButton.addTarget(self, action: #selector(onPressSetting(_:)), for: .touchUpInside)

        userIDLabel.topAnchor.constraint(equalTo: environment.bottomAnchor, constant: 20).isActive = true
        userIDLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true

        userIDTextField.topAnchor.constraint(equalTo: userIDLabel.bottomAnchor, constant: 5).isActive = true
        userIDTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        userIDTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
        userIDTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        userIDTextField.text = UserDefaults.standard.string(forKey: "userID") ?? ""

        phoneLabel.topAnchor.constraint(equalTo: userIDTextField.bottomAnchor, constant: 20).isActive = true
        phoneLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true

        phoneTextField.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 5).isActive = true
        phoneTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        phoneTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
        phoneTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        phoneTextField.text = UserDefaults.standard.string(forKey: "phone") ?? ""

        loginButton.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 20).isActive = true
        loginButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        loginButton.trailingAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -5).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loginButton.addTarget(self, action: #selector(submit), for: .touchUpInside)

        logoutButton.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 20).isActive = true
        logoutButton.leadingAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 5).isActive = true
        logoutButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)

        scrollView.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true

        sdkContainer.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        sdkContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        sdkContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        sdkContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

        balance.topAnchor.constraint(equalTo: sdkContainer.topAnchor, constant: 20).isActive = true
        balance.leadingAnchor.constraint(equalTo: sdkContainer.leadingAnchor, constant: 10).isActive = true

        refreshButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        refreshButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        refreshButton.topAnchor.constraint(equalTo: sdkContainer.topAnchor, constant: 20).isActive = true
        refreshButton.trailingAnchor.constraint(equalTo: sdkContainer.trailingAnchor, constant: -10).isActive = true
        refreshButton.addTarget(self, action: #selector(getBalance(_:)), for: .touchUpInside)

        priceLabel.topAnchor.constraint(equalTo: sdkContainer.topAnchor, constant: 20).isActive = true
        priceLabel.trailingAnchor.constraint(equalTo: refreshButton.leadingAnchor, constant: -30).isActive = true

        openWalletButton.topAnchor.constraint(equalTo: refreshButton.bottomAnchor, constant: 10).isActive = true
        openWalletButton.leadingAnchor.constraint(equalTo: sdkContainer.leadingAnchor, constant: 10).isActive = true
        openWalletButton.trailingAnchor.constraint(equalTo: sdkContainer.trailingAnchor, constant: -10).isActive = true
        openWalletButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        openWalletButton.addTarget(self, action: #selector(openWalletAction), for: .touchUpInside)

        depositButton.topAnchor.constraint(equalTo: openWalletButton.bottomAnchor, constant: 20).isActive = true
        depositButton.leadingAnchor.constraint(equalTo: sdkContainer.leadingAnchor, constant: 10).isActive = true
        depositButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        depositButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        depositButton.addTarget(self, action: #selector(depositAction), for: .touchUpInside)

        moneyDeposit.topAnchor.constraint(equalTo: openWalletButton.bottomAnchor, constant: 20).isActive = true
        moneyDeposit.leadingAnchor.constraint(equalTo: depositButton.trailingAnchor, constant: 10).isActive = true
        moneyDeposit.trailingAnchor.constraint(equalTo: sdkContainer.trailingAnchor, constant: -10).isActive = true
        moneyDeposit.heightAnchor.constraint(equalToConstant: 30).isActive = true

        withDrawButton.topAnchor.constraint(equalTo: depositButton.bottomAnchor, constant: 10).isActive = true
        withDrawButton.leadingAnchor.constraint(equalTo: sdkContainer.leadingAnchor, constant: 10).isActive = true
        withDrawButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        withDrawButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        withDrawButton.addTarget(self, action: #selector(withDrawAction), for: .touchUpInside)

        moneyWithDraw.topAnchor.constraint(equalTo: depositButton.bottomAnchor, constant: 10).isActive = true
        moneyWithDraw.leadingAnchor.constraint(equalTo: depositButton.trailingAnchor, constant: 10).isActive = true
        moneyWithDraw.trailingAnchor.constraint(equalTo: sdkContainer.trailingAnchor, constant: -10).isActive = true
        moneyWithDraw.heightAnchor.constraint(equalToConstant: 30).isActive = true

        payButton.topAnchor.constraint(equalTo: withDrawButton.bottomAnchor, constant: 10).isActive = true
        payButton.leadingAnchor.constraint(equalTo: sdkContainer.leadingAnchor, constant: 10).isActive = true
        payButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        payButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        payButton.addTarget(self, action: #selector(payAction), for: .touchUpInside)

        moneyPay.topAnchor.constraint(equalTo: withDrawButton.bottomAnchor, constant: 10).isActive = true
        moneyPay.leadingAnchor.constraint(equalTo: depositButton.trailingAnchor, constant: 10).isActive = true
        moneyPay.trailingAnchor.constraint(equalTo: sdkContainer.trailingAnchor, constant: -10).isActive = true
        moneyPay.heightAnchor.constraint(equalToConstant: 30).isActive = true

        transferButton.topAnchor.constraint(equalTo: payButton.bottomAnchor, constant: 10).isActive = true
        transferButton.leadingAnchor.constraint(equalTo: sdkContainer.leadingAnchor, constant: 10).isActive = true
        transferButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        transferButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        transferButton.addTarget(self, action: #selector(transferAction), for: .touchUpInside)

        moneyTransfer.topAnchor.constraint(equalTo: payButton.bottomAnchor, constant: 10).isActive = true
        moneyTransfer.leadingAnchor.constraint(equalTo: transferButton.trailingAnchor, constant: 10).isActive = true
        moneyTransfer.trailingAnchor.constraint(equalTo: sdkContainer.trailingAnchor, constant: -10).isActive = true
        moneyTransfer.heightAnchor.constraint(equalToConstant: 30).isActive = true

        getServiceButton.topAnchor.constraint(equalTo: transferButton.bottomAnchor, constant: 10).isActive = true
        getServiceButton.leadingAnchor.constraint(equalTo: sdkContainer.leadingAnchor, constant: 10).isActive = true
        getServiceButton.trailingAnchor.constraint(equalTo: sdkContainer.trailingAnchor, constant: -10).isActive = true
        getServiceButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        getServiceButton.addTarget(self, action: #selector(getListService), for: .touchUpInside)

        getMethodButton.topAnchor.constraint(equalTo: getServiceButton.bottomAnchor, constant: 10).isActive = true
        getMethodButton.leadingAnchor.constraint(equalTo: sdkContainer.leadingAnchor, constant: 10).isActive = true
        getMethodButton.trailingAnchor.constraint(equalTo: sdkContainer.trailingAnchor, constant: -10).isActive = true
        getMethodButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        getMethodButton.addTarget(self, action: #selector(getListMethod), for: .touchUpInside)

        kycButton.topAnchor.constraint(equalTo: getMethodButton.bottomAnchor, constant: 10).isActive = true
        kycButton.leadingAnchor.constraint(equalTo: sdkContainer.leadingAnchor, constant: 10).isActive = true
        kycButton.trailingAnchor.constraint(equalTo: sdkContainer.trailingAnchor, constant: -10).isActive = true
        kycButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        kycButton.addTarget(self, action: #selector(onKYC), for: .touchUpInside)

        updateViewConstraints()
        view.layoutIfNeeded()

        //them view o day
//        let a = UIView(frame: CGRect.zero)
//        a.backgroundColor = .red
//        sdkContainer.addSubview(a)
//        a.translatesAutoresizingMaskIntoConstraints = false
//        a.topAnchor.constraint(equalTo: getMethodButton.bottomAnchor).isActive = true
//        a.leadingAnchor.constraint(equalTo: sdkContainer.leadingAnchor, constant: 10).isActive = true
//        a.trailingAnchor.constraint(equalTo: sdkContainer.trailingAnchor, constant: -10).isActive = true
//        a.heightAnchor.constraint(equalToConstant: 200).isActive = true

        sdkContainer.bottomAnchor.constraint(equalTo: sdkContainer.subviews[sdkContainer.subviews.count - 1].bottomAnchor, constant: 8).isActive = true

        updateViewConstraints()
        view.layoutIfNeeded()
        scrollView.contentSize = sdkContainer.frame.size

        let env = UserDefaults.standard.string(forKey: "env") ?? ""
        if (env == "") {
            setEnv(env: PayME.Env.SANDBOX, text: "sandbox")
        } else {
            envList.selectRow(Array(envData.keys).index(of: env)!, inComponent: 0, animated: true)
            setEnv(env: envData[env], text: env)
        }
    }

}

extension ViewController: UITextFieldDelegate {
    // when user select a textfield, this method will be called
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // set the activeTextField to the selected textfield
        self.activeTextField = textField
    }

    // when user click 'done' or dismiss the keyboard
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }

    func setRightPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
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

var vSpinner: UIView?

extension UIViewController {
    func showSpinner(onView: UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center

        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }

        vSpinner = spinnerView
    }

    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}

