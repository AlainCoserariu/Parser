/* Analyseur lexicale pour le langage TCP (presque sous-ensemble du langage C) */

%{
#include <stdio.h>

#include "parser.h"

void yyerror(char* msg);
int lineno = 1;
int colno_tmp = 1;
int colno = 1;
%}

%option nounput noinput
%x COM

%%
    /* Mots clefs du langage */
if                      {colno += yyleng; return IF;};
else                    {colno += yyleng; return ELSE;};
return                  {colno += yyleng; return RETURN;};
while                   {colno += yyleng; return WHILE;};
void                    {colno += yyleng; return VOID;};

    /* Operateurs */
&&                      {colno_tmp = colno; colno += yyleng; return AND;};
"||"                    {colno_tmp = colno; colno += yyleng; return OR;};
"=="|"!="               {colno_tmp = colno; colno += yyleng; return EQ;};
"<"|">"|"<="|">="       {colno_tmp = colno; colno += yyleng; return ORDER;};
[-+]                    {colno_tmp = colno; colno += yyleng; return ADDSUB;};
[*/%]                   {colno_tmp = colno; colno += yyleng; return DIVSTAR;};

"int"|"char"            {colno_tmp = colno; colno += yyleng; return TYPE;}; 

[_a-zA-Z][_a-zA-Z0-9]*  {colno_tmp = colno; colno += yyleng; return IDENT;};
[0-9]+                  {colno_tmp = colno; colno += yyleng; return NUM;};

\'[^\\]\'|\'\\[nt]\'    {colno_tmp = colno; colno += yyleng; return CHARACTER;};

    /* Caractères unique */
;                       {colno_tmp = colno; colno += yyleng; return ';';};
,                       {colno_tmp = colno; colno += yyleng; return ',';};
"{"                     {colno_tmp = colno; colno += yyleng; return '{';};
"}"                     {colno_tmp = colno; colno += yyleng; return '}';};
"("                     {colno_tmp = colno; colno += yyleng; return '(';};
")"                     {colno_tmp = colno; colno += yyleng; return ')';};
"="                     {colno_tmp = colno; colno += yyleng; return '=';};
"!"                     {colno_tmp = colno; colno += yyleng; return '!';};
"["                     {colno_tmp = colno; colno += yyleng; return '[';};
"]"                     {colno_tmp = colno; colno += yyleng; return ']';};

    /* Compte le nombre de ligne */
[\n\r]                  {colno_tmp = 1; colno = 1; lineno++;};

    /* Ignore les commentaires et compte le nombre de ligne du commentaire */
"/*"                    {BEGIN COM;};
<COM>.                  {;};
<COM>[\n\r]             {colno_tmp = 1; colno = 1; lineno++;};
<COM>"*/"               {BEGIN INITIAL;};
\/\/.*[\n\r]            {colno_tmp = 1; colno = 1; lineno++;};

    /* Ignore les espaces ou tabulations en trop */
[ \t]+                  {colno_tmp = colno; colno += yyleng;};

    /* Cas par défaut */
.                       {return yytext[0];};
%%