#!/bin/bash -x

rm -rf releases
rm ../src/neao_merge.owl

./build_doc.sh 0.1.0

cd docker
./build.sh

