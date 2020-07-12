# ---------------------------------------------------
# INSTALLING KUBERNETES
# ---------------------------------------------------
echo "================KUBERNETES INSTALLATION STARTS================"
echo "EXECUTING STEP 4 --> INSTALLING KUBERNETES (WAIT FOR FEW MINUTES)"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat >>/etc/apt/sources.list.d/kubernetes.list<<EOF
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update -y -qq && apt-get install -y -qq kubelet kubeadm kubectl >/dev/null 2>&1

# ---------------------------------------------------
# INITIALIZING A SINGLE CONTROL-PLANE CLUSTER
# ---------------------------------------------------
echo "EXECUTING STEP 5 --> INITIALIZING KUBERNETES CLUSTER"

# PULL THE IMAGES
kubeadm config images pull

# START THE CLUSTER >> /root/kubeinit.log 2>/dev/null
kubeadm init --apiserver-advertise-address=172.16.1.100 --pod-network-cidr=192.168.0.0/16 

# ---------------------------------------------------
# COPY THE KUBE ADMIN CONFIG TO USER DIRECTORY
# ---------------------------------------------------
echo "EXECUTING STEP 6 --> COPYING KUBE CONFIG TO USER DIRECTORY"
mkdir /home/vagrant/.kube
cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube

# ---------------------------------------------------
# DEPLOYING CNI
# ---------------------------------------------------
echo "EXECUTING STEP 7 --> DEPLOYING CALICO NETWORK"
su - vagrant -c "kubectl create -f https://docs.projectcalico.org/v3.11/manifests/calico.yaml"

# ---------------------------------------------------
# ALLOWING PODS TO RUN ON MASTER NODE 
# ---------------------------------------------------
echo "EXECUTING STEP 8 --> REMOVING TAINT FROM MASTER NODE TO DEPLOY PODS"
su - vagrant -c "kubectl taint nodes --all node-role.kubernetes.io/master-"
echo "==============COPY AND SAVE THE JOIN TOKEN COMMAND==============="
echo "================KUBERNETES INSTALLATION COMPLETES================"
