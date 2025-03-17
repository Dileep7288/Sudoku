import UIKit

enum SudokuPuzzle {
    struct PuzzleData {
        let sudokuID: Int
        let category: String
        let eventID: String
        var puzzle: [[Int]]
        let solution: [[Int]]
        let puzzleDate: String
        let status: String
        let undoLimit: Int
        let redoLimit: Int
        let hintLimit: Int
    }
}

class SudokuStartVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView!
    let gridSize = 9
    var puzzleData: SudokuPuzzle.PuzzleData?
    var selectedDifficulty: String?
    var selectedIndexPath: IndexPath?
    var currentNumber: Int? // Track the last selected number
    
    // Undo/Redo stacks
    private var undoStack: [(row: Int, column: Int, number: Int)] = []
    private var redoStack: [(row: Int, column: Int, number: Int)] = []
    
    // Hint related
    private var hintsUsed: Int = 0
    
    // MARK: - Background Image View
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "background_image")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Action Stack View
    let actionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // Difficulty label
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
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 65),
                button.heightAnchor.constraint(equalToConstant: 65)
            ])
            
            return button
        }
        
        let xButton = UIButton(type: .system)
        xButton.setImage(UIImage(named: "clear")?.withRenderingMode(.alwaysTemplate), for: .normal)
        xButton.tintColor = .white
        xButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        xButton.layer.cornerRadius = 8
        NSLayoutConstraint.activate([
            xButton.widthAnchor.constraint(equalToConstant: 65),
            xButton.heightAnchor.constraint(equalToConstant: 65)
        ])
        xButton.translatesAutoresizingMaskIntoConstraints = false
        buttons.append(xButton)
        
        return buttons
    }()
    
    private lazy var numberButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let row1 = UIStackView()
        row1.axis = .horizontal
        row1.distribution = .fillEqually
        row1.alignment = .center
        row1.spacing = 10
        
        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.distribution = .fillEqually
        row2.alignment = .center
        row2.spacing = 10
        
        for (index, button) in numberButtons.enumerated() {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupActionStackView()
        setupDifficultyLabel()
        setupCollectionView()
        setupNumberButtonStackView()
        setupNumberButtonActions()
        fetchPuzzleData(difficulty: selectedDifficulty ?? "medium")
        // Disable number buttons initially
        toggleNumberButtons(enabled: false)
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
        
        let undoButton = createActionButton(imageName: "arrow.uturn.left", title: "Undo", action: #selector(undoTapped))
        let redoButton = createActionButton(imageName: "arrow.uturn.right", title: "Redo", action: #selector(redoTapped))
        let resetButton = createActionButton(imageName: "arrow.clockwise", title: "Reset", action: #selector(resetTapped))
        let hintButton = createActionButton(imageName: "lightbulb", title: "Hint", action: #selector(hintTapped))
        let noteButton = createActionButton(imageName: "note.text", title: "Note", action: #selector(noteTapped))
        
        actionStackView.addArrangedSubview(undoButton)
        actionStackView.addArrangedSubview(redoButton)
        actionStackView.addArrangedSubview(resetButton)
        actionStackView.addArrangedSubview(hintButton)
        actionStackView.addArrangedSubview(noteButton)
        
        NSLayoutConstraint.activate([
            actionStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            actionStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionStackView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func setupDifficultyLabel() {
        view.addSubview(difficultyLabel)
        
        difficultyLabel.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        difficultyLabel.layer.cornerRadius = 5
        difficultyLabel.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            difficultyLabel.topAnchor.constraint(equalTo: actionStackView.bottomAnchor, constant: 10),
            difficultyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 150),
            difficultyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -150),
            difficultyLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        if let difficulty = selectedDifficulty {
            difficultyLabel.text = "\(difficulty.capitalized)"
        }
    }
    
    private func createActionButton(imageName: String, title: String, action: Selector) -> UIView {
        let buttonContainer = UIView()
        let button = UIButton(type: .system)
        
        let _: CGFloat = 20
        let image = UIImage(systemName: imageName)!
        button.setImage(image, for: .normal)
        
        
        button.addTarget(self, action: action, for: .touchUpInside)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
            button.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
        ])
        
        let label = UILabel()
        label.text = title
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        buttonContainer.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 5),
            label.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor)
        ])
        
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        return buttonContainer
    }
    
    private func setupNumberButtonStackView() {
        view.addSubview(numberButtonsStackView)
        
        NSLayoutConstraint.activate([
            numberButtonsStackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            numberButtonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            numberButtonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            numberButtonsStackView.heightAnchor.constraint(equalToConstant: 140)
        ])
    }
    
    private func setupNumberButtonActions() {
        // Add targets for number buttons
        for button in numberButtons {
            button.addTarget(self, action: #selector(numberButtonTapped(_:)), for: .touchUpInside)
        }
    }
    
    @objc func undoTapped() {
        guard !undoStack.isEmpty else { return }
        let lastMove = undoStack.removeLast()
        
        if var puzzleData = puzzleData {
            // Save the current state before undoing
            let currentState = (
                row: lastMove.row,
                column: lastMove.column,
                number: puzzleData.puzzle[lastMove.row][lastMove.column]
            )
            
            // Restore the previous state
            puzzleData.puzzle[lastMove.row][lastMove.column] = lastMove.number
            self.puzzleData = puzzleData
            
            // Add the current state to redo stack
            redoStack.append(currentState)
            
            // Update UI for the specific cell
            let indexPath = IndexPath(row: lastMove.row * gridSize + lastMove.column, section: 0)
            collectionView.reloadItems(at: [indexPath])
        }
        
        // Enable the number buttons if there's a selected cell
        if selectedIndexPath != nil {
            toggleNumberButtons(enabled: true)
        }
    }
    
    @objc func redoTapped() {
        guard !redoStack.isEmpty else { return }
        let lastRedo = redoStack.removeLast()
        
        if var puzzleData = puzzleData {
            // Save the current state before redoing
            let currentState = (
                row: lastRedo.row,
                column: lastRedo.column,
                number: puzzleData.puzzle[lastRedo.row][lastRedo.column]
            )
            
            // Apply the redo state
            puzzleData.puzzle[lastRedo.row][lastRedo.column] = lastRedo.number
            self.puzzleData = puzzleData
            
            // Add the current state to undo stack
            undoStack.append(currentState)
            
            // Update UI for the specific cell
            let indexPath = IndexPath(row: lastRedo.row * gridSize + lastRedo.column, section: 0)
            collectionView.reloadItems(at: [indexPath])
        }
        
        // Enable the number buttons if there's a selected cell
        if selectedIndexPath != nil {
            toggleNumberButtons(enabled: true)
        }
    }
    
    @objc func resetTapped() {
        guard let currentDifficulty = selectedDifficulty else {
            return
        }
        
        // Clear undo/redo stacks
        undoStack.removeAll()
        redoStack.removeAll()
        
        // Reset hints used
        hintsUsed = 0
        
        // Clear selection
        selectedIndexPath = nil
        currentNumber = nil
        
        // Fetch new puzzle
        fetchPuzzleData(difficulty: currentDifficulty)
        
        // Disable number buttons until a cell is selected
        toggleNumberButtons(enabled: false)
    }
    
    @objc func hintTapped() {
        // Check if we have a selected cell
        guard let selectedIndexPath = selectedIndexPath else {
            print("Please select a cell first")
            return
        }
        
        // Check if we have puzzle data
        guard var puzzleData = puzzleData else {
            print("No puzzle data available")
            return
        }
        
        // Check hint limit
        guard hintsUsed < puzzleData.hintLimit else {
            // Show alert for no more hints
            let alert = UIAlertController(
                title: "No More Hints",
                message: "You have used all available hints",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let row = selectedIndexPath.row / gridSize
        let column = selectedIndexPath.row % gridSize
        
        // Check if the cell is empty or has a wrong number
        let currentValue = puzzleData.puzzle[row][column]
        let correctValue = puzzleData.solution[row][column]
        
        if currentValue == correctValue {
            // Cell already has correct value
            print("This cell already has the correct number")
            return
        }
        
        // Save current state for undo
        undoStack.append((row: row, column: column, number: currentValue))
        redoStack.removeAll()
        
        // Update the puzzle with the correct number
        puzzleData.puzzle[row][column] = correctValue
        self.puzzleData = puzzleData
        hintsUsed += 1
        
        // Update the UI
        collectionView.reloadItems(at: [selectedIndexPath])
        
        // Show remaining hints
        print("Hint used. \(puzzleData.hintLimit - hintsUsed) hints remaining")
    }
    
    @objc func noteTapped() {
        print("Note Tapped")
    }
    
    // Update value to puzzle using selectedIndexpath
    func updatePuzzle(with number: Int, at indexPath: IndexPath) {
        guard var puzzleData = self.puzzleData else { return }
        
        let row = indexPath.row / gridSize
        let column = indexPath.row % gridSize
        
        // Save the current state to undo stack
        undoStack.append((row: row, column: column, number: puzzleData.puzzle[row][column]))
        redoStack.removeAll() // Clear redo stack when making a new move
        
        // Update the puzzle with new number
        puzzleData.puzzle[row][column] = number
        self.puzzleData = puzzleData
        
        // Update UI
        collectionView.reloadItems(at: [indexPath])
    }
    
    @objc func numberButtonTapped(_ sender: UIButton) {
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
        
        // Check if it's an initial cell (can't modify initial numbers)
        if puzzleData.puzzle[row][column] != 0 && puzzleData.solution[row][column] == puzzleData.puzzle[row][column] {
            print("Cannot modify initial numbers")
            return
        }
        
        if let numberString = sender.titleLabel?.text, let number = Int(numberString) {
            currentNumber = number
            
            // Save current state to undo stack
            undoStack.append((row: row, column: column, number: puzzleData.puzzle[row][column]))
            redoStack.removeAll()
            
            // Update the puzzle with the new number
            var updatedPuzzleData = puzzleData
            updatedPuzzleData.puzzle[row][column] = number
            self.puzzleData = updatedPuzzleData
            
            // Update UI for this cell only
            collectionView.reloadItems(at: [selectedIndexPath])
        }
    }
    
    // MARK: - Sudoku Validation Methods
    
    private func isValidMove(number: Int, at indexPath: IndexPath) -> Bool {
        guard let puzzleData = puzzleData else { return false }
        
        let row = indexPath.row / gridSize
        let column = indexPath.row % gridSize
        
        return !numberExistsInRow(number, row: row) &&
               !numberExistsInColumn(number, column: column) &&
               !numberExistsInBox(number, row: row, column: column)
    }
    
    private func numberExistsInRow(_ number: Int, row: Int) -> Bool {
        guard let puzzleData = puzzleData else { return false }
        return puzzleData.puzzle[row].contains(number)
    }
    
    private func numberExistsInColumn(_ number: Int, column: Int) -> Bool {
        guard let puzzleData = puzzleData else { return false }
        for row in 0..<gridSize {
            if puzzleData.puzzle[row][column] == number {
                return true
            }
        }
        return false
    }
    
    private func numberExistsInBox(_ number: Int, row: Int, column: Int) -> Bool {
        guard let puzzleData = puzzleData else { return false }
        
        // Get the top-left position of the 3x3 box
        let boxRow = (row / 3) * 3
        let boxColumn = (column / 3) * 3
        
        // Check all cells in the 3x3 box
        for r in boxRow..<(boxRow + 3) {
            for c in boxColumn..<(boxColumn + 3) {
                if puzzleData.puzzle[r][c] == number {
                    return true
                }
            }
        }
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Toggle selection state: deselect if same cell tapped, otherwise select new cell
        if selectedIndexPath == indexPath {
            selectedIndexPath = nil // Deselect
            currentNumber = nil // clear old value
            toggleNumberButtons(enabled: false) // Disable number buttons
        } else {
            selectedIndexPath = indexPath // Select new cell
            // Enable number buttons only if there is value
            toggleNumberButtons(enabled: true)
            // Change the number button color based on the selected cell
            let row = indexPath.row / gridSize
            let column = indexPath.row % gridSize
            let cellValue = puzzleData?.puzzle[row][column] ?? 0
            changeNumberButtonColor(selectCell: cellValue)
        }
        // Reload the collection view to update the highlighting
        collectionView.reloadData()
    }
    
    private func fetchPuzzleData(difficulty: String) {
        
        let urlString = "http://127.0.0.1:8000/api/sudoku/\(difficulty)/"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching puzzle: \(error)")
                return
            }
            guard let data = data else { return }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("API Response: \(jsonString)")
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let sudokuID = json["sudoku_id"] as? Int,
                   let category = json["category"] as? String,
                   let eventID = json["event_id"] as? String,
                   let puzzleString = json["puzzle"] as? String,
                   let solutionString = json["solution"] as? String,
                   let solutionData = solutionString.data(using: .utf8),
                   let puzzleDate = json["puzzle_date"] as? String,
                   let status = json["status"] as? String,
                   let undoLimit = json["undo_limit"] as? Int,
                   let redoLimit = json["redo_limit"] as? Int,
                   let hintLimit = json["hint_limit"] as? Int {
                    
                    let puzzle = self.parsePuzzleString(puzzleString)
                    let solution = try JSONDecoder().decode([[Int]].self, from: solutionData)
                    
                    self.puzzleData = SudokuPuzzle.PuzzleData(
                        sudokuID: sudokuID,
                        category: category,
                        eventID: eventID,
                        puzzle: puzzle,
                        solution: solution,
                        puzzleDate: puzzleDate,
                        status: status,
                        undoLimit: undoLimit,
                        redoLimit: redoLimit,
                        hintLimit: hintLimit
                    )
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        task.resume()
    }
    
    private func parsePuzzleString(_ puzzleString: String) -> [[Int]] {
        var puzzle = [[Int]]()
        if let data = puzzleString.data(using: .utf8) {
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[Int]] {
                    puzzle = jsonArray
                }
            } catch {
                print("Error parsing puzzle string: \(error)")
            }
        }
        return puzzle
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gridSize * gridSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SudokuCell.identifier, for: indexPath) as! SudokuCell
        let row = indexPath.row / gridSize
        let column = indexPath.row % gridSize
        cell.updateBorder(row: row, column: column)
        
        // Update cell with puzzle value
        if let puzzle = puzzleData?.puzzle {
            let cellValue = puzzle[row][column]
            let isInitial = cellValue != 0 && puzzleData?.solution[row][column] == cellValue
            
            // Check if the number is incorrect
            var isIncorrect = false
            if cellValue != 0 {
                if let solution = puzzleData?.solution {
                    // Number is incorrect if it doesn't match solution
                    isIncorrect = cellValue != solution[row][column]
                }
                
                // Or if it violates Sudoku rules (same number in row/column/box)
                if !isInitial {
                    let sameInRow = puzzle[row].filter { $0 == cellValue }.count > 1
                    
                    var sameInColumn = false
                    for r in 0..<gridSize {
                        if r != row && puzzle[r][column] == cellValue {
                            sameInColumn = true
                            break
                        }
                    }
                    
                    var sameInBox = false
                    let boxStartRow = (row / 3) * 3
                    let boxStartCol = (column / 3) * 3
                    for r in boxStartRow..<(boxStartRow + 3) {
                        for c in boxStartCol..<(boxStartCol + 3) {
                            if (r != row || c != column) && puzzle[r][c] == cellValue {
                                sameInBox = true
                                break
                            }
                        }
                    }
                    
                    isIncorrect = isIncorrect || sameInRow || sameInColumn || sameInBox
                }
            }
            
            cell.configure(
                with: cellValue == 0 ? nil : cellValue,
                isInitial: isInitial,
                isIncorrect: isIncorrect,
                correctNumber: puzzleData?.solution[row][column]
            )
        } else {
            cell.configure(with: nil)
        }
        
        // Set default background color
        cell.contentView.backgroundColor = .white
        
        // Highlight logic for selected cell and related cells
        if let selectedIndexPath = selectedIndexPath {
            let selectedRow = selectedIndexPath.row / gridSize
            let selectedColumn = selectedIndexPath.row % gridSize
            
            // Get the 3x3 box boundaries for the selected cell
            let selectedBoxStartRow = (selectedRow / 3) * 3
            let selectedBoxStartCol = (selectedColumn / 3) * 3
            let selectedBoxEndRow = selectedBoxStartRow + 2
            let selectedBoxEndCol = selectedBoxStartCol + 2
            
            // Check if current cell is in the same row, column, or 3x3 box as the selected cell
            let isInSameRow = row == selectedRow
            let isInSameColumn = column == selectedColumn
            let isInSameBox = (row >= selectedBoxStartRow && row <= selectedBoxEndRow) &&
                             (column >= selectedBoxStartCol && column <= selectedBoxEndCol)
            
            if indexPath == selectedIndexPath {
                cell.contentView.backgroundColor = UIColor(white: 0.8, alpha: 1.0)  // Darker gray
            } else if isInSameRow || isInSameColumn || isInSameBox {
                cell.contentView.backgroundColor = UIColor(white: 0.85, alpha: 1.0)  // Medium gray
            }
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
                    numberLabel.textColor = #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1)
                }
            }
        } else {
            numberLabel.text = nil
        }
        
        // Display notes
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
        noteLabel.font = UIFont.systemFont(ofSize: 10)
        noteLabel.textAlignment = .center
        noteLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(noteLabel)
        noteLabels.append(noteLabel)
        
        // Position the note label in the cell
        updateNotePositions()
    }
    
    func updateNotes(_ notes: [Int]) {
        // Clear existing note labels
        clearNotes()
        
        // Add new note labels
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
            
            // Set constraints for the note label
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
        
        // Add normal borders on all sides
        addBorder(to: .top, color: .darkGray, width: normalWidth)
        addBorder(to: .left, color: .darkGray, width: normalWidth)
        addBorder(to: .bottom, color: .darkGray, width: normalWidth)
        addBorder(to: .right, color: .darkGray, width: normalWidth)
        
        // Apply thicker black border on top for row 3 and 6
        if row == 2 || row == 5 {
            addBorder(to: .bottom, color: .black, width: borderWidth)
        }
        
        // Apply thicker black border on left for column 3 and 6
        if column == 2 || column == 5 {
            addBorder(to: .right, color: .black, width: borderWidth)
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
    
    func changeNumberButtonColor(selectCell: Int) {
        for button in self.numberButtons {
            if button.titleLabel?.text == String(selectCell) {
                button.backgroundColor = .systemGreen
            } else {
                button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            }
        }
    }
}
