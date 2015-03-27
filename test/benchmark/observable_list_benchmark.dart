// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library observe.test.benchmark.observable_list_benchmark;

import 'package:observe/observe.dart';
import 'observation_benchmark_base.dart';

class ObservableListBenchmark extends ObservationBenchmarkBase {
  final int elementCount = 100;

  ObservableListBenchmark(int objectCount, int mutationCount, String config) : super(
          'ArrayBenchmark:$objectCount:$mutationCount:$config', objectCount,
          mutationCount, config);

  @override
  int mutateObject(ObservableList obj) {
    switch (config) {
      case 'update':
        var size = (elementCount / 10).floor();
        for (var j = 0; j < size; j++) {
          obj[j * size]++;
        }
        return size;

      case 'splice':
        var size = (elementCount / 5).floor();
        // No splice equivalent in dart, so we hardcode it.
        var removed = [];
        for (int i = 0; i < size; i++) {
          removed.add(obj.removeAt(i + size));
        }
        for (int i = 0; i < size; i++) {
          obj.insert(size * 2, removed.removeAt(0));
        }
        return size * 2;

      case 'push/pop':
        var val = obj.removeLast();
        obj.add(val + 1);
        return 2;

      case 'shift/unshift':
        var val = obj.removeAt(0);
        obj.insert(0, val + 1);
        return 2;

      default:
        throw new ArgumentError('Invalid config for ArrayBenchmark: $config');
    }
  }

  @override
  ObservableList newObject() {
    var list = new ObservableList();
    for (int i = 0; i < elementCount; i++) {
      list.add(i);
    }
    return list;
  }
}
