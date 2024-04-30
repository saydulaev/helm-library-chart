# Library chart


This chart provide a core Kubernetes resource definitions.

Tha main purpose of this chart to figure out how to use library chart in Helm.

Example.

Let's suppose we have an upper chart that includes our library and use it definitions. Our deployment.yaml will looks like:

```yaml
{{- define "base.deployment" -}}
metadata:
  labels:
    base.deployment: true
spec:
  template:
    spec:
      serviceAccountName: {{ include "library.fullname" . }}
      priorityClassName: "base.deployment"
      hostNetwork: false
      {{- if hasKey .Values.deployment "hostAliases" }}
      hostAliases: {{ .Values.deployment.hostAliases | toYaml | trim | nindent 8 }}
      {{- end }}
      {{- if .Values.app.ephemeralContainers }}
      ephemeralContainers: {{ tpl (.Values.app.ephemeralContainers | toYaml | toString) . | nindent 6 }}
      {{- end }}
      {{- if .Values.app.initContainers }}
      initContainers: {{ tpl (.Values.app.initContainers | toYaml | toString) . | nindent 6 }}
      {{- end }}
      {{- if .Values.app.containers }}
      containers: {{ tpl (.Values.app.containers | toYaml | toString) . | nindent 6 }}
      {{- end }}
      {{- if .Values.app.volumes }}
      volumes: {{ tpl (.Values.app.volumes | toYaml | toString) . | nindent 6 }}
      {{- end }}
      securityContext: {{ default (dict ) (tpl (.Values.app.securityContext | toYaml | toString) .) | nindent 8 }}
      {{- if .Values.tolerations }}
      tolerations: {{ tpl (.Values.tolerations | toYaml | toString) . | nindent 6 }}
      {{- end }}
{{- end -}}

{{- include "library.deployment" (list . "base.deployment") -}}
```
The above example we defined the custom template called `base.deployment`. Then we included the `library.deployment` custom template from our library chart with list of args. At that moment when we run `helm template ...` under the hood the library chart will perform the next steps:
 1. `$validateSrc := include "library.Deployment" (list $top (tpl  (index . 1) $top))` First render our `base.deployment` and then validate it according to the `library.Deployment` template.
 2. `$dest := (include "library.deployment.defaults" $top) | fromYaml` Load library default template. That allows us not define the main spec into upper deployment definitions
 3. `include "library.util.merge" (dict "top" $top "src" $validateSrc "dest" $dest)` Merge our previously validated template to destination (default) template to ensure that all Deployment requirements will be keeped
