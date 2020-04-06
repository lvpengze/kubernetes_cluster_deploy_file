kubectl create -f ./
kubectl exec busybox -- nslookup redis-master
kubectl exec busybox -- nslookup www.baidu.com