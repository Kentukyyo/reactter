library reactter;

import 'package:flutter/material.dart';
import '../core/reactter_hook.dart';
import '../core/reactter_hook_manager.dart';
import '../core/reactter_types.dart';
import '../hooks/reactter_use_effect.dart';
import 'reactter_use_state.dart';

enum UseAsyncStateStatus {
  standby,
  loading,
  done,
  error,
}

/// Has the same functionality of [UseState] but providing a [asyncValue]
/// which sets [value] when [resolve] method is called
///
/// This example produces one simple [UseAsyncState] :
///
/// ```dart
/// late final userName = UseAsyncState<String>(
///   "My username",
///   () async => await api.getUserName(),
///   this,
/// );
/// ```
///
/// It also has [when] method that returns a widget depending on the state of the hook.
/// for example:
///
/// ```dart
/// userName.when(
///   standby: (value) => Text("Standby: ${value}"),
///   loading: () => const CircularProgressIndicator(),
///   done: (value) => Text(value),
///   error: (error) => const Text("Unhandled exception: ${error}"),
/// );
/// ```
class UseAsyncState<T, A> extends ReactterHook {
  ReactterHookManager? context;

  /// Works as a the [value] initializer.
  /// Need to call [resolve] to execute.
  final AsyncFunction<T, A> asyncValue;

  T get value => _value.value;
  Object? get error => _error.value;
  UseAsyncStateStatus get status => _status.value;

  final T _initial;
  late final _value = UseState<T>(_initial, this);
  late final _error = UseState<Object?>(null, this);
  late final _status = UseState(UseAsyncStateStatus.standby, this);

  UseAsyncState(
    initial,
    this.asyncValue, [
    this.context,
  ])  : _initial = initial,
        super(context) {
    context?.listenHooks([this]);

    UseEffect(() {
      _status.value = UseAsyncStateStatus.done;
    }, [_value]);

    UseEffect(() {
      if (_error.value != null) {
        _status.value = UseAsyncStateStatus.error;
      }
    }, [_error]);
  }

  /// Execute [asyncValue] to resolve [value].
  Future<T?> resolve([A? arg]) async {
    _status.value = UseAsyncStateStatus.loading;

    try {
      if (arg == null && null is! A) {
        return _value.value = await asyncValue();
      }

      return _value.value = await asyncValue(arg as A);
    } catch (e) {
      _error.value = e;

      return null;
    }
  }

  /// Reset [value] to his initial value.
  void reset() {
    _value.reset();
    _error.reset();
    _status.reset();
  }

  /// React when the [value] change and re-render the widget depending of the state.
  ///
  /// `standby`: When the state has the initial value.
  /// `loading`: When the request for the state is retrieving the value.
  /// `done`: When the request is done.
  /// `error`: If any errors happens in the request.
  ///
  /// For example:
  ///
  /// ```dart
  /// userContext.userName.when(
  ///   standby: (value) => Text("Standby: ${value}"),
  ///   loading: () => const CircularProgressIndicator(),
  ///   done: (value) => Text(value),
  ///   error: (error) => const Text("Unhandled exception: ${error}"),
  /// )
  /// ```
  Widget when({
    WidgetCreatorValue<T>? standby,
    WidgetCreator? loading,
    WidgetCreatorValue<T>? done,
    WidgetCreatorErrorHandler? error,
  }) {
    if (status == UseAsyncStateStatus.error) {
      return error?.call(this.error) ?? const SizedBox.shrink();
    }

    if (status == UseAsyncStateStatus.loading) {
      return loading?.call() ?? const SizedBox.shrink();
    }

    if (status == UseAsyncStateStatus.done) {
      return done?.call(value) ?? const SizedBox.shrink();
    }

    return standby?.call(value) ?? const SizedBox.shrink();
  }
}
