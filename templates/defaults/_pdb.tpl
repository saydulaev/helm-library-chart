{{- define "library.pdb.defaults" -}}
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  labels:
    helm.sh/template-source: {{ .Template.Name }}
    helm.sh/version: {{ .Capabilities.HelmVersion.Version }}
spec:
  minAvailable: 2
{{- end -}}