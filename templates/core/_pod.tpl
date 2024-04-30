{{/*
# PodTemplateSpec
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#podtemplatespec-v1-core
*/}}
{{- define "library.podTemplateSpec" -}}
metadata: {{ include "library.metadata.podTeplate" .top | nindent 2 }}
{{/*   */}}
spec: {{- include "library.podSpec" (dict "top" .top "spec" .spec) | nindent 2 -}}
{{- end -}}

{{/*
# PodSpec
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#podspec-v1-core
*/}}
{{- define "library.podSpec" -}}
{{- $top := .top -}}
{{- with .spec -}}
{{- if .serviceAccountName }}
serviceAccountName: {{ default $top.Release.Namespace .serviceAccountName | quote }}
{{- end }}
{{- if .serviceAccount }}
serviceAccount: {{ .serviceAccount | quote }}
{{- end }}
{{- if .strategy }}
strategy: {{ tpl (.strategy | toYaml | toString) $top | nindent 2 }}
{{- end }}
{{- if .topologySpreadConstraints }}
topologySpreadConstraints: {{ tpl (.topologySpreadConstraints | toYaml | toString) $top | nindent 2 }}
{{- end }}
{{- if .activeDeadlineSeconds }}
activeDeadlineSeconds: {{ .activeDeadlineSeconds | int }}
{{- end }}
{{- if hasKey . "automountServiceAccountToken" }}
automountServiceAccountToken: {{ .automountServiceAccountToken }}
{{- end }}
{{- if .dnsConfig }}
dnsConfig: {{ tpl (.dnsConfig | toYaml | toString) $top | nindent 2 }}
{{- end }}
{{- if .dnsPolicy }}
dnsPolicy: {{ .dnsPolicy | quote }}
{{- end }}
{{- if hasKey . "enableServiceLinks" }}
enableServiceLinks: {{ .enableServiceLinks }}
{{- end }}
{{- if .ephemeralContainers }}
ephemeralContainers: {{ include "library.containers" (dict "top" $top "containers" .ephemeralContainers) | trim | nindent 0 }}
{{- end }}
{{- if or .hostAliases $top.Values.hostAliases }}
hostAliases: {{ tpl ((.hostAliases | default $top.Values.hostAliases) | toYaml | toString) $top | trim | nindent 0 }}
{{- end }}
{{- if hasKey . "hostIPC" }}
hostIPC: {{ .hostIPC }}
{{- end }}
{{- if hasKey . "hostNetwork" }}
hostNetwork: {{ .hostNetwork }}
{{- end }}
{{- if hasKey . "hostPID" }}
hostPID: {{ .hostPID }}
{{- end }}
{{- if hasKey . "hostUsers" }}
hostUsers: {{ .hostUsers }}
{{- end }}
{{- if .hostname }}
hostname: {{ .hostname | quote }}
{{- end }}
{{- if .imagePullSecrets }}
imagePullSecrets:
{{- range .imagePullSecrets }}
- name: {{ .name | quote }}
{{- end }}
{{- end }}
{{- if .initContainers }}
initContainers: {{ include "library.containers" (dict "top" $top "containers" .initContainers) | trim | nindent 0 }}
{{- end }}
{{- if .nodeName }}
nodeName: {{ .nodeName | quote }}
{{- end }}
{{- if .nodeSelector }}
nodeSelector: {{ tpl (.nodeSelector | toYaml | toString) $top | nindent 8 }}
{{- end }}
{{- if .os }}
os:
{{- range $os := .os }}
- name: {{ $os.name | quote }}
{{- end }}
{{- end }}
{{- if .overhead }}
overhead: {{ tpl (.overhead | toYaml | toString) $top | nindent 2 }}
{{- end }}
{{- if .preemptionPolicy }}
preemptionPolicy: {{ .preemptionPolicy | quote }}
{{- end }}
{{- if .priority }}
priority: {{ .priority | int }}
{{- end }}
{{- if or .priorityClassName $top.Values.priorityClassName }}
priorityClassName: {{ default $top.Values.priorityClassName .priorityClassName | quote }}
{{- end }}
{{- if .readinessGates }}
readinessGates:
{{- range $gate := .readinessGates }}
- conditionType: {{ $gate.conditionType | quote }}
{{- end }}
{{- end }}
{{- if .resourceClaims }}
resourceClaims: {{ tpl (.resourceClaims | toYaml | toString) $top | nindent 2 }}
{{- end }}
{{- if .restartPolicy }}
restartPolicy: {{ .restartPolicy | quote }}
{{- end }}
{{- if .runtimeClassName }}
runtimeClassName: {{ .runtimeClassName | quote }}
{{- end }}
{{- if .schedulerName }}
schedulerName: {{ .schedulerName | quote }}
{{- end }}
{{- if .schedulingGates }}
schedulingGates:
{{- range $gate := .schedulingGates }}
- name: {{ $gate.name | quote }}
{{- end }}
{{- end }}
{{- if or .securityContext $top.Values.securityContext }}
securityContext: {{- include "library.securityContext" (.securityContext | default $top.Values.securityContext) | trim | nindent 2 }}
{{- end }}
{{- if .setHostnameAsFQDN }}
setHostnameAsFQDN: {{ .setHostnameAsFQDN }}
{{- end }}
{{- if hasKey . "shareProcessNamespace" }} 
shareProcessNamespace: {{ .shareProcessNamespace }}
{{- end }}
{{- if .subdomain }}
subdomain: {{ .subdomain | quote }}
{{- end }}
{{- if .terminationGracePeriodSeconds }}
terminationGracePeriodSeconds: {{ .terminationGracePeriodSeconds | int }}
{{- end }}
{{- if and .containers (gt (len .containers) 0) }}
containers: {{ include "library.containers" (dict "top" $top "containers" .containers) | trim | nindent 0 }}
{{- end }}
{{- if or .nodeSelector $top.Values.nodeSelector  }}
nodeSelector: {{ tpl (default $top.Values.nodeSelector .nodeSelector | toYaml | toString) $top | nindent 0 }}
{{- end }}
{{- if or .affinity $top.Values.affinity }}
affinity: {{ tpl (default $top.Values.affinity .affinity | toYaml | toString) $top | nindent 2 }}
{{- end }}
{{- if and .tolerations (gt (len .tolerations) 0) }}
tolerations: {{ include "library.Toleration" .tolerations | trim | nindent 0 }}
{{- end }}
{{- if .volumes }}
volumes: {{ tpl (.volumes | toYaml | toString) $top | nindent 0 }}
{{- end }}
{{- end }}
{{- end -}}


{{/*
# Volume
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#volume-v1-core
*/}}
{{- define "library.pod.Library" -}}
{{- $top := .top -}}
{{- range . }}
{{- if .configMap }}
configMap: {{ include "library.pod.ConfigMapVolumeSource" .configMap | trim | nindent 2 }}
{{- end }}
{{- if .csi }}
csi: {{ include "library.pod.CSIVolumeSource" .csi | trim | nindent 2 }}
{{- end }}
{{- if .downwardAPI }}
downwardAPI: {{ include "library.pod.DownwardAPIVolumeSource" .downwardAPI | trim | nindent 2 }}
{{- end }}
{{- if .emptyDir }}
emptyDir: {{ include "library.pod.EmptyDirVolumeSource" .emptyDir | trim | nindent 2 }}
{{- end }}
{{- if .ephemeral }}
ephemeral: {{ include "library.pod.EphemeralVolumeSource" .ephemeral | trim | nindent 2 }}
{{- end }}
{{- if .hostPath }}
hostPath: {{ include "library.pod.HostPathVolumeSource" .hostPath | trim | nindent 2 }}
{{- end }}
name: {{ .name | quote }}
{{- if .persistentVolumeClaim }}
persistentVolumeClaim: {{ include "library.pod.PersistentVolumeClaimVolumeSource" .persistentVolumeClaim | trim | nindent 2 }}
{{- end }}
{{- if .projected }}
projected: {{ include "library.pod.ProjectedVolumeSource" .projected | trim | nindent 2 }}
{{- end }}
{{- if .secret }}
secret: {{ include "library.pod.SecretVolumeSource" .secret | trim | nindent 2 }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
# ConfigMapVolumeSource
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#configmapvolumesource-v1-core
*/}}
{{- define "library.pod.ConfigMapVolumeSource" -}}
defaultMode: {{ default 0644 .defaultMode | int }}
{{- if .items }}
items: 
{{- range .items }}
- key: {{ .key | quote }}
  mode: {{ .mode | int }}
  path: {{ .path | quote }}
{{- end }}
{{- end }}
name: {{ .name | quote }}
{{- if hasKey . "optional" }}
optional: {{ .optional }}
{{- end }}
{{- end -}}


{{/*
# CSIVolumeSource
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#csivolumesource-v1-core
*/}}
{{- define "library.pod.CSIVolumeSource" -}}
driver: {{ .driver | quote }}
fsType: {{ .fsType | quote }}
nodePublishSecretRef: 
{{- if hasKey . "readOnly" }}
readOnly: {{ .readOnly }}
{{- end }}
nodePublishSecretRef: {{ .nodePublishSecretRef | toYaml | nindent 2 }}
{{- if .volumeAttributes }}
volumeAttributes: {{ .volumeAttributes | toYaml | nindent 2 }}
{{- end }}
{{- end -}}


{{/*
# DownwardAPIVolumeSource
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#downwardapivolumesource-v1-core
*/}}
{{- define "library.pod.DownwardAPIVolumeSource" -}}
defaultMode: {{ .defaultMode | int }}
items: {{ include "library.DownwardAPIVolumeFile" .items | trim | nindent 2 }}
{{- end -}}

{{/*
# DownwardAPIVolumeFile
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#downwardapivolumefile-v1-core
*/}}
{{- define "livrary.DownwardAPIVolumeFile" -}}
{{- range . }}
fieldRef:
  apiVersion: {{ default "v1" .fieldRef.apiVersion | quote }}
  fieldPath: {{ .fieldRef.fieldPath }}
mode: {{ .mode | int }}
path: {{ .path | quote }}
{{- with .resourceFieldRef }}
resourceFieldRef:
  containerName: {{ .containerName | quote }}
  divisor: {{ .divisor }}
  resource: {{ .resource }}
{{- end }}
{{- end }}
{{- end -}}


{{/*
# EmptyDirVolumeSource
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#emptydirvolumesource-v1-core
*/}}
{{- define "library.pod.EmptyDirVolumeSource" -}}
medium: {{ default "" .medium | quote }}
{{- if .sizeLimit }}
sizeLimit: {{ .sizeLimit }}
{{- end }}
{{- end -}}


{{/*
# EphemeralVolumeSource
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#ephemeralvolumesource-v1-core
*/}}
{{- define "library.pod.EphemeralVolumeSource" -}}
volumeClaimTemplate: {{ include "library.persistentVolumeClaimTemplate" (dict "top" .top "spec" .volumeClaimTemplate) | nindent 2 }}
{{- end -}}


{{/*
# HostPathVolumeSource
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#hostpathvolumesource-v1-core
*/}}
{{- define "library.pod.HostPathVolumeSource" -}}
path: {{ .path | quote }}
type: {{ .type | quote }}
{{- end -}}


{{/*
# PersistentVolumeClaimVolumeSource
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#persistentvolumeclaimvolumesource-v1-core
*/}}
{{- define "library.pod.PersistentVolumeClaimVolumeSource" -}}
claimName: {{ .claimName | quote }}
{{- if hasKey . "readOnly" }}
readOnly: {{ .readOnly }}
{{- end }}
{{- end -}}


{{/*
# ProjectedVolumeSource
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#projectedvolumesource-v1-core
*/}}
{{- define "library.pod.ProjectedVolumeSource" -}}
defaultMode: {{ .defaultMode | int }}
sources: {{ include "library.pod.VolumeProjection" .sources | trim | nindent 2 }}
{{- end -}}


{{/*
# VolumeProjection
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#volumeprojection-v1-core
*/}}
{{- define "library.pod.VolumeProjection" -}}
{{- range . }}
{{- if .clusterTrustBundle -}}
clusterTrustBundle: {{ include "library.ClusterTrustBundleProjection" .clusterTrustBundle | trim | nindent 2 }}
{{- end }}
{{- if .configMap }}
configMap: {{ include "library.ConfigMapProjection" .configMap | trim | nindent 2 }}
{{- end }}
{{- if .downwardAPI }}
downwardAPI: {{ include "library.DownwardAPIProjection" .downwardAPI | trim | nindent 2 }}
{{- end }}
{{- if .secret }}
secret: {{ include "library.SecretProjection" .secret | trim | nindent 2 }}
{{- end }}
{{- if .serviceAccountToken }}
serviceAccountToken: {{ include "library.ServiceAccountTokenProjection" .serviceAccountToken | trim | nindent 2 }}
{{- end }}
{{- end }}
{{- end -}}


{{/*
# ClusterTrustBundleProjection
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#clustertrustbundleprojection-v1-core
*/}}
{{- define "library.ClusterTrustBundleProjection" -}}
{{- if .labelSelector }}
labelSelector: {{ .labelSelector | toYaml | nindent 2 }}
{{- end }}
{{- if .name }}
name: {{ .name | quote }}
{{- end }}
{{- if hasKey . "optional" }}
optional: {{ .optional }}
{{- end }}
{{- if .path }}
path: {{ .path | quote }}
{{- end }}
{{- if .signerName }}
signerName: {{ .signerName | quote }}
{{- end }}
{{- end -}}


{{/*
# ConfigMapProjection
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#configmapprojection-v1-core
*/}}
{{- define "library.ConfigMapProjection" -}}
{{- if .items }}
{{- range .items }}
- key: {{ .key | quote }}
  mode: {{ .mode | quote }}
  path: {{ .path | quote }}
{{- end }}
{{- end }}
name: {{ .name | quote }}
{{- if hasKey . "optional" }}
optional: {{ .optional }}
{{- end }}
{{- end -}}


{{/*
# DownwardAPIProjection
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#downwardapiprojection-v1-core
*/}}
{{- define "library.DownwardAPIProjection" -}}
items: {{ include "library.DownwardAPIVolumeFile" .items | trim | nindent 2 }}
{{- end -}}


{{/*
# SecretProjection
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#secretprojection-v1-core
*/}}
{{- define "library.SecretProjection" -}}
items:
{{- range .items }}
- key: {{ .key | quote }}
  mode: {{ .mode | int }}
  path: {{ .path | quote }}
{{- end }}
name: {{ .name | quote }}
{{- if hasKey . "optional" }}
optional: {{ .optional }}
{{- end }}
{{- end -}}


{{/*
# ServiceAccountTokenProjection
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#serviceaccounttokenprojection-v1-core
*/}}
{{- define "library.ServiceAccountTokenProjection" -}}
audience: {{ .audience | quote }}
expirationSeconds: {{ .expirationSeconds | int }}
path: {{ .path | quote }}
{{- end -}}


{{/*
# SecretVolumeSource
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#secretvolumesource-v1-core
*/}}
{{- define "library.pod.SecretVolumeSource" -}}
defaultMode: {{ default 0644 .defaultMode | int }}
{{- if .items }}
items:
{{- range .items }}
- key: {{ .key | quote }}
  mode: {{ .mode | int }}
  path: {{ .path | quote }}
{{- end }}
{{- end }}
{{- if hasKey . "optional" }}
optional: {{ .optional }}
{{- end }}
{{- if .secretName }}
secretName: {{ .secretName | quote }}
{{- end }}
{{- end -}}