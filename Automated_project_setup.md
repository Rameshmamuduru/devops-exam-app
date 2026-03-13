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
## Setup Jenkins
- Access soanrqube on port <ec2_public_ip:8000>
<img width="975" height="484" alt="image" src="https://github.com/user-attachments/assets/34ef2a54-46cf-4e36-aa3c-66eab437c526" />
- install required plugins
- Once done with the setup generate a PAT in GitHub and update that in jenkins global credentials
- in the same way create Docker hub access token as well and update in the jenkins global credentials
```
sonarqube scanner, sonar quality gates and all docker plugins
```
## Setup SonarQube:
- Access soanrqube on port <ec2_public_ip:9000>
- Create access token
- update access token in Jenkind global credentials
- Create a webhook in sonarqube

## Jenksins Tools and System configaration
- Configure the tools section for sonar-scanner and docker
- configure the system cinfigaration for Sonarqube server
  
## Create EKS Cluster using eksctl
```
eksctl create cluster \
  --name devops-exam-app-cluster \
  --region us-east-1 \
  --nodes 1 \
  --node-type t3.medium \
  --managed

```
<img width="1364" height="492" alt="image" src="https://github.com/user-attachments/assets/e649d08e-c028-4213-babd-2b9ac61448a0" />


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

kubectl get sa -n kube-system

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
```
# Expected Output
```
jenkins@ip-172-31-37-33:~$ kubectl get deployment -n kube-system
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
aws-load-balancer-controller   2/2     2            2           42s
coredns                        2/2     2            2           10m
metrics-server                 2/2     2            2           5m27s

```


<img width="1365" height="204" alt="image" src="https://github.com/user-attachments/assets/c9dc2faa-6e88-4d7f-8960-b28b90eaac0c" />

<img width="1359" height="561" alt="image" src="https://github.com/user-attachments/assets/32d3da41-bb4e-46d8-ac15-5e9a4a4a0c38" />


## Installation/Setup For Argo CD
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### Expected Output
```
NAME                                               READY   STATUS    RESTARTS      AGE
argocd-application-controller-0                    1/1     Running   0             80s
argocd-applicationset-controller-974d64569-vv6h2   1/1     Running   0             84s
argocd-dex-server-66fc67645-zrsvh                  1/1     Running   2 (63s ago)   83s
argocd-notifications-controller-5474d4cbb6-4zlgs   1/1     Running   0             83s
argocd-redis-6888c8c66f-mbmkk                      1/1     Running   0             82s
argocd-repo-server-6c4975f4ff-69m7d                1/1     Running   0             81s
argocd-server-5f7ff864d5-h757z                     1/1     Running   0             81s
```
### Expose ArgoCD to Browser
```
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
kubectl get svc -n argocd

#expected Output
NAME                                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
argocd-applicationset-controller          ClusterIP   10.100.129.190   <none>        7000/TCP,8080/TCP            4m32s
argocd-dex-server                         ClusterIP   10.100.42.7      <none>        5556/TCP,5557/TCP,5558/TCP   4m31s
argocd-metrics                            ClusterIP   10.100.119.183   <none>        8082/TCP                     4m30s
argocd-notifications-controller-metrics   ClusterIP   10.100.47.106    <none>        9001/TCP                     4m30s
argocd-redis                              ClusterIP   10.100.240.24    <none>        6379/TCP                     4m29s
argocd-repo-server                        ClusterIP   10.100.161.156   <none>        8081/TCP,8084/TCP            4m29s
argocd-server                             NodePort    10.100.163.230   <none>        80:32487/TCP,443:31194/TCP   4m28s
argocd-server-metrics                     ClusterIP   10.100.230.125   <none>        8083/TCP                     4m27s

```
* Allow port 32487 in the node security group and  access it on <http://node_public_ip:32487>
* To get the intial password
```
kubectl get secrets -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode
```
<img width="1354" height="658" alt="image" src="https://github.com/user-attachments/assets/b5a697cf-dc85-4a38-a103-bdbb4fc35f58" />

## Apply Secrets and configmaps:
```
kubectl create namespace dev
kubectl create namespace stage
kubectl create namespace prod
kubectl apply -f secrets.yml -n dev
kubectl apply -f secrets.yml -n stage
kubectl apply -f secrets.yml -n prod
kubectl apply -f cinfigmap.yml -n dev
kubectl apply -f cinfigmap.yml -n stage
kubectl apply -f cinfigmap.yml -n prod
```
** secrets.yml and cofgmap.yml was there in k8s_manifets folder
===============================================================================================================================================================
***NOTE: For Secrets.yml - change the MYSQL_HOST: according Mysql service and host name if not updated you can not submit your exam. it means your backend can not make a communication with DB***
===============================================================================================================================================================


## For test Manually cretaed App for Dev in Argo CD

<img width="1365" height="666" alt="image" src="https://github.com/user-attachments/assets/66f193ad-eac1-41ee-95cd-2588b5a1ba06" />

<img width="1365" height="413" alt="image" src="https://github.com/user-attachments/assets/cc3222ba-2b31-4a85-bd97-f2d80a20434b" />

<img width="1365" height="700" alt="image" src="https://github.com/user-attachments/assets/7457bc72-78ab-48e6-be3f-0b47ab43c215" />

## ArgoCD App for seperate environment:
- create seperate repository to have the single source of truth
- you can follw ths below folder struture
```
argo-apps/                       # Optional: Argo CD App manifests per environment
├── dev-app.yaml                 # Argo CD app for Dev cluster
├── stage-app.yaml               # Argo CD app for Stage cluster
└── prod-app.yaml                # Argo CD app for Prod cluster
```
- yaml file will be

```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: Argo-dev
  namespace: argocd
spec:
  project: default
  source:
    repoURL: <Path/to/github>
    targetRevision: <which/brach/to/target>
    path:
      helm:
        valueFiles:
          - values_dev.yaml
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: dev
    syncPolicy:
      automated:
        prune: true
        selfHeal: true

```

