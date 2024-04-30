{{- define "library.hpa" }}
---
{{- $top := first . }}
{{- if $top.Capabilities.APIVersions.Has "autoscaling/v2" }}
{{- $validateSrc := include "library.hpa.HorizontalPodAutoscaler" (list $top (tpl  (index . 1) $top)) }}
{{- $dest := (include "library.hpa.defaults" $top) | fromYaml }}
{{- include "library.util.merge" (dict "top" $top "src" $validateSrc "dest" $dest) -}}
{{- else }}
# {{ printf "The Kubernetes cluster does not has the capabilities: %s" "autoscaling/v2" }}
{{- end }}
{{- end -}}


{{/*
# HorizontalPodAutoscaler
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#horizontalpodautoscaler-v2-autoscaling
*/}}
{{- define "library.hpa.HorizontalPodAutoscaler" -}}
{{ $top := first . -}}
{{- $resource := fromYaml (include (index . 1) $top) | default (dict ) -}}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata: {{ merge ($resource.metadata | default (dict )) (fromYaml (include "library.metadata" $top)) | toYaml | nindent 2 }}
spec: {{ include "library.hpa.HorizontalPodAutoscalerSpec" (dict "top" $top "spec" $resource.spec) | trim | nindent 2 }}
{{- end -}}


{{/*
# HorizontalPodAutoscalerSpec
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#horizontalpodautoscalerspec-v2-autoscaling
*/}}
{{- define "library.hpa.HorizontalPodAutoscalerSpec" -}}
{{- $top := .top -}}
{{- with .spec }}
{{- if .behavior }}
behavior: {{ include "library.hpa.HorizontalPodAutoscalerBehavior" .behavior | trim | nindent 2 }}
{{- end }}
{{- if .maxReplicas }}
maxReplicas: {{ .maxReplicas | int }}
{{- end }}
{{- if .metrics }}
metrics: {{ include "library.hpa.MetricSpec" .metrics | trim | nindent 2 }}
{{- end }}
{{- if .minReplicas }}
minReplicas: {{ .minReplicas | int }}
{{- end }}
{{- if .scaleTargetRef }}
{{- with .scaleTargetRef }}
scaleTargetRef:
  apiVersion: {{ .apiVersion | quote }}
  kind: {{ .kind | quote }}
  name: {{ .name | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}


{{/*
# HorizontalPodAutoscalerBehavior
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#horizontalpodautoscalerbehavior-v2-autoscaling
*/}}
{{- define "library.hpa.HorizontalPodAutoscalerBehavior" -}}
{{- if .scaleDown }}
scaleDown: {{ include "library.hpa.HPAScalingRules" .scaleDown | trim | nindent 2 }}
{{- end }}
{{- if .scaleUp }}
scaleUp: {{ include "library.hpa.HPAScalingRules" .scaleUp | trim | nindent 2 }}
{{- end }}
{{- end -}}


{{/*
# HPAScalingRules
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#hpascalingrules-v2-autoscaling
*/}}
{{- define "library.hpa.HPAScalingRules" -}}
{{- if .policies }}
policies: 
{{- range .policies }}
- type: {{ .type | quote }}
  periodSeconds: {{ default 1800 .periodSeconds | int }}
  value: {{ .value | int }}
{{- end }}
{{- end }}
{{- if .selectPolicy }}
selectPolicy: {{ .selectPolicy | quote }}
{{- end }}
{{- if .stabilizationWindowSeconds }}
stabilizationWindowSeconds: {{ .stabilizationWindowSeconds | int }}
{{- end }}
{{- end -}}


{{/*
# MetricSpec
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#metricspec-v2-autoscaling
*/}}
{{- define "library.hpa.MetricSpec" -}}
{{- range . }}
- type: {{ .type | quote }} # ContainerResource / External / Object / Pods / Resource
  {{- if .containerResource }}
  containerResource: 
    container: {{ .containerResource.container | quote }}
    name: {{ .containerResource.name | quote }}
    target: {{ include "library.hpa.MetricTarget" .containerResource.target | trim | nindent 6 }}
  {{- end }}
  {{- if .external }}
  external:
    metric: {{ include "library.hpa.MetricIdentifier" .external | trim | nindent 4 }}
    target: {{ include "library.hpa.MetricTarget" .external.target | trim | nindent 6 }}
  {{- end }}
  {{- if .object }}
  object: {{ include "library.hpa.ObjectMetricSource" .object | trim | nindent 4 }}
  {{- end }}
  {{- if .pods }}
  pods: {{ include "library.hpa.PodsMetricSource" .pods | trim | nindent 2 }}
  {{- end }}
  {{- if .resource }}
  resource: {{ include "library.hpa.ResourceMetricSource" .resource | trim | nindent 4 }}
  {{- end }}
{{- end }}
{{- end -}}


{{/*
# MetricTarget
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#metrictarget-v2-autoscaling
*/}}
{{- define "library.hpa.MetricTarget" -}}
averageUtilization: {{ .averageUtilization | int }}
averageValue: {{ .averageValue }}
type: {{ .type | quote }}
value: {{ .value }}
{{- end -}}


{{/*
# ResourceMetricSource
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#resourcemetricsource-v2-autoscaling
*/}}
{{- define "library.hpa.ResourceMetricSource" -}}
name: {{ .name | quote }}
target: {{ include "library.hpa.MetricTarget" .target | trim | nindent 2 }}
{{- end -}}


{{/*
# ObjectMetricSource
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectmetricsource-v2-autoscaling
*/}}
{{- define "library.hpa.ObjectMetricSource" -}}
{{- if .describedObject }}
describedObject:
  {{- with .describedObject }}
  apiVersion: {{ .apiVersion | quote }}
  kind: {{ .kind | quote }}
  name: {{ .name | quote }}
  {{- end }}
{{- end }}
{{- if .metric }}
metric: {{ include "library.hpa.MetricIdentifier" .metric | trim | nindent 2 }}
{{- end }}
{{- if .target }}
target: {{ include "library.hpa.MetricTarget" .target | trim | nindent 2 }}
{{- end }}
{{- end -}}


{{/*
# PodsMetricSource
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#podsmetricsource-v2-autoscaling
*/}}
{{- define "library.hpa.PodsMetricSource" -}}
{{- if .metric }}
metric: {{ include "library.hpa.MetricIdentifier" .metric | trim | nindent 2 }}
{{- end }}
{{- if .target }}
target: {{ include "library.hpa.MetricTarget" .target | trim | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
# MetricIdentifier
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#metricidentifier-v2-autoscaling
*/}}
{{- define "library.hpa.MetricIdentifier" -}}
name: {{ .name | quote }}
{{- if .selector }}
selector: {{ .selector | toYaml | nindent 2 }}
{{- end }}
{{- end -}}