// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library memcache;

import "dart:async";

import "memcache_raw.dart" show Status;

/**
 * General memcache exception.
 */
class MemcacheError implements Exception {
  final Status status;
  final String message;

  MemcacheError(this.status, this.message);

  String toString() => 'MemcacheError(status: $status, message: $message';
}

/**
 * Exception thrown by [Memcache.set] if the item was not stored.
 */
class NotStored extends MemcacheError {
  NotStored(message) : super(null, message);

  String toString(){
    return 'Memcache item was not stored' + (message != null ? message : '');
  }
}

/**
 * Access to the memcache service.
 *
 * The memcache service provides a shared cache organized as a map from keys
 * to values where both keys and values are binary values
 * (i.e. list of bytes). For each entry in the cache an expiry time can be set
 * to ensure the item is evicted from the cache after a given interval or at
 * a specific point in time. The cache has a limited size, so items can be
 * evicted by the service at any point in time, typically using a LRU-policy.
 *
 * The key value used in memcache is a binary value with a maximim length of
 * 250 bytes.
 *
 * The values stored in memcache are binary values. The maximum size for a
 * value depends on the configuration of the memcache service. The most common
 * default is 1M (one megabyte).
 *
 * In all cases where a key is passed it can be of type `List<int>` or of
 * type `String`. In the case of `List<int>` the key value is passed directly
 * to the memcached. In the case of a `String` the key value is converted into
 * bytes by using the UTF-8 encoding. Note that when combining both types of
 * in an application a key of one type can alias a key of the other type. E.g.
 * the keys `[64]` and `'A'` are the same key.
 *
 * When the type `List<int>` is used note the values are bytes and each value
 * in the list must be in the range [0..255]. Using the class `Uint8List`
 * from `dart:typed_data`provides a compact and efficient represetation.
 */
abstract class Memcache {
  /**
   * Retreives a value from the memcache.
   *
   * If the value is not found the future completes with `null`.
   *
   * If the value is found the value of [asBinary] determins the type of
   * the value the future completes with. If [asBinary] is `false` (the
   * default) the future completes with a `String`. Otherwise the future
   * completes with a list of bytes.
   *
   * The internal representation in the memcache is binary. When a `String` is
   * returned it uses a UTF-8 decoder to produce a `String`.
   */
  Future get(Object key, {bool asBinary: false});

  /**
   * Retreives multiple values from the memcache.
   *
   * The values are returned in a map where the keys are the same instances
   * as where passed in the [keys] argument.
   */
  Future<Map> getAll(Iterable keys, {bool asBinary: false});

  /**
   * Sets the value for a key in the memcache. The value is set
   * Unconditionally.
   *
   * If [expiration] is not set the value is set without
   * any explicit lifetime. The [expiration] cannot exceed 30 days.
   *
   * If [action] is sert to [SetAction.SET] (the default) the
   * value is set unconditionally in the memcache. That is, if the key does not
   * already exist it is created and if the key already exists its current
   * value is overwritten.
   * The value [SetAction.ADD] is used to indicate that the value will only be
   * set if the key was not in the mamcache already. The value
   * [SetAction.REPLACE] is used to indicate that the value will only be set
   * if the key was already in the memcache.
   *
   * The key and value can have type `String` or `List<int>`. When a `String`
   * is used for either key or value a UTF-8 encoder is used to produce the
   * binary value which is stored in the memecache.
   *
   *     Memcache m = ...;
   *     m.set('mykey', 'myvalue');
   *     m.set([0, 1, 2], [3, 4, 5], expiration: new Duration(hours: 1));
   */
  Future set(key, value,
             {Duration expiration, SetAction action: SetAction.SET});

  /**
   * Sets multiple values in the memcache.
   *
   * The value passed can have type `String`, `List<int>` or `Value`
   *
   *     Memcache m = ...;
   *     m.setMultiple(
   *         {'mykey': 'myvalue',
   *          [0, 1, 2]: [3, 4, 5]
   *         });
   *
   * The values passed for [expiration] and [action] are applied to all values
   * set.
   *
   * See [set] for information on [expiration] and [action].
   *
   * Note that memcache is not transactional, so it this operation fails some
   * of the updates might still have succeeded.
   */
  Future setAll(Map keysAndValues,
                {Duration expiration, SetAction action: SetAction.SET});

  /**
   * Removes the key from the memcache.
   */
  Future remove(key);

  /**
   * Removes all the keys in [keys] from the memcache.
   *
   * Note that memcache is not transactional, so if this operation fails some
   * of the keys might still have been removed.
   */
  Future removeAll(Iterable keys);

  /**
   * Delete all items in the cache.
   *
   * If [expiration] is set the flushing of the cache will happen after that
   * duration has passed.
   */
  Future clear({Duration expiration});
}

class SetAction {
  final int _action;
  final String _name;
  static const SetAction SET = const SetAction._(0, "SET");
  static const SetAction ADD = const SetAction._(1, "ADD");
  static const SetAction REPLACE = const SetAction._(2, "REPLACE");

  const SetAction._(this._action, this._name);

  int get hashCode => _action.hashCode;

  String oString() => 'SetAction($_name)';
}