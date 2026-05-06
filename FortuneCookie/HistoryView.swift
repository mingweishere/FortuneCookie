import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var store: FortuneStore
    @State private var selectedFortune: Fortune?

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Theme.darkRed, Theme.red.opacity(0.85)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                if store.todayFortunes.isEmpty {
                    emptyState
                } else {
                    cookieGrid
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 1) {
                        Text("Today's Cookies")
                            .font(.system(size: 18, weight: .bold, design: .serif))
                            .foregroundColor(Theme.gold)
                        let todayXP = store.todayFortunes.reduce(0) { $0 + $1.xpEarned }
                        Text("\(store.todayFortunes.count)/24 opened  ·  +\(todayXP) XP today")
                            .font(.system(size: 11))
                            .foregroundColor(Theme.lightGold.opacity(0.7))
                    }
                }
            }
            .toolbarBackground(Theme.darkRed, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(item: $selectedFortune) { fortune in
                FortuneDetailSheet(fortune: fortune)
                    .environmentObject(store)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Text("🥠")
                .font(.system(size: 80))
                .opacity(0.4)
            Text("No cookies opened yet today")
                .font(.system(size: 17, weight: .medium, design: .serif))
                .foregroundColor(Theme.lightGold.opacity(0.7))
            Text("Go draw your first fortune!")
                .font(.system(size: 14))
                .foregroundColor(Theme.gold.opacity(0.5))
        }
    }

    // MARK: - Cookie Grid

    private var cookieGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(store.todayFortunes) { fortune in
                    CookieTileView(fortune: fortune)
                        .onTapGesture { selectedFortune = fortune }
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Cookie Tile

struct CookieTileView: View {
    let fortune: Fortune

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Rank color accent strip
            fortune.rank.color
                .frame(height: 4)

            // Card header
            ZStack {
                Theme.red
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(fortune.character)
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                        // Rank label
                        HStack(spacing: 3) {
                            Text(fortune.rank.emoji)
                                .font(.system(size: 9))
                            Text(fortune.rank.chinese)
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(fortune.rank.color)
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        if fortune.isSaved {
                            Image(systemName: "bookmark.fill")
                                .foregroundColor(Theme.gold)
                                .font(.system(size: 13))
                        }
                        Text("+\(fortune.xpEarned) XP")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundColor(Theme.gold)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }

            // Fortune preview
            VStack(alignment: .leading, spacing: 8) {
                Text("🥠")
                    .font(.system(size: 28))

                Text(fortune.text)
                    .font(.system(size: 11, weight: .medium, design: .serif))
                    .foregroundColor(Theme.inkBlack)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)

                HStack(spacing: 4) {
                    ForEach(fortune.luckyNumbers.prefix(3), id: \.self) { n in
                        Text("\(n)")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(Theme.red)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Theme.gold.opacity(0.2)))
                    }
                    Text("···")
                        .font(.system(size: 9))
                        .foregroundColor(Theme.inkBlack.opacity(0.4))
                }

                Text(fortune.drawnAt, style: .time)
                    .font(.system(size: 9))
                    .foregroundColor(Theme.inkBlack.opacity(0.45))
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.paper)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Theme.gold.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
    }
}

// MARK: - Fortune Detail Sheet

struct FortuneDetailSheet: View {
    let fortune: Fortune
    @EnvironmentObject var store: FortuneStore
    @Environment(\.dismiss) private var dismiss
    @State private var isSaved: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.07, green: 0.03, blue: 0.01), Theme.darkRed.opacity(0.9)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        Text("🥠")
                            .font(.system(size: 64))
                            .padding(.top, 24)

                        // Rank badge
                        HStack(spacing: 14) {
                            Text(fortune.rank.emoji)
                                .font(.system(size: 28))
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Text(fortune.rank.chinese)
                                        .font(.system(size: 26, weight: .black))
                                        .foregroundColor(fortune.rank.color)
                                    Text(fortune.rank.title)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white.opacity(0.85))
                                }
                                HStack(spacing: 3) {
                                    ForEach(0..<5) { i in
                                        Image(systemName: i < fortune.rank.stars ? "star.fill" : "star")
                                            .font(.system(size: 10))
                                            .foregroundColor(i < fortune.rank.stars ? fortune.rank.color : Color.white.opacity(0.25))
                                    }
                                    Text("  +\(fortune.rank.xp) XP")
                                        .font(.system(size: 11, weight: .black, design: .rounded))
                                        .foregroundColor(Theme.gold)
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(fortune.rank.color.opacity(0.12))
                                .overlay(RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(fortune.rank.color.opacity(0.55), lineWidth: 1.5))
                        )
                        .padding(.horizontal, 20)

                        // Rank detail description
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "quote.opening")
                                .font(.system(size: 12))
                                .foregroundColor(fortune.rank.color.opacity(0.7))
                                .padding(.top, 2)
                            Text(fortune.rank.detail)
                                .font(.system(size: 13, design: .serif))
                                .foregroundColor(Theme.lightGold.opacity(0.85))
                                .italic()
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 24)

                        fullCard
                            .padding(.horizontal, 20)
                            .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Theme.gold)
                            .fontWeight(.semibold)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        store.toggleSave(fortune)
                        isSaved.toggle()
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                            .foregroundColor(isSaved ? Theme.gold : Theme.gold.opacity(0.6))
                            .fontWeight(.semibold)
                    }
                }
            }
            .toolbarBackground(Theme.darkRed, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear { isSaved = fortune.isSaved }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.clear)
    }

    private var fullCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("🥠  Fortune Cookie  🥠")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
                .tracking(2)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Theme.red)

            VStack(alignment: .leading, spacing: 20) {
                Text("\u{201C}\(fortune.text)\u{201D}")
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .foregroundColor(Theme.inkBlack)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)

                Divider().background(Theme.red.opacity(0.25))

                HStack(alignment: .top, spacing: 16) {
                    VStack(spacing: 4) {
                        Text(fortune.character)
                            .font(.system(size: 54, weight: .bold))
                            .foregroundColor(Theme.red)
                        Text(fortune.characterMeaning)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Theme.inkBlack.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .frame(width: 72)
                    }
                    .frame(width: 72)

                    Rectangle()
                        .fill(Theme.red.opacity(0.18))
                        .frame(width: 1)
                        .padding(.vertical, 2)

                    VStack(alignment: .leading, spacing: 5) {
                        Text("成语 · Idiom")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Theme.red.opacity(0.65))
                            .tracking(1)
                        Text(fortune.idiom)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Theme.inkBlack)
                        Text(fortune.idiomPinyin)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Theme.red.opacity(0.85))
                            .italic()
                        Text(fortune.idiomMeaning)
                            .font(.system(size: 12))
                            .foregroundColor(Theme.inkBlack.opacity(0.72))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, 2)

                Divider().background(Theme.red.opacity(0.25))

                VStack(spacing: 8) {
                    Text("Lucky Numbers")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Theme.red.opacity(0.65))
                        .tracking(2)
                        .frame(maxWidth: .infinity)
                    HStack(spacing: 8) {
                        ForEach(fortune.luckyNumbers.prefix(5), id: \.self) { n in
                            Text("\(n)")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(Theme.inkBlack)
                                .frame(width: 33, height: 33)
                                .background(Circle().fill(Theme.gold.opacity(0.28)))
                        }
                        Text("·")
                            .foregroundColor(Theme.inkBlack.opacity(0.3))
                            .font(.title3)
                        if let last = fortune.luckyNumbers.last {
                            Text("\(last)")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .frame(width: 33, height: 33)
                                .background(Circle().fill(Theme.red))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(20)
            .background(Theme.paper)

            Text(fortune.drawnAt, style: .time)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.65))
                .tracking(1)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(Theme.red)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Theme.gold.opacity(0.45), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.45), radius: 20, y: 8)
    }
}

#Preview {
    HistoryView()
        .environmentObject(FortuneStore())
}
