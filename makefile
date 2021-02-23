mbr:
	nasm ./src/arch/x86/boot/mbr_s.asm -o ./dist/mbr.img
	nasm ./src/arch/x86/boot/bootloader_s.asm -o ./dist/bootloader.img
	cat ./dist/mbr.img ./dist/bootloader.img  > ./dist/loader.img;