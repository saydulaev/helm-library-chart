{{- define "library.statefulset" }}
---
{{- $top := first . }}
{{- if $top.Capabilities.APIVersions.Has "apps/v1" }}
{{- $validateSrc := include "library.StatefulSet" (list $top (tpl  (index . 1) $top)) }}
{{- $dest := (include "library.statefulset.defaults" $top) | fromYaml }}
{{- include "library.util.merge" (dict "top" $top "src" $validateSrc "dest" $dest) -}}
{{- else }}
# {{ printf "The Kubernetes cluster does not has the capabilities: %s" "apps/v1" }}
{{- end }}
{{- end -}}


{{/*
# DaemonSet
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#statefulset-v1-apps
*/}}
{{- define "library.StatefulSet" -}}
{{ $top := first . -}}
{{- $resource := fromYaml (include (index . 1) $top) | default (dict ) -}} 
apiVersion: apps/v1
kind: StatefulSet
metadata: {{ merge ($resource.metadata | default (dict )) (fromYaml (include "library.metadata" $top)) | toYaml | nindent 2 }}
spec: {{ include "library.StatefulSetSpec" (dict "top" $top "spec" $resource.spec) | trim | nindent 2 }}
{{- end -}}


{{/*
# StatefulSetSpec
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#statefulsetspec-v1-apps
*/}}
{{- define "library.StatefulSetSpec" -}}
{{- $top := .top -}}
{{- $spec := .spec -}}
{{- with .spec }}
minReadySeconds: {{ default 0 .minReadySeconds | int }}
{{- if .ordinals }}
ordinals:
  start: {{ default 0 .ordinals.start | int }}
{{- end }}
{{- if .persistentVolumeClaimRetentionPolicy }}
persistentVolumeClaimRetentionPolicy:
  {{- with .persistentVolumeClaimRetentionPolicy }}
  {{- if .whenDeleted }}
  whenDeleted: {{ .whenDeleted | quote }}
  {{- end }}
  {{- if .whenScaled }}
  whenScaled: {{ .whenScaled | quote }}
  {{- end }}
  {{- end }}
{{- end }}
podManagementPolicy: {{ default "OrderedReady" .podManagementPolicy | quote }}
replicas: {{ default 1 .replicas | int }}
revisionHistoryLimit: {{ default 10 .revisionHistoryLimit | int }}
selector: {{ default (dict "matchLabels" (include "library.selectorLabels" $top)) (include "library.meta.LabelSelector" .selector | toYaml) | trim | nindent 2 }}
serviceName: {{ default (include "library.fullname" $top) .serviceName | quote }}
template: {{ include "library.podTemplateSpec" (dict "top" $top "spec" $spec.template) | nindent 2 }}
updateStrategy: {{ include "library.StatefulSetUpdateStrategy" .updateStrategy | trim | nindent 2 }}
{{- end }}
{{- end -}}


{{/*
# StatefulSetUpdateStrategy
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#statefulsetupdatestrategy-v1-apps
*/}}
{{- define "library.StatefulSetUpdateStrategy" -}}
type: {{ default "RollingUpdate" .type | quote }}
rollingUpdate:
  maxSurge: {{ default "25%" .rollingUpdate.maxSurge }}
  maxUnavailable: {{ default "25%" .rollingUpdate.maxUnavailable }}
{{- end -}}