import UIKit

class ListItem: UITableViewCell {

    let logLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setupCell() {
        self.contentView.addSubview(logLabel)
        logLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        logLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
    }

}

class ModalController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var logListData = ["1", "2", "3", "4", "5", "6"]
    
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
        
        logContainer.dataSource = self
        logContainer.delegate = self
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
        return cell
    }
    
    @objc func onPressClose(){
        self.dismiss(animated: true, completion: nil)
    }
}
