py_run(PathTo,ScriptName,Option,Lines):-
	string_concat(PathTo,ScriptName,Script),
    setup_call_cleanup(
    process_create(path(python),[Script,Option],[stdout(pipe(Out))]),
    read_lines(Out,OLines),
    close(Out)),
	string_list_to_list(OLines,Lines).

py_run(ScriptName,Option,Lines) :-
	py_run('scripts/',ScriptName,Option,Lines).

py_call_base(PathTo,ScriptName,FunctionName,Parameter,Lines):-
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
    read_lines(Out,OLines),
    close(Out)),
    maplist(string_list_to_list,OLines,Lines),
    working_directory(_,OldPath).


string_list_to_list(StrList, List) :-
	name(StrList,CharList),
	CharList = [FirstChar|Rest],
	reverse(Rest, [LastChar|Reverse]),
	reverse(Reverse,CleanedString),
	((FirstChar=91,LastChar=93)
	-> name(CleanedAtom,CleanedString),atomic_list_concat(List,',',CleanedAtom)).

string_list_to_list(StrList, List) :-
	name(StrList,CharList),
	CharList = [FirstChar|Rest],
	reverse(Rest, [LastChar|_]),
	((FirstChar=\=91;LastChar=\=93)
	-> List = StrList).

string_list_to_list(StrList, List) :-
	name(StrList,CharList),
	length(CharList,Len),
	( Len =< 1
	-> List = StrList).

read_lines(Out, Lines) :-
        read_line_to_codes(Out, Line1),
        read_lines(Line1, Out, Lines).

read_lines(end_of_file, _, []) :- !.
read_lines(Codes, Out, [Line|Lines]) :-
        atom_codes(Line, Codes),
        read_line_to_codes(Out, Line2),
        read_lines(Line2, Out, Lines).