import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

                      const Divider(height: 24),

                      SettingsRow(
                        title: 'Report a problem',
                        trailing: const Icon(Icons.report_problem),
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
                      ),
                      const Divider(height: 24),

                      SettingsRow(
                        title: 'About the app',
                        trailing: const CircleAvatar(radius: 14, child: Icon(Icons.question_mark, size: 16)),
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          openAboutAppDialog(context);
                        },
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
