// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library observe.test.benchmark.index;

import 'dart:async';
import 'dart:html';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:chart/chart.dart';
import 'package:smoke/mirrors.dart';
import 'object_benchmark.dart';
import 'setup_object_benchmark.dart';
import 'array_benchmark.dart';
import 'setup_array_benchmark.dart';
import 'path_benchmark.dart';
import 'setup_path_benchmark.dart';

var benchmarks = {
  'ObjectBenchmark': (int objectCount, int mutationCount, String config) =>
      new ObjectBenchmark(objectCount, mutationCount, config),
  'SetupObjectBenchmark': (int objectCount, int mutationCount, String config) =>
      new SetupObjectBenchmark(objectCount, config),
  'ArrayBenchmark': (int objectCount, int mutationCount, String config) =>
      new ArrayBenchmark(objectCount, mutationCount, config),
  'SetupArrayBenchmark': (int objectCount, int mutationCount, String config) =>
      new SetupArrayBenchmark(objectCount, config),
  'PathBenchmark': (int objectCount, int mutationCount, String config) =>
      new PathBenchmark(objectCount, mutationCount, config),
  'SetupPathBenchmark': (int objectCount, int mutationCount, String config) =>
      new SetupPathBenchmark(objectCount, config),
};
var benchmarkConfigs = {
  'ObjectBenchmark': [],
  'SetupObjectBenchmark': [],
  'ArrayBenchmark': ['splice', 'update', 'push/pop', 'shift/unshift'],
  'SetupArrayBenchmark': [],
  'PathBenchmark': ['leaf', 'root'],
  'SetupPathBenchmark': [],
};
Iterable<int> objectCounts;
Iterable<int> mutationCounts;
var goButton = document.getElementById('go') as ButtonElement;
var objectCountInput =
    document.getElementById('objectCountInput') as InputElement;
var mutationCountInput =
    document.getElementById('mutationCountInput') as InputElement;
var statusSpan = document.getElementById('status') as SpanElement;
var canvaseWrapper = document.getElementById('canvasWrapper') as DivElement;
var benchmarkSelect =
    document.getElementById('benchmarkSelect') as SelectElement;
var configSelect = document.getElementById('configSelect') as SelectElement;
var colors = [
  [0, 0, 255],
  [138, 43, 226],
  [165, 42, 42],
  [100, 149, 237],
  [220, 20, 60],
  [184, 134, 11]
].map((rgb) => 'rgba(' + rgb.join(',') + ',.7)').toList();

main() {
  useMirrors();
  benchmarkSelect.onChange.listen((_) => changeBenchmark());
  changeBenchmark();

  var ul = document.getElementById('legendList') as UListElement;

  goButton.onClick.listen((_) async {
    canvaseWrapper.children.clear();
    goButton.disabled = true;
    goButton.text = 'Running...';
    ul.text = '';
    objectCounts =
        objectCountInput.value.split(',').map((val) => int.parse(val));
    mutationCounts = mutationCountInput.value
        .split(',')
        .map((val) => int.parse(val));

    var i = 0;
    mutationCounts.forEach((count) {
      var li = document.createElement('li');
      li.text = '$count mutations.';
      li.style.color = colors[i];
      ul.append(li);
      i++;
    });

    var results = [];
    for (int objectCount in objectCounts) {
      int x = 0;
      for (int mutationCount in mutationCounts) {
        statusSpan.text = 'Testing: ${objectCount} objects, '
            '$mutationCount mutations';
        // Let the status text render before running the next benchmark.
        await new Future(() {});
        var resultMicros = (benchmarks[benchmarkSelect.value](objectCount,
            mutationCount, configSelect.value) as BenchmarkBase).measure();

        if (results.length <= x) results.add([]);
        results[x].add(resultMicros / 1000);
        x++;
      }
    }

    drawBenchmarks(results);
  });
}

void drawBenchmarks(List<List<double>> results) {
  var datasets = [];
  var x = 0;
  for (List<int> times in results) {
    datasets.add({
      'fillColor': 'rgba(255, 255, 255, 0)',
      'strokeColor': colors[x],
      'pointColor': colors[x],
      'pointStrokeColor': "#fff",
      'data': times
    });
    x++;
  }
  var data = {
    'labels': objectCounts.map((c) => '$c').toList(),
    'datasets': datasets,
  };

  new Line(data, {'bezierCurve': false,}).show(canvaseWrapper);
  goButton.disabled = false;
  goButton.text = 'Run Benchmarks';
  statusSpan.text = '';
}

void changeBenchmark() {
  var configs = benchmarkConfigs[benchmarkSelect.value];
  configSelect.text = '';
  configs.forEach((config) {
    var option = document.createElement('option');
    option.text = config;
    configSelect.append(option);
  });
  document.title = benchmarkSelect.value;
}
