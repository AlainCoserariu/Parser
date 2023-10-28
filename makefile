# makefile pour compiler un projet d'analyseur syntaxique avec flex et bison
# Compile tous les fichier c contenus dans le dossier src

CC = gcc
CFLAGS = -Wall -Wfatal-errors -pedantic
LDFLAGS = -lfl

EXEC = bin/tpcas

CFILES = $(wildcard src/*.c)
OBJFILES = $(patsubst src/%.c, obj/%.o, $(CFILES))

$(EXEC) : obj/lexer.yy.o obj/parser.o
	$(CC) $^ $(LDFLAGS) -o $@

obj/lexer.yy.c : src/lexer.lex
	flex -o $@ src/lexer.lex

obj/parser.c : src/parser.y
	bison $< -o obj/parser.c -d

obj/lexer.yy.o : obj/lexer.yy.c obj/parser.o
	$(CC) $(CFLAGS) $< -o $@ -c

obj/parser.o : obj/parser.c
	$(CC) $(CFLAGS) $< -o $@ -c

clean :
	rm -f obj/*
	rm -f bin/*
