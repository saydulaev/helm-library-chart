{{- define "library.job.defaults" -}}
apiVersion: batch/v1
kind: Job
spec:
  backoffLimit: {{ .backoffLimit | default "1"}}
  activeDeadlineSeconds: {{ .activeDeadlineSeconds | default "180"}}
{{- end -}}