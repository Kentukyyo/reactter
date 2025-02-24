import 'package:flutter/material.dart';
import 'package:flutter_reactter/src/framework.dart';
import 'package:flutter_reactter/src/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../shareds/test_builder.dart';
import '../shareds/test_controller.dart';

void main() {
  group("ReactterNestedWidget", () {
    testWidgets("should throw exception when use build method", (tester) async {
      bool hasException = false;

      await tester.pumpWidget(
        TestBuilder(
          child: TestBuilder(
            child: Builder(
              builder: (context) {
                try {
                  return ReactterNestedWidget(
                    owner: ReactterProvider(
                      () => TestController(),
                      child: const SizedBox.shrink(),
                    ) as ReactterProviderElement,
                    wrappedWidget: ReactterProvider(
                      () => TestController(),
                      child: const SizedBox.shrink(),
                    ),
                  ).build(context);
                } catch (e) {
                  hasException = true;
                  return Text(e.toString());
                }
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expectLater(hasException, true);
      expect(find.text("Rendered"), findsNothing);
    });
  });
}
