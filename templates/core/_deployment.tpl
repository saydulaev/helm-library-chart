{{/*
Validate the deployment.spec.template.spec accordingly the PodSpec
and add metadata object
*/}}
{{- define "library.Deployment" -}}
{{ $top := first . -}}
{{- $deployment := fromYaml (include (index . 1) $top) | default (dict ) -}} 
apiVersion: apps/v1
kind: Deployment
metadata: {{ merge ($deployment.metadata | default (dict )) (fromYaml (include "library.metadata" $top)) | toYaml | nindent 2 }}
spec: {{ include "library.DeploymentSpec" (dict "top" $top "spec" $deployment.spec.template.spec) | trim | nindent 2 }}
{{- end -}}


{{- define "library.deployment" }}
---
{{- $top := first . }}
{{- if $top.Capabilities.APIVersions.Has "apps/v1" }}
{{- $validateSrc := include "library.Deployment" (list $top (tpl  (index . 1) $top)) }}
{{- $dest := (include "library.deployment.defaults" $top) | fromYaml }}
{{- include "library.util.merge" (dict "top" $top "src" $validateSrc "dest" $dest) -}}
{{- else }}
# {{ printf "The Kubernetes cluster does not has the capabilities: %s" "apps/v1" }}
{{- end }}
{{- end -}}


{{/*
# DeploymentSpec
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#deploymentspec-v1-apps
*/}}
{{- define "library.DeploymentSpec" -}}
{{- $top := .top -}}
{{- $spec := .spec -}}
{{- with .spec }}
minReadySeconds: {{ default 0 .minReadySeconds }}
{{- if .paused }}
paused: {{ .paused }}
{{- end }}
progressDeadlineSeconds: {{ default "600s" .progressDeadlineSeconds }}
replicas: {{ default 1 .replicas }}
revisionHistoryLimit: {{ default 10 .revisionHistoryLimit }}
selector:
  matchLabels:
    {{- include "library.selectorLabels" $top | nindent 6 }}
strategy: {{ include "library.DeploymentStrategy" .strategy | nindent 2 }}
template: {{ include "library.podTemplateSpec" (dict "top" $top "spec" $spec) | nindent 2 }}
{{- end }}
{{- end -}}


{{/*
# DeploymentStrategy
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#deploymentstrategy-v1-apps
*/}}
{{- define "library.DeploymentStrategy" -}}
type: {{ default "RollingUpdate" .type | quote }}
rollingUpdate:
  maxSurge: {{ default "25%" .rollingUpdate.maxSurge }}
  maxUnavailable: {{ default "25%" .rollingUpdate.maxUnavailable }}
{{- end -}}