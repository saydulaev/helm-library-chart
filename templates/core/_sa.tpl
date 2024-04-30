{{- define "library.serviceaccount" -}}
{{- $top := first . -}}
{{- $sa := fromYaml (include (index . 1) $top) | default (dict ) -}}
apiVersion: v1
kind: ServiceAccount
metadata: {{- merge ($sa.metadata | default (dict )) (fromYaml (include "library.metadata.resource" $top)) | toYaml | nindent 2 }}
{{- if hasKey $sa "automountServiceAccountToken" }}
automountServiceAccountToken: {{ $sa.automountServiceAccountToken }}
{{- end }}
{{- if $sa.imagePullSecrets }}
imagePullSecrets: {{ toYaml $sa.imagePullSecrets | nindent 0 }}
{{- end }}
{{- if $sa.secrets }}
secrets: {{ toYaml $sa.secrets | nindent 0 }}
{{- end }}
{{- end }}