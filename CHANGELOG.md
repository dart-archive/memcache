## 0.3.0

* Update code for Dart 2.

## 0.2.2

* Ignore exceptions when closing connection in error state.

## 0.2.1+2

* Fix bug in [Memcache.get] to throw an exception if we a get operation resulted
  in neither found/not-found but rather in an error (i.e. if the tcp connection
  is fine, but the server returns an error instead found/not-found).

## 0.2.1+1

* Added [Memcache.fromRaw] constructor.

## 0.2.1

* Added [BinaryMemcacheProtocol] which implements the [RawMemcache] API.

* Fix bugs in the [MemCacheNativeConnection] which used typed-data views
  incorrectly.

* Switch from `package:unittest` to `package:test`.

## 0.2.0

* Added expiration to the RawMemcache API when adding values. Pass the
  expiration from the Memcache implemented on RawMemcache.

* Removed the expiration from the clear method on the Memcache interface. Some
  implementations do not support it.

## 0.1.0

* First release.
