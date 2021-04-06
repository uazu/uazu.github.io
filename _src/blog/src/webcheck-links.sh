#!/bin/bash

OUT=/tmp/webcheck-$$

webcheck -o $OUT file://$PWD/../../../blog

w3m $OUT/index.html
rm -r $OUT
