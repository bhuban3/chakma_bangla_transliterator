# চাকমা ↔ বাংলা লিপি রূপান্তর
### Chakma ↔ Bengali Script Transliterator — Flutter Android App

A script-level transliterator that converts text between Chakma (𑄌𑄦𑄟) and Bengali (বাংলা) scripts.
Phonetic content is preserved — only the writing system changes.

---

## Project Structure

```
chakma_bengali_transliterator/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── theme/
│   │   └── app_theme.dart                 # Colors, fonts, Material3 theme
│   ├── screens/
│   │   └── translator_screen.dart         # Main UI screen
│   ├── services/
│   │   └── transliteration_service.dart   # Core mapping engine (singleton)
│   └── widgets/
│       ├── language_selector.dart         # Animated direction switcher
│       ├── text_input_card.dart           # Input text area
│       ├── output_card.dart               # Output display + copy
│       └── example_chips.dart             # Tap-to-fill examples
├── assets/
│   ├── data/
│   │   ├── syllabary_Bengali.json         # Bengali vowels, consonants, compounds
│   │   ├── syllabary_Chakma.json          # Chakma vowels, consonants, compounds
│   │   ├── conjuncts_Bengali_[a, ā, i, ī, u, ū, ṛ, e, ĕ, ai, o, ŏ, au, aṃ, aḥ].json
│   │   ├── conjuncts_Chakma_[a, ā, i, ī, u, ū, ṛ, e, ĕ, ai, o, ŏ, au, aṃ, aḥ].json
│   └── fonts/
│       ├── NotoSansChakma-Regular.ttf     # ← YOU MUST ADD THIS 
│       ├── NotoSansBengali-Regular.ttf    # ← YOU MUST ADD THIS
│       └── NotoSansBengali-Bold.ttf       # ← YOU MUST ADD THIS
├── android/
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       └── res/values/
│   │           ├── styles.xml
│   │           └── colors.xml
│   ├── build.gradle
│   ├── settings.gradle
│   └── gradle.properties
└── pubspec.yaml
```

---

## Setup Instructions

### Step 1 — Install Flutter
Download Flutter SDK from https://flutter.dev/docs/get-started/install
Minimum version: Flutter 3.16+ / Dart 3.0+

### Step 2 — Download Required Fonts

You need 3 font files. Download from Google Fonts (free, OFL license):

**Noto Sans Chakma:**
https://fonts.google.com/noto/specimen/Noto+Sans+Chakma
→ Download → extract → copy `NotoSansChakma-Regular.ttf`
→ Place at: `assets/fonts/NotoSansChakma-Regular.ttf`

**Noto Sans Bengali:**
https://fonts.google.com/noto/specimen/Noto+Sans+Bengali
→ Download → extract → copy:
- `NotoSansBengali-Regular.ttf`
- `NotoSansBengali-Bold.ttf`
  → Place both at: `assets/fonts/`

### Step 3 — Install Dependencies

```bash
cd chakma_bengali_transliterator
flutter pub get
```

### Step 4 — Run or Build

**Run on connected device / emulator:**
```bash
flutter run
```

**Build release APK:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Build App Bundle (for Play Store):**
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## How the Transliteration Engine Works

The `TransliterationService` loads all syllabary and conjunct JSON files at startup and builds a flat
`Map<String, String>` by zipping parallel arrays by index:

```
Bengali  vowels[i]    ↔  Chakma  vowels[i]
Bengali  consonants[i] ↔  Chakma  consonants[i]
Bengali  compounds[i]  ↔  Chakma  compounds[i]
Bengali  conjuncts*[i] ↔  Chakma  conjuncts*[i]
```

Entries starting with `&` (variant/alternate forms) are stripped of the prefix
before being added to the map.

At query time, the engine uses **greedy longest-match** scanning:
- Entries are sorted by Unicode code-point length (longest key first)
- The input string is scanned left-to-right
- At each position, the longest matching key is found and replaced
- Unmapped characters (spaces, digits, punctuation) pass through unchanged

The reverse map (Chakma → Bengali) is the same map with keys and values swapped,
sorted longest-first by the Chakma key.

**Total mappings loaded:** ~700–900 entries across vowels, consonants,
compounds, and 1–5-component conjuncts.

---

## App Features

| Feature | Details |
|---|---|
| Bidirectional | Bengali → Chakma and Chakma → Bengali |
| Swap with animation | One tap swaps direction, output becomes new input |
| Real-time | Converts as you type |
| Copy output | Copies result to clipboard with haptic feedback |
| Example chips | 5 tappable examples per direction |
| Character count | Live count for both input and output |
| Share intent | App can receive shared text from other apps |
| Font bundled | Noto Sans Chakma & Bengali rendered natively |
| No internet | Works fully offline |

---

## Minimum Requirements

| Requirement | Value |
|---|---|
| Android minSdkVersion | 21 (Android 5.0 Lollipop) |
| Flutter SDK | 3.16+ |
| Dart SDK | 3.0+ |
