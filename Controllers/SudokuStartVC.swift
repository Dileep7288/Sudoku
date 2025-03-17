import UIKit

class SudokuStartVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView!
    let gridSize = 9
    var puzzleData: PuzzleData?
    var selectedDifficulty: String?
    var selectedIndexPath: IndexPath?
    var currentNumber: Int?
    private var initialPuzzle: [[Int]] = []
    
    private var undoStack: [(row: Int, column: Int, number: Int)] = []
    private var redoStack: [(row: Int, column: Int, number: Int)] = []
    private var noteButtonContainer: UIView?
    
    private var hasSubmittedGameData = false
    
    var isNotesMode = false
    var cellNotes: [IndexPath: Set<Int>] = [:]
    
    private var gameTimer: Timer?
    private var elapsedTime: Int = 0
    private var startTime: Date?

    private var hintsUsed: Int = 0 {
        didSet {
            updateHintCountLabel()
        }
    }
    
    private var undoCount: Int = 0
    
    private var redoCount: Int = 0
    
    private var wrongEntryCount: Int = 0
    
    init(difficulty: String) {
        self.selectedDifficulty = difficulty
        super.init(nibName: nil, bundle: nil) 
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Bamboo Zen")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let actionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let difficultyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var numberButtons: [UIButton] = {
        var buttons = (1...9).map { number in
            let button = UIButton(type: .system)
            button.setTitle("\(number)", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 35, weight: .medium)
            button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            button.layer.cornerRadius = 8
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }
        
        let xButton = UIButton(type: .system)
        xButton.setImage(UIImage(named: "clear")?.withRenderingMode(.alwaysTemplate), for: .normal)
        xButton.tintColor = .white
        xButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        xButton.layer.cornerRadius = 8
        xButton.translatesAutoresizingMaskIntoConstraints = false
        buttons.append(xButton)
        
        return buttons
    }()

    private lazy var numberButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let row1 = UIStackView()
        row1.axis = .horizontal
        row1.distribution = .fillEqually
        row1.alignment = .fill
        row1.spacing = 10

        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.distribution = .fillEqually
        row2.alignment = .fill
        row2.spacing = 10

        for (index, button) in numberButtons.enumerated() {
            button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
            if index < 5 {
                row1.addArrangedSubview(button)
            } else {
                row2.addArrangedSubview(button)
            }
        }

        stackView.addArrangedSubview(row1)
        stackView.addArrangedSubview(row2)

        return stackView
    }()
    
    private lazy var hintCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var hasSubmittedZeroValues = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let customBackButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        customBackButton.tintColor = .white
        navigationItem.leftBarButtonItem = customBackButton
        
        setupBackground()
        setupActionStackView()
        setupDifficultyLabel()
        setupCollectionView()
        setupNumberButtonStackView()
        setupNumberButtonActions()
        fetchPuzzleData(difficulty: selectedDifficulty ?? "medium")
        toggleNumberButtons(enabled: false, forEmptyCell: false)
        updateHintCountLabel()
        
        startTimer()
        
        loadSavedBackgroundImage()
        NotificationCenter.default.addObserver(self, selector: #selector(updateBackgroundImage(_:)), name: NSNotification.Name("BackgroundImageChanged"), object: nil)
    }
    
    private func loadSavedBackgroundImage() {
        if let filePath = UserDefaults.standard.string(forKey: "selectedBackgroundImagePath") {
            let fileURL = URL(fileURLWithPath: filePath)
            
            if let imageData = try? Data(contentsOf: fileURL),
               let savedImage = UIImage(data: imageData) {
                backgroundImageView.image = savedImage
                print("Background image loaded from:", filePath)
            } else {
                print("Failed to load background image")
            }
        } else {
            print("No saved background image found")
        }
    }

    @objc private func updateBackgroundImage(_ notification: Notification) {
        if let imageData = UserDefaults.standard.data(forKey: "selectedBackgroundImage"),
           let newImage = UIImage(data: imageData) {
            backgroundImageView.image = newImage
        }
    }
    
    //MARK: BackButton Are You Sure
    @objc private func backButtonTapped() {
        let alert = UIAlertController(
            title: "Are you sure you want to exit?",
            message: "Your progress will be lost.",
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            self?.submitZeroValuesAndExit()
        }
        
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func submitZeroValuesAndExit() {
        guard !hasSubmittedZeroValues else { return }
        hasSubmittedZeroValues = true

        stopTimer()
        print("Total Time Taken Before Exit: \(elapsedTime) seconds")
        
        let elapsedSeconds = elapsedTime
        let conversionTime = formatTime(seconds: elapsedSeconds)
        print("Formatted Time: \(conversionTime)")

        let riderID = 2
        let eventID = puzzleData?.eventID ?? "Unknown"
        guard let puzzleDate = puzzleData?.puzzleDate else {
            print("No puzzle data available. Not adding any date.")
            return
        }
        let category = selectedDifficulty ?? "easy"

        var playedDates = UserDefaults.standard.stringArray(forKey: "PlayedDates") ?? []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let currentDate = dateFormatter.date(from: puzzleDate) else {
            print("Invalid puzzle date format")
            return
        }
        
        if !playedDates.contains(puzzleDate) {
            playedDates.append(puzzleDate)
            UserDefaults.standard.set(playedDates, forKey: "PlayedDates")
        }

        let sortedDates = playedDates.compactMap { dateFormatter.date(from: $0) }.sorted()

        var totalScore = 0
        let streakBonusGivenKey = "StreakBonusGiven_\(puzzleDate)"
        let firstGamePlayedTodayKey = "FirstGamePlayedToday_\(puzzleDate)"
        
        if isSevenDayStreak(sortedDates, currentDate) {
            let hasReceivedBonus = UserDefaults.standard.bool(forKey: streakBonusGivenKey)
            let firstGamePlayedToday = UserDefaults.standard.bool(forKey: firstGamePlayedTodayKey)
            if !hasReceivedBonus && !firstGamePlayedToday {
                totalScore += 70
                print("7-Day Streak Achieved on Exit! +70 Bonus Points")
                
                UserDefaults.standard.set(true, forKey: streakBonusGivenKey)
                UserDefaults.standard.set(true, forKey: firstGamePlayedTodayKey)
                UserDefaults.standard.set(true, forKey: "StreakAchieved_\(puzzleDate)")
            }
        }
        submitGameData(
            riderID: riderID,
            eventID: eventID,
            puzzleDate: puzzleDate,
            negativePoints: 0,
            redo: 0,
            undo: 0,
            hint: 0,
            totalPoints: totalScore,
            timeTaken: conversionTime,
            category: category
        ) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.navigateToCustomViewController()
                } else {
                    print("Failed to submit zero values.")
                }
            }
        }
    }

    private func navigateToCustomViewController() {
        let customVC = CustomViewController()
        customVC.modalPresentationStyle = .fullScreen 
        navigationController?.pushViewController(customVC, animated: true)
    }
    
    private func startTimer() {
        elapsedTime = 0
        startTime = Date()
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    @objc private func updateTimer() {
        guard let startTime = startTime else { return }
        elapsedTime = Int(Date().timeIntervalSince(startTime))
    }
    
    private func setupBackground() {
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SudokuCell.self, forCellWithReuseIdentifier: SudokuCell.identifier)
        collectionView.backgroundColor = .clear
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: difficultyLabel.bottomAnchor, constant: 30),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalTo: collectionView.widthAnchor),
            collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupActionStackView() {
        view.addSubview(actionStackView)
        
        //let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        
        let undoButton = createActionButton(imageName: "arrow.uturn.left", action: #selector(undoTapped))
        let redoButton = createActionButton(imageName: "arrow.uturn.right", action: #selector(redoTapped))
        let resetButton = createActionButton(imageName: "arrow.clockwise", action: #selector(resetTapped))
        let hintButton = createActionButton(imageName: "lightbulb", action: #selector(hintTapped))
        let noteButton = createActionButton(imageName: "note.text", action: #selector(noteTapped))
        
        actionStackView.addArrangedSubview(undoButton)
        actionStackView.addArrangedSubview(redoButton)
        actionStackView.addArrangedSubview(resetButton)
        actionStackView.addArrangedSubview(hintButton)
        actionStackView.addArrangedSubview(noteButton)
        
        NSLayoutConstraint.activate([
            actionStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 90),
            actionStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupDifficultyLabel() {
        view.addSubview(difficultyLabel)
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(navigateToNextScreen))
//        difficultyLabel.isUserInteractionEnabled = true
//        difficultyLabel.addGestureRecognizer(tapGesture)
        difficultyLabel.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        difficultyLabel.layer.cornerRadius = 5
        difficultyLabel.clipsToBounds = true
        difficultyLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        difficultyLabel.textAlignment = .center
        difficultyLabel.textColor = .white
        
        NSLayoutConstraint.activate([
            difficultyLabel.topAnchor.constraint(equalTo: actionStackView.bottomAnchor, constant: 20),
            difficultyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 140),
            difficultyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -140),
            difficultyLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        if let difficulty = selectedDifficulty {
            difficultyLabel.text = "\(difficulty.capitalized)"
        }
    }
    
    private func createActionButton(imageName: String, action: Selector) -> UIView {
        let buttonContainer = UIView()
        let button = UIButton(type: .system)
        let buttonSize: CGFloat = 44
        let image = UIImage(systemName: imageName)!
        button.setImage(image, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false

        buttonContainer.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: buttonSize),
            button.heightAnchor.constraint(equalToConstant: buttonSize),

            buttonContainer.widthAnchor.constraint(equalToConstant: buttonSize),
            buttonContainer.heightAnchor.constraint(equalToConstant: buttonSize)
        ])
        
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        
        if imageName == "lightbulb" {
            buttonContainer.addSubview(hintCountLabel)
            
            NSLayoutConstraint.activate([
                hintCountLabel.bottomAnchor.constraint(equalTo: button.topAnchor, constant: 12),
                hintCountLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -2),
                hintCountLabel.widthAnchor.constraint(equalToConstant: 20),
                hintCountLabel.heightAnchor.constraint(equalToConstant: 20)
            ])
        }
        if imageName == "note.text" {
            noteButtonContainer = buttonContainer
        }
        
        return buttonContainer
    }

    private func setupNumberButtonStackView() {
        view.addSubview(numberButtonsStackView)
        
        NSLayoutConstraint.activate([
            numberButtonsStackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 30),
            numberButtonsStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            numberButtonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            numberButtonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            numberButtonsStackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.15),
            numberButtonsStackView.heightAnchor.constraint(lessThanOrEqualToConstant: 180),
            numberButtonsStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
    }

    private func setupNumberButtonActions() {
        for i in 0..<9 {
            numberButtons[i].addTarget(self, action: #selector(numberButtonTapped(_:)), for: .touchUpInside)
        }
        numberButtons.last?.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
    }
    
    private func countNumberOccurrences(_ number: Int) -> Int {
        guard let puzzle = puzzleData?.puzzle else { return 0 }
        var count = 0
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if puzzle[row][col] == number {
                    count += 1
                }
            }
        }
        return count
    }

    private func toggleNumberButtons(enabled: Bool, forEmptyCell: Bool = false) {
        guard !numberButtons.isEmpty else {
            print("Error: numberButtons array is empty!")
            return
        }

        guard let selectedIndexPath = selectedIndexPath else {
            for button in numberButtons {
                button.isEnabled = false
                button.alpha = 0.3
            }
            return
        }

        var numberCounts = [Int: Int]()
        if let puzzle = puzzleData?.puzzle {
            for row in 0..<gridSize {
                for col in 0..<gridSize {
                    let num = puzzle[row][col]
                    if num > 0 {
                        numberCounts[num, default: 0] += 1
                    }
                }
            }
        }
        for (index, button) in numberButtons.enumerated() {
            if index == numberButtons.count - 1 {
                let row = selectedIndexPath.row / gridSize
                let col = selectedIndexPath.row % gridSize
                guard let puzzle = puzzleData?.puzzle,
                      row >= 0, row < puzzle.count,
                      col >= 0, col < puzzle[row].count else {
                    print("Error: Row/Col out of bounds! row: \(row), col: \(col)")
                    button.isEnabled = false
                    button.alpha = 0.3
                    continue
                }
                
                let currentCellValue = puzzle[row][col]
                let correctValue = puzzleData?.solution[row][col]
                let isCellIncorrect = currentCellValue != 0 && currentCellValue != correctValue
                button.isEnabled = (isCellIncorrect || currentCellValue == 0)
                button.alpha = (isCellIncorrect || currentCellValue == 0) ? 1.0 : 0.3
            } else {
                let number = index + 1
                let isMaxCountReached = numberCounts[number, default: 0] >= 9
                button.isEnabled = enabled && !isMaxCountReached
                button.alpha = button.isEnabled ? 1.0 : 0.3
            }
        }

        DispatchQueue.main.async {
            self.updateNumberButtonAppearance()
        }

    }

    private func updateNumberButtonAppearance() {
        for button in self.numberButtons {
            button.setNeedsDisplay()
            button.setNeedsLayout()
        }
    }

    private func isPuzzleCompleted() -> Bool {
        guard let puzzleData = puzzleData else { return false }
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if puzzleData.puzzle[row][col] != puzzleData.solution[row][col] {
                    return false
                }
            }
        }
        return true
    }
    //MARK: Undo
    @objc func undoTapped() {
        guard let currentPuzzleData = puzzleData else { return }
        
        guard undoCount < currentPuzzleData.undoLimit else {
            let alert = UIAlertController(
                title: "Undo Limit Reached",
                message: "You have used all available undo actions.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        guard !undoStack.isEmpty else { return }
        let lastMove = undoStack.removeLast()
        
        if var puzzleData = puzzleData {
            let previousState = (
                row: lastMove.row,
                column: lastMove.column,
                number: puzzleData.puzzle[lastMove.row][lastMove.column]
            )

            puzzleData.puzzle[lastMove.row][lastMove.column] = lastMove.number
            self.puzzleData = puzzleData
            redoStack.append(previousState)

            let indexPath = IndexPath(row: lastMove.row * gridSize + lastMove.column, section: 0)
            selectedIndexPath = indexPath
            currentNumber = nil

            collectionView.reloadData()
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)

            DispatchQueue.main.async {
                self.toggleNumberButtons(enabled: true)
                self.updateNumberButtonAppearance()
                
                for button in self.numberButtons {
                    button.isEnabled = !self.isNumberDisabled(button)
                    button.alpha = button.isEnabled ? 1.0 : 0.3
                    button.setNeedsDisplay()
                    button.setNeedsLayout()
                    button.layoutIfNeeded()
                }
            }
        }
        
        undoCount += 1

        if selectedIndexPath != nil {
            toggleNumberButtons(enabled: true)
        }
    }
    //MARK: Redo
    @objc func redoTapped() {
        guard let currentPuzzleData = puzzleData else { return }
        
        guard redoCount < currentPuzzleData.redoLimit else {
            let alert = UIAlertController(
                title: "Redo Limit Reached",
                message: "You have used all available redo actions.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        guard !redoStack.isEmpty else { return }
        let lastRedo = redoStack.removeLast()
        
        if var puzzleData = puzzleData {
            let currentState = (
                row: lastRedo.row,
                column: lastRedo.column,
                number: puzzleData.puzzle[lastRedo.row][lastRedo.column]
            )

            puzzleData.puzzle[lastRedo.row][lastRedo.column] = lastRedo.number
            self.puzzleData = puzzleData

            undoStack.append(currentState)

            let indexPath = IndexPath(row: lastRedo.row * gridSize + lastRedo.column, section: 0)

            currentNumber = lastRedo.number
            selectedIndexPath = indexPath

            collectionView.reloadData()
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)

            redoCount += 1

            DispatchQueue.main.async {
                self.toggleNumberButtons(enabled: true)
                self.updateNumberButtonAppearance()
                
                for button in self.numberButtons {
                    button.isEnabled = !self.isNumberDisabled(button)
                    button.alpha = button.isEnabled ? 1.0 : 0.3
                    button.setNeedsDisplay()
                    button.setNeedsLayout()
                    button.layoutIfNeeded()
                }
            }

            if selectedIndexPath != nil {
                toggleNumberButtons(enabled: true)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self else { return }

                self.animateCompletedSections(at: indexPath)

                if self.isPuzzleCompleted() {
                    self.navigateToNextScreen()
                }
            }
        }
    }
    //MARK: Reset
    @objc func resetTapped() {
        guard let currentDifficulty = selectedDifficulty else {
            return
        }

        undoStack.removeAll()
        redoStack.removeAll()

        hintsUsed = 0
        undoCount = 0
        redoCount = 0
        wrongEntryCount = 0
        
        isNotesMode = false
        if let noteButton = noteButtonContainer?.subviews.first as? UIButton {
            noteButton.tintColor = .white
        }

        selectedIndexPath = nil
        currentNumber = nil
        cellNotes.removeAll()

        fetchPuzzleData(difficulty: currentDifficulty)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.collectionView.reloadData()
            self.toggleNumberButtons(enabled: false)

            self.updateNumberButtonAppearance()
            
            for button in self.numberButtons {
                button.isEnabled = !self.isNumberDisabled(button)
                button.alpha = button.isEnabled ? 1.0 : 0.3
                button.setNeedsDisplay()
                button.setNeedsLayout()
                button.layoutIfNeeded()
            }
        }
    }
    //MARK: Hint
    @objc func hintTapped() {
        guard let selectedIndexPath = selectedIndexPath else {
            print("Please select a cell first")
            return
        }
        guard var puzzleData = puzzleData else {
            print("No puzzle data available")
            return
        }
        guard hintsUsed < puzzleData.hintLimit else {
            let alert = UIAlertController(
                title: "No More Hints",
                message: "You have used all available hints (\(puzzleData.hintLimit) total)",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let row = selectedIndexPath.row / gridSize
        let column = selectedIndexPath.row % gridSize
        
        let currentValue = puzzleData.puzzle[row][column]
        let correctValue = puzzleData.solution[row][column]
        
        if currentValue == correctValue {
            return
        }
        
        undoStack.append((row: row, column: column, number: currentValue))
        redoStack.removeAll()

        puzzleData.puzzle[row][column] = correctValue
        self.puzzleData = puzzleData
        hintsUsed += 1

        currentNumber = correctValue

        if hintsUsed == puzzleData.hintLimit {
            let alert = UIAlertController(
                title: "Last Hint Used",
                message: "You have used all available hints",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }

        collectionView.reloadData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }

            self.animateCompletedSections(at: selectedIndexPath)

            if self.isPuzzleCompleted() {
                self.navigateToNextScreen()
            }
        }
    }
    //MARK: Note
    @objc func noteTapped(_ sender: UIButton) {
        isNotesMode = !isNotesMode
        sender.tintColor = isNotesMode ? .yellow : .white
    }

    func updatePuzzle(with number: Int, at indexPath: IndexPath) {
        guard var puzzleData = self.puzzleData else { return }
        
        let row = indexPath.row / gridSize
        let column = indexPath.row % gridSize

        undoStack.append((row: row, column: column, number: puzzleData.puzzle[row][column]))
        redoStack.removeAll()

        puzzleData.puzzle[row][column] = number
        self.puzzleData = puzzleData

        collectionView.reloadItems(at: [indexPath])
    }
    
    //MARK: Travelling Light
    private var isAnimating = false
    private func animateCompletedSections(at indexPath: IndexPath) {
        guard !isAnimating else { return }
        isAnimating = true
        let row = indexPath.row / gridSize
        let col = indexPath.row % gridSize
        let boxRow = (row / 3) * 3
        let boxCol = (col / 3) * 3

        func isSectionComplete(type: String, index: Int) -> [IndexPath]? {
            guard let puzzle = puzzleData?.puzzle,
                  let solution = puzzleData?.solution else { return nil }
            
            var isComplete = false
            var cellsToAnimate: [IndexPath] = []
            
            switch type {
            case "row":
                isComplete = (0..<gridSize).allSatisfy { c in
                    puzzle[index][c] == solution[index][c]
                }
                if isComplete {
                    cellsToAnimate = (0..<gridSize).map { c in
                        IndexPath(item: index * gridSize + c, section: 0)
                    }
                }
                
            case "column":
                isComplete = (0..<gridSize).allSatisfy { r in
                    puzzle[r][index] == solution[r][index]
                }
                if isComplete {
                    cellsToAnimate = (0..<gridSize).map { r in
                        IndexPath(item: r * gridSize + index, section: 0)
                    }
                }
                
            case "box":
                let startRow = (index / 3) * 3
                let startCol = (index % 3) * 3
                isComplete = true
                
                for r in startRow..<(startRow + 3) {
                    for c in startCol..<(startCol + 3) {
                        if puzzle[r][c] != solution[r][c] {
                            isComplete = false
                            break
                        }
                    }
                }
                
                if isComplete {
                    for r in 0..<3 {
                        for c in 0..<3 {
                            let fullRow = startRow + r
                            let fullCol = startCol + c
                            cellsToAnimate.append(IndexPath(item: fullRow * gridSize + fullCol, section: 0))
                        }
                    }
                }
            default:
                break
            }
            
            return isComplete ? cellsToAnimate : nil
        }
        
        var sectionsToAnimate: [[IndexPath]] = []

        if let rowCells = isSectionComplete(type: "row", index: row) {
            sectionsToAnimate.append(rowCells)
        }

        if let colCells = isSectionComplete(type: "column", index: col) {
            sectionsToAnimate.append(colCells)
        }

        let boxIndex = (boxRow / 3) * 3 + (boxCol / 3)
        if let boxCells = isSectionComplete(type: "box", index: boxIndex) {
            sectionsToAnimate.append(boxCells)
        }

        func animateNextSection(_ sections: [[IndexPath]], currentSectionIndex: Int = 0) {
            guard currentSectionIndex < sections.count else {
                isAnimating = false
                return
            }
            
            func animateCell(_ cells: [IndexPath], currentCellIndex: Int = 0) {
                guard currentCellIndex < cells.count else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        animateNextSection(sections, currentSectionIndex: currentSectionIndex + 1)
                    }
                    return
                }

                let indices = [
                    currentCellIndex,
                    currentCellIndex + 1,
                    currentCellIndex + 2
                ].filter { $0 < cells.count }
                
                var animatedCells: [(SudokuCell, UIColor)] = []

                for index in indices {
                    if let cell = collectionView.cellForItem(at: cells[index]) as? SudokuCell {
                        animatedCells.append((cell, cell.contentView.backgroundColor ?? .white))
                    }
                }

                UIView.animate(withDuration: 0.1, animations: {
                    for (cell, _) in animatedCells {
                        cell.contentView.backgroundColor = UIColor(red: 163/255, green: 226/255, blue: 245/255, alpha: 1.0)
                    }
                }) { _ in
                    UIView.animate(withDuration: 0.08, animations: {
                        for (cell, originalColor) in animatedCells {
                            cell.contentView.backgroundColor = originalColor
                        }
                    }) { _ in
                        animateCell(cells, currentCellIndex: currentCellIndex + 3)
                    }
                }
            }
            animateCell(sections[currentSectionIndex])
        }
        
        if !sectionsToAnimate.isEmpty {
            animateNextSection(sectionsToAnimate)
        } else {
            isAnimating = false
        }
    }
    
    private func isNumberConflicting(_ number: Int, at row: Int, column: Int) -> Bool {
        guard let puzzle = puzzleData?.puzzle else { return false }
        for c in 0..<gridSize {
            if puzzle[row][c] == number {
                return true
            }
        }
        for r in 0..<gridSize {
            if puzzle[r][column] == number {
                return true
            }
        }
        let boxRow = (row / 3) * 3
        let boxCol = (column / 3) * 3
        for r in boxRow..<(boxRow + 3) {
            for c in boxCol..<(boxCol + 3) {
                if puzzle[r][c] == number {
                    return true
                }
            }
        }
        
        return false
    }
    //MARK: Number Button
    @objc func numberButtonTapped(_ sender: UIButton) {
        guard let selectedIndexPath = selectedIndexPath,
              let numberString = sender.titleLabel?.text,
              let number = Int(numberString) else { return }
        
        let row = selectedIndexPath.row / gridSize
        let column = selectedIndexPath.row % gridSize
        
        if initialPuzzle[row][column] != 0 {
            return
        }

        if isNotesMode {
            if puzzleData?.puzzle[row][column] != 0 {
                print("Note mode is disabled for filled cells!")
                return
            }
            if isNumberConflicting(number, at: row, column: column) {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                highlightCellsForNumber(number: number, at: selectedIndexPath)
                return
            }
            if cellNotes[selectedIndexPath] == nil {
                cellNotes[selectedIndexPath] = Set<Int>()
            }
            if cellNotes[selectedIndexPath]?.contains(number) == true {
                cellNotes[selectedIndexPath]?.remove(number)
            } else {
                cellNotes[selectedIndexPath]?.insert(number)
            }

            if let cell = collectionView.cellForItem(at: selectedIndexPath) as? SudokuCell {
                cell.configure(
                    with: nil,
                    isInitial: false,
                    isIncorrect: false,
                    correctNumber: puzzleData?.solution[row][column],
                    notes: Array(cellNotes[selectedIndexPath] ?? []).sorted()
                )
            }
            highlightCellsForNumber(number: number, at: selectedIndexPath)
        } else {
            cellNotes[selectedIndexPath] = nil
            
            guard var puzzleData = puzzleData else { return }
            
            let previousNumber = puzzleData.puzzle[row][column]// Store the number before replacing it

            undoStack.append((row: row, column: column, number: puzzleData.puzzle[row][column]))
            redoStack.removeAll()

            let correctNumber = puzzleData.solution[row][column]
            let isIncorrect = number != correctNumber
            
            if isIncorrect {
                wrongEntryCount += 1
                toggleNumberButtons(enabled: true, forEmptyCell: true)
            }

            puzzleData.puzzle[row][column] = number
            self.puzzleData = puzzleData
            
            // Re-enable the previous number's button if occurrences drop below 9
            if previousNumber != 0 {
                let previousOccurrences = countNumberOccurrences(previousNumber) - 1
                if previousOccurrences < 9 {
                    if let button = self.numberButtons.first(where: { $0.titleLabel?.text == "\(previousNumber)" }) {
                        button.isEnabled = true
                        button.alpha = 1.0
                    }
                }
            }

            if let cell = collectionView.cellForItem(at: selectedIndexPath) as? SudokuCell {
                cell.configure(
                    with: number,
                    isInitial: false,
                    isIncorrect: isIncorrect,
                    correctNumber: correctNumber
                )
                cell.layoutIfNeeded()
            }
            
            currentNumber = number
            collectionView.reloadData()

            let occurrences = countNumberOccurrences(number)
            if occurrences == 9 {
                blinkCells(for: number)
            }
            let shouldDisableNumber = occurrences >= 9
            
            toggleNumberButtons(enabled: true)

            DispatchQueue.main.async {
                self.updateNumberButtonAppearance()

                if shouldDisableNumber {
                    if let button = self.numberButtons.first(where: { $0.titleLabel?.text == "\(number)" }) {
                        button.isEnabled = false
                        button.alpha = 0.3
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    guard let self = self else { return }

                    self.animateCompletedSections(at: selectedIndexPath)

                    if self.isPuzzleCompleted() {
                        self.navigateToNextScreen()
                    }
                }
            }
        }
        self.updateNumberButtonAppearance()
    }
    
    var blinkingCells: Set<IndexPath> = []

    func blinkCells(for number: Int) {
        var cellsToBlink: [IndexPath] = []

        for row in 0..<gridSize {
            for column in 0..<gridSize {
                if puzzleData?.puzzle[row][column] == number {
                    let indexPath = IndexPath(row: row * gridSize + column, section: 0)
                    cellsToBlink.append(indexPath)
                }
            }
        }

        guard !cellsToBlink.isEmpty else { return }

        // **Cancel all ongoing animations & reset previous blinking cells**
        for indexPath in blinkingCells {
            if let cell = collectionView.cellForItem(at: indexPath) {
                cell.layer.removeAllAnimations()  // **Stop animation immediately**
                cell.contentView.backgroundColor = UIColor.white  // **Reset to default**
            }
        }
        blinkingCells.removeAll()  // Clear old blinking cells

        blinkingCells = Set(cellsToBlink)  // Store new blinking cells
        collectionView.reloadItems(at: cellsToBlink) // **Ensure UI updates properly**

        DispatchQueue.main.async {
            for indexPath in cellsToBlink {
                if let cell = self.collectionView.cellForItem(at: indexPath) {
                    let originalColor = UIColor.white
                    let blinkColor = UIColor.systemBlue.withAlphaComponent(0.5)

                    UIView.animateKeyframes(withDuration: 1.2, delay: 0, options: [], animations: {
                        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25) {
                            cell.contentView.backgroundColor = blinkColor
                        }
                        UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) {
                            cell.contentView.backgroundColor = originalColor
                        }
                        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25) {
                            cell.contentView.backgroundColor = blinkColor
                        }
                        UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
                            cell.contentView.backgroundColor = originalColor
                        }
                    }) { _ in
                        self.blinkingCells.remove(indexPath)
                        self.collectionView.reloadItems(at: [indexPath])
                    }
                }
            }
        }
    }

    func highlightCellsForNumber(number: Int, at indexPath: IndexPath) {
        let gridSize = 9
        var highlightedIndexPaths: Set<IndexPath> = []
        let row = indexPath.row / gridSize
        let column = indexPath.row % gridSize
        let startRow = (row / 3) * 3
        let startColumn = (column / 3) * 3
        for r in startRow..<startRow+3 {
            for c in startColumn..<startColumn+3 {
                if puzzleData?.puzzle[r][c] == number {
                    highlightedIndexPaths.insert(IndexPath(row: r * gridSize + c, section: 0))
                }
            }
        }
        for c in 0..<gridSize {
            if puzzleData?.puzzle[row][c] == number {
                highlightedIndexPaths.insert(IndexPath(row: row * gridSize + c, section: 0))
            }
        }
        for r in 0..<gridSize {
            if puzzleData?.puzzle[r][column] == number {
                highlightedIndexPaths.insert(IndexPath(row: r * gridSize + column, section: 0))
            }
        }

        var originalColors: [IndexPath: UIColor] = [:]

        for indexPath in highlightedIndexPaths {
            if let cell = collectionView.cellForItem(at: indexPath) as? SudokuCell {
                let originalColor = cell.contentView.backgroundColor ?? UIColor.white
                originalColors[indexPath] = originalColor
                cell.contentView.backgroundColor = UIColor.gray
            }
        }

        var isHighlighted = true

        let blinkDuration: TimeInterval = 0.1
        let totalBlinkTime: TimeInterval = 0.5

        let blinkTimer = Timer.scheduledTimer(withTimeInterval: blinkDuration, repeats: true) { _ in
            for indexPath in highlightedIndexPaths {
                if let cell = self.collectionView.cellForItem(at: indexPath) as? SudokuCell {
                    if isHighlighted {
                        cell.contentView.backgroundColor = UIColor.gray
                    } else {
                        if let originalColor = originalColors[indexPath] {
                            cell.contentView.backgroundColor = originalColor
                        }
                    }
                }
            }
            isHighlighted.toggle()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + totalBlinkTime) {
            blinkTimer.invalidate()
            for indexPath in highlightedIndexPaths {
                if let cell = self.collectionView.cellForItem(at: indexPath) as? SudokuCell {
                    if let originalColor = originalColors[indexPath] {
                        cell.contentView.backgroundColor = originalColor
                    }
                }
            }
        }
    }

    @objc func navigateToNextScreen() {
        stopTimer()
        print("Total Time Taken: \(elapsedTime) seconds")

        let elapsedSeconds = elapsedTime
        let conversionTime = formatTime(seconds: elapsedSeconds)
        print("Formatted Time: \(conversionTime)")

        var totalScore = 100
        var timeBonus = 0
        switch selectedDifficulty {
            case "Beginner":
                timeBonus = elapsedSeconds < 240 ? 10 : 0
            case "Easy":
                timeBonus = elapsedSeconds < 300 ? 10 : 0
            case "Medium":
                timeBonus = elapsedSeconds < 360 ? 10 : 0
            case "Hard":
                timeBonus = elapsedSeconds < 420 ? 10 : 0
            case "Expert":
                timeBonus = elapsedSeconds < 480 ? 10 : 0
            default:
                timeBonus = 0
        }
        totalScore += timeBonus
        totalScore -= (hintsUsed * 3) + (redoCount * 1) + (undoCount * 1) + (wrongEntryCount * 2)
        totalScore = max(totalScore, 0)

        let riderID = 2
        let eventID = puzzleData?.eventID ?? "Unknown"
        let puzzleDate = puzzleData?.puzzleDate ?? ""
        let negativePoints = wrongEntryCount * 2
        let redo = redoCount * 1
        let undo = undoCount * 1
        let hint = hintsUsed * 3
        let category = selectedDifficulty ?? "easy"

        var playedDates = UserDefaults.standard.stringArray(forKey: "PlayedDates") ?? []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        guard let currentDate = dateFormatter.date(from: puzzleDate) else {
            print("Invalid puzzle date format")
            return
        }

        if !playedDates.contains(puzzleDate) {
            playedDates.append(puzzleDate)
            UserDefaults.standard.set(playedDates, forKey: "PlayedDates")
        }

        let sortedDates = playedDates.compactMap { dateFormatter.date(from: $0) }.sorted()

        var shouldShowStreakCelebration = false
        let streakBonusGivenKey = "StreakBonusGiven_\(puzzleDate)"
        let firstGamePlayedTodayKey = "FirstGamePlayedToday_\(puzzleDate)"

        if isSevenDayStreak(sortedDates, currentDate) {
            let hasReceivedBonus = UserDefaults.standard.bool(forKey: streakBonusGivenKey)
            let firstGamePlayedToday = UserDefaults.standard.bool(forKey: firstGamePlayedTodayKey)

            if !hasReceivedBonus && !firstGamePlayedToday {
                totalScore += 70
                print("7-Day Streak Achieved! +70 Bonus Points")

                UserDefaults.standard.set(true, forKey: streakBonusGivenKey)
                UserDefaults.standard.set(true, forKey: firstGamePlayedTodayKey)
                UserDefaults.standard.set(true, forKey: "StreakAchieved_\(puzzleDate)")
                
                shouldShowStreakCelebration = true
            } else {
                print("7-Day Streak but bonus already given today.")
            }
        } else {
            print("No 7-day streak, no extra points")
        }

        submitGameData(
            riderID: riderID,
            eventID: eventID,
            puzzleDate: puzzleDate,
            negativePoints: negativePoints,
            redo: redo,
            undo: undo,
            hint: hint,
            totalPoints: totalScore,
            timeTaken: conversionTime,
            category: category
        ) { [weak self] (success: Bool) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                let nextVC = PointsScreen()
                nextVC.elapsedTime = conversionTime
                nextVC.undoCount = undo
                nextVC.redoCount = redo
                nextVC.hintsUsed = hint
                nextVC.wrongEntryCount = negativePoints
                nextVC.selectedDifficulty = category
                nextVC.points = totalScore
                nextVC.timeBonus = timeBonus
                nextVC.shouldShowStreakCelebration = shouldShowStreakCelebration

                self.navigationController?.pushViewController(nextVC, animated: true)
            }
        }
    }
    
    private func isSevenDayStreak(_ dates: [Date], _ currentDate: Date) -> Bool {
        let calendar = Calendar.current
        guard dates.count >= 7 else { return false }
        
        let sortedDates = dates.sorted()
        var streakCount = 1
        var lastDate = sortedDates.last!

        for i in stride(from: sortedDates.count - 2, through: 0, by: -1) {
            let previousDate = sortedDates[i]
            
            if let expectedDate = calendar.date(byAdding: .day, value: -1, to: lastDate),
               calendar.isDate(previousDate, inSameDayAs: expectedDate) {
                streakCount += 1
                lastDate = previousDate
            } else {
                break
            }
        }

        if streakCount == 7, calendar.isDate(sortedDates.last!, inSameDayAs: currentDate) {
            return true
        }
        
        return false
    }

    private func formatTime(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }

    private func submitGameData(
        riderID: Int,
        eventID: String,
        puzzleDate: String,
        negativePoints: Int,
        redo: Int,
        undo: Int,
        hint: Int,
        totalPoints: Int,
        timeTaken: String,
        category: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard !hasSubmittedGameData else {
            print("Game data already submitted, skipping duplicate call.")
            return
        }
        
        hasSubmittedGameData = true

        let url = URL(string: APIEndpoints.submitGameURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "rider_id": riderID,
            "event_id": eventID,
            "negative_points": negativePoints,
            "redo": redo,
            "undo": undo,
            "hint": hint,
            "total_points": totalPoints,
            "submit_date": puzzleDate,
            "time_taken": timeTaken,
            "category": category
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error submitting game data: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                print("Server error: Invalid response")
                completion(false)
                return
            }

            DispatchQueue.main.async {
                completion(true)
            }
        }

        task.resume()
    }

    
    private func stopTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    @objc private func clearButtonTapped() {
        guard let selectedIndexPath = selectedIndexPath else {
            print("Select a cell")
            return
        }
        
        let row = selectedIndexPath.row / gridSize
        let column = selectedIndexPath.row % gridSize
        
        guard let puzzleData = puzzleData else {
            print("PuzzleData is nil")
            return
        }

        if initialPuzzle[row][column] != 0 {
            print("Cannot clear initial numbers")
            return
        }

        undoStack.append((row: row, column: column, number: puzzleData.puzzle[row][column]))
        redoStack.removeAll()

        cellNotes[selectedIndexPath] = nil
        var updatedPuzzleData = puzzleData
        updatedPuzzleData.puzzle[row][column] = 0
        self.puzzleData = updatedPuzzleData
        currentNumber = nil

        resetCellHighlights(excluding: selectedIndexPath)

        DispatchQueue.main.async {
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadItems(at: [selectedIndexPath])
            }, completion: { _ in
                self.toggleNumberButtons(enabled: true)
                
                self.updateNumberButtonAppearance()

                for button in self.numberButtons {
                    button.isEnabled = !self.isNumberDisabled(button)
                    button.alpha = button.isEnabled ? 1.0 : 0.3
                    button.setNeedsDisplay()
                    button.setNeedsLayout()
                    button.layoutIfNeeded()
                }
            })
        }
    }
    
    private func isNumberDisabled(_ button: UIButton) -> Bool {
        guard let title = button.titleLabel?.text, let number = Int(title) else { return false }
        return countNumberOccurrences(number) >= 9
    }

    private func resetCellHighlights(excluding excludedIndexPath: IndexPath?) {
        for cellIndexPath in collectionView.indexPathsForVisibleItems {
            guard let cell = collectionView.cellForItem(at: cellIndexPath) as? SudokuCell else { continue }

            if let savedColorHex = UserDefaults.standard.string(forKey: "selectedGridColor") {
                let savedColor = UIColor(hex: savedColorHex)
                cell.contentView.backgroundColor = savedColor
            } else {
                cell.contentView.backgroundColor = UIColor.white
            }

            cell.contentView.layer.borderWidth = 0
            cell.contentView.layer.borderColor = UIColor.clear.cgColor

            guard let excludedIndexPath = excludedIndexPath else { continue }
            
            let excludedRow = excludedIndexPath.row / gridSize
            let excludedColumn = excludedIndexPath.row % gridSize

            let isInSameRow = cellIndexPath.row / gridSize == excludedRow
            let isInSameColumn = cellIndexPath.row % gridSize == excludedColumn
            let isInSameBox = (cellIndexPath.row / gridSize / 3 == excludedRow / 3) && (cellIndexPath.row % gridSize / 3 == excludedColumn / 3)

            if isInSameRow || isInSameColumn || isInSameBox {
                cell.contentView.backgroundColor = UIColor(red: 0.89, green: 0.97, blue: 0.99, alpha: 1.0)
            }
        }
    }

//    private func highlightCellsWithSameNumber(excluding excludedIndexPath: IndexPath?) {
//        guard let currentNumber = currentNumber else { return }
//
//        for row in 0..<gridSize {
//            for col in 0..<gridSize {
//                let cellIndexPath = IndexPath(row: row * gridSize + col, section: 0)
//                guard let cell = collectionView.cellForItem(at: cellIndexPath) as? SudokuCell else { continue }
//                if puzzleData?.puzzle[row][col] == currentNumber, cellIndexPath != excludedIndexPath {
//                    cell.contentView.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
//                    cell.contentView.layer.borderWidth = 2
//                    cell.contentView.layer.borderColor = UIColor(red: 32/255, green: 152/255, blue: 185/255, alpha: 1.0).cgColor
//                }
//            }
//        }
//    }
//
//    private func numberExistsInRow(_ number: Int, row: Int) -> Bool {
//        guard let puzzleData = puzzleData else { return false }
//        return puzzleData.puzzle[row].contains(number)
//    }
//    
//    private func numberExistsInColumn(_ number: Int, column: Int) -> Bool {
//        guard let puzzleData = puzzleData else { return false }
//        for row in 0..<gridSize {
//            if puzzleData.puzzle[row][column] == number {
//                return true
//            }
//        }
//        return false
//    }
//    
//    private func numberExistsInBox(_ number: Int, row: Int, column: Int) -> Bool {
//        guard let puzzleData = puzzleData else { return false }
//        
//        let boxRow = (row / 3) * 3
//        let boxColumn = (column / 3) * 3
//        
//        for r in boxRow..<(boxRow + 3) {
//            for c in boxColumn..<(boxColumn + 3) {
//                if puzzleData.puzzle[r][c] == number {
//                    return true
//                }
//            }
//        }
//        return false
//    }
//    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isAnimating else { return }
        
        let row = indexPath.row / gridSize
        let column = indexPath.row % gridSize
        let isCellEmpty = puzzleData?.puzzle[row][column] == 0
        if selectedIndexPath == indexPath {
            return
        }
        selectedIndexPath = indexPath
        if let puzzleData = puzzleData {
            let cellValue = puzzleData.puzzle[row][column]
            currentNumber = cellValue != 0 ? cellValue : nil
        }
        toggleNumberButtons(enabled: true, forEmptyCell: isCellEmpty)
        collectionView.reloadData()
    }
    
    //MARK: API call
    private func fetchPuzzleData(difficulty: String) {
        let difficult = difficulty.prefix(1).lowercased() + difficulty.dropFirst()
        print("Fetching puzzle with difficulty: \(difficult)")
        
        let urlString = APIEndpoints.baseSudokuURL + difficult + "/"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching puzzle: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let puzzleString = json["puzzle"] as? String,
                   let solutionString = json["solution"] as? String,
                   let sudokuID = json["sudoku_id"] as? Int,
                   let category = json["category"] as? String,
                   let eventID = json["event_id"] as? String,
                   let puzzleDate = json["puzzle_date"] as? String,
                   let status = json["status"] as? Bool,
                   let undoLimit = json["undo_limit"] as? Int,
                   let redoLimit = json["redo_limit"] as? Int,
                   let hintLimit = json["hint_limit"] as? Int {
                    
                    let puzzle = self.parsePuzzleString(puzzleString)
                    let solution = self.parsePuzzleString(solutionString)
                    
                    self.initialPuzzle = puzzle.map { $0.map { $0 } }
                    
                    DispatchQueue.main.async {
                        self.puzzleData = PuzzleData(
                            sudokuID: sudokuID,
                            category: category,
                            eventID: eventID,
                            puzzle: puzzle,
                            solution: solution,
                            puzzleDate: puzzleDate,
                            status: String(status),
                            undoLimit: undoLimit,
                            redoLimit: redoLimit,
                            hintLimit: hintLimit
                        )
                        self.collectionView.reloadData()
                        self.updateHintCountLabel()
                        self.savePlayedDate(puzzleDate)

                        self.selectedIndexPath = nil
                        self.toggleNumberButtons(enabled: false)
                        
                        for button in self.numberButtons {
                            button.isEnabled = false
                            button.alpha = 0.3
                            button.setNeedsDisplay()
                            button.setNeedsLayout()
                            button.layoutIfNeeded()
                        }
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        
        task.resume()
    }
    
    private func savePlayedDate(_ date: String) {
        var playedDates = UserDefaults.standard.stringArray(forKey: "PlayedDates") ?? []
        
        if !playedDates.contains(date) {
            playedDates.append(date)
            UserDefaults.standard.set(playedDates, forKey: "PlayedDates")
        }
    }
    
    private func parsePuzzleString(_ puzzleString: String) -> [[Int]] {
        var puzzle = [[Int]]()
        if let data = puzzleString.data(using: .utf8) {
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[Int]] {
                    puzzle = jsonArray
                    print("Successfully parsed puzzle: \(puzzle)")
                } else {
                    print("Failed to parse puzzle as [[Int]]")
                }
            } catch {
                print("Error parsing puzzle string: \(error)")
            }
        }
        return puzzle
    }
    
    private func updateHintCountLabel() {
        if let puzzleData = puzzleData {
            let remainingHints = puzzleData.hintLimit - hintsUsed
            hintCountLabel.text = "\(remainingHints)"
        }
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gridSize * gridSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SudokuCell.identifier, for: indexPath) as! SudokuCell
        let row = indexPath.row / gridSize
        let column = indexPath.row % gridSize
        cell.updateBorder(row: row, column: column)

        if blinkingCells.contains(indexPath) {
            cell.contentView.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        }else if let savedColorHex = UserDefaults.standard.string(forKey: "selectedGridColor") {
            let savedColor = UIColor(hex: savedColorHex)
            cell.contentView.backgroundColor = savedColor
        } else {
            cell.contentView.backgroundColor = UIColor.white
        }

        if let puzzle = puzzleData?.puzzle {
            let cellValue = puzzle[row][column]
            let isInitial = initialPuzzle[row][column] != 0
            let correctNumber = puzzleData?.solution[row][column]

            cell.configure(
                with: cellValue == 0 ? nil : cellValue,
                isInitial: isInitial,
                isIncorrect: cellValue != 0 && cellValue != correctNumber,
                correctNumber: correctNumber,
                notes: Array(cellNotes[indexPath] ?? []).sorted()
            )

            if let savedColorHex = UserDefaults.standard.string(forKey: "selectedGridColor") {
                let savedColor = UIColor(hex: savedColorHex)
                cell.contentView.backgroundColor = savedColor
            } else {
                cell.contentView.backgroundColor = UIColor.white
            }
            cell.contentView.layer.borderWidth = 0
            cell.contentView.layer.borderColor = UIColor.clear.cgColor

            if cellValue != 0 && cellValue == currentNumber {
                cell.contentView.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
                cell.contentView.layer.borderWidth = 2
                cell.contentView.layer.borderColor = UIColor(red: 32/255, green: 152/255, blue: 185/255, alpha: 1.0).cgColor
            }
//            else if cellValue != 0 && cellValue != correctNumber {
//                cell.contentView.layer.borderWidth = 2
//                cell.contentView.layer.borderColor = UIColor.red.cgColor
//                cell.contentView.backgroundColor = UIColor(red: 1.0, green: 0.92, blue: 0.93, alpha: 1.0)
//            }
            else if indexPath == selectedIndexPath {
                cell.contentView.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
                cell.contentView.layer.borderWidth = 2
                cell.contentView.layer.borderColor = UIColor(red: 32/255, green: 152/255, blue: 185/255, alpha: 1.0).cgColor
            }
            else if let currentNum = currentNumber, cellValue == currentNum {
                cell.contentView.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
                cell.contentView.layer.borderWidth = 2
                cell.contentView.layer.borderColor = UIColor(red: 32/255, green: 152/255, blue: 185/255, alpha: 1.0).cgColor
            }
            else if let selectedIndexPath = selectedIndexPath {
                let selectedRow = selectedIndexPath.row / gridSize
                let selectedColumn = selectedIndexPath.row % gridSize
                let isInSameRow = row == selectedRow
                let isInSameColumn = column == selectedColumn
                let isInSameBox = (row / 3 == selectedRow / 3) && (column / 3 == selectedColumn / 3)
                
                if isInSameRow || isInSameColumn || isInSameBox {
                    cell.contentView.backgroundColor = UIColor(red: 0.89, green: 0.97, blue: 0.99, alpha: 1.0)
                }
            }
        } else {
            cell.configure(with: nil)
        }

        return cell
    }

    // MARK: - Collection View Flow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / CGFloat(gridSize)
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension SudokuStartVC {
    private func toggleNumberButtons(enabled: Bool) {
        for button in numberButtons {
            if button.titleLabel?.text == "0" {
                button.isEnabled = true
            }
            else{
                button.isEnabled = enabled
            }
        }
    }
}
