import SwiftUI

// MARK: - Almanac colour palette (aged-paper ink style)

private enum Ink {
    static let paper     = Color(red: 0.96, green: 0.92, blue: 0.77)   // aged parchment
    static let paperDark = Color(red: 0.90, green: 0.84, blue: 0.66)   // shadow paper
    static let paperEdge = Color(red: 0.83, green: 0.76, blue: 0.56)   // worn edge
    static let vermilion = Color(red: 0.71, green: 0.05, blue: 0.05)   // Chinese red/cinnabar
    static let crimson   = Color(red: 0.55, green: 0.03, blue: 0.03)   // darker red
    static let inkBlack  = Color(red: 0.10, green: 0.06, blue: 0.01)   // ink black
    static let inkBrown  = Color(red: 0.28, green: 0.16, blue: 0.04)   // aged ink
    static let gold      = Color(red: 0.68, green: 0.52, blue: 0.06)   // tarnished gold
}

// MARK: - Top-level view

struct AlmanacView: View {
    @StateObject private var service = FengshuiService()

    var body: some View {
        ZStack {
            // Aged-paper background with subtle vignette
            Ink.paper.ignoresSafeArea()
            LinearGradient(
                colors: [Ink.paperEdge.opacity(0.6), .clear, Ink.paperEdge.opacity(0.4)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if let a = service.almanac {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        pageHeader
                        mainContent(a)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            } else {
                loadingIndicator
            }
        }
        .onAppear { service.load() }
    }

    // MARK: - Page header (top masthead)

    private var pageHeader: some View {
        VStack(spacing: 0) {
            // Top red band
            ZStack {
                Ink.vermilion
                Text("老 黄 历")
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(Ink.paper)
                    .tracking(12)
            }
            .frame(height: 44)

            // Source label
            if !service.sourceLabel.isEmpty {
                HStack(spacing: 4) {
                    Circle().fill(service.isLoading ? Color.orange : Ink.gold)
                        .frame(width: 5, height: 5)
                    Text(service.sourceLabel)
                        .font(.system(size: 10))
                        .foregroundColor(Ink.inkBrown.opacity(0.7))
                }
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity)
                .background(Ink.paperDark)
            }
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 0)
        )
    }

    // MARK: - Main content

    private func mainContent(_ a: DailyAlmanac) -> some View {
        VStack(spacing: 12) {
            dateCard(a)
            ganzhiCard(a)
            if let term = a.solarTerm { solarTermBanner(term) }
            yiJiCard(a)
            fengshuiCard(a)
            chongCard(a)
            footerNote
        }
        .padding(.top, 12)
    }

    // MARK: - 1. Date card

    private func dateCard(_ a: DailyAlmanac) -> some View {
        AlmanacCard {
            HStack(alignment: .top, spacing: 0) {
                // Left: large lunar day
                VStack(spacing: 0) {
                    Text(a.lunarDay)
                        .font(.system(size: 56, weight: .black))
                        .foregroundColor(Ink.vermilion)
                        .frame(width: 100)
                    Text(a.lunarMonth)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Ink.inkBlack)
                }
                .frame(width: 100)
                .padding(.trailing, 12)

                VStack(alignment: .leading) {
                    Rectangle().fill(Ink.vermilion.opacity(0.2)).frame(height: 1)
                    Text(a.gregorianString)
                        .font(.system(size: 18, weight: .bold, design: .serif))
                        .foregroundColor(Ink.inkBlack)
                    Text(a.weekdayString)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Ink.inkBrown)
                    Rectangle().fill(Ink.vermilion.opacity(0.2)).frame(height: 1)
                    Spacer(minLength: 6)
                    Text(a.lunarYear)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Ink.vermilion)
                    Text("【\(a.zodiac)年】")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Ink.inkBrown)
                    Spacer(minLength: 4)
                    // Day officer badge
                    HStack(spacing: 6) {
                        Text(a.dayOfficer)
                            .font(.system(size: 13, weight: .black))
                            .foregroundColor(Ink.paper)
                            .frame(width: 24, height: 24)
                            .background(Circle().fill(Ink.vermilion))
                        Text(a.nayin)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Ink.inkBrown)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
        }
    }

    // MARK: - 2. Ganzhi pillars

    private func ganzhiCard(_ a: DailyAlmanac) -> some View {
        AlmanacCard {
            VStack(spacing: 8) {
                sectionLabel("干 支")
                HStack(spacing: 0) {
                    pillar(label: "年", ganzhi: a.yearGanzhi)
                    verticalDivider
                    pillar(label: "月", ganzhi: a.monthGanzhi)
                    verticalDivider
                    pillar(label: "日", ganzhi: a.dayGanzhi)
                }
            }
            .padding(14)
        }
    }

    private func pillar(label: String, ganzhi: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Ink.inkBrown.opacity(0.7))
                .tracking(2)
            // Ganzhi in vertical layout
            VStack(spacing: 2) {
                Text(String(ganzhi.prefix(1)))
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(Ink.vermilion)
                Text(String(ganzhi.suffix(1)))
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(Ink.inkBlack)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Ink.paperDark.opacity(0.5))
                    .overlay(RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(Ink.vermilion.opacity(0.3), lineWidth: 1))
            )
        }
        .frame(maxWidth: .infinity)
    }

    private var verticalDivider: some View {
        Rectangle()
            .fill(Ink.vermilion.opacity(0.25))
            .frame(width: 1)
            .padding(.vertical, 8)
    }

    // MARK: - 3. Solar term banner

    private func solarTermBanner(_ term: String) -> some View {
        HStack(spacing: 10) {
            Rectangle().fill(Ink.gold).frame(height: 1)
            Text("✦ 今日\(term) ✦")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Ink.gold)
                .lineLimit(1)
            Rectangle().fill(Ink.gold).frame(height: 1)
        }
        .padding(.horizontal, 4)
    }

    // MARK: - 4. 宜/忌 card

    private func yiJiCard(_ a: DailyAlmanac) -> some View {
        AlmanacCard {
            VStack(spacing: 12) {
                sectionLabel("宜 忌")
                HStack(alignment: .top, spacing: 0) {
                    // 宜
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 4) {
                            Text("宜")
                                .font(.system(size: 16, weight: .black))
                                .foregroundColor(Ink.paper)
                                .frame(width: 26, height: 26)
                                .background(RoundedRectangle(cornerRadius: 4).fill(Ink.vermilion))
                            Text("Auspicious")
                                .font(.system(size: 9))
                                .foregroundColor(Ink.inkBrown.opacity(0.6))
                        }
                        ForEach(a.yi, id: \.self) { item in
                            activityTag(item, good: true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Rectangle()
                        .fill(Ink.vermilion.opacity(0.2))
                        .frame(width: 1)
                        .padding(.vertical, 4)

                    // 忌
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 4) {
                            Text("忌")
                                .font(.system(size: 16, weight: .black))
                                .foregroundColor(Ink.paper)
                                .frame(width: 26, height: 26)
                                .background(RoundedRectangle(cornerRadius: 4).fill(Ink.inkBrown))
                            Text("Inauspicious")
                                .font(.system(size: 9))
                                .foregroundColor(Ink.inkBrown.opacity(0.6))
                        }
                        ForEach(a.ji, id: \.self) { item in
                            activityTag(item, good: false)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 12)
                }
            }
            .padding(14)
        }
    }

    private func activityTag(_ text: String, good: Bool) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(good ? Ink.vermilion : Ink.inkBrown)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(good ? Ink.vermilion.opacity(0.08) : Ink.paperDark.opacity(0.5))
                    .overlay(RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(
                            good ? Ink.vermilion.opacity(0.35) : Ink.inkBrown.opacity(0.25),
                            lineWidth: 0.8
                        )
                    )
            )
    }

    // MARK: - 5. Fengshui card

    private func fengshuiCard(_ a: DailyAlmanac) -> some View {
        AlmanacCard {
            VStack(spacing: 10) {
                sectionLabel("风 水 方 位")
                HStack(spacing: 0) {
                    directionCell(icon: "💰", label: "财神", direction: a.positionCaiShen)
                    directionDivider
                    directionCell(icon: "🎊", label: "喜神", direction: a.positionXiShen)
                    directionDivider
                    directionCell(icon: "🌟", label: "福神", direction: a.positionFuShen)
                }
            }
            .padding(14)
        }
    }

    private func directionCell(icon: String, label: String, direction: String) -> some View {
        VStack(spacing: 5) {
            Text(icon).font(.system(size: 22))
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Ink.inkBrown)
            compassRose(direction: direction)
            Text(direction)
                .font(.system(size: 13, weight: .black))
                .foregroundColor(Ink.vermilion)
        }
        .frame(maxWidth: .infinity)
    }

    private var directionDivider: some View {
        Rectangle()
            .fill(Ink.vermilion.opacity(0.2))
            .frame(width: 1, height: 70)
    }

    /// Simple compass rose showing the lucky direction
    private func compassRose(direction: String) -> some View {
        let angle: Double = {
            switch direction {
            case "正北": return 0
            case "东北": return 45
            case "正东": return 90
            case "东南": return 135
            case "正南": return 180
            case "西南": return 225
            case "正西": return 270
            case "西北": return 315
            default:     return 0
            }
        }()
        return ZStack {
            Circle()
                .stroke(Ink.vermilion.opacity(0.3), lineWidth: 1)
                .frame(width: 30, height: 30)
            // Cardinal marks
            ForEach([0.0, 90.0, 180.0, 270.0], id: \.self) { a in
                Rectangle()
                    .fill(Ink.inkBrown.opacity(0.3))
                    .frame(width: 1, height: 4)
                    .offset(y: -12)
                    .rotationEffect(.degrees(a))
            }
            // Pointer arrow
            Triangle()
                .fill(Ink.vermilion)
                .frame(width: 6, height: 10)
                .offset(y: -8)
                .rotationEffect(.degrees(angle))
        }
        .frame(width: 30, height: 30)
    }

    // MARK: - 6. Clash card

    private func chongCard(_ a: DailyAlmanac) -> some View {
        AlmanacCard {
            VStack(spacing: 8) {
                sectionLabel("冲 煞 彭 祖")
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("冲煞").font(.system(size: 10, weight: .bold)).foregroundColor(Ink.inkBrown.opacity(0.6))
                        Text(a.chongSha)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Ink.inkBlack)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 3) {
                        Text("五行").font(.system(size: 10, weight: .bold)).foregroundColor(Ink.inkBrown.opacity(0.6))
                        Text(a.nayin)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Ink.inkBlack)
                    }
                }
            }
            .padding(14)
        }
    }

    // MARK: - Footer

    private var footerNote: some View {
        VStack(spacing: 4) {
            Rectangle().fill(Ink.vermilion.opacity(0.3)).frame(height: 1)
            Text("黄历仅供参考，不作为行事依据")
                .font(.system(size: 10))
                .foregroundColor(Ink.inkBrown.opacity(0.5))
                .italic()
            Text("The almanac is for reference only")
                .font(.system(size: 9))
                .foregroundColor(Ink.inkBrown.opacity(0.35))
        }
        .padding(.top, 8)
    }

    // MARK: - Loading

    private var loadingIndicator: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(Ink.vermilion)
            Text("卜问今日…")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Ink.inkBrown)
        }
    }

    // MARK: - Shared label

    private func sectionLabel(_ text: String) -> some View {
        HStack(spacing: 6) {
            Rectangle().fill(Ink.vermilion.opacity(0.4)).frame(height: 1)
            Text(text)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Ink.vermilion)
                .tracking(4)
                .lineLimit(1)
                .fixedSize()
            Rectangle().fill(Ink.vermilion.opacity(0.4)).frame(height: 1)
        }
    }
}

// MARK: - Almanac card container (double-border frame)

struct AlmanacCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            // Aged shadow
            RoundedRectangle(cornerRadius: 2)
                .fill(Ink.paperEdge)
                .offset(x: 3, y: 3)

            // Background parchment
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [Ink.paper, Ink.paper.opacity(0.94)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )

            // Outer border (thick)
            RoundedRectangle(cornerRadius: 2)
                .strokeBorder(Ink.vermilion, lineWidth: 2)

            // Inner border (thin, inset 5pt)
            RoundedRectangle(cornerRadius: 1)
                .strokeBorder(Ink.vermilion.opacity(0.55), lineWidth: 0.8)
                .padding(5)

            content
        }
        .compositingGroup()
    }
}

// MARK: - Triangle shape for compass needle

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

// MARK: - Preview

#Preview {
    AlmanacView()
}
