# init_network [address] [gateway] [nameserver]
#sed 's/要被取代的字串/新的字串/g' 文件名
address=${1}
gateway=${2}
nameserver=${3}

cp 50-cloud-init.yaml.template 50-cloud-init.yaml
sed -i 's#{{address}}#'$address'#g' ./50-cloud-init.yaml
sed -i 's#{{gateway}}#'$gateway'#g' ./50-cloud-init.yaml
sed -i 's#{{nameserver}}#'$nameserver'#g' ./50-cloud-init.yaml

mv 50-cloud-init.yaml /etc/netplan/

netplan apply