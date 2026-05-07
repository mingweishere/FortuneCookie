import Foundation

// MARK: - API key config (read from Config.plist — never hardcode here)

enum BriefingConfig {
    static var apiKey: String {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key  = dict["GeminiAPIKey"] as? String,
              !key.isEmpty, key != "PASTE_YOUR_KEY_HERE" else { return "" }
        return key
    }
}

// MARK: - Errors

enum BriefingError: LocalizedError {
    case missingAPIKey
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API key not configured. Open Config.plist and paste your Gemini key."
        case .apiError(let msg):
            return "API error: \(msg)"
        }
    }
}

// MARK: - Agent

class DailyBriefingAgent {
    private let tools = DailyBriefingTools()
    private let model = "gemini-2.5-pro"
    private var apiURL: URL {
        URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(BriefingConfig.apiKey)")!
    }

    private let systemPrompt = """
    You are a personal Fengshui daily briefing assistant. You will receive the user's \
    Fengshui data, calendar events, and profile. Use Google Search to find relevant \
    current news and world context, then synthesise everything into a warm, insightful \
    morning briefing. Be specific — reference actual Fengshui indicators, calendar events \
    by name, and real news from your search.

    Structure your response with EXACTLY these section headers (keep the emoji):
    ## 🌟 Fengshui Snapshot
    ## 📅 Calendar Alignment
    ## 🌐 World Context
    ## 🥠 Your Personal Fortune
    """

    // MARK: - Main entry point

    // Phase 1: gather all local data directly in Swift (no API call, no tool-conflict).
    // Phase 2: single Gemini request with google_search grounding only — synthesises
    //          everything and fetches live web context in one clean call.
    func generate(onToolCall: @escaping (String) -> Void) async throws -> String {
        guard !BriefingConfig.apiKey.isEmpty else { throw BriefingError.missingAPIKey }

        // Phase 1 — local tools (instant, no API)
        onToolCall("get_fengshui_data")
        let fengshui = tools.getFengshuiData()

        onToolCall("get_user_profile")
        let profile = tools.getUserProfile()

        onToolCall("get_calendar_events")
        let calendar = (try? await tools.getCalendarEvents()) ?? "Calendar unavailable."

        // Phase 2 — single grounded API call
        onToolCall("web_search")
        return try await synthesise(fengshui: fengshui, calendar: calendar, profile: profile)
    }

    // MARK: - Synthesis (google_search grounding only — no function_declarations)

    private func synthesise(fengshui: String, calendar: String, profile: String) async throws -> String {
        let userMessage = """
        Please generate my personalised daily briefing using the data below. \
        Search the web for relevant current news before writing.

        FENGSHUI & ALMANAC:
        \(fengshui)

        CALENDAR EVENTS:
        \(calendar)

        USER PROFILE:
        \(profile)
        """

        let response = try await callAPI(
            systemInstruction: GeminiContent(role: nil, parts: [GeminiPart(text: systemPrompt)]),
            contents: [GeminiContent(role: "user", parts: [GeminiPart(text: userMessage)])],
            tools: [GeminiTool(functionDeclarations: nil, googleSearch: GeminiGoogleSearch())]
        )

        guard let candidate = response.candidates.first else {
            throw BriefingError.apiError("No candidates returned.")
        }

        let text = candidate.content.parts.compactMap { $0.text }.joined(separator: "\n")
        guard !text.isEmpty else { throw BriefingError.apiError("Empty response from model.") }
        return text
    }

    // MARK: - HTTP

    private func callAPI(
        systemInstruction: GeminiContent,
        contents: [GeminiContent],
        tools: [GeminiTool]
    ) async throws -> GeminiResponse {
        let body = GeminiRequest(
            systemInstruction: systemInstruction,
            contents: contents,
            tools: tools,
            generationConfig: GeminiGenerationConfig(maxOutputTokens: 4096)
        )

        var req = URLRequest(url: apiURL)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: req)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw BriefingError.apiError(msg)
        }

        return try JSONDecoder().decode(GeminiResponse.self, from: data)
    }
}
