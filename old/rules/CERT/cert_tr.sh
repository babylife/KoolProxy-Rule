#!/bin/sh

md5=`openssl x509 -subject_hash_old -in ca.cer | head -1`

rm -rf ca.cer  > /dev/null
cp ca.crt ca.cer
cp ca.cer $md5.0
openssl x509 -text -in ca.cer -out /dev/null >> $md5.0
rm -rf ca.cer
