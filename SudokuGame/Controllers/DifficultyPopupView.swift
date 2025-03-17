
//  DifficultyPopupView.swift
//  SudokuGame
//
//  Created by SS-MAC-007 on 05/02/25.
//
import UIKit

class DifficultyPopupView: UIView {
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose Difficulty"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let easyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Easy", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        button.backgroundColor = #colorLiteral(red: 0.2964565456, green: 0.1093532816, blue: 0.6993825436, alpha: 1)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let mediumButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Medium", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        button.backgroundColor = #colorLiteral(red: 0.2964565456, green: 0.1093532816, blue: 0.6993825436, alpha: 1)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let hardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Hard", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        button.backgroundColor = #colorLiteral(red: 0.2964565456, green: 0.1093532816, blue: 0.6993825436, alpha: 1)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [easyButton, mediumButton, hardButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Properties
    var onDifficultySelected: ((String) -> Void)?
    var onCancel: (() -> Void)?

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupActions()
    }

    // MARK: - Private Methods
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        layer.cornerRadius = 20
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(closeButton)
        addSubview(buttonStack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),

            buttonStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            buttonStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            buttonStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50)
        ])
    }

    private func setupActions() {
        easyButton.addTarget(self, action: #selector(difficultyButtonTapped(_:)), for: .touchUpInside)
        mediumButton.addTarget(self, action: #selector(difficultyButtonTapped(_:)), for: .touchUpInside)
        hardButton.addTarget(self, action: #selector(difficultyButtonTapped(_:)), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }

    @objc private func difficultyButtonTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }
        onDifficultySelected?(title.lowercased()) // Pass the difficulty in lowercase
    }

    @objc private func closeButtonTapped() {
        onCancel?()
    }
}
