import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// The animated start screen, shown while [app] is being prepared.
///
/// It picks up exactly where the native splash leaves off (the VYBE wordmark,
/// centred on the dark background), then:
/// 1. the letters ripple, one after another;
/// 2. a coral underline draws across and the tagline rises in;
/// 3. once [app] is ready, the splash lifts away like a curtain.
///
/// If the app takes longer than the intro, a highlight keeps sweeping along
/// the underline. With "remove animations" on, it shows the final frame and
/// switches straight to the app.
class SplashGate extends StatefulWidget {
  const SplashGate({required this.app, this.tagline = 'Meet new people, safely', super.key});

  /// The app (or an error screen) to show next. Never completes with an error.
  final Future<Widget> app;
  final String tagline;

  /// Key of the splash layer, for tests.
  static const overlayKey = ValueKey('splash-overlay');

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  late final AnimationController _idle = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
  late final AnimationController _exit = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

  Widget? _next;
  bool _done = false;
  bool _started = false;

  bool get _reduceMotion => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (_reduceMotion) {
      _intro.value = 1;
    } else {
      _intro.forward().whenComplete(() {
        // Still waiting for the app: keep the underline alive.
        if (mounted && _next == null) _idle.repeat();
        _maybeExit();
      });
    }
    widget.app.then((app) {
      if (!mounted) return;
      setState(() => _next = app);
      _maybeExit();
    });
  }

  void _maybeExit() {
    if (!mounted || _next == null || _exit.isAnimating || _done) return;
    if (_reduceMotion) {
      setState(() => _done = true);
      return;
    }
    if (!_intro.isCompleted) return; // the intro calls back when it ends
    _idle.stop();
    _exit.forward().whenComplete(() {
      if (mounted) setState(() => _done = true);
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _idle.dispose();
    _exit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final next = _next;
    if (_done && next != null) return next;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ?next,
          AnimatedBuilder(
            animation: Listenable.merge([_intro, _idle, _exit]),
            builder: (context, _) {
              final lift = Curves.easeInOutCubic.transform(_exit.value);
              return LayoutBuilder(
                builder: (context, box) => Transform.translate(
                  offset: Offset(0, -lift * box.maxHeight),
                  child: Semantics(
                    key: SplashGate.overlayKey,
                    label: 'VYBE. ${widget.tagline}',
                    container: true,
                    child: ColoredBox(
                      color: AppColors.background,
                      child: CustomPaint(
                        size: box.biggest,
                        painter: _SplashPainter(
                          intro: _intro.value,
                          idle: _idle.isAnimating ? _idle.value : null,
                          // The content drifts up a little faster than the curtain.
                          drift: lift,
                          tagline: widget.tagline,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Fraction of [t] between [start] and [end], clamped to 0..1.
double _span(double t, double start, double end) => ((t - start) / (end - start)).clamp(0.0, 1.0);

class _SplashPainter extends CustomPainter {
  _SplashPainter({required this.intro, required this.idle, required this.drift, required this.tagline});

  final double intro;
  final double? idle;
  final double drift;
  final String tagline;

  static const _letters = ['V', 'Y', 'B', 'E'];

  static TextPainter _text(String text, TextStyle style) => TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero) - Offset(0, drift * 60);

    const wordStyle = TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 46,
      fontWeight: FontWeight.w800,
      letterSpacing: 3,
      height: 1,
      color: AppColors.onInk,
    );
    final letters = [
      for (var i = 0; i < _letters.length; i++)
        _text(_letters[i], i == _letters.length - 1 ? wordStyle.copyWith(color: AppColors.accent) : wordStyle),
    ];
    final wordWidth = letters.fold<double>(0, (sum, l) => sum + l.width) - wordStyle.letterSpacing!;
    final wordHeight = letters.first.height;

    // Centred, exactly where the native splash draws it (tool/icon/make_icon.py).
    final wordLeft = center.dx - wordWidth / 2;
    final wordTop = center.dy - wordHeight / 2;

    // Letters ripple: each lifts a little and settles, one after another.
    var x = wordLeft;
    for (var i = 0; i < letters.length; i++) {
      final start = 0.04 + i * 0.08;
      final lift = math.sin(_span(intro, start, start + 0.3) * math.pi) * 10;
      letters[i].paint(canvas, Offset(x, wordTop - lift));
      x += letters[i].width;
    }

    // Underline: draws left to right, then a highlight sweeps while waiting.
    final lineTop = wordTop + wordHeight + 10;
    final draw = Curves.easeInOutCubic.transform(_span(intro, 0.42, 0.75));
    if (draw > 0) {
      final line = Rect.fromLTWH(wordLeft, lineTop, wordWidth * draw, 3);
      canvas.drawRRect(RRect.fromRectAndRadius(line, const Radius.circular(2)), Paint()..color = AppColors.accent);
      final sweep = idle;
      if (sweep != null) {
        final segment = wordWidth * 0.28;
        final segmentLeft = wordLeft - segment + sweep * (wordWidth + segment);
        canvas.save();
        canvas.clipRect(line);
        canvas.drawRect(
          Rect.fromLTWH(segmentLeft, lineTop, segment, 3),
          Paint()..color = AppColors.onInk.withValues(alpha: 0.7),
        );
        canvas.restore();
      }
    }

    // Tagline rises in under the line.
    final taglinePainter = _text(
      tagline,
      const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 15, letterSpacing: 0.3, color: AppColors.muted),
    );
    final taglineTop = lineTop + 18;
    final taglineLeft = center.dx - taglinePainter.width / 2;
    final taglineIn = Curves.easeOutCubic.transform(_span(intro, 0.62, 1));
    if (taglineIn > 0) {
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(taglineLeft - 4, taglineTop, taglinePainter.width + 8, taglinePainter.height + 2));
      taglinePainter.paint(canvas, Offset(taglineLeft, taglineTop + (1 - taglineIn) * taglinePainter.height));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SplashPainter old) =>
      old.intro != intro || old.idle != idle || old.drift != drift || old.tagline != tagline;
}
