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

    init(template: FortuneTemplate) {
        self.id = UUID()
        self.text = template.text
        self.character = template.character
        self.characterMeaning = template.characterMeaning
        self.idiom = template.idiom
        self.idiomPinyin = template.idiomPinyin
        self.idiomMeaning = template.idiomMeaning
        self.drawnAt = Date()
        self.isSaved = false

        var used = Set<Int>()
        var white: [Int] = []
        while white.count < 5 {
            let n = Int.random(in: 1...69)
            if used.insert(n).inserted { white.append(n) }
        }
        self.luckyNumbers = white.sorted() + [Int.random(in: 1...26)]
    }
}
