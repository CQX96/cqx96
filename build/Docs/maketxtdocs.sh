#!/bin/bash

# GOOMBADocgen for CQX96
# Copyright (c) 2022 GoombaProgrammer


DOCOUT=docs.html
SHELLF=SH
SOURCE=".ASM"
KERNEL=CQX96
PROGEX=".PRG"
FSUSAG="FAT"
PANICS=("No shell found!")
PANICD=("there is no shell")
DOCTYP=("Programs" "Filesystem")
DOCCON=("There are $(ls ../../programs/*.prg | wc -l) programs that come with ${KERNEL}, these are $(find ../../programs/*.prg -type f -printf '%f, ')more info on these later." "${KERNEL} uses the ${FSUSAG} file system.")

DOCUMENTATION=""

DOCUMENTATION+="Welcome to the documentation for the ${KERNEL} kernel!\n\n"
DOCUMENTATION+="1. Shells\n"
DOCUMENTATION+="You may see the error message '${PANICS[0]}', this is because ${PANICD[0]}.\n"
DOCUMENTATION+="To fix this, you can create a shell or use the template, call it '${SHELLF}${SOURCE}'.\n"
DOCUMENTATION+="It should output a new file called ${SHELLF}${PROGEX}.\n"
DOCUMENTATION+="\n"
I=1
Y=0
for t in ${DOCTYP[@]}; do
  I=$((I+1))
  DOCUMENTATION+="$I. $t\n"
  DOCUMENTATION+=${DOCCON[$Y]}
  DOCUMENTATION+="\n\n"
  Y+=1
done
for f in ../../programs/*.prg; do
  I=$((I+1))
  upperstr=$(echo $(basename $f) | tr '[:lower:]' '[:upper:]')
  DOCUMENTATION+="$I. $upperstr\n"
  line=$(awk "NR==2" ../../programs/$(basename $f .prg).asm)
  DOCUMENTATION+="Program name: ${line:7}"
  read -r line < ../../programs/$(basename $f .prg).asm
  DOCUMENTATION+="${line:7}"
  DOCUMENTATION+="\n\n"
done
printf "$DOCUMENTATION"	> rawdocs.txt
