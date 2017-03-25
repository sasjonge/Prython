py_run(PathTo,ScriptName,Option,Lines):-
	string_concat(PathTo,ScriptName,Script),
    setup_call_cleanup(
    process_create(path(python),[Script,Option],[stdout(pipe(Out))]),
    read_lines(Out,OLines),
    close(Out)),
	string_list_to_list(OLines,Lines).

py_run(ScriptName,Option,Lines) :-
	py_run('scripts/',ScriptName,Option,Lines).

py_call_base(PathTo,ScriptName,FunctionName,Parameter,Return):-
	working_directory(OldPath,PathTo),
	string_concat('import sys;import io; import ',ScriptName,Temp1),
	string_concat(Temp1,';save_out = sys.stdout;sys.stdout = io.BytesIO(); ret = ',Temp2),
	string_concat(Temp2,ScriptName,Temp3),
	string_concat(Temp3,'.',Temp4),
	string_concat(Temp4,FunctionName,Temp5),
	string_concat(Temp5,'(',Temp6),
	atomic_list_concat(Parameter,',',Clist),
	atom_string(Clist,ParameterString),
	string_concat(Temp6,ParameterString,Temp7),
	string_concat(Temp7,');sys.stdout = save_out; print str(ret)',CallArgu),
	setup_call_cleanup(
    process_create(path(python),['-c', CallArgu],[stdout(pipe(Out))]),
    read_lines(Out,Return),
    close(Out)),
    % maplist(string_list_to_list,OLines,Return),
    working_directory(_,OldPath).

py_call(PathTo,ScriptName,FunctionName,Parameter,ReturnTyped) :-
	py_call_base(PathTo,ScriptName,FunctionName,Parameter,Return),
	maplist(return_true_type,Return,ReturnTyped).

return_true_type(Input, TypedInput) :-
	(is_list(Input) -> maplist(return_true_type,Input,TypedInput));
	(atom_number(Input,TypedInput)-> true;TypedInput=Input).	

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