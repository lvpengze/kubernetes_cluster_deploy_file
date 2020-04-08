for svc in docker kubelet kube-proxy; do 
    systemctl restart $svc
    systemctl enable $svc
    systemctl status $svc
done

