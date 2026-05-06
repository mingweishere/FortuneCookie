import SwiftUI

struct DrawView: View {
    @EnvironmentObject var store: FortuneStore
    @State private var drawnFortune: Fortune?
    @State private var showReveal = false
    @State private var jarShake: CGFloat = 0
    @State private var buttonPulse = false

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundLayer
                VStack(spacing: 0) {
                    headerDecoration
                    Spacer()
                    jarSection
                    Spacer()
                    drawSection
                    Spacer(minLength: 32)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showReveal) {
                if let fortune = drawnFortune {
                    CookieRevealView(fortune: fortune)
                }
            }
        }
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.darkRed, Theme.red, Color(red: 0.55, green: 0.02, blue: 0.02)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Decorative watermark characters
            VStack {
                HStack {
                    decorativeChar("福", size: 90, opacity: 0.07)
                    Spacer()
                    decorativeChar("喜", size: 70, opacity: 0.06)
                }
                Spacer()
                HStack {
                    Spacer()
                    decorativeChar("运", size: 80, opacity: 0.06)
                    Spacer()
                }
                Spacer()
                HStack {
                    decorativeChar("寿", size: 65, opacity: 0.07)
                    Spacer()
                    decorativeChar("禄", size: 75, opacity: 0.06)
                }
            }
            .padding(24)
            .ignoresSafeArea()
        }
    }

    private func decorativeChar(_ text: String, size: CGFloat, opacity: Double) -> some View {
        Text(text)
            .font(.system(size: size, weight: .bold, design: .default))
            .foregroundColor(Theme.gold.opacity(opacity))
    }

    // MARK: - Header

    private var headerDecoration: some View {
        VStack(spacing: 6) {
            HStack(spacing: 16) {
                Text("🏮").font(.system(size: 36))
                VStack(spacing: 2) {
                    Text("Fortune Cookie")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(Theme.gold)
                    Text("今日运势")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.lightGold.opacity(0.8))
                        .tracking(6)
                }
                Text("🏮").font(.system(size: 36))
            }

            // Ornamental divider
            HStack(spacing: 4) {
                goldLine
                Text("✦").foregroundColor(Theme.gold).font(.system(size: 10))
                goldLine
            }
            .padding(.horizontal, 40)
        }
        .padding(.top, 20)
        .padding(.bottom, 8)
    }

    private var goldLine: some View {
        Rectangle()
            .fill(Theme.gold.opacity(0.5))
            .frame(height: 1)
    }

    // MARK: - Jar Section

    private var jarSection: some View {
        VStack(spacing: 16) {
            JarView(cookieCount: store.remainingDraws)
                .offset(x: jarShake)

            Text(store.canDraw
                 ? "\(store.remainingDraws) fortune\(store.remainingDraws == 1 ? "" : "s") remaining today"
                 : "Come back in \(store.timeUntilReset())")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Theme.lightGold.opacity(0.85))
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.black.opacity(0.25)))
        }
    }

    // MARK: - Draw Button

    private var drawSection: some View {
        VStack(spacing: 14) {
            Button {
                handleDraw()
            } label: {
                HStack(spacing: 10) {
                    Text("🥠")
                        .font(.system(size: 22))
                        .scaleEffect(buttonPulse ? 1.15 : 1.0)
                    Text(store.canDraw ? "Draw Your Fortune" : "No More Draws Today")
                        .font(.system(size: 18, weight: .bold, design: .serif))
                }
                .foregroundColor(store.canDraw ? Theme.inkBlack : Theme.gold.opacity(0.5))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    store.canDraw
                        ? LinearGradient(colors: [Theme.lightGold, Theme.gold], startPoint: .top, endPoint: .bottom)
                        : LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)], startPoint: .top, endPoint: .bottom)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: store.canDraw ? Theme.gold.opacity(0.4) : .clear, radius: 12, y: 4)
            }
            .disabled(!store.canDraw)
            .padding(.horizontal, 32)
            .onAppear {
                guard store.canDraw else { return }
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    buttonPulse = true
                }
            }
            .onChange(of: store.canDraw) { _, newValue in
                if !newValue { buttonPulse = false }
            }

            if !store.todayFortunes.isEmpty {
                Text("\(store.todayFortunes.count) opened today")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.lightGold.opacity(0.6))
            }
        }
    }

    // MARK: - Actions

    private func handleDraw() {
        guard store.canDraw else { return }

        withAnimation(.interpolatingSpring(stiffness: 300, damping: 5)) { jarShake = 10 }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        Task {
            try? await Task.sleep(for: .milliseconds(300))
            withAnimation(.interpolatingSpring(stiffness: 300, damping: 5)) { jarShake = 0 }
            try? await Task.sleep(for: .milliseconds(100))
            drawnFortune = store.drawFortune()
            if drawnFortune != nil { showReveal = true }
        }
    }
}

// MARK: - Jar View

struct JarView: View {
    let cookieCount: Int

    var body: some View {
        ZStack(alignment: .top) {
            // Jar body
            VStack(spacing: 0) {
                // Lid
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(colors: [Theme.lightGold, Theme.gold], startPoint: .top, endPoint: .bottom))
                        .frame(width: 124, height: 16)
                    // Lid knob
                    Capsule()
                        .fill(Theme.gold)
                        .frame(width: 30, height: 8)
                        .offset(y: -10)
                }
                .zIndex(1)

                // Neck
                Rectangle()
                    .fill(jarGradient)
                    .frame(width: 100, height: 22)
                    .overlay(Rectangle().fill(jarShine).frame(width: 14).offset(x: -28))

                // Body
                RoundedRectangle(cornerRadius: 16)
                    .fill(jarGradient)
                    .frame(width: 160, height: 170)
                    .overlay(
                        // Shine strip
                        RoundedRectangle(cornerRadius: 16)
                            .fill(jarShine)
                            .frame(width: 18)
                            .offset(x: -52)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    )
                    .overlay(
                        cookiesGrid
                            .padding(.horizontal, 12)
                            .padding(.vertical, 16)
                    )
            }
        }
        .compositingGroup()
        .shadow(color: Color.black.opacity(0.35), radius: 16, y: 8)
    }

    private var jarGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.88, green: 0.72, blue: 0.28).opacity(0.55),
                Color(red: 0.65, green: 0.50, blue: 0.12).opacity(0.50),
                Color(red: 0.80, green: 0.64, blue: 0.20).opacity(0.48),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var jarShine: LinearGradient {
        LinearGradient(
            colors: [Color.white.opacity(0.25), Color.white.opacity(0.05)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    @ViewBuilder
    private var cookiesGrid: some View {
        let count = min(cookieCount, 9)
        if count == 0 {
            Text("空")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(Theme.gold.opacity(0.3))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                spacing: 4
            ) {
                ForEach(0..<count, id: \.self) { _ in
                    Text("🥠").font(.system(size: 26))
                }
            }
        }
    }
}

#Preview {
    DrawView()
        .environmentObject(FortuneStore())
}
