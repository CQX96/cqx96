CQX96
=====

The CQX96 kernel is a free DOS/UNIX like kernel for the intel (x86).

I am going to try to work on CQX96 again...


CQX96 is written in assembly.

All contributions are welcome.




Currently, CQX96 supports the FAT file system.

This kernel has been tested and worked on these computers (using the [example shell](https://github.com/CQX96/cqx96-apps/blob/main/shelltemplate.asm)):
  1. Acer Aspire 3690
  2. Some HP computer I don't know the model

COMPILING
=========
----
Requirements:

A linux machine or WSL2 on windows (you might need to install dosfstools)

NASM

sudo (root privileges)

----

To compile it, execute mk.sh using sudo, like this:

sudo ./mk.sh

After, a file CQX96.img will appear in the build directory.


FEATURES
========

CQX96 has a custom interrupt number: int 96h

It also has FAT filesystem support

Login system, passwords are hashed with MD5

CQX96 DOES NOT COME WITH A SHELL BY DEFAULT!
You can compile the shell template at https://github.com/CQX96/cqx96-apps/blob/main/shelltemplate.asm

NOTE 1
======

This project uses some code from different authors. (people from Stack Overflow and MikeOS)


The snippets from MikeOS are in the include\mike directory (note that we did change some stuff).

NOTE 2
======

This is my second operating system (My first one was very bad).

Technically it is not my second operating system, but others were for learning, so...

