import SwiftUI

struct ContentView: View {
    @StateObject private var store = FortuneStore()

    var body: some View {
        TabView {
            DrawView()
                .tabItem {
                    Label("Draw", systemImage: "hand.draw.fill")
                }
            HistoryView()
                .tabItem {
                    Label("Today", systemImage: "scroll.fill")
                }
            AlmanacView()
                .tabItem {
                    Label("黄历", systemImage: "calendar")
                }
        }
        .environmentObject(store)
        .tint(Theme.gold)
    }
}

// MARK: - Theme

enum Theme {
    static let red       = Color(red: 0.70, green: 0.04, blue: 0.04)
    static let darkRed   = Color(red: 0.45, green: 0.02, blue: 0.02)
    static let gold      = Color(red: 0.94, green: 0.76, blue: 0.18)
    static let lightGold = Color(red: 1.00, green: 0.92, blue: 0.55)
    static let paper     = Color(red: 0.99, green: 0.97, blue: 0.90)
    static let inkBlack  = Color(red: 0.10, green: 0.06, blue: 0.03)
}

#Preview {
    ContentView()
}
