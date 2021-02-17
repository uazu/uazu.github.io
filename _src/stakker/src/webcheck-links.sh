#!/bin/bash

OUT=/tmp/webcheck-$$

webcheck -o $OUT file://$PWD/../../../stakker

w3m $OUT/index.html
rm -r $OUT
