#!/bin/bash

set -e
mkdir -p /usr/src/agensgraph

cd /usr/src/agensgraph
wget https://github.com/bitnine-oss/agensgraph/releases/download/v2.1.3/AgensGraph_v2.1.3_linux_CE.tar.gz
tar xfz AgensGraph_v2.1.3_linux_CE.tar.gz
rm AgensGraph_v2.1.3_linux_CE.tar.gz

./configure --prefix=/usr/lib/postgresql/10 --datarootdir=/usr/share/postgresql/10
make
make install
sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/share/postgresql/10/postgresql.conf.sample
rm -rf /usr/src/agensgraph
