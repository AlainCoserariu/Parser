/* tree.c */
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "tree.h"
extern int lineno;       /* from lexer */

static const char *StringFromLabel[] = {
  "type",
  "void",
  "ident",
  "order",
  "eq",
  "addsub",
  "divstar",
  "num",
  "character",
  "OR",
  "AND",
  "IF",
  "WHILE",
  "RETURN",
  "ELSE",
  "Prog",
  "DeclVars",
  "Declarateurs",
  "DeclFoncts",
  "EnTeteFonct",
  "Parametres",
  "ListTypeVar",
  "Corps",
  "SuiteInstr",
  "Instr",
  "Exp",
  "TB",
  "FB",
  "M",
  "E",
  "T",
  "F",
  "LValue",
  "Arguments",
  "ListExp",
  /* list all other node labels, if any */
  /* The list must coincide with the label_t enum in tree.h */
  /* To avoid listing them twice, see https://stackoverflow.com/a/10966395 */
};

Node *makeNode(label_t label, union values v, value_type t) {
  Node *node = malloc(sizeof(Node));
  if (!node) {
    printf("Run out of memory\n");
    exit(1);
  }
  node->label = label;
  node->type = t;
  
  if (t == STRING_T) {
    node->v.string = (char*) malloc(sizeof(char) * (MAX_STRING_SIZE + 1));
    if (!node->v.string) {
      fprintf(stderr, "allocation impossible, fin du programme");
      exit(2);
    }

    strcpy(node->v.string, v.string);
  } else {
    node->v = v;
  }
  
  node-> firstChild = node->nextSibling = NULL;
  node->lineno=lineno;
  return node;
}

void addSibling(Node *node, Node *sibling) {
  Node *curr = node;
  while (curr->nextSibling != NULL) {
    curr = curr->nextSibling;
  }
  curr->nextSibling = sibling;
}

void addChild(Node *parent, Node *child) {
  if (parent->firstChild == NULL) {
    parent->firstChild = child;
  }
  else {
    addSibling(parent->firstChild, child);
  }
}

void deleteTree(Node *node) {
  if (node->firstChild) {
    deleteTree(node->firstChild);
  }
  if (node->nextSibling) {
    deleteTree(node->nextSibling);
  }
  free(node);
}

void printTree(Node *node) {
  static bool rightmost[128]; // tells if node is rightmost sibling
  static int depth = 0;       // depth of current node
  for (int i = 1; i < depth; i++) { // 2502 = vertical line
    printf(rightmost[i] ? "    " : "\u2502   ");
  }
  if (depth > 0) { // 2514 = L form; 2500 = horizontal line; 251c = vertical line and right horiz 
    printf(rightmost[depth] ? "\u2514\u2500\u2500 " : "\u251c\u2500\u2500 ");
  }

  if (node->type == NONE_T) {
    printf("%s", StringFromLabel[node->label]);
  } else {
    printf("%s : ", StringFromLabel[node->label]);
  }

  if (node->type == INTEGER_T) {
    printf("%d", node->v.num);
  } else if (node->type == CHARACTER_T) {
    printf("%c", node->v.chararcter);
  } else if (node->type == STRING_T) {
    printf("%s", node->v.string);
  }
  
  printf("\n");
  depth++;
  for (Node *child = node->firstChild; child != NULL; child = child->nextSibling) {
    rightmost[depth] = (child->nextSibling) ? false : true;
    printTree(child);
  }
  depth--;
}
