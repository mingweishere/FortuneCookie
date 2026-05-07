import EventKit
import Foundation

// MARK: - User Profile

struct UserProfile: Codable {
    var name: String = ""
    var chineseZodiac: String = ""
    var goals: [String] = []

    private static let defaultsKey = "userProfile_v1"

    static func load() -> UserProfile {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let profile = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            return UserProfile()
        }
        return profile
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.defaultsKey)
        }
    }
}

// MARK: - Tool implementations

struct DailyBriefingTools {
    private let eventStore = EKEventStore()

    // Tool 1: Calendar events
    func getCalendarEvents() async throws -> String {
        let granted: Bool
        if #available(iOS 17.0, *) {
            granted = try await eventStore.requestFullAccessToEvents()
        } else {
            granted = try await withCheckedThrowingContinuation { cont in
                eventStore.requestAccess(to: .event) { ok, err in
                    if let err { cont.resume(throwing: err) } else { cont.resume(returning: ok) }
                }
            }
        }
        guard granted else { return "Calendar access was not granted." }

        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end   = cal.date(byAdding: .day, value: 1, to: start)!
        let pred  = eventStore.predicateForEvents(withStart: start, end: end, calendars: nil)
        let events = eventStore.events(matching: pred)

        guard !events.isEmpty else { return "No calendar events scheduled for today." }

        let fmt = DateFormatter()
        fmt.timeStyle = .short
        fmt.dateStyle = .none

        return events.map { ev -> String in
            var parts = ["\(ev.title ?? "Untitled") at \(fmt.string(from: ev.startDate))"]
            if let loc = ev.location,  !loc.isEmpty   { parts.append("Location: \(loc)") }
            if let notes = ev.notes,   !notes.isEmpty { parts.append("Notes: \(notes)") }
            return parts.joined(separator: "; ")
        }.joined(separator: "\n")
    }

    // Tool 2: Fengshui / almanac data
    func getFengshuiData() -> String {
        let a = ChineseCalendarEngine.calculate(for: Date())
        var lines = [
            "Date: \(a.gregorianString) \(a.weekdayString)",
            "Lunar date: \(a.lunarYear) \(a.lunarMonthDay)",
            "Zodiac year: \(a.zodiac)",
            "Day Ganzhi: \(a.dayGanzhi)",
            "Five Elements (Nayin): \(a.nayin)",
            "Day Officer (建除): \(a.dayOfficer)",
            "Day quality: \(a.dayQuality.label)",
            "Auspicious activities (宜): \(a.yi.joined(separator: ", "))",
            "Inauspicious activities (忌): \(a.ji.joined(separator: ", "))",
            "Wealth God direction: \(a.positionCaiShen)",
            "Joy God direction: \(a.positionXiShen)",
            "Fortune God direction: \(a.positionFuShen)",
            "Clash: \(a.chongSha)",
        ]
        if let term = a.solarTerm { lines.append("Solar term: \(term)") }
        return lines.joined(separator: "\n")
    }

    // Tool 3: User profile
    func getUserProfile() -> String {
        let p = UserProfile.load()
        var lines: [String] = []
        if !p.name.isEmpty          { lines.append("Name: \(p.name)") }
        if !p.chineseZodiac.isEmpty { lines.append("Chinese Zodiac: \(p.chineseZodiac)") }
        if !p.goals.isEmpty         { lines.append("Goals: \(p.goals.joined(separator: "; "))") }
        return lines.isEmpty ? "No user profile set up yet." : lines.joined(separator: "\n")
    }
}
