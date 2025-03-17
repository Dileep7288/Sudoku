import UIKit

class CoinView: UIView {
    
    var coinColor: UIColor
    
    init(frame: CGRect, coinColor: UIColor) {
        self.coinColor = coinColor
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        self.coinColor = UIColor.green
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.75

        let outerPath = UIBezierPath(arcCenter: center, radius: outerRadius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        coinColor.setFill()
        outerPath.fill()

        let innerPath = UIBezierPath(arcCenter: center, radius: innerRadius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        UIColor.white.setFill()
        innerPath.fill()

        let starPath = UIBezierPath()
        let starPoints = getStarPoints(center: center, radius: innerRadius * 0.6)
        starPath.move(to: starPoints[0])
        for i in 1..<starPoints.count {
            starPath.addLine(to: starPoints[i])
        }
        starPath.close()
        
        coinColor.setFill()
        starPath.fill()
    }
    
    private func getStarPoints(center: CGPoint, radius: CGFloat) -> [CGPoint] {
        let angle = CGFloat.pi / 5 
        var points: [CGPoint] = []
        
        for i in 0..<10 {
            let r = i % 2 == 0 ? radius : radius * 0.5
            let x = center.x + r * cos(angle * CGFloat(i) * 2)
            let y = center.y - r * sin(angle * CGFloat(i) * 2)
            points.append(CGPoint(x: x, y: y))
        }
        
        return points
    }
}
