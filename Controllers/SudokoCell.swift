import UIKit

class SudokuCell: UICollectionViewCell {
    static let identifier = "SudokuCell"
    
    private var noteLabels: [UILabel] = []
    
    let numberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var borderViews: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(numberLabel)
        setupConstraints()
        contentView.backgroundColor = .white
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            numberLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with number: Int?, isInitial: Bool = false, isIncorrect: Bool = false, correctNumber: Int? = nil, notes: [Int]? = nil) {
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.clear.cgColor
        self.backgroundColor = .white
        
        if let number = number {
            numberLabel.text = String(number)
            if isInitial {
                numberLabel.textColor = .black
                numberLabel.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
            } else {
                numberLabel.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
                if number == correctNumber {
                    numberLabel.textColor = .black
                } else {
                    numberLabel.textColor = UIColor.red
                    
//                    if isIncorrect {
//                        self.layer.borderWidth = 2
//                        //self.layer.borderColor = UIColor.red.cgColor
//                        self.backgroundColor = UIColor(red: 1.0, green: 0.92, blue: 0.93, alpha: 1.0) 
//                    }
                }
            }
        } else {
            numberLabel.text = nil
        }
        clearNotes()
        if let notes = notes {
            for note in notes {
                addNote(note)
            }
        }
    }
    
    func addNote(_ number: Int) {
        let noteLabel = UILabel()
        noteLabel.text = "\(number)"
        noteLabel.textColor = .blue
        noteLabel.font = UIFont.systemFont(ofSize: 10)
        noteLabel.textAlignment = .center
        noteLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(noteLabel)
        noteLabels.append(noteLabel)
        
        updateNotePositions()
    }
    
    func updateNotes(_ notes: [Int]) {
        clearNotes()
        
        for note in notes {
            addNote(note)
        }
    }
    
    private func updateNotePositions() {
        for (index, noteLabel) in noteLabels.enumerated() {
            let row = index / 3
            let column = index % 3
            let xOffset = CGFloat(column) * (contentView.bounds.width / 3)
            let yOffset = CGFloat(row) * (contentView.bounds.height / 3)
            
            NSLayoutConstraint.activate([
                noteLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: xOffset),
                noteLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: yOffset),
                noteLabel.widthAnchor.constraint(equalToConstant: contentView.bounds.width / 3),
                noteLabel.heightAnchor.constraint(equalToConstant: contentView.bounds.height / 3)
            ])
        }
    }
    
    func clearNotes() {
        noteLabels.forEach { $0.removeFromSuperview() }
        noteLabels.removeAll()
    }
    
    func updateBorder(row: Int, column: Int) {
        borderViews.forEach { $0.removeFromSuperview() }
        borderViews.removeAll()
        
        let normalWidth: CGFloat = 0.2
        let borderWidth: CGFloat = 1.5
        
        addBorder(to: .top, color: .darkGray, width: normalWidth)
        addBorder(to: .left, color: .darkGray, width: normalWidth)
        addBorder(to: .bottom, color: .darkGray, width: normalWidth)
        addBorder(to: .right, color: .darkGray, width: normalWidth)

        if row == 2 || row == 5 {
            addBorder(to: .bottom, color: .gray, width: borderWidth)
        }

        if column == 2 || column == 5 {
            addBorder(to: .right, color: .gray, width: borderWidth)
        }
    }
    
    private func addBorder(to edge: UIRectEdge, color: UIColor, width: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(border)
        borderViews.append(border)
        
        switch edge {
        case .top:
            NSLayoutConstraint.activate([
                border.topAnchor.constraint(equalTo: contentView.topAnchor),
                border.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                border.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                border.heightAnchor.constraint(equalToConstant: width)
            ])
        case .bottom:
            NSLayoutConstraint.activate([
                border.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                border.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                border.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                border.heightAnchor.constraint(equalToConstant: width)
            ])
        case .left:
            NSLayoutConstraint.activate([
                border.topAnchor.constraint(equalTo: contentView.topAnchor),
                border.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                border.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                border.widthAnchor.constraint(equalToConstant: width)
            ])
        case .right:
            NSLayoutConstraint.activate([
                border.topAnchor.constraint(equalTo: contentView.topAnchor),
                border.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                border.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                border.widthAnchor.constraint(equalToConstant: width)
            ])
        default:
            break
        }
    }
    
}
