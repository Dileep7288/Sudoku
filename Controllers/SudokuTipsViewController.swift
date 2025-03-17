import UIKit

class SudokuTipsViewController: UIViewController {
    
    var previousCard: UIView?
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let titleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sudoku Tips & Strategies"
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        label.textAlignment = .center
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = .white
        
        let backGroundimage = UIImageView()
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
        
        view.addSubview(titleView)
        titleView.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        addTipsCards()
        setupConstraints()
    }

    private func addTipsCards() {
        let tips = [
            ("How to Play Sudoku?", "(i). No row can contain more than one of the same number from 1 to 9.\n(ii). No column can contain more than one of the same number from 1 to 9.\n(iii). No 3x3 grid can contain more than one of the same number from 1 to 9."),
            ("Look for the Easy Solutions", "Some puzzles will have one or two blanks in a row, column, or box. If a number is missing, check whether it’s already in the box."),
            ("Seek the Missing Numbers", "As you fill in the easy solutions, you may start to find other missing numbers that are easy to place."),
            ("Keep Scanning the Entire Puzzle", "If you get stuck, don’t concentrate too hard on one part of the grid. Let your eye scan the puzzle to find another place on the grid with new possibilities."),
            ("Constantly Re-Evaluate the Grid", "Whenever you place a new number, see if that opens up a new row or box. It might narrow down the possibilities or make another number obvious."),
            ("Be Patient and Enjoy the Hunt", "Remember that although you want to finish a puzzle, the point is to enjoy the challenge and work your brain as you relax."),
            ("Undo Moves When Needed", "If you make a mistake, use **Undo** to revert your last move. This helps you correct errors without restarting the entire puzzle."),
            ("Redo a Move", "Accidentally undid a correct move? Use **Redo** to bring back your last undone action."),
            ("Reset the Puzzle", "Want a fresh start? The **Reset** button clears your progress and lets you restart the puzzle from the beginning."),
            ("Use Note Mode for Possibilities", "In **Note Mode**, you can enter multiple small numbers in a cell to track possible values. This is helpful when you're unsure about a number."),
            ("Use Hints Wisely", "Stuck on a tough puzzle? Use the **Hint** feature to get a correct number placed for you. Be mindful, as hints may be limited!")
        ]
        
        for (index, tip) in tips.enumerated() {
            let card = createTipCard(title: tip.0, description: tip.1, index: index)
            contentView.addSubview(card)
            
            NSLayoutConstraint.activate([
                card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                card.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
            ])
            
            if let previousCard = previousCard {
                card.topAnchor.constraint(equalTo: previousCard.bottomAnchor, constant: 5).isActive = true
            } else {
                card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15).isActive = true
            }
            
            previousCard = card
        }
        
        if let lastCard = previousCard {
            lastCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        }
    }
    
    private func createTipCard(title: String, description: String, index: Int) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.2
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 4
        card.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = UIColor.systemBlue
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(titleLabel)
        card.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        return card
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 130),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 90),
            titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -20)
        ])
    }
}
