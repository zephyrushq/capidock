import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'locale_controller.dart';
import 'localization.dart';

/// Native names make each language recognisable regardless of the current locale.
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key, this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final controller = AppLocaleScope.of(context);
    return PopupMenuButton<Locale>(
      key: const ValueKey('language-selector'),
      tooltip: context.l10n.language,
      initialValue: controller.locale,
      position: PopupMenuPosition.under,
      onSelected: (locale) async {
        try {
          await controller.select(locale);
        } catch (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.languageSaveError)),
            );
          }
        }
      },
      itemBuilder: (_) => [
        for (final language in AppLanguage.values)
          PopupMenuItem(
            key: ValueKey('language-${language.locale.toLanguageTag()}'),
            value: language.locale,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CountryFlag(country: language.locale.countryCode!),
                const SizedBox(width: 12),
                Flexible(child: Text(language.name)),
                const SizedBox(width: 12),
                if (language.locale == controller.locale)
                  const Icon(Icons.check, size: 18),
              ],
            ),
          ),
      ],
      child: Semantics(
        button: true,
        label: '${context.l10n.language}: ${controller.language.name}',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CountryFlag(country: controller.locale.countryCode!),
              if (!compact) ...[
                const SizedBox(width: 10),
                Text(context.l10n.language),
              ],
              const SizedBox(width: 4),
              const Icon(Icons.expand_more, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vector flags are bundled in code; no emoji fonts, packages or network are needed.
class CountryFlag extends StatelessWidget {
  const CountryFlag({super.key, required this.country});
  final String country;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: 28,
      height: 19,
      child: CustomPaint(painter: _FlagPainter(country)),
    ),
  );
}

class _FlagPainter extends CustomPainter {
  const _FlagPainter(this.country);
  final String country;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(2)),
    );
    canvas.scale(size.width / 30, size.height / 20);
    void rect(double x, double y, double w, double h, Color colour) =>
        canvas.drawRect(Rect.fromLTWH(x, y, w, h), Paint()..color = colour);
    void circle(double x, double y, double radius, Color colour) =>
        canvas.drawCircle(Offset(x, y), radius, Paint()..color = colour);
    const red = Color(0xffc8102e),
        white = Colors.white,
        blue = Color(0xff012169);
    switch (country) {
      case 'GB':
        rect(0, 0, 30, 20, blue);
        for (final width in [5.0, 2.0]) {
          final paint = Paint()
            ..color = (width == 5 ? white : red)
            ..strokeWidth = width;
          canvas.drawLine(Offset.zero, const Offset(30, 20), paint);
          canvas.drawLine(const Offset(0, 20), const Offset(30, 0), paint);
        }
        rect(12, 0, 6, 20, white);
        rect(0, 7, 30, 6, white);
        rect(13.5, 0, 3, 20, red);
        rect(0, 8.5, 30, 3, red);
      case 'US':
        rect(0, 0, 30, 20, white);
        for (var i = 0; i < 13; i += 2) {
          rect(0, i * 20 / 13, 30, 20 / 13, red);
        }
        rect(0, 0, 12, 20 * 7 / 13, blue);
        for (var row = 0; row < 9; row++) {
          for (var col = 0; col < (row.isEven ? 6 : 5); col++) {
            final centre = Offset(
              (col + (row.isEven ? 0.5 : 1)) * 2,
              1 + row * 1.1,
            );
            final star = Path();
            for (var point = 0; point < 10; point++) {
              final angle = -math.pi / 2 + point * math.pi / 5;
              final radius = point.isEven ? 0.55 : 0.23;
              final x = centre.dx + math.cos(angle) * radius,
                  y = centre.dy + math.sin(angle) * radius;
              if (point == 0) {
                star.moveTo(x, y);
              } else {
                star.lineTo(x, y);
              }
            }
            canvas.drawPath(star..close(), Paint()..color = white);
          }
        }
      case 'PT':
        rect(0, 0, 30, 20, const Color(0xffda291c));
        rect(0, 0, 12, 20, const Color(0xff046a38));
        circle(12, 10, 4.2, const Color(0xffffd700));
        rect(9.9, 7, 4.2, 6, white);
        rect(10.6, 7.7, 2.8, 4.5, red);
        circle(12, 10, 1, blue);
      case 'BR':
        rect(0, 0, 30, 20, const Color(0xff009739));
        final diamond = Path()
          ..moveTo(15, 2)
          ..lineTo(28, 10)
          ..lineTo(15, 18)
          ..lineTo(2, 10)
          ..close();
        canvas.drawPath(diamond, Paint()..color = const Color(0xffffdf00));
        circle(15, 10, 5, const Color(0xff002776));
        canvas.drawArc(
          const Rect.fromLTWH(8, 8, 15, 9),
          -math.pi * .8,
          math.pi * .6,
          false,
          Paint()
            ..color = white
            ..style = PaintingStyle.stroke
            ..strokeWidth = .8,
        );
      case 'ES':
        rect(0, 0, 30, 20, const Color(0xffaa151b));
        rect(0, 5, 30, 10, const Color(0xfff1bf00));
        rect(8, 8, 3, 5, red);
        rect(8.4, 8.4, .8, 2, white);
        rect(10, 10.5, .7, 2, white);
        rect(7.2, 8.5, .4, 4, white);
        rect(11.5, 8.5, .4, 4, white);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FlagPainter oldDelegate) =>
      oldDelegate.country != country;
}
