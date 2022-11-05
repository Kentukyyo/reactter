import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_reactter/flutter_reactter.dart';

import '../shareds/reactter_providers_builder.dart';
import '../shareds/test_builder.dart';
import '../shareds/test_context.dart';

void main() {
  group("ReactterComponent", () {
    late TestContext instanceObtained;

    testWidgets("should renders and get instance", (tester) async {
      await tester.pumpWidget(
        TestBuilder(
          child: TestBuilder(
            child: ReactterComponentTest(
              getInstance: (ctx) {
                instanceObtained = ctx;
              },
            ),
          ),
        ),
      );

      _testReactterComponent(tester: tester, instance: instanceObtained);
    });

    testWidgets("should renders and gets instance by id", (tester) async {
      late TestContext instanceObtained;

      await tester.pumpWidget(
        TestBuilder(
          child: ReactterProvidersBuilder(
            builder: (_, __) {
              return ReactterComponentTest(
                id: "uniqueId",
                getInstance: (ctx) {
                  instanceObtained = ctx;
                },
              );
            },
          ),
        ),
      );

      _testReactterComponent(
        tester: tester,
        instance: instanceObtained,
        byId: true,
      );
    });

    testWidgets("should renders and gets instance without builder instance",
        (tester) async {
      late TestContext instanceObtained;

      await tester.pumpWidget(
        TestBuilder(
          child: ReactterProvidersBuilder(
            builder: (_, __) {
              return ReactterComponentTest(
                withoutBuilder: true,
                getInstance: (ctx) {
                  instanceObtained = ctx;
                },
              );
            },
          ),
        ),
      );

      _testReactterComponent(tester: tester, instance: instanceObtained);
    });

    testWidgets("should renders and gets instance without listen hooks",
        (tester) async {
      late TestContext instanceObtained;

      await tester.pumpWidget(
        TestBuilder(
          child: ReactterProvidersBuilder(
            builder: (_, __) {
              return ReactterComponentTest(
                withoutListenHooks: true,
                getInstance: (ctx) {
                  instanceObtained = ctx;
                },
              );
            },
          ),
        ),
      );

      _testReactterComponent(
        tester: tester,
        instance: instanceObtained,
        withoutListenHooks: true,
      );
    });
  });
}

_testReactterComponent({
  required WidgetTester tester,
  required TestContext instance,
  bool withoutListenHooks = false,
  bool byId = false,
}) async {
  await tester.pumpAndSettle();

  _expectInitial() {
    expect(find.text("stateBool: false"), findsOneWidget);

    if (byId) {
      expect(find.text("stateString: from uniqueId"), findsOneWidget);
    } else {
      expect(find.text("stateString: initial"), findsOneWidget);
    }
  }

  _expectInitial();

  instance.stateBool.value = true;
  instance.stateString.value = "new value";

  await tester.pumpAndSettle();

  if (withoutListenHooks) {
    _expectInitial();
  } else {
    expect(find.text("stateBool: true"), findsOneWidget);
    expect(find.text("stateString: new value"), findsOneWidget);
  }
}

class ReactterComponentTest extends StatelessWidget {
  const ReactterComponentTest({
    Key? key,
    this.id,
    required this.getInstance,
    this.withoutBuilder = false,
    this.withoutListenHooks = false,
  }) : super(key: key);

  final bool withoutBuilder;
  final bool withoutListenHooks;

  final String? id;
  final void Function(TestContext ctx) getInstance;

  @override
  build(context) {
    if (withoutBuilder) {
      return ReactterComponentTestWithoutBuilder(
        id: id,
        getInstance: getInstance,
      );
    }

    if (withoutListenHooks) {
      return ReactterComponentTestWithoutListenHooks(
        id: id,
        getInstance: getInstance,
      );
    }

    if (id == null) {
      return ReactterComponentTestWithoutId(
        getInstance: getInstance,
      );
    }

    return ReactterComponentTestAll(
      id: id,
      getInstance: getInstance,
    );
  }
}

class ReactterComponentTestWithoutId extends ReactterComponent<TestContext> {
  const ReactterComponentTestWithoutId({
    Key? key,
    required this.getInstance,
  }) : super(key: key);

  final void Function(TestContext ctx) getInstance;

  @override
  get builder => () => TestContext();

  @override
  get listenHooks => (ctx) => [ctx.stateBool, ctx.stateString];

  @override
  Widget render(TestContext ctx, BuildContext context) {
    getInstance(ctx);

    return _buildWidget(ctx);
  }
}

class ReactterComponentTestWithoutBuilder
    extends ReactterComponent<TestContext> {
  const ReactterComponentTestWithoutBuilder({
    Key? key,
    this.id,
    required this.getInstance,
  }) : super(key: key);

  final void Function(TestContext ctx) getInstance;

  @override
  final String? id;

  @override
  get listenHooks => (ctx) => [ctx.stateBool, ctx.stateString];

  @override
  Widget render(TestContext ctx, BuildContext context) {
    getInstance(ctx);

    return _buildWidget(ctx);
  }
}

class ReactterComponentTestWithoutListenHooks
    extends ReactterComponent<TestContext> {
  const ReactterComponentTestWithoutListenHooks({
    Key? key,
    this.id,
    required this.getInstance,
  }) : super(key: key);

  final void Function(TestContext ctx) getInstance;

  @override
  final String? id;

  @override
  get builder => () => TestContext();

  @override
  Widget render(TestContext ctx, BuildContext context) {
    getInstance(ctx);

    return _buildWidget(ctx);
  }
}

class ReactterComponentTestAll extends ReactterComponent<TestContext> {
  const ReactterComponentTestAll({
    Key? key,
    this.id,
    required this.getInstance,
  }) : super(key: key);

  final void Function(TestContext ctx) getInstance;

  @override
  final String? id;

  @override
  get listenAllHooks => true;

  @override
  get builder => () => TestContext();

  @override
  Widget render(TestContext ctx, BuildContext context) {
    getInstance(ctx);

    return _buildWidget(ctx);
  }
}

Widget _buildWidget(TestContext ctx) {
  return Column(
    children: [
      Text("stateBool: ${ctx.stateBool.value}"),
      Text("stateString: ${ctx.stateString.value}"),
    ],
  );
}
