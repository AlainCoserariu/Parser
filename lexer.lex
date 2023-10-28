/* Lexer for the language TCP */

%{
#include "tree.h"
#include "parser.h"
void yyerror(char* msg);
int lineno;
%}

%option nounput noinput noyywrap
%x COM

%%
/* Key word for the language */
if return IF;
else return ELSE;
return return RETURN;
while return WHILE;
void return VOID;

/* Operators */
&& return AND;
|| return OR;
==|!= return EQ;
<|>|<=|>= return ORDER;
-|\+ return ADDSUB;
[*/%] return DIVSTAR;

"int"|"char" return TYPE; 
[_a-zA-Z][_a-zA-Z0-9]* return IDENT;
[0-9]+ return NUM;
[a-zA-Z] return CHARACTER;
; return ';';
, return ',';
\{ return '{';
\} return '}';
\( return '(';
\) return ')';
\= return '=';
\! return '!';
\[ return '[';
\] return ']';
\n lineno++;
"/*" BEGIN COM;
<COM>. ;
<COM>[\n\r] lineno++;
<COM>"*/" BEGIN INITIAL;
\/\/.*[\n\r] lineno++;
[ \t]+ ;
. return yytext[0];
%%

int main(void){
    yylex();
    return 0;
}