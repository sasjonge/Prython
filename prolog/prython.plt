:- begin_tests(prython).
:- use_module('prython').

:- source_file(File),string_concat(Path,'/prython.pl',File),string_concat(Path,'/../scripts',FullPath),add_py_path(FullPath).

test(py_call_string) :-
        once(py_call('test','ret_str',[],'Hello World')).

test(py_call_float) :-
        once(py_call('test','ret_num',[1,1,1],3.3123123)).

test(py_call_int) :-
        once(py_call('test','ret_int',[1,1,5],7)).

test(py_call_list) :-
        once(py_call('test','ret_list',[1,1,5],[1,1,5])).

:- end_tests(prython).