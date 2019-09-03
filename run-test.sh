#!/bin/bash

export SAXON_HOME=~/tmp/saxon
for xspectest in elifesciences/eLife-JATS-schematron/xspec/*.xspec;
do ~tmp/xspec/bin/xspec.sh -s $xspectest &> result.log
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