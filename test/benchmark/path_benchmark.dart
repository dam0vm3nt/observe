// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library observe.test.benchmark.path_benchmark;

import 'package:observe/observe.dart';
import 'observation_benchmark_base.dart';
import 'test_path_observable.dart';

class PathBenchmark extends ObservationBenchmarkBase {
  final bool leaf;
  final PropertyPath path = new PropertyPath('foo.bar.baz');
  final PropertyPath firstPathProp = new PropertyPath('foo');

  PathBenchmark(int objectCount, int mutationCount, String config)
      : super('PathBenchmark:$objectCount:$mutationCount:$config', objectCount,
          mutationCount, config),
        leaf = config == 'leaf';

  @override
  int mutateObject(TestPathObservable obj) {
    var val = path.getValueFrom(obj);
    if (leaf) {
      path.setValueFrom(obj, val + 1);
    } else {
      firstPathProp.setValueFrom(obj, new Foo(val + 1));
    }

    return 1;
  }

  @override
  TestPathObservable newObject() => new TestPathObservable(1);

  @override
  PathObserver newObserver(TestPathObservable obj) =>
      new PathObserver(obj, path)..open((_) => mutations--);
}
