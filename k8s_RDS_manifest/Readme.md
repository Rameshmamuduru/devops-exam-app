# Setup:

## Create an RDS Mysql DB
```
ssh to EC2
apt install mysql-client -y
mysql -h database-1.chwk0ee0ig63.ap-south-1.rds.amazonaws.com -P 3306 -u admin -p

CREATE USER 'appuser'@'%' IDENTIFIED BY 'StrongPassword123';
GRANT ALL PRIVILEGES ON devops_exam.* TO 'appuser'@'%';
FLUSH PRIVILEGES;
SELECT user, host FROM mysql.user;

mysql> SELECT user, host FROM mysql.user;
+--------------------+-----------+
| user               | host      |
+--------------------+-----------+
| admin              | %         |
| appuser            | %         |
| appyuser           | %         |
| rds_superuser_role | %         |
| mysql.infoschema   | localhost |
| mysql.session      | localhost |
| mysql.sys          | localhost |
| rdsadmin           | localhost |
+--------------------+-----------+
8 rows in set (0.01 sec)

```

## Create a cluster 

## create a secret for 
- MYSQL_HOST
- MYSQL_USER
- MYSQL_PASSWORD
- MYSQL_DATABASE

```
kubectl create secret generic mysql-secret \
  --from-literal=MYSQL_HOST=database-1.chwk0ee0ig63.ap-south-1.rds.amazonaws.com \
  --from-literal=MYSQL_USER=appuser \
  --from-literal=MYSQL_PASSWORD=StrongPassword123 \
  --from-literal=MYSQL_DATABASE=devops_exam

```
<img width="1361" height="271" alt="image" src="https://github.com/user-attachments/assets/8251fd68-c23d-458e-9637-807e26b934b7" />

## Update the Backend manifest
