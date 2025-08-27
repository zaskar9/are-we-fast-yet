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
OLCFLAGS = -v -c -O3 -I$(INC) -L$(LIB) -loberon
LDFLAGS = -loberon
ifeq ($(OS), macos)
	CXX = clang
	LDFLAGS += -rpath @executable_path/lib
else ifeq ($(OS), linux)
	CXX = gcc
	O7CFLAGS += --reloc=pic
	LDFLAGS += -lm -Wl,-rpath,$(LIB)
endif

.PHONY: clean
.PRECIOUS: %.s %.ll

clean:
	@rm -f *.s *.o *.ll *.bc *.smb
ifeq ($(OS), macos)
	@find . -depth 1 -type f ! -name "*.*" -perm +111 -delete
else ifeq ($(OS), linux)
	@find . -maxdepth 1 -type f ! -name "*.*" -executable -delete
endif

% : %.o
	@$(CXX) $(CXXFLAGS) $< -o $@ -L$(LIB) $(LDFLAGS)

%.o : %.Mod
	@$(OLC) $(OLCFLAGS) $<

%.s : %.Mod
	@$(OLC) $(OLCFLAGS) -S $<

%.ll : %.Mod
	@$(OLC) $(OLCFLAGS) -S --emit-llvm $<
