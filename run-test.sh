#!/bin/bash

#export SAXON_HOME=/home/travis/tmp/saxon
echo "SAXON_HOME=$SAXON_HOME"
for xspectest in test/xspec/*.xspec;
do /home/travis/tmp/xspec/bin/xspec.sh -s $xspectest &> result.log
    if grep -q ".*failed:\s[1-9]" result.log || grep -q -E "\*+\sError\s(running|compiling)\sthe\stest\ssuite" result.log;
        then
            echo "FAILED: $xspectest";
            echo "---------- result.log";
            cat result.log;
            echo "----------";
            exit 1;
        else echo "OK: $xspectest";
    fi
done