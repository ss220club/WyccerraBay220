#!/bin/bash
set -euo pipefail

MAP=$1

echo Testing $MAP

tools/deploy.sh ci_test

#set the map
cp maps/$MAP.json ci_test/data/next_map.json

cd ci_test
DreamDaemon baystation12.dmb -close -trusted -verbose -params "log-directory=ci"

cd ..

cat ci_test/data/logs/ci/clean_run.lk
