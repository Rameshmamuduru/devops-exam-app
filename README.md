## Verify DB:
```
kubectl get pods
kubectl exec -it mysql-0 -- mysql -u root -p
SHOW DATABASES;
SELECT user, host FROM mysql.user;
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
