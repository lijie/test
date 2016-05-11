%{
#include <stdio.h>
#include "json.tab.h"

int yywrap() { return 1; }

%}

%%

\"	return QUOTE;
\,	return COMMA;
\{	return START;
\}	return END;
\:	return COLON;
[a-zA-Z]+ yylval = strdup(yytext);return STRING;
[\n\t\r]
%%
