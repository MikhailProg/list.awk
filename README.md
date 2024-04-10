
Double link list in awk. The implementation uses awk multidimensional array as a C-like structure.

With such approach it's possible to model any dynamic data structures e.g lists, binary search tries (balanced and not balanced).

There are a set of functions and unit tests.

```
$ chmod a+x list.awk
$ ./list.awk
Check list is empty                     : PASS
Check first (empty)                     : PASS
Check last (empty)                      : PASS
Check list is not empty (prepend)       : PASS
Check first (prepend)                   : PASS
...
``` 
