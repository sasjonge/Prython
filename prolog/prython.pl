run_python_script(PathTo,ScriptName,Option,Lines):-
	string_concat(PathTo,ScriptName,Script),
    setup_call_cleanup(
    process_create(path(python),[Script,Option],[stdout(pipe(Out))]),
    read_lines(Out,Str_Lines),
    close(Out)).

run_python_script(ScriptName,Option,Lines) :-
	run_python('scripts/',ScriptName,Option,Lines).

run_python_function(PathTo,ScriptName,FunctionName,Parameter,Lines):-
	working_directory(OldPath,PathTo),
	string_concat('import ',ScriptName,Temp1),
	string_concat(Temp1,'; ret = ',Temp2),
	string_concat(Temp2,ScriptName,Temp3),
	string_concat(Temp3,'.',Temp4),
	string_concat(Temp4,FunctionName,Temp5),
	string_concat(Temp5,'(',Temp6),
	atomic_list_concat(Parameter,',',Clist),
	atom_string(Clist,ParameterString),
	string_concat(Temp6,ParameterString,Temp7),
	string_concat(Temp7,'); print str(ret)',CallArgu),
	setup_call_cleanup(
    process_create(path(python),['-c', CallArgu],[stdout(pipe(Out))]),
    read_lines(Out,Lines),
    close(Out)),
    working_directory(_,OldPath).

run_python_function(ScriptName,FunctionName,Parameter,Lines):-
	run_python_function('scripts/',ScriptName,FunctionName,Parameter,Lines).

read_lines(Out, Lines) :-
        read_line_to_codes(Out, Line1),
        read_lines(Line1, Out, Lines).

read_lines(end_of_file, _, []) :- !.
read_lines(Codes, Out, [Line|Lines]) :-
        atom_codes(Line, Codes),
        read_line_to_codes(Out, Line2),
        read_lines(Line2, Out, Lines).