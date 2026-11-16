import 'package:findx/core/utils/app_failure.dart';
import 'package:findx/core/widgets/async_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

Widget _view(AsyncValue<List<String>> value, {VoidCallback? onRetry}) => AsyncStateView<List<String>>(
  value: value,
  isEmpty: (items) => items.isEmpty,
  emptyTitle: 'No spots yet',
  onRetry: onRetry,
  builder: (context, items) => Text(items.join(',')),
);

void main() {
  testWidgets('loading shows a spinner', (tester) async {
    await pumpInApp(tester, _view(const AsyncLoading()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('data shows the content', (tester) async {
    await pumpInApp(tester, _view(const AsyncData(['a', 'b'])));
    expect(find.text('a,b'), findsOneWidget);
    expect(find.byType(OfflineBanner), findsNothing);
  });

  testWidgets('empty data shows the empty state', (tester) async {
    await pumpInApp(tester, _view(const AsyncData([])));
    expect(find.text('No spots yet'), findsOneWidget);
  });

  testWidgets('error shows a friendly message and retries', (tester) async {
    var retries = 0;
    await pumpInApp(
      tester,
      _view(const AsyncError(AppFailure(FailureKind.slotFull), StackTrace.empty), onRetry: () => retries++),
    );
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('That time slot just filled up. Pick another one.'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(retries, 1);
  });

  testWidgets('offline with an error shows the offline state', (tester) async {
    await pumpInApp(tester, _view(const AsyncError(AppFailure(FailureKind.network), StackTrace.empty)), online: false);
    expect(find.text('You are offline'), findsOneWidget);
  });

  testWidgets('offline with cached data keeps the data under a banner', (tester) async {
    await pumpInApp(tester, _view(const AsyncData(['cached'])), online: false);
    expect(find.text('cached'), findsOneWidget);
    expect(find.byType(OfflineBanner), findsOneWidget);
  });
}
