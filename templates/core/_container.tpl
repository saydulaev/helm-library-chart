{{/* List of containers */}}
{{- define "library.containers" -}}
{{- $top := .top -}}
{{- range $container := .containers }}
{{ include "library.container" (dict "top" $top "container" $container) }}
{{- end }}
{{- end -}}

{{/*
# Container
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#container-v1-core
*/}}
{{- define "library.container" -}}
{{- $top := .top -}}
- name: {{ required "Container name is required!" (tpl (.container.name | toString) $top) | quote }}
  {{- if .container.args }}
  args: 
  {{- range .container.args }}
  - {{ tpl (. | toString) $top }}
  {{- end }}
  {{- end }}
  {{- if .container.command }}
  command:
  {{- range .container.command }}
  - {{ tpl (. | toString) $top }}
  {{- end }}
  {{- end }}
  {{- if .container.env }}
  env: {{ include "library.container.env" (dict "top" $top "envs" .container.env) | trim | nindent 2 }}
  {{- end }}
  {{- if .container.envFrom }}
  envFrom: {{ tpl (.container.envFrom | toYaml | toString) $top | trim | nindent 2 }}
  {{- end }}
  image: {{- include "library.container.image" (dict "top" $top "container" .container) }}
  imagePullPolicy: {{ default "Always" .container.imagePullPolicy }}
  {{- if .container.lifecycle }}
  lifecycle: {{- include "library.container.lifecycle" (dict "top" .top "lifecycle" .container.lifecycle) | nindent 4 -}}
  {{- end }}
  {{- if .container.livenessProbe }}
  livenessProbe: {{- include "library.container.actionHandler" (dict "top" $top "probe" .container.livenessProbe) | trim | nindent 4 -}}
  {{- end }}
  {{- if .container.ports }}
  ports:
  {{- include "library.container.ports" .container.ports | trim | nindent 2 -}}
  {{- end }}
  {{- if .container.readinessProbe }}
  readinessProbe: {{- include "library.container.actionHandler" (dict "top" $top "probe" .container.readinessProbe) | trim | nindent 4 -}}
  {{- end }}
  {{- if .container.resizePolicy }}
  resizePolicy: {{- include "library.container.resizePolicy" .container.resizePolicy -}}
  {{- end }}
  resources: {{- include "library.container.resources" .container.resources | trim | nindent 4 -}}
  {{- if .container.restartPolicy }}
  restartPolicy: {{ .container.restartPolicy | quote }}
  {{- end }}
  {{- if .container.securityContext }}
  securityContext: {{- include "library.securityContext" .container.securityContext | trim | nindent 4 -}}
  {{- end }}
  {{- if .container.startupProbe }}
  startupProbe: {{- include "library.container.actionHandler" (dict "top" $top "probe" .container.startupProbe) | trim | nindent 4 -}}
  {{- end }}
  {{- if hasKey .container "stdin" }}
  stdin: {{ .container.stdin }}
  {{- end }}
  {{- if hasKey .container "stdinOnce" }}
  stdinOnce: {{ .container.stdinOnce }}
  {{- end }}
  {{- if .container.terminationMessagePath }}
  terminationMessagePath: {{ tpl (.container.terminationMessagePath | toString) $top | quote }}
  {{- end }}
  {{- if .container.terminationMessagePolicy }}
  terminationMessagePolicy: {{ tpl (.container.terminationMessagePolicy | toString) $top | quote }}
  {{- end }}
  {{- if hasKey .container "tty" }}
  tty: {{ default false .container.tty }}
  {{- end }}
  {{- if .container.volumeDevices }}
  volumeDevices: {{- include "library.container.volumeDevices" .container.volumeDevices | trim | nindent 4 -}}
  {{- end }}
  {{- if .container.volumeMounts }}
  volumeMounts:  {{ include "library.container.volumeMounts" .container.volumeMounts | trim | nindent 4 }}
  {{- end }}
  {{- if .container.workingDir }}
  workingDir: {{ .container.workingDir }}
  {{- end }}
{{- end -}}


{{/*
# ContainerResizePolicy
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#containerresizepolicy-v1-core
*/}}
{{- define "library.container.resizePolicy" -}}
{{- $resources := (list "cpu" "memory" | toStrings) -}}
{{- if and .resourceName (has (default "" .resourceName) $resources) }}
resourceName: {{ .resourceName }}
{{- else }}
{{ fail (printf "Container.resizePolicy.resourceName could be: %v" $resources) }}
{{- end }}
restartPolicy: {{ .restartPolicy }}
{{- end -}}


{{/*
# VolumeDevice
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#volumedevice-v1-core
*/}}
{{- define "library.container.volumeDevices" -}}
{{- range .volumeDevices }}
- devicePath: {{ .devicePath | quote }}
  name: {{ .name | quote }}
{{- end }}
{{- end -}}


{{/*
# ResourceRequirements
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#resourcerequirements-v1-core
*/}}
{{- define "library.container.resources" -}}
limits:
  memory: {{ default "128Mi" .limits.memory }}
  cpu: {{ default "128m" .limits.cpu }}
requests: 
  memory: {{ default "128Mi" .requests.memory }}
  cpu: {{ default "128m" .requests.cpu }}
{{- if .claims }}
claims: {{- include "library.container.resourceClaim" .claims | nindent 2 -}}
{{- end }}
{{- end -}}


{{/*
# ResourceClaim
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#resourceclaim-v1-core
*/}}
{{- define "library.container.resourceClaim" -}}
name: {{ .name | quote }}
{{- end -}}


{{/*
# VolumeMount
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#volumemount-v1-core
*/}}
{{- define "library.container.volumeMounts" -}}
{{- range . }}
- name: {{ required "Name of volume must be defined" .name }}
  {{- if .mountPath }}
  mountPath: {{ .mountPath }}
  {{- end }}
  {{- if .mountPropagation }}
  mountPropagation: {{ .mountPropagation }}
  {{- end }}
  {{- if .readOnly }}
  readOnly: {{ .readOnly }}
  {{- end }}
  {{- if .subPath }}
  subPath: {{ .subPath }}
  {{- end }}
  {{- if .subPathExpr }}
  subPathExpr: {{ .subPathExpr }}
  {{- end }}
{{- end }}
{{- end -}}


{{/*
# ExecAction
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#execaction-v1-core
*/}}
{{- define "library.container.lifecycle.exec" -}}
{{- $top := .top -}}
command:
{{- range .action.command }}
- {{ tpl (. | toString) $top }}
{{- end }}
{{- end -}}


{{/*
# HTTPGetAction
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#execaction-v1-core
*/}}
{{- define "library.container.lifecycle.httpGet" -}}
{{- $top := .top -}}
{{- with .action -}}
{{- if .host }}
host: {{ tpl (.host | toString) $top }}
{{- end }}
{{- if .httpHeaders }}
httpHeaders: {{ toYaml .httpHeaders | nindent 0 }}
{{- end }}
{{- if .path }}
path: {{ tpl (.path | toString) $top }}
{{- end }}
{{- if .port }}
port: {{ tpl (.port | toString) $top }}
{{- end }}
{{- if .scheme }}
scheme: {{ tpl (.scheme | toString) $top }}
{{- end }}
{{- end }}
{{- end -}}


{{/*
# GRPCAction
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#grpcaction-v1-core
*/}}
{{- define "library.container.lifecycle.grpc" -}}
port: {{ .action.port }}
service: {{ .action.service }}
{{- end -}}


{{/*
# TCPSocketAction
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#tcpsocketaction-v1-core
*/}}
{{- define "library.container.lifecycle.tcpSocket" -}}
{{- if .action.host }}
host: {{ tpl (.action.host | toString) .top }}
{{- end }}
{{- if .action.port }}
port: {{ tpl (.action.port | toString) .top }}
{{- end }}
{{- end -}}


{{/*
# SleepAction
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#sleepaction-v1-core
*/}}
{{- define "library.container.lifecycle.sleep" -}}
seconds: {{ .action.seconds }}
{{- end -}}


{{/*
# Lifecycle
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#lifecycle-v1-core
*/}}
{{- define "library.container.lifecycle" -}}
{{- if .lifecycle.postStart -}}
postStart: {{- include "library.container.lifecycleHandler" (dict "top" .top "handler" .lifecycle.postStart) | nindent 2 -}}
{{- end }}
{{- if .lifecycle.preStop }}
preStop: {{- include "library.container.lifecycleHandler" (dict "top" .top "handler" .lifecycle.preStop) | nindent 2 -}}
{{- end }}
{{- end -}}


{{/*
# LifecycleHandler
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#lifecyclehandler-v1-core
*/}}
{{- define "library.container.lifecycleHandler" -}}
{{- $handlerType := first (keys .handler) -}}
{{- if eq $handlerType "exec" }}
exec: {{- include "library.container.lifecycle.exec" (dict "top" .top "action" .handler.exec) | trim | nindent 2 -}}
{{- end }}
{{- if eq $handlerType "httpGet" }}
httpGet: {{- include "library.container.lifecycle.httpGet" (dict "top" .top "action" .handler.httpGet) | trim | nindent 2 -}}
{{- end }}
{{- if eq $handlerType "tcpSocket" }}
tcpSocket: {{- include "library.container.lifecycle.tcpSocket" (dict "top" .top "action" .handler.tcpSocket) | trim | nindent 2 -}}
{{- end }}
{{- if eq $handlerType "sleep" }}
sleep: {{- include "library.container.lifecycle.sleep" (dict "top" .top "action" .handler.sleep) | nindent 2 -}}
{{- end }}
{{- end -}}

{{/*
# ContainerPort
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#containerport-v1-core
*/}}
{{- define "library.container.ports" -}}
{{- range . -}}
- containerPort: {{ .containerPort }}
  {{- if .hostIP }}
  hostIP: {{ .hostIP }}
  {{- end }}
  {{- if .hostPort }}
  hostPort: {{ .hostPort }}
  {{- end }}
  {{- if .protocol }}
  protocol: {{ default "TCP" .protocol | quote }}
  {{- end }}
{{- end }}
{{- end -}}


{{- define "library.container.actionParams" -}}
{{- if .failureThreshold }}
failureThreshold:  {{ default 30 .failureThreshold }}
{{- end }}
{{- if .periodSeconds }}
periodSeconds: {{ default 10 .periodSeconds }}
{{- end }}
{{- if .initialDelaySeconds }}
initialDelaySeconds: {{ default 5 .initialDelaySeconds }}
{{- end }}
{{- end -}}


{{- define "library.container.actionHandler" -}}
{{- $top := .top -}}
{{- $keys := (keys .probe) -}}
{{- if has "exec" $keys -}}
exec: 
{{- include "library.container.lifecycle.exec" (dict "top" $top "action" .probe.exec) | nindent 2 -}}
{{- include "library.container.actionParams" .probe -}}
{{- end }}
{{- if has "httpGet" $keys -}}
httpGet: 
{{- include "library.container.lifecycle.httpGet" (dict "top" $top "action" .probe.httpGet) | trim | nindent 2 -}}
{{- include "library.container.actionParams" .probe -}}
{{- end }}
{{- if has "tcpSocket" $keys -}}
tcpSocket: 
{{- include "library.container.lifecycle.tcpSocket" (dict "top" $top "action" .probe.tcpSocket) | trim | nindent 2 -}}
{{- include "library.container.actionParams" .probe -}}
{{- end }}
{{- if has "sleep" $keys -}}
sleep: 
{{- include "library.container.lifecycle.sleep" (dict "top" $top "action" .probe.sleep) | trim | nindent 2 -}}
{{- include "library.container.actionParams" .probe -}}
{{- end }}
{{- if has "grpc" $keys -}}
grpc: 
{{- include "library.container.lifecycle.sleep" (dict "top" $top "action" .probe.grpc) | trim | nindent 2 -}}
{{- include "library.container.actionParams" .probe | nindent 2 -}}
{{- end }}
{{- end -}}