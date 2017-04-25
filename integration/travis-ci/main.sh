#!/bin/bash
set -e

echo Build \(begin\)

### display ghc infomation
ghc -V

### Setting up optimizing flags
if [ x"$DEBUG" = x"true" ]; then
    STACK_FLAGS=$STACK_FLAGS" --flag pim-server:debug --flag pim-server:rtsopts "
fi

### Setting up llvm
if [ -n "$LLVM" ]; then
    alias opt=opt-$LLVM
    alias llc=llc-$LLVM
    export STACK_FLAGS=$STACK_FLAGS" --flag pim-server:llvm "
fi

### Setting up threaded
if [ x"$THREADED" = x"true" ]; then
    STACK_FLAGS=$STACK_FLAGS" --flag pim-server:threaded "
fi

### install
stack install pim-server $STACK_FLAGS

echo Build \(end\)

echo Test \(begin\)

echo Test \(end\)
