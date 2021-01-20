import UIKit

class ListItem: UITableViewCell {

    let logLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    func setupCell() {
        self.contentView.addSubview(logLabel)
        logLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        logLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        logLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        logLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
    }

}

class ModalController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var logListData: [String] = Log.custom.logList
    
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
    let logContainer: UITableView = {
        let view = UITableView()
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let clearButton: UIButton = {
        let button = UIButton()
        button.setTitle("Clear", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.black
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(logLabel)
        self.view.addSubview(closeButton)
        self.view.addSubview(logContainer)
        self.view.addSubview(clearButton)
        
        logLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50).isActive = true
        logLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        closeButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50).isActive = true
        closeButton.addTarget(self, action: #selector(onPressClose), for: .touchUpInside)
        
        logContainer.topAnchor.constraint(equalTo: logLabel.bottomAnchor, constant: 20).isActive = true
        logContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        logContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        logContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50).isActive = true
        
        clearButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        clearButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        clearButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50).isActive = true
        clearButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        clearButton.addTarget(self, action: #selector(onPressClear), for: .touchUpInside)
        
        logContainer.dataSource = self
        logContainer.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ((logListData.count - 1) > 0) {
            logContainer.scrollToRow(at: IndexPath(row: logListData.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
            
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logListData.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ListItem()
        cell.setupCell()
        cell.logLabel.text = logListData[indexPath.row]
        if (indexPath.row == logListData.count - 1) {
            cell.backgroundColor = .lightGray
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIPasteboard.general.string = logListData[indexPath.row]
        let alert = UIAlertController(title: "Copy", message: "Copied to clipboard", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func onPressClose(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onPressClear(){
        Log.custom.clear()
        self.logListData = []
        DispatchQueue.main.async{
            self.logContainer.reloadData()
        }
    }
}
