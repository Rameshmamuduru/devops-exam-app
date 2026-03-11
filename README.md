# Project setup:

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
```
