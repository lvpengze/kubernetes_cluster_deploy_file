kubectl delete svc heapster monitoring-grafana  monitoring-influxdb -n kube-system
kubectl delete rc heapster influxdb-grafana -n kube-system