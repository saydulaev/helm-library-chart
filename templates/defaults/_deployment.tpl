{{/*
Deployment default template.
*/}}
{{- define "library.deployment.defaults" -}}
apiVersion: apps/v1
kind: Deployment
spec:
  replicas: 1
  template:
    spec:
      # securityContext:
      #   runAsUser: 1000
      #   runAsGroup: 3000
      #   fsGroup: 2000
      #   fsGroupChangePolicy: "OnRootMismatch"
      containers:
      - name: {{ .Release.Name }}-defaults
        imagePullPolicy: Always
        image: {{ include "library.container.defaultImage" . }}
        env:
        - name: "TZ"
          value: "Europe/Moscow"
        ports:
        - containerPort: 80
          protocol: TCP
        resources:
          limits:
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 200Mi
        livenessProbe:
          httpGet:
            path: "/status"
            port: 80
          timeoutSeconds: 3
          failureThreshold: 5
          initialDelaySeconds: 30
        readinessProbe:
          httpGet:
            path: "/rediz"
            port: 80
          timeoutSeconds: 3
          failureThreshold: 5
          initialDelaySeconds: 30
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: node-role.kubernetes.io/control-plane
                operator: DoesNotExist
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 1
            preference:
              matchExpressions:
              - key: kubernetes.io/os
                operator: In
                values:
                - linux
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app.kubernetes.io/name
                  operator: In
                  values:
                  - '{{ include "library.fullname" . }}'
                - key: app.kubernetes.io/instance
                  operator: In
                  values:
                  - "{{ .Release.Name }}"
              topologyKey: kubernetes.io/host
            weight: 100
      tolerations:
      # - effect: NoExecute
      #   key: node-role.kubernetes.io/control-plane
      #   operator: Exists
      # - effect: NoSchedule
      #   key: node-role.kubernetes.io/control-plane
      #   operator: Exists
      - effect: NoExecute
        key: node.kubernetes.io/not-ready
        operator: Exists
        tolerationSeconds: 300
      - effect: NoExecute
        key: node.kubernetes.io/unreachable
        operator: Exists
        tolerationSeconds: 300
{{- end -}}
