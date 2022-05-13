enum LifeCycleEvent { willMount, didMount, willUpdate, didUpdate, willUnmount }

/// Provides a life cycle manager
mixin ReactterLifeCycle {
  /// Stores all events of life cycle with the callbacks
  final Map<LifeCycleEvent, List<Function>> _events = {};

  /// Fires the event of type and executes the callbacks
  void executeEvent(LifeCycleEvent type) {
    for (final callback in _events[type] ?? []) {
      callback();
    }
  }

  /// Save a callback on [willMount] event.
  ///
  /// This event will trigger before the [ReactterContext] instance will mount in the tree by [ReactterProvider].
  void Function() onWillMount(Function callback) =>
      _onLifeCycleEvent(LifeCycleEvent.willMount, callback);

  /// Save a callback on [didMount] event.
  ///
  /// This event will trigger after the [ReactterContext] instance did mount in the tree by [ReactterProvider].
  void Function() onDidMount(Function callback) =>
      _onLifeCycleEvent(LifeCycleEvent.didMount, callback);

  /// Save a callback on [willUpdate] event.
  ///
  /// This event will trigger before the [ReactterContext] instance will update by any [ReactterHook].
  void Function() onWillUpdate(Function callback) =>
      _onLifeCycleEvent(LifeCycleEvent.willUpdate, callback);

  /// Save a callback on [didUpdate] event.
  ///
  /// This event will trigger after the [ReactterContext] instance did update by any [ReactterHook].
  void Function() onDidUpdate(Function callback) =>
      _onLifeCycleEvent(LifeCycleEvent.didUpdate, callback);

  /// Save a callback on [willUnmount] event.
  ///
  /// This event will trigger before the [ReactterContext] instance will unmount in the tree by [ReactterProvider].
  void Function() onWillUnmount(Function callback) =>
      _onLifeCycleEvent(LifeCycleEvent.willUnmount, callback);

  _onLifeCycleEvent(LifeCycleEvent event, Function callback) {
    _events[event] ??= [];
    _events[event]?.add(callback);

    return () => _events[event]?.remove(callback);
  }
}
