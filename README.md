## Creation/setup for TLS:

### Create certificate (CA)
```
openssl genrsa -out ca.key 2048

openssl req -x509 -new -nodes \
-key ca.key \
-subj "/CN=mysql-ca" \
-days 365 \
-out ca.crt
```
### Create a DB Certificate
```
openssl genrsa -out server.key 2048
```
### Create request
```
openssl req -new \
-key server.key \
-subj "/CN=mysql.default.svc.cluster.local" \
-out server.csr
```
### Sign it with CA
```
openssl x509 -req \
-in server.csr \
-CA ca.crt \
-CAkey ca.key \
-CAcreateserial \
-out server.crt \
-days 365
```

**now we have**
ca.crt
server.crt
server.key

## Create Kubernetes Secret
```
kubectl create secret generic mysql-tls \
--from-file=ca.crt \
--from-file=server.crt \
--from-file=server.key
```

## Create MySQL ConfigMap
```yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
data:
  my.cnf: |
    [mysqld]
    ssl-ca=/etc/mysql/tls/ca.crt
    ssl-cert=/etc/mysql/tls/server.crt
    ssl-key=/etc/mysql/tls/server.key
    require_secure_transport=ON


kubectl apply -f mysql-config.yaml

```
## Apply secret and comfig map yml and then Deploy MySQL Pod and create a headless

## Verify DB:
```
kubectl get pods
kubectl exec -it mysql-0 -- mysql -u root -p
SHOW DATABASES;
SELECT user, host FROM mysql.user;
```

<img width="1355" height="568" alt="image" src="https://github.com/user-attachments/assets/301bf9cb-8034-442e-bbf4-492a7c278a37" />

## Dns resolve test for DB-pods
```
kubectl run -it --rm --image=busybox:1.35 dns-test -- sh
nslookup mysql-0.mysql.default.svc.cluster.local
nslookup mysql.default.svc.cluster.local   # if using normal service
```


## Verify conncetion between backend to DB:
```
mysql -h mysql-0.mysql.default.svc.cluster.local -u root -p \
      --ssl-ca=/etc/ca/ca.crt --ssl-mode=REQUIRED
```
<img width="1364" height="216" alt="image" src="https://github.com/user-attachments/assets/cab043fa-c33a-4fa3-b416-5d8deb9091d2" />

