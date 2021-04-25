#!/bin/sh

rm -rf *.md5 > /dev/null

md5sum daily.txt > daily.txt.md5
md5sum koolproxy.txt > koolproxy.txt.md5
md5sum kp.dat > kp.dat.md5

sed -ri 's/(  .*\.txt|  .*kp\.dat)//' *.md5 