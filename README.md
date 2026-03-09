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
kubectl get pods
kubectl exec -it backend -- /bin/sh
ping mysql
(or)
mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE

# From Mysql-PODS

kubectl exec -it mysql-0 -- /bin/bash
mysql -u root -p
curl http://backend:5000

```

Ah! Got it now — you want **production-grade SSL/TLS using a proper CA**, but **without touching your backend source code**. ✅

Good news — this is possible **entirely via Kubernetes and environment configuration** if you use **MySQL client environment variables** or **CA files mounted via Secrets**, so the backend code does not change. Here’s how.

---

## **Step 1: Generate a CA and server certificate**

1. Create a CA:

```bash
openssl genrsa 2048 > ca-key.pem
openssl req -new -x509 -nodes -days 3650 -key ca-key.pem -out ca.pem -subj "/CN=my-cluster-CA"
```

2. Generate MySQL server key & cert signed by your CA:

```bash
openssl genrsa 2048 > server-key.pem
openssl req -new -key server-key.pem -out server.csr -subj "/CN=mysql"
openssl x509 -req -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -days 3650
```

---

## **Step 2: Create a Kubernetes Secret for MySQL TLS**

```bash
kubectl create secret generic mysql-tls \
  --from-file=ca.pem \
  --from-file=server-cert.pem \
  --from-file=server-key.pem
```

---

## **Step 3: Mount TLS certificates into MySQL StatefulSet**

Update your MySQL StatefulSet YAML:

```yaml
volumeMounts:
  - name: mysql-tls
    mountPath: /etc/mysql/tls
volumes:
  - name: mysql-tls
    secret:
      secretName: mysql-tls
args:
  - --ssl-ca=/etc/mysql/tls/ca.pem
  - --ssl-cert=/etc/mysql/tls/server-cert.pem
  - --ssl-key=/etc/mysql/tls/server-key.pem
```

* This ensures **MySQL serves SSL using a trusted CA**.

---

## **Step 4: Configure backend pod to trust the CA**

1. Create a **Secret with CA only**:

```bash
kubectl create secret generic backend-mysql-ca --from-file=ca.pem
```

2. Mount it in your backend pod:

```yaml
volumeMounts:
  - name: mysql-ca
    mountPath: /etc/mysql/ca
volumes:
  - name: mysql-ca
    secret:
      secretName: backend-mysql-ca
```

3. Set environment variable for MySQL CLI (and some connectors automatically read this):

```yaml
env:
  - name: MYSQL_SSL_CA
    value: /etc/mysql/ca/ca.pem
```

* No need to touch the source code — the backend MySQL client or connector **reads this env var automatically** and validates the server certificate.

---

## **Step 5: Restart pods**

```bash
kubectl rollout restart statefulset mysql
kubectl rollout restart deployment backend
```

* Backend now **trusts the MySQL server cert via CA**.

---

## **Step 6: Test connection from backend pod**

```bash
kubectl exec -it backend-55bbdc69f9-nbwsg -- /bin/bash
mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD --ssl-ca=$MYSQL_SSL_CA $MYSQL_DATABASE
```

* Connection works **securely with TLS**.
* **No source code change needed**.

---

✅ **Key Points:**

* MySQL serves a **CA-signed certificate**.
* Backend trusts the CA via **mounted cert & environment variable**.
* Code stays untouched — all config is in **Secrets & Deployment YAML**.
* Internal traffic is secure and production-ready.

---

If you want, I can write a **ready-to-apply YAML snippet** for:

1. MySQL StatefulSet with TLS
2. Backend Deployment with CA mounted and env var
3. Fully production-ready **no code changes**

…so you can just apply it.

Do you want me to do that?




