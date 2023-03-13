#!/bin/sh
set -e

pip -q install s3cmd

touch largefile.raw
size=$(shuf -i 300-600 -n 1)
head -c "$size"m /dev/urandom > largefile.raw

yes | /shared/crypt4gh encrypt -p /shared/c4gh.pub.pem -f largefile.raw

s3cmd -c /shared/s3cfg put largefile.raw.c4gh s3://dummy_gdi.eu
