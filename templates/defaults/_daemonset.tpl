{{- define "library.daemonset.defaults" -}}
apiVersion: apps/v1
kind: DaemonSet
spec:
  selector:
    matchLabels: {{ include "library.selectorLabels" . | trim | nindent 6 }}
  template:
    metadata:
      labels: {{ include "library.selectorLabels" . | trim | nindent 8 }}
    spec:
      tolerations:
      # these tolerations are to have the daemonset runnable on control plane nodes
      # remove them if your control plane nodes should not run pods
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      serviceAccountName: {{ include "library.fullname" . }}
      imagePullSecrets:
      - name: {{ include "library.fullname" . }}
      containers:
      - name: {{ include "library.fullname" . }}
        image: {{ include "library.container.defaultImage" . }}
        resources:
          limits:
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 200Mi
        volumeMounts: []
        # - name: varlog
        #   mountPath: /var/log
      # it may be desirable to set a high priority class to ensure that a DaemonSet Pod
      # preempts running Pods
      # priorityClassName: important
      terminationGracePeriodSeconds: 30
      volumes: []
      # - name: varlog
      #   hostPath:
      #     path: /var/log
{{- end -}}