//
//  Methods.swift
//  PayMESDK
//
//  Created by HuyOpen on 10/28/20.
//

import UIKit

class Methods: UIViewController, PanModalPresentable, UITableViewDelegate,  UITableViewDataSource {
    
    var data : [MethodInfo] = [
        MethodInfo(amount: 0, bankCode: "ABC", cardNumber: "def", detail: "", linkedId: "", swiftCode: "", type: "AppWallet", active: false),
        MethodInfo(amount: 0, bankCode: "ABC", cardNumber: "def", detail: "", linkedId: "", swiftCode: "", type: "AppWallet", active: false)
    ]
    var active = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(button)
        view.addSubview(closeButton)
        view.addSubview(txtLabel)
        view.addSubview(detailView)
        view.addSubview(methodTitle)
        view.addSubview(tableView)
        detailView.addSubview(price)
        detailView.backgroundColor = UIColor(8,148,31)
        detailView.addSubview(contentLabel)
        detailView.addSubview(memoLabel)
        txtLabel.text = "Xác nhận thanh toán"
        price.text = "\(PayME.amount) đ"
        contentLabel.text = "Nội dung"
        memoLabel.text = "Merchant ghi chú đơn hàng"
        methodTitle.text = "Chọn nguồn thanh toán"
        button.setTitle("Xác nhận", for: .normal)
        setupConstraints()
        tableView.register(Method.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        PayME.getTransferMethods(onSuccess: {response in
            // Update UI
            let items = response["items"]! as! [[String:AnyObject]]
            var responseData : [MethodInfo] = []
            for i in 0..<items.count {
                print(items)
                if (i == 0) {
                    var temp = MethodInfo(amount: items[i]["amount"] as? Int, bankCode: items[i]["bankCode"] as? String, cardNumber: items[i]["cardNumber"] as? String, detail: items[i]["detail"] as? String, linkedId: items[i]["linkedId"] as? String, swiftCode: items[i]["swiftCode"] as? String, type: items[i]["type"] as! String, active: true)
                    responseData.append(temp)
                } else {
                    var temp = MethodInfo(amount: items[i]["amount"] as? Int, bankCode: items[i]["bankCode"] as? String, cardNumber: items[i]["cardNumber"] as? String, detail: items[i]["detail"] as? String, linkedId: items[i]["linkedId"] as? String, swiftCode: items[i]["swiftCode"] as? String, type: items[i]["type"] as! String, active: false)
                    responseData.append(temp)
                }
            }
   
             DispatchQueue.main.async {
                self.data = responseData
                self.tableView.reloadData()
                self.viewDidLayoutSubviews()

                self.panModalSetNeedsLayoutUpdate()


             }
            
        },
                                 
         onError: {a in})
    }
    
    var longFormHeight: PanModalHeight {
        return .intrinsicHeight
    }

    var anchorModalToLongForm: Bool {
        return false
    }

    var shouldRoundTopCorners: Bool {
        return true
    }
    
    func setupConstraints() {
        detailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        detailView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        detailView.heightAnchor.constraint(equalToConstant: 118.0).isActive = true
        detailView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        detailView.topAnchor.constraint(equalTo: txtLabel.bottomAnchor, constant: 16.0).isActive = true
        
        price.topAnchor.constraint(equalTo: detailView.topAnchor, constant: 15).isActive = true
        price.centerXAnchor.constraint(equalTo: detailView.centerXAnchor).isActive = true
        
        contentLabel.bottomAnchor.constraint(equalTo: detailView.bottomAnchor, constant: -20).isActive = true
        contentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        
        memoLabel.bottomAnchor.constraint(equalTo: detailView.bottomAnchor, constant: -20).isActive = true
        memoLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentLabel.leadingAnchor, constant: 30).isActive = true
        memoLabel.trailingAnchor.constraint(equalTo: detailView.trailingAnchor, constant: -30).isActive = true
        
        methodTitle.topAnchor.constraint(equalTo: detailView.bottomAnchor, constant: 10).isActive = true
        methodTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        
        txtLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 19).isActive = true
        txtLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        /*
        tableView.topAnchor.constraint(equalTo: methodTitle.topAnchor, constant: 10).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        */

        tableView.topAnchor.constraint(equalTo: methodTitle.bottomAnchor, constant: 10).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 108.0
        tableView.alwaysBounceVertical = false

        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 19).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        button.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        button.addTarget(self, action: #selector(payAction), for: .touchUpInside)
        
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        bottomLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: button.bottomAnchor, constant: 10).isActive = true
        
        
    }
    
    override func viewDidLayoutSubviews() {
        print("Test update layout")
        let topPoint = CGPoint(x: detailView.frame.minX+10, y: detailView.bounds.midY + 15)
        let bottomPoint = CGPoint(x: detailView.frame.maxX-10, y: detailView.bounds.midY + 15)
        detailView.createDashedLine(from: topPoint, to: bottomPoint, color: UIColor(203,203,203), strokeLength: 3, gapLength: 4, width: 0.5)
        tableView.heightAnchor.constraint(equalToConstant: tableView.contentSize.height).isActive = true
        
        
    }
    
    @objc
    func closeAction(button:UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc
    func payAction(button:UIButton)
    {
        if(data[active].type == "AppWallet") {
          print("Hello")
            PayME.postTransferAppWallet(
            onSuccess:{a in
                self.dismiss(animated: true)
                PayME.currentVC!.presentPanModal(Success())
            },
            onError: {b in
                print(b)
                self.dismiss(animated: true)
                PayME.currentVC!.presentPanModal(Failed())

                print("Ok1")
                
            })
        } else {
            print("Halo")
        }
    }
    
    
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
        button.backgroundColor = UIColor(8,148,31)
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        for i in 0..<data.count {
            if (i == indexPath.row) {
                data[i].active = true
            } else {
                data[i].active = false
            }
        }
        self.active = indexPath.row
        tableView.reloadData()
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    var panScrollable: UIScrollView? {
        return nil
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
}
extension Methods{
    func numberOfSectionsInTableView(_tableView: UITableView) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? Method
            else { return UITableViewCell() }
        cell.configure(with: data[indexPath.row])

        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    
    
    
}


