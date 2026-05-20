{{/*
Common labels for a service.
Usage: {{ include "ob.labels" (dict "name" $name "component" "service" "root" $) }}
*/}}
{{- define "ob.labels" -}}
app.kubernetes.io/name: {{ .name }}
app.kubernetes.io/instance: {{ .name }}
app.kubernetes.io/component: {{ .component }}
app.kubernetes.io/owner: {{ .root.Values.global.owner }}
{{- end -}}

{{/*
Selector labels (must match between Deployment selector and Pod template).
*/}}
{{- define "ob.selectorLabels" -}}
app.kubernetes.io/name: {{ .name }}
app.kubernetes.io/instance: {{ .name }}
app.kubernetes.io/component: service
app.kubernetes.io/owner: {{ .root.Values.global.owner }}
{{- end -}}

{{/*
Resolve the full image reference for a service.
*/}}
{{- define "ob.image" -}}
{{- $reg := .root.Values.global.imageRegistry -}}
{{- printf "%s/%s:%s" $reg .svc.image.repository .svc.image.tag -}}
{{- end -}}

{{/*
Resolve effective resources for a service: merge global defaults with overrides.
*/}}
{{- define "ob.resources" -}}
{{- if .svc.resources -}}
{{- toYaml .svc.resources -}}
{{- else -}}
{{- toYaml .root.Values.global.resources -}}
{{- end -}}
{{- end -}}
