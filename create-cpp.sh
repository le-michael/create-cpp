#!/bin/bash
arg1=$1
arg2=$2
err(){
    err=$1
    echo -e "$1"
    exit 1
}
if [ $# -gt 2 ] || [ $# -eq 0 ]; then
    err "Valid argument format:\n -create-cpp [PROJECT-NAME]\n -create-cpp [PATH] [PROJECT-NAME]"
fi

if [ $# -eq 1 ]; then
    path="./"
    proj=$1
else
    path=$1
    proj=$2
fi

if ! grep '^[-0-9a-zA-Z]*$' <<< $proj; then
    err "Valid project name must only contain: [a-z][A-Z][0-9][-]"
fi

mkdir "$path/$proj"
folders=("bin" "build" "doc" "include" "lib" "src" "test")

for folder in "${folders[@]}"
do
    mkdir "$path/$proj/$folder"
done

touch "$path/$proj/Makefile"
makefile="$path/$proj/Makefile"

cat <<EOM >> $makefile
#Make file from https://hiltmon.com/blog/2013/07/03/a-simple-c-plus-plus-project-structure/

CC := g++ # This is the main compiler
# CC := clang --analyze # and comment out the linker last line for sanity
SRCDIR := src
BUILDDIR := build
TARGET := bin/runner
 
SRCEXT := cpp
SOURCES := \$(shell find \$(SRCDIR) -type f -name *.\$(SRCEXT))
OBJECTS := \$(patsubst \$(SRCDIR)/%,\$(BUILDDIR)/%,\$(SOURCES:.\$(SRCEXT)=.o))
CFLAGS := -g # -Wall
INC := -I include

\$(TARGET): \$(OBJECTS); \
    @echo " Linking..."; \
    echo " \$(CC) \$^ -o \$(TARGET) "; \$(CC) \$^ -o \$(TARGET) 
\$(BUILDDIR)/%.o: \$(SRCDIR)/%.\$(SRCEXT); \
    @mkdir -p \$(BUILDDIR); \
    echo " \$(CC) \$(CFLAGS) \$(INC) -c -o \$@ $<"; \$(CC) \$(CFLAGS) \$(INC) -c -o \$@ \$<
clean:; \
    @echo " Cleaning..." ; \
    echo " \$(RM) -r \$(BUILDDIR) \$(TARGET)"; \$(RM) -r \$(BUILDDIR) \$(TARGET)
# Tests
tester:; \
    \$(CC) \$(CFLAGS) test/tester.cpp \$(INC)  -o bin/tester
.PHONY: clean
EOM
