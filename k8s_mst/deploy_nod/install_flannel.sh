# ## 安装flannel

# #解压
# mkdir temp
# tar xzvf ./flannel-v0.7.1-linux-amd64.tar.gz -C temp

# #拷贝文件
# cp ./temp/flanneld /usr/bin/flanneld
# cp ./temp/mk-docker-opts.sh /usr/bin/mk-docker-opts.sh

# #创建flannel的service文件
# export ETCD_ENDPOINTS="http://192.168.0.10:2379"
# export ETCD_PREFIX="/atomic.io/network"
# export IFACE="ens33"

# cp flanneld.service.template flanneld.service

# sed -i 's#{{ETCD_ENDPOINTS}}#'"$ETCD_ENDPOINTS"'#' ./flanneld.service
# sed -i 's#{{ETCD_PREFIX}}#'"$ETCD_PREFIX"'#' ./flanneld.service
# sed -i 's#{{IFACE}}#'"$IFACE"'#' ./flanneld.service

# #拷贝service文件
# mkdir -p /usr/lib/system/systemd
# mv flanneld.service /usr/lib/system/systemd

# #删除临时文件
# rm -rf ./temp

# #使用mk-docker-opts.sh生成DOCKER_OPTS
# sh /usr/bin/mk-docker-opts.sh

##参照docker.service.bk修改docker.service,之后重启服务