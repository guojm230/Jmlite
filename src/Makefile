build_path := $(build_dir)

dirs := $(subst ./,,$(shell find ./ -type d))

all_c_sources := $(foreach dir,$(dirs),$(wildcard $(dir)/*.c))
all_c_objs := $(patsubst %.c,%.o,$(all_c_sources))

all_s_sources := $(foreach dir,$(dirs),$(wildcard $(dir)/*_s.asm))
all_s_objs := $(patsubst %.asm,%.o,$(all_s_sources))

all_objs := $(all_c_objs) $(all_s_objs)

c_sources := $(filter-out arch/%,$(all_c_sources))
c_objs := $(patsubst %.c,%.o,$(c_sources))
s_sources := $(filter-out arch/%,$(all_s_sources))
s_objs := $(patsubst %.c,%.o,$(s_sources))

build_all_objs := $(foreach obj,$(all_objs), $(build_path)/$(obj) )

g_include_dirs := $(abspath ./include)

export g_include_dirs

compile_options := -nostdlib -nodefaultlibs -m32
entry_address := 0xC0100000

init_dirs:
	mkdir -p $(foreach dir,$(dirs),$(build_path)/$(dir))

make_kernel: init_dirs $(c_objs) $(s_objs)
	cd $(source_dir)/arch/$(platform) && $(MAKE) compile_kernel
	clang $(compile_options) $(build_all_objs) -o $(dist_dir)/kernel.bin -Wl,-Ttext-segment=$(entry_address)	\

%.o : %.c
	clang $(compile_options) -c $^ -o $(build_path)/$@ -I $(g_include_dirs)

%_s.o : %_s.asm
	nasm -f elf32 $^ -o $(build_path)/$@