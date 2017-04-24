#!/bin/bash
set -e
echo After success \(begin\)

### Setting up docker
if [ x"$DOCKER" = "xtrue" ]; then
    ### Setting tag
    if [ -n "$TRAVIS_TAG" ]; then
	export VERSION=pim-server-$TRAVIS_TAG
    else
	export VERSION=pim-server-$TRAVIS_BRANCH-${TRAVIS_COMMIT:0:7}
    fi
    export OS_INFO=$(uname)-$OS_DISTRIBUTOR-$OS_CORENAME-GHC_$GHC_VER-$(uname -m)
    export IMAGE_TAG=$VERSION-$OS_INFO
    if [ -n "$LLVM" ]; then
	export IMAGE_TAG=$IMAGE_TAG-llvm-$LLVM
    fi
    if [ x"$THREADED" = "xtrue" ]; then
	export IMAGE_TAG=$IMAGE_TAG-threaded
    fi
    if [ x"$DEBUG" = "xtrue" ]; then
	export IMAGE_TAG=$IMAGE_TAG-debug
	export DEBUG_EXT=.debug
    fi
    ### Coping files
    cd $TRAVIS_BUILD_DIR
    mkdir -p docker.tmp/bin
    cp $HOME/.local/bin/pim-server docker.tmp/bin
    cp $TRAVIS_BUILD_DIR/integration/dockerfiles/hub.dockerfile$DEBUG_EXT docker.tmp/Dockerfile
    ## Build and push
    docker build -t qinka/pim-be:$IMAGE_TAG .
    docker push qinka/pim-be
fi
echo After success \(end\)
