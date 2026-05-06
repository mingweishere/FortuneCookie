import Foundation
import Combine

class FortuneStore: ObservableObject {
    static let maxDailyDraws = 24

    @Published private(set) var todayFortunes: [Fortune] = []

    private let storageKey = "fortuneCookie_todayFortunes"
    private let dateKey    = "fortuneCookie_date"

    var remainingDraws: Int { max(0, Self.maxDailyDraws - todayFortunes.count) }
    var canDraw: Bool { remainingDraws > 0 }

    init() { loadTodayFortunes() }

    @discardableResult
    func drawFortune() -> Fortune? {
        guard canDraw else { return nil }

        let usedTexts = Set(todayFortunes.map(\.text))
        let available = FortuneData.templates.filter { !usedTexts.contains($0.text) }
        guard let template = available.randomElement() else { return nil }

        let fortune = Fortune(template: template)
        todayFortunes.append(fortune)
        persist()
        return fortune
    }

    func toggleSave(_ fortune: Fortune) {
        guard let idx = todayFortunes.firstIndex(where: { $0.id == fortune.id }) else { return }
        todayFortunes[idx].isSaved.toggle()
        persist()
    }

    func timeUntilReset() -> String {
        let calendar = Calendar.current
        let now = Date()
        guard let tomorrow = calendar.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) else { return "midnight" }
        let components = calendar.dateComponents([.hour, .minute], from: now, to: tomorrow)
        let h = components.hour ?? 0
        let m = components.minute ?? 0
        return h > 0 ? "\(h)h \(m)m" : "\(m)m"
    }

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
            persist()
        }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(todayFortunes) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
        UserDefaults.standard.set(Date(), forKey: dateKey)
    }
}
