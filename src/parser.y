/* Analyseur syntaxique pour le langage TPC (presque sous-ensemble du langage C) */

%{
#include <stdio.h>
#include <string.h>

#include "tree.h"

#include "parser.h"

extern int lineno;
extern int colno_tmp;

int display_tree = 0;

// typedef struct {
//     yylval;
// }

int yylex();

void yyerror(char* msg) {
    fprintf(stderr, "Erreur à la ligne %d, colonne %d : %s\n", lineno, colno_tmp, msg);
}



%}

%union {
    Node* node;
    char operator;
    int num;
    char ident[128];
    char comp[3];
    char logic_op[3];
    char struct_control_op[10];
    char type[10];
    char character;
} 

%type <node> Prog DeclVars Declarateurs DeclFoncts DeclFonct
%type <node> EnTeteFonct Parametres ListTypVar Corps SuiteInstr
%type <node> Instr Exp TB FB M E T F LValue Arguments ListExp
%token <type> TYPE VOID
%token <ident> IDENT
%token <comp> ORDER EQ
%token <operator> ADDSUB DIVSTAR
%token <num> NUM
%token <character> CHARACTER
%token <logic_op> OR AND
%token <struct_control_op> IF WHILE RETURN ELSE

%expect 1
%%

Prog:  DeclVars DeclFoncts                      {$$ = makeNode(Prog, (union values) { .num = 0}, NONE_T);
                                                addChild($$, $1);
                                                addChild($$, $2);
                                                
                                                if (display_tree)
                                                    printTree($$);
                                                }
    ;
DeclVars:
       DeclVars TYPE Declarateurs ';'           {$$ = $1;
                                                Node* i = makeNode(type, (union values)  { .string = $2 }, STRING_T);
                                                addChild($$, i );
                                                addChild(i, $3);
                                                }
    |                                           {$$ = makeNode(DeclVars, (union values)  {.num = 0}, NONE_T);}
    ;
Declarateurs:
       Declarateurs ',' IDENT                   {$$ = $1;
                                                addSibling($$, makeNode(ident, (union values) {.string = $3}, STRING_T));
                                                }
    |  Declarateurs ',' IDENT '[' NUM ']'       {$$ = $1;
                                                Node* i = makeNode(ident, (union values) {.string = $3}, STRING_T);
                                                addSibling($$, i);
                                                addChild(i, makeNode(num, (union values) {.num = $5}, INTEGER_T));
                                                }
    |  IDENT                                    {$$ = makeNode(ident, (union values) {.string = $1}, STRING_T);}
    |  IDENT '[' NUM ']'                        {$$ = makeNode(ident, (union values) {.string = $1}, STRING_T);
                                                addChild($$, makeNode(num, (union values) {.num = $3}, INTEGER_T));
                                                }
    ;
DeclFoncts:
       DeclFoncts DeclFonct                     {$$ = $1;
                                                addSibling($$, $2);
                                                }
    |  DeclFonct                                {$$ = $1;
                                                }
    ;
DeclFonct:
       EnTeteFonct Corps                        {$$ = makeNode(DeclFonct, (union values)  {.num = 0}, NONE_T);
                                                addChild($$, $1);
                                                addChild($$, $2);
                                                }
    ;
EnTeteFonct:
       TYPE IDENT '(' Parametres ')'            {$$ = makeNode(EnTeteFonct, (union values)  {.num = 0}, NONE_T);
                                                addChild($$, makeNode(type, (union values)  { .string = $1 }, STRING_T));
                                                addChild($$, makeNode(ident, (union values) {.string = $2}, STRING_T));
                                                addChild($$, $4);
                                                }
    |  VOID IDENT '(' Parametres ')'            {$$ = makeNode(EnTeteFonct, (union values)  {.num = 0}, NONE_T);
                                                addChild($$, makeNode(void_type, (union values)  { .string = $1 }, STRING_T));
                                                addChild($$, makeNode(ident, (union values) {.string = $2}, STRING_T));
                                                addChild($$, $4);
                                                }
    ;
Parametres:
       VOID                                     {$$ = makeNode(void_type, (union values)  { .string = $1 }, STRING_T);}
    |  ListTypVar                               {$$ = $1;}
    ;
ListTypVar:
       ListTypVar ',' TYPE IDENT                {$$ = $1;
                                                addSibling($$, makeNode(type, (union values) {.string = $3}, STRING_T));
                                                addSibling($$, makeNode(ident, (union values) {.string = $4}, STRING_T));}
    |  ListTypVar ',' TYPE IDENT '[' ']'        {$$ = $1;
                                                addSibling($$, makeNode(type, (union values) {.string = $3}, STRING_T));
                                                addSibling($$, makeNode(ident, (union values) {.string = $4}, STRING_T));
                                                addSibling($$, makeNode(num, (union values) { .num = 0}, NONE_T));
                                                }
    |  TYPE IDENT '[' ']'                       {$$ = makeNode(type, (union values) {.string = $1}, STRING_T);
                                                addSibling($$, makeNode(ident, (union values) {.string = $2}, STRING_T));
                                                addSibling($$, makeNode(num, (union values) { .num = 0}, NONE_T));}
    |  TYPE IDENT                               {$$ = makeNode(type, (union values) {.string = $1}, STRING_T);
                                                addSibling($$, makeNode(ident, (union values) {.string = $2}, STRING_T));}
    ;
Corps: '{' DeclVars SuiteInstr '}'              {$$ = makeNode(Corps, (union values) {.num = 0}, NONE_T);
                                                addChild($$, $2);
                                                addChild($$, $3);
                                                }
    ;
SuiteInstr:
       SuiteInstr Instr                         {$$ = $1;
                                                addChild($$, $2);}
    |                                           {$$ = makeNode(SuiteInstr, (union values) {.num = 0}, NONE_T);}
    ;
Instr:
       LValue '=' Exp ';'                       {$$ = makeNode(Instr, (union values) {.num = 0}, NONE_T);
                                                addSibling($$, makeNode(character, (union values) {.character = '='}, CHARACTER_T));
                                                addSibling($$, $3);}
    |  IF '(' Exp ')' Instr                     {$$ = makeNode(if_type, (union values) {.string = $1}, STRING_T);
                                                addSibling($$, $3);
                                                addSibling($$, $5);}
    |  IF '(' Exp ')' Instr ELSE Instr          {$$ = makeNode(if_type, (union values) {.string = $1}, STRING_T);
                                                addSibling($$, $3);
                                                addSibling($$, $5);
                                                addSibling($$, makeNode(else_type, (union values) {.string = $6}, STRING_T));
                                                addSibling($$, $7);}
    |  WHILE '(' Exp ')' Instr                  {$$ = makeNode(while_type, (union values) {.string = $1}, STRING_T);
                                                addSibling($$, $3);
                                                addSibling($$, $5);}
    |  IDENT '(' Arguments  ')' ';'             {$$ = makeNode(ident, (union values) {.string = $1}, STRING_T);
                                                addSibling($$, $3);}
    |  RETURN Exp ';'                           {$$ = makeNode(return_type, (union values) {.string = $1}, STRING_T);
                                                addSibling($$, $2);}
    |  RETURN ';'                               {$$ = makeNode(return_type, (union values) {.string = $1}, STRING_T);}
    |  '{' SuiteInstr '}'                       {$$ = $2;}
    |  ';'                                      {;}
    ;
Exp :  Exp OR TB                                {$$ = makeNode(or, (union values) {.string = $2}, STRING_T);
                                                addChild($$, $1);
                                                addChild($$, $3);}
    |  TB                                       {$$ = $1;}
    ;
TB  :  TB AND FB                                {$$ = makeNode(and, (union values) {.string = $2}, STRING_T);
                                                addChild($$, $1);
                                                addChild($$, $3);}
    |  FB                                       {$$ = $1;}
    ;
FB  :  FB EQ M                                  {$$ = makeNode(eq, (union values) {.string = $2}, STRING_T);
                                                addChild($$, $1);
                                                addChild($$, $3);}
    |  M                                        {$$ = $1;}
    ;
M   :  M ORDER E                                {$$ = makeNode(order, (union values) {.string = $2}, STRING_T);
                                                addChild($$, $1);
                                                addChild($$, $3);}
    |  E                                        {$$ = $1;}
    ;
E   :  E ADDSUB T                               {$$ = makeNode(addsub, (union values) {.character = $2}, CHARACTER_T);
                                                addChild($$, $1);
                                                addChild($$, $3);}
    |  T                                        {$$ = $1;}
    ;    
T   :  T DIVSTAR F                              {$$ = makeNode(divstar, (union values) {.character = $2}, CHARACTER_T);
                                                addChild($$, $1);
                                                addChild($$, $3);}
    |  F                                        {$$ = $1;}
    ;
F   :  ADDSUB F                                 {$$ = makeNode(addsub, (union values) {.character = $1}, CHARACTER_T);
                                                addChild($$, $2);}
    |  '!' F                                    {$$ = makeNode(character, (union values) {.character = '!'}, CHARACTER_T);
                                                addChild($$, $2);}
    |  '(' Exp ')'                              {$$ = $2;}
    |  NUM                                      {$$ = makeNode(num, (union values) {.num = $1}, INTEGER_T);}
    |  CHARACTER                                {$$ = makeNode(character, (union values) {.num = $1}, CHARACTER_T);}
    |  LValue                                   {$$ = $1;}
    |  IDENT '(' Arguments ')'                  {$$ = makeNode(ident, (union values) {.string = $1}, STRING_T);
                                                addChild($$, $3);}
    ;
LValue:
       IDENT                                    {$$ = makeNode(ident, (union values) {.string = $1}, STRING_T);}
    |  IDENT '[' Exp ']'                        {$$ = makeNode(ident, (union values) {.string = $1}, STRING_T);
                                                addChild($$, $3);}
    ;
Arguments:
       ListExp                                  {$$ = makeNode(Arguments, (union values) {.num = 0}, NONE_T);}
    |                                           {;}
    ;
ListExp:
       ListExp ',' Exp                          {$$ = $1;
                                                addSibling($$, $3);}
    |  Exp                                      {$$ = $1;}
    ;
%%

void help() {
    printf("tpcas est un utilitaire qui permet de vérifier si un programme ");
    printf("TCP est correctement formé. L'utilitaire renvoie 0 si aucune ");
    printf("erreur syntaxique n'a été découverte et 1 inversement.\nEn cas ");
    printf("d'erreur la ligne et le numéro de colonne de l'erreur sera ");
    printf("afficher.\nIl est aussi possible d'afficher l'arbre syntaxique du");
    printf(" programme a l'aide de l'option -t ou --tree\n");
    printf("Exemple d'utilisation : \ntpcas < fichier.tpc\n");
    printf("tpcas -t < fichier.tpc");
    printf("tpcas --tree < fichier.tpc");
}

int main(int argc, char* argv[]) {
    if (argc > 2) {
        fprintf(stderr, "Mauvais nombre de paramètre.\n");
        fprintf(stderr, "Un seul paramètre possible parmis : -h --help -t --tree\n");
        return 2;
    } else if (argc == 2 && (strcmp(argv[1], "-t") == 0 || strcmp(argv[1], "--tree") == 0)) {
        display_tree = 1;
    } else if (argc == 2 && (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0)) {
        help();
        return 0;
    } else if (argc == 2) {
        fprintf(stderr, "Paramètre inconnu\n");
        fprintf(stderr, "Un seul paramètre possible parmis : -h --help -t --tree\n");
        return 2;
    }

    return yyparse();
}

