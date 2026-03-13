import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/theme_settings_controller.dart';
import '../../application/kanji_deck_controller.dart';
import '../dialogs/about_app_dialog.dart';
import '../widgets/settings/settings_row.dart';

void openKanjiSettingsDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(kanjiDeckControllerProvider);
          final notifier = ref.read(kanjiDeckControllerProvider.notifier);

          final themeState = ref.watch(themeSettingsProvider);
          final themeNotifier = ref.read(themeSettingsProvider.notifier);

          return Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),

                      SettingsRow(
                        title: 'Dark mode',
                        trailing: Switch(
                          value: themeState.mode == ThemeMode.dark,
                          onChanged: (v) => themeNotifier.setDarkMode(v),
                        ),
                      ),

                      const Divider(height: 24),

                      SettingsRow(
                        title: 'Show readings',
                        trailing: Checkbox(
                          value: state.showReadings,
                          onChanged: (v) => notifier.setShowReadings(v ?? false),
                        ),
                      ),
                      SettingsRow(
                        title: 'Show meanings',
                        trailing: Checkbox(
                          value: state.showMeanings,
                          onChanged: (v) => notifier.setShowMeanings(v ?? false),
                        ),
                      ),
                      FutureBuilder<Box<dynamic>>(
                        future: Hive.openBox<dynamic>('app_settings'),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox.shrink();
                          }

                          final box = snapshot.data!;

                          return ValueListenableBuilder(
                            valueListenable: box.listenable(keys: const ['show_learning_tips']),
                            builder: (context, _, _) {
                              final raw = box.get('show_learning_tips');
                              final showTips = raw is bool ? raw : true;

                              return SettingsRow(
                                title: 'Show learning tips',
                                trailing: Switch(
                                  value: showTips,
                                  onChanged: (value) async {
                                    await box.put('show_learning_tips', value);
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),

                      const Divider(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                final uri = Uri(
                                  scheme: 'mailto',
                                  path: 'support@higaladev.com',
                                  queryParameters: const {'subject': 'Kanjimoo Problem Report'},
                                );

                                try {
                                  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  if (!ok && context.mounted) {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(const SnackBar(content: Text('Unable to open email app.')));
                                  }
                                } catch (_) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(const SnackBar(content: Text('Unable to open email app.')));
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                child: Row(
                                  children: [
                                    const Icon(Icons.report_problem_outlined, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text('Report', style: Theme.of(context).textTheme.bodySmall)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.of(dialogContext).pop();
                                openAboutAppDialog(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_outline, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text('About the app', style: Theme.of(context).textTheme.bodySmall),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Close'),
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
}
