# Kubernetes Demo com Minikube + ArgoCD + Rollouts

Este repositório é uma base para iniciar projetos Kubernetes com suporte a:

- Ambientes: `dev`, `qa`, `prod`
- Geração automatizada de manifests via script
- Estrutura `kustomize` com base e overlays
- Integração com ArgoCD
- Suporte a Rollouts (deploy canário)
- Autoscaling via HPA (Horizontal Pod Autoscaler)

---

## ✨ Requisitos

- Docker Desktop (habilitado)
- Minikube (com driver Hyper-V ou Docker)
- Node.js/NPM (para testar backend local)
- Git / Bash / Make / curl / wget

---

## ⚙️ Instalação do Minikube

```bash
choco install minikube -y
minikube start --driver=docker --memory=6000 --cpus=2
```

> Se estiver usando Hyper-V, certifique-se de estar com a rede externa habilitada no gerenciador de virtualização.

---

## 🎓 Configuração inicial do cluster

### Habilitar Ingress NGINX

```bash
minikube addons enable ingress
```

### Habilitar Metrics Server (para HPA)

```bash
minikube addons enable metrics-server
```

### Adicionar vhost local (Windows)

> **Atenção**: O arquivo `hosts` deve ser editado com permissão de administrador.
> **Atenção**: O IP pode mudar a cada reinicialização do Minikube.

```bash
$ minikube ip
172.24.168.198
```

Edite o arquivo `C:\Windows\System32\drivers\etc\hosts` e adicione:

```text
172.24.168.198    k8s-demo-backend-qa
172.24.168.198    k8s-demo-backend-dev
172.24.168.198    k8s-demo-backend-prod
```

---

## 🧱 Instalar o ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### Acessar a UI do ArgoCD

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Abra [https://localhost:8080](https://localhost:8080)

#### Credenciais iniciais

- **Usuário**: `admin`
- **Senha**: output do comando:

```bash
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```

---

## 🌐 Instalar Argo Rollouts

```bash
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
```

Verifique o pod:

```bash
kubectl get pods -n argo-rollouts
```

---

## 🚀 Gerar estrutura de app

O script `generate.sh` cria toda estrutura de base + overlays + transformers + patches.

```bash
cd templates
bash generate.sh nome-do-app -p:3000
```

### Estrutura gerada:

```bash
my-app/
  base/
    deployment.yaml
    service.yaml
    kustomization.yaml
  overlays/
    dev/
      configmap.yaml
      hpa.yaml
      secret.yaml
      ingress.yaml
      patches/
        rollouts.yaml
      kustomizeconfig/
        dd-transformer.yaml
        namesuffixtransformer.yaml
      kustomization.yaml
```

---

## 🔧 Subindo a aplicação com ArgoCD

Crie um Application:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: k8s-demo-backend
  namespace: argocd
spec:
  destination:
    namespace: k8s-demo-dev
    server: https://kubernetes.default.svc
  source:
    repoURL: { { URL_DO_REPO } }
    path: k8s-demo-backend/overlays/dev
    targetRevision: HEAD
  project: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

> Substitua `repoURL` por seu caminho real local (se estiver testando com ArgoCD local).

---

## 📊 Monitorar HPA

```bash
kubectl get hpa -n k8s-demo-dev
kubectl top pods -n k8s-demo-dev
```

eval $(minikube -p minikube docker-env)

docker build -t k8s-demo-backend:latest .

$ kubectl port-forward svc/k8s-demo-backend-dev 80:3000 -n k8s-demo-dev
