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
    private let model = "gemini-2.5-flash"
    private var apiURL: URL {
        URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(BriefingConfig.apiKey)")!
    }

    private let systemPrompt = """
    You are a personal Fengshui daily briefing assistant. Each morning, you \
    autonomously gather the user's calendar, today's Fengshui energy, and share \
    relevant world context from your knowledge. You then synthesize a warm, insightful morning \
    briefing that helps the user align their day with cosmic energy. Always call \
    ALL available functions before writing the briefing. Be specific — reference \
    actual calendar events by name, actual Fengshui indicators, and real news.

    Structure your final response using EXACTLY these section headers (keep the emoji):
    ## 🌟 Fengshui Snapshot
    ## 📅 Calendar Alignment
    ## 🌐 World Context
    ## 🥠 Your Personal Fortune
    """

    private var functionDeclarations: [GeminiFunctionDeclaration] {[
        GeminiFunctionDeclaration(
            name: "get_fengshui_data",
            description: "Returns today's Chinese almanac and Fengshui data: lunar date, ganzhi, auspicious/inauspicious activities, lucky directions, and day quality.",
            parameters: GeminiParameters(properties: [:], required: [])
        ),
        GeminiFunctionDeclaration(
            name: "get_calendar_events",
            description: "Fetches today's calendar events from the user's device, including title, time, location, and notes.",
            parameters: GeminiParameters(properties: [:], required: [])
        ),
        GeminiFunctionDeclaration(
            name: "get_user_profile",
            description: "Returns the user's stored profile: name, Chinese zodiac sign, and personal goals.",
            parameters: GeminiParameters(properties: [:], required: [])
        ),
    ]}

    // Main entry point. `onToolCall` fires on the main actor before each local tool execution.
    func generate(onToolCall: @escaping (String) -> Void) async throws -> String {
        guard !BriefingConfig.apiKey.isEmpty else { throw BriefingError.missingAPIKey }

        let systemContent = GeminiContent(role: nil, parts: [GeminiPart(text: systemPrompt)])
        var contents: [GeminiContent] = [
            GeminiContent(role: "user", parts: [
                GeminiPart(text: "Please generate my personalised daily briefing for today. Call ALL available functions before writing the briefing.")
            ])
        ]

        let geminiTools: [GeminiTool] = [
            GeminiTool(functionDeclarations: functionDeclarations, googleSearch: nil),
        ]

        while true {
            let response = try await callAPI(
                systemInstruction: systemContent,
                contents: contents,
                tools: geminiTools
            )

            guard let candidate = response.candidates.first else {
                throw BriefingError.apiError("No candidates returned.")
            }

            let parts = candidate.content.parts
            let functionCalls = parts.compactMap { $0.functionCall }

            // No more function calls → extract text and return
            if functionCalls.isEmpty {
                let text = parts.compactMap { $0.text }.joined(separator: "\n")
                return text
            }

            // Append model's turn (includes the function call parts)
            contents.append(GeminiContent(role: "model", parts: parts))

            // Execute each function and collect responses
            onToolCall(functionCalls.first?.name ?? "")
            var responseParts: [GeminiPart] = []
            for call in functionCalls {
                onToolCall(call.name)
                let result = try await executeTool(name: call.name, args: call.args)
                responseParts.append(GeminiPart(
                    functionResponse: GeminiFunctionResponse(
                        name: call.name,
                        response: ["output": result]
                    )
                ))
            }

            // Append user turn with function responses
            contents.append(GeminiContent(role: "user", parts: responseParts))
        }
    }

    // MARK: - Tool dispatch

    private func executeTool(name: String, args: JSONValue?) async throws -> String {
        switch name {
        case "get_fengshui_data":   return tools.getFengshuiData()
        case "get_calendar_events": return (try? await tools.getCalendarEvents()) ?? "Calendar unavailable."
        case "get_user_profile":    return tools.getUserProfile()
        default:                    return "Unknown function."
        }
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
