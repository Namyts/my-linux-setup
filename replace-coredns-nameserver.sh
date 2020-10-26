k get -n kube-system cm coredns -o yaml | awk '{gsub(/(forward \. ([0-9]{1,3}\.?){4})/,"forward . '"$(dns)"'"); print }' | k apply -f - #update nameserver in config maps
pod=$(k get pods -n kube-system | awk '{print $1}' | grep coredns)
k delete pod -n kube-system $pod