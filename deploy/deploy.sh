#!/usr/bin/env sh

set -eux

# Create the namespace
kubectl create namespace $NAMESPACE || true

# Delete Kubernetes secret if exists
kubectl delete secret ocl-service-account --namespace $NAMESPACE || true

# Create GCP service account file
cat $GOOGLE_APPLICATION_CREDENTIALS >> ./service-account.json

# Recreate service account file as Kubernetes secret
kubectl create secret generic ocl-service-account \
    --namespace $NAMESPACE \
    --from-file=key.json=./service-account.json

helm upgrade \
    --install \
    --debug \
    --create-namespace \
    --namespace "${NAMESPACE}" \
    --set app.replicaCount="${APP_REPLICA_COUNT}" \
    --set service.port="${PORT}"\
    --set service.backendport="${BACKEND_PORT}"\
    --set app.container.env.databaseInstanceConnectionName="${DB_INSTANCE_NAME}"\
    --set app.container.env.redisHost="${REDIS_HOST}"\
    --set app.container.env.redisPort="${REDIS_PORT}"\
    --set app.container.env.dbHost="${DB_HOST}"\
    --set app.container.env.dbPort="${DB_PORT}"\
    --set app.container.env.db="${DB}"\
    --set app.container.env.dbPassword="${DB_PASSWORD}"\
    --set app.container.env.elasticSearchHost="${ES_HOST}"\
    --set app.container.env.elasticSearchPort="${ES_PORT}"\
    --set app.container.env.environment="${ENVIRONMENT}"\
    --set app.container.env.debug="${DEBUG}"\
    --set app.container.env.secretKey="${SECRET_KEY}"\
    --set app.container.env.sentryDsn="${SENTRY_DSN_KEY}"\
    --set app.container.env.apiSuperUserPassword="${API_SUPERUSER_PASSWORD}"\
    --set app.container.env.apiSuperUserToken="${API_SUPERUSER_TOKEN}"\
    --set app.container.env.apiBaseURL="${API_BASE_URL}"\
    --set app.container.env.apiInternalBaseURL="${API_INTERNAL_BASE_URL}"\
    --set app.container.env.emailNoReplyPassword="${EMAIL_NOREPLY_PASSWORD}"\
    --set app.container.env.awsAccessKeyID="${AWS_ACCESS_KEY_ID}"\
    --set app.container.env.awsSecretAccessKey="${AWS_SECRET_ACCESS_KEY}"\
    --set app.container.env.awsStorageBucketName="${AWS_STORAGE_BUCKET_NAME}"\
    --set app.container.env.awsRegionName="${AWS_REGION_NAME}"\
    --set networking.issuer.name="letsencrypt-prod"\
    --set networking.issuer.privateKeySecretRef="letsencrypt-prod"\
    --set networking.backend.ingress.host="${BACKEND_APP_DOMAIN}"\
    --set networking.ingress.host="${APP_DOMAIN}"\
    --wait \
    --timeout 300s \
    -f ./charts/openconceptlab/values.yaml \
    $APP_NAME \
    ./charts/openconceptlab
