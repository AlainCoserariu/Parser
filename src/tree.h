/* tree.h */

#define MAX_STRING_SIZE 128

typedef enum {
  type,
  void_type,
  ident,
  order,
  eq,
  addsub,
  divstar,
  num,
  character,
  or,
  and,
  if_type,
  while_type,
  return_type,
  else_type,
  Prog,
  DeclVars,
  Declarateurs,
  DeclFoncts,
  DeclFonct,
  EnTeteFonct,
  Parametres,
  ListTypVar,
  Corps,
  SuiteInstr,
  Instr,
  Exp,
  TB,
  FB,
  M,
  E,
  T,
  F,
  LValue,
  Arguments,
  ListExp
  /* list all other node labels, if any */
  /* The list must coincide with the string array in tree.c */
  /* To avoid listing them twice, see https://stackoverflow.com/a/10966395 */
} label_t;

union values {
    char character;
    int num;
    char* string;
};

typedef enum {
    INTEGER_T,
    CHARACTER_T,
    STRING_T,
    NONE_T
} value_type;

typedef struct Node {
  label_t label;
  union values v;
  struct Node *firstChild, *nextSibling;
  value_type type;
  int lineno;
} Node;


Node *makeNode(label_t label, union values v, value_type t);
void addSibling(Node *node, Node *sibling);
void addChild(Node *parent, Node *child);
void deleteTree(Node*node);
void printTree(Node *node);

#define FIRSTCHILD(node) node->firstChild
#define SECONDCHILD(node) node->firstChild->nextSibling
#define THIRDCHILD(node) node->firstChild->nextSibling->nextSibling
