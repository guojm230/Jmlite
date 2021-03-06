relative_path := $(subst $(source_dir)/,,$(realpath ./))
build_path := $(build_dir)/$(relative_path)

dirs := $(subst ./,,$(shell find ./ -type d))
c_sources := $(foreach dir,$(dirs), $(wildcard $(dir)/*.c))
asm_sources := $(foreach dir,$(dirs), $(wildcard $(dir)/*_s.asm))

kernel_objs := $(patsubst %.asm,%.o,$(asm_sources)) $(patsubst %.c,%.o,$(c_sources))

compile_options := -nostdlib -nodefaultlibs -m32


init_dirs: 
	mkdir -p $(foreach dir,$(dirs),$(build_path)/$(dir) )

mbr:
	nasm boot/mbr.asm -o $(build_path)/boot/mbr.bin
loader:
	nasm boot/bootloader.asm -o $(build_path)/boot/loader.bin

bootloader: init_dirs mbr loader
	cat $(build_path)/boot/mbr.bin $(build_path)/boot/loader.bin  > $(dist_dir)/bootloader.bin

compile_kernel: init_dirs $(kernel_objs)
	echo "build platform kernel"

%.o : %.c
	clang $(compile_options) -c $^ -o $(build_path)/$@ -I $(g_include_dirs)

%_s.o : %_s.asm
	nasm -f elf32 $^ -o $(build_path)/$@