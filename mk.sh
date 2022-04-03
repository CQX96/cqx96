echo "MAKE for CQX96"

echo "Assembling..."
nasm -O0 -f bin -o boot.bin main.asm
nasm -O0 -f bin -o build/Setup.img boot/setup.asm
cd main
nasm -O0 -f bin -o ../kernel/cqx96.sys main.asm
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
echo "Mounting disk image..."
rm -rf tmp-loop
mkdir tmp-loop && mount -o loop -t vfat ./CQX96.img tmp-loop && mcopy ../kernel/cqx96.sys tmp-loop/
mcopy ../programs/*.prg tmp-loop
sleep 0.2
echo "Unmounting disk image..."
umount tmp-loop || exit
rm -rf tmp-loop
cat CQX96.img >> Setup.img
truncate -s -512 Setup.img
cd ..
echo Done!
