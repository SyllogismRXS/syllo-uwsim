#!/bin/bash

pushd ../ >& /dev/null

./clean.sh
rm -rf uwsim

popd >& /dev/null
