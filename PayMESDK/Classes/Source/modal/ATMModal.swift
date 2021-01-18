//
//  Methods.swift
//  PayMESDK
//
//  Created by HuyOpen on 10/28/20.
//

import UIKit
import CommonCrypto



class ATMModal: UINavigationController, PanModalPresentable, UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //Format Date of Birth dd-MM-yyyy

        //initially identify your textfield

        if textField == dateField {

            // check the chars length dd -->2 at the same time calculate the dd-MM --> 5
            if (dateField.text?.count == 2) {
                //Handle backspace being pressed
                if !(string == "") {
                    // append the text
                    dateField.text = (atmView.dateField.text)! + "/"
                }
            }
            // check the condition not exceed 9 chars
            return !(textField.text!.count > 4 && (string.count ) > range.length)
        }
        if textField == cardNumberField {
            if (cardNumberField.text!.count >= 5) {
                if !(string == "") {
                    print(string)
                    // append the text
                    let stringToCompare = (cardNumberField.text)! + string
                    for bank in listBank {
                        self.bankDetect = nil
                        if (stringToCompare.contains(bank.cardPrefix)) {
                            self.bankDetect = bank
                            self.guideTxt.textColor = UIColor(11,11,11)

                            //atmView.cardNumberField
                            self.guideTxt.text = bank.shortName
                            break
                        }
                    }
                    if (self.bankDetect == nil) {
                        self.guideTxt.text = "Thẻ không đúng định dạng"
                        self.guideTxt.textColor = .red

                    }
                } else {
                    self.guideTxt.text = "Nhập số thẻ ở mặt trước thẻ"
                    self.guideTxt.textColor = UIColor(11,11,11)
                    self.bankDetect = nil
                    
                }
            } else {
                self.guideTxt.text = "Nhập số thẻ ở mặt trước thẻ"
                self.guideTxt.textColor = UIColor(11,11,11)
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
                            self.nameField.text = name
                        } else {
                            self.bankName = ""
                            self.nameField.text = ""
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
    
    var bankName : String = ""
    var data : [MethodInfo] = []
    var storeId : Int = 0
    var orderId : Int = 0
    var amount : Int = 10000
    var note : String = ""
    var extraData : String = ""
    var transaction : String = ""
    private var active : Int?
    private var bankDetect : Bank?
    var onError : (([String:AnyObject]) -> ())? = nil
    var onSuccess : (([String:AnyObject]) -> ())? = nil
    var appENV : String?

    let methodsView : UIView = {
        let methodsView  = UIView()
        methodsView.translatesAutoresizingMaskIntoConstraints = false
        return methodsView
    }()
    var listBank : [Bank] = []
    let atmView = ATMView()
    let successView = SuccessView()
    let failView = FailView()
    var keyBoardHeight : CGFloat = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        self.view.addSubview(closeButton)
        self.view.addSubview(txtLabel)
        self.view.addSubview(detailView)
        self.view.addSubview(methodTitle)
        self.view.addSubview(containerView)
        self.view.addSubview(button)
        self.view.addSubview(cardNumberField)
        self.view.addSubview(dateField)
        self.view.addSubview(nameField)
        self.view.addSubview(guideTxt)
        
        button.setTitle("THANH TOÁN", for: .normal)
        bankNameLabel.text = "Thẻ ATM nội địa"
        
        containerView.addSubview(walletMethodImage)
        containerView.addSubview(bankNameLabel)
        containerView.addSubview(bankContentLabel)
        // contentView.addSubview(walletMethodImage)
        
        detailView.addSubview(price)
        detailView.backgroundColor = UIColor(8,148,31)
        detailView.addSubview(contentLabel)
        detailView.addSubview(memoLabel)
        txtLabel.text = "Xác nhận thanh toán"
        price.text = "\(formatMoney(input: PayME.amount)) đ"
        contentLabel.text = "Nội dung"
        if (PayME.description == "") {
            memoLabel.text = "Không có nội dung"
        } else {
            memoLabel.text = PayME.description
        }
        methodTitle.text = "Nguồn thanh toán"

        txtLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 19).isActive = true
        txtLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        
        detailView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        detailView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        detailView.heightAnchor.constraint(equalToConstant: 118.0).isActive = true
        detailView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        detailView.topAnchor.constraint(equalTo: txtLabel.bottomAnchor, constant: 16.0).isActive = true
        
        price.topAnchor.constraint(equalTo: detailView.topAnchor, constant: 15).isActive = true
        price.centerXAnchor.constraint(equalTo: detailView.centerXAnchor).isActive = true
        
        
        closeButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 19).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        contentLabel.bottomAnchor.constraint(equalTo: detailView.bottomAnchor, constant: -15).isActive = true
        contentLabel.leadingAnchor.constraint(equalTo: detailView.leadingAnchor, constant: 30).isActive = true
        contentLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .horizontal)
        contentLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        memoLabel.bottomAnchor.constraint(equalTo: detailView.bottomAnchor, constant: -15).isActive = true
        memoLabel.leadingAnchor.constraint(equalTo: contentLabel.trailingAnchor, constant: 30).isActive = true
        memoLabel.trailingAnchor.constraint(equalTo: detailView.trailingAnchor, constant: -30).isActive = true
        memoLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 250), for: .horizontal)
        memoLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        methodTitle.topAnchor.constraint(equalTo: detailView.bottomAnchor, constant: 10).isActive = true
        methodTitle.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        
    
        containerView.topAnchor.constraint(equalTo: methodTitle.bottomAnchor, constant: 10).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
        containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        
        walletMethodImage.heightAnchor.constraint(equalToConstant: 26).isActive = true
        walletMethodImage.widthAnchor.constraint(equalToConstant: 26).isActive = true
        walletMethodImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
        walletMethodImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        bankNameLabel.leadingAnchor.constraint(equalTo: walletMethodImage.trailingAnchor, constant: 10).isActive = true
        bankNameLabel.trailingAnchor.constraint(equalTo: bankContentLabel.leadingAnchor, constant: -5).isActive = true
        bankNameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true

        bankContentLabel.leadingAnchor.constraint(equalTo: bankNameLabel.trailingAnchor, constant: 5).isActive = true
        bankContentLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        cardNumberField.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 10).isActive = true
        cardNumberField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cardNumberField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
        cardNumberField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        
        guideTxt.topAnchor.constraint(equalTo: self.cardNumberField.bottomAnchor, constant: 10).isActive = true
        guideTxt.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
        guideTxt.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        
        nameField.topAnchor.constraint(equalTo: self.guideTxt.bottomAnchor, constant: 10).isActive = true
        nameField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        nameField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
        nameField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        
        dateField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 10).isActive = true
        dateField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        dateField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
        dateField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        
        button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        button.topAnchor.constraint(equalTo: dateField.bottomAnchor, constant: 20).isActive = true
        button.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
        button.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: button.bottomAnchor, constant: 10).isActive = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {

          // if keyboard size is not available for some reason, dont do anything
          return
        }
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: button.bottomAnchor, constant: keyboardSize.height).isActive = true
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
    }
    
    
    override func viewDidLayoutSubviews() {
        let topPoint = CGPoint(x: self.frame.minX+10, y: self.bounds.midY + 15)
        let bottomPoint = CGPoint(x: self.frame.maxX-10, y: self.bounds.midY + 15)
        successView.button.applyGradient(colors: [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor], radius: 10)
        failView.button.applyGradient(colors: [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor], radius: 10)
        
        self.detailView.createDashedLine(from: topPoint, to: bottomPoint, color: UIColor(203,203,203), strokeLength: 3, gapLength: 4, width: 0.5)
        self.detailView.applyGradient(colors: [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor], radius: 0)

        self.button.applyGradient(colors: [UIColor(hexString: PayME.configColor[0]).cgColor, UIColor(hexString: PayME.configColor.count > 1 ? PayME.configColor[1] : PayME.configColor[0]).cgColor], radius: 10)

    }
    
    
    
    @objc
    func closeAction(button:UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func payATM() {
        let cardNumber = self.cardNumberField.text
        let cardHolder = self.nameField.text
        let issuedAt = self.dateField.text
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
            let date = "20" + dateArr[1] + "-" + dateArr[0] + "-01T00:00:00.000Z"
            self.showSpinner(onView: self.view)
            API.transferATM(storeId: self.storeId, orderId: self.orderId, extraData: self.extraData, note: self.note, cardNumber: cardNumber!, cardHolder: cardHolder!, issuedAt: date, amount: self.amount,
                            onSuccess: { success in
                                print(success)
                                let payment = success["OpenEWallet"]!["Payment"] as! [String:AnyObject]
                                let pay = payment["Pay"] as! [String:AnyObject]
                                let succeeded = pay["succeeded"] as! Bool
                                if (succeeded == true) {
                                    DispatchQueue.main.async {
                                        self.atmView.removeFromSuperview()
                                        self.setupSuccess()
                                    }
                                } else {
                                    let statePay = pay["payment"] as? [String:AnyObject]
                                    if (statePay == nil) {
                                        let message = pay["message"] as! String
                                        self.atmView.removeFromSuperview()
                                        self.setupFail()
                                        self.failView.failLabel.text = message
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
                                                self.atmView.removeFromSuperview()
                                                self.setupSuccess()
                                            })
                                            webViewController.setOnFailWebView(onFailWebView: { responseFromWebView in
                                                webViewController.dismiss(animated: true)
                                                self.removeSpinner()
                                                self.atmView.removeFromSuperview()
                                                self.setupFail()
                                                self.failView.failLabel.text = responseFromWebView
                                            })
                                            self.presentPanModal(webViewController)
                                        }
                                    } else {
                                        let message = statePay!["message"] as! String
                                        self.atmView.removeFromSuperview()
                                        self.setupFail()
                                        self.failView.failLabel.text = message
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
    
   
    
    func setupFail() {
        view.addSubview(failView)
        failView.translatesAutoresizingMaskIntoConstraints = false
        failView.isUserInteractionEnabled = true
        failView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        failView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        failView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        failView.heightAnchor.constraint(equalTo: self.view.heightAnchor, constant: 0).isActive = true
        failView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: 0).isActive = true
        failView.roleLabel.text = formatMoney(input: self.amount)
        if (self.note == "") {
            failView.memoLabel.text = "Không có nội dung"
        } else {
            failView.memoLabel.text = self.note
        }
        failView.button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        failView.closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: failView.button.bottomAnchor, constant: 10).isActive = true
        self.updateViewConstraints()
        self.view.layoutIfNeeded()
        self.panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .shortForm)
    }
    
    func setupSuccess() {
        view.addSubview(successView)
        successView.translatesAutoresizingMaskIntoConstraints = false
        successView.isUserInteractionEnabled = true
        successView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        successView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        successView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        successView.heightAnchor.constraint(equalTo: self.view.heightAnchor, constant: 0).isActive = true
        successView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: 0).isActive = true
        successView.button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        successView.closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        successView.roleLabel.text = formatMoney(input: self.amount)
        if (self.note == "") {
            successView.memoLabel.text = "Không có nội dung"
        } else {
            successView.memoLabel.text = self.note
        }
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: successView.button.bottomAnchor, constant: 10).isActive = true
        self.updateViewConstraints()
        self.view.layoutIfNeeded()
        self.panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .shortForm)
        
    }
    
    func toastMessError(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    var panScrollable: UIScrollView? {
        return nil
    }

    var longFormHeight: PanModalHeight {
        return .intrinsicHeight
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
    
    let atmView : UIView = {
        
    }()
    
    let detailView : UIView = {
          let detailView  = UIView()
          detailView.translatesAutoresizingMaskIntoConstraints = false
          return detailView
      }()
      
      let tableView : UITableView = {
          let tableView = UITableView()
          tableView.translatesAutoresizingMaskIntoConstraints = false
          tableView.backgroundColor = .red
          tableView.separatorStyle = .none
          
          return tableView
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
           let image = UIImage(named: "ptBank", in: resourceBundle, compatibleWith: nil)
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
    
}


