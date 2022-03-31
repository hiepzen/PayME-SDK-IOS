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
    var extraIcon: UIButton = UIButton(frame: .zero)
    var onPressIcon: () -> () = {}

    var extraImageTrailing: NSLayoutConstraint?

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

    init(title: String, placeholder: String = "", keyboardType: UIKeyboardType = .default, state: InputState = .normal,
         isAutoCapitalization: Bool = false, extraIcon: UIButton = UIButton(frame: CGRect.zero)) {
        self.title = title
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.extraIcon = extraIcon
        super.init(frame: CGRect.zero)
        setupUI()
        updateState(state: state)
        if isAutoCapitalization {
            textInput.autocapitalizationType = .allCharacters
        }
    }

    func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 13
        layer.borderWidth = 1
        titleLabel.text = title
        textInput.placeholder = placeholder
        textInput.keyboardType = keyboardType

        addSubview(titleLabel)
        addSubview(textInput)
        addSubview(extraIcon)
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

        extraIcon.translatesAutoresizingMaskIntoConstraints = false
        extraIcon.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        extraIcon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        extraIcon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        extraIcon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true

        extraImage.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        extraImageTrailing = extraImage.trailingAnchor.constraint(equalTo: extraIcon.leadingAnchor, constant: -12)
        extraImageTrailing?.isActive = true
        extraImage.heightAnchor.constraint(equalToConstant: 20).isActive = true
        extraImage.widthAnchor.constraint(equalToConstant: 30).isActive = true
        extraIcon.addTarget(self, action: #selector(onPressIconObjc), for: .touchUpInside)

        addDoneButtonOnKeyboard()
    }

    @objc private func onPressIconObjc() {
        onPressIcon()
    }

    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "done".localize(), style: .done, target: self, action: #selector(doneButtonAction))
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        textInput.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction() {
        textInput.resignFirstResponder()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateExtraIcon(iconImage: UIImage?, onPress: @escaping () -> () = {}) {
        extraIcon.setImage(iconImage, for: .normal)
        if (iconImage != nil) {
            extraIcon.isHidden = false
            extraImageTrailing?.isActive = false
            extraImageTrailing = extraImage.trailingAnchor.constraint(equalTo: extraIcon.leadingAnchor, constant: -12)
            extraImageTrailing?.isActive = true
            onPressIcon = onPress
        } else {
            extraIcon.isHidden = true
            extraImageTrailing?.isActive = false
            extraImageTrailing = extraImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
            extraImageTrailing?.isActive = true
        }
        updateConstraints()
        layoutIfNeeded()
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

    func updateExtraInfo(data: String = "") {
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

    func updateTitle(_ title: String) {
        titleLabel.text = title
        self.title = title
    }
}

