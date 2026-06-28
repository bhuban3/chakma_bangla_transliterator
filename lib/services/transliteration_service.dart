// import 'dart:convert';
// import 'package:flutter/services.dart';
//
// /// Represents the direction of transliteration
// enum TransliterationDirection { bengaliToChakma, chakmaToBengali }
//
// class TransliterationService {
//   // Singleton
//   static final TransliterationService _instance = TransliterationService._internal();
//   factory TransliterationService() => _instance;
//   TransliterationService._internal();
//
//   bool _isInitialized = false;
//
//   // Ordered maps (longest-key-first for greedy matching)
//   final List<MapEntry<String, String>> _bengaliToChakma = [];
//   final List<MapEntry<String, String>> _chakmaToBengali = [];
//
//   // ── ADD YOUR NEW FILE PAIRS HERE (Bengali file, Chakma file) ─────────────
//   // Just keep adding more pairs as you get them. Order doesn't matter.
//   static const List<(String, String)> _conjunctFilePairs = [
//     ('assets/data/conjuncts_Bengali_a.json', 'assets/data/conjuncts_Chakma_a.json'),
//     ('assets/data/conjuncts_Bengali_ai.json', 'assets/data/conjuncts_Chakma_ai.json'),
//     ('assets/data/conjuncts_Bengali_au.json', 'assets/data/conjuncts_Chakma_au.json'),
//     ('assets/data/conjuncts_Bengali_aḥ.json', 'assets/data/conjuncts_Chakma_aḥ.json'),
//     ('assets/data/conjuncts_Bengali_aṃ.json', 'assets/data/conjuncts_Chakma_aṃ.json'),
//     ('assets/data/conjuncts_Bengali_e.json', 'assets/data/conjuncts_Chakma_e.json'),
//     ('assets/data/conjuncts_Bengali_o.json', 'assets/data/conjuncts_Chakma_o.json'),
//     ('assets/data/conjuncts_Bengali_u.json', 'assets/data/conjuncts_Chakma_u.json'),
//     ('assets/data/conjuncts_Bengali_i.json', 'assets/data/conjuncts_Chakma_i.json'),
//     ('assets/data/conjuncts_Bengali_ā.json', 'assets/data/conjuncts_Chakma_ā.json'),
//     ('assets/data/conjuncts_Bengali_ĕ.json', 'assets/data/conjuncts_Chakma_ĕ.json'),
//     ('assets/data/conjuncts_Bengali_ṛ.json', 'assets/data/conjuncts_Chakma_ṛ.json'),
//     ('assets/data/conjuncts_Bengali_ī.json', 'assets/data/conjuncts_Chakma_ī.json'),
//     ('assets/data/conjuncts_Bengali_ū.json', 'assets/data/conjuncts_Chakma_ū.json'),
//     ('assets/data/conjuncts_Bengali_ŏ.json', 'assets/data/conjuncts_Chakma_ŏ.json'),
//   ];
//
//   // Categories present in every conjunct file
//   static const List<String> _conjunctCategories = [
//     'conjuncts1S1',
//     'conjuncts2S1',
//     'conjuncts3S1',
//     'conjuncts4S1',
//     'conjuncts5S1',
//   ];
//
//   Future<void> initialize() async {
//     if (_isInitialized) return;
//
//     final syllBn = await _loadJson('assets/data/syllabary_Bengali.json');
//     final syllCk = await _loadJson('assets/data/syllabary_Chakma.json');
//
//     // Build raw map: Bengali → Chakma
//     final Map<String, String> rawMap = {};
//
//     // 1. Vowels
//     _addParallelLists(rawMap, _asList(syllBn['vowels']), _asList(syllCk['vowels']));
//
//     // 2. Consonants
//     _addParallelLists(rawMap, _asList(syllBn['consonants']), _asList(syllCk['consonants']));
//
//     // 3. Compounds
//     _addParallelLists(rawMap, _asList(syllBn['compounds']), _asList(syllCk['compounds']));
//
//     // 4. All conjunct file pairs — loaded in parallel for speed
//     final conjunctResults = await Future.wait(
//       _conjunctFilePairs.map((pair) => _loadConjunctPair(pair.$1, pair.$2)),
//     );
//     for (final pairMap in conjunctResults) {
//       rawMap.addAll(pairMap);
//     }
//
//     // Strip & prefix (variant marker) then deduplicate
//     final Map<String, String> cleaned = {};
//     rawMap.forEach((k, v) {
//       final cleanK = k.startsWith('&') ? k.substring(1) : k;
//       final cleanV = v.startsWith('&') ? v.substring(1) : v;
//       if (cleanK.isNotEmpty && cleanV.isNotEmpty) {
//         cleaned[cleanK] = cleanV;
//       }
//     });
//
//     // Sort by key length descending (greedy longest-match)
//     final sortedEntries = cleaned.entries.toList()
//       ..sort((a, b) => b.key.length.compareTo(a.key.length));
//
//     _bengaliToChakma
//       ..clear()
//       ..addAll(sortedEntries);
//
//     // Reverse map: Chakma → Bengali
//     final Map<String, String> reverseMap = {};
//     for (final e in sortedEntries) {
//       reverseMap[e.value] = e.key;
//     }
//     final reverseSorted = reverseMap.entries.toList()
//       ..sort((a, b) => b.key.length.compareTo(a.key.length));
//
//     _chakmaToBengali
//       ..clear()
//       ..addAll(reverseSorted);
//
//     _isInitialized = true;
//   }
//
//   /// Loads one Bengali+Chakma conjunct file pair and returns their merged map.
//   /// Skips the file silently if it doesn't exist yet (useful during development).
//   Future<Map<String, String>> _loadConjunctPair(
//       String bengaliPath, String chakmaPath) async {
//     final result = <String, String>{};
//     try {
//       final conjBn = await _loadJson(bengaliPath);
//       final conjCk = await _loadJson(chakmaPath);
//       for (final category in _conjunctCategories) {
//         _addParallelLists(
//           result,
//           _asList(conjBn[category]),
//           _asList(conjCk[category]),
//         );
//       }
//     } catch (_) {
//       // File not found or malformed — skip silently
//     }
//     return result;
//   }
//
//   /// Transliterate [input] in the given [direction].
//   String transliterate(String input, TransliterationDirection direction) {
//     if (!_isInitialized || input.isEmpty) return input;
//
//     final table = direction == TransliterationDirection.bengaliToChakma
//         ? _bengaliToChakma
//         : _chakmaToBengali;
//
//     final buffer = StringBuffer();
//     int i = 0;
//
//     // Work on Unicode code points to handle multi-codepoint sequences
//     final runes = input.runes.toList();
//
//     while (i < runes.length) {
//       bool matched = false;
//
//       for (final entry in table) {
//         final keyRunes = entry.key.runes.toList();
//         if (i + keyRunes.length <= runes.length) {
//           bool eq = true;
//           for (int j = 0; j < keyRunes.length; j++) {
//             if (runes[i + j] != keyRunes[j]) {
//               eq = false;
//               break;
//             }
//           }
//           if (eq) {
//             buffer.write(entry.value);
//             i += keyRunes.length;
//             matched = true;
//             break;
//           }
//         }
//       }
//
//       if (!matched) {
//         // Pass through unmapped characters (spaces, punctuation, numbers, etc.)
//         buffer.writeCharCode(runes[i]);
//         i++;
//       }
//     }
//
//     return buffer.toString();
//   }
//
//   // ── Helpers ──────────────────────────────────────────────────────────────
//
//   Future<Map<String, dynamic>> _loadJson(String asset) async {
//     final raw = await rootBundle.loadString(asset);
//     return json.decode(raw) as Map<String, dynamic>;
//   }
//
//   List<String> _asList(dynamic value) {
//     if (value == null) return [];
//     return (value as List).map((e) => e.toString()).toList();
//   }
//
//   void _addParallelLists(
//       Map<String, String> map,
//       List<String> keys,
//       List<String> values,
//       ) {
//     final len = keys.length < values.length ? keys.length : values.length;
//     for (int i = 0; i < len; i++) {
//       final k = keys[i];
//       final v = values[i];
//       if (k.isNotEmpty && v.isNotEmpty) {
//         map[k] = v;
//       }
//     }
//   }
//
//   int get mappingCount => _bengaliToChakma.length;
//   bool get isInitialized => _isInitialized;
// }


import 'dart:convert';
import 'package:flutter/services.dart';

enum TransliterationDirection { bengaliToChakma, chakmaToBengali }

class TransliterationService {
  static final TransliterationService _instance =
  TransliterationService._internal();
  factory TransliterationService() => _instance;
  TransliterationService._internal();

  bool _isInitialized = false;

  final List<MapEntry<String, String>> _bengaliToChakma = [];
  final List<MapEntry<String, String>> _chakmaToBengali = [];

  // ── Add more conjunct pairs here as you receive them
  static const List<(String, String)> _conjunctFilePairs = [
    ('assets/data/conjuncts_Bengali_a.json', 'assets/data/conjuncts_Chakma_a.json'),
    ('assets/data/conjuncts_Bengali_ai.json', 'assets/data/conjuncts_Chakma_ai.json'),
    ('assets/data/conjuncts_Bengali_au.json', 'assets/data/conjuncts_Chakma_au.json'),
    ('assets/data/conjuncts_Bengali_aḥ.json', 'assets/data/conjuncts_Chakma_aḥ.json'),
    ('assets/data/conjuncts_Bengali_aṃ.json', 'assets/data/conjuncts_Chakma_aṃ.json'),
    ('assets/data/conjuncts_Bengali_e.json', 'assets/data/conjuncts_Chakma_e.json'),
    ('assets/data/conjuncts_Bengali_o.json', 'assets/data/conjuncts_Chakma_o.json'),
    ('assets/data/conjuncts_Bengali_u.json', 'assets/data/conjuncts_Chakma_u.json'),
    ('assets/data/conjuncts_Bengali_i.json', 'assets/data/conjuncts_Chakma_i.json'),
    ('assets/data/conjuncts_Bengali_ā.json', 'assets/data/conjuncts_Chakma_ā.json'),
    ('assets/data/conjuncts_Bengali_ĕ.json', 'assets/data/conjuncts_Chakma_ĕ.json'),
    ('assets/data/conjuncts_Bengali_ṛ.json', 'assets/data/conjuncts_Chakma_ṛ.json'),
    ('assets/data/conjuncts_Bengali_ī.json', 'assets/data/conjuncts_Chakma_ī.json'),
    ('assets/data/conjuncts_Bengali_ū.json', 'assets/data/conjuncts_Chakma_ū.json'),
    ('assets/data/conjuncts_Bengali_ŏ.json', 'assets/data/conjuncts_Chakma_ŏ.json'),
  ];

  static const List<String> _conjunctCategories = [
    'conjuncts1S1', 'conjuncts2S1', 'conjuncts3S1',
    'conjuncts4S1', 'conjuncts5S1',
  ];

  Future<void> initialize() async {
    if (_isInitialized) return;

    final syllBn = await _loadJson('assets/data/syllabary_Bengali.json');
    final syllCk = await _loadJson('assets/data/syllabary_Chakma.json');

    final Map<String, String> rawMap = {};

    // 1. Vowels — parallel zip.
    //    NOTE: entries like ' ং' (space + diacritic) are in this list.
    //    We strip the leading space so they match mid-word characters.
    _addParallelListsStripSpace(
      rawMap,
      _asList(syllBn['vowels']),
      _asList(syllCk['vowels']),
    );

    // 2. Consonants — parallel zip (both arrays have 45 entries)
    _addParallelLists(
      rawMap,
      _asList(syllBn['consonants']),
      _asList(syllCk['consonants']),
    );

    // 3. Compounds — parallel zip.
    //    Both arrays are 810 entries (45 consonants × 18 forms), fully aligned.
    _addParallelLists(
      rawMap,
      _asList(syllBn['compounds']),
      _asList(syllCk['compounds']),
    );

    // 4. Conjuncts — loaded in parallel for speed
    final conjResults = await Future.wait(
      _conjunctFilePairs.map((p) => _loadConjunctPair(p.$1, p.$2)),
    );
    for (final m in conjResults) rawMap.addAll(m);

    // 5. Extras: numerals + punctuation
    rawMap.addAll(_extras);

    // Strip & prefix (variant marker), deduplicate
    final Map<String, String> cleaned = {};
    rawMap.forEach((k, v) {
      final cleanK = k.startsWith('&') ? k.substring(1) : k;
      final cleanV = v.startsWith('&') ? v.substring(1) : v;
      if (cleanK.isNotEmpty && cleanV.isNotEmpty) cleaned[cleanK] = cleanV;
    });

    // Sort longest-key-first for greedy matching
    final sorted = cleaned.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));

    _bengaliToChakma..clear()..addAll(sorted);

    // Reverse map: Chakma → Bengali
    final Map<String, String> rev = {};
    for (final e in sorted) rev[e.value] = e.key;
    _chakmaToBengali
      ..clear()
      ..addAll(rev.entries.toList()
        ..sort((a, b) => b.key.length.compareTo(a.key.length)));

    _isInitialized = true;
  }

  // ── Extras ───────────────────────────────────────────────────────────────
  // Standalone diacritics that appear mid-word (not covered by compound entries)
  // and Bengali numerals / punctuation.
  static const Map<String, String> _extras = {
    // Standalone diacritics (mid-word, no consonant prefix)
    'ং': '𑄁',   // anusvara  — e.g. বাংলা → 𑄝𑄁𑄣
    'ঃ': '𑄂',   // visarga
    'ঁ': '𑄀',   // chandrabindu
    '্': '𑄴',   // hasanta / virama

    // Bengali numerals → Chakma numerals
    '০': '𑄶', '১': '𑄷', '২': '𑄸', '৩': '𑄹', '৪': '𑄺',
    '৫': '𑄻', '৬': '𑄼', '৭': '𑄽', '৮': '𑄾', '৯': '𑄿',

    // Punctuation
    '।': '𑅃',
  };

  String transliterate(String input, TransliterationDirection direction) {
    if (!_isInitialized || input.isEmpty) return input;

    final table = direction == TransliterationDirection.bengaliToChakma
        ? _bengaliToChakma
        : _chakmaToBengali;

    final buffer = StringBuffer();
    final runes = input.runes.toList();
    int i = 0;

    while (i < runes.length) {
      bool matched = false;
      for (final entry in table) {
        final keyRunes = entry.key.runes.toList();
        if (i + keyRunes.length <= runes.length) {
          bool eq = true;
          for (int j = 0; j < keyRunes.length; j++) {
            if (runes[i + j] != keyRunes[j]) { eq = false; break; }
          }
          if (eq) {
            buffer.write(entry.value);
            i += keyRunes.length;
            matched = true;
            break;
          }
        }
      }
      if (!matched) {
        buffer.writeCharCode(runes[i]);
        i++;
      }
    }

    String result = buffer.toString();

    if (direction == TransliterationDirection.chakmaToBengali) {
      result = _injectZWNJAfterHashanta(result);
    }
    return result;
  }


  static String _injectZWNJAfterHashanta(String text) {
    const int hasanta = 0x09CD;
    const int zwnj    = 0x200C;
    final runes = text.runes.toList();
    final out   = StringBuffer();
    for (int i = 0; i < runes.length; i++) {
      out.writeCharCode(runes[i]);
      if (runes[i] == hasanta && i + 1 < runes.length) {
        final next = runes[i + 1];
        final isBengaliConsonant =
            (next >= 0x0995 && next <= 0x09B9) ||
                next == 0x09CE ||
                (next >= 0x09DC && next <= 0x09DF);
        if (isBengaliConsonant) out.writeCharCode(zwnj);
      }
    }
    return out.toString();
  }
  // ── Helpers ──────────────────────────────────────────────────────────────

  Future<Map<String, String>> _loadConjunctPair(
      String bnPath, String ckPath) async {
    final result = <String, String>{};
    try {
      final conjBn = await _loadJson(bnPath);
      final conjCk = await _loadJson(ckPath);
      for (final cat in _conjunctCategories) {
        _addParallelLists(result, _asList(conjBn[cat]), _asList(conjCk[cat]));
      }
    } catch (_) { /* file missing — skip */ }
    return result;
  }

  /// Parallel zip, stripping a single leading space from keys.
  /// The syllabary vowel list stores standalone diacritics as ' ং', ' ঃ', ' ঁ'
  /// (with a space prefix to distinguish them visually in the JSON).
  /// We strip that space so they match bare diacritics in real text.
  void _addParallelListsStripSpace(
      Map<String, String> map,
      List<String> keys,
      List<String> values,
      ) {
    final len = keys.length < values.length ? keys.length : values.length;
    for (int i = 0; i < len; i++) {
      var k = keys[i];
      final v = values[i];
      if (k.startsWith(' ')) k = k.substring(1); // strip visual space prefix
      if (k.isNotEmpty && v.isNotEmpty) map[k] = v;
    }
  }

  void _addParallelLists(
      Map<String, String> map, List<String> keys, List<String> values) {
    final len = keys.length < values.length ? keys.length : values.length;
    for (int i = 0; i < len; i++) {
      if (keys[i].isNotEmpty && values[i].isNotEmpty) map[keys[i]] = values[i];
    }
  }

  Future<Map<String, dynamic>> _loadJson(String asset) async {
    final raw = await rootBundle.loadString(asset);
    return json.decode(raw) as Map<String, dynamic>;
  }

  List<String> _asList(dynamic value) {
    if (value == null) return [];
    return (value as List).map((e) => e.toString()).toList();
  }

  int get mappingCount => _bengaliToChakma.length;
  bool get isInitialized => _isInitialized;
}