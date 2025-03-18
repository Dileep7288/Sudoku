import UIKit

class ScoreViewController: UIViewController {
    
    private var backGroundimage: UIImageView!
    private var scoreTitleLabel: UILabel!
    private var cardView: UIView!
    private var totalPointsLabel: UILabel!
    
    private var categoryLabels: [UILabel] = []
    private var bestTimeLabels: [UILabel] = []
    
    private var headerImageView: UIImageView!
    private var headerNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = UIColor(red: 229/255.0, green: 231/255.0, blue: 235/255.0, alpha: 1.0)
        setupBackgroundImage()
        setupUI()
        fetchGameResult()
        getProfileData()
        NotificationCenter.default.addObserver(self, selector: #selector(updateBackgroundImage), name: NSNotification.Name("BackgroundImageChanged"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadSavedBackgroundImage()
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
        loadSavedBackgroundImage()
    }
    
    private func loadSavedBackgroundImage() {
        if let filePath = UserDefaults.standard.string(forKey: "selectedBackgroundImagePath") {
            let fileURL = URL(fileURLWithPath: filePath)
            
            if let imageData = try? Data(contentsOf: fileURL),
               let savedImage = UIImage(data: imageData) {
                backGroundimage.image = savedImage
            } else {
                backGroundimage.image = UIImage(named: "Bamboo Zen")
            }
        } else {
            backGroundimage.image = UIImage(named: "Bamboo Zen")
        }
    }
    
    @objc private func updateBackgroundImage() {
        loadSavedBackgroundImage()
    }
    
    private func setupUI() {
        scoreTitleLabel = createLabel(text: "MY SCORE BOARD", fontSize: 28, weight: .bold)
        scoreTitleLabel.textAlignment = .center
        scoreTitleLabel.textColor = .black
        view.addSubview(scoreTitleLabel)

        cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)

        applyConstraints()
    }

    private func applyConstraints() {
        NSLayoutConstraint.activate([
            scoreTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            scoreTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.topAnchor.constraint(equalTo: scoreTitleLabel.bottomAnchor, constant: 20),
            cardView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)
        ])
    }

    private func createLabel(text: String, fontSize: CGFloat, weight: UIFont.Weight, textColor: UIColor = .black, alignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.textColor = textColor
        label.textAlignment = alignment
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func fetchGameResult() {
        guard let url = URL(string: APIEndpoints.results) else {
            print("Invalid API URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ Error fetching data: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No data received")
                return
            }

            do {
                let gameResult = try JSONDecoder().decode(GameResult.self, from: data)
                DispatchQueue.main.async {
                    self.updateUI(with: gameResult)
                }
            } catch {
                print("❌ JSON Decoding Failed:", error)
                self.showNoGameMessage()
            }
        }

        task.resume()
    }
    
    private func showNoGameMessage() {
        DispatchQueue.main.async {
            let noGameLabel = UILabel()
            noGameLabel.text = "You didn't play any game till now"
            noGameLabel.textColor = .gray
            noGameLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            noGameLabel.textAlignment = .center
            noGameLabel.translatesAutoresizingMaskIntoConstraints = false

            self.cardView.addSubview(noGameLabel)

            NSLayoutConstraint.activate([
                noGameLabel.centerXAnchor.constraint(equalTo: self.cardView.centerXAnchor),
                noGameLabel.centerYAnchor.constraint(equalTo: self.cardView.centerYAnchor)
            ])
        }
    }
    
    private func updateUI(with gameResult: GameResult) {
        categoryLabels.forEach { $0.removeFromSuperview() }
        bestTimeLabels.forEach { $0.removeFromSuperview() }
        totalPointsLabel?.removeFromSuperview()
        categoryLabels.removeAll()
        bestTimeLabels.removeAll()

        cardView.subviews.forEach { $0.removeFromSuperview() }

        let headerBar = UIView()
        headerBar.backgroundColor = UIColor(red: 80/255.0, green: 9/255.0, blue: 176/255.0, alpha: 1.0)
        headerBar.layer.cornerRadius = 12
        headerBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        headerBar.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(headerBar)

        headerImageView = UIImageView()
        headerImageView.contentMode = .scaleAspectFit
        headerImageView.translatesAutoresizingMaskIntoConstraints = false
        headerImageView.layer.cornerRadius = 20
        headerImageView.clipsToBounds = true
        headerBar.addSubview(headerImageView)

        headerNameLabel = createLabel(text: "", fontSize: 22, weight: .bold)
        headerNameLabel.textColor = .white
        headerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        headerBar.addSubview(headerNameLabel)

        NSLayoutConstraint.activate([
            headerBar.topAnchor.constraint(equalTo: cardView.topAnchor),
            headerBar.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            headerBar.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            headerBar.heightAnchor.constraint(equalToConstant: 80),
            
            headerImageView.leadingAnchor.constraint(equalTo: headerBar.leadingAnchor, constant: 15),
            headerImageView.centerYAnchor.constraint(equalTo: headerBar.centerYAnchor),
            headerImageView.widthAnchor.constraint(equalToConstant: 40),
            headerImageView.heightAnchor.constraint(equalToConstant: 40),
            
            headerNameLabel.leadingAnchor.constraint(equalTo: headerImageView.trailingAnchor, constant: 10),
            headerNameLabel.centerYAnchor.constraint(equalTo: headerBar.centerYAnchor),
            headerNameLabel.trailingAnchor.constraint(equalTo: headerBar.trailingAnchor, constant: -15)
        ])

        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.alignment = .fill
        mainStackView.spacing = 15
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: headerBar.bottomAnchor, constant: 10),
            mainStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            mainStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),
            mainStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20)
        ])

        let headerStackView = UIStackView()
        headerStackView.axis = .horizontal
        headerStackView.distribution = .fillEqually
        headerStackView.spacing = 10
        headerStackView.alignment = .center
        headerStackView.translatesAutoresizingMaskIntoConstraints = false

        let categoryHeaderLabel = createLabel(text: "Category", fontSize: 14, weight: .regular, textColor: .gray)
        let bestTimeHeaderLabel = createLabel(text: "Best Time", fontSize: 14, weight: .regular, textColor: .gray)
        let pointsHeaderLabel = createLabel(text: "Points", fontSize: 14, weight: .regular, textColor: .gray)

        categoryHeaderLabel.textAlignment = .center
        bestTimeHeaderLabel.textAlignment = .center
        pointsHeaderLabel.textAlignment = .center

        headerStackView.addArrangedSubview(categoryHeaderLabel)
        headerStackView.addArrangedSubview(bestTimeHeaderLabel)
        headerStackView.addArrangedSubview(pointsHeaderLabel)
        mainStackView.addArrangedSubview(headerStackView)

        let separatorLine = UIView()
        separatorLine.backgroundColor = .lightGray
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.addArrangedSubview(separatorLine)

        NSLayoutConstraint.activate([
            separatorLine.heightAnchor.constraint(equalToConstant: 1)
        ])

        for category in gameResult.categoryStats {
            let cardView = UIView()
            cardView.backgroundColor = UIColor(red: 240/255.0, green: 242/255.0, blue: 245/255.0, alpha: 1.0)
            cardView.layer.cornerRadius = 7
            cardView.layer.shadowColor = UIColor.black.cgColor
            cardView.layer.shadowOpacity = 0.1
            cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
            cardView.layer.shadowRadius = 4
            cardView.translatesAutoresizingMaskIntoConstraints = false

            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.distribution = .fillEqually
            rowStackView.spacing = 10
            rowStackView.alignment = .center
            rowStackView.translatesAutoresizingMaskIntoConstraints = false

            let categoryStackView = UIStackView()
            categoryStackView.axis = .horizontal
            categoryStackView.spacing = 5
            categoryStackView.alignment = .center
            categoryStackView.translatesAutoresizingMaskIntoConstraints = false

            let starImageView = UIImageView(image: UIImage(systemName: "star.fill"))
            starImageView.tintColor = .systemYellow
            starImageView.contentMode = .scaleAspectFit
            starImageView.translatesAutoresizingMaskIntoConstraints = false
            starImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true

            let categoryLabel = createLabel(text: category.category.capitalized, fontSize: 16, weight: .regular)
            categoryLabel.textAlignment = .center

            categoryStackView.addArrangedSubview(starImageView)
            categoryStackView.addArrangedSubview(categoryLabel)

            let hours = category.bestTime / 3600
            let minutes = (category.bestTime % 3600) / 60
            let seconds = category.bestTime % 60

            var timeText: String

            if hours > 0 {
                timeText = String(format: "%02d:%02d:%02d hrs", hours, minutes, seconds)
            } else if minutes > 0 {
                timeText = String(format: "%02d:%02d min", minutes, seconds)
            } else {
                timeText = String(format: "%d sec", seconds)
            }

            let bestTimeLabel = createLabel(text: timeText, fontSize: 16, weight: .regular)
            let pointsLabel = createLabel(text: "\(category.totalPoints)", fontSize: 16, weight: .regular)

            bestTimeLabel.textAlignment = .center
            pointsLabel.textAlignment = .center

            rowStackView.addArrangedSubview(categoryStackView)
            rowStackView.addArrangedSubview(bestTimeLabel)
            rowStackView.addArrangedSubview(pointsLabel)

            cardView.addSubview(rowStackView)
            mainStackView.addArrangedSubview(cardView)

            NSLayoutConstraint.activate([
                cardView.heightAnchor.constraint(equalToConstant: 40),
                rowStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
                rowStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
                rowStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),
                rowStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10)
            ])
        }
        let totalPointsContainer = UIView()
        totalPointsContainer.translatesAutoresizingMaskIntoConstraints = false
        totalPointsContainer.backgroundColor = UIColor(red: 240/255.0, green: 242/255.0, blue: 245/255.0, alpha: 1.0)
        totalPointsContainer.layer.cornerRadius = 10
        totalPointsContainer.layer.shadowColor = UIColor.black.cgColor
        totalPointsContainer.layer.shadowOpacity = 0.1
        totalPointsContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        totalPointsContainer.layer.shadowRadius = 4

        let totalPointsStackView = UIStackView()
        totalPointsStackView.axis = .horizontal
        totalPointsStackView.spacing = 5
        totalPointsStackView.alignment = .center
        totalPointsStackView.translatesAutoresizingMaskIntoConstraints = false

        let crownImageView = UIImageView(image: UIImage(systemName: "crown.fill"))
        crownImageView.tintColor = .systemYellow
        crownImageView.contentMode = .scaleAspectFit
        crownImageView.translatesAutoresizingMaskIntoConstraints = false
        crownImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true

        totalPointsLabel = UILabel()
        totalPointsLabel.font = UIFont.boldSystemFont(ofSize: 20)
        totalPointsLabel.textAlignment = .center

        let totalPointsText = "Total Points: "
        let pointsValue = "\(gameResult.grandTotalPoints)"

        let attributedText = NSMutableAttributedString(string: totalPointsText, attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.boldSystemFont(ofSize: 20)
        ])

        let bluePoints = NSAttributedString(string: pointsValue, attributes: [
            .foregroundColor: UIColor(red: 80/255.0, green: 9/255.0, blue: 176/255.0, alpha: 1.0),
            .font: UIFont.boldSystemFont(ofSize: 20)
        ])

        attributedText.append(bluePoints)
        totalPointsLabel.attributedText = attributedText

        totalPointsStackView.addArrangedSubview(crownImageView)
        totalPointsStackView.addArrangedSubview(totalPointsLabel)

        totalPointsContainer.addSubview(totalPointsStackView)

        mainStackView.addArrangedSubview(totalPointsContainer)

        NSLayoutConstraint.activate([
            totalPointsContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            totalPointsContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),
            totalPointsContainer.heightAnchor.constraint(equalToConstant: 50),

            totalPointsStackView.centerXAnchor.constraint(equalTo: totalPointsContainer.centerXAnchor),
            totalPointsStackView.centerYAnchor.constraint(equalTo: totalPointsContainer.centerYAnchor)
        ])
    }
    private func getProfileData() {
        guard let url = URL(string: "") else {
            print("Invalid URL")
            return
        }

        let body: String = ""
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)

        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No data received")
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let profileData = json?["profile"] as? [[String: Any]], let profile = profileData.first {
                    let firstName = profile["firstName"] as? String ?? ""
                    let lastName = profile["lastName"] as? String ?? ""
                    let profileUrl = profile["profileUrl"] as? String ?? ""

                    DispatchQueue.main.async {
                        guard let headerNameLabel = self.headerNameLabel,
                              let headerImageView = self.headerImageView else {
                            print("❌ UI elements not initialized")
                            return
                        }

                        headerNameLabel.text = "\(firstName) \(lastName)"

                        if let url = URL(string: profileUrl), !profileUrl.isEmpty {
                            self.downloadImage(from: url) { image in
                                DispatchQueue.main.async {
                                    headerImageView.image = image ?? UIImage(named: "defaultProfile")
                                }
                            }
                        } else {
                            headerImageView.image = UIImage(named: "defaultProfile") // Use a valid default image
                        }
                    }
                }
            } catch {
                print("❌ Error parsing JSON: \(error.localizedDescription)")
            }
        }
        dataTask.resume()
    }

    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                completion(UIImage(data: data))
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
}
