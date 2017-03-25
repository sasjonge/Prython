# Prython

Beispiel Function Call:

`run_python_function('/home/sascha/suturo16/prython/scripts','test','ret_num',['9'],Lines).`

Or if you are in the main directory, where /scripts and /prolog are placed, yo can call the function without a path:

`run_python_function('test','ret_num',['9'],Lines).`

## Tests

To run the PLUnit tests:

```prolog
use_module(prython).
use_module(prython).
run_tests.
```