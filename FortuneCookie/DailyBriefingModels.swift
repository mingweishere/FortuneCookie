import Foundation

// MARK: - Request

struct GeminiRequest: Encodable {
    let systemInstruction: GeminiContent?
    let contents: [GeminiContent]
    let tools: [GeminiTool]?
    let generationConfig: GeminiGenerationConfig?

    enum CodingKeys: String, CodingKey {
        case systemInstruction = "system_instruction"
        case contents, tools
        case generationConfig = "generation_config"
    }
}

struct GeminiGenerationConfig: Encodable {
    let maxOutputTokens: Int

    enum CodingKeys: String, CodingKey {
        case maxOutputTokens = "max_output_tokens"
    }
}

// MARK: - Content / Parts

struct GeminiContent: Codable {
    let role: String?
    let parts: [GeminiPart]
}

struct GeminiPart: Codable {
    var text: String?
    var functionCall: GeminiFunctionCall?
    var functionResponse: GeminiFunctionResponse?

    enum CodingKeys: String, CodingKey {
        case text
        case functionCall     = "function_call"
        case functionResponse = "function_response"
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(text,             forKey: .text)
        try c.encodeIfPresent(functionCall,     forKey: .functionCall)
        try c.encodeIfPresent(functionResponse, forKey: .functionResponse)
    }
}

struct GeminiFunctionCall: Codable {
    let name: String
    let args: JSONValue?
}

struct GeminiFunctionResponse: Encodable {
    let name: String
    let response: [String: String]   // {"output": "<tool result>"}
}

// MARK: - Tool definitions

struct GeminiTool: Encodable {
    let functionDeclarations: [GeminiFunctionDeclaration]?
    let googleSearch: GeminiGoogleSearch?

    enum CodingKeys: String, CodingKey {
        case functionDeclarations = "function_declarations"
        case googleSearch         = "google_search"
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(functionDeclarations, forKey: .functionDeclarations)
        try c.encodeIfPresent(googleSearch,         forKey: .googleSearch)
    }
}

struct GeminiGoogleSearch: Encodable {}   // presence of key enables grounding

struct GeminiFunctionDeclaration: Encodable {
    let name: String
    let description: String
    let parameters: GeminiParameters
}

struct GeminiParameters: Encodable {
    let type = "object"
    let properties: [String: GeminiPropertySchema]
    let required: [String]
}

struct GeminiPropertySchema: Encodable {
    let type: String
    let description: String
}

// MARK: - Response

struct GeminiResponse: Decodable {
    let candidates: [GeminiCandidate]
}

struct GeminiCandidate: Decodable {
    let content: GeminiContent
    let finishReason: String?

    enum CodingKeys: String, CodingKey {
        case content
        case finishReason = "finish_reason"
    }
}

// MARK: - JSONValue (arbitrary JSON for function call args)

enum JSONValue: Codable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    case null

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let v = try? c.decode(Bool.self)                { self = .bool(v);   return }
        if let v = try? c.decode(Double.self)              { self = .number(v); return }
        if let v = try? c.decode(String.self)              { self = .string(v); return }
        if let v = try? c.decode([String: JSONValue].self) { self = .object(v); return }
        if let v = try? c.decode([JSONValue].self)         { self = .array(v);  return }
        self = .null
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .string(let v): try c.encode(v)
        case .number(let v): try c.encode(v)
        case .bool(let v):   try c.encode(v)
        case .object(let v): try c.encode(v)
        case .array(let v):  try c.encode(v)
        case .null:          try c.encodeNil()
        }
    }

    subscript(_ key: String) -> JSONValue? {
        guard case .object(let d) = self else { return nil }
        return d[key]
    }

    var stringValue: String? {
        guard case .string(let s) = self else { return nil }
        return s
    }
}
