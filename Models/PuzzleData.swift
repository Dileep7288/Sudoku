import Foundation

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
