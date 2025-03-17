import Foundation

struct APIEndpoints {
    private static let baseURL = "https://zdotapps.in/carelon"
    static let baseSudokuURL = "\(baseURL)/sudoku/"
    static let submitGameURL = "\(baseURL)/submit_game/"
    static let results = "\(baseURL)/results/?rider_id=2"
}
