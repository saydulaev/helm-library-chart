{{/*
# Secret
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#secret-v1-core
*/}}
{{- define "library.secret.validate" -}}
{{- $top := first . -}}
{{- $secret := fromYaml (include (index . 1) $top) | default (dict ) -}}
apiVersion: v1
kind: Secret
metadata: {{- merge ($secret.metadata | default (dict )) (fromYaml (include "library.metadata.resource" $top)) | toYaml | nindent 2 }}
type: {{ default "Opaque" $secret.type | quote }}
{{- if $secret.data }}
data: {{ toYaml $secret.data | nindent 2 }}
{{- end }}
{{- if $secret.stringData }}
stringData: {{ toYaml $secret.stringData | nindent 2 }}
{{- end }}
immutable: {{ default false $secret.immutable }}
{{- end -}}


{{- define "library.secret" -}}
{{- $top := first . }}
{{- $validateSrc := include "library.secret.validate" (list $top (tpl  (index . 1) $top)) }}
{{- $dest := (include "library.secret.defaults" $top) | fromYaml }}
{{- include "library.util.merge" (dict "top" $top "src" $validateSrc "dest" $dest) -}}
{{- end -}}