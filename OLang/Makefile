# Check operating system
ifeq ($(OS), Windows_NT)
	OS = windows
else
	UNAME := $(shell uname -s)
	ifeq ($(UNAME), Darwin)
		OS = macos
	else ifeq ($(UNAME), Linux)
		OS = linux
	else
		$(error OS not supported by this Makefile)
	endif
endif

# Compiler and linker settings
OLCHOME = ../../Oberon/oberon-lang/test/oberon
LIB = $(OLCHOME)/lib
INC = .:$(OLCHOME)/include
OLC = $(OLCHOME)/oberon-lang
OLCFLAGS = -O3 -I$(INC) -L$(LIB) -loberon
LDFLAGS = -loberon
ifeq ($(OS), macos)
	CXX = clang
	LDFLAGS += -rpath $(LIB) #@executable_path/lib
else ifeq ($(OS), linux)
	CXX = gcc
	O7CFLAGS += --reloc=pic
	LDFLAGS += -lm -Wl,-rpath,$(LIB)
endif

.DEFAULT_GOAL: all
.PHONY: clean
.PRECIOUS: %.s %.ll

clean:
	@rm -f *.s *.o *.ll *.bc *.smb
ifeq ($(OS), macos)
	@find . -depth 1 -type f ! -name "*.*" -perm +111 -delete
else ifeq ($(OS), linux)
	@find . -maxdepth 1 -type f ! -name "*.*" -executable -delete
endif

all: SOM.o Benchmark.o Random.o Bounce.o List.o Mandelbrot.o NBody.o Permute.o Towers.o Harness.o
	@$(CXX) $(CXXFLAGS) -o run SOM.o Benchmark.o Random.o Bounce.o List.o Mandelbrot.o NBody.o Permute.o Towers.o Harness.o -L$(LIB) $(LDFLAGS)

Harness.o: 
	@$(OLC) $(OLCFLAGS) -c -fenable-main Harness.Mod

% : %.o
	@$(CXX) $(CXXFLAGS) $< -o $@ -L$(LIB) $(LDFLAGS)

%.o : %.Mod
	@$(OLC) $(OLCFLAGS) -c $<

%.s : %.Mod
	@$(OLC) $(OLCFLAGS) -S $<

%.ll : %.Mod
	@$(OLC) $(OLCFLAGS) -S --emit-llvm $<

