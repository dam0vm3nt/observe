// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library observe.test.benchmark.observation_benchmark_base;

import 'dart:async';
import 'package:observe/observe.dart';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'test_observable.dart';

abstract class ObservationBenchmarkBase extends BenchmarkBase {
  /// The number of objects to create and observe.
  final int objectCount;

  /// The number of mutations to perform.
  final int mutationCount;

  /// The current configuration.
  final String config;

  /// The number of pending mutations left to observe.
  int mutations;

  /// The objects we want to observe.
  List objects;

  /// The change listeners on all of our objects.
  List<StreamSubscription<List<ChangeRecord>>> observers;

  /// The current object being mutated.
  int objectIndex;

  /// The number of mutations left to be performed.
  int mutationsLeft;

  /// Completes when each benchmark is done.
  Completer done;

  ObservationBenchmarkBase(
      String name, this.objectCount, this.mutationCount, this.config)
      : super(name);

  /// Subclasses should use this method to perform mutations on an object. The
  /// return value indicates how many mutations were performed on the object.
  int mutateObject(TestObservable obj);

  /// Set up each benchmark by creating all the objects and listeners.
  @override
  void setup() {
    mutations = 0;

    objects = [];
    observers = [];
    objectIndex = 0;
    mutationsLeft = mutationCount;
    done = new Completer();

    while(objects.length < objectCount) {
      var obj = new TestObservable();
      objects.add(obj);
      observers.add(obj.changes.listen((List<ChangeRecord> record) {
        mutations--;
        if (mutations == 0) done.complete();
      }));
    }
  }

  /// Tear down each benchmark and make sure that [mutations] is 0.
  @override
  void teardown() {
    objects = null;
    while (observers.isNotEmpty) {
      observers.removeLast().cancel();
    }
    observers = null;
    done = null;
  }

  /// Run the benchmark
  @override
  void run() {
    while (mutationsLeft > 0) {
      var obj = objects[objectIndex];
      mutationsLeft -= mutateObject(obj);
      this.mutations++;
      this.objectIndex++;
      if (this.objectIndex == this.objects.length) {
        this.objectIndex = 0;
      }
    }
    Observable.dirtyCheck();
  }
}
