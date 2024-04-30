{{/*
# SecurityContext
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#securitycontext-v1-core
*/}}
{{- define "library.securityContext" -}}
{{- if .runAsUser }}
runAsUser: {{ default 1000 .runAsUser }}
{{- end }}
{{- if .runAsGroup }}
runAsGroup: {{ default 1000 .runAsGroup }}
{{- end }}
{{- if .fsGroup }}
fsGroup: {{ .fsGroup }}
{{- end }}
{{- if .allowPrivilegeEscalation }}
allowPrivilegeEscalation: {{ default false .allowPrivilegeEscalation }}
{{- end }}
{{- if .fsGroupChangePolicy }}
fsGroupChangePolicy: {{ default "OnRootMismatch" .fsGroupChangePolicy }} # Always
{{- end }}
{{- if .privileged }}
privileged: {{ default false .privileged }}
{{- end }}
{{- if .procMount }}
procMount: {{ .procMount }}
{{- end }}
{{- if .readOnlyRootFilesystem }}
readOnlyRootFilesystem: {{ default true .readOnlyRootFilesystem }}
{{- end }}
{{- if .runAsNonRoot }}
runAsNonRoot: {{ default true .runAsNonRoot }}
{{- end }}
{{- if .windowsOptions }}
windowsOptions:
  {{- include "library.securityContext.windowsOptions" .windowsOptions | nindent 2 -}}
{{- end }}
{{- if .capabilities }}
capabilities:
  {{- include "library.securityContext.capabilities" .capabilities | nindent 2 -}}
{{- end }}
{{- if .seccompProfile }}
seccompProfile:
  {{- include "library.securityContext.seccompProfile" .seccompProfile | nindent 2 -}}
{{- end }}
{{- if .seLinuxOptions }}
seLinuxOptions:
  {{- include "library.securityContext.seLinuxOptions" .seLinuxOptions | nindent 2 -}}
{{- end }}
{{- end -}}


{{/*
# SELinuxOptions
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#selinuxoptions-v1-core
*/}}
{{- define "library.securityContext.seLinuxOptions" -}}
{{- if .level }}
level: {{ .level }}
{{- end }}
{{- if .role }}
role: {{ .role }}
{{- end }}
{{- if .type }}
type: {{ .type }}
{{- end }}
{{- if .user }}
user: {{ .user }}
{{- end }}
{{- end -}}


{{/*
# Capabilities
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#capabilities-v1-core
*/}}
{{- define "library.securityContext.capabilities" -}}
{{- if .add }}
add: {{ .add }}
{{- end }}
{{- if .drop }}
drop: {{ .drop }}
{{- end }}
{{- end -}}


{{/*
# SeccompProfile
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#seccompprofile-v1-core
*/}}
{{- define "library.securityContext.seccompProfile" -}}
{{- if .type }}
type: RuntimeDefault # localhostProfile RuntimeDefault Unconfined Localhost
  {{- if eq .seccompProfile.type "Localhost" }}
  localhostProfile: {{ .seccompProfile.localhostProfile }}
  {{- end }}
{{- end }}
{{- end -}}


{{/*
# WindowsSecurityContextOptions
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#windowssecuritycontextoptions-v1-core
*/}}
{{- define "library.securityContext.windowsOptions" -}}
{{- if .gmsaCredentialSpec }}
gmsaCredentialSpec: {{ .gmsaCredentialSpec }}
{{- end }}
{{- if .gmsaCredentialSpecName }}
gmsaCredentialSpecName: {{ .gmsaCredentialSpecName }}
{{- end }}
{{- if .hostProcess }}
hostProcess: {{ .hostProcess }}
{{- end }}
{{- if .runAsUserName }}
runAsUserName: {{ .runAsUserName }}
{{- end }}
{{- end -}}