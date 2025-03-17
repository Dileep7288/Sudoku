import UIKit

class StreakCelebrationView: UIView {
    
    private let streakLabel: UILabel
    private var confettiTimer: Timer?
    
    override init(frame: CGRect) {
        self.streakLabel = UILabel()
        super.init(frame: frame)
        
        setupUI()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.startAnimation()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.7)

        streakLabel.text = "🌟 Wow! Another 70 points in the bag! Your streak is getting legendary! 💪✨"
        streakLabel.font = UIFont.boldSystemFont(ofSize: 24)
        streakLabel.textColor = .white
        streakLabel.textAlignment = .center
        streakLabel.alpha = 0
        streakLabel.numberOfLines = 0

        let labelWidth = bounds.width - 40
        streakLabel.frame = CGRect(x: 20, y: bounds.height / 2 - 40, width: labelWidth, height: 0)
        streakLabel.sizeToFit()
        streakLabel.center.x = bounds.width / 2

        addSubview(streakLabel)
    }

    
    func startAnimation() {
        streakLabel.alpha = 0
        streakLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 1.2, delay: 0, options: .curveEaseInOut, animations: {
            self.streakLabel.alpha = 1
            self.streakLabel.transform = .identity
            self.streakLabel.layer.shadowColor = UIColor.white.cgColor
            self.streakLabel.layer.shadowRadius = 10
            self.streakLabel.layer.shadowOpacity = 0.8
            self.streakLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        }) { _ in
            self.startConfettiEffect()
            self.startColorCycle()
            self.createFireworksEffect()
        }

        createConfettiBurst()

        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.success)

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.removeFromSuperview()
        }
    }
    
    private func startConfettiEffect() {
        confettiTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(createConfetti), userInfo: nil, repeats: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.confettiTimer?.invalidate()
        }
    }
    
    @objc private func createConfetti() {
        let startX = CGFloat.random(in: 0...bounds.width)
        let confetti = UIView(frame: CGRect(x: startX, y: -20, width: 10, height: 20))
        confetti.backgroundColor = getRandomColor()
        confetti.layer.cornerRadius = 3
        addSubview(confetti)
        
        let endX = startX + CGFloat.random(in: -50...50)
        let endY = bounds.height + 50
        
        UIView.animate(withDuration: 3.0, delay: 0, options: .curveEaseOut, animations: {
            confetti.center = CGPoint(x: endX, y: endY)
            confetti.transform = CGAffineTransform(rotationAngle: .random(in: -1...1)) // Random rotation
        }) { _ in
            confetti.removeFromSuperview()
        }
    }
    
    private func createConfettiBurst() {
        for _ in 0..<15 {
            let confetti = UIView(frame: CGRect(x: bounds.width / 2, y: streakLabel.frame.midY, width: 10, height: 20))
            confetti.backgroundColor = getRandomColor()
            confetti.layer.cornerRadius = 3
            addSubview(confetti)

            let randomX = CGFloat.random(in: -bounds.width/3...bounds.width/3)
            let randomY = CGFloat.random(in: -50...50)
            let endX = confetti.center.x + randomX
            let peakY = confetti.center.y - 100
            let finalY = confetti.center.y + randomY + 200

            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                confetti.center = CGPoint(x: endX, y: peakY)
            }) { _ in
                UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseIn, animations: {
                    confetti.center.y = finalY
                    confetti.transform = CGAffineTransform(rotationAngle: .random(in: -0.5...0.5))
                    confetti.alpha = 0
                }) { _ in
                    confetti.removeFromSuperview()
                }
            }
        }
    }

    
    private func startColorCycle() {
        UIView.animate(withDuration: 3.0, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.streakLabel.textColor = self.getRandomColor()
        })
    }
    
    private func createFireworksEffect() {
        let fireworksLayer = CAEmitterLayer()
        fireworksLayer.emitterPosition = CGPoint(x: bounds.width / 2, y: streakLabel.frame.midY - 50)
        fireworksLayer.emitterShape = .point
        fireworksLayer.emitterSize = CGSize(width: 1, height: 1)
        
        let cell = CAEmitterCell()
        cell.birthRate = 10
        cell.lifetime = 1.5
        cell.velocity = 200
        cell.velocityRange = 50
        cell.emissionRange = .pi * 2
        cell.scale = 0.5
        cell.scaleRange = 0.3
        cell.contents = UIImage(named: "spark")?.cgImage
        
        fireworksLayer.emitterCells = [cell]
        layer.addSublayer(fireworksLayer)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            fireworksLayer.birthRate = 0
        }
    }
    
    private func getRandomColor() -> UIColor {
        let colors: [UIColor] = [.red, .yellow, .blue, .green, .orange, .purple, .cyan, .magenta]
        return colors.randomElement() ?? .white
    }
}
