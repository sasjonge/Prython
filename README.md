# Prython

Prython is a prolog module to run python functions in prolog.

## Usage

There are two recommended predicates to call python functions. The first one is 

`py_call(+PathTo:string, +ScriptName:string, +FunctionName:string, +Parameter:list, ?ReturnTyped) is semidet.`

, where PathTo is the path to the python file, ScriptName the name of the python script, FunctionName the name of the function to call and Parameter a list of parameters for the python call. To use this you need to know the path to the python file you want to use. An example call would look like this:

```
?- py_call('/home/sascha/suturo16/prython/scripts','test','ret_num',['9','8','5'],Return).
Return = 22.3123123.
```

Instead of this you cann also use,

`py_call(+ScriptName:string, +FunctionName:string, +Parameter:list, ?ReturnTyped)`

where you don't need to give the path to the script. Instead the path need to be added by using `add_py_path(+Path).`.

An example call would look like this:

```
?- add_py_path('/home/path/to/pythonpackage/scripts').
true.

?- py_call('test','ret_list',['9','8','5'],Return).
Return = [9, 8, 5] 
```

## TODO

### Better path handling

Till now the pathes need to be added by a call to an predicate. I am open for ideas, how to handle this better.

An example how i used the module, is by organizing the directory in the following structure:

```
+-- prolog
|   +-- your_prolog_file.pl
+-- scripts
|   +-- your_python_script.py
```

Now i can get the path to the python file automatically like this:

```
source_file(File),
string_concat(Path,'/your_prolog_file.pl',File),
string_concat(Path,'/../scripts',FullPath)
```

### Dicts

Another part that is missing is the handling of dict's as return value. This will be added, but will probably use prolog dicts, which are only available with Prolog > 7.

## Tests

To run the PLUnit tests:

```prolog
use_module(prython).
load_test_files(prython).
run_tests.
```