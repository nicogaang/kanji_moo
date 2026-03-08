import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

void openAboutAppDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/kanjimoo2.png',
                      width: 164,
                      fit: BoxFit.contain,
                      color: Theme.of(context).colorScheme.onSurface,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 4),

                  FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      final version = snapshot.data?.version ?? '';
                      final build = snapshot.data?.buildNumber ?? '';
                      return Text(
                        version.isEmpty ? '' : 'Version $version+$build',
                        style: const TextStyle(fontSize: 14),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'KanjiMoo is a minimalist JLPT kanji flashcard app designed for focused learning with smooth vertical swipe navigation.',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Credits & Data Sources', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Kanji data provided by kanjiapi.dev.\n'
                      'Dictionary files © Electronic Dictionary Research and Development Group (EDRDG).\n'
                      'JLPT level information adapted from Jonathan Waller\'s JLPT Resources.\n\n'
                      'Used in accordance with their respective licenses.',
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text('© HigalaDev', style: TextStyle(fontSize: 12)),

                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
