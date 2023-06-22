AS = /usr/bin/nasm
LD = /usr/bin/ld

CCFLAGS = -g -c -Ofast
ASFLAGS = -g -f elf64
LDFLAGS = -static -z noexecstack

LIBPATH = -L /lib/gcc/x86_64-unknown-linux-gnu/12.2.0 -L /lib
OBJPATH = /usr/lib

LIBS = -lgcc -lgcc_eh -lc -lm

PREOBJ = $(OBJPATH)/crt1.o $(OBJPATH)/crti.o
POSTOBJ = $(OBJPATH)/crtn.o

SRCS_C = main.c process_image/process_image.c
SRCS_S = main.c process_image/process_image_asm.s
HEAD = process_image/process_image.h
OBJS_S = main.o process_image/process_image_asm.o
OBJS_C = main.o process_image/process_image.o

EXE_S = lab_s
EXE_C = lab_c

#all: $(SRCS) $(EXE)

all: s_build

c_build: $(SRCS_C) $(EXE_C)

s_build: $(SRCS_S) $(EXE_S)

clean:
	rm -rf $(EXE_S) $(OBJS_S) $(OBJS_C)

$(OBJS_C): $(HEAD)

$(OBJS_S): $(HEAD)

$(EXE_C): $(OBJS_C)
	$(LD) $(LDFLAGS) $(LIBPATH) $(PREOBJ) $(OBJS_C) $(POSTOBJ) -\( $(LIBS) -\) -o $@

$(EXE_S): $(OBJS_S)
	$(LD) $(LDFLAGS) $(LIBPATH) $(PREOBJ) $(OBJS_S) $(POSTOBJ) -\( $(LIBS) -\) -o $@


.c.o:
	$(CC) $(CCFLAGS) $< -o $@

.s.o:
	$(AS) $(ASFLAGS) $< -o $@

