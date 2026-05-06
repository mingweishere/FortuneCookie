import Foundation

enum FortuneData {
    static let templates: [FortuneTemplate] = [
        FortuneTemplate(
            text: "A pleasant surprise awaits you just around the corner.",
            character: "喜", characterMeaning: "Joy & Happiness",
            idiom: "喜出望外", idiomPinyin: "xǐ chū wàng wài",
            idiomMeaning: "Pleasantly surprised beyond all expectations"
        ),
        FortuneTemplate(
            text: "Your patience and perseverance will be richly rewarded.",
            character: "忍", characterMeaning: "Patience",
            idiom: "磨杵成针", idiomPinyin: "mó chǔ chéng zhēn",
            idiomMeaning: "Grinding a pestle into a needle — persistence conquers all"
        ),
        FortuneTemplate(
            text: "The greatest risk is not taking one. Seize today's opportunity.",
            character: "勇", characterMeaning: "Courage",
            idiom: "破釜沉舟", idiomPinyin: "pò fǔ chén zhōu",
            idiomMeaning: "Burn the boats — commit fully with no turning back"
        ),
        FortuneTemplate(
            text: "Kindness offered freely returns multiplied a thousandfold.",
            character: "善", characterMeaning: "Kindness",
            idiom: "好事多磨", idiomPinyin: "hǎo shì duō mó",
            idiomMeaning: "Good things come after much effort and patience"
        ),
        FortuneTemplate(
            text: "A journey of a thousand miles begins beneath your very feet.",
            character: "行", characterMeaning: "Journey",
            idiom: "千里之行始于足下", idiomPinyin: "qiān lǐ zhī xíng shǐ yú zú xià",
            idiomMeaning: "Every great journey begins with a single step"
        ),
        FortuneTemplate(
            text: "Wisdom whispers to those who know how to listen.",
            character: "慧", characterMeaning: "Wisdom",
            idiom: "大智若愚", idiomPinyin: "dà zhì ruò yú",
            idiomMeaning: "True wisdom appears as simplicity"
        ),
        FortuneTemplate(
            text: "Prosperity grows where harmony and hard work meet.",
            character: "福", characterMeaning: "Fortune & Prosperity",
            idiom: "一帆风顺", idiomPinyin: "yī fān fēng shùn",
            idiomMeaning: "Smooth sailing all the way — great success ahead"
        ),
        FortuneTemplate(
            text: "A true friend is a treasure more valuable than gold.",
            character: "友", characterMeaning: "Friendship",
            idiom: "莫逆之交", idiomPinyin: "mò nì zhī jiāo",
            idiomMeaning: "Friends who never clash — kindred spirits"
        ),
        FortuneTemplate(
            text: "Change is the only constant. Embrace what is yet to come.",
            character: "变", characterMeaning: "Change & Transformation",
            idiom: "因势利导", idiomPinyin: "yīn shì lì dǎo",
            idiomMeaning: "Go with the current and turn it to your advantage"
        ),
        FortuneTemplate(
            text: "Love given freely from the heart always finds its way home.",
            character: "爱", characterMeaning: "Love",
            idiom: "两情相悦", idiomPinyin: "liǎng qíng xiāng yuè",
            idiomMeaning: "Two hearts in perfect harmony"
        ),
        FortuneTemplate(
            text: "Your creativity is the compass that guides your destiny.",
            character: "创", characterMeaning: "Creation",
            idiom: "别具一格", idiomPinyin: "bié jù yī gé",
            idiomMeaning: "Uniquely distinctive — in a class of its own"
        ),
        FortuneTemplate(
            text: "Success is not a destination but a continuous journey of growth.",
            character: "进", characterMeaning: "Progress",
            idiom: "精益求精", idiomPinyin: "jīng yì qiú jīng",
            idiomMeaning: "Always striving for excellence beyond excellence"
        ),
        FortuneTemplate(
            text: "Still waters run deep — your quiet strength is your greatest gift.",
            character: "静", characterMeaning: "Stillness",
            idiom: "宁静致远", idiomPinyin: "níng jìng zhì yuǎn",
            idiomMeaning: "Tranquility leads to far-reaching achievement"
        ),
        FortuneTemplate(
            text: "The door you have been afraid to open holds your greatest reward.",
            character: "开", characterMeaning: "Opening",
            idiom: "柳暗花明", idiomPinyin: "liǔ àn huā míng",
            idiomMeaning: "After dark willows, bright flowers — light follows darkness"
        ),
        FortuneTemplate(
            text: "Every setback plants the seed of an equal or greater opportunity.",
            character: "韧", characterMeaning: "Resilience",
            idiom: "塞翁失马", idiomPinyin: "sài wēng shī mǎ",
            idiomMeaning: "A seeming loss may disguise a hidden blessing"
        ),
        FortuneTemplate(
            text: "Your generosity today weaves the tapestry of tomorrow's abundance.",
            character: "慷", characterMeaning: "Generosity",
            idiom: "乐善好施", idiomPinyin: "lè shàn hào shī",
            idiomMeaning: "Joyfully doing good and giving freely to others"
        ),
        FortuneTemplate(
            text: "Trust the timing of your life — everything unfolds as it should.",
            character: "时", characterMeaning: "Time & Timing",
            idiom: "顺其自然", idiomPinyin: "shùn qí zì rán",
            idiomMeaning: "Let things take their natural course"
        ),
        FortuneTemplate(
            text: "Your health is the foundation upon which all dreams are built.",
            character: "健", characterMeaning: "Health",
            idiom: "身体力行", idiomPinyin: "shēn tǐ lì xíng",
            idiomMeaning: "Practice what you preach with your whole being"
        ),
        FortuneTemplate(
            text: "New connections made today may lead to extraordinary horizons.",
            character: "缘", characterMeaning: "Fate & Connection",
            idiom: "有缘千里来相会", idiomPinyin: "yǒu yuán qiān lǐ lái xiāng huì",
            idiomMeaning: "Fate brings kindred souls together across great distances"
        ),
        FortuneTemplate(
            text: "Look within — the answer you seek has always lived inside you.",
            character: "悟", characterMeaning: "Enlightenment",
            idiom: "醍醐灌顶", idiomPinyin: "tí hú guàn dǐng",
            idiomMeaning: "A moment of sudden clarity that illuminates the mind"
        ),
        FortuneTemplate(
            text: "The best project you will ever work on is the one called You.",
            character: "己", characterMeaning: "Self",
            idiom: "修身齐家", idiomPinyin: "xiū shēn qí jiā",
            idiomMeaning: "Cultivate yourself first to harmonize those around you"
        ),
        FortuneTemplate(
            text: "Beauty surrounds you — today, make time to truly notice it.",
            character: "美", characterMeaning: "Beauty",
            idiom: "良辰美景", idiomPinyin: "liáng chén měi jǐng",
            idiomMeaning: "A glorious moment amid beautiful surroundings"
        ),
        FortuneTemplate(
            text: "A well-timed word can change the entire arc of a life.",
            character: "言", characterMeaning: "Words & Speech",
            idiom: "一言九鼎", idiomPinyin: "yī yán jiǔ dǐng",
            idiomMeaning: "One word carries the weight of nine cauldrons — words have power"
        ),
        FortuneTemplate(
            text: "Fortune favors the prepared mind and the courageous heart.",
            character: "备", characterMeaning: "Preparation",
            idiom: "有备无患", idiomPinyin: "yǒu bèi wú huàn",
            idiomMeaning: "Preparedness ensures freedom from worry"
        ),
        FortuneTemplate(
            text: "Your next chapter is more exciting than any you have yet read.",
            character: "新", characterMeaning: "New Beginnings",
            idiom: "万象更新", idiomPinyin: "wàn xiàng gēng xīn",
            idiomMeaning: "All things renew themselves — everything is made fresh"
        ),
        FortuneTemplate(
            text: "Let your dreams be bigger than your fears and your actions louder than your words.",
            character: "志", characterMeaning: "Ambition",
            idiom: "有志者事竟成", idiomPinyin: "yǒu zhì zhě shì jìng chéng",
            idiomMeaning: "Where there is will, there is always a way"
        ),
        FortuneTemplate(
            text: "The harvest you reap tomorrow is planted in the choices of today.",
            character: "耕", characterMeaning: "Cultivation",
            idiom: "耕耘收获", idiomPinyin: "gēng yún shōu huò",
            idiomMeaning: "Those who plow and sow shall harvest"
        ),
        FortuneTemplate(
            text: "Laughter is the shortest distance between two hearts.",
            character: "乐", characterMeaning: "Joy & Laughter",
            idiom: "苦尽甘来", idiomPinyin: "kǔ jìn gān lái",
            idiomMeaning: "After bitterness comes sweetness — joy follows hardship"
        ),
        FortuneTemplate(
            text: "Mountains yield to those who persist with both strength and grace.",
            character: "毅", characterMeaning: "Perseverance",
            idiom: "锲而不舍", idiomPinyin: "qiè ér bù shě",
            idiomMeaning: "Keep chiseling and never give up — persistent effort succeeds"
        ),
        FortuneTemplate(
            text: "The universe conspires in your favor today — dare to believe it.",
            character: "运", characterMeaning: "Fate & Fortune",
            idiom: "天道酬勤", idiomPinyin: "tiān dào chóu qín",
            idiomMeaning: "Heaven rewards the diligent — the cosmos honors hard work"
        ),
    ]
}
