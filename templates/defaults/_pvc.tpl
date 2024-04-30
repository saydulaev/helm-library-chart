{{- define "library.persistentVolumeClaim.defaults" -}}
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: default
{{- end -}}