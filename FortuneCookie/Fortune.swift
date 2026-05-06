import Foundation

struct FortuneTemplate {
    let text: String
    let character: String
    let characterMeaning: String
    let idiom: String
    let idiomPinyin: String
    let idiomMeaning: String
}

struct Fortune: Identifiable, Codable {
    let id: UUID
    let text: String
    let luckyNumbers: [Int]
    let character: String
    let characterMeaning: String
    let idiom: String
    let idiomPinyin: String
    let idiomMeaning: String
    let drawnAt: Date
    var isSaved: Bool
    let rank: FortuneRank
    let xpEarned: Int

    init(template: FortuneTemplate, rank: FortuneRank) {
        self.id = UUID()
        self.text = template.text
        self.character = template.character
        self.characterMeaning = template.characterMeaning
        self.idiom = template.idiom
        self.idiomPinyin = template.idiomPinyin
        self.idiomMeaning = template.idiomMeaning
        self.drawnAt = Date()
        self.isSaved = false
        self.rank = rank
        self.xpEarned = rank.xp

        var used = Set<Int>()
        var white: [Int] = []
        while white.count < 5 {
            let n = Int.random(in: 1...69)
            if used.insert(n).inserted { white.append(n) }
        }
        self.luckyNumbers = white.sorted() + [Int.random(in: 1...26)]
    }

    // Custom decoder for backward-compatibility with data that predates rank/xpEarned
    enum CodingKeys: String, CodingKey {
        case id, text, luckyNumbers, character, characterMeaning
        case idiom, idiomPinyin, idiomMeaning, drawnAt, isSaved
        case rank, xpEarned
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id               = try c.decode(UUID.self,   forKey: .id)
        text             = try c.decode(String.self, forKey: .text)
        luckyNumbers     = try c.decode([Int].self,  forKey: .luckyNumbers)
        character        = try c.decode(String.self, forKey: .character)
        characterMeaning = try c.decode(String.self, forKey: .characterMeaning)
        idiom            = try c.decode(String.self, forKey: .idiom)
        idiomPinyin      = try c.decode(String.self, forKey: .idiomPinyin)
        idiomMeaning     = try c.decode(String.self, forKey: .idiomMeaning)
        drawnAt          = try c.decode(Date.self,   forKey: .drawnAt)
        isSaved          = try c.decode(Bool.self,   forKey: .isSaved)
        rank     = try c.decodeIfPresent(FortuneRank.self, forKey: .rank)     ?? .kichi
        xpEarned = try c.decodeIfPresent(Int.self,         forKey: .xpEarned) ?? 12
    }
}
