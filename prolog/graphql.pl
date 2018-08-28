%% -*- mode: prolog; coding: utf-8; -*-
%%
%% Copyright 2017 FUJITSU LIMITED
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%% http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%

:- module(graphql, [graphql/4]).

:- use_module(library(dcg/basics)).
:- use_module(library(quasi_quotations)).

:- quasi_quotation_syntax(graphql).

%%
tokenize(_QQDict, []) -->
    eos,
    %{ writeln(eos) },
    !.
tokenize(QQDict, [' '|Tokens]) -->
    blank, blanks,
    %{ writeln(blanks) },
    !, tokenize(QQDict, Tokens).
tokenize(QQDict, [Value|Tokens]) -->
    prolog_var_name(Key),
    %{ writeln(prolog_var_name(Key, Value)) },
    { ( memberchk(Key=Value, QQDict)
        ; Value = Key ) },
    !, tokenize(QQDict, Tokens).
tokenize(QQDict, ['"',Atom,'"'|Tokens]) -->
    `\"`,
     upto_quote(Atom),
    %{ writeln(upto_quote(Atom)) },
    !, tokenize(QQDict, Tokens).
tokenize(QQDict, [Atom, Sep|Tokens]) -->
    upto_sep(Atom, Sep),
    %{ writeln(upto_sep(Atom, Sep)) },
    !, tokenize(QQDict, Tokens).

upto_sep(Atom, Sep) -->
        string(Codes), [S],
        { atom_codes(Atom, Codes),
          ( code_type(S, space)
            ; code_type(S, prolog_symbol)
            ; code_type(S, paren(_))
            ; code_type(_, paren(S))
            ; code_type(S, end_of_line)
          ),
          !,
          ( code_type(S, end_of_line)
            -> Sep = ''
            ;  atom_codes(Sep, [S])
          )
        }.

upto_quote(Atom) -->
    string(Codes), `\"`, !,
    { atom_codes(Atom, Codes) }.

%%
graphql(Content, Vars, Dict, List) :-
    % format(user_error, 'graphql(~p, ~p, ~p, ~p)~n', [Content, Vars, Dict, List]),

    include(qq_var(Vars), Dict, QQDict),

    % format(user_error, 'qq_var(~p), ~p, ~p))~n', [Vars, Dict, QQDict]),

    phrase_from_quasi_quotation(tokenize(QQDict, List), Content).

qq_var(Vars, _=Var) :- member(V, Vars), V == Var, !.
