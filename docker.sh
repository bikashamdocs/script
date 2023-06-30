#!/bin/bash
# Script to pull and publish public docker images used by TI into our private ACR.
# Auth Note -: Please make sure to login into the diff destination private ACR reg on terminal shell from where the script is run. 

GREEN='\033[0;32m'
NC='\033[0m'
Yellow='\033[0;33m'

# Public images to be published under ACR
images=(
    "docker.io/library/mongo:5.0.4"
    "docker.io/library/mongo:4.4"
    "docker.io/library/rabbitmq:3.9.10-management-alpine"
    "docker.elastic.co/beats/filebeat:8.2.1"
    "docker.io/library/redis:7"
    "docker.elastic.co/logstash/logstash:8.2.1"
    "docker.io/fission/fetcher:v1.15.1"
    "docker.io/fission/node-env:latest"
    "fission/fetcher:v1.15.1"
    "docker.io/fission/node-env:latest"
    "docker.io/library/influxdb:1.8"
    "index.docker.io/fluent/fluent-bit:1.8.8"
    "docker.io/fluent/fluent-bit:1.8.8"
    "docker.io/library/busybox:latest"
    "index.docker.io/fission/fission-bundle:v1.15.1"
    "docker.io/fission/fission-bundle:v1.15.1"
    "k8s.gcr.io/ingress-nginx/controller:v1.1.0@sha256:f766669fdcf3dc26347ed273a55e754b427eb4411ee075a53f30718b4499076a"
    "quay.io/prometheus/alertmanager:v0.24.0"
    "docker.io/grafana/agent:main"
    "quay.io/kiwigrid/k8s-sidecar:1.19.2"
    "docker.io/library/busybox:1.31.1"
    "docker.io/grafana/grafana:9.1.4"
    "registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.6.0"
    "quay.io/prometheus-operator/prometheus-operator:v0.59.1"
    "quay.io/prometheus/node-exporter:v1.3.1"
    "docker.io/grafana/loki:2.6.1"
    "docker.io/prom/blackbox-exporter:v0.22.0"
    "quay.io/prometheus/prometheus:v2.38.0"
    "quay.io/prometheus-operator/prometheus-config-reloader:v0.59.1"
    "docker.io/velero/velero:v1.8.1"
    "docker.io/velero/velero-plugin-for-microsoft-azure:master"
    "ghcr.io/external-secrets/kubernetes-external-secrets:8.3.0"
)

# Private ACR for diff TI env's
dockerrReg=(
    "devdockerti.azurecr.io"
    "stagingdockerti.azurecr.io"
    "proddockerti.azurecr.io"
    "devdockerdice.azurecr.io"
    "stagingdockerdice.azurecr.io"
    "proddockerdice.azurecr.io"
    "proddrilldockerti.azurecr.io"
    "icedev.azurecr.io"
    "icedprod.azurecr.io"
)

# Process all docker images
for image in ${images[@]};
do
    echo -e "${GREEN}Pulling public image => \"${image}\"...${NC}"
    docker pull ${image}
    for reg in ${dockerrReg[@]};
    do
        retaggedImage="$( cut -d '/' -f 2- <<< "$image" )";
        retaggedImage=$reg"/"$retaggedImage;
        echo -e "${Yellow}Tagging docker image as per destination \"${reg}\" ACR...${NC}"
        docker tag $image $retaggedImage    # Retag them as per new destination
        
        echo -e "${GREEN}Pushing image to ACR, \"${retaggedImage}\"...${NC} \n"
        docker push $retaggedImage          # Push them to destination ACR
        echo "==================================================================="
    done
done
