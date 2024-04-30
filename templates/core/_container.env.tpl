{{/*
# EnvVar
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#envvar-v1-core
*/}}
{{- define "library.container.env" -}}
{{- $top := .top -}}
{{- $envs := .envs -}}
{{- range $env := .envs -}}
- name: {{ $env.name | quote }}
{{- if $env.value }}
  value: {{ tpl ($env.value | toString) $top | quote }}
{{- end }}
{{- if .valueFrom }}
  valueFrom:
{{- $valueFrom := first (keys $env.valueFrom) -}}
  {{- if eq $valueFrom "configMapKeyRef" }}
    configMapKeyRef:
    {{- with $env.valueFrom.configMapKeyRef }}
      key: {{ .key }}
      name: {{ .name }}
      optional: {{ default false .optional }}
    {{- end }}
  {{- else if eq $valueFrom "resourceFieldRef" }}
    resourceFieldRef:
    {{- with $env.valueFrom.resourceFieldRef }}
      containerName: {{ .containerName }}
      {{- if .divisor }}
      divisor: {{ .divisor }}
      {{- end }}
      resource: {{ .resource }}
    {{- end }}
  {{- else if eq $valueFrom "secretKeyRef" }}
    secretKeyRef:
    {{- with $env.valueFrom.secretKeyRef }}
      key: {{ .key }}
      name: {{ .name }}
      optional: {{ default false .optional }}
    {{- end }}
  {{- else if eq $valueFrom "fieldRef" }}
    fieldRef:
    {{- with $env.valueFrom.fieldRef }}
      {{- if .apiVersion }}
      apiVersion: {{ .apiVersion }}
      {{- end }}
      fieldPath: {{ .fieldPath }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}
{{- end -}}


{{- define "library.container.envFrom" -}}
{{- $top := .top -}}
{{- $envs := .envs -}}
{{- range $env := $envs }}
{{- $envFrom := first (keys $env.envFrom) -}}
- {{ $envFrom }}:
  {{- with $env }}
    name: {{ tpl (.name | toString) $top }}
    optional: {{ default false .optional }}
  {{- end }}
{{- end }}
{{- end -}}

{{/*
# fieldRef
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#objectfieldselector-v1-core
*/}}
{{- define "library.container.env.fieldRef" -}}
{{- if .apiVersion }}
apiVersion: {{ .apiVersion }}
{{- end }}
fieldPath: {{ .fieldPath }}
{{- end -}}


{{- define "library.container.env.configMapKeyRef" -}}
key: {{ .key }}
name: {{ .name }}
optional: {{ default false .optional }}
{{- end -}}


{{/*
# resourceFieldRef
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#resourcefieldselector-v1-core
*/}}
{{- define "library.container.env.resourceFieldRef" -}}
containerName: {{ .containerName }}
{{- if .divisor }}
divisor: {{ .divisor }}
{{- end }}
resource: {{ .resource }}
{{- end -}}


{{- define "library.container.env.secretKeyRef" -}}
key: {{ .key }}
name: {{ .name }}
optional: {{ default false .optional }}
{{- end -}}


{{/*
# configMapRef
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#configmapenvsource-v1-core
*/}}
{{- define "library.container.env.configMapRef" -}}
name: {{ .name }}
optional: {{ default false .optional }}
{{- end }}


{{/*
# secretRef
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#secretenvsource-v1-core
*/}}
{{- define "library.container.env.secretRef" -}}
name: {{ .name }}
optional: {{ default false .optional }}
{{- end -}}