{{- define "library.hpa.defaults" -}}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  labels:
    helm.sh/template-source: {{ .Template.Name }}
    helm.sh/version: {{ .Capabilities.HelmVersion.Version }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "library.fullname" . }}
  minReplicas: 1
  maxReplicas: 3
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 70
{{- end -}}