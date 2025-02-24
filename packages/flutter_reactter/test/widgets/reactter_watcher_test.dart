import 'package:flutter/widgets.dart';
import 'package:flutter_reactter/flutter_reactter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../shareds/test_builder.dart';

void main() {
  group("ReactterWatcher", () {
    testWidgets(
      "should rebuild when detected signals has changes",
      (tester) async {
        final signalString = "initial".signal;

        await tester.pumpWidget(
          TestBuilder(
            child: ReactterWatcher(
              builder: (context, child) => Text("$signalString"),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text("initial"), findsOneWidget);

        signalString.value = "other value";

        await tester.pumpAndSettle();

        expect(find.text("other value"), findsOneWidget);
      },
    );
  });
}
