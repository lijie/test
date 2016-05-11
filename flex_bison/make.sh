#!/bin/sh

flex json.l
bison -d json.y
gcc -DYYDEBUG=1 -DYYERROR_VERBOSE -o flex_bison_json json.tab.c lex.yy.c
