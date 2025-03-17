import UIKit

protocol ThemesPopupDelegate: AnyObject {
    func updateBackgroundImage(with image: UIImage)
    func updateGridBackgroundColor(to color: UIColor)
}

class ThemesPopupViewController: UIViewController {
    
    weak var delegate: ThemesPopupDelegate?
    
    var grayBackground: UIView!
    var gradientLayer: CAGradientLayer!
    var secondGrayBackground: UIView!
    var selectedImageView: UIImageView?
    var selectedGridImageView: UIImageView?
    var secondStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPopup()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        gradientLayer.frame = grayBackground.bounds

        if let secondGradientLayer = secondGrayBackground.layer.sublayers?.first as? CAGradientLayer {
            secondGradientLayer.frame = secondGrayBackground.bounds
        }

        if secondGrayBackground.layer.sublayers?.first == nil {
            let secondGradientLayer = CAGradientLayer()
            secondGradientLayer.frame = secondGrayBackground.bounds
            secondGradientLayer.colors = [
                UIColor(red: 5/255.0, green: 5/255.0, blue: 5/255.0, alpha: 0.65).cgColor,
                UIColor(red: 24/255.0, green: 93/255.0, blue: 222/255.0, alpha: 0.53).cgColor
            ]
            secondGradientLayer.locations = [0.0, 1.0]
            secondGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            secondGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            secondGrayBackground.layer.addSublayer(secondGradientLayer)
        }
    }

    private func setupPopup() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        let popupView = UIView()
        popupView.backgroundColor = .white
        popupView.layer.cornerRadius = 12
        popupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupView)

        let titleLabel = UILabel()
        titleLabel.text = "Background Style"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(titleLabel)

        grayBackground = UIView()
        grayBackground.layer.cornerRadius = 10
        grayBackground.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(grayBackground)

        gradientLayer = CAGradientLayer()
        gradientLayer.frame = grayBackground.bounds
        gradientLayer.colors = [
            UIColor(red: 5/255.0, green: 5/255.0, blue: 5/255.0, alpha: 0.65).cgColor,
            UIColor(red: 24/255.0, green: 93/255.0, blue: 222/255.0, alpha: 0.53).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        grayBackground.layer.addSublayer(gradientLayer)

        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        grayBackground.addSubview(scrollView)

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        let imageNames = ["Bamboo Zen", "Zenwood", "Dreamscape", "Halloween", "Aurora", "Skyline", "Smoke Effect", "Leaf"]
        for imageName in imageNames {
            let containerStack = UIStackView()
            containerStack.axis = .vertical
            containerStack.alignment = .center
            containerStack.spacing = 5
            containerStack.translatesAutoresizingMaskIntoConstraints = false

            let label = UILabel()
            label.text = imageName
            label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            label.textColor = .black
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false

            let imageView = UIImageView(image: UIImage(named: imageName))
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 10
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.isUserInteractionEnabled = true

            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 100),
                imageView.heightAnchor.constraint(equalToConstant: 100)
            ])

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            imageView.addGestureRecognizer(tapGesture)

            containerStack.addArrangedSubview(label)
            containerStack.addArrangedSubview(imageView)

            stackView.addArrangedSubview(containerStack)
        }

        let belowLabel = UILabel()
        belowLabel.text = "Grid Style"
        belowLabel.font = UIFont.boldSystemFont(ofSize: 20)
        belowLabel.textAlignment = .center
        belowLabel.textColor = .black
        belowLabel.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(belowLabel)

        secondGrayBackground = UIView()
        secondGrayBackground.layer.cornerRadius = 10
        secondGrayBackground.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(secondGrayBackground)

        let secondGradientLayer = CAGradientLayer()
        secondGradientLayer.frame = secondGrayBackground.bounds
        secondGradientLayer.colors = [
            UIColor(red: 5/255.0, green: 5/255.0, blue: 5/255.0, alpha: 0.65).cgColor,
            UIColor(red: 24/255.0, green: 93/255.0, blue: 222/255.0, alpha: 0.53).cgColor
        ]
        secondGradientLayer.locations = [0.0, 1.0]
        secondGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        secondGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        secondGrayBackground.layer.addSublayer(secondGradientLayer)

        let secondScrollView = UIScrollView()
        secondScrollView.showsHorizontalScrollIndicator = true
        secondScrollView.translatesAutoresizingMaskIntoConstraints = false
        secondGrayBackground.addSubview(secondScrollView)

        secondStackView = UIStackView()
        secondStackView.axis = .horizontal
        secondStackView.spacing = 10
        secondStackView.alignment = .center
        secondStackView.distribution = .equalSpacing
        secondStackView.translatesAutoresizingMaskIntoConstraints = false
        secondScrollView.addSubview(secondStackView)

        let secondImageNames = ["grid1", "grid2", "grid3", "grid4"]
        for imageName in secondImageNames {
            let imageView = UIImageView(image: UIImage(named: imageName))
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 10
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.isUserInteractionEnabled = true

            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 100),
                imageView.heightAnchor.constraint(equalToConstant: 100)
            ])

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            imageView.addGestureRecognizer(tapGesture)

            secondStackView.addArrangedSubview(imageView)
        }

        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.addTarget(self, action: #selector(closePopup), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(closeButton)

        NSLayoutConstraint.activate([
            popupView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popupView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            popupView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            //popupView.heightAnchor.constraint(greaterThanOrEqualToConstant: 410),
            popupView.bottomAnchor.constraint(equalTo: secondStackView.bottomAnchor, constant: 35),


            titleLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),

            grayBackground.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            grayBackground.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            grayBackground.widthAnchor.constraint(equalTo: popupView.widthAnchor, multiplier: 0.9),
            grayBackground.heightAnchor.constraint(equalToConstant: 140),

            scrollView.topAnchor.constraint(equalTo: grayBackground.topAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: grayBackground.leadingAnchor, constant: 10),
            scrollView.trailingAnchor.constraint(equalTo: grayBackground.trailingAnchor, constant: -10),
            scrollView.bottomAnchor.constraint(equalTo: grayBackground.bottomAnchor, constant: -10),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),

            belowLabel.topAnchor.constraint(equalTo: grayBackground.bottomAnchor, constant: 10),
            belowLabel.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            belowLabel.heightAnchor.constraint(equalToConstant: 30),

            secondGrayBackground.topAnchor.constraint(equalTo: belowLabel.bottomAnchor, constant: 10),
            secondGrayBackground.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            secondGrayBackground.widthAnchor.constraint(equalTo: popupView.widthAnchor, multiplier: 0.9),
            secondGrayBackground.heightAnchor.constraint(equalToConstant: 130),

            secondScrollView.topAnchor.constraint(equalTo: secondGrayBackground.topAnchor, constant: 10),
            secondScrollView.leadingAnchor.constraint(equalTo: secondGrayBackground.leadingAnchor, constant: 10),
            secondScrollView.trailingAnchor.constraint(equalTo: secondGrayBackground.trailingAnchor, constant: -10),
            secondScrollView.bottomAnchor.constraint(equalTo: secondGrayBackground.bottomAnchor, constant: -10),

            secondStackView.topAnchor.constraint(equalTo: secondScrollView.topAnchor),
            secondStackView.leadingAnchor.constraint(equalTo: secondScrollView.leadingAnchor),
            secondStackView.trailingAnchor.constraint(equalTo: secondScrollView.trailingAnchor),
            secondStackView.bottomAnchor.constraint(equalTo: secondScrollView.bottomAnchor),
            secondStackView.heightAnchor.constraint(equalTo: secondScrollView.heightAnchor),

            closeButton.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -10),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
        ])
    }

    @objc private func imageTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView, let image = tappedImageView.image else { return }
        
        if sender.view?.superview == secondStackView {
            handleSecondSetImageTapped(tappedImageView, image)
        } else {
            handleFirstSetImageTapped(tappedImageView, image)
        }
    }

    private func handleFirstSetImageTapped(_ imageView: UIImageView, _ image: UIImage) {
        selectedImageView?.layer.borderColor = UIColor.clear.cgColor
        selectedImageView?.layer.borderWidth = 0
        selectedImageView = imageView
        selectedImageView?.layer.borderColor = UIColor.black.cgColor
        selectedImageView?.layer.borderWidth = 2

        delegate?.updateBackgroundImage(with: image)
        
        // Save image to disk and store the path in UserDefaults
        if let filePath = saveImageToDocuments(image: image, fileName: "background.jpg") {
            UserDefaults.standard.set(filePath, forKey: "selectedBackgroundImagePath")
            
            NotificationCenter.default.post(name: NSNotification.Name("BackgroundImageChanged"), object: nil)
        }
    }
    
    func saveImageToDocuments(image: UIImage, fileName: String) -> String? {
        if let data = image.jpegData(compressionQuality: 0.8) { // Compress to reduce size
            let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = directory.appendingPathComponent(fileName)

            do {
                try data.write(to: fileURL)
                print("✅ Image saved at:", fileURL.path)
                return fileURL.path  // Return file path instead of raw data
            } catch {
                print("❌ Failed to save image:", error.localizedDescription)
            }
        }
        return nil
    }


    private func handleSecondSetImageTapped(_ imageView: UIImageView, _ image: UIImage) {
        let colors: [UIColor] = [
            UIColor(hex: "#F8DCBE"),
            UIColor(hex: "#89BBFC"),
            UIColor(hex: "#F4E5FD"),
            UIColor(hex: "#FFFFFF")
        ]
        
        if let index = secondStackView.arrangedSubviews.firstIndex(of: imageView) {
            let selectedColor = colors[index]
            let selectedColorHex = selectedColor.toHexString()
            UserDefaults.standard.set(selectedColorHex, forKey: "selectedGridColor")
            delegate?.updateGridBackgroundColor(to: selectedColor)
            NotificationCenter.default.post(name: NSNotification.Name("BackgroundColorChanged"), object: nil)
        }
        selectedGridImageView?.layer.borderColor = UIColor.clear.cgColor
        selectedGridImageView?.layer.borderWidth = 0
        selectedGridImageView = imageView
        selectedGridImageView?.layer.borderColor = UIColor.black.cgColor
        selectedGridImageView?.layer.borderWidth = 2
    }

    @objc private func closePopup() {
  
        selectedImageView?.layer.borderColor = UIColor.clear.cgColor
        selectedImageView?.layer.borderWidth = 0
        selectedGridImageView?.layer.borderColor = UIColor.clear.cgColor
        selectedGridImageView?.layer.borderWidth = 0
        
        dismiss(animated: true, completion: nil)
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
extension UIColor {
    func toHexString() -> String {
        let components = self.cgColor.components ?? [0, 0, 0, 0]
        let r = components[0]
        let g = components[1]
        let b = components[2]
        let a = components[3]
        let hexString = String(format: "#%02lX%02lX%02lX", Int(r * 255), Int(g * 255), Int(b * 255))
        return hexString
    }
}
