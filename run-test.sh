#!/bin/bash
if [ -z $SAXON_HOME ]; then
    export SAXON_HOME=$PWD/validator/saxon
fi

for xspectest in test/xspec/*.xspec;do 
    if [[ "$xspectest" == *schematron* ]]; then ./xspec/bin/xspec.sh -s $xspectest &> result.log
        if [ $? -ne 0 ] || grep -q ".*failed:\s[1-9]" result.log || grep -q -E "\*+\sError\s(running|compiling)\sthe\stest\ssuite" result.log;
            then
                echo "FAILED: $xspectest";
                echo "---------- result.log";
                cat result.log;
                echo "----------";
                exit 1;
        else echo "OK: $xspectest";
        fi
    else ./xspec/bin/xspec.sh $xspectest &> result.log
        if [ $? -ne 0 ] || grep -q ".*failed:\s[1-9]" result.log || grep -q -E "\*+\sError\s(running|compiling)\sthe\stest\ssuite" result.log;
            then
                echo "FAILED: $xspectest";
                echo "---------- result.log";
                cat result.log;
                echo "----------";
                exit 1;
        else echo "OK: $xspectest";
        fi
    fi
done