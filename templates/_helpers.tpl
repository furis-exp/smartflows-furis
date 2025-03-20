{{/*
Expand the name of the chart.
*/}}
{{- define "smartflows.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "smartflows.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create a namespace name for the app.
*/}}
{{- define "smartflows.namespace" -}}
{{- if .Values.namespaceOverride }}
{{- .Values.namespaceOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- if .Values.createNamespace }}
{{- $name := default .Chart.Name .Values.namespaceOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- else }}
{{- printf "default" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "smartflows.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "smartflows.labels" -}}
helm.sh/chart: {{ include "smartflows.chart" . }}
{{ include "smartflows.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "smartflows.selectorLabels" -}}
app.kubernetes.io/name: {{ include "smartflows.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Repository credentials
*/}}
{{- define "imagePullSecret" }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.imageCredentials.registry (printf "%s:%s" .Values.imageCredentials.username .Values.imageCredentials.password | b64enc) | b64enc }}
{{- end }}

{{/*
Create environment variables based on the variable object provided.
*/}}

{{- define "flatten" -}}
{{- $prefix := .prefix -}}
{{- $object := .object -}}
{{- range $key, $value := $object -}}
{{- $newPrefix := printf "%s%s_" $prefix $key -}}
{{- if kindIs "map" $value -}}
{{- include "flatten" (dict "prefix" $newPrefix "object" $value) -}}
{{- else -}}
{{- $keyName := printf "%s%s" $prefix $key -}}
- name: {{ $keyName | upper }}
  value: {{ $value | quote }}{{ "\n" }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "createEnvVars" -}}
{{- $object := . -}}
{{- include "flatten" (dict "prefix" "" "object" $object) -}}
{{- end -}}
