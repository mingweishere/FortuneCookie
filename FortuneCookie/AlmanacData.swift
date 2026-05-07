import Foundation

// MARK: - Data model

struct DailyAlmanac {
    let date: Date
    // Solar
    let gregorianString: String    // "2026年5月6日"
    let weekdayString: String      // "星期三"
    // Lunar
    let lunarYear: String          // "乙巳年"
    let lunarMonthDay: String      // "四月初十"
    let lunarMonth: String         // "四月"
    let lunarDay: String           // "初十"
    let zodiac: String             // "蛇"
    // Ganzhi
    let yearGanzhi: String         // "乙巳"
    let monthGanzhi: String        // "庚辰"
    let dayGanzhi: String          // "甲午"
    // Five elements
    let nayin: String              // "大驿土"
    // Day officer (建除十二神)
    let dayOfficer: String         // "满"
    // Solar term
    let solarTerm: String?         // "立夏" or nil
    // Activities
    let yi: [String]               // Auspicious
    let ji: [String]               // Inauspicious
    // Fengshui directions
    let positionCaiShen: String    // 财神 "正东"
    let positionXiShen: String     // 喜神 "东南"
    let positionFuShen: String     // 福神 "正北"
    // Clash
    let chongSha: String           // "冲马（壬午）煞南"
    // Day quality
    let dayQuality: DayQuality

    enum DayQuality {
        case excellent, good, neutral, caution, bad
        var label: String {
            switch self {
            case .excellent: return "大吉"
            case .good:      return "吉"
            case .neutral:   return "平"
            case .caution:   return "凶"
            case .bad:       return "大凶"
            }
        }
        var color: AlmanacColor { self == .excellent || self == .good ? .red : self == .neutral ? .ink : .red }
    }
    enum AlmanacColor { case red, ink }
}

// MARK: - Local calculator

struct ChineseCalendarEngine {

    // MARK: Constants

    static let tiangan   = ["甲","乙","丙","丁","戊","己","庚","辛","壬","癸"]
    static let dizhi     = ["子","丑","寅","卯","辰","巳","午","未","申","酉","戌","亥"]
    static let zodiac    = ["鼠","牛","虎","兔","龙","蛇","马","羊","猴","鸡","狗","猪"]
    static let lunarMonthNames = [
        "正月","二月","三月","四月","五月","六月",
        "七月","八月","九月","十月","冬月","腊月"
    ]
    static let lunarDayNames = [
        "初一","初二","初三","初四","初五","初六","初七","初八","初九","初十",
        "十一","十二","十三","十四","十五","十六","十七","十八","十九","二十",
        "廿一","廿二","廿三","廿四","廿五","廿六","廿七","廿八","廿九","三十"
    ]
    // 纳音五行 for each pair of the 60-cycle
    static let nayin60 = [
        "海中金","海中金","炉中火","炉中火","大林木","大林木",
        "路旁土","路旁土","剑锋金","剑锋金","山头火","山头火",
        "涧下水","涧下水","城头土","城头土","白蜡金","白蜡金",
        "杨柳木","杨柳木","泉中水","泉中水","屋上土","屋上土",
        "霹雳火","霹雳火","松柏木","松柏木","长流水","长流水",
        "沙中金","沙中金","山下火","山下火","平地木","平地木",
        "壁上土","壁上土","金箔金","金箔金","覆灯火","覆灯火",
        "天河水","天河水","大驿土","大驿土","钗钏金","钗钏金",
        "桑柘木","桑柘木","大溪水","大溪水","沙中土","沙中土",
        "天上火","天上火","石榴木","石榴木","大海水","大海水"
    ]
    static let dayOfficers = ["建","除","满","平","定","执","破","危","成","收","开","闭"]

    // 财神/喜神/福神 directions by day stem (甲乙丙丁戊己庚辛壬癸)
    static let caiShenDir = ["正东","正北","正西","正南","东北","正东","西北","正南","东北","正西"]
    static let xiShenDir  = ["东南","东北","西南","西北","东北","东南","西南","西北","东北","西南"]
    static let fuShenDir  = ["正南","正东","正北","正西","正南","正北","正东","正西","正南","正东"]

    // Auspicious activities by day branch index
    static let yiByBranch: [[String]] = [
        ["开市","出行","祭祀","祈福","纳采","求财"],          // 子
        ["祭祀","祈福","嫁娶","移徙","入宅","纳财","纳采"],   // 丑
        ["出行","求财","开市","赴任","安床","祭祀","纳采"],    // 寅
        ["祭祀","祈福","嫁娶","开光","出行","造屋","纳财"],    // 卯
        ["开市","纳财","祈福","嫁娶","移徙","入宅","造屋"],    // 辰
        ["祭祀","开光","祈福","纳财","出行"],                  // 巳
        ["出行","求财","开市","赴任","纳采","嫁娶"],           // 午
        ["祭祀","祈福","出行","纳财","开市","嫁娶","移徙"],    // 未
        ["开市","纳财","出行","赴任","祈福","动土","安床"],    // 申
        ["祭祀","祈福","出行","纳财","纳采","嫁娶","开光"],    // 酉
        ["出行","开市","纳财","祈福","移徙","入宅"],           // 戌
        ["祭祀","祈福","出行","纳采","嫁娶","纳财","开市"],    // 亥
    ]
    // Inauspicious activities by day branch index
    static let jiByBranch: [[String]] = [
        ["嫁娶","安床","修造","动土","破土"],          // 子
        ["开市","动土","破土","安葬","行丧"],          // 丑
        ["嫁娶","安葬","破土","掘井"],                 // 寅
        ["动土","破土","安葬","掘井","行丧"],          // 卯
        ["嫁娶","安葬","破土","行丧"],                 // 辰
        ["嫁娶","动土","破土","安葬","修造"],          // 巳
        ["安葬","破土","修造","动土"],                 // 午
        ["嫁娶","动土","破土","安葬","掘井"],          // 未
        ["嫁娶","破土","安葬","行丧"],                 // 申
        ["嫁娶","动土","破土","安葬"],                 // 酉
        ["嫁娶","破土","安葬","行丧"],                 // 戌
        ["嫁娶","动土","破土","安葬"],                 // 亥
    ]

    // Clash zodiac by day branch (clashes with opposite)
    static let chongZodiac  = ["马","羊","猴","鸡","狗","猪","鼠","牛","虎","兔","龙","蛇"]
    static let shaDirection  = ["南","西","南","西","北","东","北","东","北","东","南","西"]

    // 2026 solar terms (month-day pairs, 24 nodes)
    static let solarTerms2026: [(month: Int, day: Int, name: String)] = [
        (1,5,"小寒"),(1,20,"大寒"),
        (2,4,"立春"),(2,19,"雨水"),
        (3,6,"惊蛰"),(3,21,"春分"),
        (4,5,"清明"),(4,20,"谷雨"),
        (5,5,"立夏"),(5,21,"小满"),
        (6,6,"芒种"),(6,21,"夏至"),
        (7,7,"小暑"),(7,23,"大暑"),
        (8,7,"立秋"),(8,23,"处暑"),
        (9,8,"白露"),(9,23,"秋分"),
        (10,8,"寒露"),(10,23,"霜降"),
        (11,7,"立冬"),(11,22,"小雪"),
        (12,7,"大雪"),(12,22,"冬至"),
    ]

    // Day anchor: 2000-01-07 = 甲子日 (cycle index 0)
    private static let dayAnchor: Date = {
        var c = DateComponents()
        c.year = 2000; c.month = 1; c.day = 7
        return Calendar(identifier: .gregorian).date(from: c)!
    }()

    // MARK: - Main calculation

    static func calculate(for date: Date) -> DailyAlmanac {
        let greg = Calendar(identifier: .gregorian)
        let chin = Calendar(identifier: .chinese)

        // --- Gregorian components ---
        let gYear  = greg.component(.year,    from: date)
        let gMonth = greg.component(.month,   from: date)
        let gDay   = greg.component(.day,     from: date)
        let weekday = greg.component(.weekday, from: date) // 1=Sun

        let weekdayNames = ["星期日","星期一","星期二","星期三","星期四","星期五","星期六"]
        let weekdayStr = weekdayNames[weekday - 1]

        let gregStr = "\(gYear)年\(gMonth)月\(gDay)日"

        // --- Chinese (lunar) components ---
        let chinComps = chin.dateComponents([.year, .month, .day, .isLeapMonth], from: date)
        let cYear    = chinComps.year  ?? 1
        let cMonth   = chinComps.month ?? 1
        let cDay     = chinComps.day   ?? 1
        let isLeap   = chinComps.isLeapMonth ?? false

        // Year ganzhi
        let yCycleIdx  = (cYear - 1) % 60
        let yStemIdx   = yCycleIdx % 10
        let yBranchIdx = yCycleIdx % 12
        let yearGanzhi = tiangan[yStemIdx] + dizhi[yBranchIdx]
        let zodiacStr  = zodiac[yBranchIdx]
        let lunarYear  = yearGanzhi + "年"

        // Month ganzhi
        let monthStemBases = [2, 4, 6, 8, 0, 2, 4, 6, 8, 0]
        let mStemIdx   = (monthStemBases[yStemIdx % 5] + (cMonth - 1)) % 10
        let mBranchIdx = (cMonth + 1) % 12
        let monthGanzhi = tiangan[mStemIdx] + dizhi[mBranchIdx]

        // Day ganzhi (days since anchor / 60-cycle)
        let daysSince = greg.dateComponents([.day], from: dayAnchor, to: date).day ?? 0
        let dCycleIdx  = ((daysSince % 60) + 60) % 60
        let dStemIdx   = dCycleIdx % 10
        let dBranchIdx = dCycleIdx % 12
        let dayGanzhi  = tiangan[dStemIdx] + dizhi[dBranchIdx]

        // Lunar month/day strings
        let monthPrefix = isLeap ? "闰" : ""
        let lunarMonthStr = monthPrefix + lunarMonthNames[cMonth - 1]
        let lunarDayStr   = lunarDayNames[cDay - 1]

        // Five elements (纳音)
        let nayin = nayin60[dCycleIdx / 2]

        // Day officer (建除十二神)
        let officerIdx = ((dBranchIdx - mBranchIdx) % 12 + 12) % 12
        let officer = dayOfficers[officerIdx]

        // Solar term check
        let solarTerm: String? = solarTerms2026.first {
            $0.month == gMonth && $0.day == gDay && gYear == 2026
        }?.name

        // 宜/忌
        var yi = Array(yiByBranch[dBranchIdx].prefix(5))
        var ji = Array(jiByBranch[dBranchIdx].prefix(4))
        // Adjust based on day officer
        if officer == "破" {
            yi = ["祭祀","祈福"]
            ji = ["百事不宜","开市","嫁娶","出行","动土","破土"]
        } else if officer == "开" {
            yi.insert("嫁娶", at: 0)
        }

        // Lucky directions
        let caiShen = caiShenDir[dStemIdx]
        let xiShen  = xiShenDir[dStemIdx]
        let fuShen  = fuShenDir[dStemIdx]

        // Clash
        let chongAnimal = chongZodiac[dBranchIdx]
        let sha         = shaDirection[dBranchIdx]
        let chongSha = "冲\(chongAnimal)（\(tiangan[(dStemIdx + 6) % 10])\(dizhi[(dBranchIdx + 6) % 12])）煞\(sha)"

        // Day quality based on officer
        let quality: DailyAlmanac.DayQuality
        switch officer {
        case "建","除","满","成","开": quality = .good
        case "定","执":               quality = .neutral
        case "破","危":               quality = .caution
        case "平","收","闭":          quality = .neutral
        default:                      quality = .neutral
        }

        return DailyAlmanac(
            date:           date,
            gregorianString: gregStr,
            weekdayString:  weekdayStr,
            lunarYear:      lunarYear,
            lunarMonthDay:  lunarMonthStr + lunarDayStr,
            lunarMonth:     lunarMonthStr,
            lunarDay:       lunarDayStr,
            zodiac:         zodiacStr,
            yearGanzhi:     yearGanzhi,
            monthGanzhi:    monthGanzhi,
            dayGanzhi:      dayGanzhi,
            nayin:          nayin,
            dayOfficer:     officer,
            solarTerm:      solarTerm,
            yi:             yi,
            ji:             ji,
            positionCaiShen: caiShen,
            positionXiShen:  xiShen,
            positionFuShen:  fuShen,
            chongSha:       chongSha,
            dayQuality:     quality
        )
    }
}
