#以下命令均已root用户进行操作
cp ./sources.list /etc/apt/sources.list
curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
apt update
#查看docker版本
apt-cache madison docker-ce

#安装指定版本
apt install -y docker-ce=18.03.1~ce~3-0~ubuntu