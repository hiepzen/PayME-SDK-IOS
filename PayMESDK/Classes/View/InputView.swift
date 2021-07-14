enum InputState {
    case focus
    case error
    case normal
}
class InputView: UIView {
    var title: String = ""
    var placeholder: String = ""
    var keyboardType: UIKeyboardType = .default
    var errorMessage: String = ""

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(165, 174, 184)
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    let extraLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(11, 11, 11)
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    let extraImage: UIImageView = {
        var image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()

    let textInput: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .systemFont(ofSize: 16, weight: .medium)
        textField.textColor = UIColor(11, 11, 11)
        return textField
    }()

    init(title: String, placeholder: String = "", keyboardType: UIKeyboardType = .default, state: InputState = .normal){
        self.title = title
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        super.init(frame: CGRect.zero)
        setupUI()
        updateState(state: state)
    }

    func setupUI(){
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 13
        layer.borderWidth = 1
        titleLabel.text = title
        textInput.placeholder = placeholder
        textInput.keyboardType = keyboardType

        addSubview(titleLabel)
        addSubview(textInput)
        addSubview(extraLabel)
        addSubview(extraImage)
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true

        textInput.heightAnchor.constraint(equalToConstant: 30).isActive = true
        textInput.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        textInput.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        textInput.trailingAnchor.constraint(equalTo: extraImage.trailingAnchor, constant: -8).isActive = true

        extraLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        extraLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 4).isActive = true
        extraLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true

        extraImage.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        extraImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        extraImage.heightAnchor.constraint(equalToConstant: 20).isActive = true
        extraImage.widthAnchor.constraint(equalToConstant: 30).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateState(state: InputState = .normal) {
        switch state {
        case .error:
            layer.borderColor = UIColor.red.cgColor
            backgroundColor = .white
            titleLabel.text = errorMessage
            titleLabel.textColor = .red
            break
        case .focus:
            layer.borderColor = UIColor(0, 190, 0).cgColor
            backgroundColor = .white
            titleLabel.text = title
            titleLabel.textColor = UIColor(165, 174, 184)
        default:
            layer.borderColor = UIColor(239, 242, 247).cgColor
            backgroundColor = UIColor(239, 242, 247)
            titleLabel.text = title
            titleLabel.textColor = UIColor(165, 174, 184)
        }
    }

    func updateExtraInfo(data: String = ""){
        extraImage.isHidden = true
        extraLabel.isHidden = false
        extraLabel.text = data
    }
    func updateExtraInfo(image: UIImage? = nil, url: String = "") {
        extraLabel.isHidden = true
        extraImage.isHidden = false
        if image != nil {
            extraImage.image = image!
            return
        }
        if url != "" {
            extraImage.load(url: url)
        }
    }
    func resetExtraInfo() {
        extraLabel.text = ""
        extraImage.image = nil
        extraLabel.isHidden = true
        extraImage.isHidden = true
    }
}

