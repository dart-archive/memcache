// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library memcache.raw;

import "dart:async";

class Status {
  final int _status;
  final String _name;
  static Status NO_ERROR = const Status._(0x0000, 'NO_ERROR');
  static Status KEY_NOT_FOUND = const Status._(0x0001, 'KEY_NOT_FOUND');
  static Status KEY_EXISTS = const Status._(0x0002, 'KEY_EXISTS');
  static Status NOT_STORED = const Status._(0x0005, 'NOT_STORED');
  static Status ERROR = const Status._(0x0084, 'ERROR');

  const Status._(this._status, this._name);

  int get hashCode => _status.hashCode;

  String toString() => 'Status($_name)';
}

/**
 * Low level memcache interface providing access to all details.
 */
abstract class RawMemcache {
  Future<List<GetResult>> get(List<GetOperation> batch);
  Future<List<SetResult>> set(List<SetOperation> batch);
  Future<List<RemoveResult>> remove(List<RemoveOperation> batch);
  Future<List<IncrementResult>> increment(List<IncrementOperation> batch);
  Future clear();
}

class GetOperation {
  final List<int> key;

  GetOperation(this.key);

  String toString() => 'GetOperation(key: $key)';
}

class GetResult {
  final Status status;
  final String message;
  final int flags;
  final int cas;
  final List<int> value;

  GetResult(this.status, this.message, this.flags, this.cas, this.value);

  String toString() =>
      'GetResult(status: $status, message: $message, flags: $flags, '
      'cas: $cas, value: $value)';
}

class SetOperation {
  static const int SET = 0;
  static const int ADD = 1;
  static const int REPLACE = 2;
  static const int CAS = 3;

  final int operation;
  final List<int> key;
  final int flags;
  final int cas;
  final List<int> value;

  SetOperation(this.operation, this.key, this.flags, this.cas, this.value);

  String toString() =>
      'SetOperation(operation: $operation, key: $key, flags: $flags, '
      'cas: $cas, value: $value)';
}

class SetResult {
  final Status status;
  final String message;

  SetResult(this.status, this.message);

  String toString() => 'SetResult(status: $status, message: $message)';
}

class RemoveOperation {
  final List<int> key;

  RemoveOperation(this.key);

  String toString() => 'RemoveOperation(key: $key)';
}

class RemoveResult {
  final Status status;
  final String message;

  RemoveResult(this.status, this.message);

  String toString() => 'RemoveResult(status: $status, message: $message)';
}

class IncrementOperation {
  static const int INCREMENT = 0;
  static const int DECREMENT = 1;

  final List<int> key;
  final int delta;
  final int direction;
  final int initialFlags;
  final int initialValue;

  IncrementOperation(this.key, this.delta, this.direction,
                     this.initialFlags, this.initialValue);

  String toString() =>
      'IncrementOperation(key: $key, delta: $delta, direction: $direction, '
      'initialFlags: $initialFlags, initialValue: $initialValue)';
}

class IncrementResult {
  final Status status;
  final String message;
  final int value;

  IncrementResult(this.status, this.message, this.value);

  String toString() => 'IncrementResult(status: $status, message: $message)';
}
