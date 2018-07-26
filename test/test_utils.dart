// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:memcache/memcache.dart';
import 'package:test/test.dart';

const isMemcacheError = const TypeMatcher<MemcacheError>();
const isMemcacheNotStored = const TypeMatcher<NotStoredError>();
const isMemcacheModifiedError = const TypeMatcher<ModifiedError>();
