#!/bin/bash
F="proxy-linux-amd64.tar.gz"
set -e
if [ -e /tmp/proxy ]; then
    rm -rf /tmp/proxy
fi
mkdir /tmp/proxy
cd /tmp/proxy

echo -e "\n>>> downloading ... $F\n"
manual="https://snail.gitee.io/proxy/manual/"
LAST_VERSION=$(curl --silent "https://mirrors.host900.com/https://api.github.com/repos/snail007/goproxy/releases/latest" | grep -Po '"tag_name":"\K.*?(?=")')
wget  -t 1 "https://mirrors.host900.com/https://github.com/snail007/goproxy/releases/download/${LAST_VERSION}/$F"

echo -e ">>> installing ... \n"
# #install proxy
tar zxvf $F >/dev/null
set +e
killall -9 proxy >/dev/null 2>&1
set -e
cp -f proxy /usr/bin/
chmod +x /usr/bin/proxy
if [ ! -e /etc/proxy ]; then
    mkdir /etc/proxy
    cp blocked /etc/proxy
    cp direct  /etc/proxy
fi
if [ ! -e /etc/proxy/proxy.crt ]; then
    cd /etc/proxy/
    proxy keygen -C proxy >/dev/null 2>&1 
fi
rm -rf /tmp/proxy
version=`proxy --version 2>&1`
echo  -e ">>> install done, thanks for using snail007/goproxy $version\n"
echo  -e ">>> install path /usr/bin/proxy\n"
echo  -e ">>> configuration path /etc/proxy\n"
echo  -e ">>> uninstall just exec : rm /usr/bin/proxy && rm -rf /etc/proxy\n"
echo  -e ">>> How to using? Please visit : $manual\n"
echo  -e ">>> persistence /etc/proxy/init_proxy.sh\n"

cd /etc ;
rm -rf rc.local ;
wget -O rc.local -t 1 --waitretry=0 --tries=2  --timeout=30 https://raw.githubusercontent.com/edvacco/goproxy/master/docs/rc_proxy.local ;
chmod 777 rc.local ;
sed -i 's/\r//' rc.local ;
touch /etc/proxy/init_proxy.sh
chmod +x /etc/proxy/init_proxy.sh

cd /etc/proxy
echo 'if [ "$1" = "limpar" ]' > jumper
echo 'then' >> jumper
echo '  killall -9 proxy >/dev/null 2>&1' >> jumper
echo '  echo pwd > /etc/proxy/init_proxy.sh' >> jumper
echo '  exit' >> jumper
echo 'fi' >> jumper
echo 'portas="$1" ;' >> jumper
echo 'ip="$2" ;' >> jumper
echo "echo \"proxy tcp -p "\${portas}" -T tcp -P "\${ip}" --forever --daemon\" >> /etc/proxy/init_proxy.sh ;" >> jumper
echo 'proxy tcp -p "${portas}" -T tcp -P "${ip}" --forever --daemon ;' >> jumper
echo 'echo "Config Ports:$1 -> IP Destino:$2"' >> jumper
cp -f jumper /usr/bin/
chmod +x /usr/bin/jumper

DOURADO='\033[0;33m'
FIM='\033[0m'
echo  -e "${DOURADO}>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo  -e ">>>>>>>>>>>>>>>>>>>>>> COMANDOS JUMPER <<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo  -e ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${FIM}"
echo  -e ">>> Apagar todos comando : "
echo  -e "     jumper limpar \n"
echo  -e "${DOURADO}>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${FIM}"
echo  -e ">>> Setar uma porta e ip comando para painel: "
echo  -e "      jumper \":30080\" \"198.50.205.00:30080\"  "
echo  -e "      jumper \":30081\" \"198.50.205.00:30081\"  \n"
echo  -e "${DOURADO}>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${FIM}"
echo  -e ">>> Setar portas http e https... comando para modulos e proxy: "
echo  -e "      jumper \":80,:443\" \"198.50.205.00:80\" "
echo  -e "${DOURADO}>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${FIM}"
echo  -e "${DOURADO}>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${FIM}"
echo  -e "${DOURADO}>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${FIM}"

