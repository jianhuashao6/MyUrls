#!/bin/bash

if [[ "$(. /etc/os-release && echo "$ID")" == "ubuntu" ]]; then
  echo -e "\033[32m ubuntu \033[0m"
elif [[ "$(. /etc/os-release && echo "$ID")" == "debian" ]]; then
  echo -e "\033[32m debian \033[0m"
else
   echo -e "\033[31m 不支持该系统 \033[0m"
   exit 1
fi

export arch=$(arch)
if [[ $arch == "x86_64" || $arch == "x64" || $arch == "amd64" ]]; then
  ARCH_PRINT="amd64"
elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
  ARCH_PRINT="arm64"
else
  echo -e "\033[31m 不支持此系统,只支持x86_64和arm64的系统 \033[0m"
  exit 1
fi

apt-get update

git clone https://github.com/CareyWang/MyUrls /root/MyUrls
chmod -R +x /root/MyUrls

apt-get remove golang-go
apt-get remove --auto-remove golang-go
rm -rf /usr/local/go

wget -c https://github.com/281677160/MyUrls/releases/download/v1.10/go1.18.2.linux-${ARCH_PRINT}.tar.gz -O /root/go1.18.2.linux-${ARCH_PRINT}.tar.gz

tar -zxvf /root/go1.18.2.linux-${ARCH_PRINT}.tar.gz -C /usr/local/

cat >>"/etc/profile" <<-EOF
export PATH=$PATH:/usr/local/go/bin
EOF

source /etc/profile

go version

apt-get install -y gcc automake autoconf libtool make

cd /root/MyUrls

make install
make all

mkdir -p myurls
cp -Rf  public myurls/public

cp -Rf build/myurls-linux-amd64 myurls/
tar -czvf myurls-linux-amd64.tar.gz myurls
mv myurls-linux-amd64.tar.gz build/
rm build/myurls-linux-amd64
rm -rf myurls/*
