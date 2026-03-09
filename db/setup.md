Perfect — let’s make this **crystal clear**, step by step, so you can have a **Primary-Replica MySQL setup in Kubernetes** using a StatefulSet. I’ll assume **2 pods** for simplicity.

---

## **Step 0: Pre-requisites**

* Kubernetes cluster running
* `kubectl` configured
* PersistentVolume (PV) or StorageClass ready for MySQL pods

---

## **Step 1: Create a Headless Service**

A headless service lets pods talk to each other by stable hostnames (required for replication).

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql
  labels:
    app: mysql
spec:
  clusterIP: None        # Headless service
  selector:
    app: mysql
  ports:
    - port: 3306
      name: mysql
```

> Save as `mysql-headless-service.yaml` and apply:

```bash
kubectl apply -f mysql-headless-service.yaml
```

---

## **Step 2: Create the StatefulSet**

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: "mysql"
  replicas: 2
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        env:
          - name: MYSQL_ROOT_PASSWORD
            valueFrom:
              secretKeyRef:
                name: mysql-secret
                key: MYSQL_ROOT_PASSWORD
          - name: MYSQL_DATABASE
            valueFrom:
              secretKeyRef:
                name: mysql-secret
                key: MYSQL_DATABASE
          - name: MYSQL_USER
            valueFrom:
              secretKeyRef:
                name: mysql-secret
                key: MYSQL_REPLICATION_USER
          - name: MYSQL_PASSWORD
            valueFrom:
              secretKeyRef:
                name: mysql-secret
                key: MYSQL_REPLICATION_PASSWORD
        ports:
          - containerPort: 3306
volumeClaimTemplates:
  - metadata:
      name: mysql-persistent-storage
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
```

* This creates **2 pods**: `mysql-0` and `mysql-1`
* Each pod has its **own PV**

Apply it:

```bash
kubectl apply -f mysql-statefulset.yaml
```

---

## **Step 3: Initialize Primary (mysql-0)**

1. Connect to primary pod:

```bash
kubectl exec -it mysql-0 -- mysql -uroot -pStrongRootPass123
```

2. Enable binary logging for replication:

```sql
SHOW VARIABLES LIKE 'log_bin';
-- If off, edit my.cnf or use env MYSQL_LOG_BIN=ON in StatefulSet
```

3. Create replication user:

```sql
CREATE USER 'repl_user'@'%' IDENTIFIED BY 'ReplPass123';
GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'%';
FLUSH PRIVILEGES;
```

---

## **Step 4: Configure Replica (mysql-1)**

1. Connect to replica pod:

```bash
kubectl exec -it mysql-1 -- mysql -uroot -pStrongRootPass123
```

2. Set up replication:

```sql
CHANGE MASTER TO
  MASTER_HOST='mysql-0.mysql.default.svc.cluster.local',
  MASTER_USER='repl_user',
  MASTER_PASSWORD='ReplPass123',
  MASTER_PORT=3306,
  MASTER_AUTO_POSITION=1;

START SLAVE;
SHOW SLAVE STATUS\G
```

* `MASTER_HOST` = **headless service + pod name of primary**

---

## **Step 5: Verify**

* On primary (`mysql-0`):

```sql
SHOW MASTER STATUS;
```

* On replica (`mysql-1`):

```sql
SHOW SLAVE STATUS\G
```

You should see `Slave_IO_Running: Yes` and `Slave_SQL_Running: Yes` ✅

---

## **Step 6: Notes for Production**

1. Kubernetes alone **does not automatically promote replicas** if primary fails.
2. For automatic failover and scaling, use a **MySQL Operator** (Percona XtraDB, Oracle MySQL Operator).
3. Always use **PVCs** to persist data — without them, pods lose data on restart.
4. Consider **separate config for my.cnf** to enable replication, GTID, and binary logging.

---

If you want, I can give you a **ready-to-use YAML for a 2-pod StatefulSet with replication enabled automatically**, so you just apply it and the primary/replica setup is done.



kubectl create secret generic mysql-secret \
  --from-literal=MYSQL_ROOT_PASSWORD=StrongRootPass123 \
  --from-literal=MYSQL_DATABASE=mydb \
  --from-literal=MYSQL_USER=myuser \
  --from-literal=MYSQL_PASSWORD=MyUserPass123 \
  --from-literal=MYSQL_REPLICATION_USER=repl_user \
  --from-literal=MYSQL_REPLICATION_PASSWORD=ReplPass123

Do you want me to do that?
