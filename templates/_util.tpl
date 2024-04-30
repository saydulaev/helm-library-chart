{{- /*
mylibchart.util.merge will merge two YAML templates and output the result.
This takes an array of three values:
- the top context
- the template name of the dest (destination)
- the template name of the base (src)
*/}}
{{- define "library.util.merge" -}}
{{- $top :=  .top -}}
{{- $src := .src -}}
{{- $dest := .dest }}
{{- deepCopy $dest | mustMerge ($src | fromYaml) | toYaml -}}
{{- end -}}


{{- define "library.util.test" -}}
# typeOf . {{ typeOf . }}
{{- end -}}
