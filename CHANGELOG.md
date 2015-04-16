## 0.2.0

* Added expiration to the RawMemcache API when adding values. Pass the
  expiration from the Memcache implemented on RawMemcache.

* Removed the expiration from the clear method on the Memcache interface. Some
  implementations do not support it.

## 0.1.0

* First release.
