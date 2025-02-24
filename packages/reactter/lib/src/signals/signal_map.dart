// coverage:ignore-file
part of '../signals.dart';

extension SignalMapExt<K, V> on Signal<Map<K, V>> {
  /// Associates the [key] with the given [value].
  ///
  /// If the key was already in the map, its associated value is changed.
  /// Otherwise the key/value pair is added to the map.
  void operator []=(K key, V valueToSet) =>
      update((_) => value[key] = valueToSet);

  /// Adds all key/value pairs of [newEntries] to this map.
  ///
  /// If a key of [newEntries] is already in this map,
  /// the corresponding value is overwritten.
  ///
  /// The operation is equivalent to doing `this[entry.key] = entry.value`
  /// for each [MapEntry] of the iterable.
  /// ```dart
  /// final planets = <int, String>{1: 'Mercury', 2: 'Venus',
  ///   3: 'Earth', 4: 'Mars'};
  /// final gasGiants = <int, String>{5: 'Jupiter', 6: 'Saturn'};
  /// final iceGiants = <int, String>{7: 'Uranus', 8: 'Neptune'};
  /// planets.addEntries(gasGiants.entries);
  /// planets.addEntries(iceGiants.entries);
  /// print(planets);
  /// // {1: Mercury, 2: Venus, 3: Earth, 4: Mars, 5: Jupiter, 6: Saturn,
  /// //  7: Uranus, 8: Neptune}
  /// ```
  void addEntries(Iterable<MapEntry<K, V>> newEntries) =>
      update((_) => value.addEntries(newEntries));

  /// Updates the value for the provided [key].
  ///
  /// Returns the new value associated with the key.
  ///
  /// If the key is present, invokes [update] with the current value and stores
  /// the new value in the map.
  ///
  /// If the key is not present and [ifAbsent] is provided, calls [ifAbsent]
  /// and adds the key with the returned value to the map.
  ///
  /// If the key is not present, [ifAbsent] must be provided.
  /// ```dart
  /// final planetsFromSun = <int, String>{1: 'Mercury', 2: 'unknown',
  ///   3: 'Earth'};
  /// // Update value for known key value 2.
  /// planetsFromSun.update(2, (value) => 'Venus');
  /// print(planetsFromSun); // {1: Mercury, 2: Venus, 3: Earth}
  ///
  /// final largestPlanets = <int, String>{1: 'Jupiter', 2: 'Saturn',
  ///   3: 'Neptune'};
  /// // Key value 8 is missing from list, add it using [ifAbsent].
  /// largestPlanets.update(8, (value) => 'New', ifAbsent: () => 'Mercury');
  /// print(largestPlanets); // {1: Jupiter, 2: Saturn, 3: Neptune, 8: Mercury}
  /// ```
  V updateMap(K key, V fnUpdate(V value), {V ifAbsent()?}) {
    late V _result;
    update(
      (_) => _result = value.update(
        key,
        fnUpdate,
        ifAbsent: ifAbsent,
      ),
    );
    return _result;
  }

  /// Updates all values.
  ///
  /// Iterates over all entries in the map and updates them with the result
  /// of invoking [update].
  /// ```dart
  /// final terrestrial = <int, String>{1: 'Mercury', 2: 'Venus', 3: 'Earth'};
  /// terrestrial.updateAll((key, value) => value.toUpperCase());
  /// print(terrestrial); // {1: MERCURY, 2: VENUS, 3: EARTH}
  /// ```
  void updateAll(V fnUpdate(K key, V value)) =>
      update((_) => value.updateAll(fnUpdate));

  /// Removes all entries of this map that satisfy the given [test].
  /// ```dart
  /// final terrestrial = <int, String>{1: 'Mercury', 2: 'Venus', 3: 'Earth'};
  /// terrestrial.removeWhere((key, value) => value.startsWith('E'));
  /// print(terrestrial); // {1: Mercury, 2: Venus}
  /// ```
  void removeWhere(bool test(K key, V value)) =>
      update((_) => value.removeWhere(test));

  /// Look up the value of [key], or add a new entry if it isn't there.
  ///
  /// Returns the value associated to [key], if there is one.
  /// Otherwise calls [ifAbsent] to get a new value, associates [key] to
  /// that value, and then returns the new value.
  /// ```dart
  /// final diameters = <num, String>{1.0: 'Earth'};
  /// final otherDiameters = <double, String>{0.383: 'Mercury', 0.949: 'Venus'};
  ///
  /// for (final item in otherDiameters.entries) {
  ///   diameters.putIfAbsent(item.key, () => item.value);
  /// }
  /// print(diameters); // {1.0: Earth, 0.383: Mercury, 0.949: Venus}
  ///
  /// // If the key already exists, the current value is returned.
  /// final result = diameters.putIfAbsent(0.383, () => 'Random');
  /// print(result); // Mercury
  /// print(diameters); // {1.0: Earth, 0.383: Mercury, 0.949: Venus}
  /// ```
  /// Calling [ifAbsent] must not add or remove keys from the map.
  V putIfAbsent(K key, V ifAbsent()) {
    late V _result;
    update((_) => _result = value.putIfAbsent(key, ifAbsent));
    return _result;
  }

  /// Adds all key/value pairs of [other] to this map.
  ///
  /// If a key of [other] is already in this map, its value is overwritten.
  ///
  /// The operation is equivalent to doing `this[key] = value` for each key
  /// and associated value in other. It iterates over [other], which must
  /// therefore not change during the iteration.
  /// ```dart
  /// final planets = <int, String>{1: 'Mercury', 2: 'Earth'};
  /// planets.addAll({5: 'Jupiter', 6: 'Saturn'});
  /// print(planets); // {1: Mercury, 2: Earth, 5: Jupiter, 6: Saturn}
  /// ```
  void addAll(Map<K, V> other) => update((_) => value.addAll(other));

  /// Removes [key] and its associated value, if present, from the map.
  ///
  /// Returns the value associated with `key` before it was removed.
  /// Returns `null` if `key` was not in the map.
  ///
  /// Note that some maps allow `null` as a value,
  /// so a returned `null` value doesn't always mean that the key was absent.
  /// ```dart
  /// final terrestrial = <int, String>{1: 'Mercury', 2: 'Venus', 3: 'Earth'};
  /// final removedValue = terrestrial.remove(2); // Venus
  /// print(terrestrial); // {1: Mercury, 3: Earth}
  /// ```
  V? remove(Object? key) {
    late V? _result;
    update((_) => _result = value.remove(key));
    return _result;
  }

  /// Removes all entries from the map.
  ///
  /// After this, the map is empty.
  /// ```dart
  /// final planets = <int, String>{1: 'Mercury', 2: 'Venus', 3: 'Earth'};
  /// planets.clear(); // {}
  /// ```
  void clear() => update((_) => value.clear());
}

extension SignalMapNullExt<K, V> on Signal<Map<K, V>?> {
  /// Associates the [key] with the given [value].
  ///
  /// If the key was already in the map, its associated value is changed.
  /// Otherwise the key/value pair is added to the map.
  void operator []=(K key, V valueToSet) {
    if (value == null) return null;
    update((_) => value?[key] = valueToSet);
  }

  /// Adds all key/value pairs of [newEntries] to this map.
  ///
  /// If a key of [newEntries] is already in this map,
  /// the corresponding value is overwritten.
  ///
  /// The operation is equivalent to doing `this[entry.key] = entry.value`
  /// for each [MapEntry] of the iterable.
  /// ```dart
  /// final planets = <int, String>{1: 'Mercury', 2: 'Venus',
  ///   3: 'Earth', 4: 'Mars'};
  /// final gasGiants = <int, String>{5: 'Jupiter', 6: 'Saturn'};
  /// final iceGiants = <int, String>{7: 'Uranus', 8: 'Neptune'};
  /// planets.addEntries(gasGiants.entries);
  /// planets.addEntries(iceGiants.entries);
  /// print(planets);
  /// // {1: Mercury, 2: Venus, 3: Earth, 4: Mars, 5: Jupiter, 6: Saturn,
  /// //  7: Uranus, 8: Neptune}
  /// ```
  void addEntries(Iterable<MapEntry<K, V>> newEntries) {
    if (value == null) return null;
    update((_) => value!.addEntries(newEntries));
  }

  /// Updates the value for the provided [key].
  ///
  /// Returns the new value associated with the key.
  ///
  /// If the key is present, invokes [update] with the current value and stores
  /// the new value in the map.
  ///
  /// If the key is not present and [ifAbsent] is provided, calls [ifAbsent]
  /// and adds the key with the returned value to the map.
  ///
  /// If the key is not present, [ifAbsent] must be provided.
  /// ```dart
  /// final planetsFromSun = <int, String>{1: 'Mercury', 2: 'unknown',
  ///   3: 'Earth'};
  /// // Update value for known key value 2.
  /// planetsFromSun.update(2, (value) => 'Venus');
  /// print(planetsFromSun); // {1: Mercury, 2: Venus, 3: Earth}
  ///
  /// final largestPlanets = <int, String>{1: 'Jupiter', 2: 'Saturn',
  ///   3: 'Neptune'};
  /// // Key value 8 is missing from list, add it using [ifAbsent].
  /// largestPlanets.update(8, (value) => 'New', ifAbsent: () => 'Mercury');
  /// print(largestPlanets); // {1: Jupiter, 2: Saturn, 3: Neptune, 8: Mercury}
  /// ```
  V? updateMap(K key, V fnUpdate(V value), {V ifAbsent()?}) {
    if (value == null) return null;
    late V _result;
    update(
      (_) => _result = value!.update(
        key,
        fnUpdate,
        ifAbsent: ifAbsent,
      ),
    );
    return _result;
  }

  /// Updates all values.
  ///
  /// Iterates over all entries in the map and updates them with the result
  /// of invoking [update].
  /// ```dart
  /// final terrestrial = <int, String>{1: 'Mercury', 2: 'Venus', 3: 'Earth'};
  /// terrestrial.updateAll((key, value) => value.toUpperCase());
  /// print(terrestrial); // {1: MERCURY, 2: VENUS, 3: EARTH}
  /// ```
  void updateAll(V fnUpdate(K key, V value)) {
    if (value == null) return null;
    update((_) => value!.updateAll(fnUpdate));
  }

  /// Removes all entries of this map that satisfy the given [test].
  /// ```dart
  /// final terrestrial = <int, String>{1: 'Mercury', 2: 'Venus', 3: 'Earth'};
  /// terrestrial.removeWhere((key, value) => value.startsWith('E'));
  /// print(terrestrial); // {1: Mercury, 2: Venus}
  /// ```
  void removeWhere(bool test(K key, V value)) {
    if (value == null) return null;
    update((_) => value!.removeWhere(test));
  }

  /// Look up the value of [key], or add a new entry if it isn't there.
  ///
  /// Returns the value associated to [key], if there is one.
  /// Otherwise calls [ifAbsent] to get a new value, associates [key] to
  /// that value, and then returns the new value.
  /// ```dart
  /// final diameters = <num, String>{1.0: 'Earth'};
  /// final otherDiameters = <double, String>{0.383: 'Mercury', 0.949: 'Venus'};
  ///
  /// for (final item in otherDiameters.entries) {
  ///   diameters.putIfAbsent(item.key, () => item.value);
  /// }
  /// print(diameters); // {1.0: Earth, 0.383: Mercury, 0.949: Venus}
  ///
  /// // If the key already exists, the current value is returned.
  /// final result = diameters.putIfAbsent(0.383, () => 'Random');
  /// print(result); // Mercury
  /// print(diameters); // {1.0: Earth, 0.383: Mercury, 0.949: Venus}
  /// ```
  /// Calling [ifAbsent] must not add or remove keys from the map.
  V? putIfAbsent(K key, V ifAbsent()) {
    if (value == null) return null;
    late V _result;
    update((_) => _result = value!.putIfAbsent(key, ifAbsent));
    return _result;
  }

  /// Adds all key/value pairs of [other] to this map.
  ///
  /// If a key of [other] is already in this map, its value is overwritten.
  ///
  /// The operation is equivalent to doing `this[key] = value` for each key
  /// and associated value in other. It iterates over [other], which must
  /// therefore not change during the iteration.
  /// ```dart
  /// final planets = <int, String>{1: 'Mercury', 2: 'Earth'};
  /// planets.addAll({5: 'Jupiter', 6: 'Saturn'});
  /// print(planets); // {1: Mercury, 2: Earth, 5: Jupiter, 6: Saturn}
  /// ```
  void addAll(Map<K, V> other) {
    if (value == null) return null;
    update((_) => value!.addAll(other));
  }

  /// Removes [key] and its associated value, if present, from the map.
  ///
  /// Returns the value associated with `key` before it was removed.
  /// Returns `null` if `key` was not in the map.
  ///
  /// Note that some maps allow `null` as a value,
  /// so a returned `null` value doesn't always mean that the key was absent.
  /// ```dart
  /// final terrestrial = <int, String>{1: 'Mercury', 2: 'Venus', 3: 'Earth'};
  /// final removedValue = terrestrial.remove(2); // Venus
  /// print(terrestrial); // {1: Mercury, 3: Earth}
  /// ```
  V? remove(Object? key) {
    if (value == null) return null;
    late V? _result;
    update((_) => _result = value!.remove(key));
    return _result;
  }

  /// Removes all entries from the map.
  ///
  /// After this, the map is empty.
  /// ```dart
  /// final planets = <int, String>{1: 'Mercury', 2: 'Venus', 3: 'Earth'};
  /// planets.clear(); // {}
  /// ```
  void clear() {
    if (value == null) return null;
    update((_) => value!.clear());
  }
}
