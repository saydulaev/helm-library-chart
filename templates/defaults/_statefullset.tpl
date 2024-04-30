{{- define "library.statefulset.defaults" -}}
apiVersion: apps/v1
kind: StatefulSet
spec:
  selector:
    matchLabels: {{ include "library.selectorLabels" . | trim | nindent 6 }}
  serviceName: {{ include "library.fullname" . }}
  replicas: 1
  minReadySeconds: 10
  template:
    metadata:
      labels: {{ include "library.selectorLabels" . | trim | nindent 6 }}
    spec:
      terminationGracePeriodSeconds: 10
      containers:
      - name: {{ include "library.fullname" . }}
        image: {{ include "library.container.defaultImage" . }}
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/www
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "default"
      resources:
        requests:
          storage: 1Gi
{{- end -}}