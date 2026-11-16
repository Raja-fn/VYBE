import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/core/dev/component_gallery_screen.dart';
import 'package:vybe/core/router/screens/start_screen.dart';

import '../../helpers/test_app.dart';

/// Every shared widget must lay out at 1.3x text on the smallest phone.
void main() {
  for (final size in [smallPhoneSize, phoneSize]) {
    testWidgets('component gallery has no overflow at 1.3x on ${size.width.toInt()} wide', (tester) async {
      await pumpInApp(tester, const ComponentGalleryScreen(), textScale: 1.3, size: size, wrapInScaffold: false);
      // Scroll through the whole list so every section is laid out.
      await tester.dragUntilVisible(find.text('SCREEN STATES'), find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('start screen has no overflow at 1.3x on ${size.width.toInt()} wide', (tester) async {
      await pumpInApp(tester, const StartScreen(), textScale: 1.3, size: size, wrapInScaffold: false);
      expect(tester.takeException(), isNull);
    });
  }
}
