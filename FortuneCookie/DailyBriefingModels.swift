import Foundation

// MARK: - Request

struct AnthropicRequest: Encodable {
    let model: String
    let maxTokens: Int
    let system: String
    let messages: [APIMessage]
    let tools: [ToolDefinition]

    enum CodingKeys: String, CodingKey {
        case model, system, messages, tools
        case maxTokens = "max_tokens"
    }
}

struct APIMessage: Encodable {
    let role: String
    let content: [ContentBlock]
}

struct ContentBlock: Codable {
    let type: String
    var text: String?
    var id: String?
    var name: String?
    var input: JSONValue?
    var toolUseId: String?
    var content: String?

    enum CodingKeys: String, CodingKey {
        case type, text, id, name, input, content
        case toolUseId = "tool_use_id"
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(type, forKey: .type)
        try c.encodeIfPresent(text,      forKey: .text)
        try c.encodeIfPresent(id,        forKey: .id)
        try c.encodeIfPresent(name,      forKey: .name)
        try c.encodeIfPresent(input,     forKey: .input)
        try c.encodeIfPresent(toolUseId, forKey: .toolUseId)
        try c.encodeIfPresent(content,   forKey: .content)
    }

    static func text(_ value: String) -> ContentBlock {
        ContentBlock(type: "text", text: value)
    }

    static func toolResult(toolUseId: String, content: String) -> ContentBlock {
        ContentBlock(type: "tool_result", toolUseId: toolUseId, content: content)
    }
}

// MARK: - Tool definitions

struct ToolDefinition: Encodable {
    let type: String?
    let name: String
    let description: String?
    let inputSchema: InputSchema?

    enum CodingKeys: String, CodingKey {
        case type, name, description
        case inputSchema = "input_schema"
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(type,        forKey: .type)
        try c.encode(name,                 forKey: .name)
        try c.encodeIfPresent(description, forKey: .description)
        try c.encodeIfPresent(inputSchema, forKey: .inputSchema)
    }

    static func builtin(type: String, name: String) -> ToolDefinition {
        ToolDefinition(type: type, name: name, description: nil, inputSchema: nil)
    }

    static func custom(name: String, description: String) -> ToolDefinition {
        ToolDefinition(type: nil, name: name, description: description,
                       inputSchema: InputSchema(properties: [:], required: []))
    }
}

struct InputSchema: Encodable {
    let type = "object"
    let properties: [String: SchemaProperty]
    let required: [String]
}

struct SchemaProperty: Encodable {
    let type: String
    let description: String
}

// MARK: - Response

struct AnthropicResponse: Decodable {
    let id: String
    let content: [ResponseBlock]
    let stopReason: String?

    enum CodingKeys: String, CodingKey {
        case id, content
        case stopReason = "stop_reason"
    }
}

struct ResponseBlock: Decodable {
    let type: String
    let text: String?
    let id: String?
    let name: String?
    let input: JSONValue?
}

// MARK: - JSONValue (arbitrary JSON)

enum JSONValue: Codable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    case null

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let v = try? c.decode(Bool.self)               { self = .bool(v);   return }
        if let v = try? c.decode(Double.self)             { self = .number(v); return }
        if let v = try? c.decode(String.self)             { self = .string(v); return }
        if let v = try? c.decode([String: JSONValue].self){ self = .object(v); return }
        if let v = try? c.decode([JSONValue].self)        { self = .array(v);  return }
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
        guard case .object(let dict) = self else { return nil }
        return dict[key]
    }

    var stringValue: String? {
        guard case .string(let s) = self else { return nil }
        return s
    }
}
