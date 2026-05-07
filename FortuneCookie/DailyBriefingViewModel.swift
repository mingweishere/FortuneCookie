import Combine
import Foundation

// MARK: - State

enum BriefingState {
    case idle
    case loading(step: String)
    case loaded(sections: [BriefingSection])
    case error(String)
}

struct BriefingSection: Identifiable {
    let id = UUID()
    let emoji: String
    let title: String
    let body: String
}

// MARK: - ViewModel

class DailyBriefingViewModel: ObservableObject {
    @Published var state: BriefingState = .idle
    @Published var lastUpdated: Date?

    private let agent = DailyBriefingAgent()

    func generate() async {
        state = .loading(step: "Preparing your briefing…")
        do {
            let raw = try await agent.generate { [weak self] toolName in
                self?.state = .loading(step: self?.stepMessage(for: toolName) ?? "Working…")
            }
            let sections = parse(raw)
            state = .loaded(sections: sections)
            lastUpdated = Date()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    // MARK: - Helpers

    private func stepMessage(for toolName: String) -> String {
        switch toolName {
        case "get_fengshui_data":   return "Reading today's energy…"
        case "get_user_profile":    return "Loading your profile…"
        case "get_calendar_events": return "Checking your calendar…"
        default:                    return "Gathering information…"
        }
    }

    private func parse(_ raw: String) -> [BriefingSection] {
        let defs: [(marker: String, emoji: String, title: String)] = [
            ("## 🌟 Fengshui Snapshot",    "🌟", "Fengshui Snapshot"),
            ("## 📅 Calendar Alignment",   "📅", "Calendar Alignment"),
            ("## 🌐 World Context",         "🌐", "World Context"),
            ("## 🥠 Your Personal Fortune", "🥠", "Your Personal Fortune"),
        ]

        // Locate each marker in the raw string
        var cuts: [(start: String.Index, end: String.Index, emoji: String, title: String)] = []
        for def in defs {
            if let r = raw.range(of: def.marker) {
                cuts.append((r.lowerBound, r.upperBound, def.emoji, def.title))
            }
        }
        cuts.sort { $0.start < $1.start }

        var sections: [BriefingSection] = []
        for (i, cut) in cuts.enumerated() {
            let bodyEnd = i + 1 < cuts.count ? cuts[i + 1].start : raw.endIndex
            let body = String(raw[cut.end..<bodyEnd]).trimmingCharacters(in: .whitespacesAndNewlines)
            sections.append(BriefingSection(emoji: cut.emoji, title: cut.title, body: body))
        }

        // Fallback: display everything as one card if markers weren't found
        if sections.isEmpty {
            sections.append(BriefingSection(
                emoji: "🌅",
                title: "Your Daily Briefing",
                body: raw.trimmingCharacters(in: .whitespacesAndNewlines)
            ))
        }
        return sections
    }
}
