import UIKit

class PointsScreen: UIViewController {
    var gameResult: GameResult?
    var elapsedTime: String = "00:00:00"
    var undoCount: Int = 0
    var redoCount: Int = 0
    var hintsUsed: Int = 0
    var wrongEntryCount: Int = 0
    var selectedDifficulty: String = "Medium"
    var points: Int = 110
    var timeBonus: Int = 0
    var starIcon: UIImageView!
    var totalPoints: Int = 0
    var totalPointsLabel: UILabel!
    
    private var bestTimeLabel: UILabel!
    private var bestTimeView: UIView!
    
    var shouldShowStreakCelebration: Bool = false
    
    var cardView: UIView!
    
    var sudokuLabel: UILabel!
    
    private let progressBar: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.progressTintColor = UIColor(red: 19/255, green: 224/255, blue: 139/255, alpha: 1.0)
        progress.trackTintColor = .gray
        progress.progress = 0.0
        progress.layer.cornerRadius = 10
        progress.clipsToBounds = true
        return progress
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        setupViews()
        fetchGameResult()
        let score = Float(points) / 100.0
        progressBar.progress = score
        NotificationCenter.default.addObserver(self, selector: #selector(updateBackgroundImage), name: NSNotification.Name("BackgroundImageChanged"), object: nil)
        if shouldShowStreakCelebration {
            showStreakCelebration()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(resumeStarAnimation), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    @objc func resumeStarAnimation() {
        startRotatingStar(starIcon)
    }
    
    private func showStreakCelebration() {
        print("🎊 Showing Streak Celebration!")
        
        let celebrationView = StreakCelebrationView(frame: view.bounds)
        view.addSubview(celebrationView)
    }
    
    private func fetchGameResult() {
        guard let url = URL(string: APIEndpoints.results) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let gameResult = try JSONDecoder().decode(GameResult.self, from: data)
                DispatchQueue.main.async {
                    self.updateUI(with: gameResult, difficulty: self.selectedDifficulty)
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }
        
        task.resume()
    }
    
    private func updateUI(with gameResult: GameResult, difficulty: String) {
        let bestTimeForDifficulty = gameResult.categoryStats
            .first { $0.category.lowercased() == difficulty.lowercased() }?.bestTime ?? 0
        let formattedTime = formatTime(seconds: bestTimeForDifficulty)
        bestTimeLabel?.text = formattedTime
        self.totalPointsLabel.text = "\(gameResult.grandTotalPoints)"

        if let bestTimeLabel = bestTimeView?.subviews
            .compactMap({ ($0 as? UIStackView)?.arrangedSubviews.last as? UILabel })
            .first {
            bestTimeLabel.text = formattedTime
        } else {
            print("⚠️ bestTimeLabel not found in bestTimeView (Check createInfoLabel)")
        }
    }

    private func formatTime(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRotatingStar(starIcon)
    }
    
    @objc private func updateBackgroundImage() {
        if let imageData = UserDefaults.standard.data(forKey: "selectedBackgroundImage"),
           let newImage = UIImage(data: imageData) {
            backgroundImageView.image = newImage
        }
    }
    
    private func setupViews() {
        view.addSubview(backgroundImageView)

        if let filePath = UserDefaults.standard.string(forKey: "selectedBackgroundImagePath") {
            let fileURL = URL(fileURLWithPath: filePath)
            
            if let imageData = try? Data(contentsOf: fileURL),
               let savedImage = UIImage(data: imageData) {
                backgroundImageView.image = savedImage
                print("✅ Loaded background image from:", filePath)
            } else {
                print("❌ Failed to load background image, using default")
                backgroundImageView.image = UIImage(named: "Bamboo Zen")
            }
        } else {
            print("ℹ️ No saved background image found, using default")
            backgroundImageView.image = UIImage(named: "Bamboo Zen")
        }
        
        sudokuLabel = createLabel(text: "SUDOKU", fontSize: 40, weight: .bold)
        view.addSubview(sudokuLabel)
        
        cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 15
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.2
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        view.addSubview(cardView)
        
        starIcon = UIImageView(image: UIImage(named: "star.fill")?.withRenderingMode(.alwaysTemplate))
        starIcon.translatesAutoresizingMaskIntoConstraints = false
        starIcon.tintColor = UIColor(red: 19/255, green: 224/255, blue: 139/255, alpha: 1.0)
        starIcon.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate([
            starIcon.widthAnchor.constraint(equalToConstant: 50),
            starIcon.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        let pointsLabel = UILabel()
        pointsLabel.translatesAutoresizingMaskIntoConstraints = false
        pointsLabel.textColor = UIColor(red: 19/255, green: 224/255, blue: 139/255, alpha: 1.0)
        
        let pointsText = "\(points)"
        let ptsText = " PTS"
        let fullText = pointsText + ptsText
        
        let attributedText = NSMutableAttributedString(string: fullText)
        attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 30, weight: .regular), range: NSRange(location: 0, length: pointsText.count))
        attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .regular), range: NSRange(location: pointsText.count, length: ptsText.count))
        
        pointsLabel.attributedText = attributedText
        
        NSLayoutConstraint.activate([
            pointsLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let starStack = UIStackView(arrangedSubviews: [starIcon, pointsLabel])
        starStack.translatesAutoresizingMaskIntoConstraints = false
        starStack.axis = .horizontal
        starStack.alignment = .center
        
        starIcon.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        starIcon.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        let totalScoreLabel = createLabel(text: "TOTAL SCORE :", fontSize: 20, weight: .regular)
        totalScoreLabel.textColor = UIColor(red: 19/255, green: 224/255, blue: 139/255, alpha: 1.0)
        
        totalPointsLabel = createLabel(text: "\(totalPoints)", fontSize: 22, weight: .regular)
        totalPointsLabel.textColor = UIColor(red: 19/255, green: 224/255, blue: 139/255, alpha: 1.0)
        
        let totalStack = UIStackView(arrangedSubviews: [totalScoreLabel, totalPointsLabel])
        totalStack.translatesAutoresizingMaskIntoConstraints = false
        totalStack.axis = .horizontal
        totalStack.spacing = 8
        totalStack.alignment = .center
        
        let difficultyLabel = createLabel(text: selectedDifficulty, fontSize: 20, weight: .regular)
        difficultyLabel.textColor = UIColor(red: 19/255, green: 224/255, blue: 139/255, alpha: 1.0)
        
        let timeBonusLabel = createInfoLabel(title: "TIME BONUS",value: "+\(timeBonus) PTS", fontSize: 18, index: 0)
        let hintsLabel = createInfoLabel(title: "HINTS", value: "-\(hintsUsed) PTS", fontSize: 18, index: 1)
        let mistakesLabel = createInfoLabel(title: "MISTAKES", value: "-\(wrongEntryCount) PTS", fontSize: 18, index: 2)
        let undoLabel = createInfoLabel(title: "UNDO", value: "-\(undoCount) PTS", fontSize: 18, index: 3)
        let redoLabel = createInfoLabel(title: "REDO", value: "-\(redoCount) PTS", fontSize: 18, index: 4)
        let timeLabel = createInfoLabel(title: "TIME", value: elapsedTime, fontSize: 18, index: 5)
        bestTimeView = createInfoLabel(title: "BEST TIME", value: "0", fontSize: 18, index: 6)
        if let label = bestTimeView.subviews
            .compactMap({ ($0 as? UIStackView)?.arrangedSubviews.last as? UILabel })
            .first {
            bestTimeLabel = label
        } else {
            print("⚠️ bestTimeLabel not found in bestTimeView (Check createInfoLabel)")
        }
        
        let labelsStack = UIStackView(arrangedSubviews: [
            timeBonusLabel, hintsLabel, mistakesLabel, undoLabel, redoLabel, timeLabel, bestTimeView
        ])
        labelsStack.translatesAutoresizingMaskIntoConstraints = false
        labelsStack.axis = .vertical
        labelsStack.spacing = 8
        labelsStack.alignment = .fill
        labelsStack.distribution = .fillEqually
        
        cardView.addSubview(starStack)
        view.layoutIfNeeded()
        startRotatingStar(starIcon)
        cardView.addSubview(totalStack)
        cardView.addSubview(difficultyLabel)
        cardView.addSubview(progressBar)
        cardView.addSubview(labelsStack)

         let newGameButton = createButton(title: "NEW GAME")
         let exitButton = createButton(title: "EXIT")
         let streakButton = createButton(title: "🔥 STREAK")

         let shareContainer = UIView()
         shareContainer.translatesAutoresizingMaskIntoConstraints = false
         shareContainer.backgroundColor = UIColor.black.withAlphaComponent(0.7)
         shareContainer.layer.cornerRadius = 10
         shareContainer.clipsToBounds = true

         let shareButton = UIImageView(image: UIImage(named: "share")?.withRenderingMode(.alwaysTemplate)) 
         shareButton.tintColor = .white
         shareButton.isUserInteractionEnabled = true
         shareButton.translatesAutoresizingMaskIntoConstraints = false
         shareButton.contentMode = .scaleAspectFit
         let shareTapGesture = UITapGestureRecognizer(target: self, action: #selector(shareTapped))
         shareButton.addGestureRecognizer(shareTapGesture)
         shareContainer.addSubview(shareButton)

         let gameExitStack = UIStackView(arrangedSubviews: [newGameButton, exitButton])
         gameExitStack.translatesAutoresizingMaskIntoConstraints = false
         gameExitStack.axis = .horizontal
         gameExitStack.spacing = 15
         gameExitStack.alignment = .fill
         gameExitStack.distribution = .fillProportionally

         newGameButton.widthAnchor.constraint(equalTo: exitButton.widthAnchor, multiplier: 1.8).isActive = true

         let buttonStack = UIStackView(arrangedSubviews: [gameExitStack])
         buttonStack.translatesAutoresizingMaskIntoConstraints = false
         buttonStack.axis = .vertical
         buttonStack.spacing = 10
         buttonStack.alignment = .fill
         buttonStack.distribution = .fillEqually

         view.addSubview(buttonStack)
         view.addSubview(streakButton)
         view.addSubview(shareContainer)

        NSLayoutConstraint.activate([
            
            newGameButton.heightAnchor.constraint(equalToConstant: 50),
            exitButton.heightAnchor.constraint(equalToConstant: 50),
            streakButton.heightAnchor.constraint(equalToConstant: 50),
            shareContainer.heightAnchor.constraint(equalToConstant: 50),

            newGameButton.widthAnchor.constraint(equalToConstant: 150),
            exitButton.widthAnchor.constraint(equalToConstant: 80),

            streakButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
            shareContainer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15),

            shareButton.centerXAnchor.constraint(equalTo: shareContainer.centerXAnchor),
            shareButton.centerYAnchor.constraint(equalTo: shareContainer.centerYAnchor),
            shareButton.widthAnchor.constraint(equalTo: shareContainer.widthAnchor, multiplier: 0.6),
            shareButton.heightAnchor.constraint(equalTo: shareContainer.heightAnchor, multiplier: 0.6),

            buttonStack.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: view.bounds.height * 0.03),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.width * 0.05),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.bounds.width * 0.05),

            streakButton.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: view.bounds.height * 0.015),
            streakButton.centerXAnchor.constraint(equalTo: buttonStack.centerXAnchor, constant: -view.bounds.width * 0.12),

            shareContainer.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: view.bounds.height * 0.015),
            shareContainer.leadingAnchor.constraint(equalTo: streakButton.trailingAnchor, constant: view.bounds.width * 0.04),

            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            sudokuLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sudokuLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height * 0.1),

            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.topAnchor.constraint(equalTo: sudokuLabel.bottomAnchor, constant: view.bounds.height * 0.025),
            cardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.62),
            cardView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),

            starStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: view.bounds.height * 0.025),
            starStack.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            totalStack.topAnchor.constraint(equalTo: starStack.bottomAnchor, constant: view.bounds.height * 0.007),
            totalStack.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            difficultyLabel.topAnchor.constraint(equalTo: totalStack.bottomAnchor, constant: view.bounds.height * 0.01),
            difficultyLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            progressBar.topAnchor.constraint(equalTo: difficultyLabel.bottomAnchor, constant: view.bounds.height * 0.015),
            progressBar.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            progressBar.widthAnchor.constraint(equalTo: cardView.widthAnchor, multiplier: 0.8),
            progressBar.heightAnchor.constraint(equalToConstant: 20),

            labelsStack.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: view.bounds.height * 0.03),
            labelsStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: view.bounds.width * 0.05),
            labelsStack.widthAnchor.constraint(equalTo: cardView.widthAnchor, multiplier: 0.9),
            labelsStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -view.bounds.height * 0.025)
        ])

    }
    
    private func createImageView(named imageName: String, contentMode: UIView.ContentMode) -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = contentMode
        return imageView
    }
    
    private func createLabel(text: String, fontSize: CGFloat, weight: UIFont.Weight) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.textAlignment = .center
        return label
    }
    
    private func startRotatingStar(_ imageView: UIImageView) {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = 3
        rotation.repeatCount = .infinity
        imageView.layer.add(rotation, forKey: "rotateAnimation")
    }
    
    private func createInfoLabel(title: String, value: String, fontSize: CGFloat, index: Int) -> UIView {
        let lightGrayColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1.0)
        let veryLightGrayColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = index % 2 == 0 ? veryLightGrayColor : lightGrayColor
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .light)
        titleLabel.textAlignment = .left
        
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.textColor = .black
        valueLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .light)
        valueLabel.textAlignment = .right
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
        
        return containerView
    }
    
    private func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        if sender.currentTitle == "NEW GAME" {
            let dif = DifficultyPopupViewController()
            dif.modalPresentationStyle = .overCurrentContext
            dif.modalTransitionStyle = .crossDissolve
            self.present(dif, animated: true, completion: {
                print("Difficulty Popup Presented")
            })
        } else if sender.currentTitle == "EXIT" {
     
            if let filePath = UserDefaults.standard.string(forKey: "selectedBackgroundImagePath") {
                let fileURL = URL(fileURLWithPath: filePath)
                do {
                    try FileManager.default.removeItem(at: fileURL)
                    print("🗑️ Background image file deleted successfully")
                } catch {
                    print("❌ Error deleting background image file:", error)
                }
            }

            UserDefaults.standard.removeObject(forKey: "selectedBackgroundImage")
            UserDefaults.standard.removeObject(forKey: "selectedBackgroundImagePath")
            UserDefaults.standard.removeObject(forKey: "selectedGridColor")
            UserDefaults.standard.synchronize()

            let customVC = CustomViewController()
            if let navController = navigationController {
                navController.pushViewController(customVC, animated: true)
            }
        }else if sender.currentTitle == "🔥 STREAK" {
            let streakPopupVC = StreakPopupViewController()
            streakPopupVC.modalPresentationStyle = .overFullScreen
            present(streakPopupVC, animated: true, completion: nil)
        }
    }

    @objc func shareTapped() {
        guard let image = generateSudokuShareImage(level: selectedDifficulty, score: points, timeTaken: elapsedTime),
              let imageURL = saveImageToAppGroupContainer(image: image) else {
            print("Failed to generate or save image.")
            return
        }

        let activityVC = UIActivityViewController(activityItems: [imageURL], applicationActivities: nil)
        present(activityVC, animated: true)
    }

    func generateSudokuShareImage(level: String, score: Int, timeTaken: String) -> UIImage? {
        let canvasSize = CGSize(width: 300, height: 380)
        let renderer = UIGraphicsImageRenderer(size: canvasSize)

        let image = renderer.image { context in
 
            if let background = UIImage(named: "app") {
                background.draw(in: CGRect(origin: .zero, size: canvasSize))
            }

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 26),
                .foregroundColor: UIColor.white
            ]

            let subtitleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18),
                .foregroundColor: UIColor.white
            ]

            let infoAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.white
            ]

            var yOffset: CGFloat = 20

            let title = "Sudoku"
            let titleSize = title.size(withAttributes: titleAttributes)
            title.draw(at: CGPoint(x: (canvasSize.width - titleSize.width) / 2, y: yOffset), withAttributes: titleAttributes)
            yOffset += titleSize.height + 10

            if let winnerImage = UIImage(named: "winner") {
                let imageSize = CGSize(width: 80, height: 80)
                let imageOrigin = CGPoint(x: (canvasSize.width - imageSize.width) / 2, y: yOffset)
                winnerImage.draw(in: CGRect(origin: imageOrigin, size: imageSize))
                yOffset += imageSize.height + 10
            }

            let congrats = "Congratulations!"
            let congratsSize = congrats.size(withAttributes: subtitleAttributes)
            congrats.draw(at: CGPoint(x: (canvasSize.width - congratsSize.width) / 2, y: yOffset), withAttributes: subtitleAttributes)
            yOffset += congratsSize.height + 8

            let solvedText = "You solved this puzzle!"
            let solvedSize = solvedText.size(withAttributes: subtitleAttributes)
            solvedText.draw(at: CGPoint(x: (canvasSize.width - solvedSize.width) / 2, y: yOffset), withAttributes: subtitleAttributes)
            yOffset += solvedSize.height + 16

            let levelText = "Level: \(level)"
            let levelSize = levelText.size(withAttributes: infoAttributes)
            levelText.draw(at: CGPoint(x: (canvasSize.width - levelSize.width) / 2, y: yOffset), withAttributes: infoAttributes)
            yOffset += levelSize.height + 10

            let scoreText = "Score: \(score)"
            let scoreSize = scoreText.size(withAttributes: infoAttributes)
            scoreText.draw(at: CGPoint(x: (canvasSize.width - scoreSize.width) / 2, y: yOffset), withAttributes: infoAttributes)
            yOffset += scoreSize.height + 10

            let timeText = "Time Taken: \(timeTaken)"
            let timeSize = timeText.size(withAttributes: infoAttributes)
            timeText.draw(at: CGPoint(x: (canvasSize.width - timeSize.width) / 2, y: yOffset), withAttributes: infoAttributes)
        }

        return image
    }

    func saveImageToAppGroupContainer(image: UIImage) -> URL? {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return nil }
        
        let fileManager = FileManager.default
        guard let sharedContainerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.cykul.SudokuNew") else {
            print("❌ Could not get App Group container URL.")
            return nil
        }
        
        let imageURL = sharedContainerURL.appendingPathComponent("sudoku_result.jpg")
        do {
            if fileManager.fileExists(atPath: imageURL.path) {
                try fileManager.removeItem(at: imageURL)
            }
            try imageData.write(to: imageURL)
            print("✅ Image saved at:", imageURL.path)
            return imageURL
        } catch {
            print("❌ Failed to save image:", error)
            return nil
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
