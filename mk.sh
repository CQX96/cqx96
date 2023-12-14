#!/bin/bash
graphics_support="y"
login_system="y"
ignore_panics="n"
load_screen="n"
md5_hash="y"
multi_device="y"



echo "MAKE for CQX96"
echo "Preprocessing configuration..."
# Check if config.txt exists
if [ ! -f config.txt ]; then
   echo "config.txt not found!"
   echo "Please run ./config.sh first!"
   exit
fi
# Read config.txt
while read line
do
   if [ "$line" == "graphics_support=y" ]; then
      graphics_support="y"
   fi
   if [ "$line" == "graphics_support=n" ]; then
      graphics_support="n"
   fi
   if [ "$line" == "login_system=y" ]; then
      login_system="y"
   fi
   if [ "$line" == "login_system=n" ]; then
      login_system="n"
   fi
   if [ "$line" == "ignore_panics=y" ]; then
      ignore_panics="y"
   fi
   if [ "$line" == "ignore_panics=n" ]; then
      ignore_panics="n"
   fi
   if [ "$line" == "load_screen=y" ]; then
      load_screen="y"
   fi
   if [ "$line" == "load_screen=n" ]; then
      load_screen="n"
   fi
   if [ "$line" == "md5_hash=y" ]; then
      md5_hash="y"
   fi
   if [ "$line" == "md5_hash=n" ]; then
      md5_hash="n"
   fi
   if [ "$line" == "multi_device=y" ]; then
      multi_device="y"
   fi
   if [ "$line" == "multi_device=n" ]; then
      multi_device="n"
   fi
done < config.txt
config=""
if [ "$graphics_support" == "y" ]; then
   config="$config -dGRAPHICS_SUPPORT=1"
fi
if [ "$login_system" == "y" ]; then
   config="$config -dLOGIN_SYSTEM=1"
fi
if [ "$ignore_panics" == "y" ]; then
   config="$config -dIGNORE_PANICS=1"
fi
if [ "$load_screen" == "y" ]; then
   config="$config -dLOAD_SCREEN=1"
fi
if [ "$md5_hash" == "y" ]; then
   config="$config -dMD5_HASH=1"
fi
if [ "$multi_device" == "y" ]; then
   config="$config -dMULTI_DEVICE=1"
fi
echo "Assembling..."
nasm -O0 -f bin -o boot.bin main.asm
cd main
nasm -O0$config -f bin -o ../kernel/cqx96.sys main.asm
cd ../programs
rm *.prg
for i in *.asm
do
	nasm -O0 -w+orphan-labels -f bin $i -o `basename $i .asm`.prg || exit
done

echo "Copying bootsector to disk image..."
cd ..
cd build
rm CQX96.img
mkdosfs -C CQX96.img 1440
dd status=noxfer conv=notrunc if=../boot.bin of=CQX96.img
echo "Copying files to disk image..."
mcopy -i CQX96.img ../kernel/cqx96.sys ::/
mcopy -i CQX96.img ../programs/*.prg ::/
cd ..
echo Done!
