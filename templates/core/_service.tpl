{{- define "library.service" -}}
{{- $top := first . }}
{{- $validateSrc := include "library.service.validate" (list $top (tpl  (index . 1) $top)) }}
{{- $dest := (include "library.service.defaults" $top) | fromYaml }}
{{- include "library.util.merge" (dict "top" $top "src" $validateSrc "dest" $dest) -}}
{{- end -}}

{{/*
# Service
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#service-v1-core
*/}}
{{- define "library.service.validate" -}}
{{- $top := first . -}}
{{- $svc := fromYaml (include (index . 1) $top) | default (dict ) -}}
apiVersion: v1
kind: Service
{{- with $svc }}
metadata: {{- merge (.metadata | default (dict )) (fromYaml (include "library.metadata.resource" $top)) | toYaml | nindent 2 }}
spec:
  allocateLoadBalancerNodePorts: {{ default false .allocateLoadBalancerNodePorts }}
  {{- if .clusterIP  }}
  clusterIP: {{ .clusterIP }}
  {{- end }}
  {{- if .clusterIPs }}
  clusterIPs: {{ .clusterIPs }}
  {{- end }}
  {{- if .externalIPs }}
  externalIPs: {{ .externalIPs }}
  {{- end }}
  {{- if .externalName }}
  externalName: {{ .externalName }}
  {{- end }}
  {{- if .externalTrafficPolicy }}
  externalTrafficPolicy: {{ .externalTrafficPolicy }}
  {{- end }}
  {{- if $svc.healthCheckNodePort }}
  healthCheckNodePort: {{ .healthCheckNodePort }}
  {{- end }}
  internalTrafficPolicy: {{ default "Cluster" .internalTrafficPolicy }}
  {{- if .ipFamilies }}
  ipFamilies: {{ .ipFamilies }}
  {{- end }}
  ipFamilyPolicy: {{ default "SingleStack" .ipFamilyPolicy }}
  {{- if .loadBalancerClass }}
  loadBalancerClass: {{ .loadBalancerClass }}
  {{- end }}
  {{- if .loadBalancerIP }}
  loadBalancerIP: {{ .loadBalancerIP }}
  {{- end }}
  {{- if .loadBalancerSourceRanges }}
  loadBalancerSourceRanges: {{ .loadBalancerSourceRanges }}
  {{- end }}
  {{- if .ports }}
  ports: {{- include "library.service.port" (dict "top" $top "ports" .ports) | trim | nindent 2 -}}
  {{- end }}
  {{- if .publishNotReadyAddresses }}
  publishNotReadyAddresses: {{ .publishNotReadyAddresses }}
  {{- end }}
  selector:
  {{- include "library.selectorLabels" $top | nindent 4 }}
  {{- if .sessionAffinity }}
  sessionAffinity: {{ .sessionAffinity }}
  {{- end }}
  {{- if .sessionAffinityConfig }}
  sessionAffinityConfig: {{ include "library.service.sessionAffinityConfig" .sessionAffinityConfig | nindent 4 }}
  {{- end }}
  type: {{ default "ClusterIP" .type }}
{{- end }}
{{- end -}}


{{/* 
# ServicePort
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#serviceport-v1-core
*/}}
{{- define "library.service.port" -}}
{{- $top := .top -}}
{{- range .ports }}
- name: {{ required "Port name must be set" .name }}
{{- if .appProtocol }}
  appProtocol: {{ tpl (.appProtocol | toString) $top | quote }}
{{- end }}
{{- if .nodePort }}
  nodePort: {{ tpl (.nodePort | toString) $top }}
{{- end }}
{{- if .port }}
  port: {{ tpl (.port | toString) $top }}
{{- end }}
{{- if .protocol }}
  protocol: {{ tpl (.protocol | toString) $top }}
{{- end }}
{{- if .targetPort }}
  targetPort: {{ tpl (.targetPort | toString) $top }}
{{- end }}
{{- end -}}
{{- end -}}


{{/*
# SessionAffinityConfig
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#sessionaffinityconfig-v1-core
*/}}
{{- define "library.service.sessionAffinityConfig" -}}
clientIP: {{ include "library.service.clientIPConfig" .clientIP | nindent 2 }}
{{- end -}}


{{/*
# ClientIPConfig
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#clientipconfig-v1-core
*/}}
{{- define "library.service.clientIPConfig" -}}
timeoutSeconds: {{ .timeoutSeconds }}
{{- end -}}