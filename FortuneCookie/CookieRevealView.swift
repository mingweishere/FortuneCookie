import SwiftUI

private enum BreakState { case whole, broken }

struct CookieRevealView: View {
    let fortune: Fortune
    @EnvironmentObject var store: FortuneStore
    @Environment(\.dismiss) private var dismiss

    @State private var breakState: BreakState = .whole
    @State private var shakeAngle: Double = 0
    @State private var leftOffset   = CGSize.zero
    @State private var rightOffset  = CGSize.zero
    @State private var leftRotation:  Double = 0
    @State private var rightRotation: Double = 0
    @State private var piecesOpacity: Double = 1
    @State private var cardOffset:    CGFloat = 80
    @State private var cardOpacity:   Double  = 0
    @State private var isSaved: Bool = false

    var body: some View {
        ZStack {
            background
            VStack(spacing: 0) {
                if breakState == .whole {
                    wholeCookieView
                } else {
                    brokenView
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Theme.gold)
                        .fontWeight(.semibold)
                }
            }
        }
        .onAppear { isSaved = fortune.isSaved }
    }

    // MARK: - Background

    private var background: some View {
        LinearGradient(
            colors: [Color(red: 0.07, green: 0.03, blue: 0.01), Theme.darkRed.opacity(0.9)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // MARK: - Whole Cookie

    private var wholeCookieView: some View {
        VStack(spacing: 36) {
            Spacer()

            Text("Your Fortune Awaits")
                .font(.system(size: 22, weight: .semibold, design: .serif))
                .foregroundColor(Theme.lightGold)

            Text("🥠")
                .font(.system(size: 120))
                .rotationEffect(.degrees(shakeAngle))
                .shadow(color: Theme.gold.opacity(0.5), radius: 24)
                .onTapGesture { startBreak() }

            VStack(spacing: 6) {
                Text("Tap to break")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Theme.gold.opacity(0.75))
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Theme.gold.opacity(0.5))
            }

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Broken View

    private var brokenView: some View {
        VStack(spacing: 0) {
            // Flying pieces
            ZStack {
                Text("🥠")
                    .font(.system(size: 68))
                    .offset(leftOffset)
                    .rotationEffect(.degrees(leftRotation))
                    .opacity(piecesOpacity)

                Text("🥠")
                    .font(.system(size: 68))
                    .offset(rightOffset)
                    .rotationEffect(.degrees(rightRotation))
                    .opacity(piecesOpacity)
            }
            .frame(height: 130)
            .padding(.top, 16)

            // Fortune card in scroll view
            ScrollView {
                fortuneCard
                    .offset(y: cardOffset)
                    .opacity(cardOpacity)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
            }
            .scrollBounceBehavior(.basedOnSize)

            // Action buttons
            actionBar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { animateReveal() }
    }

    // MARK: - Fortune Card

    private var fortuneCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Red header band
            Text("🥠  Fortune Cookie  🥠")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
                .tracking(2)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Theme.red)

            // Parchment body
            VStack(alignment: .leading, spacing: 20) {
                // Fortune text
                Text("\u{201C}\(fortune.text)\u{201D}")
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .foregroundColor(Theme.inkBlack)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)

                Divider().background(Theme.red.opacity(0.25))

                // Character + Idiom row
                HStack(alignment: .top, spacing: 16) {
                    // Chinese character
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

                    // Idiom
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

                // Lucky numbers
                VStack(spacing: 8) {
                    Text("Lucky Numbers")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Theme.red.opacity(0.65))
                        .tracking(2)
                        .frame(maxWidth: .infinity)

                    HStack(spacing: 8) {
                        ForEach(fortune.luckyNumbers.prefix(5), id: \.self) { n in
                            luckyBubble(n, special: false)
                        }
                        Text("·")
                            .foregroundColor(Theme.inkBlack.opacity(0.3))
                            .font(.title3)
                        if let last = fortune.luckyNumbers.last {
                            luckyBubble(last, special: true)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(20)
            .background(Theme.paper)

            // Red footer band
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

    private func luckyBubble(_ n: Int, special: Bool) -> some View {
        Text("\(n)")
            .font(.system(size: 13, weight: .bold, design: .monospaced))
            .foregroundColor(special ? .white : Theme.inkBlack)
            .frame(width: 33, height: 33)
            .background(Circle().fill(special ? Theme.red : Theme.gold.opacity(0.28)))
    }

    // MARK: - Action Bar

    private var actionBar: some View {
        HStack(spacing: 14) {
            Button {
                store.toggleSave(fortune)
                isSaved.toggle()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                Label(isSaved ? "Saved" : "Save", systemImage: isSaved ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isSaved ? Theme.gold : Theme.paper.opacity(0.8))
                    .padding(.horizontal, 22)
                    .padding(.vertical, 13)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSaved ? Theme.gold.opacity(0.18) : Color.white.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(
                                        isSaved ? Theme.gold.opacity(0.55) : Color.white.opacity(0.15),
                                        lineWidth: 1
                                    )
                            )
                    )
            }

            Button { dismiss() } label: {
                Label("Draw Again", systemImage: "arrow.clockwise")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.inkBlack)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 13)
                    .background(
                        LinearGradient(colors: [Theme.lightGold, Theme.gold], startPoint: .top, endPoint: .bottom)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Theme.gold.opacity(0.35), radius: 8, y: 3)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }

    // MARK: - Animations

    private func startBreak() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        withAnimation(.linear(duration: 0.07).repeatCount(7, autoreverses: true)) {
            shakeAngle = 14
        }

        Task {
            try? await Task.sleep(for: .milliseconds(550))
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            withAnimation(.easeInOut(duration: 0.15)) {
                breakState = .broken
            }
        }
    }

    private func animateReveal() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            leftOffset   = CGSize(width: -88, height: -25)
            rightOffset  = CGSize(width:  88, height: -25)
            leftRotation  = -42
            rightRotation =  42
        }
        withAnimation(.easeOut(duration: 0.55).delay(0.45)) {
            piecesOpacity = 0
        }
        withAnimation(.spring(response: 0.55, dampingFraction: 0.72).delay(0.25)) {
            cardOffset  = 0
            cardOpacity = 1
        }
    }
}

#Preview {
    NavigationStack {
        CookieRevealView(fortune: Fortune(template: FortuneData.templates[0]))
            .environmentObject(FortuneStore())
    }
}
