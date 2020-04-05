for svc in kube-apiserver kube-controller-manager kube-scheduler; do
    systemctl restart $svc
    systemctl enable $svc
    systemctl status $svc
done

