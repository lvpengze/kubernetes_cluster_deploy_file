#!/bin/bash
# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

MASTER_ADDRESS=${1:-"192.168.0.10"}
ETCD_SERVERS=${2:-"http://192.168.0.10:2379"}
SERVICE_CLUSTER_IP_RANGE=${3:-"10.254.0.0/16"}
ADMISSION_CONTROL=${4:-"NamespaceLifecycle,NamespaceExists,LimitRanger,SecurityContextDeny,ResourceQuota"}

mkdir -p /etc/kubernetes

cat <<EOF >/etc/kubernetes/config
# --logtostderr=true: log to standard error instead of files
KUBE_LOGTOSTDERR="--logtostderr=true"

# --v=0: log level for V logs
KUBE_LOG_LEVEL="--v=0"

# --allow-privileged=false: If true, allow privileged containers.
KUBE_ALLOW_PRIV="--allow-privileged=true"

# How the controller-manager, scheduler, and proxy find the apiserver
KUBE_MASTER="--master=${MASTER_ADDRESS}:8080"
EOF

cat <<EOF >/etc/kubernetes/apiserver
# --insecure-bind-address=127.0.0.1: The IP address on which to serve the --insecure-port.
KUBE_API_ADDRESS="--insecure-bind-address=0.0.0.0"

# --insecure-port=8080: The port on which to serve unsecured, unauthenticated access.
KUBE_API_PORT="--insecure-port=8080"

# --kubelet-port=10250: Kubelet port
NODE_PORT="--kubelet-port=10250"

# --etcd-servers=[]: List of etcd servers to watch (http://ip:port),
# comma separated. Mutually exclusive with -etcd-config
KUBE_ETCD_SERVERS="--etcd-servers=${ETCD_SERVERS}"

# --advertise-address=<nil>: The IP address on which to advertise
# the apiserver to members of the cluster.
KUBE_ADVERTISE_ADDR="--advertise-address=${MASTER_ADDRESS}"

# --service-cluster-ip-range=<nil>: A CIDR notation IP range from which to assign service cluster IPs.
# This must not overlap with any IP ranges assigned to nodes for pods.
KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=${SERVICE_CLUSTER_IP_RANGE}"


# --admission-control="AlwaysAdmit": Ordered list of plug-ins
# to do admission control of resources into cluster.
# Comma-delimited list of:
#  LimitRanger, AlwaysDeny, SecurityContextDeny, NamespaceExists,
#  NamespaceLifecycle, NamespaceAutoProvision,
#  AlwaysAdmit, ServiceAccount, ResourceQuota, DefaultStorageClass
KUBE_ADMISSION_CONTROL="--admission-control=${ADMISSION_CONTROL}"

# Add your own!
KUBE_API_ARGS=""
EOF

KUBE_APISERVER_OPTS="--admission-control=NamespaceLifecycle,LimitRanger,ResourceQuota --etcd-servers=http://192.168.0.10:2379 --insecure-bind-address=0.0.0.0 --insecure-port=8080 --log-dir=/root/kubernetes/kube-apiserver --logtostderr=false --service-cluster-ip-range=10.254.0.0/16 --v=4 --allow-privileged=true"

cat <<EOF >/usr/lib/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes
After=network.target
After=etcd.service

[Service]
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/apiserver
ExecStart=/usr/bin/kube-apiserver ${KUBE_APISERVER_OPTS}
Restart=on-failure
Type=notify
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF >/etc/kubernetes/controller-manager
###
# The following values are used to configure the kubernetes controller-manager

# defaults from config and apiserver should be adequate

# Add your own!
KUBE_CONTROLLER_MANAGER_ARGS=""
EOF

KUBE_CONTROLLER_MANAGER_OPTS=" --logtostderr=false --log-dir=/root/kubernetes/kube-controller-manager --master=http://192.168.0.10:8080 --leader-elect=true --v=4 "

cat <<EOF >/usr/lib/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/controller-manager
ExecStart=/usr/bin/kube-controller-manager ${KUBE_CONTROLLER_MANAGER_OPTS}
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF >/etc/kubernetes/scheduler
###
# kubernetes scheduler config

# Add your own!
KUBE_SCHEDULER_ARGS=""
EOF

KUBE_SCHEDULER_OPTS="   --log-dir=/root/kubernetes/kube-scheduler \
                        --logtostderr=false \
                        --master=http://192.168.0.10:8080 \
                        --leader-elect=false \
                --v=4
            "

cat <<EOF >/usr/lib/systemd/system/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/scheduler
ExecStart=/usr/bin/kube-scheduler ${KUBE_SCHEDULER_OPTS}
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

