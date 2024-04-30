{{/* Expand the name of the chart. */}}
{{- define "library.name" -}}
{{- default .Chart.Name .Values.nameOverride | replace "_" "-" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "library.fullname" -}}
{{- $values := .Values -}}
{{- $chart := .Chart -}}
{{- $release := .Release -}}
{{- $name := "" -}}
{{- if $values.fullnameOverride }}
{{- $name := ($values.fullnameOverride | toString) | replace "_" "-" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- if $values.nameOverride }}
{{- $name := ($values.nameOverride | toString) | replace "_" "-" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- if contains $name ($release.Name | toString) }}
{{- ($release.Name | toString) | replace "_" "-" | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" ($release.Name | toString) ($name | toString) | replace "_" "-" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/* Selector labels */}}
{{- define "library.selectorLabels" -}}
app.kubernetes.io/name: {{ include "library.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Common labels */}}
{{- define "library.metadata.labels" -}}
helm.sh/chart: {{ include "library.chart" . }}
{{ include "library.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "library.metadata.podLabels" -}}
{{- if .Values.podLabels }}
{{- range $k, $v := .Values.podLabels }}
{{ $k | quote }}: {{ $v | quote }}
{{- end }}
{{- end }}
{{- end -}}

{{/* metadata.annotations Deployment */}}
{{- define "library.metadata.deploymentAnnotations" -}}
{{- with .Values.deployment }}
{{- if .annotations }}
{{- range $k, $v := .annotations -}}
{{ $k }}: {{ tpl $v $ | quote }}
{{- end }}
{{- end }}
# rollme: {{ randAlphaNum 5 | quote }}
{{- end }}
{{- end -}}

{{/* metadata.annotations */}}
{{- define "library.metadata.annotations" -}}
{{- if .Values.annotations }}
{{- range $k, $v := .Values.annotations -}}
{{ $k }}: {{ tpl $v $ | quote }}
{{- end }}
{{- end }}
{{- include "library.metadata.deploymentAnnotations" . -}}
{{- end -}}


{{/* metadata.tepmplate */}}
{{- define "library.metadata.podTeplate" -}}
labels: {{ include "library.metadata.labels" . | nindent 2 }}
annotations: {{ include "library.metadata.annotations" . | nindent 2 }}
{{- end }}

{{/* metadata */}}
{{- define "library.metadata" -}}
name: {{ include "library.fullname" . }}
namespace: {{ .Release.Namespace | quote }}
{{ include "library.metadata.podTeplate" . -}}
{{- end -}}


{{/* metadata.resource for all resources except Deployment */}}
{{- define "library.metadata.resource" -}}
name: {{ include "library.fullname" . }}
namespace: {{ .Release.Namespace | quote }}
labels: {{ include "library.metadata.labels" . | nindent 2 }}
{{- end -}}


{{- define "library.metadata.test" -}}
{{- $top := first . -}}
{{ $top.Release.Namespace }}
{{ $top.Chart.Name }}
{{/* {{ $top | toYaml }} */}}
{{- end -}}


{{/*
# LabelSelector
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#labelselector-v1-meta
*/}}
{{- define "library.meta.LabelSelector" -}}
{{- if .matchExpressions }}
matchExpressions: {{ include "library.meta.LabelSelectorRequirement" .matchExpressions | trim | nindent 0 }}
{{- end }}
{{- if .matchLabels }}
matchLabels: {{ .matchLabels | toYaml | nindent 2 }}
{{- end }}
{{- end -}}


{{/*
# LabelSelectorRequirement
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#labelselectorrequirement-v1-meta
*/}}
{{- define "library.meta.LabelSelectorRequirement" -}}
{{- range . }}
- key: {{ .key | quote }}
  operator: {{ .operator | quote }}
  values:
  {{- range .values }}
  - {{ . | quote }}
  {{- end }}
{{- end }}
{{- end -}}
