apiVersion: apps/v1
kind: Deployment
metadata:
  name: bcp
  labels:
    app: bcp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: bcp
  template:
    metadata:
      labels:
        app: bcp
    spec:
      containers:
      - name: bcp
        image: "eu.gcr.io/GOOGLE_CLOUD_PROJECT/blaise-case-processor-k8s:COMMIT_SHA"
        imagePullPolicy: Always
        ports:
        - containerPort: 5000
        livenessProbe:
          httpGet:
            path: /
            port: 5000
        readinessProbe:
          httpGet:
            path: /
            port: 5000
        env:
          - name: SQLALCHEMY_DATABASE_URI
            valueFrom:
              secretKeyRef:
                name: blaise-mysql
                key: dbConnectionString
          - name: API_PATH
            value: https://localhost:5000
          - name: ENV
            value: DEV
          - name: SECRET_KEY
            value: a_secret
          - name: RABBITMQ_EXCHANGE
            value: bsm_exchange
          - name: RABBITMQ_USER
            valueFrom:
              secretKeyRef:
                key: rabbitmq-username
                name: rabbitmq
          - name: RABBITMQ_PASSWORD
            valueFrom:
              secretKeyRef:
                key: rabbitmq-password
                name: rabbitmq
          - name: RABBITMQ_HOST
            value: rabbitmq
          - name: URL_SCHEME
            value: https
---
apiVersion: v1
kind: Service
metadata:
  name: bcp
spec:
  type: NodePort
  selector:
    app: bcp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5000
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.allow-http: "false"
    kubernetes.io/ingress.global-static-ip-name: bcp
    ingress.gcp.kubernetes.io/pre-shared-cert: bcp
  name: bcp
spec:
    backend:
      serviceName: bcp
      servicePort: 80
