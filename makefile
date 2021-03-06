dist_dir := $(realpath ./dist)
build_dir := $(realpath ./build)
root_dir := $(realpath ./)
source_dir := $(realpath ./src)
platform := i386
export dist_dir build_dir root_dir source_dir platform

all: bootloader kernel
	cat $(dist_dir)/bootloader.bin $(dist_dir)/kernel.bin > $(dist_dir)/Jmlite.bin
	rm $(dist_dir)/bootloader.bin $(dist_dir)/kernel.bin

source_dirs := $(dir $(wildcard ./src/*))

cpp_sources := $(foreach dir,$(source_dirs),$(wildcard $(dir)/*.cpp))


compile_options := -nostdlib -nodefaultlibs -m32

bootloader:
	cd $(source_dir)/arch/$(platform) && $(MAKE) bootloader

kernel:
	cd $(source_dir) && $(MAKE) make_kernel


test:
	cd $(source_dir)/arch/$(platform) && $(MAKE) loader

clean:
	rm -rf $(dist_dir)/*
	rm -rf $(build_dir)/*