ARCH = armv7-a
MCPU = cortex-a8

CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
LD = arm-none-eabi-ld
OC = arm-none-eabi-objcopy

LINKER_SCRIPT = ./robin.ld

ASM_SRCS := $(wildcard ./boot/*.S)
ASM_OBJS := $(patsubst ./boot/%.S, ./build/%.o, $(ASM_SRCS))

test:
	@echo $(ASM_SRCS)
	@echo $(ASM_OBJS)

robin = build/robin.axf
robin_bin = build/robin.bin

.PHONY: all clean run debug gdb

all: $(robin)

clean:
	@rm -rf build

run: $(robin)
	qemu-system-arm -M realview-pb-a8 -kernel $(robin)

debug: $(robin)
	qemu-system-arm -M realview-pb-a8 -kernel $(robin) -S -gdb tcp::1234,ipv4

gdb:
	arm-none-eabi-gdb

$(robin): $(ASM_OBJS) $(LINKER_SCRIPT)
	$(LD) -n -T $(LINKER_SCRIPT) -o $(robin) $(ASM_OBJS)
	$(OC) -O binary $(robin) $(robin_bin)

build/%.o: boot/%.S
	mkdir -p $(shell dirname $@)
	$(AS) -march=$(ARCH) -mcpu=$(MCPU) -g -o $@ $<
