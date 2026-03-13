import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> openKanjiTipDialog(BuildContext context, {required VoidCallback onConfirmed}) async {
  const boxName = 'app_settings';
  const showTipsKey = 'show_learning_tips';

  final box = await Hive.openBox<dynamic>(boxName);
  final rawShowTips = box.get(showTipsKey);
  final showTips = rawShowTips is bool ? rawShowTips : true;

  if (!showTips) {
    onConfirmed();
    return;
  }

  final tip = await _loadRandomTip();
  if (!context.mounted) return;

  var optOut = false;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Learning Tip',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(tip, style: Theme.of(context).textTheme.bodyLarge),
                      ),
                      const SizedBox(height: 18),
                      CheckboxListTile(
                        value: optOut,
                        onChanged: (value) {
                          setState(() {
                            optOut = value ?? false;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text("I don't need these tips", style: Theme.of(context).textTheme.bodySmall),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: () async {
                            if (optOut) {
                              await box.put(showTipsKey, false);
                            }
                            if (!dialogContext.mounted) return;
                            Navigator.of(dialogContext).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );

  if (!context.mounted) return;
  onConfirmed();
}

Future<String> _loadRandomTip() async {
  try {
    final raw = await rootBundle.loadString('assets/kanji/kanji_tips.json');
    final decoded = jsonDecode(raw);
    final tips = _extractTips(decoded);

    if (tips.isEmpty) {
      return 'Try reading the kanji first before revealing the answer.';
    }

    return tips[Random().nextInt(tips.length)];
  } catch (_) {
    return 'Try reading the kanji first before revealing the answer.';
  }
}

List<String> _extractTips(dynamic decoded) {
  final tips = <String>[];

  if (decoded is List) {
    for (final item in decoded) {
      final tip = _extractTipText(item);
      if (tip != null && tip.isNotEmpty) {
        tips.add(tip);
      }
    }
    return tips;
  }

  if (decoded is Map) {
    final nested = decoded['kanji_tips'] ?? decoded['tips'];
    if (nested is List) {
      for (final item in nested) {
        final tip = _extractTipText(item);
        if (tip != null && tip.isNotEmpty) {
          tips.add(tip);
        }
      }
    }
  }

  return tips;
}

String? _extractTipText(dynamic item) {
  if (item is String) return item;

  if (item is Map) {
    final candidates = [item['tip'], item['text'], item['message'], item['content'], item['title']];

    for (final value in candidates) {
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
  }

  return null;
}
