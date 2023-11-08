/* Analyseur lexicale pour le langage TCP (presque sous-ensemble du langage C) */

%{
#include <stdio.h>

#include "parser.h"

void yyerror(char* msg);
int lineno = 1;
int colno = 0;
%}

%option nounput noinput
%x COM

%%
    /* Mots clefs du langage */
if {colno += yyleng; return IF;};
else {colno += yyleng; return ELSE;};
return {colno += yyleng; return RETURN;};
while {colno += yyleng; return WHILE;};
void {colno += yyleng; return VOID;};

    /* Operateurs */
&& {colno += yyleng; return AND;};
"||" {colno += yyleng; return OR;};
"=="|"!=" {colno += yyleng; return EQ;};
"<"|">"|"<="|">=" {colno += yyleng; return ORDER;};
[-+] {colno += yyleng; return ADDSUB;};
[*/%] {colno += yyleng; return DIVSTAR;};

"int"|"char" {colno += yyleng; return TYPE;}; 

[_a-zA-Z][_a-zA-Z0-9]* {colno += yyleng; return IDENT;};
[0-9]+ {colno += yyleng; return NUM;};

'[a-zA-Z]' {colno += yyleng; return CHARACTER;};

    /* Caractères unique */
; {colno += yyleng; return ';';};
, {colno += yyleng; return ',';};
"{" {colno += yyleng; return '{';};
"}" {colno += yyleng; return '}';};
"(" {colno += yyleng; return '(';};
")" {colno += yyleng; return ')';};
"=" {colno += yyleng; return '=';};
"!" {colno += yyleng; return '!';};
"[" {colno += yyleng; return '[';};
"]" {colno += yyleng; return ']';};

    /* Compte le nombre de ligne */
[\n\r] {colno = 0; lineno++;};

    /* Ignore les commentaires et compte le nombre de ligne du commentaire */
"/*" {BEGIN COM;};
<COM>. {;};
<COM>[\n\r] {colno = 0; lineno++;};
<COM>"*/" {BEGIN INITIAL;};
\/\/.*[\n\r] {colno = 0; lineno++;};

    /* Ignore les espaces ou tabulations en trop */
[ \t]+ {colno += yyleng;};

    /* Cas par défaut */
. {return yytext[0];};
%%