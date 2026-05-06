import SwiftUI

enum FortuneRank: String, Codable, CaseIterable {
    case daikichi   // 大吉  Great Blessing
    case chukichi   // 中吉  Good Fortune
    case shokichi   // 小吉  Minor Fortune
    case kichi      // 吉    Lucky
    case suekichi   // 末吉  Budding Luck
    case kyo        // 凶    Caution
    case daikyo     // 大凶  Great Challenge

    var chinese: String {
        switch self {
        case .daikichi: "大吉"
        case .chukichi: "中吉"
        case .shokichi: "小吉"
        case .kichi:    "吉"
        case .suekichi: "末吉"
        case .kyo:      "凶"
        case .daikyo:   "大凶"
        }
    }

    var title: String {
        switch self {
        case .daikichi: "Great Blessing"
        case .chukichi: "Good Fortune"
        case .shokichi: "Minor Fortune"
        case .kichi:    "Lucky"
        case .suekichi: "Budding Luck"
        case .kyo:      "Caution"
        case .daikyo:   "Great Challenge"
        }
    }

    var detail: String {
        switch self {
        case .daikichi:
            return "The stars align perfectly in your favor. This rare and auspicious sign heralds exceptional luck — great opportunities, deep happiness, and triumphant outcomes await. Dare to dream boldly."
        case .chukichi:
            return "A favorable wind fills your sails. Your efforts are being seen and rewarded. Good things are already unfolding around you; keep your heart open to receive them fully."
        case .shokichi:
            return "Small but genuine blessings grace your path today. Look closely — the best things often arrive quietly. A modest fortune, sincerely felt, is a treasure worth savoring."
        case .kichi:
            return "Reliable and steady fortune walks beside you today. While not extraordinary, it is solid and real. Build upon this foundation — consistency compounds into remarkable results."
        case .suekichi:
            return "Your fortune is still developing, like a seed resting beneath winter soil. Be patient. The most beautiful blossoms take the longest to emerge, and the wait shall be well worth it."
        case .kyo:
            return "A caution is drawn. Tread carefully and reflect before acting impulsively. In Japanese tradition, this is a gentle reminder to pause and reconsider — not a verdict. Every challenge carries wisdom for those willing to receive it."
        case .daikyo:
            return "The rarest draw — a great challenge. In Japanese shrines, one ties this slip to a tree branch and leaves the difficulty behind. Your perseverance through this trial will forge a strength that ordinary fortune can never bestow."
        }
    }

    var xp: Int {
        switch self {
        case .daikichi: 25
        case .chukichi: 20
        case .shokichi: 15
        case .kichi:    12
        case .suekichi: 10
        case .kyo:       8
        case .daikyo:    5
        }
    }

    var color: Color {
        switch self {
        case .daikichi: Color(red: 0.98, green: 0.78, blue: 0.08)
        case .chukichi: Color(red: 1.00, green: 0.52, blue: 0.04)
        case .shokichi: Color(red: 0.18, green: 0.72, blue: 0.32)
        case .kichi:    Color(red: 0.08, green: 0.55, blue: 0.22)
        case .suekichi: Color(red: 0.12, green: 0.52, blue: 0.85)
        case .kyo:      Color(red: 0.52, green: 0.08, blue: 0.72)
        case .daikyo:   Color(red: 0.60, green: 0.04, blue: 0.04)
        }
    }

    var emoji: String {
        switch self {
        case .daikichi: "✨"
        case .chukichi: "☀️"
        case .shokichi: "🌿"
        case .kichi:    "🍀"
        case .suekichi: "🌸"
        case .kyo:      "🌊"
        case .daikyo:   "⚡"
        }
    }

    // Stars shown in the UI (out of 5)
    var stars: Int {
        switch self {
        case .daikichi: 5
        case .chukichi: 4
        case .shokichi: 3
        case .kichi:    3
        case .suekichi: 2
        case .kyo:      1
        case .daikyo:   1
        }
    }

    // Weighted random draw (total weight 100)
    static func random() -> FortuneRank {
        let table: [(FortuneRank, Int)] = [
            (.daikichi,  5),
            (.chukichi, 15),
            (.shokichi, 20),
            (.kichi,    30),
            (.suekichi, 15),
            (.kyo,      12),
            (.daikyo,    3),
        ]
        var pick = Int.random(in: 0..<100)
        for (rank, weight) in table {
            pick -= weight
            if pick < 0 { return rank }
        }
        return .kichi
    }
}

// MARK: - Level system

struct LevelInfo {
    let level: Int
    let chinese: String
    let english: String

    static func for_(xp: Int) -> LevelInfo {
        let level = xp / 100 + 1
        return LevelInfo(level: level, chinese: chineseName(level), english: englishName(level))
    }

    static func chineseName(_ level: Int) -> String {
        switch level {
        case 1:  return "初学"
        case 2:  return "学徒"
        case 3:  return "习者"
        case 4:  return "智者"
        case 5:  return "达人"
        case 6:  return "贤者"
        case 7:  return "仙人"
        case 8:  return "大师"
        case 9:  return "龙王"
        case 10: return "天神"
        default: return "传奇"
        }
    }

    static func englishName(_ level: Int) -> String {
        switch level {
        case 1:  return "Novice"
        case 2:  return "Apprentice"
        case 3:  return "Seeker"
        case 4:  return "Wiseman"
        case 5:  return "Expert"
        case 6:  return "Sage"
        case 7:  return "Immortal"
        case 8:  return "Grand Master"
        case 9:  return "Dragon King"
        case 10: return "Celestial"
        default: return "Legend"
        }
    }
}
