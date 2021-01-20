//
//  File.swift
//  PayMESDK
//
//  Created by HuyOpen on 11/6/20.
//

import UIKit
import Lottie

class ATMModal: UIViewController, PanModalPresentable, UITextFieldDelegate {
    let screenSize:CGRect = UIScreen.main.bounds
    var atmView = ATMView()
    var keyboardHeight : CGFloat = 0
    internal var listBank : [Bank] = []
    internal var bankDetect : Bank?
    var onError : (([String:AnyObject]) -> ())? = nil
    var onSuccess : (([String:AnyObject]) -> ())? = nil
    var bankName : String = ""
    let successView = SuccessView()
    let failView = FailView()
    var result = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        atmView.price.text = "\(formatMoney(input: Methods.amount)) đ"
        contentLabel.text = "Nội dung"
        if (Methods.note == "") {
            atmView.memoLabel.text = "Không có nội dung"
        } else {
            atmView.memoLabel.text = Methods.note
        }
        
        view.addSubview(scrollView)
        scrollView.backgroundColor = .white
        atmView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(atmView)

        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.heightAnchor.constraint(equalToConstant: 500).isActive = true
    
        atmView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        atmView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        atmView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        atmView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        // this is important for scrolling
        atmView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        atmView.cardNumberField.delegate = self
        atmView.dateField.delegate = self
        
        atmView.button.addTarget(self, action: #selector(payATM), for: .touchUpInside)
        atmView.closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewDidLayoutSubviews() {
        let topPoint = CGPoint(x: atmView.detailView.frame.minX+10, y: atmView.detailView.bounds.midY + 15)
        let bottomPoint = CGPoint(x: atmView.detailView.frame.maxX-10, y: atmView.detailView.bounds.midY + 15)
        atmView.detailView.createDashedLine(from: topPoint, to: bottomPoint, color: UIColor(203,203,203), strokeLength: 3, gapLength: 4, width: 0.5)
        atmView.detailView.applyGradient(colors: [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor], radius: 0)
        atmView.button.applyGradient(colors: [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor], radius: 10)
        successView.button.applyGradient(colors: [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor], radius: 10)
        failView.button.applyGradient(colors: [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor], radius: 10)
    }
    
    @objc func closeAction() {
        self.dismiss(animated: true, completion: nil)

    }
    
    @objc func payATM() {
        let cardNumber = atmView.cardNumberField.text
        let cardHolder = atmView.nameField.text
        let issuedAt = atmView.dateField.text
        if (bankDetect != nil) {
            if (cardNumber!.count != bankDetect!.cardNumberLength) {
                toastMessError(title: "Lỗi", message: "Vui lòng nhập mã thẻ đúng định dạng")
                return
            }
        } else {
            toastMessError(title: "Lỗi", message: "Vui lòng nhập mã thẻ đúng định dạng")
            return
        }
        if (cardHolder == nil) {
            toastMessError(title: "Lỗi", message: "Vui lòng nhập họ tên chủ thẻ")
            return
        } else {
            if (cardHolder!.count == 0) {
                toastMessError(title: "Lỗi", message: "Vui lòng nhập họ tên chủ thẻ")
                return
            }
        }
        if (issuedAt!.count != 5) {
            toastMessError(title: "Lỗi", message: "Vui lòng nhập ngày phát hành thẻ")
            return
        } else {
            let dateArr = issuedAt!.components(separatedBy: "/")
            let month = Int(dateArr[0]) ?? 0
            let year = Int(dateArr[1]) ?? 0
            if (month == 0 || year == 0 || month > 12 || year > 21 || month <= 0 ) {
                toastMessError(title: "Lỗi", message: "Vui lòng nhập ngày phát hành thẻ hợp lệ")
                return
            }
            let date = "20" + dateArr[1] + "-" + dateArr[0] + "-01T00:00:00.000Z"
            self.showSpinner(onView: self.view)
            API.transferATM(storeId: Methods.storeId, orderId: Methods.orderId, extraData: Methods.extraData, note: Methods.note, cardNumber: cardNumber!, cardHolder: cardHolder!, issuedAt: date, amount: Methods.amount,
                            onSuccess: { success in
                                print(success)
                                let payment = success["OpenEWallet"]!["Payment"] as! [String:AnyObject]
                                let pay = payment["Pay"] as! [String:AnyObject]
                                let succeeded = pay["succeeded"] as! Bool
                                if (succeeded == true) {
                                    DispatchQueue.main.async {
                                        self.removeSpinner()
                                        self.setupSuccess()
                                    }
                                } else {
                                    let statePay = pay["payment"] as? [String:AnyObject]
                                    if (statePay == nil) {
                                        let message = pay["message"] as! String
                                        self.failView.failLabel.text = message
                                        self.setupFail()
                                        self.removeSpinner()
                                        return
                                    }
                                    let state = statePay!["state"] as! String
                                    if (state == "REQUIRED_VERIFY")
                                    {
                                        let html = statePay!["html"] as? String
                                        if (html != nil) {
                                            self.removeSpinner()
                                            let webViewController = WebViewController()
                                            webViewController.form = html!
                                            webViewController.setOnSuccessWebView(onSuccessWebView: { responseFromWebView in
                                                webViewController.dismiss(animated: true)
                                                self.setupSuccess()
                                            })
                                            webViewController.setOnFailWebView(onFailWebView: { responseFromWebView in
                                                webViewController.dismiss(animated: true)
                                                self.removeSpinner()
                                                self.failView.failLabel.text = responseFromWebView
                                                self.setupFail()
                                            })
                                            self.presentPanModal(webViewController)
                                        }
                                    } else {
                                        let message = statePay!["message"] as! String
                                        self.failView.failLabel.text = message
                                        self.setupFail()
                                        self.removeSpinner()
                                    }
                                }
                            
                                
                            }, onError: { error in
                                self.onError!(error)
                                self.removeSpinner()
                                self.dismiss(animated: true, completion: {
                                    self.toastMessError(title: "Lỗi", message: error["message"] as! String)
                                })
            })
            
        }
        
        
    }
    
    func setupSuccess() {
        self.result = true
        scrollView.removeFromSuperview()
        view.addSubview(successView)
        successView.translatesAutoresizingMaskIntoConstraints = false
        successView.widthAnchor.constraint(equalToConstant: screenSize.width).isActive = true
        successView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        successView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        successView.button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        successView.closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        successView.roleLabel.text = formatMoney(input: Methods.amount)
        if (Methods.note == "") {
            successView.memoLabel.text = "Không có nội dung"
        } else {
            successView.memoLabel.text = Methods.note
        }
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: successView.button.bottomAnchor, constant: 10).isActive = true
        self.updateViewConstraints()
        self.view.layoutIfNeeded()
        self.panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .shortForm)
        
    }
    
    func setupFail() {
        self.result = true
        scrollView.removeFromSuperview()
        view.addSubview(failView)
        failView.translatesAutoresizingMaskIntoConstraints = false
        failView.widthAnchor.constraint(equalToConstant: screenSize.width).isActive = true
        failView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        failView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    
        failView.roleLabel.text = formatMoney(input: Methods.amount)
        if (Methods.note == "") {
            failView.memoLabel.text = "Không có nội dung"
        } else {
            failView.memoLabel.text = Methods.note
        }
        failView.button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        failView.closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: failView.button.bottomAnchor, constant: 10).isActive = true
        self.updateViewConstraints()
        self.view.layoutIfNeeded()
        self.panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .shortForm)
        
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {

        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        let contentInset:UIEdgeInsets = self.scrollView.contentInset
        
        if (contentInset.bottom < 625 + keyboardFrame.size.height - screenSize.height) {
            scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 625 + keyboardFrame.size.height - screenSize.height, right: 0.0)
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom)
            scrollView.setContentOffset(bottomOffset, animated: true)
        }
        self.keyboardHeight = keyboardFrame.size.height
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
    }

    @objc func keyboardWillHide(notification:NSNotification) {
        self.keyboardHeight = 0
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
    }
    
    func toastMessError(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }


    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    let detailView : UIView = {
          let detailView  = UIView()
          detailView.translatesAutoresizingMaskIntoConstraints = false
          return detailView
      }()
      

    let price : UILabel = {
      let price = UILabel()
      price.textColor = .white
      price.backgroundColor = .clear
      price.font = UIFont(name: "Arial", size: 32)
      price.translatesAutoresizingMaskIntoConstraints = false
      return price
    }()
      
    let memoLabel : UILabel = {
          let memoLabel = UILabel()
          memoLabel.textColor = .white
          memoLabel.backgroundColor = .clear
          memoLabel.font = UIFont(name: "Arial", size: 16)
          memoLabel.translatesAutoresizingMaskIntoConstraints = false
          memoLabel.textAlignment = .right
          return memoLabel
    }()
      
    let methodTitle : UILabel = {
          let methodTitle = UILabel()
          methodTitle.textColor = UIColor(114,129,144)
          methodTitle.backgroundColor = .clear
          methodTitle.font = UIFont(name: "Arial", size: 16)
          methodTitle.translatesAutoresizingMaskIntoConstraints = false
          return methodTitle
    }()
      
    let contentLabel : UILabel = {
          let contentLabel = UILabel()
          contentLabel.textColor = .white
          contentLabel.backgroundColor = .clear
          contentLabel.font = UIFont(name: "Arial", size: 16)
          contentLabel.translatesAutoresizingMaskIntoConstraints = false
          return contentLabel
    }()
      
    let closeButton : UIButton = {
          let button = UIButton()
          let bundle = Bundle(for: QRNotFound.self)
          let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
          let resourceBundle = Bundle(url: bundleURL!)
          let image = UIImage(named: "16Px", in: resourceBundle, compatibleWith: nil)
          button.setImage(image, for: .normal)
          button.translatesAutoresizingMaskIntoConstraints = false
          return button
    }()

      
    let button : UIButton = {
          let button = UIButton()
          button.translatesAutoresizingMaskIntoConstraints = false
          button.layer.cornerRadius = 10
          return button
    }()
      
    let txtLabel : UILabel = {
          let label = UILabel()
          label.textColor = UIColor(26,26,26)
          label.backgroundColor = .clear
          label.font = UIFont(name: "Lato-SemiBold", size: 20)
          label.translatesAutoresizingMaskIntoConstraints = false
          return label
    }()

    let containerView : UIView = {
           let containerView = UIView()
           containerView.layer.cornerRadius = 15.0
           containerView.layer.borderColor = UIColor(203,203,203).cgColor
           containerView.layer.borderWidth = 0.5
           containerView.translatesAutoresizingMaskIntoConstraints = false
           return containerView
    }()

    let bankNameLabel: UILabel = {
           let label = UILabel()
           label.textColor = UIColor(9,9,9)
           label.font = label.font.withSize(16)
           label.backgroundColor = .clear
           label.translatesAutoresizingMaskIntoConstraints = false
           return label
    }()

    let bankContentLabel: UILabel = {
           let label = UILabel()
           label.textColor = UIColor(98,98,98)
           label.backgroundColor = .clear
           label.font = label.font.withSize(12)
           label.translatesAutoresizingMaskIntoConstraints = false
           return label
   }()

   let walletMethodImage: UIImageView = {
           let bundle = Bundle(for: Method.self)
           let bundleURL = bundle.resourceURL?.appendingPathComponent("PayMESDK.bundle")
           let resourceBundle = Bundle(url: bundleURL!)
           let image = UIImage(named: "ptAtm", in: resourceBundle, compatibleWith: nil)
           var bgImage = UIImageView(image: image)
           bgImage.translatesAutoresizingMaskIntoConstraints = false
           return bgImage
   }()

   let cardNumberField: UITextField = {
           let textField = UITextField()
           textField.layer.borderColor = UIColor.init(hexString: "#cbcbcb").cgColor
           textField.layer.borderWidth = 0.5
           textField.translatesAutoresizingMaskIntoConstraints = false
           textField.placeholder = "Nhập số thẻ"
           textField.setLeftPaddingPoints(20)
           textField.keyboardType = .numberPad
           textField.layer.cornerRadius = 15
           return textField
   }()

   let dateField: UITextField = {
       let textField = UITextField()
       textField.layer.borderColor = UIColor.init(hexString: "#cbcbcb").cgColor
       textField.layer.borderWidth = 0.5
       textField.translatesAutoresizingMaskIntoConstraints = false
       textField.placeholder = "Ngày phát hành (MM/YY)"
       textField.setLeftPaddingPoints(20)
       textField.keyboardType = .numberPad
       textField.layer.cornerRadius = 15
       return textField
   }()

   let nameField: UITextField = {
       let textField = UITextField()
       textField.layer.borderColor = UIColor.init(hexString: "#cbcbcb").cgColor
       textField.layer.borderWidth = 0.5
       textField.translatesAutoresizingMaskIntoConstraints = false
       textField.placeholder = "Họ tên chủ thẻ"
       textField.setLeftPaddingPoints(20)
       textField.layer.cornerRadius = 15
       return textField
   }()
   
   let guideTxt : UILabel = {
       let confirmTitle = UILabel()
       confirmTitle.textColor = UIColor(11,11,11)
       confirmTitle.font = UIFont.systemFont(ofSize: 12, weight: .regular)
       confirmTitle.translatesAutoresizingMaskIntoConstraints = false
       confirmTitle.textAlignment = .left
       confirmTitle.lineBreakMode = .byWordWrapping
       confirmTitle.numberOfLines = 0
       confirmTitle.text = "Nhập số thẻ ở mặt trước thẻ"
       return confirmTitle
   }()
   
    
    var allowsExtendedPanScrolling: Bool {
        return true
    }
    
    var panScrollable: UIScrollView? {
        return nil
    }

    var longFormHeight: PanModalHeight {
        if (keyboardHeight != 0) {
            return .maxHeightWithTopInset(40)
        }
        if (result == true) {
            return .intrinsicHeight
        }
        return .contentHeight(500)
    }
    var shortFormHeight: PanModalHeight {
        return longFormHeight
    }

    var anchorModalToLongForm: Bool {
        return false
    }

    var shouldRoundTopCorners: Bool {
        return true
    }

    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //Format Date of Birth dd-MM-yyyy

        //initially identify your textfield

        if textField == atmView.dateField {

            // check the chars length dd -->2 at the same time calculate the dd-MM --> 5
            if (atmView.dateField.text?.count == 2) {
                //Handle backspace being pressed
                if !(string == "") {
                    // append the text
                    atmView.dateField.text = (atmView.dateField.text)! + "/"
                }
            }
            // check the condition not exceed 9 chars
            return !(textField.text!.count > 4 && (string.count ) > range.length)
        }
        if textField == atmView.cardNumberField {
            if (atmView.cardNumberField.text!.count >= 5) {
                if !(string == "") {
                    print(string)
                    // append the text
                    let stringToCompare = (atmView.cardNumberField.text)! + string
                    for bank in listBank {
                        self.bankDetect = nil
                        if (stringToCompare.contains(bank.cardPrefix)) {
                            self.bankDetect = bank
                            self.atmView.guideTxt.textColor = UIColor(11,11,11)

                            //atmView.cardNumberField
                            self.atmView.guideTxt.text = bank.shortName
                            break
                        }
                    }
                    if (self.bankDetect == nil) {
                        self.atmView.guideTxt.text = "Thẻ không đúng định dạng"
                        self.atmView.guideTxt.textColor = .red

                    }
                } else {
                    self.atmView.guideTxt.text = "Nhập số thẻ ở mặt trước thẻ"
                    self.atmView.guideTxt.textColor = UIColor(11,11,11)
                    self.bankDetect = nil
                    
                }
            } else {
                self.atmView.guideTxt.text = "Nhập số thẻ ở mặt trước thẻ"
                self.atmView.guideTxt.textColor = UIColor(11,11,11)
                self.bankDetect = nil
            }
            if (bankDetect != nil) {
                if (textField.text!.count + 1  == bankDetect!.cardNumberLength) {
                    API.getBankName(swiftCode: bankDetect!.swiftCode, cardNumber: textField.text! + string, onSuccess: {response in
                        print(PayME.accessToken)
                        let bankNameRes = response["Utility"]!["GetBankName"] as! [String:AnyObject]
                        let succeeded = bankNameRes["succeeded"] as! Bool
                        if (succeeded == true) {
                            let name = bankNameRes["accountName"] as! String
                            self.bankName = name
                            self.atmView.nameField.text = name
                        } else {
                            self.bankName = ""
                            self.atmView.nameField.text = ""
                        }
                    }, onError: { error in
                        print(error)
                    })
                    print(textField.text! + string)
                }
            }
            
            if (bankDetect != nil) {
                return textField.text!.count + 1 <= bankDetect!.cardNumberLength
            }
            return !(textField.text!.count > 19 && (string.count ) > range.length)

        }
        return true
    }
}
