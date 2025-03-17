import Foundation

struct GameResult: Codable {
    let riderId: String
    let category: String
    let categoryStats: [CategoryStat]
    let grandTotalPoints: Int

    enum CodingKeys: String, CodingKey {
        case riderId = "rider_id"
        case category
        case categoryStats = "category_stats"
        case grandTotalPoints = "grand_total_points"
    }
}

struct CategoryStat: Codable {
    let category: String
    let bestTime: Int
    let totalPoints: Int

    enum CodingKeys: String, CodingKey {
        case category
        case bestTime = "best_time"
        case totalPoints = "total_points"
    }
}
