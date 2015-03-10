// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library observe.change_detection_list;

import 'dart:async' show Stream, StreamController, scheduleMicrotask;
import 'dart:collection' show ListBase;

/// Represents an list of values. If any items are added, removed, or replaced,
/// then listeners can be notified of the [listChanges].
/// will be notified. Unlike `ObservableList` this version doesn't track
/// what changed in the list, only that it changed.
class ChangeDetectionList<E> extends ListBase<E> {
  /// The controller to notify listeners of changes.
  StreamController _listChanges;

  bool _scheduled = false;

  /// The inner [List<E>] with the actual storage.
  final List<E> _list;

  /// Creates an observable list of the given [length].
  ///
  /// If no [length] argument is supplied an extendable list of
  /// length 0 is created.
  ///
  /// If a [length] argument is supplied, a fixed size list of that
  /// length is created.
  ChangeDetectionList({int length, bool equals(E x, E y)})
      : _list = length != null ? new List<E>(length) : <E>[];

  /// Creates an observable list with the elements of [other]. The order in
  /// the list will be the order provided by the iterator of [other].
  factory ChangeDetectionList.from(Iterable<E> other) =>
      new ChangeDetectionList<E>()..addAll(other);

  /// Notifies asynchronously that a change occurred to the list.
  ///
  /// There is no data associated with a change, it simply passes along this
  /// list object for convenience.
  ///
  /// For example:
  ///
  ///     var list = new ChangeDetectionList<E>();
  ///     list.changed.listen((x) {
  ///       print('The list $x changed!');
  ///     });
  ///     list.addAll([1, 2, 3]);
  ///
  Stream<ChangeDetectionList<E>> get changed {
    if (_listChanges == null) {
      _listChanges = new StreamController.broadcast(sync: true,
          onCancel: () { _listChanges = null; });
    }
    return _listChanges.stream;
  }

  int get length => _list.length;

  set length(int value) {
    int len = _list.length;
    if (len == value) return;
    _notifyChange();
    _list.length = value;
  }

  E operator [](int index) => _list[index];

  void operator []=(int index, E value) {
    if (_list[index] != value) _notifyChange();
    _list[index] = value;
  }

  // Per documentation on ListBase, implementing these improves performance.

  void add(E value) {
    int len = _list.length;
    _notifyChange();
    _list.add(value);
  }

  void addAll(Iterable<E> iterable) {
    int len = _list.length;
    _list.addAll(iterable);
    if (len != _list.length) _notifyChange();
  }

  void _notifyChange() {
    if (_scheduled || _listChanges == null || !_listChanges.hasListener) return;

    _scheduled = true;
    scheduleMicrotask(() {
      _scheduled = false;
      _listChanges.add(this);
    });
  }
}
