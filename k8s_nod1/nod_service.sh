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
NODE_HOSTNAME=${2:-"k8s-nod1"}

mkdir -p /etc/kubernetes

cat <<EOF >/etc/kubernetes/config
# --logtostderr=true: log to standard error instead of files
KUBE_LOGTOSTDERR="--logtostderr=true"

# --v=0: log level for V logs
KUBE_LOG_LEVEL="--v=4"

# --allow-privileged=false: If true, allow privileged containers.
KUBE_ALLOW_PRIV="--allow-privileged=true"

# How the controller-manager, scheduler, and proxy find the apiserver
KUBE_MASTER="--master=${MASTER_ADDRESS}:8080"
EOF

cat <<EOF >/etc/kubernetes/proxy
###
# kubernetes proxy config

# default config should be adequate

# Add your own!
KUBE_PROXY_ARGS=""
EOF

KUBE_PROXY_OPTS="   \${KUBE_LOGTOSTDERR} \\
                    \${KUBE_LOG_LEVEL}   \\
                    \${KUBE_MASTER}    \\
                    \${KUBE_PROXY_ARGS}"

cat <<EOF >/usr/lib/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Proxy
After=network.target

[Service]
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/kube-proxy
ExecStart=/usr/bin/kube-proxy ${KUBE_PROXY_OPTS}
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF >/etc/kubernetes/kubelet
# --address=0.0.0.0: The IP address for the Kubelet to serve on (set to 0.0.0.0 for all interfaces)
KUBELET__ADDRESS="--address=0.0.0.0"

# --port=10250: The port for the Kubelet to serve on. Note that "kubectl logs" will not work if you set this flag.
KUBELET_PORT="--port=10250"

# --hostname-override="": If non-empty, will use this string as identification instead of the actual hostname.
KUBELET_HOSTNAME="--hostname-override=${NODE_HOSTNAME}"

# --api-servers=[]: List of Kubernetes API servers for publishing events, 
# and reading pods and services. (ip:port), comma separated.
KUBELET_API_SERVER="--api-servers=http://${MASTER_ADDRESS}:8080"

# pod infrastructure container
KUBELET_POD_INFRA_CONTAINER="--pod-infra-container-image=registry.access.redhat.com/rhel7/pod-infrastructure:latest"

# Add your own!
KUBELET_ARGS=""
EOF

KUBELET_OPTS="      \${KUBE_LOGTOSTDERR}     \\
                    \${KUBE_LOG_LEVEL}       \\
                    \${KUBELET__ADDRESS}         \\
                    \${KUBELET_PORT}            \\
                    \${KUBELET_HOSTNAME}        \\
                    \${KUBELET_API_SERVER}   \\
                    \${KUBE_ALLOW_PRIV}      \\
                    \${KUBELET_POD_INFRA_CONTAINER}\\
                    \${KUBELET_ARGS}"

mkdir -p /var/lib/kubelet

cat <<EOF >/usr/lib/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
After=docker.service
Requires=docker.service

[Service]
WorkingDirectory=/var/lib/kubelet
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/kubelet
ExecStart=/usr/bin/kubelet ${KUBELET_OPTS} --cluster_dns=10.254.0.3 --cluster_domain=cluster.local --resolv-conf=/run/systemd/resolve/resolv.conf
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

