%{
#include <stdio.h>
#include <string.h>

#define YYSTYPE char *

void yyerror(const char* s)
{
	printf("ERROR:%s\n",s);
}

extern int yydebug;
int main()
{
	yydebug = 0;
	FILE * infp = NULL;
	infp = fopen("config.json","r");
	yyrestart(infp);
	yyparse();
	fclose(infp);
	return 0;
}
%}

%token QUOTE COMMA COLON START END STRING

%%

root: START items END
{
	// printf("xxxxx: %s %s %s %s\n", $$, $1, $2, $3);
};

items: items COMMA item | item;

item: item_key COLON item_value
{
	// printf("xxxxx: %s %s %s %s\n", $$, $1, $2, $3);
};

item_key: QUOTE STRING QUOTE;

item_value: item_string;

item_string: QUOTE STRING QUOTE
{
	printf("%s:%s\n", $$, $2);
};
