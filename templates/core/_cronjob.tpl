{{- define "library.cronJob.validate" -}}
{{ $top := first . -}}
{{- $job := fromYaml (include (index . 1) $top) | default (dict ) -}}
apiVersion: batch/v1
kind: CronJob
metadata: {{ merge ($job.metadata | default (dict )) (fromYaml (include "library.metadata" $top)) | toYaml | nindent 2 }}
spec: {{ include "library.cronJobSpec" (dict "top" $top "spec" $job.spec) | trim | nindent 2 }}
{{/*  */}}
{{- end -}}


{{/*
To define multiple cronJobs
Example:
# chart/templates/cronjob.yaml
{{- if .Values.cronJobs }}
{{- $top := . -}}
{{- range $key, $val := $top.Values.cronJobs }}
{{- $result := include "base.cronJob" (dict "top" $top "spec" $val "index" $key) -}}
{{- include "library.cronJob" (list $top $result $key) -}}
{{- end }}
{{- end }}

{{- define "base.cronJob" -}}
...
{{- end -}}
*/}}
{{- define "library.cronJobs.validate" -}}
{{ $top := first . -}}
{{- $job := fromYaml (index . 1) -}}
apiVersion: batch/v1
kind: CronJob
metadata: {{ merge ($job.metadata | default (dict )) (fromYaml (include "library.metadata" $top)) | toYaml | nindent 2 }}
spec: {{ include "library.cronJobSpec" (dict "top" $top "spec" $job.spec) | trim | nindent 2 }}
{{- end -}}


{{/*
Template to include in child charts.

# The last item in args list, show that must be template "library.cronJobs.validate"
{{- $top := . -}}
{{- range $key, $val := $top.Values.cronJobs }}
{{- $result := include "base.cronJob" (dict "top" $top "spec" $val "index" $key) -}}
{{- include "library.cronJob" (list $top $result $key) -}}
{{- end }}

{{- define "base.cronJob" -}}
...
{{- end -}}
------------
# For rendering single chart template
{{- include "library.cronJob" (list . "base.cronJob") -}}
{{- define "base.cronJob" -}}
...
{{- end -}}
*/}}
{{- define "library.cronJob" -}}
---
{{ $top := first . }}
{{- $dest := (include "library.cronJob.defaults" $top) | fromYaml }}
{{- if eq (len .) 3 }}
{{- $validateSrc := include "library.cronJobs.validate" (list $top (tpl  (index . 1) $top)) }}
{{- include "library.util.merge" (dict "top" $top "src" $validateSrc "dest" $dest) -}}
{{- else }}
{{- $validateSrc := include "library.cronJob.validate" (list $top (tpl  (index . 1) $top)) }}
{{- include "library.util.merge" (dict "top" $top "src" $validateSrc "dest" $dest) -}}
{{- end }}
{{- end -}}


{{/*
# CronJobSpec
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#cronjobspec-v1-batch
*/}}
{{- define "library.cronJobSpec" -}}
{{- $top := .top -}}
{{- with .spec }}
{{- if .concurrencyPolicy }}
concurrencyPolicy: {{ .concurrencyPolicy | quote }}
{{- end }}
failedJobsHistoryLimit: {{ default 1 .failedJobsHistoryLimit | int }}
jobTemplate:
  {{- $spec := include "library.jobSpec" (dict "top" $top "spec" .jobTemplate.spec) | fromYaml }}
  spec: 
    template: {{ omit ($spec.template) "metadata" | toYaml | trim | nindent 6 }}
schedule: {{ required "Cronjob requred .schedule spec" .schedule | quote }}
{{- if .startingDeadlineSeconds }}
startingDeadlineSeconds: {{ .startingDeadlineSeconds | int }}
{{- end }}
{{- if .successfulJobsHistoryLimit }}
successfulJobsHistoryLimit: {{ .successfulJobsHistoryLimit | int }}
{{- end }}
{{- if hasKey . "suspend" }}
suspend: {{ .suspend }}
{{- end }}
{{- if .timeZone }}
timeZone: {{ .timeZone | quote }}
{{- end }}
{{- end }}
{{- end -}}



{{/*
# JobTemplateSpec
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#jobtemplatespec-v1-batch
*/}}
{{- define "library.JobTemplateSpec" -}}
metadata: {{ include "library.metadata" .top | trim | nindent 2  }}
spec: {{ include "library.jobSpec" (dict "top" .top "spec" .spec) | trim | nindent 2 }}
{{- end }}