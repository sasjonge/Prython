# Prython

Prython is a fast and easy-to-use prolog module to run python functions in prolog. It uses the bi-directional Python-Java bridge JPY to call CPython directly.

## Installation

This module depends on the bi-directional Python-Java bridge JPY. To follow this, follow the instructions at

`https://github.com/bcdev/jpy`

(If the newer jpy versions stops working, you can use the fork at `https://github.com/sasjonge/jpy`)

If you don't want to set the path to the jpyconfig.properties after every start, you can change the value in the prython.pl file at:

```
%% py_call_init is det.
%
% Inits the jpy core by setting a system proberty and starting the python interpreter
%
py_call_init(PathToJPYConfig) :-
	py_call_init('/path/to/your/jpy/build/lib.linux-x86_64-2.7/jpyconfig.properties').
```

to your path to the jpyconfig.properties files.

## Usage

Before you can use the python call functions you first need to call `py_call_init`. If you changed the path to the jpyconfig.properties in prython.pl, you only need to call:

```
py_call_init.
``` 

Else you need to specify your path to the jpyconfig.properties:

```
py_call_init('/path/to/your/jpy/build/lib.linux-x86_64-2.7/jpyconfig.properties').
```

To use a python module you need to import it to the JPY python module. An example call would look like this:

```
?- add_py_path('/home/path/to/pythonpackage/scripts').
true.
```

(See in Chapter Better path handling for further ideas how to call this more dynamic).

Now you can call the python functions. There are two predicates to call python functions. The first one is 

`py_call(+Module:string, +FunctionName:string, +Parameter:list, ?ReturnTyped) is semidet.`

, where Module is the name of the python module, FunctionName the name of the function to call and Parameter a list of parameters for the python call. To use this you need to know the path to the python file you want to use. An example call would look like this:

```
?- py_call('test_prython','ret_int',[1,1,5],Return).
Return = 7.

```

If you expect a list as return value, you need to call 

`py_call_base(+PathTo:string, +ScriptName:string, +FunctionName:string, +Parameter:list, +ReturnTypeOfList:string, +ReturnTypeParameterForConstructor:string ?Return) is semidet.`

where ReturnTypeOfList is the type of the Java-List, that is needed to store the python returnvalue. It needs to be an object type like `java.lang.Integer`. ReturnTypeParameterForConstructor is the needed value for the Integer Constructor. For Integer this would be 0.

An example call would look like this:

```
?- py_call('test_prython','ret_list',[1,1,5],'java.lang.Integer',[0],Return).
Return = [1, 1, 5].
```

For further examples have a loke in the test-file prython.plt.

## TODO

### Better path handling

Until now the paths need to be added by a call to a predicate. I am open to ideas on how to handle this better.

An example how i used the module, is by organizing the directory in the following structure:

```
+-- prolog
|   +-- your_prolog_file.pl
+-- scripts
|   +-- your_python_script.py
```

Now I can get the path to the python file automatically like this:

```
source_file(File),
string_concat(Path,'/prython.pl',File),
string_concat(Path,'/../scripts',FullPathStr),
atom_string(FullPath,FullPathStr),
add_py_path(FullPath).
```

### Dicts

Another part that is missing is the handling of dict's as return value. This will be added, but will probably use prolog dicts, which are only available with Prolog 7 and newer.

### Python Objects

With this new version, it should be possible to implement a handling for Python Objects. 

## Speed



## Tests

To run the PLUnit tests:

```prolog
use_module(prython).
load_test_files(prython).
run_tests.
```
