#!/bin/sh

if [ -z ${GITHUB_ENV+x} ]; then GITHUB_ENV=/dev/null; fi

export BYOND_MAJOR=515
echo "BYOND_MAJOR=$BYOND_MAJOR" >> "$GITHUB_ENV"
export BYOND_MINOR=1623
echo "BYOND_MINOR=$BYOND_MINOR" >> "$GITHUB_ENV"

export RUST_G_VERSION=3.0.0
echo "RUST_G_VERSION=$RUST_G_VERSION" >> "$GITHUB_ENV"
export SPACEMAN_DMM_VERSION=suite-1.8
echo "SPACEMAN_DMM_VERSION=$SPACEMAN_DMM_VERSION" >> "$GITHUB_ENV"
