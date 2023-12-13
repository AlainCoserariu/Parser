/* Analyseur syntaxique pour le langage TPC (presque sous-ensemble du langage C) */

%{
#include <stdio.h>

#include "parser.h"

int yylex();

extern int lineno;
extern int colno_tmp;
void yyerror(char* msg) {
    fprintf(stderr, "Erreur à la ligne %d, colonne %d : %s\n", lineno, colno_tmp, msg);
}

%}

%union {
    char operator;
    int num;
    char ident[128];
    char comp[3];
    char logic_op[3];
    char struct_control_op[10];
    char type[10];
    char character;
}

%token <type> TYPE VOID
%token <ident> IDENT
%token <comp> ORDER EQ
%token <operator> ADDSUB DIVSTAR
%token <num> NUM
%token <character> CHARACTER
%token <logic_op> OR AND
%token <struct_control_op> IF WHILE RETURN ELSE

%%
Prog:  DeclVars DeclFoncts
    ;
DeclVars:
       DeclVars TYPE Declarateurs ';'
    |
    ;
Declarateurs:
       Declarateurs ',' IDENT
    |  Declarateurs ',' IDENT '[' NUM ']'
    |  IDENT
    |  IDENT '[' NUM ']'
    ;
DeclFoncts:
       DeclFoncts DeclFonct
    |  DeclFonct
    ;
DeclFonct:
       EnTeteFonct Corps
    ;
EnTeteFonct:
       TYPE IDENT '(' Parametres ')'
    |  VOID IDENT '(' Parametres ')'
    ;
Parametres:
       VOID
    |  ListTypVar
    ;
ListTypVar:
       ListTypVar ',' TYPE IDENT
    |  ListTypVar ',' TYPE IDENT '[' ']'
    |  TYPE IDENT '[' ']'
    |  TYPE IDENT
    ;
Corps: '{' DeclVars SuiteInstr '}'
    ;
SuiteInstr:
       SuiteInstr Instr
    |
    ;
Instr:
       LValue '=' Exp ';'
    |  IF '(' Exp ')' Instr
    |  IF '(' Exp ')' Instr ELSE Instr
    |  WHILE '(' Exp ')' Instr
    |  IDENT '(' Arguments  ')' ';'
    |  RETURN Exp ';'
    |  RETURN ';'
    |  '{' SuiteInstr '}'
    |  ';'
    ;
Exp :  Exp OR TB
    |  TB
    ;
TB  :  TB AND FB
    |  FB
    ;
FB  :  FB EQ M
    |  M
    ;
M   :  M ORDER E
    |  E
    ;
E   :  E ADDSUB T
    |  T
    ;    
T   :  T DIVSTAR F 
    |  F
    ;
F   :  ADDSUB F
    |  '!' F
    |  '(' Exp ')'
    |  NUM
    |  CHARACTER
    |  LValue
    |  IDENT '(' Arguments ')'
    ;
LValue:
       IDENT
    |  IDENT '[' Exp ']'
    ;
Arguments:
       ListExp
    |
    ;
ListExp:
       ListExp ',' Exp
    |  Exp
    ;
%%

int main(int argc, char* argv[]) {
    return yyparse();
}

