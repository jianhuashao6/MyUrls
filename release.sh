#!/bin/bash

export arch=$(arch)
if [[ $arch == "x86_64" || $arch == "x64" || $arch == "amd64" ]]; then
  ARCH_PRINT="amd64"
  MYURLS_ARCH="myurls-linux-amd64"
elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
  ARCH_PRINT="arm64"
  MYURLS_ARCH="myurls-arrch64"
else
  echo -e "\033[31m 不支持此系统,只支持x86_64和arm64的系统 \033[0m"
  exit 1
fi

if [[ "$(. /etc/os-release && echo "$ID")" == "ubuntu" ]]; then
  echo -e "\033[32m ${ARCH_PRINT}_ubuntu \033[0m"
elif [[ "$(. /etc/os-release && echo "$ID")" == "debian" ]]; then
  echo -e "\033[32m ${ARCH_PRINT}_debian \033[0m"
else
   echo -e "\033[31m 不支持该系统 \033[0m"
   exit 1
fi

apt-get update
apt-get install -y socat curl wget git sudo

apt-get remove -y golang-go
apt-get remove -y --auto-remove golang-go
rm -rf /usr/local/go

wget -c https://golang.google.cn/dl/go1.15.15.linux-${ARCH_PRINT}.tar.gz -O /root/go1.15.15.linux-${ARCH_PRINT}.tar.gz

tar -zxvf /root/go1.15.15.linux-${ARCH_PRINT}.tar.gz -C /usr/local/

cat >>"/etc/profile" <<-EOF
export PATH=$PATH:/usr/local/go/bin
EOF

source /etc/profile

apt-get install -y gcc automake autoconf libtool make

if [[ `go version |grep -c "go1.15.15"` == '1' ]]; then
  rm -rf /root/go1.15.15.linux-${ARCH_PRINT}.tar.gz
  echo "go环境部署完成"
else
  rm -rf /usr/local/go
  echo "go环境部署失败"
  exit 1
fi

rm -rf /root/MyUrls
git clone https://github.com/CareyWang/MyUrls /root/MyUrls
if [[ $? -ne 0 ]];then
  echo -e "\033[31m MyUrls源码下载失败，请检查网络 \033[0m"
  exit 1
fi
chmod -R +x /root/MyUrls

cd /root/MyUrls

make install
make all

mkdir -p myurls
cp -Rf public myurls/public

cp -Rf build/${MYURLS_ARCH} myurls/linux-${ARCH_PRINT}-myurls
tar -czvf linux-${ARCH_PRINT}-myurls.tar.gz myurls
mv linux-${ARCH_PRINT}-myurls.tar.gz build/linux-${ARCH_PRINT}-myurls.tar.gz
rm build/linux-${ARCH_PRINT}-myurls
rm -rf myurls/*
