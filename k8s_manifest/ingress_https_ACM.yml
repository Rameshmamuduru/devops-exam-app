apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: backend-ingress
  namespace: default
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80},{"HTTPS": 443}]'
    # ACM certificate ARN for HTTPS
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:738556366563:certificate/e7399529-76ad-424a-b16d-81a0f3e7819f
    # Optional: redirect HTTP → HTTPS
    alb.ingress.kubernetes.io/ssl-redirect: '443'
spec:
  rules:
  - host: myapp.rameshs.online
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: backend
            port:
              number: 5000
