# Manual Project setup:

## Launch a EC2 instance with large and 30 gb storage
<img width="1354" height="609" alt="image" src="https://github.com/user-attachments/assets/3482e2c7-c0d4-4b7f-9f1f-acb679a3ee1c" />


## Tools installation
- User the install.sh script to install the tools required

## Create IAM User with admin access and Create a access keys as well and then run below commands

```
aws configure   # cofigure with access and secret key
aws s3 ls        # Verify
```
## Create EKS Cluster using eksctl
```
eksctl create cluster \
  --name devops-exam-app-cluster \
  --region us-east-1 \
  --nodes 2 \
  --node-type t3.medium \
  --managed

```

## ALB Ingress setup

```
# Enable OIDC Provider
eksctl utils associate-iam-oidc-provider \
  --region us-east-1 \
  --cluster devops-exam-app-cluster \
  --approve

# Create IAM Role for
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.14.1/docs/install/iam_policy.json

# Create IAM policy
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

# Create Service Account
eksctl create iamserviceaccount \
    --cluster=devops-exam-app-cluster \
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
  --set clusterName=devops-exam-app-cluster \
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

