## ArgoCD 
- open source utility
- continuous delivery (CD) tool for Kubernetes based on GitOps principals
- is a part of k8s cluster; it pulls k8s manifest changes and applies them
- checks specific Git Repo & automatically deploys from that Git Repo to k8s cluster
- synhronize all your manifest files from Git Repo to k8s cluster
- supports: Kubernetes YAML files; Helm Charts; Kustomize 

Benefits
1. whole k8s configuration is defined as Code in Git Repository
2. single/same interface for updating cluster (Git as a single source of truth)
3. config files are not applied manually from local laptops


Best practice for Git Repo:
- separate Git Repo for application source code (java/python code) and application configuration (k8s manifest files)
- application configuration repo may contain not only Deployment.yaml but also ConfigMap, Secret, etc.
- k8s manifest files can be changed independently from source code

Workflow:
CI: sw engineer     -> GitHub (java/python code)                -> GitHub Actions/Jenkins (test/build/push artifact)  -> DockerHub/ECR/jFrog (store artifact)
CD: devops engineer -> GitGub (k8s manifest files; HelmCharts)  <-> ArgoCD (pulls changes to update k8s cluster)

ArgoCD Web: https://argoproj.github.io/cd/
ArgoCD GitHub: https://github.com/argoproj/argo-cd
Install ArgoCD: https://argo-cd.readthedocs.io/en/stable/getting_started/#1-install-argo-cd

Working with multiple clusters
1. Git branch for each environment (deployment, staging, production)
2. Using overlays with kustomize

```
.myapp-cluster
├── base
│   ├── deployment.yaml
│   ├── rbac.yaml
│   ├── service.yaml
│   └── kustomization.yaml
└── overlays                     
    ├── development
    │   └── kustomization.yaml
    ├── staging
    │   └── app2.yaml
    └── production  
        └── kustomization.yaml
```

## Application
- is main resource in ArgoCD ("kind: Application")
- can be created manually using ArgoCD UI or by using YAML Manifest file with resource "kind: Application"
- after turning "syncPolicy: automated" - ArgoCD polls Git Repo every 3 minutes
- important parameters:
  * source Repository URL
  * source Repository Branch
  * source repository Path (folder in Git)


Application spec (example):
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook
  namespace: argocd
spec:
  project: default # ArgoCD project name
  source: 
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD # Branch name from which get the code
    path: guestbook # Directory where is a code
  destination:
    server: https://kubernetes.default.svc # Cluster DNS 
    namespace: guestbook # Namespace where all manifests will be deployed 
  syncPolicy:
    automated: # automated sync by default retries failed attempts 5 times with following delays between attempts ( 5s, 10s, 20s, 40s, 80s ); retry controlled using `retry` field.
      prune: true # Specifies if resources should be pruned during auto-syncing ( false by default ).
      selfHeal: true # Specifies if partial app sync should be executed when resources are changed only in target Kubernetes cluster and no git change detected ( false by default ).
      allowEmpty: false # Allows deleting all application resources during automatic syncing ( false by default ).
    syncOptions:     # Sync options which modifies sync behavior
      - Validate=false # disables resource validation (equivalent to 'kubectl apply --validate=false') ( true by default ).
      - CreateNamespace=true # Namespace Auto-Creation ensures that namespace specified as the application destination exists in the destination cluster.
    retry:
      limit: 5 # number of failed sync attempt retries; unlimited number of attempts if less than 0
      backoff:
        duration: 5s # the amount to back off. Default unit is seconds, but could also be a duration (e.g. "2m", "1h")
        factor: 2 # a factor to multiply the base duration after each failed retry
        maxDuration: 3m # the maximum amount of time allowed for the backoff strategy

```

## Important

Without finalizer, deleting an application will not delete the resources it manages.
To perform a cascading delete, you must add the finalizer.

```
metadata:
  finalizers:
    - resources-finalizer.argocd.argoproj.io
```


## App of Apps
App ("root" ArgoCD Application) that creates other apps ("child apps"), which in turn can create other apps.
This allows you to declaratively manage a group of apps that can be deployed and configured in concert.

https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/

![Alt text](image.png)


A typical layout of Git repository:

├── Chart.yaml
├── templates
│   ├── guestbook.yaml
│   ├── helm-dependency.yaml
│   ├── helm-guestbook.yaml
│   └── kustomize-guestbook.yaml
└── values.yaml


templates contains one file for each child app, roughly:

apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook
  namespace: argocd
  finalizers: 
  - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: argocd
    server: {{ .Values.spec.destination.server }}
  project: default
  source:
    path: guestbook
    repoURL: https://github.com/argoproj/argocd-example-apps
    targetRevision: HEAD

```
│
├── HelmCharts                 # All Helm Charts
│   ├── ChartTest1
│   │   ├── Chart.yaml
│   │   ├── templates
│   │   ├── values_dev.yaml    # DEV Values
│   │   ├── values_prod.yaml   # PROD Values
│   │   └── values.yaml        # Default Values
│   └── ChartTest2
│       ├── Chart.yaml
│       ├── templates
│       ├── values_dev.yaml    # DEV Values
│       ├── values_prod.yaml   # PROD Values
│       └── values.yaml        # Default Values
│   
├── dev                        # EKS Cluster name
│   ├── applications
│   │   ├── app1.yaml
│   │   └── app2.yaml
│   └── root.yaml              # Root ArgoCD Application for Dev
└── prod                       # EKS Cluster name
    ├── applications
    │   ├── app1.yaml
    │   └── app2.yaml
    └── root.yaml              # Root ArgoCD Application for Prod   
```


### Helm chart Application example

```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app-dev
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: dev
  source:
    repoURL: 'git@github.com:Organiztion/helm-charts.git'
    path: app
    targetRevision: feature/new_application
    helm: # helm settings
      valueFiles: # File in given directory from which to get values
        - dev-values.yaml
      parameters: # additional parameters to override
        - name: 'imagePullSecrets[0].name' 
          value: pull-secret
        - name: replicaCount
          value: '1'
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: dev
  syncPolicy:
    automated: # automated sync by default retries failed attempts 5 times with following delays between attempts ( 5s, 10s, 20s, 40s, 80s ); retry controlled using `retry` field.
      prune: true # Specifies if resources should be pruned during auto-syncing ( false by default ).
      selfHeal: true # Specifies if partial app sync should be executed when resources are changed only in target Kubernetes cluster and no git change detected ( false by default ).
      allowEmpty: false # Allows deleting all application resources during automatic syncing ( false by default ).
    syncOptions:     # Sync options which modifies sync behavior
      - Validate=false # disables resource validation (equivalent to 'kubectl apply --validate=false') ( true by default ).
      - CreateNamespace=true # Namespace Auto-Creation ensures that namespace specified as the application destination exists in the destination cluster.
    # The retry feature is available since v1.7
    retry:
      limit: 5 # number of failed sync attempt retries; unlimited number of attempts if less than 0
      backoff:
        duration: 5s # the amount to back off. Default unit is seconds, but could also be a duration (e.g. "2m", "1h")
        factor: 2 # a factor to multiply the base duration after each failed retry
        maxDuration: 3m # the maximum amount of time allowed for the backoff strategy

```


## Project
- logical grouping of Applications
- reading from which Git Repo is alloweded
- where deployment can be done (namespaces, cluster)
- by default all Applications are assigned to Default Project
- Project is used rarely only when dev, qa, prod are located in the same cluster

## ApplicationSet
- this is a deploy of one Application to several clusters


