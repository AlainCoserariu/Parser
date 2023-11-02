/* Analyseur lexicale pour le langage TCP (presque sous-ensemble du langage C) */

%{
#include <stdio.h>

#include "parser.h"

void yyerror(char* msg);
int lineno = 1;
%}

%option nounput noinput
%x COM

%%
    /* Mots clefs du langage */
if {return IF;};
else {return ELSE;};
return {return RETURN;};
while {return WHILE;};
void {return VOID;};

    /* Operateurs */
&& {return AND;};
"||" {return OR;};
"=="|"!=" {return EQ;};
"<"|">"|"<="|">=" {return ORDER;};
[-+] {return ADDSUB;};
[*/%] {return DIVSTAR;};

"int"|"char" {return TYPE;}; 

[_a-zA-Z][_a-zA-Z0-9]* {return IDENT;};
[0-9]+ {return NUM;};

[a-zA-Z] {return CHARACTER;};

    /* Caractères unique */
; {return ';';};
, {return ',';};
"{" {return '{';};
"}" {return '}';};
"(" {return '(';};
")" {return ')';};
"=" {return '=';};
"!" {return '!';};
"[" {return '[';};
"]" {return ']';};

    /* Compte le nombre de ligne */
[\n\r] {lineno++;};

    /* Ignore les commentaires et compte le nombre de ligne du commentaire */
"/*" {BEGIN COM;};
<COM>. {;};
<COM>[\n\r] {lineno++;};
<COM>"*/" {BEGIN INITIAL;};
\/\/.*[\n\r] {lineno++;};

    /* Ignore les espaces ou tabulations en trop */
[ \t]+ {;};

    /* Cas par défaut */
. {return yytext[0];};
%%