:- begin_tests(prython).
:- use_module('prython').

:- py_call_init,source_file(File),string_concat(Path,'/prython.pl',File),string_concat(Path,'/../scripts',FullPathStr),atom_string(FullPath,FullPathStr),add_py_path(FullPath).

test(py_call_string) :-
        once(py_call('test_prython','ret_str',['Hello World'],'Hello World')).

test(py_call_par_list) :-
        once(py_call('test_prython','ret_concatenated_str',['Hello',' World','!'],'Hello World!')).

test(py_call_float) :-
        once(py_call('test_prython','ret_num',[1,1,1],3.3123123)).

test(py_call_int) :-
        once(py_call('test_prython','ret_int',[1,1,5],7)).

test(py_call_list) :-
        once(py_call('test_prython','ret_list',[1,1,5],[1,1,5])).

test(py_call_nested_list) :-
        once(py_call('test_prython','ret_nested_list',[1,1,5],[[1,1,5],[[1,1,5]]])).

test(py_call_nested_list_as_input) :-
        once(py_call('test_prython','ret_nested_list_as_input',[[[1,1,5],[[1,1,5]]]],[[1,1,5],1])).

:- end_tests(prython).