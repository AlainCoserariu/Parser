#!/bin/bash

C_PROGRAM="bin/tpcas"

TEST_FOLDER_GOOD="./test/good"
TEST_FOLDER_SYN_ERR="./test/syn-err"

LOG_FILE="test/resultat.log"

rm -f $LOG_FILE

for FILE in "$TEST_FOLDER_GOOD"/*
do
    echo "Execution de $C_PROGRAM sur $FILE"
    ./"$C_PROGRAM" < "$FILE"
    echo "$FILE result : $?" >> $LOG_FILE
done

for FILE in "$TEST_FOLDER_SYN_ERR"/*
do
    echo "Execution de $C_PROGRAM sur $FILE"
    ./"$C_PROGRAM" < "$FILE"
    echo "$FILE result : $?" >> $LOG_FILE
done
