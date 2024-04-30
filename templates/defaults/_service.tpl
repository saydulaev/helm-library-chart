{{- define "library.service.defaults" -}}
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: 80
      protocol: TCP
{{- end -}}