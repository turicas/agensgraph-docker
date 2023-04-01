#!/bin/bash

set -e

source_path="/usr/src/agensgraph"
mkdir -p "$source_path"
cd $source_path
url="https://github.com/bitnine-oss/agensgraph/archive/refs/tags/v2.13.1.tar.gz"
wget "$url"
tar xfz $(basename "$url")
rm $(basename "$url")

cd "agensgraph-2.13.1"
./configure --with-openssl --prefix=/usr/lib/postgresql/13 --datarootdir=/usr/share/postgresql/13
make
make install
sed -i "s/^#listen_addresses =.*/listen_addresses = '*'/" /usr/share/postgresql/13/postgresql.conf.sample
cd /
rm -rf /usr/src/agensgraph
