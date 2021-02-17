#!/bin/bash

for xx in [a-z]*.md
do
    fgrep $xx SUMMARY.md >&/dev/null || echo $xx
done
