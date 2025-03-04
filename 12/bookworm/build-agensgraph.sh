#!/bin/bash

set -e

AGENS_VERSION="2.12.1" # CHANGE HERE!
PG_MAJOR="12" # CHANGE HERE!
source_path="/usr/src/agensgraph"
APT_PACKAGES="
  bison
  build-essential
  ca-certificates
  flex
  libreadline-dev
  libssl-dev
  libxml2-dev
  libxml2-utils
  libxslt1-dev
  wget
  xsltproc
  zlib1g-dev
"
# libssl is required by postgres to run
APT_REMOVE_PACKAGES=$(echo "$APT_PACKAGES" | grep -v 'libssl-dev')

# Install system packages
apt update
apt upgrade -y
apt install -y --no-install-recommends $APT_PACKAGES

# Download source
mkdir -p "$source_path"
cd $source_path
url="https://github.com/bitnine-oss/agensgraph/archive/refs/tags/v${AGENS_VERSION}.tar.gz"
wget "$url"
tar xfz $(basename "$url")
rm $(basename "$url")

# Compile, install and remove source
cd "agensgraph-${AGENS_VERSION}"
./configure --with-openssl --prefix=/usr/lib/postgresql/${PG_MAJOR} --datarootdir=/usr/share/postgresql/${PG_MAJOR}
make
make install
sed -i "s/^#listen_addresses =.*/listen_addresses = '*'/" /usr/share/postgresql/${PG_MAJOR}/postgresql.conf.sample
cd /
rm -rf /usr/src/agensgraph

# Cleanup apt packages
apt remove -y $APT_REMOVE_PACKAGES
apt autoremove -y
apt clean
rm -rf /var/lib/apt/lists/*
