// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:observe/change_detection_list.dart';
import 'package:unittest/unittest.dart';

main() {
  // TODO(jmesserly): need all standard List API tests.

  group('ChangeDetectionList', () {

    ChangeDetectionList list;
    int changed;
    StreamSubscription sub;

    setUp(() {
      list = new ChangeDetectionList.from([1, 2, 3]);
      changed = 0;
      sub = list.changed.listen((_) {
        changed++;
      });
    });

    tearDown(() {
      sub.cancel();
    });

    test('add', () {
      list.add(4);
      expect(list, [1, 2, 3, 4]);
      return new Future(() {
        expect(changed, 1);
      });
    });

    test('removeObject', () {
      list.remove(2);
      expect(list, orderedEquals([1, 3]));

      return new Future(() {
        expect(changed, 1);
      });
    });

    test('removeRange', () {
      list.add(4);
      list.removeRange(1, 3);
      expect(list, [1, 4]);
      return new Future(() {
        expect(changed, 1);
      });
    });

    test('length=', () {
      list.length = 5;
      expect(list, [1, 2, 3, null, null]);
      return new Future(() {
        expect(changed, 1);
      });
    });

    test('[]= with new value', () {
      list[2] = 9000;
      expect(list, [1, 2, 9000]);
      return new Future(() {
        expect(changed, 1);
      });
    });

    test('[]= with same value', () {
      list[2] = 3;
      expect(list, [1, 2, 3]);
      return new Future(() {
        expect(changed, 0);
      });
    });

    test('clear', () {
      list.clear();
      expect(list, []);
      return new Future(() {
        expect(changed, 1);
      });
    });

    test('set multiple times results in one change', () {
      list[1] = 777;
      list[1] = 42;
      expect(list, [1, 42, 3]);
      return new Future(() {
        expect(changed, 1);
      });
    });

    test('set length without truncating item means no change', () {
      list.length = 3;
      expect(list, [1, 2, 3]);
      return new Future(() {
        expect(changed, 0);
      });
    });

    test('truncate removes item', () {
      list.length = 1;
      expect(list, [1]);
      return new Future(() {
        expect(changed, 1);
      });
    });

    test('truncate and add new item', () {
      list.length = 1;
      list.add(42);
      expect(list, [1, 42]);
      return new Future(() {
        expect(changed, 1);
      });
    });

    test('truncate and add same item', () {
      list.length = 1;
      list.add(2);
      expect(list, [1, 2]);
      return new Future(() {
        expect(changed, 1);
      });
    });

    test('toString', () {
      expect(list.toString(), '[1, 2, 3]');
      return new Future(() {
        expect(changed, 0);
      });
    });
  });
}
