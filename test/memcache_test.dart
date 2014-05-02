// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:unittest/unittest.dart';

import '../lib/memcache.dart';
import '../lib/memcache_raw.dart' as raw;
import '../lib/src/memcache_impl.dart';

import 'mock_raw_memcache.dart';

main() {
  var ok = new raw.SetResult(raw.Status.NO_ERROR, null);

  group('memcache', () {
    test('get', () {
      var mock = new MockRawMemcache();
      var memcache = new MemCacheImpl(mock);

      var notFound = new raw.GetResult(
          raw.Status.KEY_NOT_FOUND, 'Not found', 0, null, null);
      var foundB = new raw.GetResult(
          raw.Status.NO_ERROR, 'Not found', 0, null, [66]);

      mock.registerGet(expectAsync((batch) {
        expect(batch.length, 1);
        expect(batch[0].key, [65]);
        return new Future.value([notFound]);
      }, count: 2));

      expect(memcache.get([65]), completion(isNull));
      expect(memcache.get('A'), completion(isNull));

      mock.registerGet(expectAsync((batch) {
        expect(batch.length, 1);
        expect(batch[0].key, [65]);
        return new Future.value([foundB]);
      }, count: 4));

      expect(memcache.get([65], asBinary: true), completion([66]));
      expect(memcache.get([65]), completion('B'));
      expect(memcache.get('A', asBinary: true), completion([66]));
      expect(memcache.get('A'), completion('B'));
    });
  });

  test('get-error', () {
    var mock = new MockRawMemcache();
    var memcache = new MemCacheImpl(mock);

    mock.registerGet(expectAsync((_) {
      return new Future.error(new ArgumentError());
    }, count: 4));

    expect(memcache.get([65], asBinary: true), throwsA(isArgumentError));
    expect(memcache.get([65]), throwsA(isArgumentError));
    expect(memcache.get('A', asBinary: true), throwsA(isArgumentError));
    expect(memcache.get('A'), throwsA(isArgumentError));
  });

  test('get-throws', () {
    var mock = new MockRawMemcache();
    var memcache = new MemCacheImpl(mock);

    mock.registerGet((_) {
      throw new ArgumentError();
    });

    expect(memcache.get([65], asBinary: true), throwsA(isArgumentError));
    expect(memcache.get([65]), throwsA(isArgumentError));
    expect(memcache.get('A', asBinary: true), throwsA(isArgumentError));
    expect(memcache.get('A'), throwsA(isArgumentError));
  });

  test('get-all-throws', () {
    var mock = new MockRawMemcache();
    var memcache = new MemCacheImpl(mock);

    mock.registerGet((_) {
      throw new ArgumentError();
    });

    expect(memcache.getAll(['A', [65]], asBinary: true),
           throwsA(isArgumentError));
  });

  test('set', () {
    var mock = new MockRawMemcache();
    var memcache = new MemCacheImpl(mock);

    mock.registerSet(expectAsync((batch) {
      expect(batch.length, 1);
      expect(batch[0].operation, raw.SetOperation.SET);
      expect(batch[0].key, [65]);
      expect(batch[0].value, [66]);
      return new Future.value([ok]);
    }, count: 4));

    expect(memcache.set([65], [66]), completion(isNull));
    expect(memcache.set('A', [66]), completion(isNull));
    expect(memcache.set([65], 'B'), completion(isNull));
    expect(memcache.set('A', 'B'), completion(isNull));
  });

  testSetAction(action, operation) {
    var mock = new MockRawMemcache();
    var memcache = new MemCacheImpl(mock);

    mock.registerSet(expectAsync((batch) {
      expect(batch.length, 1);
      expect(batch[0].operation, operation);
      expect(batch[0].key, [65]);
      expect(batch[0].value, [66]);
      return new Future.value([ok]);
    }, count: 4));

    expect(memcache.set([65], [66], action: action), completion(isNull));
    expect(memcache.set('A', [66], action: action), completion(isNull));
    expect(memcache.set([65], 'B', action: action), completion(isNull));
    expect(memcache.set('A', 'B', action: action), completion(isNull));
  }

  test('set-action-set', () {
    testSetAction(SetAction.SET, raw.SetOperation.SET);
  });

  test('set-action-add', () {
    testSetAction(SetAction.ADD, raw.SetOperation.ADD);
  });

  test('set-action-replace', () {
    testSetAction(SetAction.REPLACE, raw.SetOperation.REPLACE);
  });

  test('set-error', () {
    var mock = new MockRawMemcache();
    var memcache = new MemCacheImpl(mock);

    mock.registerSet(expectAsync((_) {
      return new Future.error(new ArgumentError());
    }, count: 16));

    expect(memcache.set([65], [66]), throwsA(isArgumentError));
    expect(memcache.set('A', [66]), throwsA(isArgumentError));
    expect(memcache.set([65], 'B'), throwsA(isArgumentError));
    expect(memcache.set('A', 'B'), throwsA(isArgumentError));
    for (var action in [SetAction.SET, SetAction.ADD, SetAction.REPLACE]) {
      expect(memcache.set([65], [66], action: action),
             throwsA(isArgumentError));
      expect(memcache.set('A', [66], action: action), throwsA(isArgumentError));
      expect(memcache.set([65], 'B', action: action), throwsA(isArgumentError));
      expect(memcache.set('A', 'B', action: action), throwsA(isArgumentError));
    }
  });

  test('set-throw', () {
    var mock = new MockRawMemcache();
    var memcache = new MemCacheImpl(mock);

    mock.registerSet((_) {
      throw new ArgumentError();
    });

    expect(memcache.set([65], [66]), throwsA(isArgumentError));
    expect(memcache.set('A', [66]), throwsA(isArgumentError));
    expect(memcache.set([65], 'B'), throwsA(isArgumentError));
    expect(memcache.set('A', 'B'), throwsA(isArgumentError));
    for (var action in [SetAction.SET, SetAction.ADD, SetAction.REPLACE]) {
      expect(memcache.set([65], [66], action: action),
             throwsA(isArgumentError));
      expect(memcache.set('A', [66], action: action), throwsA(isArgumentError));
      expect(memcache.set([65], 'B', action: action), throwsA(isArgumentError));
      expect(memcache.set('A', 'B', action: action), throwsA(isArgumentError));
    }
  });

  var setAllMaps = [
    {'A': 'B', 'CD': 'EF'},
    {'A': [66], [67, 68]: 'EF'},
    {[65]: 'B', 'CD': [69, 70]},
    {[65]: [66], [67, 68]: [69, 70]}
  ];
  var setAllKeys = [[65], [67, 68]];
  var setAllValues = [[66], [69, 70]];

  checkSetAllBatch(batch, operation) {
    expect(batch.length, setAllKeys.length);
    for (var i = 0; i < setAllKeys.length; i++) {
      expect(batch[i].operation, operation);
      expect(batch[i].key, setAllKeys[i]);
      expect(batch[i].value, setAllValues[i]);
    }
  }

  test('set-all', () {
    var mock = new MockRawMemcache();
    var memcache = new MemCacheImpl(mock);

    mock.registerSet(expectAsync((batch) {
      checkSetAllBatch(batch, raw.SetOperation.SET);
      return new Future.value([ok, ok]);
    }, count: setAllMaps.length));

    for (var m in setAllMaps) {
      expect(memcache.setAll(m), completes);
    }
  });

  testSetAllAction(action, operation) {
    var mock = new MockRawMemcache();
    var memcache = new MemCacheImpl(mock);

    mock.registerSet(expectAsync((batch) {
      checkSetAllBatch(batch, operation);
      return new Future.value([ok, ok]);
    }, count: setAllMaps.length));

    for (var m in setAllMaps) {
      expect(memcache.setAll(m, action: action), completes);
    }
  }

  test('set-action-set', () {
    testSetAllAction(SetAction.SET, raw.SetOperation.SET);
  });

  test('set-action-add', () {
    testSetAllAction(SetAction.ADD, raw.SetOperation.ADD);
  });

  test('set-action-replace', () {
    testSetAllAction(SetAction.REPLACE, raw.SetOperation.REPLACE);
  });

  test('set-all-error', () {
    var mock = new MockRawMemcache();
    var memcache = new MemCacheImpl(mock);

    mock.registerSet(expectAsync((_) {
      return new Future.error(new ArgumentError());
    }, count: setAllMaps.length));

    for (var m in setAllMaps) {
      expect(memcache.setAll(m), throwsA(isArgumentError));
    }
  });

  test('set-all-throws', () {
    var mock = new MockRawMemcache();
    var memcache = new MemCacheImpl(mock);

    mock.registerSet((_) {
      throw new ArgumentError();
    });

    for (var m in setAllMaps) {
      expect(memcache.setAll(m), throwsA(isArgumentError));
    }
  });

  test('remove', () {
    var mock = new MockRawMemcache();
    var memcache = new MemCacheImpl(mock);

    mock.registerRemove(expectAsync((batch) {
      expect(batch.length, 1);
      expect(batch[0].key, [65]);
      return new Future.value([ok]);
    }, count: 2));

    expect(memcache.remove([65]), completion(isNull));
    expect(memcache.remove('A'), completion(isNull));
  });

  test('remove-error', () {
    var mock = new MockRawMemcache();
    var memcache = new MemCacheImpl(mock);

    mock.registerRemove(expectAsync((_) {
      return new Future.error(new ArgumentError());
    }));

    expect(memcache.remove([65]), throwsA(isArgumentError));
  });

  test('remove-throw', () {
    var mock = new MockRawMemcache();
    var memcache = new MemCacheImpl(mock);

    mock.registerRemove((_) {
      throw new ArgumentError();
    });

    expect(memcache.remove([65]), throwsA(isArgumentError));
    expect(memcache.remove('A'), throwsA(isArgumentError));
  });

  test('remove-all-throws', () {
    var mock = new MockRawMemcache();
    var memcache = new MemCacheImpl(mock);

    mock.registerRemove((_) {
      throw new ArgumentError();
    });

    expect(memcache.removeAll(['A', [65]]), throwsA(isArgumentError));
  });

  test('clear', () {
    var mock = new MockRawMemcache();
    var memcache = new MemCacheImpl(mock);

    mock.registerClear(expectAsync(() => null, count: 2));

    expect(memcache.clear(), completion(isNull));
    expect(memcache.clear(), completion(isNull));
  });

  test('clear-error', () {
    var mock = new MockRawMemcache();
    var memcache = new MemCacheImpl(mock);

    mock.registerClear(expectAsync(() {
      return new Future.error(new ArgumentError());
    }));

    expect(memcache.clear(), throwsA(isArgumentError));
  });

  test('clear-throw', () {
    var mock = new MockRawMemcache();
    var memcache = new MemCacheImpl(mock);

    mock.registerClear(() {
      throw new ArgumentError();
    });

    expect(memcache.clear(), throwsA(isArgumentError));
  });
}