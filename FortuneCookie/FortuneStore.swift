import Foundation
import Combine

struct DrawOutcome {
    let fortune: Fortune
    let xpEarned: Int
    let didLevelUp: Bool
    let newLevel: Int
}

class FortuneStore: ObservableObject {
    static let maxDailyDraws = 24
    static let xpPerLevel    = 100

    @Published private(set) var todayFortunes: [Fortune] = []
    @Published private(set) var totalXP: Int = 0

    private let storageKey = "fortuneCookie_todayFortunes"
    private let dateKey    = "fortuneCookie_date"
    private let xpKey      = "fortuneCookie_totalXP"

    // MARK: - Computed

    var remainingDraws: Int { max(0, Self.maxDailyDraws - todayFortunes.count) }
    var canDraw: Bool { remainingDraws > 0 }

    var currentLevel: Int { totalXP / Self.xpPerLevel + 1 }
    var xpInCurrentLevel: Int { totalXP % Self.xpPerLevel }
    var xpToNextLevel: Int { Self.xpPerLevel - xpInCurrentLevel }
    var levelProgress: Double { Double(xpInCurrentLevel) / Double(Self.xpPerLevel) }
    var levelInfo: LevelInfo { LevelInfo.for_(xp: totalXP) }

    // MARK: - Init

    init() {
        totalXP = UserDefaults.standard.integer(forKey: xpKey)
        loadTodayFortunes()
    }

    // MARK: - Draw

    func drawFortune() -> DrawOutcome? {
        guard canDraw else { return nil }

        let usedTexts = Set(todayFortunes.map(\.text))
        let available = FortuneData.templates.filter { !usedTexts.contains($0.text) }
        guard let template = available.randomElement() else { return nil }

        let rank    = FortuneRank.random()
        let fortune = Fortune(template: template, rank: rank)

        let oldLevel = currentLevel
        totalXP     += fortune.xpEarned
        let newLevel  = currentLevel

        todayFortunes.append(fortune)
        persistFortunes()
        UserDefaults.standard.set(totalXP, forKey: xpKey)

        return DrawOutcome(
            fortune:    fortune,
            xpEarned:   fortune.xpEarned,
            didLevelUp: newLevel > oldLevel,
            newLevel:   newLevel
        )
    }

    // MARK: - Save toggle

    func toggleSave(_ fortune: Fortune) {
        guard let idx = todayFortunes.firstIndex(where: { $0.id == fortune.id }) else { return }
        todayFortunes[idx].isSaved.toggle()
        persistFortunes()
    }

    // MARK: - Helpers

    func timeUntilReset() -> String {
        let cal = Calendar.current
        let now = Date()
        guard let tomorrow = cal.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) else { return "midnight" }
        let parts = cal.dateComponents([.hour, .minute], from: now, to: tomorrow)
        let h = parts.hour ?? 0
        let m = parts.minute ?? 0
        return h > 0 ? "\(h)h \(m)m" : "\(m)m"
    }

    // MARK: - Persistence

    private func loadTodayFortunes() {
        let cal = Calendar.current
        if let stored = UserDefaults.standard.object(forKey: dateKey) as? Date,
           cal.isDateInToday(stored),
           let data = UserDefaults.standard.data(forKey: storageKey),
           let fortunes = try? JSONDecoder().decode([Fortune].self, from: data) {
            todayFortunes = fortunes
        } else {
            todayFortunes = []
            UserDefaults.standard.set(Date(), forKey: dateKey)
            persistFortunes()
        }
    }

    private func persistFortunes() {
        if let data = try? JSONEncoder().encode(todayFortunes) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
        UserDefaults.standard.set(Date(), forKey: dateKey)
    }
}
