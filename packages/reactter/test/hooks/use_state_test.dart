import 'package:flutter_test/flutter_test.dart';
import 'package:reactter/reactter.dart';

import '../shareds/test_controllers.dart';

void main() {
  group("UseState", () {
    test("should has a initial value", () {
      final testController =
          Reactter.create<TestController>(builder: () => TestController())!;

      expect(testController.stateBool.value, false);
      expect(testController.stateString.value, "initial");
      expect(testController.stateInt.value, 0);
      expect(testController.stateDouble.value, 0.0);
      expect(testController.stateList.value.isEmpty, true);
      expect(testController.stateMap.value.isEmpty, true);
      expect(testController.stateClass.value, null);

      Reactter.delete<TestController>();
    });

    test("should changes state value", () {
      final testController =
          Reactter.create<TestController>(builder: () => TestController())!;

      testController.stateBool.value = !testController.stateBool.value;
      testController.stateString.value = "new value";
      testController.stateInt.value += 2;
      testController.stateDouble.value -= 2;
      testController.stateList.value = [1, 2, 3];
      testController.stateMap.value = {"x": 1, "y": 2, "z": 3};
      testController.stateClass.value = TestClass("other class");

      expect(testController.stateBool.value, true);
      expect(testController.stateString.value, "new value");
      expect(testController.stateInt.value, 2);
      expect(testController.stateDouble.value, -2);
      expect(testController.stateList.value.length, 3);
      expect(testController.stateMap.value.length, 3);
      expect(testController.stateClass.value?.prop, "other class");

      Reactter.delete<TestController>();
    });

    test("should notifies when will update", () {
      final testController =
          Reactter.create<TestController>(builder: () => TestController())!;

      testController.stateInt.value = 1;

      late final int willUpdateValue;

      Reactter.one(
        testController.stateInt,
        Lifecycle.willUpdate,
        (inst, param) {
          willUpdateValue = testController.stateInt.value;
        },
      );

      testController.stateInt.value += 1;

      expectLater(willUpdateValue, 1);

      Reactter.delete<TestController>();
    });

    test("should notifies when did update", () async {
      final testController =
          Reactter.create<TestController>(builder: () => TestController())!;

      testController.stateInt.value = 1;

      int didUpdateValue = 0;

      Reactter.one(
        testController.stateInt,
        Lifecycle.didUpdate,
        (inst, param) {
          didUpdateValue = testController.stateInt.value;
        },
      );

      testController.stateInt.value += 1;

      expectLater(didUpdateValue, 2);

      Reactter.one(
        testController.stateInt,
        Lifecycle.didUpdate,
        (inst, param) {
          didUpdateValue = testController.stateInt.value;
        },
      );

      testController.update(
        () => testController.stateInt.update(() {
          testController.stateInt.value = 3;
        }),
      );

      await Future.microtask(() {});

      expectLater(testController.stateInt.value, 3);

      Reactter.delete<TestController>();
    });

    test("should be updated as async way", () async {
      final testController =
          Reactter.create<TestController>(builder: () => TestController())!;

      testController.stateInt.value = 1;

      late final int didUpdateValue;

      Reactter.one(
        testController.stateInt,
        Lifecycle.didUpdate,
        (inst, param) {
          didUpdateValue = testController.stateInt.value;
        },
      );

      await testController.stateInt.updateAsync(() {
        return Future.microtask(() => testController.stateInt.value += 1);
      });

      expectLater(didUpdateValue, 2);

      Reactter.delete<TestController>();
    });
  });
}
