{{/*
# Toleration
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#toleration-v1-core
*/}}
{{- define "library.Toleration" -}}
{{- range . }}
- operator: {{ .operator | quote }}
  {{- if .effect }}
  effect: {{ .effect | quote }}
  {{- end }}
  key: {{ default "" .key | quote }}
  {{- if .tolerationSeconds }}
  tolerationSeconds: {{ .tolerationSeconds | int }}
  {{- end }}
  value: {{ default "" .value | quote }}
{{- end }}
{{- end -}}