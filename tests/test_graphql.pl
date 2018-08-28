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

:- include('../prolog/graphql.pl').

:- use_module(library(http/http_open)).
:- use_module(library(http/http_client)).
:- use_module(library(http/http_ssl_plugin)).

:- use_module(library(http/json)).
:- use_module(library(http/json_convert)).
:- use_module(library(http/http_json)).

%%
%% Tests
%%
:- use_module(library(plunit)).

:- begin_tests(github).

test(query) :-
    %% before running the test, set your github personal access token into
    %% the environment varialbe 'GITHUB_ACCESS_TOKEN'
    getenv('GITHUB_ACCESS_TOKEN', GITHUB_ACCESS_TOKEN),

    Owner = '"naohirotamura"',
    Name = '"faasshell"',
    Since = '"2018-06-21T00:00:00+00:00"',
    Until = '"2018-07-20T00:00:00+00:00"',
    atomic_list_concat(
        {| graphql(Owner, Name, Since, Until) || 
           {
             repository(owner: Owner, name: Name) {
               ref(qualifiedName: "master") {
                 target {
                   ... on Commit {
                     history(first: 100, since: Since, until: Until) {
                       totalCount
                       edges {
                         node {
                           oid
                           author {
                             date
                             email
                           }
                         }
                         cursor
                       }
                       pageInfo {
                         endCursor
                         hasNextPage
                       }
                     }
                   }
                 }
               }
             }
           }
        |}, Query),
    % format('~p~n', [Query]),

    term_json_dict(Json, _{ query: Query }),
    URL = 'https://api.github.com/graphql',
    atomic_list_concat(['Bearer', GITHUB_ACCESS_TOKEN], ' ', AuthorizationHeader),
    http_post(URL, json(Json), R1,
              [request_header('Authorization'=AuthorizationHeader)]),
    term_json_dict(R1, D1),

    % format('~p~n', [D1]),
    assertion(D1.data.repository.ref.target.history.totalCount = 2).

:- end_tests(github).

%%
%% Utils
%%
term_json_dict(Term, Dict) :-
    ground(Term), !,
    atom_json_term(Atom, Term, []), atom_json_dict(Atom, Dict, []).
term_json_dict(Term, Dict) :-
    atom_json_dict(Atom, Dict, []), atom_json_term(Atom, Term, []).
