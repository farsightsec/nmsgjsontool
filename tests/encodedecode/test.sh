#!/usr/bin/env bash

NMSGJSONTOOL="../../scripts/nmsgjsontool"
JSONIN=json-fsi.txt
ENCODEOUT=test.nmsg
DECODEOUT=test.json
NMSGTOOL=nmsgtool
JSONCNT=`wc -l $JSONIN | awk '{print $1}'`

$NMSGJSONTOOL -E $JSONIN -w $ENCODEOUT
if [ -s $ENCODEOUT ]; then
    echo "01 PASS: $ENCODEOUT is `ls -nl $ENCODEOUT | awk '{print $5}'` bytes"
else
    echo "01 FAIL"
    exit
fi

NMSGCNT=`$NMSGTOOL -r $ENCODEOUT | grep "base encode" | wc -l | awk '{print $1}'`

if [ $NMSGCNT -eq $JSONCNT ]; then
    echo "02 PASS: $ENCODEOUT has $NMSGCNT NMSGs ($JSONIN has $JSONCNT records)"
else
    echo "02 FAIL: $ENCODEOUT has $NMSGCNT NMSGs ($JSONIN has $JSONCNT records)"
fi


$NMSGJSONTOOL -D $ENCODEOUT > $DECODEOUT
if [ -s $DECODEOUT ]; then
    echo "03 PASS: $DECODEOUT is `ls -nl $DECODEOUT | awk '{print $5}'` bytes"
else
    echo "03 FAIL"
    exit
fi

DIFF=`diff $DECODEOUT $JSONIN`

if [[ -z $DIFF ]]; then
    echo "04 PASS: encoded JSON to NMSG and back to original JSON"
else
    echo "04 FAIL: encoded JSON to NMSG and back to different JSON: $DIFF"
fi

rm $DECODEOUT $ENCODEOUT
