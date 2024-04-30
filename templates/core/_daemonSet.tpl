{{- define "library.daemonset" }}
---
{{- $top := first . }}
{{- if $top.Capabilities.APIVersions.Has "apps/v1" }}
{{- $validateSrc := include "library.DaemonSet" (list $top (tpl  (index . 1) $top)) }}
{{- $dest := (include "library.daemonset.defaults" $top) | fromYaml }}
{{- include "library.util.merge" (dict "top" $top "src" $validateSrc "dest" $dest) -}}
{{- else }}
# {{ printf "The Kubernetes cluster does not has the capabilities: %s" "apps/v1" }}
{{- end }}
{{- end -}}


{{/*
# DaemonSet
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#daemonset-v1-apps
*/}}
{{- define "library.DaemonSet" -}}
{{ $top := first . -}}
{{- $resource := fromYaml (include (index . 1) $top) | default (dict ) -}} 
apiVersion: apps/v1
kind: DaemonSet
metadata: {{ merge ($resource.metadata | default (dict )) (fromYaml (include "library.metadata" $top)) | toYaml | nindent 2 }}
spec: {{ include "library.DaemonSetSpec" (dict "top" $top "spec" $resource.spec) | trim | nindent 2 }}
{{- end -}}


{{/*
# DaemonSetSpec
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#daemonsetspec-v1-apps
*/}}
{{- define "library.DaemonSetSpec" -}}
{{- $top := .top -}}
{{- $spec := .spec -}}
{{- with .spec }}
minReadySeconds: {{ default 0 .minReadySeconds | int }}
revisionHistoryLimit: {{ default 10 .revisionHistoryLimit | int }}
selector: {{ default (dict "matchLabels" (include "library.selectorLabels" $top)) (include "library.meta.LabelSelector" .selector | toYaml) | trim | nindent 2 }}
template: {{ include "library.podTemplateSpec" (dict "top" $top "spec" .template) | nindent 2 }}
updateStrategy: {{ (include "library.DaemonSetUpdateStrategy" .updateStrategy) | trim | nindent 2 }}
{{- end }}
{{- end -}}


{{/*
# DaemonSetUpdateStrategy
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#daemonsetupdatestrategy-v1-apps
*/}}
{{- define "library.DaemonSetUpdateStrategy" -}}
type: {{ default "RollingUpdate" .type | quote }}
rollingUpdate:
  maxSurge: {{ default "25%" .rollingUpdate.maxSurge }}
  maxUnavailable: {{ default "25%" .rollingUpdate.maxUnavailable }}
{{- end -}}