{{- define "library.ingress" -}}
{{- if gt (len .) 1 }}
{{- $top := first . }}
{{- $validateSrc := include "library.ingress.validate" (list $top (tpl (index . 1) $top)) }}
{{- $dest := (include "library.ingress.defaults" $top) | fromYaml }}
{{- include "library.util.merge" (dict "top" $top "src" $validateSrc "dest" $dest) -}}
{{- end }}
{{- end -}}


{{/*
# Ingress
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#ingress-v1-networking-k8s-io
*/}}
{{- define "library.ingress.validate" -}}
{{- $top := first . -}}
{{- $ing := fromYaml (include (index . 1) $top) | default (dict ) -}}
apiVersion: networking.k8s.io/v1
kind: Ingress 
metadata: {{ merge ($ing.metadata | default (dict )) (fromYaml (include "library.metadata" $top)) | toYaml | nindent 2 }}
spec: {{ include "library.ingressSpec" (dict "top" $top "spec" $ing.spec) | trim | nindent 2 }}
{{- end -}}


{{/*
# IngressSpec
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#ingressspec-v1-networking-k8s-io
*/}}
{{- define "library.ingressSpec" -}}
{{- $top := .top -}}
{{- with .spec }}
{{- if .defaultBackend }}
defaultBackend: {{ include "library.ingressBackend" .defaultBackend | trim | nindent 2 }}
{{- end }}
{{- if .ingressClassName }}
ingressClassName: {{ tpl .ingressClassName $top | quote }}
{{- end }}
{{- if .rules }}
rules: {{- include "library.ingressRule" (dict "top" $top "rules" .rules) | trim | nindent 0 -}}
{{- end }}
{{- if .tls }}
tls: {{ include "library.ingressTLS" (dict "top" $top "tls" .tls) | trim | nindent 0 }}
{{- end }}
{{- end }}
{{- end -}}


{{/*
# IngressBackend
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#ingressbackend-v1-networking-k8s-io
*/}}
{{- define "library.ingressBackend" -}}
{{- if .resource }}
resource: {{ include "library.TypedLocalObjectReference" .resource | nindent 2 }}
{{- end }}
{{- if .service }}
service:
  name: {{ .service.name | quote }}
  port:
    number: {{ .service.port.number }}
{{- end }}
{{- end -}}


{{/*
# IngressRule
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#ingressrule-v1-networking-k8s-io
*/}}
{{- define "library.ingressRule" -}}
{{- $top := .top -}}
{{- range .rules }}
- host: {{ .host | quote }}
  http:
    paths: {{ include "library.HTTPIngressPath" .http.paths | trim | nindent 4 }}
{{- end }}
{{- end -}}


{{/*
# IngressTLS
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#ingresstls-v1-networking-k8s-io
*/}}
{{- define "library.ingressTLS" -}}
{{- with .tls }}
{{- range . }}
- hosts:
  {{- range .hosts }}
  - {{ . | quote }}
  {{- end }}
  {{- if .secretName }}
  secretName: {{ .secretName | quote }}
  {{- end }}
{{- end }}
{{- end }}
{{- end -}}


{{/*
# HTTPIngressPath
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#httpingresspath-v1-networking-k8s-io
*/}}
{{- define "library.HTTPIngressPath" -}}
{{- range . }}
- path: {{ .path | quote }}
  backend: {{ include "library.ingressBackend" .backend | trim | nindent 4 }} 
  pathType: {{ .pathType | quote }}
{{- end }}
{{- end -}}