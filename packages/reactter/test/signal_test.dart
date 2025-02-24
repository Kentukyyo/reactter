import 'package:reactter/reactter.dart';
import 'package:flutter_test/flutter_test.dart';

import 'shareds/test_controllers.dart';

void main() {
  group("Signal", () {
    test("should be created by Obj", () {
      final obj = true.obj;

      expect(obj.toSignal, isA<Signal<bool>>());
    });

    test("should be cast away nullability", () {
      final signalNull = Signal<bool?>(false);

      expect(signalNull.value, false);
      expect(signalNull.notNull, isA<Signal<bool>>());
    });

    test("should be casted to Obj", () {
      final signal = true.signal;

      expect(signal.toObj, isA<Obj<bool>>());
    });

    test("should notifies when its value is changed", () {
      final signal = "initial".signal;

      signal.updateAsync((value) {
        signal("change value before listen");
      });

      late final willUpdateChecked;
      late final didUpdateChecked;

      Reactter.one(signal, Lifecycle.willUpdate, (_, __) {
        willUpdateChecked = true;
      });
      Reactter.one(signal, Lifecycle.didUpdate, (_, __) {
        didUpdateChecked = true;
      });

      signal("change value");

      expectLater(willUpdateChecked, true);
      expectLater(didUpdateChecked, true);
    });

    test("should be updated", () {
      final signal = "initial".signal;
      late final willUpdateChecked;
      late final didUpdateChecked;

      Reactter.one(signal, Lifecycle.willUpdate, (_, __) {
        willUpdateChecked = true;
      });
      Reactter.one(signal, Lifecycle.didUpdate, (_, __) {
        didUpdateChecked = true;
      });

      signal.update((_) {});

      expectLater(willUpdateChecked, true);
      expectLater(didUpdateChecked, true);
    });

    test("should be updated as async way", () async {
      final signal = "initial".signal;
      late final willUpdateChecked;
      late final didUpdateChecked;

      Reactter.one(signal, Lifecycle.willUpdate, (_, __) {
        willUpdateChecked = true;
      });
      Reactter.one(signal, Lifecycle.didUpdate, (_, __) {
        didUpdateChecked = true;
      });

      await signal.updateAsync(
        ((_) async => Future.delayed(Duration(microseconds: 1))),
      );

      expectLater(willUpdateChecked, true);
      expectLater(didUpdateChecked, true);
    });

    test("should be refreshed", () {
      final signal = "initial".signal;
      late final didUpdateChecked;

      Reactter.one(signal, Lifecycle.didUpdate, (_, __) {
        didUpdateChecked = true;
      });

      signal.refresh();

      expectLater(didUpdateChecked, true);
    });

    test("should be able to used on instance", () {
      late final willUpdateChecked;
      late final didUpdateChecked;

      final testController =
          Reactter.create<TestController>(builder: () => TestController())!;
      final signalString = testController.signalString;

      expect(signalString(), "initial");

      Reactter.one(testController, Lifecycle.willUpdate, (_, __) {
        willUpdateChecked = true;
      });
      Reactter.one(testController, Lifecycle.didUpdate, (_, __) {
        didUpdateChecked = true;
      });

      signalString("change signal");

      expectLater(willUpdateChecked, true);
      expectLater(didUpdateChecked, true);

      Reactter
        ..unregister<TestController>()
        ..delete<TestController>();

      expect(
        () => signalString("throw a assertion error"),
        throwsA(TypeMatcher<AssertionError>()),
      );
    });
  });
}
