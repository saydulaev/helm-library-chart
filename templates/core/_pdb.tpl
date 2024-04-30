{{- define "library.pdb" }}
---
{{- $top := first . }}
{{- if $top.Capabilities.APIVersions.Has "policy/v1" }}
{{- $validateSrc := include "library.pdb.PodDisruptionBudge" (list $top (tpl  (index . 1) $top)) }}
{{- $dest := (include "library.pdb.defaults" $top) | fromYaml }}
{{- include "library.util.merge" (dict "top" $top "src" $validateSrc "dest" $dest) -}}
{{- else }}
# {{ printf "The Kubernetes cluster does not has the capabilities: %s" "policy/v1" }}
{{- end }}
{{- end -}}


{{/*
# PodDisruptionBudge
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#poddisruptionbudget-v1-policy
*/}}
{{- define "library.pdb.PodDisruptionBudge" -}}
{{ $top := first . -}}
{{- $resource := fromYaml (include (index . 1) $top) | default (dict ) -}}
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata: {{ merge ($resource.metadata | default (dict )) (fromYaml (include "library.metadata" $top)) | toYaml | nindent 2 }}
spec: {{ include "library.pdb.PodDisruptionBudgetSpec" (dict "top" $top "spec" $resource.spec) | trim | nindent 2 }}
{{- end -}}


{{/*
# PodDisruptionBudgetSpec
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#poddisruptionbudgetspec-v1-policy
*/}}
{{- define "library.pdb.PodDisruptionBudgetSpec" -}}
{{- $top := .top -}}
{{- with .spec }}
{{- if .maxUnavailable }}
maxUnavailable: {{ .maxUnavailable }}
{{- end }}
{{- if .minAvailable }}
minAvailable: {{ .minAvailable}}
{{- end }}
selector: {{ default (include "library.selectorLabels" $top) (.selector | toYaml) | trim | nindent 2 }}
{{- if .unhealthyPodEvictionPolicy }}
unhealthyPodEvictionPolicy: {{ .unhealthyPodEvictionPolicy | quote }}
{{- end }}
{{- end }}
{{- end -}}