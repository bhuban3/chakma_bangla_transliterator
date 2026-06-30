import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WordSuggestionsCard extends StatelessWidget {
  final List<String> variants;
  final String selected;
  final ValueChanged<String> onSelected;

  const WordSuggestionsCard({
    super.key,
    required this.variants,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.accent.withValues(alpha:0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'সম্ভাব্য শব্দ',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'NotoSansBengali',
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: variants.map((word) {
              final isSelected = word == selected;

              return ChoiceChip(
                label: Text(
                  word,
                  style: const TextStyle(
                    fontFamily: 'NotoSansBengali',
                  ),
                ),
                selected: isSelected,
                onSelected: (_) {
                  onSelected(word);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}