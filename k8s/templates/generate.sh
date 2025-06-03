#!/bin/bash


if [ -z "$1" ] || [[ "$2" != -p:* ]]; then
  echo "Uso: ./generate.sh nome-da-app -p:<porta>"
  exit 1
fi

APP_NAME=$1
PORT=${2#-p:} # remove prefixo -p:

PIPELINE_ID="__PIPELINE_ID__"
PROJECT_ID="__PROJECT_ID__"
REGISTRY="__REGISTRY__"
APP_PATH="__APP_PATH__"
GIT_SHA="__GIT_SHA__"

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(dirname "$SCRIPT_DIR")
APP_DIR="$ROOT_DIR/$APP_NAME"
BASE_DIR="$APP_DIR/base"
OVERLAYS_DIR="$APP_DIR/overlays"

# Ajuste dos caminhos para refletir a estrutura correta
TEMPLATE_DEPLOY="$SCRIPT_DIR/manifest-template-deployment.yaml"
TEMPLATE_SERVICE="$SCRIPT_DIR/patches/manifest-template-service.yaml"
TEMPLATE_INGRESS="$SCRIPT_DIR/manifest-template-service.yaml"
TEMPLATE_HPA="$SCRIPT_DIR/manifest-template-hpa.yaml"
TEMPLATE_CONFIGMAP="$SCRIPT_DIR/manifest-template-configmap.yaml"
TEMPLATE_SECRET="$SCRIPT_DIR/manifest-template-secret.yaml"
TEMPLATE_ROLLOUT_PATCH="$SCRIPT_DIR/patches/manifest-template-rollouts.yaml"
TEMPLATE_INGRESS_PATCH="$SCRIPT_DIR/manifest-template-ingress.yaml"
TEMPLATE_DD="$SCRIPT_DIR/kustomizeconfig/manifest-template-dd-transformer.yaml"
TEMPLATE_SUFFIX="$SCRIPT_DIR/kustomizeconfig/manifest-template-suffix-transformer.yaml"

# === BASE ===
mkdir -p "$BASE_DIR"
cp "$TEMPLATE_DEPLOY" "$BASE_DIR/deployment.yaml"
cp "$TEMPLATE_SERVICE" "$BASE_DIR/service.yaml"

for file in deployment.yaml service.yaml; do
  sed -i "s/__NAME__/$APP_NAME/g" "$BASE_DIR/$file"
  sed -i "s/__PORT__/$PORT/g" "$BASE_DIR/$file"
done

cat <<EOF > "$BASE_DIR/kustomization.yaml"
resources:
  - deployment.yaml
  - service.yaml
EOF

# === OVERLAYS ===
for ENV in dev qa prod; do
  ENV_PATH="$OVERLAYS_DIR/$ENV"
  mkdir -p "$ENV_PATH/patches" "$ENV_PATH/kustomizeconfig"

  cp "$TEMPLATE_HPA" "$ENV_PATH/hpa.yaml"
  cp "$TEMPLATE_CONFIGMAP" "$ENV_PATH/configmap.yaml"
  cp "$TEMPLATE_SECRET" "$ENV_PATH/secret.yaml"
  cp "$TEMPLATE_ROLLOUT_PATCH" "$ENV_PATH/patches/rollouts.yaml"
  cp "$TEMPLATE_INGRESS_PATCH" "$ENV_PATH/ingress.yaml"
  cp "$TEMPLATE_DD" "$ENV_PATH/kustomizeconfig/dd-transformer.yaml"
  cp "$TEMPLATE_SUFFIX" "$ENV_PATH/kustomizeconfig/namesuffixtransformer.yaml"

  for file in hpa.yaml configmap.yaml secret.yaml patches/rollouts.yaml ingress.yaml; do
    sed -i "s/__NAME__/$APP_NAME/g" "$ENV_PATH/$file"
    sed -i "s/__ENV__/$ENV/g" "$ENV_PATH/$file"
    sed -i "s/__PORT__/$PORT/g" "$ENV_PATH/$file"
  done

  for file in kustomizeconfig/dd-transformer.yaml kustomizeconfig/namesuffixtransformer.yaml; do
    sed -i "s/__NAME__/$APP_NAME/g" "$ENV_PATH/$file"
    sed -i "s/__ENV__/$ENV/g" "$ENV_PATH/$file"
  done

  cat <<EOF > "$ENV_PATH/kustomization.yaml"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base
  - configmap.yaml
  - hpa.yaml
  - secret.yaml
  - ingress.yaml
patches:
  - path: ./patches/rollouts.yaml

transformers:
  - ./kustomizeconfig/namesuffixtransformer.yaml
  - ./kustomizeconfig/dd-transformer.yaml

images:
  - name: IMAGE_NAME/PATH:TAG
    newName: $APP_NAME
    newTag: latest

labels:
  - includeSelectors: true
    pairs:
      app: $APP_NAME
EOF

done

echo "✅ Estrutura padronizada de Kubernetes gerada para: $APP_NAME"
