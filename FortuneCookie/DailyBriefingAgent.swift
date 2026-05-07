import Foundation

// MARK: - API key config (read from Config.plist — never hardcode here)

enum BriefingConfig {
    static var apiKey: String {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key  = dict["AnthropicAPIKey"] as? String,
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
            return "API key not configured. Open Config.plist and paste your Anthropic key."
        case .apiError(let msg):
            return "API error: \(msg)"
        }
    }
}

// MARK: - Agent

class DailyBriefingAgent {
    private let tools = DailyBriefingTools()
    private let apiURL = URL(string: "https://api.anthropic.com/v1/messages")!

    private let systemPrompt = """
    You are a personal Fengshui daily briefing assistant. Each morning, you \
    autonomously gather the user's calendar, today's Fengshui energy, and relevant \
    world context via web search. You then synthesize a warm, insightful morning \
    briefing that helps the user align their day with cosmic energy. Always call \
    ALL available tools before writing the briefing. Be specific — reference actual \
    calendar events by name, actual Fengshui indicators, and real news.

    Structure your final response using EXACTLY these section headers (keep the emoji):
    ## 🌟 Fengshui Snapshot
    ## 📅 Calendar Alignment
    ## 🌐 World Context
    ## 🥠 Your Personal Fortune
    """

    private var toolDefinitions: [ToolDefinition] {[
        .builtin(type: "web_search_20250305", name: "web_search"),
        .custom(name: "get_fengshui_data",
                description: "Returns today's Chinese almanac and Fengshui data: lunar date, ganzhi, auspicious/inauspicious activities, lucky directions, and day quality."),
        .custom(name: "get_calendar_events",
                description: "Fetches today's calendar events from the user's device, including title, time, location, and notes."),
        .custom(name: "get_user_profile",
                description: "Returns the user's stored profile: name, Chinese zodiac sign, and personal goals."),
    ]}

    // Main entry point. `onToolCall` is called on the main actor before each tool execution.
    func generate(onToolCall: @escaping (String) -> Void) async throws -> String {
        guard !BriefingConfig.apiKey.isEmpty else { throw BriefingError.missingAPIKey }

        var messages: [APIMessage] = [
            APIMessage(role: "user", content: [
                .text("Please generate my personalised daily briefing for today. Call ALL available tools before writing the briefing.")
            ])
        ]

        while true {
            let response = try await callAPI(messages: messages)

            let toolUseBlocks = response.content.filter { $0.type == "tool_use" }

            // No pending tool calls → return the final text
            if toolUseBlocks.isEmpty {
                return response.content
                    .filter { $0.type == "text" }
                    .compactMap { $0.text }
                    .joined(separator: "\n")
            }

            // Append assistant turn (all content blocks, including any text before tool calls)
            let assistantBlocks = response.content.map { b in
                ContentBlock(type: b.type, text: b.text, id: b.id, name: b.name, input: b.input)
            }
            messages.append(APIMessage(role: "assistant", content: assistantBlocks))

            // Execute each tool and collect results
            var results: [ContentBlock] = []
            for block in toolUseBlocks {
                guard let toolName = block.name, let toolId = block.id else { continue }
                onToolCall(toolName)
                let result = try await executeTool(name: toolName, input: block.input)
                results.append(.toolResult(toolUseId: toolId, content: result))
            }
            messages.append(APIMessage(role: "user", content: results))
        }
    }

    // MARK: - Tool dispatch

    private func executeTool(name: String, input: JSONValue?) async throws -> String {
        switch name {
        case "get_fengshui_data":   return tools.getFengshuiData()
        case "get_calendar_events": return (try? await tools.getCalendarEvents()) ?? "Calendar unavailable."
        case "get_user_profile":    return tools.getUserProfile()
        case "web_search":          return "" // handled server-side by Anthropic
        default:                    return "Unknown tool."
        }
    }

    // MARK: - HTTP

    private func callAPI(messages: [APIMessage]) async throws -> AnthropicResponse {
        let body = AnthropicRequest(
            model: "claude-sonnet-4-20250514",
            maxTokens: 4096,
            system: systemPrompt,
            messages: messages,
            tools: toolDefinitions
        )

        var req = URLRequest(url: apiURL)
        req.httpMethod = "POST"
        req.setValue("application/json",       forHTTPHeaderField: "Content-Type")
        req.setValue(BriefingConfig.apiKey,    forHTTPHeaderField: "x-api-key")
        req.setValue("2023-06-01",             forHTTPHeaderField: "anthropic-version")
        req.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: req)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw BriefingError.apiError(msg)
        }

        return try JSONDecoder().decode(AnthropicResponse.self, from: data)
    }
}
