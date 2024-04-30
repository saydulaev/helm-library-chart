{{/*
Define the image pull secret as Docker config json
*/}}
{{- define "library.imagePullSecret" }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.image.registry (printf "%s:%s" .Values.image.credentials.username .Values.image.credentials.password | b64enc) | b64enc }}
{{- end }}


{{/* 
# Container image 
Verify if a container has the image field and use it.
Or use .Values.image.name and .Values.image.tag as global params
when container does not has a specific image.
*/}}
{{- define "library.container.image" -}}
{{- if .container.image }}
{{- printf "%s" .container.image | quote | indent 1 }}
{{- else }}
{{- printf "%s:%s" (tpl (.top.Values.image.name | toString) .top) (tpl (.top.Values.image.tag | toString) .top) | quote | indent 1 }}
{{- end }}
{{- end -}}


{{- define "library.container.defaultImage" -}}
{{- printf "%s:%s" (tpl (.Values.image.name | toString) .) (tpl (.Values.image.tag | toString) .) | quote | indent 1 }}
{{- end -}}