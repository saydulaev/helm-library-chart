{{- define "library.ingress.defaults" -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
spec:
  rules:
  - host: {{ .Values.ingress.host | quote }}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: {{ include "library.fullname" . }}
            port:
              number: 80
  {{- if .Values.ingress.tls }}
  tls:
    - hosts:
        - {{ .Values.ingress.host }}
      secretName: {{ .Values.ingress.host }}-tls
  {{- end }}
{{- end -}}