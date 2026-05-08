# 🥠 Fortune Cookie

A SwiftUI iOS app that combines the tradition of Chinese fortune cookies with a living Fengshui almanac and an AI-powered daily briefing.

---

## Features

### 🥠 Draw Fortune Cookies
- Pull a fortune cookie from a jar in a Chinese-American restaurant setting
- Tap to break the cookie open with a shake-and-crack animation
- Each fortune includes:
  - A personalised fortune message
  - A Chinese character with its meaning
  - A 成语 (chéngyǔ) idiom with pinyin and English translation
  - Six lucky numbers
- **24 draws per day**, resetting at midnight — no repeated fortunes in a single day

### ⭐ XP & Rank System
- Every draw earns XP based on the fortune's rank (inspired by Japanese omikuji):

| Rank | Chinese | Stars | XP |
|------|---------|-------|----|
| Daikichi | 大吉 | ★★★★★ | 25 |
| Chukichi | 中吉 | ★★★★ | 20 |
| Shokichi | 小吉 | ★★★ | 15 |
| Kichi | 吉 | ★★★ | 12 |
| Suekichi | 末吉 | ★★ | 10 |
| Kyo | 凶 | ★ | 8 |
| Daikyo | 大凶 | ✦ | 5 |

- 100 XP advances to the next level (10 named levels: 初学 → 传奇)
- Firecracker particle animation on every reveal
- XP toast slides in showing rank, points earned, and level-up notifications
- Progress bar visible in the Draw tab header

### 📜 Today's Cookies
- Browse all fortune cookies opened today in a scrollable grid
- Each tile shows the rank colour accent, Chinese character, XP earned, and fortune preview
- Tap any tile to open the full detail sheet with save/unsave

### 🗓 Chinese Almanac (黄历)
Nostalgic aged-paper woodblock aesthetic showing today's traditional Chinese calendar data, calculated entirely on-device:

- Lunar date, year, and zodiac
- 干支 (Ganzhi) pillars — year, month, day
- 纳音五行 (Five Elements / Nayin)
- 建除十二神 (Day Officer)
- 宜 / 忌 (Auspicious & Inauspicious activities)
- 财神 / 喜神 / 福神 directions with compass rose
- 冲煞 (Clash & Sha) information
- Solar term banner when applicable

All data is computed locally using `Calendar(identifier: .chinese)` and the `ChineseCalendarEngine`. A live API enhancement via [mxnzp.com](https://www.mxnzp.com) is available but currently disabled (see `FengshuiService.swift`).

### 🌅 AI Daily Briefing
An agentic morning briefing powered by the **Gemini 2.5 Pro** API:

1. **Fengshui data** — gathered locally from `ChineseCalendarEngine`
2. **Calendar events** — fetched from EventKit (requires calendar permission)
3. **User profile** — name, Chinese zodiac, and personal goals from your profile
4. **Live web context** — Gemini searches the web via Google Search grounding

The briefing is synthesised into four cards:
- 🌟 **Fengshui Snapshot** — today's energy, element, and day quality
- 📅 **Calendar Alignment** — each event interpreted through today's Fengshui
- 🌐 **World Context** — relevant current news and events
- 🥠 **Your Personal Fortune** — actionable advice aligned to your goals and zodiac

### 👤 Profile
Editable at any time via the person icon in the Briefing tab:
- Name
- Chinese zodiac animal (picker)
- Goals & intentions (add/remove list)
- Calendar access toggle

---

## Setup

### Requirements
- Xcode 26.4+
- iOS 26.4+ deployment target
- Swift 6

### API Key

The Daily Briefing feature requires a free Gemini API key:

1. Get a key at [aistudio.google.com/apikey](https://aistudio.google.com/apikey)
2. Create `FortuneCookie/Config.plist` in the project (it is gitignored — never committed):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>GeminiAPIKey</key>
    <string>YOUR_KEY_HERE</string>
</dict>
</plist>
```

3. Build and run — no other configuration needed.

### Calendar Permission
Grant calendar access from the **Profile** sheet (person icon in the Briefing tab) before generating your first briefing. The app will never prompt for permission mid-generation.

---

## Project Structure

```
FortuneCookie/
├── Fortune.swift              # Fortune data model + Codable
├── FortuneData.swift          # 30 unique fortune templates
├── FortuneStore.swift         # State management, XP, persistence
├── FortuneRank.swift          # 7-rank enum + LevelInfo (10 levels)
│
├── DrawView.swift             # Cookie jar draw screen + XP progress bar
├── CookieRevealView.swift     # Break animation + fortune card reveal
├── HistoryView.swift          # Today's cookie grid + detail sheet
├── FirecrackerView.swift      # Particle system (Canvas) + XP toast
│
├── AlmanacData.swift          # DailyAlmanac model + ChineseCalendarEngine
├── AlmanacView.swift          # 黄历 UI — aged paper, compass rose, cards
├── FengshuiService.swift      # Local calculation + optional mxnzp.com API
│
├── DailyBriefingModels.swift  # Gemini API Codable structs
├── DailyBriefingTools.swift   # EventKit, Fengshui, UserProfile tool impls
├── DailyBriefingAgent.swift   # Two-phase agent: local tools + grounded API call
├── DailyBriefingViewModel.swift # ObservableObject, state machine, section parser
├── DailyBriefingView.swift    # Briefing UI — idle/loading/loaded/error states
├── ProfileView.swift          # User profile editor
│
├── ContentView.swift          # TabView root + Theme constants
├── Config.plist               # ← gitignored, create locally with your API key
└── Assets.xcassets
```

---

## Architecture Notes

- **No third-party dependencies** — URLSession, EventKit, and SwiftUI only
- **`PBXFileSystemSynchronizedRootGroup`** — all files in `FortuneCookie/` are auto-included; no `.pbxproj` edits needed when adding Swift files
- **`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`** — all types are implicitly `@MainActor`; avoid adding explicit `@MainActor` annotations to `ObservableObject` subclasses
- **Gemini two-phase approach** — local tools (Fengshui, calendar, profile) are gathered in Swift without an API call, then passed as context to a single Gemini request with `google_search` grounding. This avoids Gemini's restriction on mixing `function_declarations` with `google_search` in the same request.
- **Chinese calendar** — lunar date uses `Calendar(identifier: .chinese)`; day ganzhi uses anchor-date arithmetic (2000-01-07 = 甲子, index 0)
- **Offline-first** — the almanac and all fortune logic work fully offline; the Gemini API is only needed for the Daily Briefing

---

## License

MIT
