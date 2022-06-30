#!/bin/bash
graphics_support="y"
login_system="y"
ignore_panics="n"
load_screen="n"
md5_hash="y"
multi_device="y"



echo "MAKE for CQX96"
echo "Preprocessing configuration..."
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
