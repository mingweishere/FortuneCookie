import SwiftUI

struct ProfileView: View {
    @State private var profile = UserProfile.load()
    @State private var newGoal = ""
    @Environment(\.dismiss) private var dismiss

    private let zodiacs = [
        "🐭 鼠 Rat",   "🐂 牛 Ox",      "🐯 虎 Tiger",   "🐰 兔 Rabbit",
        "🐉 龙 Dragon", "🐍 蛇 Snake",   "🐴 马 Horse",   "🐑 羊 Goat",
        "🐵 猴 Monkey", "🐔 鸡 Rooster", "🐶 狗 Dog",     "🐷 猪 Pig",
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Theme.darkRed, Theme.red.opacity(0.85)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        nameSection
                        zodiacSection
                        goalsSection
                        saveButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("My Profile")
                        .font(.system(size: 18, weight: .bold, design: .serif))
                        .foregroundColor(Theme.gold)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Theme.gold)
                            .fontWeight(.semibold)
                    }
                }
            }
            .toolbarBackground(Theme.darkRed, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Sections

    private var nameSection: some View {
        profileField("Your Name") {
            TextField("Enter your name", text: $profile.name)
                .textFieldStyle(.plain)
                .font(.system(size: 15, design: .serif))
                .foregroundColor(Theme.inkBlack)
                .padding(12)
                .background(Theme.paper)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var zodiacSection: some View {
        profileField("Chinese Zodiac") {
            Menu {
                Button("(None)", action: { profile.chineseZodiac = "" })
                ForEach(zodiacs, id: \.self) { z in
                    Button(z) { profile.chineseZodiac = z }
                }
            } label: {
                HStack {
                    Text(profile.chineseZodiac.isEmpty ? "Select your zodiac animal…" : profile.chineseZodiac)
                        .font(.system(size: 15, design: .serif))
                        .foregroundColor(profile.chineseZodiac.isEmpty ? Theme.inkBlack.opacity(0.4) : Theme.inkBlack)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.inkBlack.opacity(0.5))
                }
                .padding(12)
                .background(Theme.paper)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private var goalsSection: some View {
        profileField("Goals & Intentions") {
            VStack(spacing: 8) {
                ForEach(profile.goals.indices, id: \.self) { i in
                    HStack(spacing: 10) {
                        Text("•")
                            .foregroundColor(Theme.red)
                        Text(profile.goals[i])
                            .font(.system(size: 14, design: .serif))
                            .foregroundColor(Theme.inkBlack)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Button {
                            profile.goals.remove(at: i)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Theme.red.opacity(0.55))
                                .font(.system(size: 16))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(Theme.paper)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                HStack(spacing: 8) {
                    TextField("Add a goal or intention…", text: $newGoal)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14, design: .serif))
                        .foregroundColor(Theme.inkBlack)
                        .padding(10)
                        .background(Theme.paper)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onSubmit { appendGoal() }

                    Button(action: appendGoal) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(Theme.gold)
                    }
                }
            }
        }
    }

    private var saveButton: some View {
        Button {
            profile.save()
            dismiss()
        } label: {
            Text("Save Profile")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Theme.inkBlack)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(colors: [Theme.lightGold, Theme.gold],
                                   startPoint: .top, endPoint: .bottom)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: Theme.gold.opacity(0.4), radius: 8, y: 3)
        }
        .padding(.top, 6)
    }

    // MARK: - Helpers

    private func appendGoal() {
        let trimmed = newGoal.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        profile.goals.append(trimmed)
        newGoal = ""
    }

    private func profileField<C: View>(_ label: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Theme.lightGold.opacity(0.65))
                .tracking(1.8)
                .padding(.leading, 2)
            content()
        }
    }
}

#Preview {
    ProfileView()
}
