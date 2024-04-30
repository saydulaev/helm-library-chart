{{- define "library.persistentVolumeClaim" -}}
{{- $top := first . }}
{{- $validateSrc := include "library.persistentVolumeClaim.validate" (list $top (tpl (index . 1) $top)) }}
{{- $dest := (include "library.persistentVolumeClaim.defaults" $top) | fromYaml }}
{{- include "library.util.merge" (dict "top" $top "src" $validateSrc "dest" $dest) -}}
{{- end -}}


{{/*
# PersistentVolumeClaim
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#persistentvolumeclaim-v1-core
*/}}
{{- define "library.persistentVolumeClaim.validate" -}}
{{ $top := first . -}}
{{- $pvc := fromYaml (include (index . 1) $top) | default (dict ) -}} 
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {{ merge ($pvc.metadata | default (dict )) (fromYaml (include "library.metadata" $top)) | toYaml | nindent 2 }}
spec: {{ include "library.persistentVolumeClaimSpec" (dict "top" $top "spec" $pvc.spec) | nindent 2 }}
{{- end -}}


{{- define "library.persistentVolumeClaimTemplate" -}}
metadata: {{ merge (.pvc.metadata | default (dict )) (fromYaml (include "library.metadata" .top)) | toYaml | nindent 2 }}
spec: {{ include "library.persistentVolumeClaimSpec" (dict "top" .top "spec" .spec) | nindent 2 }}
{{- end -}}


{{/*
# PersistentVolumeClaimSpec
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#persistentvolumeclaimspec-v1-core
*/}}
{{- define "library.persistentVolumeClaimSpec" -}}
{{- $top := .top -}}
{{- with .spec }}
{{- if .dataSource }}
accessModes: {{ .accessModes }}
{{- end }}
{{- if .dataSource }}
dataSource: {{ include "library.TypedLocalObjectReference" .dataSource | trim | nindent 2 }}
{{- end }}
{{- if .dataSourceRef }}
dataSourceRef: {{ include "library.TypedObjectReference" .dataSourceRef | trim | nindent 2 }}
{{- end }}
{{- if .resources }}
resources: {{ include "library.VolumeResourceRequirements" .resources | trim | nindent 2 }}
{{- end }}
selector: {{ include "library.selectorLabels" $top | nindent 2 }}
{{- if .storageClassName }}
storageClassName: {{ .storageClassName | quote }}
{{- end }}
{{- if .volumeAttributesClassName }}
volumeAttributesClassName: {{ .volumeAttributesClassName | quote }}
{{- end }}
{{- if .volumeMode }}
volumeMode: {{ .volumeMode | quote }}
{{- end }}
{{- if .volumeName }}
volumeName: {{ .volumeName | quote }}
{{- end }}
{{- end }}
{{- end -}}


{{/*
# TypedLocalObjectReference
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#typedlocalobjectreference-v1-core
*/}}
{{- define "library.TypedLocalObjectReference" -}}
apiGroup: {{ .apiGroup | quote }}
kind: {{ .kind | quote }}
name: {{ .name | quote }}
{{- end -}}


{{/*
# TypedObjectReference
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#typedobjectreference-v1-core
*/}}
{{- define "library.TypedObjectReference" -}}
apiGroup: {{ .apiGroup | quote }}
kind: {{ .kind | quote }}
name: {{ .name | quote }}
namespace: {{ .namespace | quote }}
{{- end -}}


{{/*
# VolumeResourceRequirements
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#volumeresourcerequirements-v1-core
*/}}
{{- define "library.VolumeResourceRequirements" -}}
{{- if .limits }}
limits: {{ .limits | toYaml | nindent 2 }}
{{- end }}
{{- if .requests }}
requests: {{ .requests | toYaml | nindent 2 }}
{{- end }}
{{- end -}}
