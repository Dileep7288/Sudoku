import UIKit

class CustomViewController: UIViewController, ThemesPopupDelegate {
    func updateGridBackgroundColor(to color: UIColor) {}

    var backGroundimage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //print("🔍 UserDefaults Data Before Fetching Puzzle: \(UserDefaults.standard.dictionaryRepresentation())")
        self.navigationItem.hidesBackButton = true
        setupBackgroundImage()
        setupButtons()
    }

    private func setupBackgroundImage() {
        backGroundimage = UIImageView()
        backGroundimage.translatesAutoresizingMaskIntoConstraints = false
        backGroundimage.image = UIImage(named: "Bamboo Zen")
        backGroundimage.contentMode = .scaleToFill
        view.addSubview(backGroundimage)

        NSLayoutConstraint.activate([
            backGroundimage.topAnchor.constraint(equalTo: view.topAnchor),
            backGroundimage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backGroundimage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backGroundimage.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupButtons() {
        let button1 = createButton(title: "START GAME", action: #selector(startGameTapped))
        let button2 = createButton(title: "TIPS", action: #selector(tipsTapped))
        let button3 = createButton(title: "THEMES", action: #selector(themesSelected))
        let button4 = createButton(title: "SCORE BOARD", action: #selector(scoreSelected))

        let stackView = UIStackView(arrangedSubviews: [button1, button2, button3, button4])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        applyButtonConstraints(button1)
        applyButtonConstraints(button2)
        applyButtonConstraints(button3)
        applyButtonConstraints(button4)
    }

    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func applyButtonConstraints(_ button: UIButton) {
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func startGameTapped() {
        let popupVC = DifficultyPopupViewController()
        popupVC.modalPresentationStyle = .overFullScreen
        popupVC.modalTransitionStyle = .crossDissolve
        present(popupVC, animated: true, completion: nil)
    }

    @objc private func tipsTapped() {
        let tips = SudokuTipsViewController()
        navigationController?.pushViewController(tips, animated: true)
    }

    @objc private func themesSelected() {
        let popupVC = ThemesPopupViewController()
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overFullScreen
        popupVC.modalTransitionStyle = .crossDissolve
        present(popupVC, animated: true, completion: nil)
    }
    
    @objc private func scoreSelected() {
        let scoreVC = ScoreViewController()
        navigationController?.pushViewController(scoreVC, animated: true)
    }

    func updateBackgroundImage(with image: UIImage) {
        backGroundimage.image = image
    }
    
}

class DifficultyPopupViewController: UIViewController {
    
    let popupView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        resetIfNewDay()
        setupPopup()
    }

    private func setupPopup() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        popupView.backgroundColor = UIColor.white
        popupView.layer.cornerRadius = 12
        popupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupView)

        let titleLabel = UILabel()
        titleLabel.text = "Choose Difficulty"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(titleLabel)

        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(.black, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        closeButton.addTarget(self, action: #selector(closePopup), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(closeButton)

        let beginnerButton = createButton(title: "Beginner", action: #selector(difficultyTapped(_:)))
        let easyButton = createButton(title: "Easy", action: #selector(difficultyTapped(_:)))
        let mediumButton = createButton(title: "Medium", action: #selector(difficultyTapped(_:)))
        let hardButton = createButton(title: "Hard", action: #selector(difficultyTapped(_:)))
        let expertButton = createButton(title: "Expert", action: #selector(difficultyTapped(_:)))

        let stackView = UIStackView(arrangedSubviews: [beginnerButton, easyButton, mediumButton, hardButton, expertButton])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(stackView)

        NSLayoutConstraint.activate([
            popupView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popupView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            popupView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            popupView.heightAnchor.constraint(greaterThanOrEqualToConstant: 250),

            titleLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),

            closeButton.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -10),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),

            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -20)
        ])
    }

    private func createButton(title: String, action: Selector) -> UIButton {
        let button = GradientButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)

        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
        return button
    }
}

class GradientButton: UIButton {
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }

    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 5/255, green: 5/255, blue: 5/255, alpha: 0.65).cgColor,
            UIColor(red: 25/255, green: 93/255, blue: 222/255, alpha: 0.53).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradientLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let superview = superview else { return }
        
        gradientLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: superview.bounds.width - 40, 
            height: bounds.height
        )
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
    }
}

extension DifficultyPopupViewController {
    private func resetIfNewDay() {
        let lastPlayedDate = UserDefaults.standard.object(forKey: "LastPlayedDate") as? Date ?? Date.distantPast
        let currentDate = Date()
        let calendar = Calendar.current

        if !calendar.isDate(lastPlayedDate, inSameDayAs: currentDate) {
            UserDefaults.standard.removeObject(forKey: "PlayedDifficulties")
            UserDefaults.standard.set(Date(), forKey: "LastPlayedDate")
        }
    }

    @objc private func closePopup() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func difficultyTapped(_ sender: UIButton) {
        guard let difficulty = sender.titleLabel?.text else { return }

        let playedDifficulties = UserDefaults.standard.array(forKey: "PlayedDifficulties") as? [String] ?? []

        if playedDifficulties.contains(difficulty) {
            let alert = UIAlertController(
                title: "Already Played",
                message: "You have already played \(difficulty). You cannot play the same difficulty again.",
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        } else {
            var updatedDifficulties = playedDifficulties
            updatedDifficulties.append(difficulty)
            UserDefaults.standard.setValue(updatedDifficulties, forKey: "PlayedDifficulties")
            UserDefaults.standard.set(Date(), forKey: "LastPlayedDate")

            startSudokuGame(with: difficulty)
        }
    }

    private func startSudokuGame(with difficulty: String) {
        let sudokuVC = SudokuStartVC(difficulty: difficulty)
        let navController = UINavigationController(rootViewController: sudokuVC)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
}
