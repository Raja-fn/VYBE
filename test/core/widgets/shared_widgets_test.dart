import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/core/theme/app_colors.dart';
import 'package:vybe/core/widgets/app_button.dart';
import 'package:vybe/core/widgets/app_choice_chip.dart';
import 'package:vybe/core/widgets/app_pill_button.dart';
import 'package:vybe/core/widgets/badges.dart';
import 'package:vybe/core/widgets/content_rows.dart';
import 'package:vybe/core/widgets/photo_card.dart';

import '../../helpers/test_app.dart';

void main() {
  group('AppButton', () {
    testWidgets('calls onPressed when tapped', (tester) async {
      var taps = 0;
      await pumpInApp(tester, AppButton(label: 'Go', onPressed: () => taps++));
      await tester.tap(find.text('Go'));
      expect(taps, 1);
    });

    testWidgets('is at least 48 tall and full width', (tester) async {
      await pumpInApp(tester, AppButton(label: 'Go', onPressed: () {}));
      final size = tester.getSize(find.byType(FilledButton));
      expect(size.height, greaterThanOrEqualTo(48));
      expect(size.width, phoneSize.width);
    });

    testWidgets('does nothing while loading and announces loading', (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await pumpInApp(tester, AppButton(label: 'Go', onPressed: () => taps++, isLoading: true));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.bySemanticsLabel('Go, Loading'), findsOneWidget);
      await tester.tap(find.byType(FilledButton));
      expect(taps, 0);
      handle.dispose();
    });

    testWidgets('is disabled without onPressed', (tester) async {
      await pumpInApp(tester, const AppButton(label: 'Go', onPressed: null));
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
    });
  });

  group('AppChoiceChip', () {
    testWidgets('selected chip has a coral fill and reports selected', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpInApp(tester, AppChoiceChip(label: 'Coffee', selected: true, onSelected: () {}));
      final container = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
      expect((container.decoration! as ShapeDecoration).color, AppColors.accent);
      expect(
        tester.getSemantics(find.byType(AppChoiceChip)),
        containsSemantics(label: 'Coffee', isButton: true, isSelected: true, isInMutuallyExclusiveGroup: true),
      );
      handle.dispose();
    });

    testWidgets('unselected chip has a dark fill and taps through', (tester) async {
      var taps = 0;
      await pumpInApp(tester, AppChoiceChip(label: 'Walk', selected: false, onSelected: () => taps++));
      final container = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
      expect((container.decoration! as ShapeDecoration).color, AppColors.softFill);
      await tester.tap(find.text('Walk'));
      expect(taps, 1);
    });

    testWidgets('disabled chip is struck through and ignores taps', (tester) async {
      var taps = 0;
      await pumpInApp(tester, AppChoiceChip(label: '6 PM', selected: false, enabled: false, onSelected: () => taps++));
      final text = tester.widget<Text>(find.text('6 PM'));
      expect(text.style?.decoration, TextDecoration.lineThrough);
      await tester.tap(find.text('6 PM'));
      expect(taps, 0);
    });

    testWidgets('meets the 44 minimum touch target', (tester) async {
      await pumpInApp(
        tester,
        Center(
          child: AppChoiceChip(label: 'A', selected: false, onSelected: () {}),
        ),
      );
      final size = tester.getSize(find.byType(AppChoiceChip));
      expect(size.height, greaterThanOrEqualTo(44));
      expect(size.width, greaterThanOrEqualTo(44));
    });
  });

  group('Pills and badges', () {
    testWidgets('CreditsPill shows the balance and an accessible label', (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await pumpInApp(tester, Center(child: CreditsPill(credits: 12, onPressed: () => taps++)));
      expect(find.text('12'), findsOneWidget);
      // Coin and number only; the word is for screen readers.
      expect(find.bySemanticsLabel('12 credits. Open credits and plans'), findsOneWidget);
      await tester.tap(find.byType(CreditsPill));
      expect(taps, 1);
      handle.dispose();
    });

    testWidgets('CreditsPill uses the singular for one credit', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpInApp(tester, Center(child: CreditsPill(credits: 1, onPressed: () {})));
      expect(find.bySemanticsLabel('1 credit. Open credits and plans'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('Verified and Free now badges render their labels', (tester) async {
      await pumpInApp(tester, const Column(children: [VerifiedBadge(), FreeNowBadge()]));
      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('Free now'), findsOneWidget);
    });

    testWidgets('AppPillButton uses a custom semantic label when given', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpInApp(
        tester,
        Center(
          child: AppPillButton(label: 'Pick', semanticLabel: 'Pick Cafe One', onPressed: () {}),
        ),
      );
      expect(find.bySemanticsLabel('Pick Cafe One'), findsOneWidget);
      handle.dispose();
    });
  });

  group('Rows', () {
    testWidgets('StepRow announces its state', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpInApp(
        tester,
        const StepRow(number: 2, title: 'Selfie check', subtitle: 'About 20 seconds', state: AppStepState.current),
      );
      expect(find.bySemanticsLabel('Step 2, in progress. Selfie check. About 20 seconds'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('AppSwitchTile toggles', (tester) async {
      bool? changed;
      await pumpInApp(tester, AppSwitchTile(title: 'Free now', value: false, onChanged: (v) => changed = v));
      await tester.tap(find.byType(Switch));
      expect(changed, isTrue);
    });

    testWidgets('RuleListItem shows a check or a cross', (tester) async {
      await pumpInApp(
        tester,
        const Column(
          children: [
            RuleListItem(text: 'Yes', allowed: true),
            RuleListItem(text: 'No', allowed: false),
          ],
        ),
      );
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });

  test('initialOf takes the first letter, upper-cased', () {
    expect(initialOf('  neha'), 'N');
    expect(initialOf(''), '');
  });
}
