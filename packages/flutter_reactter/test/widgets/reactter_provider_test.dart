import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_reactter/flutter_reactter.dart';

import '../shareds/reactter_provider_builder.dart';
import '../shareds/test_builder.dart';
import '../shareds/test_controller.dart';

void main() {
  group("ReactterProvider", () {
    testWidgets("should gets instance from context", (tester) async {
      late TestController instanceObtained;

      await tester.pumpWidget(
        TestBuilder(
          child: ReactterProviderBuilder(
            builder: (_, context, child) {
              instanceObtained = context.use<TestController>();

              return Text("stateString: ${instanceObtained.stateString.value}");
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.pumpAndSettle();

      expectLater(instanceObtained, isInstanceOf<TestController>());
      expect(find.text("stateString: initial"), findsOneWidget);
    });

    testWidgets("should gets the instance by id from context", (tester) async {
      late TestController instanceObtained;

      await tester.pumpWidget(
        TestBuilder(
          child: ReactterProviderBuilder(
            id: "uniqueId",
            builder: (_, context, child) {
              instanceObtained = context.use<TestController>("uniqueId");

              return Text("stateString: ${instanceObtained.stateString.value}");
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expectLater(instanceObtained, isInstanceOf<TestController>());
      expect(find.text("stateString: from uniqueId"), findsOneWidget);
    });

    testWidgets(
        "should gets the instance from context and watch hooks to builder re-render",
        (tester) async {
      late TestController instanceObtained;

      await tester.pumpWidget(
        TestBuilder(
          child: ReactterProviderBuilder(
            builder: (_, BuildContext context, Widget? child) {
              instanceObtained = context.watch<TestController>(
                (inst) => [inst.stateString, inst.stateBool],
              );

              return Column(
                children: [
                  Text("stateString: ${instanceObtained.stateString.value}"),
                  Text("stateBool: ${instanceObtained.stateBool.value}"),
                ],
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expectLater(instanceObtained, isInstanceOf<TestController>());
      expect(find.text("stateString: initial"), findsOneWidget);
      expect(find.text("stateBool: false"), findsOneWidget);

      instanceObtained.stateString.value = "new value";
      await tester.pumpAndSettle();
      expect(find.text("stateString: new value"), findsOneWidget);

      instanceObtained.stateBool.value = true;
      await tester.pumpAndSettle();
      expect(find.text("stateBool: true"), findsOneWidget);
    });

    testWidgets(
        "should gets the instance by id from context and watch hooks to builder re-render",
        (tester) async {
      late TestController instanceObtained;

      await tester.pumpWidget(
        TestBuilder(
          child: ReactterProviderBuilder(
            id: "uniqueId",
            builder: (_, BuildContext context, Widget? child) {
              instanceObtained = context.watchId<TestController>(
                "uniqueId",
                (inst) => [inst.stateString, inst.stateBool],
              );

              return Column(
                children: [
                  Text("stateString: ${instanceObtained.stateString.value}"),
                  Text("stateBool: ${instanceObtained.stateBool.value}"),
                ],
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expectLater(instanceObtained, isInstanceOf<TestController>());
      expect(find.text("stateString: from uniqueId"), findsOneWidget);
      expect(find.text("stateBool: false"), findsOneWidget);

      instanceObtained.stateString.value = "new value";
      await tester.pumpAndSettle();
      expect(find.text("stateString: new value"), findsOneWidget);

      instanceObtained.stateBool.value = true;
      await tester.pumpAndSettle();
      expect(find.text("stateBool: true"), findsOneWidget);
    });

    testWidgets("should shows child", (tester) async {
      await tester.pumpWidget(
        TestBuilder(
          child: ReactterProvider(
            () => TestController(),
            child: const Text("child"),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text("child"), findsOneWidget);

      await tester.pumpWidget(
        TestBuilder(
          child: ReactterProvider(
            () => TestController(),
            child: const Text("child2"),
            builder: (_, context, child) {
              if (child != null) return child;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text("child2"), findsOneWidget);
    });
  });
}
