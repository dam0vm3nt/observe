// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/**
 * Defines an asynchronous benchmark, where each iteration completes
 * asynchronously.
 */
// TODO(sigmund): move this to the same repo where BenchmarkBase is.
library async_benchmark;

import 'dart:async';

/** The superclass from which all benchmarks inherit from. */
class AsyncBenchmark {
  /** Benchmark name. */
  final String name;

  const AsyncBenchmark([this.name]);

  /** The benchmark code, invoked by [warmup] and [exercise]. */
  Future run() => new Future.value(null);

  /** Runs a short version of the benchmark. By default invokes [run] once. */
  Future warmup() => run();

  /** Exercices the benchmark. By default invokes [run] 10 times. */
  Future exercise() {
    int count = 10;
    Future recurse(val) {
      if (count-- <= 0) return new Future.value(val);
      return run().then(recurse);
    }
    return recurse(null);
  }

  /** Not measured setup code executed prior to the benchmark runs. */
  void setup() { }

  /** Not measures teardown code executed after the benchark runs. */
  void teardown() { }

  /**
   * Measures the score for this benchmark by executing it repeately until
   * time minimum has been reached. The result is iterations per sec.
   */
  static Future<double> measureFor(AsyncFunction f, int timeMinimum) {
    int iter = 0;
    var watch = new Stopwatch();
    watch.start();
    Future recurse(val) {
      int elapsed = watch.elapsedMilliseconds;
      if (elapsed < timeMinimum || iter < 32) {
        iter++;
        return f().then(recurse);
      }
      return new Future.value((1000.0 * elapsed) / iter);
    }
    return recurse(null);
  }

  /** Measures and returns the score for the benchmark (bigger is better). */
  Future<double> measure() {
    setup();
    // Warmup for at least 1000ms. Discard result.
    return measureFor(warmup, 1000).then((_) {
      // Run the benchmark for at least 1000ms.
      return measureFor(exercise, 2000).then((result) {
        teardown();
        return result;
      });
    });
  }
}

typedef Future AsyncFunction();
