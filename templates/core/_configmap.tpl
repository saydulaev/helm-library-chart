{{/*
# ConfigMap
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#configmap-v1-core
*/}}
{{- define "library.configmap.validate" -}}
{{- $top := first . -}}
{{- $cm := fromYaml (include (index . 1) $top) | default (dict ) -}}
apiVersion: v1
kind: ConfigMap
metadata: {{- merge ($cm.metadata | default (dict )) (fromYaml (include "library.metadata.resource" $top)) | toYaml | nindent 2 }}
{{- with $cm }}
type: {{ default "Opaque" .type | quote }}
{{- if .data }}
data: {{ toYaml .data | nindent 2 }}
{{- end }}
{{- if .binaryData }}
binaryData: {{ toYaml .binaryData | nindent 2 }}
{{- end }}
immutable: {{ default false .immutable }}
{{- end }}
{{- end -}}


{{- define "library.configmap" -}}
{{- $top := first . }}
{{- $validateSrc := include "library.configmap.validate" (list $top (tpl  (index . 1) $top)) }}
{{- $dest := (include "library.configmap.defaults" $top) | fromYaml }}
{{- include "library.util.merge" (dict "top" $top "src" $validateSrc "dest" $dest) -}}
{{- end -}}