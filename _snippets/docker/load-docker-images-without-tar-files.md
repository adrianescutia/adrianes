# Load Docker images without (tar) uploading them

docker context create 
docker context create mycontext-lab --description "lab registry" --docker "host=ssh://root@registry"

eval `ssh-agent -s`
ssh-add my-server-key.pem

docker context use mycontext-lab
docker pull busybox
docker tag busybox my-registry-ip:5000/busybox
docker --context mycontext-lab push 10.100.10.100:5000/busybox 

**Reference:**  
* https://code.visualstudio.com/docs/containers/ssh