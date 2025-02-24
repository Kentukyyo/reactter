import 'package:flutter/material.dart';
import 'package:flutter_reactter/src/extensions.dart';
import 'package:flutter_reactter/src/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../shareds/reactter_provider_builder.dart';
import '../shareds/reactter_providers_builder.dart';
import '../shareds/test_builder.dart';
import '../shareds/test_controller.dart';

void main() {
  group(
    "ReactterConsumer",
    () {
      testWidgets(
        "should throw exception when instance not found",
        (tester) async {
          await tester.pumpWidget(
            TestBuilder(
              child: ReactterConsumer<TestController>(
                builder: (inst, _, __) {
                  return const Text("Rendered");
                },
              ),
            ),
          );

          await tester.pumpAndSettle();

          expect(
            tester.takeException(),
            isInstanceOf<ReactterInstanceNotFoundException>(),
          );
          expect(find.text("Rendered"), findsNothing);
        },
      );

      testWidgets(
        "should gets null when instance not found",
        (tester) async {
          late TestController? instanceObtained;

          await tester.pumpWidget(
            TestBuilder(
              child: ReactterConsumer<TestController?>(
                builder: (inst, _, __) {
                  instanceObtained = inst;

                  return Text(
                    "stateString: ${inst?.stateString.value ?? 'not found'}",
                  );
                },
              ),
            ),
          );

          await tester.pumpAndSettle();

          expectLater(instanceObtained, null);
          expect(find.text("stateString: not found"), findsOneWidget);
        },
      );

      testWidgets(
        "should watch instance changes",
        (tester) async {
          late TestController instanceObtained;

          await tester.pumpWidget(
            TestBuilder(
              child: ReactterProviderBuilder(
                builder: (_, __, ___) {
                  return ReactterConsumer<TestController>(
                    listenAll: true,
                    builder: (inst, _, __) {
                      instanceObtained = inst;

                      return Text("stateString: ${inst.stateString.value}");
                    },
                  );
                },
              ),
            ),
          );

          await tester.pumpAndSettle();

          expectLater(instanceObtained, isInstanceOf<TestController>());
          expect(find.text("stateString: initial"), findsOneWidget);

          instanceObtained.stateString.value = "new value";
          await tester.pumpAndSettle();

          expect(find.text("stateString: new value"), findsOneWidget);
        },
      );

      testWidgets(
        "should watch instance's states",
        (tester) async {
          late TestController instanceObtained;

          await tester.pumpWidget(
            TestBuilder(
              child: ReactterProviderBuilder(
                builder: (_, __, ___) {
                  return ReactterConsumer<TestController>(
                    listenStates: (inst) => [inst.stateInt],
                    builder: (inst, _, __) {
                      instanceObtained = inst;

                      return Column(
                        children: [
                          Text("stateString: ${inst.stateString.value}"),
                          Text("stateInt: ${inst.stateInt.value}"),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          );

          await tester.pumpAndSettle();

          expectLater(instanceObtained, isInstanceOf<TestController>());
          expect(find.text("stateString: initial"), findsOneWidget);
          expect(find.text("stateInt: 0"), findsOneWidget);

          instanceObtained.stateString.value = "new value";
          await tester.pumpAndSettle();

          expect(find.text("stateString: initial"), findsOneWidget);
          expect(find.text("stateInt: 0"), findsOneWidget);

          instanceObtained.stateInt.value += 2;
          await tester.pumpAndSettle();

          expect(find.text("stateString: new value"), findsOneWidget);
          expect(find.text("stateInt: 2"), findsOneWidget);
        },
      );

      testWidgets(
        "should watch multiple instance's states, using different context.watch",
        (tester) async {
          late TestController instanceObtained;
          late TestController instanceObtainedWithId;

          await tester.pumpWidget(
            TestBuilder(
              child: ReactterProvidersBuilder(
                builder: (_, __) {
                  return ReactterConsumer<TestController>(
                    builder: (inst, _, __) {
                      instanceObtained = inst;

                      return ReactterConsumer<TestController>(
                        id: 'uniqueId',
                        builder: (instWithId, _, __) {
                          instanceObtainedWithId = instWithId;

                          return Column(
                            children: [
                              // any change of any states without id
                              ReactterConsumer<TestController>(
                                listenAll: true,
                                builder: (_, __, ___) {
                                  return Column(
                                    children: [
                                      Text(
                                        "stateStringByIdDontWatch: ${instanceObtainedWithId.stateString.value}",
                                      ),
                                      Text(
                                        "stateString: ${inst.stateString.value}",
                                      ),
                                    ],
                                  );
                                },
                              ),
                              // only change of stateString with id
                              ReactterConsumer<TestController>(
                                id: 'uniqueId',
                                listenStates: (inst) => [inst.stateString],
                                builder: (_, __, ___) {
                                  return Text(
                                    "stateStringById: ${instWithId.stateString.value}",
                                  );
                                },
                              ),
                              // any change of stateInt
                              ReactterConsumer<TestController>(
                                listenStates: (inst) => [
                                  inst.stateInt,
                                  instWithId.stateInt,
                                ],
                                builder: (_, __, ___) {
                                  return Column(
                                    children: [
                                      Text(
                                        "stateIntById: ${instWithId.stateInt.value}",
                                      ),
                                      Text("stateInt: ${inst.stateInt.value}"),
                                    ],
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          );
          await tester.pumpAndSettle();

          expectLater(instanceObtained, isInstanceOf<TestController>());
          expectLater(instanceObtainedWithId, isInstanceOf<TestController>());

          expect(
            find.text("stateStringByIdDontWatch: from uniqueId"),
            findsOneWidget,
          );
          expect(find.text("stateString: initial"), findsOneWidget);
          expect(find.text("stateStringById: from uniqueId"), findsOneWidget);
          expect(find.text("stateIntById: 0"), findsOneWidget);
          expect(find.text("stateInt: 0"), findsOneWidget);

          instanceObtained.stateString.value = "new value";
          await tester.pumpAndSettle();

          expect(
            find.text("stateStringByIdDontWatch: from uniqueId"),
            findsOneWidget,
          );
          expect(find.text("stateString: new value"), findsOneWidget);
          expect(find.text("stateStringById: from uniqueId"), findsOneWidget);
          expect(find.text("stateIntById: 0"), findsOneWidget);
          expect(find.text("stateInt: 0"), findsOneWidget);

          instanceObtainedWithId.stateString.value = "new value";
          await tester.pumpAndSettle();

          expect(find.text("stateStringByIdDontWatch: from uniqueId"),
              findsOneWidget);
          expect(find.text("stateString: new value"), findsOneWidget);
          expect(find.text("stateStringById: new value"), findsOneWidget);
          expect(find.text("stateIntById: 0"), findsOneWidget);
          expect(find.text("stateInt: 0"), findsOneWidget);

          instanceObtained.stateInt.value += 2;
          await tester.pumpAndSettle();

          expect(
              find.text("stateStringByIdDontWatch: new value"), findsOneWidget);
          expect(find.text("stateString: new value"), findsOneWidget);
          expect(find.text("stateStringById: new value"), findsOneWidget);
          expect(find.text("stateIntById: 0"), findsOneWidget);
          expect(find.text("stateInt: 2"), findsOneWidget);

          instanceObtainedWithId.stateInt.value += 5;
          await tester.pumpAndSettle();

          expect(
              find.text("stateStringByIdDontWatch: new value"), findsOneWidget);
          expect(find.text("stateString: new value"), findsOneWidget);
          expect(find.text("stateStringById: new value"), findsOneWidget);
          expect(find.text("stateIntById: 5"), findsOneWidget);
          expect(find.text("stateInt: 2"), findsOneWidget);
        },
      );
    },
  );
}
