{{- define "library.cronJob.defaults" -}}
apiVersion: batch/v1
kind: CronJob
spec:
  schedule: {{ default "* * * * *" .schedule | quote }}
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: {{ .Release.Namespace }}
          # priorityClassName: {{ .Values.priorityClassName | quote }}
          # hostAliases: []
          # volumes: []
          restartPolicy: "OnFailure"
          containers:
          - name: {{ .Chart.Name }}
            image: "{{ .Values.image.name }}:{{ .Values.image.tag }}"
            imagePullPolicy: IfNotPresent
            command:
            {{- range .command }}
              - {{ . }}
            {{- end }}
            args:
            {{- range .args }}
              - {{ . }}
            {{- end }}
            env:
            - name: "TZ"
              value: "Europe/Moscow"
              restartPolicy: OnFailure
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
          - effect: NoExecute
            key: node-role.kubernetes.io/control-plane
            operator: Exists
          - effect: NoSchedule
            key: node-role.kubernetes.io/control-plane
            operator: Exists
          - effect: NoExecute
            key: node.kubernetes.io/not-ready
            operator: Exists
            tolerationSeconds: 300
          - effect: NoExecute
            key: node.kubernetes.io/unreachable
            operator: Exists
            tolerationSeconds: 300
{{- end -}}