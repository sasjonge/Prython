/*

  Copyright (C) 2017 Sascha Jongebloed
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
      * Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.
      * Redistributions in binary form must reproduce the above copyright
        notice, this list of conditions and the following disclaimer in the
        documentation and/or other materials provided with the distribution.
      * Neither the name of the <organization> nor the
        names of its contributors may be used to endorse or promote products
        derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

@author Sascha Jongebloed
@license BSD

*/

:- module(prython,
    [
      py_call_init/0,
      py_call_base/4,
      py_call_base/6,
      py_call/4,
      py_call/6,
      create_module_of_script/2,
      add_py_path/1,
      list_to_atom/2,
      return_true_type/2,
      string_list_to_list/2,
      string_list_to_list_one/2,
      string_list_to_list_one/6,
      parameter_to_java_object_list/2,
      parameter_to_java_object/2,
      read_lines/2,
      max_depth/2,
      remove_char/3,
      python_module/1
    ]).

:- dynamic
        python_module/1.

%% py_call_init is det.
%
% Inits the jpy core by setting a system proberty and starting the python interpreter
%
py_call_init :-
	py_call_init('/path/to/your/jpy/build/lib.linux-x86_64-2.7/jpyconfig.properties').

%% py_call_init(+PathToJPYConfig)
%
% Inits the jpy core by setting a system proberty and starting the python interpreter
%
% @param PathToJPYConfig Path to the jpyconfig.properties file
%
py_call_init(PathToJPYConfig) :-
	jpl_call( 'java.lang.System', setProperty, ['jpy.config',PathToJPYConfig], P),
	jpl_list_to_array([''],A),
	jpl_call('org.jpy.PyLib',startPython,[A],Ret).

%% add_py_path(+Path) is det.
%
% Add paths to the python files
%
% @param Path Path to the python file
%
add_py_path(Path) :-
	(not(python_module(Module)) -> jpl_call('org.jpy.PyModule',importModule,['sys'],Module);python_module(Module)),
	jpl_datums_to_array([Path], ParameterArray),
	jpl_call(Module,getAttribute,['path'],Return),
	jpl_call(Return,call,[append,ParameterArray],NewModule),
	ignore((python_module(M),retract(python_module(M)))), % Retract all python_modules
	assert(python_module(Module)).

%% py_call_base(+PathTo:string, +FunctionName:string, +Parameter:list, ?Return) is semidet.
%
% Base predicate to call a function of a python file.
%
% @param Module The name of the python script
% @param FunctionName The function to be called
% @param Parameter The Parameter for the python function
% @param Return The return value of the python function as a string
%
py_call_base(Module,FunctionName,Parameter,Return):-
	% TODO Paramets to java_objects
	parameter_to_java_object_list(Parameter, ParameterObjects),
	jpl_datums_to_array(ParameterObjects,ParameterArray),
	jpl_call(Module,call,[FunctionName,ParameterArray],ReturnValue),
	jpl_call(ReturnValue,getObjectValue,[],ReturnObject),
	(jpl_is_object(ReturnObject) -> 
		java_to_string(ReturnObject,Return);
		Return = ReturnObject).

%% py_call_base(+PathTo:string, +ScriptName:string, +FunctionName:string, +Parameter:list, +ReturnTypeOfList:string, +ReturnTypeParameterForConstructor:string ?Return) is semidet.
%
% To call if you expect a list as return type. ReturnTypeOfList has to be the type of the returned list (in java types),
% only object types are allowed.
% ReturnTypeParameterForConstructor is needed as parameter of the object constructor.
%
% @param PathTo The path to the python file
% @param ScriptName The name of the python script
% @param FunctionName The function to be called
% @param Parameter The Parameter for the python function
% @param ReturnTypeOfList Type of the returned list. Needs to be a object type.
% @param ReturnTypeParameterForConstructor Standard value for the constructor of ReturnTypeOfList
% @param Return The return value of the python function as a string
%
py_call_base(Module,FunctionName,Parameter,ReturnTypeOfList,ReturnTypeParameterForConstructor,Return):-
	% TODO Paramets to java_objects
	parameter_to_java_object_list(Parameter, ParameterObjects),
	jpl_datums_to_array(ParameterObjects,ParameterArray),
	jpl_call(Module,call,[FunctionName,ParameterArray],ReturnValue),
	jpl_new(ReturnTypeOfList,ReturnTypeParameterForConstructor,ObjectOfReturnClass),
	jpl_call(ObjectOfReturnClass, getClass,[],Class),
	jpl_call(ReturnValue,getObjectArrayValue,[Class],ObjectArray),
	jpl_array_to_list(ObjectArray,ReturnArray),
	maplist(java_to_string,ReturnArray,Return).

%% py_call(+ScriptName:string, +FunctionName:string, +Parameter:list, ?ReturnTyped) is semidet.
%
% Predicate to call a function of a python file. The file need to be placed 
% at ../scripts from this prolog source lies. It returns the values with the right types.
%
% @param ScriptName The name of the python script
% @param FunctionName The function to be called
% @param Parameter The Parameter for the python function
% @param ReturnTyped The return value of the python function
%
py_call(ScriptName,FunctionName,Parameter,ReturnTyped) :-
	create_module_of_script(ScriptName,Module),
	py_call_base(Module,FunctionName,Parameter,Return),
	return_true_type(Return,ReturnTyped),!.

%% py_call(+PathTo:string, +ScriptName:string, +FunctionName:string, +Parameter:list, +ReturnTypeOfList:string, +ReturnTypeParameterForConstructor:string ?Return) is semidet.
%
% Predicate to call a function of a python file. The file need to be placed 
% at ../scripts from this prolog source lies. It returns the values with the right types.
%
% @param PathTo The path to the python file
% @param ScriptName The name of the python script
% @param FunctionName The function to be called
% @param Parameter The Parameter for the python function
% @param ReturnTypeOfList Type of the returned list. Needs to be a object type.
% @param ReturnTypeParameterForConstructor Standard value for the constructor of ReturnTypeOfList
% @param Return The return value of the python function as a string
%
py_call(ScriptName,FunctionName,Parameter,ReturnTypeOfList,ReturnTypeParameterForConstructor,ReturnTyped) :-
	create_module_of_script(ScriptName,Module),
	py_call_base(Module,FunctionName,Parameter,ReturnTypeOfList,ReturnTypeParameterForConstructor,Return),
	return_true_type(Return,ReturnTyped),!.

%%%%%%%%%%%%%%% Help Predicates %%%%%%%%%%%%%%%%%%%%%%


%% create_module_of_script(ScriptName,Module) 
%
% Uses the importModule method of jpy, to 
% import a Python module into the Python interpreter 
% and return its Java representation.
%
% @param ScriptName Name of python script
% @param Module Returned Module Object
%
create_module_of_script(ScriptName,Module) :-
	python_module(MetaModule),
	jpl_call(MetaModule,importModule,[ScriptName],Module).

%% java_to_string(+Object, -String)
% 
% Simple Wrapper for the toString Method
%
% @param Object Object to call toString on
% @param String Returned value of toString call
%
java_to_string(Object,String) :-
	jpl_call(Object,toString,[],String).

%% return_true_type(+Input:string, -TypedInput) is semidet.
%
% Predicate to get the input in the right type
%
% @param Input A String
% @param TypedInput The value of the string in the right type
%
return_true_type(Input, TypedInput) :-
	(is_list(Input) -> maplist(return_true_type,Input,TypedInput));
	(atom(Input)->
    (atom_number(Input,TypedInput)-> 
      true;
      TypedInput=Input);
    TypedInput=Input).	


%% string_list_to_list(Original, List) is semidet.
%
% Creates from a string in the form of a python list a list, e.g: '[1,2,[1,2]]' will bind List to ['1','2',['1','2']]
%
% @param Original A String
% @param TypedInput The value of the string in the right type
%
string_list_to_list(Original,List) :-
  is_list(Original),
  max_depth(Original,NumOfOList),
  maplist(string_list_to_list_one,Original,NewList),
  max_depth(NewList,NumOfNList),
  (NumOfOList=\=NumOfNList ->
    maplist(string_list_to_list,NewList,List);
    List = NewList).

string_list_to_list(Original,List) :-
  atom(Original),
  string_list_to_list_one(Original,NewList),
  (is_list(NewList) ->
    string_list_to_list(NewList,List);
    List=Original).

string_list_to_list(Original,List) :-
  number(Original),
  List=Original.
  
%% string_list_to_list(Original, List) is semidet.
%
% Help-function for string_list_to_list. It will not translate nested lists:
% e.g. '[1,2,[1,2]]' will bind List to ['1','2','[1,2]']
%
% @param Original A String
% @param TypedInput The value of the string in the right type
%
string_list_to_list_one(Original,List) :-
  name(Original,OriginalStr),
  string_list_to_list_one(OriginalStr,OriginalStr,0,[],[],List),!.

string_list_to_list_one(Original,RestStr,0,CurrString,CurrList,List) :-
  RestStr = [FirstChar|Rest],
  (FirstChar=91
    -> string_list_to_list_one(Original,Rest,1,CurrString,CurrList,List);(name(OriginalAtom,Original),List=OriginalAtom)).

string_list_to_list_one(Original,RestStr,1,CurrString,CurrList,List) :-
  RestStr = [FirstChar|Rest],
  ((FirstChar=91
    -> append(CurrString,[91],NewString),string_list_to_list_one(Original,Rest,2,NewString,CurrList,List));
    (FirstChar=93
      -> (Rest=[]->(name(CurrAtom,CurrString),append(CurrList,[CurrAtom],NewList),List=NewList);(name(OriginalAtom,Original),List=OriginalAtom)));
    (FirstChar=44 
      -> name(CurrAtom,CurrString),append(CurrList,[CurrAtom],NewList),string_list_to_list_one(Original,Rest,1,[],NewList,List));
    (append(CurrString,[FirstChar],NewString),string_list_to_list_one(Original,Rest,1,NewString,CurrList,List))
  ).

string_list_to_list_one(Original,RestStr,CountBracket,CurrString,CurrList,List) :-
  CountBracket >= 2,
  RestStr = [FirstChar|Rest],
  ((FirstChar=91
    -> append(CurrString,[91],NewString),NewCountBracket is CountBracket + 1,string_list_to_list_one(Original,Rest,NewCountBracket,NewString,CurrList,List));
  (FirstChar=93
    -> append(CurrString,[93],NewString),NewCountBracket is CountBracket - 1,string_list_to_list_one(Original,Rest,NewCountBracket,NewString,CurrList,List));
  (append(CurrString,[FirstChar],NewString),string_list_to_list_one(Original,Rest,CountBracket,NewString,CurrList,List))
  ).

%% create_parameter_string(Parameter,ParameterObjects) is semidet.
%
parameter_to_java_object_list(Parameter,ParameterObjects) :-
	maplist(parameter_to_java_object,Parameter,ParameterObjects).

parameter_to_java_object(Parameter, Object) :-
	atom(Parameter),
	Object = Parameter. %No jpl call necessary here, jpl converts this values automatically

parameter_to_java_object(Parameter, Object) :-
	float(Parameter),
	jpl_new('java.lang.Float',[Parameter],Object).

parameter_to_java_object(Parameter, Object) :-
	integer(Parameter),
	jpl_new('java.lang.Integer',[Parameter],Object).

list_to_atom(List,Atom) :-
  is_list(List),
  maplist(list_to_atom,List,StrList),
  atomic_list_concat(StrList,',',ListStr),
  name(ListStr,ChrList),
  reverse([91|ChrList],Reversed),
  reverse([93|Reversed], AtomChrList),
  name(Atom,AtomChrList).

list_to_atom(List,Atom) :-
  number(List),
  Atom=List.

list_to_atom(List,Atom) :-
  atom(List),
  name(List,ListChr),
  reverse([39|ListChr],Reversed),
  reverse([39|Reversed], AtomFull),
  name(Atom,AtomFull).

%% max_depth(+List,-MaxDepth) is det
% 
% Calculates the max. depth of a nested list
%
% @param List
% @MaxDepth The maximum depth of the list
max_depth(List,MaxDepth) :-
  (is_list(List) -> 
    (maplist(max_depth,List,DepthList),
    max_list(DepthList,MDepth),
    MaxDepth is MDepth + 1)
  ;MaxDepth = 0).

max_depth([],MaxDepth) :-
  MaxDepth = 1.

%% read_lines(+Out, -Lines) is semidet.
%
% Reads lines from the stdoutput
%
% @param Input A String
% @param TypedInput The value of the string in the right type
%
read_lines(Out, Lines) :-
        read_line_to_codes(Out, Line1),
        read_lines(Line1, Out, Lines).
read_lines(end_of_file, _, []) :- !.
read_lines(Codes, Out, [Line|Lines]) :-
        atom_codes(Line, Codes),
        read_line_to_codes(Out, Line2),
        read_lines(Line2, Out, Lines).

%% remove_char(+String:string, +Char:int, -NewString) is det
%
% Simply removes a defined char from a string
%
remove_char(String, Char, NewString) :-
	name(String,CharList),
	delete(CharList,Char,CleanedCharList),
	name(NewString,CleanedCharList).