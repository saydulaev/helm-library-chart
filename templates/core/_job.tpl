{{- define "library.job.validate" -}}
{{ $top := first . -}}
{{- $job := fromYaml (include (index . 1) $top) | default (dict ) -}}
apiVersion: batch/v1
kind: Job
metadata: {{ merge ($job.metadata | default (dict )) (fromYaml (include "library.metadata" $top)) | toYaml | nindent 2 }}
spec: {{ include "library.jobSpec" (dict "top" $top "spec" $job.spec) | trim | nindent 2 }}
{{- end -}}

{{/*
To define multiple jobs
Example:
# chart/templates/job.yaml
{{- if .Values.jobs }}
{{- $top := . -}}
{{- range $key, $val := $top.Values.jobs }}
{{- $result := include "base.job" (dict "top" $top "spec" $val "index" $key) -}}
{{- include "library.job" (list $top $result $key) -}}
{{- end }}
{{- end }}

{{- define "base.job" -}}
...
{{- end -}}
*/}}
{{- define "library.jobs.validate" -}}
{{ $top := first . -}}
{{- $job := fromYaml (index . 1) -}}
apiVersion: batch/v1
kind: Job
metadata: {{ merge ($job.metadata | default (dict )) (fromYaml (include "library.metadata" $top)) | toYaml | nindent 2 }}
spec: {{ include "library.jobSpec" (dict "top" $top "spec" $job.spec) | trim | nindent 2 }}
{{- end -}}

{{/*
Template to include in child charts.

# The last item in args list, show that must be template "library.jobs.validate"
{{- $top := . -}}
{{- range $key, $val := $top.Values.jobs }}
{{- $result := include "base.job" (dict "top" $top "spec" $val "index" $key) -}}
{{- include "library.job" (list $top $result $key) -}}
{{- end }}

{{- define "base.job" -}}
...
{{- end -}}
------------
# For rendering single chart template
{{- include "library.job" (list . "base.job") -}}
{{- define "base.job" -}}
...
{{- end -}}
*/}}
{{- define "library.job" -}}
---
{{- $top := first . }}
{{- $dest := (include "library.job.defaults" $top) | fromYaml }}
{{- if eq (len .) 3 }}
{{- $validateSrc := include "library.jobs.validate" (list $top (tpl  (index . 1) $top)) }}
{{- include "library.util.merge" (dict "top" $top "src" $validateSrc "dest" $dest) -}}
{{- else }}
{{- $validateSrc := include "library.job.validate" (list $top (tpl  (index . 1) $top)) }}
{{- include "library.util.merge" (dict "top" $top "src" $validateSrc "dest" $dest) -}}
{{- end }}
{{- end -}}


{{/*
# JobSpec
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#jobspec-v1-batch
*/}}
{{- define "library.jobSpec" -}}
{{ $top := .top -}}
{{- $spec := .spec -}}
{{- with .spec }}
{{- if .activeDeadlineSeconds }}
activeDeadlineSeconds: {{ .activeDeadlineSeconds | int }}
{{- end }}
backoffLimit: {{ default 6 .backoffLimit | int }}
{{- if .backoffLimitPerIndex }}
backoffLimitPerIndex: {{ .backoffLimitPerIndex | int }}
{{- end }}
{{- if .completionMode }}
completionMode: {{ .completionMode | quote }}
{{- end }}
{{- if .completions }}
completions: {{ .completions | int }}
{{- end }}
{{- if hasKey . "manualSelector" }}
manualSelector: {{ .manualSelector }}
{{- end }}
{{- if .maxFailedIndexes }}
maxFailedIndexes: {{ .maxFailedIndexes | int }}
{{- end }}
{{- if .parallelism }}
parallelism: {{ .parallelism | int }}
{{- end }}
{{- if .podFailurePolicy }}
podFailurePolicy: {{ include "libraty.podFailurePolicy" .podFailurePolicy | nindent 2 }}
{{- end }}
{{- if .podReplacementPolicy }}
podReplacementPolicy: {{ .podReplacementPolicy | quote }}
{{- end }}
{{- if .selector }}
selector: {{ .selector | toYaml | indent 2 }}
{{- end }}
{{- if hasKey . "suspend" }}
suspend: {{ .suspend }}
{{- end }}
template: {{ include "library.podTemplateSpec" (dict "top" $top "spec" .template.spec) | trim | nindent 2 }}
{{- if .ttlSecondsAfterFinished }}
ttlSecondsAfterFinished: {{ .ttlSecondsAfterFinished | int }}
{{- end }}
{{- end }}
{{- end -}}


{{/*
# PodFailurePolicy
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#podfailurepolicy-v1-batch
*/}}
{{- define "libraty.podFailurePolicy" -}}
{{ include "library.podFailurePolicyRule" .rules }}
{{- end -}}


{{/* 
# PodFailurePolicyRule
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#podfailurepolicyrule-v1-batch
*/}}
{{- define "library.podFailurePolicyRules" -}}
{{- range . }}
action: {{ .action | quote }}
{{- if .onExitCodes }}
onExitCodes: {{ required "Resource PodFailurePolicyOnExitCodesRequirement should be defined" (include "library.podFailurePolicyOnExitCodesRequirement" .onExitCodes) | trim | nindent 2 }}
{{- end }}
{{- if .onPodConditions }}
onPodConditions: {{ include "library.podFailurePolicyOnPodConditionsPattern" .onPodConditions | trim | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}


{{/*
# PodFailurePolicyOnExitCodesRequirement
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#podfailurepolicyonexitcodesrequirement-v1-batch
*/}}
{{- define "library.podFailurePolicyOnExitCodesRequirement" -}}
containerName: {{ .containerName | quote }}
operator: {{ .operator | quote }}
values:
{{- range .values }}
- {{ . | int }}
{{- end }}
{{- end -}}


{{/*
# PodFailurePolicyOnPodConditionsPattern
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#podfailurepolicyonpodconditionspattern-v1-batch
*/}}
{{- define "library.podFailurePolicyOnPodConditionsPattern" -}}
{{- range . }}
- name: {{ .status | quote }}
  type: {{ .type | quote }}
{{- end }}
{{- end -}}