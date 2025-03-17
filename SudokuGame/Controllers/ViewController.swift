import UIKit

class ViewController: UIViewController {
    // MARK: - UI Components
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "background_image")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let logoImageView1: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "sudoku1")
        imageView.layer.cornerRadius = 10
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 15
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#4B01B2")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        view.backgroundColor = #colorLiteral(red: 0.9951923077, green: 0.9903846154, blue: 1, alpha: 1)

        // Disable the default navigation back button
        self.navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    // MARK: - Private Methods
    private func createButton(title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = color
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(headerView)
        view.addSubview(buttonStack)
        view.addSubview(logoImageView1)
        view.addSubview(activityIndicator)

        // Create a custom back button
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.setTitle("Back", for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        // Add the button to the navigation bar
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backBarButtonItem

        // Add other buttons to the stack
        let startButton = createButton(title: "START GAME", color: #colorLiteral(red: 0.2964565456, green: 0.1093532816, blue: 0.6993825436, alpha: 1))
        let tipsButton = createButton(title: "TIPS", color: #colorLiteral(red: 0.2964565456, green: 0.1093532816, blue: 0.6993825436, alpha: 1))

        [startButton, tipsButton].forEach {
            buttonStack.addArrangedSubview($0)
        }

        setupConstraints()
    }

    private func setupConstraints() {
        let screenSize = UIScreen.main.bounds.size
        let headerHeight: CGFloat = screenSize.height * 0.11
        let logoSize: CGFloat = screenSize.width * 0.8
        let buttonHeight: CGFloat = 50

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: headerHeight),

            logoImageView1.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            logoImageView1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView1.widthAnchor.constraint(equalToConstant: logoSize),
            logoImageView1.heightAnchor.constraint(equalToConstant: logoSize),

            buttonStack.topAnchor.constraint(equalTo: logoImageView1.bottomAnchor, constant: 40),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: screenSize.width * 0.1),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -screenSize.width * 0.1),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // Set button heights
        buttonStack.arrangedSubviews.forEach { button in
            button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        }
    }

    private func setupActions() {
        for case let button as UIButton in buttonStack.arrangedSubviews {
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }
        handleButtonTap(withTitle: title)
    }

    private func handleButtonTap(withTitle title: String) {
        switch title {
        case "START GAME":
            showDifficultyPopup()
        case "TIPS":
            showTips()
        default:
            break
        }
    }

    private func showTips() {
        navigateToTips()
    }

    @objc private func backButtonTapped() {
        // Pop the current view controller
        self.navigationController?.popViewController(animated: true)
    }

    internal func showLoader() {
        activityIndicator.startAnimating()
    }

    internal func hideLoader() {
        activityIndicator.stopAnimating()
    }

    private func showNetworkErrorAlert() {
        let alert = UIAlertController(
            title: "No Internet Connection",
            message: "Please check your network settings and try again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showDifficultyPopup() {
        // Create overlay view
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        
        // Add constraints to cover the entire screen
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Create the popup
        let popup = DifficultyPopupView()
        popup.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popup)
        
        // Constraints for the popup
        NSLayoutConstraint.activate([
            popup.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popup.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            popup.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            popup.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])
        
        // Handle difficulty selection
        popup.onDifficultySelected = { [weak self] difficulty in
            guard let self = self else { return }
            
            overlayView.removeFromSuperview()
            popup.removeFromSuperview()
            
            self.navigateToSudoku(difficulty: difficulty) // Pass selected difficulty to the next screen
        }
        
        // Handle cancel
        popup.onCancel = {
            overlayView.removeFromSuperview()
            popup.removeFromSuperview()
        }
        
        // Add animation for overlay and popup
        overlayView.alpha = 0
        popup.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        popup.alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            overlayView.alpha = 1 // Fade in overlay
            popup.transform = .identity // Scale popup to normal size
            popup.alpha = 1 // Fade in popup
        }
    }

    func navigateToTips() {
        let tipsVC = SudokuTipsViewController()
        navigationController?.pushViewController(tipsVC, animated: true)
    }
    //Navigate to the Sudoku start VC
    private func navigateToSudoku(difficulty: String) {
        let sudokuVC = SudokuStartVC()
        sudokuVC.selectedDifficulty = difficulty //Set difficulty
        navigationController?.pushViewController(sudokuVC, animated: true)
    }

}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }

        assert(hexFormatted.count == 6, "Invalid hex code used.")

        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
