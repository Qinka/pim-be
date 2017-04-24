#!/bin/bash
set -e
echo The pre-install for pim-be begin

### apt update and install
apt update
echo install
apt install -y `echo $INSTALL_LIST`

### Setting Environment Variables
echo fetch the system\' name
export OS_CORENAME=$(lsb_release -a | grep Codename | awk '{print $2}')
export OS_DISTRIBUTOR=$(lsb_release -a | grep Description | awk '{print $2}')
echo using $OS_DISTRIBUTOR  $OS_CORENAME

### Setting up llvm
if [ -n "$LLVM" ]; then
    echo setting up llvm-$LLVM
    wget -O - http://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add -
    echo deb http://apt.llvm.org/$OS_CORENAME/ llvm-toolchain-$OS_CORENAME main \
	 > /etc/apt/sources.list.d/llvm.list
    echo deb-src http://apt.llvm.org/$OS_CORENAME/ llvm-toolchain-$OS_CORENAME main \
	 > /etc/apt/sources.list.d/llvm.list
    echo deb http://apt.llvm.org/$OS_CORENAME/ llvm-toolchain-$OS_CORENAME-$LLVM main \
	 > /etc/apt/sources.list.d/llvm.list
    echo deb-src http://apt.llvm.org/$OS_CORENAME/ llvm-toolchain-$OS_CORENAME-$LLVM main \
	 > /etc/apt/sources.list.d/llvm.list
    apt update
    apt install -y libllvm-$LLVM-ocaml-dev \
	libllvm$LLVM libllvm$LLVM-dbg \
	lldb-$LLVM \
	llvm-$LLVM \
	llvm-$LLVM-dev \
	llvm-$LLVM-runtime \
	lldb-$LLVM-dev
else
    echo continue without llvm
fi

### Setting up docker
echo login docker as $DOCKER_USERNAME
docker login -e="$DOCKER_EMAIL" -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"

### Setting up stack config file
rm -rf $TRAVIS_BUILD_DIR/stack.yaml
STACK_YAML=$TRAVIS_BUILD_DIR/integration/haskell-stack/`cat $TRAVIS_BUILD_DIR/integration/haskell-stack/list | grep $GHC_VER | awk '{print $2}'`
cp STACK_YAML $TRAVIS_BUILD_DIR/stack.yaml

### Setting up stack
mkdir -p ~/.local/bin
export PATH=$HOME/.local/bin:$PATH
travis_retry curl -L https://www.stackage.org/stack/linux-x86_64 \
    | tar xz --wildcards --strip-components=1 -C ~/.local/bin '*/stack'
stack setup

### End
echo pre-install end






