//
//  SudokuTipsViewController.swift
//  SudokuGame
//
//  Created by SS-MAC-007 on 05/02/25.
//
import UIKit

class SudokuTipsViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.5180133581, green: 0.3614192009, blue: 1, alpha: 1) // Transparent background
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sudoku Tips & Strategies"
        label.font = UIFont(name: "Avenir-Black", size: 28)
        label.textAlignment = .center
        label.textColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0).cgColor
        ]
        gradient.locations = [0.0, 1.0]
        return gradient
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0) // Light gray
    
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        // Set gradient background
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Add header view
        view.addSubview(headerView)
        
     
        // Add scroll view and content view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add title label
        contentView.addSubview(titleLabel)
        
        // Add tips cards
        addTipsCards()
        
        // Set constraints
        setupConstraints()
    }
    
    private func addTipsCards() {
        let tips = [
            ("How to Play Sudoku?", "1. No row can contain more than one of the same number from 1 to 9.\n2. No column can contain more than one of the same number from 1 to 9.\n3. No 3x3 grid can contain more than one of the same number from 1 to 9."),
            ("Look for the Easy Solutions", "Some puzzles will have one or two blanks in a row, column, or box. If a number is missing, check whether it’s already in the box. For example, if a row needs a 5 and a 6, but the box already contains a 6, the blank in that box must be 5, and the other blank will be 6. Filling these quickly moves you closer to solving the puzzle."),
            ("Seek the Missing Numbers", "As you fill in the easy solutions, you may start to find other missing numbers that are easy to place. In the above example, the box now has a 5, and that may help you solve that 3×3 area, or might help you solve the lines that cross that area."),
            ("Keep Scanning the Entire Puzzle", "If you get stuck, don’t concentrate too hard on one part of the grid. Let your eye scan the puzzle to find another place on the grid with new possibilities. You may find another quick solution."),
            ("Constantly Re-Evaluate the Grid", "Whenever you place a new number, see if that opens up a new row or box. It might narrow down the possibilities or make another number obvious. If you keep asking yourself which numbers you’re missing in a line or grid, you might find it more quickly."),
            ("Be Patient and Enjoy the Hunt", "Remember that although you want to finish a puzzle, the point is to enjoy the challenge and work your brain as you relax. If you find yourself getting frustrated, walk away. Let your mind clear and try again later. The most important thing is to have fun.")
        ]
        
        var previousCard: UIView?
        
        for (index, tip) in tips.enumerated() {
            let card = createTipCard(title: tip.0, description: tip.1, index: index)
            contentView.addSubview(card)
            
            NSLayoutConstraint.activate([
                card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                card.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
            ])
            
            if let previousCard = previousCard {
                card.topAnchor.constraint(equalTo: previousCard.bottomAnchor, constant: 20).isActive = true
            } else {
                card.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30).isActive = true
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
        titleLabel.font = UIFont(name: "Avenir-Bold", size: 20)
        titleLabel.textColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = UIFont(name: "Avenir-Medium", size: 16)
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
            // Header view constraints
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100),
            

            
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title label constraints
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
