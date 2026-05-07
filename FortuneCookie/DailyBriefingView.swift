import SwiftUI

struct DailyBriefingView: View {
    @StateObject private var vm = DailyBriefingViewModel()
    @State private var showProfile = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Theme.darkRed, Theme.red.opacity(0.85)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                mainContent
                    .animation(.easeInOut(duration: 0.35), value: stateTag)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 1) {
                        Text("Daily Briefing")
                            .font(.system(size: 18, weight: .bold, design: .serif))
                            .foregroundColor(Theme.gold)
                        Text(Date().formatted(.dateTime.weekday(.wide).month().day()))
                            .font(.system(size: 11))
                            .foregroundColor(Theme.lightGold.opacity(0.7))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showProfile = true } label: {
                        Image(systemName: "person.circle")
                            .font(.system(size: 18))
                            .foregroundColor(Theme.gold)
                    }
                }
            }
            .toolbarBackground(Theme.darkRed, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showProfile) { ProfileView() }
        }
    }

    // Drives the animation value — SwiftUI needs Equatable
    private var stateTag: Int {
        switch vm.state {
        case .idle:    return 0
        case .loading: return 1
        case .loaded:  return 2
        case .error:   return 3
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        switch vm.state {
        case .idle:
            idleView
        case .loading(let step):
            loadingView(step: step)
        case .loaded(let sections):
            loadedView(sections: sections)
        case .error(let msg):
            errorView(msg: msg)
        }
    }

    // MARK: - Idle

    private var idleView: some View {
        VStack(spacing: 28) {
            Spacer()
            Text("🌅")
                .font(.system(size: 80))
            VStack(spacing: 8) {
                Text("Good morning")
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundColor(Theme.lightGold)
                Text("Tap below to receive your\npersonalised daily reading")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.gold.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            Button {
                Task { await vm.generate() }
            } label: {
                Label("Generate My Briefing", systemImage: "sparkles")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.inkBlack)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: [Theme.lightGold, Theme.gold],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: Theme.gold.opacity(0.4), radius: 12, y: 4)
            }
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Loading

    private func loadingView(step: String) -> some View {
        VStack(spacing: 22) {
            Spacer()
            ProgressView()
                .scaleEffect(1.6)
                .tint(Theme.gold)
            Text(step)
                .font(.system(size: 16, weight: .medium, design: .serif))
                .foregroundColor(Theme.lightGold)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .id(step)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Loaded

    private func loadedView(sections: [BriefingSection]) -> some View {
        ScrollView {
            VStack(spacing: 14) {
                HStack {
                    if let updated = vm.lastUpdated {
                        Text("Updated \(updated, style: .time)")
                            .font(.system(size: 11))
                            .foregroundColor(Theme.lightGold.opacity(0.55))
                    }
                    Spacer()
                    Button {
                        Task { await vm.generate() }
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Theme.gold)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                ForEach(sections) { section in
                    BriefingSectionCard(section: section)
                        .padding(.horizontal, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .padding(.bottom, 24)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    // MARK: - Error

    private func errorView(msg: String) -> some View {
        VStack(spacing: 18) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(Theme.gold.opacity(0.75))
            Text("Something went wrong")
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundColor(Theme.lightGold)
            Text(msg)
                .font(.system(size: 13))
                .foregroundColor(Theme.lightGold.opacity(0.65))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button {
                Task { await vm.generate() }
            } label: {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.inkBlack)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Theme.gold)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Section card

struct BriefingSectionCard: View {
    let section: BriefingSection

    private var accentColor: Color {
        switch section.emoji {
        case "🌟": return Theme.red
        case "📅": return Color(red: 0.15, green: 0.28, blue: 0.55)
        case "🌐": return Color(red: 0.1,  green: 0.38, blue: 0.22)
        case "🥠": return Color(red: 0.52, green: 0.28, blue: 0.04)
        default:   return Theme.darkRed
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Text(section.emoji)
                    .font(.system(size: 17))
                Text(section.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .tracking(0.4)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(accentColor)

            Text(section.body)
                .font(.system(size: 13, design: .serif))
                .foregroundColor(Theme.inkBlack)
                .fixedSize(horizontal: false, vertical: true)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.paper)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Theme.gold.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
    }
}

#Preview {
    DailyBriefingView()
        .environmentObject(FortuneStore())
}
