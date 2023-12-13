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
if                      {colno += yyleng; strcpy(yylval.struct_control_op, yytext); return IF;};
else                    {colno += yyleng; strcpy(yylval.struct_control_op, yytext); return ELSE;};
return                  {colno += yyleng; strcpy(yylval.struct_control_op, yytext); return RETURN;};
while                   {colno += yyleng; strcpy(yylval.struct_control_op, yytext); return WHILE;};
void                    {colno += yyleng; strcpy(yylval.type, yytext); return VOID;};

    /* Operateurs */
&&                      {colno_tmp = colno; colno += yyleng; strcpy(yylval.logic_op, yytext); return AND;};
"||"                    {colno_tmp = colno; colno += yyleng; strcpy(yylval.logic_op, yytext); return OR;};
"=="|"!="               {colno_tmp = colno; colno += yyleng; strcpy(yylval.comp, yytext); return EQ;};
"<"|">"|"<="|">="       {colno_tmp = colno; colno += yyleng; strcpy(yylval.comp, yytext); return ORDER;};
[-+]                    {colno_tmp = colno; colno += yyleng; yylval.operator = yytext[0]; return ADDSUB;};
[*/%]                   {colno_tmp = colno; colno += yyleng; yylval.operator = yytext[0]; return DIVSTAR;};

"int"|"char"            {colno_tmp = colno; colno += yyleng; strcpy(yylval.type, yytext); return TYPE;}; 

[_a-zA-Z][_a-zA-Z0-9]*  {colno_tmp = colno; colno += yyleng; strcpy(yylval.ident, yytext); return IDENT;};
[0-9]+                  {colno_tmp = colno; colno += yyleng; yylval.num = atoi(yytext); return NUM;};

\'[^\\]\'|\'\\[nt]\'    {colno_tmp = colno; colno += yyleng; yylval.character = yytext[1]; return CHARACTER;};

    /* Caractères unique */
;                       {colno_tmp = colno; colno += yyleng; yylval.character = yytext[0]; return ';';};
,                       {colno_tmp = colno; colno += yyleng; yylval.character = yytext[0]; return ',';};
"{"                     {colno_tmp = colno; colno += yyleng; yylval.character = yytext[0]; return '{';};
"}"                     {colno_tmp = colno; colno += yyleng; yylval.character = yytext[0]; return '}';};
"("                     {colno_tmp = colno; colno += yyleng; yylval.character = yytext[0]; return '(';};
")"                     {colno_tmp = colno; colno += yyleng; yylval.character = yytext[0]; return ')';};
"="                     {colno_tmp = colno; colno += yyleng; yylval.character = yytext[0]; return '=';};
"!"                     {colno_tmp = colno; colno += yyleng; yylval.character = yytext[0]; return '!';};
"["                     {colno_tmp = colno; colno += yyleng; yylval.character = yytext[0]; return '[';};
"]"                     {colno_tmp = colno; colno += yyleng; yylval.character = yytext[0]; return ']';};

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