## Verify DB:
```
kubectl get pods
kubectl exec -it mysql-0 -- mysql -u root -p
SHOW DATABASES;
SELECT user, host FROM mysql.user;
```
