import Foundation

// MARK: - API response models (mxnzp.com free tier)
// Register for a free key at: https://www.mxnzp.com/

private struct MXNZPResponse: Codable {
    let code: Int
    let data: MXNZPData?
}
private struct MXNZPData: Codable {
    let lunarYear: String?
    let lunarMonth: String?
    let lunarDay: String?
    let solarTerm: String?
    let weekDayTips: String?
    let yi: [String]?
    let ji: [String]?
    let chongSha: String?
    let wuXing: String?
    let positionCaiShen: String?
    let positionXiShen: String?
    let positionFuShen: String?
    let zhiShen: String?
    let yearTips: String?
}

// MARK: - API configuration
// Get a free key at https://www.mxnzp.com (50 calls/day free tier)
// Leave empty to use fully-offline local computation.
enum FengshuiAPIConfig {
    static let appId     = ""   // ← paste your mxnzp app_id here
    static let appSecret = ""   // ← paste your mxnzp app_secret here
    static var isConfigured: Bool { !appId.isEmpty && !appSecret.isEmpty }
}

// MARK: - Service

@MainActor
class FengshuiService: ObservableObject {
    @Published private(set) var almanac: DailyAlmanac?
    @Published private(set) var isLoading = false
    @Published private(set) var sourceLabel = ""   // "本地计算" or "实时数据"

    private let greg = Calendar(identifier: .gregorian)

    func load(for date: Date = Date()) {
        let local = ChineseCalendarEngine.calculate(for: date)
        almanac     = local
        sourceLabel = "本地计算"

        // Live API fetch disabled — uncomment when mxnzp.com credentials are available
        // guard FengshuiAPIConfig.isConfigured else { return }
        // isLoading = true
        // Task {
        //     if let enhanced = try? await fetchFromAPI(date: date, base: local) {
        //         almanac     = enhanced
        //         sourceLabel = "实时数据"
        //     }
        //     isLoading = false
        // }
    }

    // MARK: - API fetch

    private func fetchFromAPI(date: Date, base: DailyAlmanac) async throws -> DailyAlmanac {
        let y = greg.component(.year,  from: date)
        let m = greg.component(.month, from: date)
        let d = greg.component(.day,   from: date)
        let dateStr = String(format: "%04d%02d%02d", y, m, d)

        var comps = URLComponents(string: "https://www.mxnzp.com/api/lunar/info/\(dateStr)")!
        comps.queryItems = [
            URLQueryItem(name: "app_id",     value: FengshuiAPIConfig.appId),
            URLQueryItem(name: "app_secret", value: FengshuiAPIConfig.appSecret),
        ]
        guard let url = comps.url else { throw URLError(.badURL) }

        let (data, _) = try await URLSession.shared.data(from: url)
        let resp = try JSONDecoder().decode(MXNZPResponse.self, from: data)
        guard let api = resp.data, resp.code == 1 else { throw URLError(.badServerResponse) }

        // Merge API data on top of local calculation (API wins where non-empty)
        return DailyAlmanac(
            date:            base.date,
            gregorianString: base.gregorianString,
            weekdayString:   api.weekDayTips  ?? base.weekdayString,
            lunarYear:       api.lunarYear    ?? base.lunarYear,
            lunarMonthDay:   (api.lunarMonth ?? "") + (api.lunarDay ?? ""),
            lunarMonth:      api.lunarMonth   ?? base.lunarMonth,
            lunarDay:        api.lunarDay     ?? base.lunarDay,
            zodiac:          base.zodiac,
            yearGanzhi:      base.yearGanzhi,
            monthGanzhi:     base.monthGanzhi,
            dayGanzhi:       base.dayGanzhi,
            nayin:           api.wuXing       ?? base.nayin,
            dayOfficer:      api.zhiShen      ?? base.dayOfficer,
            solarTerm:       api.solarTerm.flatMap { $0.isEmpty ? nil : $0 } ?? base.solarTerm,
            yi:              api.yi?.isEmpty == false ? api.yi! : base.yi,
            ji:              api.ji?.isEmpty == false ? api.ji! : base.ji,
            positionCaiShen: api.positionCaiShen ?? base.positionCaiShen,
            positionXiShen:  api.positionXiShen  ?? base.positionXiShen,
            positionFuShen:  api.positionFuShen  ?? base.positionFuShen,
            chongSha:        api.chongSha        ?? base.chongSha,
            dayQuality:      base.dayQuality
        )
    }
}
