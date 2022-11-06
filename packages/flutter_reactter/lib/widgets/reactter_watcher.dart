part of '../widgets.dart';

/// A [StatefulWidget] that listens for [Signal]s and re-build when any [Signal] is changed.
///
/// For example:
///
/// ```dart
/// final count = 0.signal;
/// final toggle = false.signal;
///
/// class Example extends StatelessWidget {
///   ...
///   Widget build(context) {
///     return ReactterWatcher(
///       builder: (context, child) {
///         return Column(
///           children: [
///             Text("Count: $count"),
///             Text("Toggle is: $toggle"),
///           ],
///         );
///       },
///     );
///   }
/// }
/// ```
///
/// Build the widget tree with the values of the [Signal]s contained in
/// the [ReactterWatcher] [builder], and with each change of its values,
/// it will re-build the widget tree.
///
/// **CONSIDER** Use [child] property to pass a [Widget] that
/// you want to build it once. The [ReactterWatcher] pass it through
/// the [builder] callback, so you can incorporate it into your build:
///
/// ```dart
/// ReactterWatcher(
///   child: Column(
///     children: [
///       ElevatedButton(
///         onPressed: () => signal.value += 1,
///         child: const Text("Increase +1"),
///       ),
///       ElevatedButton(
///         onPressed: () => toggle(!toggle.value),
///         child: const Text("Toggle"),
///       ),
///     ],
///   ),
///   builder: (context, child) {
///     return Column(
///       children: [
///         Text("Count: $count"),
///         Text("Toggle is: $toggle"),
///         child, // Column with 2 buttons
///       ],
///     );
///   },
/// );
/// ```
///
/// See also:
///
/// * [Signal], a reactive state of any type.
class ReactterWatcher extends StatefulWidget {
  /// Provides a widget , which render one time.
  ///
  /// It's expose on [builder] method as second parameter.
  final Widget? child;

  /// Method which has the render logic
  ///
  /// Exposes [BuilderContext] and [child] widget as parameters.
  /// and returns a widget.
  final TransitionBuilder? builder;

  const ReactterWatcher({
    Key? key,
    this.child,
    this.builder,
  }) : super(key: key);

  @override
  State<ReactterWatcher> createState() => _ReactterWatcherState();
}

class _ReactterWatcherState extends State<ReactterWatcher>
    with ReactterSignalProxy {
  final Set<Signal> _signals = {};

  @override
  Widget build(BuildContext context) {
    _clearSignals();

    ReactterSignalProxy? signalProxyPrev = Reactter.signalProxy;
    Reactter.signalProxy = this;

    final widgetBuit =
        widget.builder?.call(context, widget.child) ?? widget.child!;

    Reactter.signalProxy = signalProxyPrev;

    return widgetBuit;
  }

  @override
  void dispose() {
    _clearSignals();
    super.dispose();
  }

  @override
  void addSignal(Signal signal) {
    Reactter.signalProxy = null;
    if (!_signals.contains(signal)) {
      Reactter.one(signal, Lifecycle.didUpdate, _onSignalDidUpdate);
      _signals.add(signal);
    }
    Reactter.signalProxy = this;
  }

  void _onSignalDidUpdate(_, __) => setState(() {});

  void _clearSignals() {
    for (var signal in _signals) {
      Reactter.off(signal, Lifecycle.didUpdate, _onSignalDidUpdate);
    }
    _signals.clear();
  }
}
