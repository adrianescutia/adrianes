---
title: Installing Kubernetes and Docker in offline scenarios
description: Steps to prepare an environment to install Kubernetes and Docker on Red Hat 7 where it is not possible to access the internet
categories:
  - Kubernetes
---

# Download and Install Docker

YUM performs dependency resolution when installing, updating, and removing software packages, but if you don't have Internet access, you need to install packages with `rpm` command. Many times is very difficult, or tedious to prepare instalation of Linux software when there is no Internet access to repositories, difficulty relies on the fact that RPMs may have many dependiencies and you need to download each of this one by one, sometimes in a try an error approach.

Kubernetes and Docker are going to be installed in a Red Hat 7 server without connectivity to the Internet, if you need to install another software, the process will be the similar, download the packages in your local PC, upload TAR files to the offline server and install packages. You need RHEL with Internet access, but to make it much simply, for this process we are going to use a Centos container as "bridge" to download packages and all their dependencies.

Run the Centos container mounting a volume in your Docker host/PC, then, that path will be used to package all files that will be uploaded to your server with no Internet access.

This process was ran and tested using [WSL](https://docs.microsoft.com/en-us/windows/wsl/about) in the PC with Internet access, the directory used to host files in example is: 
<your_rpm_dir> --> /c/Temp/deleteme

## Download Docker (online machine/Docker host)

```s
docker pull centos:centos7
docker run -d --name centos -v <your_rpm_dir>:/var/rpm_dir centos:centos7
docker exec -it centos /bin/bash

# Now in your Docker container, execute
# Configure YUM so it can download packages correctly
yum install -y yum-utils
# install the Docker repository
yum-config-manager --add-repo \
https://download.docker.com/linux/centos/docker-ce.repo
# download required files
yumdownloader --assumeyes --destdir=/var/rpm_dir/yum --resolve yum-utils
yumdownloader --assumeyes --destdir=/var/rpm_dir/dm --resolve device-mapper-persistent-data
yumdownloader --assumeyes --destdir=/var/rpm_dir/lvm2 --resolve lvm2
yumdownloader --assumeyes --destdir=/var/rpm_dir/docker-ce --resolve docker-ce
yumdownloader --assumeyes --destdir=/var/rpm_dir/se --resolve container-selinux

```

## Download Kubernetes (online machine/Docker host)

```s
# install the Kubernetes repository:
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# download the Kubernetes utilities:
yumdownloader --assumeyes --destdir=/var/rpm_dir/kube --resolve yum-utils kubeadm-1.19.* kubelet-1.19.* kubectl-1.19.* ebtables

```

## Copy the Docker files from the online machine to the offline machine

```s
tar -czvf d4r-k8s.tar.gz /var/rpm_dir
mv d4r-k8s.tar.gz /var/rpm_dir/
# Connect to your offline machine
ssh root@10.100.10.44
mkdir /var/rpm_dir
# In your Docker host
cd /c/Temp/deleteme
scp d4r-k8s.tar.gz root@10.100.10.44:/var/rpm_dir
tar -xzvf d4r-k8s.tar.gz -C /
```

## Install Docker (offline machine)

```s
# Install yum utilities (offline machine)
yum install -y --cacheonly --disablerepo=* /var/rpm_dir/yum/*.rpm
# install Docker file drivers:
yum install -y --cacheonly --disablerepo=* /var/rpm_dir/dm/*.rpm
yum install -y --cacheonly --disablerepo=* /var/rpm_dir/lvm2/*.rpm
# install container-selinux:
yum install -y --cacheonly --disablerepo=* /var/rpm_dir/se/*.rpm
# install Docker:
yum install -y --cacheonly --disablerepo=* /var/rpm_dir/docker-ce/*.rpm
# enable and start docker service:
systemctl enable docker
systemctl start docker
# verify docker:
systemctl status docker
docker version
```

## Install Kubernetes (offline machine)

```s
yum install -y --cacheonly --disablerepo=* /var/rpm_dir/kube/*.rpm
# run kubeadm, which returns a list of required images:
kubeadm config images list
```

A list of required images is displayed, probably with an error, due to the lack of connectivity to Internet:

```s
W1103 10:05:20.147419     653 version.go:102] could not fetch a Kubernetes version from the internet: unable to get URL "https://dl.k8s.io/release/stable-1.txt": Get "https://dl.k8s.io/release/stable-1.txt": dial tcp: lookup dl.k8s.io on 192.168.22.2:53: server misbehaving
W1103 10:05:20.147489     653 version.go:103] falling back to the local client version: v1.19.3
W1103 10:05:20.147648     653 configset.go:348] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
k8s.gcr.io/kube-apiserver:v1.19.3
k8s.gcr.io/kube-controller-manager:v1.19.3
k8s.gcr.io/kube-scheduler:v1.19.3
k8s.gcr.io/kube-proxy:v1.19.3
k8s.gcr.io/pause:3.2
k8s.gcr.io/etcd:3.4.13-0
k8s.gcr.io/coredns:1.7.0
```

## Download and Install Kubernetes Images

In your Docker host (PC), pull and save required Kubernetes images

```s
mkdir docker-images
cd docker-images
# pull the images
docker pull k8s.gcr.io/kube-apiserver:v1.19.3
docker pull k8s.gcr.io/kube-controller-manager:v1.19.3
docker pull k8s.gcr.io/kube-scheduler:v1.19.3
docker pull k8s.gcr.io/kube-proxy:v1.19.3
docker pull k8s.gcr.io/pause:3.2
docker pull k8s.gcr.io/etcd:3.4.13-0
docker pull k8s.gcr.io/coredns:1.7.0
# save images as TAR archives
docker save k8s.gcr.io/kube-apiserver:v1.19.3 > kube-apiserver_v1.19.3.tar
docker save k8s.gcr.io/kube-controller-manager:v1.19.3 > kube-controller-manager_v1.19.3.tar
docker save k8s.gcr.io/kube-scheduler:v1.19.3 > kube-scheduler_v1.19.3.tar
docker save k8s.gcr.io/kube-proxy:v1.19.3 > kube-proxy_v1.19.3.tar
docker save k8s.gcr.io/pause:3.2 > pause_3.2.tar
docker save k8s.gcr.io/etcd:3.4.13-0 > etcd_3.4.13-0.tar
docker save k8s.gcr.io/coredns:1.7.0  > coredns_1.7.0.tar
# Package all TAR files
tar -czvf docker-images.tar.gz 
# copy to offline server
scp docker-images.tar.gz root@10.100.10.44:/var/rpm_dir
```

## Load Kubernetes Images (offline machine)

```s
# extract images
mkdir -p /var/rpm_dir/docker-images
cd /var/rpm_dir/
tar -xzvf docker-images.tar.gz -C /var/rpm_dir/docker-images
# unpack and load images
for x in *.tar; do docker load < $x && echo "loaded from file $x"; done;
```

## Download networking files (online machine)

Flannel is a virtual network that gives a subnet to each host for use with container runtimes.
Doesn't like you Flannel? Check other options [here](https://kubernetes.io/docs/concepts/cluster-administration/networking/).

```s
# download the yaml descriptor
wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
# find the flannel image version
grep image kube-flannel.yml
# download and save the required image (from previous command)
docker pull quay.io/coreos/flannel:v0.13.0
docker save quay.io/coreos/flannel:v0.13.0 > flannel_v0.13.0.tar
# zip the files
tar -czvf flannel_v0.13.0.tar.gz flannel_v0.13.0.tar kube-flannel.yml
#gzip -v flannel_v0.13.0.tar
# copy to offline server
scp flannel_v0.13.0.tar.gz root@10.100.10.44:/var/rpm_dir
```

## Install Kubernetes networking files (offline machine)

```s
cd /var/rpm_dir/
# unpack the networking image:
tar -xzvf flannel_v0.13.0.tar.gz
#gzip -d flannel_v0.13.0.tar.gz
docker load < flannel_v0.13.0.tar
```

## Download NGINX images (online machine)

```s
mkdir nginx
cd nginx
# download yaml descriptor:
wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/ingress-nginx-3.8.0/deploy/static/provider/baremetal/deploy.yaml
# download and save the images:
docker pull k8s.gcr.io/ingress-nginx/controller:v0.41.0
docker pull docker.io/jettech/kube-webhook-certgen:v1.5.0
docker save k8s.gcr.io/ingress-nginx/controller:v0.41.0 > nginx-controller_v0.41.0.tar
docker save docker.io/jettech/kube-webhook-certgen:v1.5.0 > kube-webhook-certgen_v1.5.0.tar
cd ..
tar -czvf nginx.tar.gz nginx
scp nginx.tar.gz root@10.100.10.44:/var/rpm_dir
```

## Load NGINX images (offline machine)

```s
cd /var/rpm_dir/
tar -xzvf nginx.tar.gz -C /var/rpm_dir
cd nginx
# unpack and load images
for x in *.tar; do docker load < $x && echo "loaded from file $x"; done;
```

## Deploying Kubernetes cluster (offline machine)

```s
hostnamectl set-hostname 'sdk8s-master'
# disable swap for the current session or comment out swap partitions or swap file from fstab file
swapoff -a
# Ensure that SELinux is in permissive mode
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
# In case you don’t have your own dns server then update /etc/hosts file on master and worker nodes
192.168.22.8    sdk8s-master
192.168.22.40   sdworker-node1
192.168.22.50   sdworker-node2
# configure kubectl autocompletion:
echo "source <(kubectl completion bash)" >> ~/.bashrc
# Previous steps need to be done on each cluster's machine before continuing
# enable kubelet service
systemctl enable kubelet.service
kubectl version
kubeadm init --pod-network-cidr=10.244.0.0/16 --kubernetes-version=v1.19.3 > ~/kubeadm.init.log
# IMPORTANT: ~/kubeadm.init.log generated file include the token required to join the worker nodes to the cluster

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# verify the node is running:
kubectl get nodes
# configure kubectl to manage your cluster:
grep -q "KUBECONFIG" ~/.bashrc || {
    echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >> ~/.bashrc
    . ~/.bashrc
}

cd /var/rpm_dir/
# initiate the Flannel network in Control Plane node:
kubectl apply -f kube-flannel.yml
# for security reasons, the cluster does not schedule pods on the Control plane node by default.
# In my case, I'm deploying a single node,then, executing this command removes the node-role.kubernetes.io/master 
# taint from any nodes that have it, so that the scheduler can schedule pods everywhere:
kubectl taint nodes --all node-role.kubernetes.io/master-
```

### Join worker nodes to the cluster

```s
# Find the join command string saved in a previous step in file: ~/kubeadm.init.log
kubeadm join 192.168.22.8:6443 --token 49gfys.l4obg3x8flxyc0fr \
    --discovery-token-ca-cert-hash sha256:479203ed42d2884d950ddb81874ea11667788805511b297f3a32c7958fd7fd27
# On the Control plane node machine, verify nodes:
kubectl get nodes
```

References:

* [installation of Genesys Customer Experience Insights](https://docs.genesys.com/Documentation/GCXI/9.0.0/Dep/DockerOffline)
* [How to Install Kubernetes (k8s) 1.7 on CentOS 7 / RHEL 7](https://www.linuxtechi.com/install-kubernetes-1-7-centos7-rhel7/)


## Backup / logs

```s
W1104 18:18:31.401054     851 configset.go:348] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
[init] Using Kubernetes version: v1.19.3
[preflight] Running pre-flight checks
        [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
        [WARNING Service-Kubelet]: kubelet service is not enabled, please run 'systemctl enable kubelet.service'
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local sdk8s-master] and IPs [10.96.0.1 192.168.22.8]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [localhost sdk8s-master] and IPs [192.168.22.8 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [localhost sdk8s-master] and IPs [192.168.22.8 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 9.502572 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.19" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node sdk8s-master as control-plane by adding the label "node-role.kubernetes.io/master=''"
[mark-control-plane] Marking the node sdk8s-master as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: 49gfys.l4obg3x8flxyc0fr
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.22.8:6443 --token 49gfys.l4obg3x8flxyc0fr \
    --discovery-token-ca-cert-hash sha256:479203ed42d2884d950ddb81874ea11667788805511b297f3a32c7958fd7fd27
```