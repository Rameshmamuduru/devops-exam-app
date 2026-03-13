# Manual Project setup:

## Launch a EC2 instance with large and 30 gb storage
<img width="1365" height="621" alt="image" src="https://github.com/user-attachments/assets/6542fd8c-5ba8-4f4b-bf2d-fdc8d3caee82" />

## Tools installation

```
sudo apt update -y && sudo apt upgrade -y && \
# Install required tools
sudo apt install -y curl unzip apt-transport-https ca-certificates gnupg lsb-release software-properties-common && \

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
sudo apt update -y && sudo apt install -y docker-ce docker-ce-cli containerd.io && \
sudo usermod -aG docker $USER && \

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && rm kubectl && \

# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp && \
sudo mv /tmp/eksctl /usr/local/bin && \

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" && \
unzip /tmp/awscliv2.zip -d /tmp && sudo /tmp/aws/install && rm -rf /tmp/aws /tmp/awscliv2.zip && \
# Check versions
docker --version && kubectl version --client && eksctl version && aws --version

#Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
```
## Create IAM User with admin access and Create a access keys as well and then run below commands

```
aws configure   # cofigure with access and secret key
aws s3 ls        # Verify
```
## Create EKS Cluster using eksctl
```
eksctl create cluster \
  --name my-eks-cluster \
  --region us-east-1 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 3 \
  --managed
```

## ALB Ingress setup

```
# Enable OIDC Provider
eksctl utils associate-iam-oidc-provider \
  --region us-east-1 \
  --cluster my-eks-cluster \
  --approve

# Create IAM Role for
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.14.1/docs/install/iam_policy.json

# Create IAM policy
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

# Create Service Account
eksctl create iamserviceaccount \
    --cluster=my-eks-cluster \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --attach-policy-arn=arn:aws:iam::738556366563:policy/AWSLoadBalancerControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --region us-east-1 \
    --approve

kubectl etl sa -n kube-system

# install AWS LB controller using Helm
helm repo add eks https://aws.github.io/eks-charts
helm repo update eks

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=my-eks-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --version 1.14.0

wget https://raw.githubusercontent.com/aws/eks-charts/master/stable/aws-load-balancer-controller/crds/crds.yaml
kubectl apply -f crds.yaml

# Verify the Controller Deployment
kubectl get deployment -n kube-system

# Expected Output
root@ip-172-31-30-185:/home/ubuntu# kubectl get deployment -n kube-system
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
aws-load-balancer-controller   2/2     2            2           2m6s
coredns                        2/2     2            2           14m
metrics-server                 2/2     2            2           9m29s
root@ip-172-31-30-185:/home/ubuntu# 
```


<img width="1365" height="204" alt="image" src="https://github.com/user-attachments/assets/c9dc2faa-6e88-4d7f-8960-b28b90eaac0c" />

<img width="1359" height="561" alt="image" src="https://github.com/user-attachments/assets/32d3da41-bb4e-46d8-ac15-5e9a4a4a0c38" />

