#!/bin/bash

echo Build (begin)

### display ghc infomation
ghc -V

### Setting up optimizing flags
if [ x"$DEBUG" = "xtrue" ]; then
    STACK_FLAGS=$STACK_FLAGS" --flag pim-server:debug --flag pim-server:rtsopts "
fi

### Setting up llvm
if [ -n "$LLVM" ]; then
    alias opt=opt-$LLVM
    alias llc=llc-$LLVM
    export STACK_FLAGS=$STACK_FLAGS" --flag pim-server:llvm "
fi

### Setting up threaded
if [ x"$THREADED" = "xtrue" ]; then
    STACK_FLAGS=$STACK_FLAGS" --flag pim-sever:threaded "
fi

### install
stack install pim-server $STACK_FLAGS

echo Build (end)

echo Test (begin)

echo Test (end)
