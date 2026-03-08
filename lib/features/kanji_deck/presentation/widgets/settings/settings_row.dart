import 'package:flutter/material.dart';

class SettingsRow extends StatelessWidget {
  const SettingsRow({super.key, required this.title, required this.trailing, this.enabled = true, this.onTap});

  final String title;
  final Widget trailing;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge;

    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: enabled ? textStyle : textStyle?.copyWith(color: Theme.of(context).disabledColor),
              ),
            ),
            const SizedBox(width: 12),
            Opacity(opacity: enabled ? 1 : 0.5, child: trailing),
          ],
        ),
      ),
    );
  }
}
