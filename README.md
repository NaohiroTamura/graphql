# GraphQL Prolog Library

## Installation

```prolog
?- pack_install('https://github.com/NaohiroTamura/graphql.git').

?- use_module(library(graphql)).
```

## Run tests

```sh
$ swipl -l tests/test_graphql.pl
```

```prolog
?- setenv('GITHUB_ACCESS_TOKEN', 'set_your_github_personal_access_token').
true.

?- run_tests.
% PL-Unit: github . done
% test passed
true.
```
