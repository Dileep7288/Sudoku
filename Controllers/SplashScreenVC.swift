import UIKit

class SplashScreenVC: UIViewController {

    private let progressBar: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.progressTintColor = UIColor(red: 19/255, green: 224/255, blue: 139/255, alpha: 1.0) 
        progress.trackTintColor = .white
        progress.progress = 0.0
        progress.layer.cornerRadius = 10
        progress.clipsToBounds = true
        return progress
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        startProgress()
        UserDefaults.standard.removeObject(forKey: "selectedBackgroundImage")
        UserDefaults.standard.removeObject(forKey: "selectedGridColor")
        //UserDefaults.standard.removeObject(forKey: "PlayedDifficulties")
    }
    
    private func setupViews() {
        let backgroundImage = createImageView(named: "Bamboo Zen", contentMode: .scaleToFill)
        view.addSubview(backgroundImage)

        let sudokuImage = createImageView(named: "Splashscreenimage", contentMode: .scaleToFill)
        sudokuImage.transform = CGAffineTransform(rotationAngle: -(.pi / 18))
        backgroundImage.addSubview(sudokuImage)

        let sudokuLabel = createLabel(text: "SUDOKU", fontSize: 40)
        backgroundImage.addSubview(sudokuLabel)

        backgroundImage.addSubview(progressBar)

        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            sudokuImage.topAnchor.constraint(equalTo: backgroundImage.topAnchor, constant: 250),
            sudokuImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sudokuImage.widthAnchor.constraint(equalToConstant: 160),
            sudokuImage.heightAnchor.constraint(equalToConstant: 160),

            sudokuLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sudokuLabel.topAnchor.constraint(equalTo: sudokuImage.bottomAnchor, constant: 20),

            progressBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressBar.topAnchor.constraint(equalTo: sudokuLabel.bottomAnchor, constant: 25),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            progressBar.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    private func createImageView(named imageName: String, contentMode: UIView.ContentMode) -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = contentMode
        return imageView
    }

    private func createLabel(text: String, fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        label.textAlignment = .center
        return label
    }

    private func startProgress() {
        progressBar.setProgress(0.0, animated: false)
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            self.progressBar.setProgress(1.0, animated: true)
        }
    }

    private func transitionToMainScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            guard let navigationController = self.navigationController else {
                print("⚠️ Error: No Navigation Controller found!")
                return
            }
            navigationController.pushViewController(CustomViewController(), animated: true)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        transitionToMainScreen()
    }
}
