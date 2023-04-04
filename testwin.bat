@echo off
path %path%;C:\Program Files\qemu
qemu-system-i386 -fda build\CQX96.img
