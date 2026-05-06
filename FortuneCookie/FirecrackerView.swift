import SwiftUI

// MARK: - Particle data

private struct Spark {
    let x: CGFloat
    let y: CGFloat
    let vx: CGFloat
    let vy: CGFloat
    let color: Color
    let size: CGFloat
    let lifetime: Double
    let isRound: Bool  // circle vs capsule
}

// MARK: - Firecracker overlay

/// Full-screen particle-burst overlay. Set `isActive` to `true` to trigger;
/// the view resets it automatically when the animation completes.
struct FirecrackerView: View {
    @Binding var isActive: Bool

    @State private var sparks: [Spark] = []
    @State private var startTime: Date?

    private let gravity: CGFloat = 420   // px / s²
    private let duration: Double = 1.8

    private let palette: [Color] = [
        Theme.red,
        Theme.gold,
        Theme.lightGold,
        Color.orange,
        Color(red: 1.0, green: 0.5, blue: 0.0),
        Color(red: 1.0, green: 0.88, blue: 0.35),
        .white,
        Color(red: 1.0, green: 0.30, blue: 0.15),
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let start = startTime {
                    TimelineView(.animation(minimumInterval: 1.0 / 60)) { tl in
                        Canvas { ctx, _ in
                            let t = CGFloat(tl.date.timeIntervalSince(start))
                            guard t < CGFloat(duration) else { return }
                            for s in sparks {
                                let x = s.x + s.vx * t
                                let y = s.y + s.vy * t + 0.5 * gravity * t * t
                                let fade = max(0, 1.0 - Double(t) / s.lifetime)
                                guard fade > 0 else { continue }
                                var copy = ctx
                                copy.opacity = fade
                                if s.isRound {
                                    let r = CGRect(x: x - s.size / 2, y: y - s.size / 2,
                                                   width: s.size, height: s.size)
                                    copy.fill(Path(ellipseIn: r), with: .color(s.color))
                                } else {
                                    let r = CGRect(x: x - s.size * 0.35, y: y - s.size,
                                                   width: s.size * 0.7, height: s.size * 2.4)
                                    copy.fill(Path(roundedRect: r, cornerRadius: s.size * 0.35),
                                              with: .color(s.color))
                                }
                            }
                        }
                    }
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                }
            }
            .onChange(of: isActive) { _, fired in
                if fired { launch(in: geo.size) }
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Launch

    private func launch(in size: CGSize) {
        let w = size.width  > 0 ? size.width  : 390
        let h = size.height > 0 ? size.height : 844

        // Five burst centers spread across the screen
        let centers: [CGPoint] = [
            CGPoint(x: w * 0.18, y: h * 0.28),
            CGPoint(x: w * 0.82, y: h * 0.22),
            CGPoint(x: w * 0.50, y: h * 0.38),
            CGPoint(x: w * 0.12, y: h * 0.58),
            CGPoint(x: w * 0.88, y: h * 0.52),
        ]

        var newSparks: [Spark] = []
        for center in centers {
            let count = Int.random(in: 14...18)
            for _ in 0..<count {
                let angle  = Double.random(in: 0..<360) * .pi / 180
                let speed  = Double.random(in: 90...240)
                let upBias = Double.random(in: 80...160)   // net upward push
                newSparks.append(Spark(
                    x:        center.x,
                    y:        center.y,
                    vx:       CGFloat(cos(angle) * speed),
                    vy:       CGFloat(sin(angle) * speed) - CGFloat(upBias),
                    color:    palette.randomElement()!,
                    size:     CGFloat.random(in: 3.5...7),
                    lifetime: Double.random(in: 0.9...Double(duration)),
                    isRound:  Bool.random()
                ))
            }
        }

        sparks    = newSparks
        startTime = Date()

        Task {
            try? await Task.sleep(for: .milliseconds(Int(duration * 1000) + 200))
            sparks    = []
            startTime = nil
            isActive  = false
        }
    }
}

// MARK: - XP gain toast

struct XPToast: View {
    let rank: FortuneRank
    let xpEarned: Int
    let didLevelUp: Bool
    let newLevel: Int

    @State private var offsetY: CGFloat = -90
    @State private var opacity: Double  = 0

    var body: some View {
        VStack(spacing: 0) {
            if didLevelUp {
                HStack(spacing: 6) {
                    Text("🎉")
                    Text("LEVEL UP!  →  Lv.\(newLevel) \(LevelInfo.chineseName(newLevel))")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(Theme.lightGold)
                    Text("🎉")
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .padding(.bottom, 4)
            }

            HStack(spacing: 10) {
                Text(rank.emoji)
                    .font(.system(size: 20))
                VStack(alignment: .leading, spacing: 1) {
                    Text(rank.chinese)
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(rank.color)
                    Text(rank.title)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                Text("+\(xpEarned) XP")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(Theme.gold)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, didLevelUp ? 8 : 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.black.opacity(0.88))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(rank.color.opacity(0.7), lineWidth: 1.5)
                )
        )
        .shadow(color: rank.color.opacity(0.4), radius: 12, y: 4)
        .offset(y: offsetY)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.68)) {
                offsetY = 0
                opacity = 1
            }
            Task {
                try? await Task.sleep(for: .milliseconds(3000))
                withAnimation(.easeIn(duration: 0.35)) {
                    offsetY = -90
                    opacity  = 0
                }
            }
        }
    }
}
