# Nmsgjsontool
This is the NMSG JSON tool (`njt`). It is a Python-based convenience tool used
to do the following:

 * Encode JSON into NMSG PDUs as `base`:`encode`(JSON)
 * Decode NMSG `base`:`encode`(JSON) PDUs to presentation format JSON

A full writeup on `njt` is available on the [Farsight Security Blog](https://www.farsightsecurity.com/Blog/20150506-mschiffm-nmsg-nmsgjsontool/).

## Command Summary
`njt` can be invoked in a few different ways and has several options,
everything is described below.

    $ ./scripts/njt --help
    usage: njt [-h] (-e | -d) [-c COUNT] [-w OUT_FILE] [-p] [-z]
                        [--setsource SETSOURCE] [-V] [-v]
                        [--setoperator SETOPERATOR] [--setgroup SETGROUP]
                        [in_file]

    Serialize JSON as base:encode(JSON) NMSG PDUs or deserialize base:encode(JSON)
    NMSG PDUs to JSON

    positional arguments:
      in_file               input file, also accepts input from pipeline

    optional arguments:
      -h, --help            show this help message and exit
      -e, --encode          encode JSON --> NMSG
      -d, --decode          encode NMSG --> JSON
      -c COUNT, --count COUNT
                            stop after count payloads
      -w OUT_FILE, --out_file OUT_FILE
                            write NMSG data to file
      -p, --prettyprint     pretty print JSON output
      -z, --zlibout         compress NMSG output
      --setsource SETSOURCE
                            set payload source
      -V, --verbose         print debugging information
      -v, --version         show program's version number and exit
      --setoperator SETOPERATOR
                            set payload operator
      --setgroup SETGROUP   set payload group

## Encoding Examples
Some encoding examples are provided below.

### Read presentation file
`in_file`

The source file from which to read data. Input can be specified in a number of
ways, as per the following:

#### A positional file argument:

    $ njt -e tests/encodedecode/test.jsonl

#### Output of a pipeline:

    $ cat tests/encodedecode/test.jsonl | njt -e
    $ echo '{"count": 1}' | njt -e

#### Redirect input from a file:

    $ njt -e < json.txt

#### Specify ASCII text at the command line:

    $ njt -e^M
    {"count": 1}^D^D

### Write NMSG file
`-w filename`

Name of binary NMSG output file. If omitted, default is `njt.out.<epoch>.nmsg`.

### Compress output
`-z`

Compress the output payloads.

### Set source ID
`--setsource sourceid`

Set the source ID for the payloads, should be a hex number.

### Set operator ID
`--setoperator operator`

Set the operator ID for the payloads, should have an entry in the `nmsg.opalias`
file.

### Set group ID
`--setgroup group`

Set the group ID for the payloads, should have an entry in the `nmsg.gralias`
file.

### Verbose
`-V`

Write debug messages to the console.

### Version
`-v`

Print version.

## Decoding base:encode(JSON) NMSG PDUs
Some decoding examples are provided below.

### Read NMSG file
`input_file`

The source file from which to read NMSG data. Input can be specified as a
positional file or as a pipeline.

#### A positional file argument:

    $ njt -d json.nmsg

#### Output of a pipeline:

    $ cat json.nmsg | njt -d

### Count
`-c count`

Only process `count` payloads.

## Examples
`njt` can be invoked using a file or as part of a pipeline.

### Input from a file
Write `base`:`encode`(JSON) NMSGs to file, set source and operator, use
`nmsgtool` to verify two payloads

    $ njt -e json.txt --setsource 0xdeadbeef --setoperator FSI

    $ nmsgtool -r njt.out.1423857733.67.nmsg -c 2
    [181] [2015-04-26 21:24:53.119086027] [1:11 base encode] [deadbeef] [FSI] [] 
    type: JSON
    payload: <BYTE ARRAY LEN=176>

    [184] [2015-04-26 21:24:53.119126081] [1:11 base encode] [deadbeef] [FSI] [] 
    type: JSON
    payload: <BYTE ARRAY LEN=179>

### Pipelining
Write `base`:`encode`(JSON) NMSGs to specified file, get debug output:

    $ cat tests/encodedecode/test.jsonl | njt -e -w json.nmsg -V
    wrote 176 byte payload
    wrote 179 byte payload
    wrote 675 byte payload
    wrote 982 byte payload
    wrote 894 byte payload
    wrote 877 byte payload
    wrote 826 byte payload
    wrote 810 byte payload
    wrote 707 byte payload
    wrote 675 byte payload
    wrote 658 byte payload
    wrote 644 byte payload
    wrote 605 byte payload
    wrote 591 byte payload
    wrote 610 byte payload
    wrote 589 byte payload
    wrote 576 byte payload
    wrote 555 byte payload
    wrote 538 byte payload
    wrote 521 byte payload
    wrote 504 byte payload
    wrote 487 byte payload
    wrote 470 byte payload
    wrote 453 byte payload
    wrote 436 byte payload
    wrote 419 byte payload
    wrote 333 byte payload
    wrote 352 byte payload
    wrote 407 byte payload
    wrote 607 byte payload
    wrote 535 byte payload
    wrote 177 byte payload
    wrote 197 byte payload
    Finished, wrote 18065 bytes in 33 payloads to json.nmsg


### Pipeline `njt` as per the following:

    $ echo '{"count":1}' | njt -e --setsource 0x4e110  | nmsgtool -r -
    [16] [2015-04-26 21:26:51.739906072] [1:11 base encode] [0004e110] [] [] 
    type: JSON
    payload: <BYTE ARRAY LEN=12>

### Read NMSGs to a network listener:
Busier pipelines are available to `njt`. Set up an `nmsgtool` listener:

    $ nmsgtool -l 127.0.0.1/9430

Issue a `DNSDB` query, encode the returned JSON as NMSG and use `nmsgtool` to
write the payloads to the network:

    $ dnsdb_query.py -r farsightsecurity.com -j -l1 | njt -e | nmsgtool -r - -s 127.0.0.1/9430

And `nmsgtool` emits:

    [244] [2015-04-26 21:29:04.044215917] [1:11 base encode] [00000000] [] [] 
    type: JSON
    payload: <BYTE ARRAY LEN=239>

### Read NMSGs from Farsight's Security Internet Exchange (SIE)
Using `njt`, you can decode live data from SIE:

    $ nmsgtool -c 1 -C ch42 --unbuffered -w - | njt -d -p
    {
        "Alert": {
            "AdditionalData": [
                {
                    "content": "0",
                    "meaning": "direction"
                },
                {
                    "content": "1",
                    "meaning": "anon"
                },
                {
                    "content": "1",
                    "meaning": "version"
                },
                {
                    "content": "apr 26 13:41:51 10.128.0.1 %asa-5-305013: asymmetric nat rules matched for forward and reverse flows; connection for tcp src publicipdmz2:10.153.116.32/57745 dst hosted:10.153.119.200/80 denied due to nat reverse path failure",
                    "meaning": "raw"
                }
            ],
            "Analyser": {
                "Node": {
                    "name": "MzcwOGU3.YjdjYWU3"
                },
                "analyserid": "ThreatSTOP"
            },
            "CreateTime": {
                "content": "2015-04-26T13:41:51Z",
                "ntpstamp": "0x553ceb1f.0x00000000"
            },
            "Source": {
                "Node": {
                    "Address": {
                        "address": "10.153.116.32",
                        "category": "ipv4-addr"
                    },
                    "Service": {
                        "ip_version": "4",
                        "lana_protocol_name": "tcp",
                        "port": "57745",
                        "protocol": ""
                    }
                }
            },
            "Target": {
                "Node": {
                    "Address": {
                        "address": "10.153.119.200",
                        "category": "ipv4-addr"
                    },
                    "Service": {
                        "ip_version": "4",
                        "lana_protocol_name": "tcp",
                        "port": "80",
                        "protocol": ""
                    }
                }
            },
            "messageid": "TS-1430055711-1025"
        }
    }

### Pipelining with jq
As an additional convenience, `njt` supports pipelining directly into
[`jq`](http://stedolan.github.io/jq/), for filtering of JSON output:

    $ njt -d test.nmsg | jq ".rrtype"
    "MX"
    "NS"
    "NS"
    "NS"
    "A"
    "A"
    "NS"
    "NS"
    "NS"
    "NS"
    "NS"
    "SOA"
    "SOA"
    "SOA"
    "SOA"
    "SOA"
