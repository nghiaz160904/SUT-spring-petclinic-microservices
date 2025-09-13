#!/bin/bash

# ===============================
# Config
DOCKER_USER="nghiax1609"
DOCKER_REPO_PREFIX="$DOCKER_USER/spring-petclinic"
services=(
    "customers-service"
    "vets-service"
    "visits-service"
    "api-gateway"
    "config-server"
    "discovery-server"
    "admin-server"
)
# ===============================

echo "=== Step 1: Build Docker images with Maven ==="
./mvnw clean install -P buildDocker -DskipTests

echo "=== Step 2: Tag and Push images to Docker Hub ==="

for service in "${services[@]}"; do
    if [[ -z "$service" ]]; then
        echo " Skipping empty service"
        continue
    fi

    LOCAL_TAG="springcommunity/spring-petclinic-$service:latest"
    REMOTE_TAG="$DOCKER_REPO_PREFIX-$service:latest"

    # Kiểm tra image có tồn tại chưa
    exists=$(docker images -q "$LOCAL_TAG")
    if [[ -z "$exists" ]]; then
        echo "Image $LOCAL_TAG not found. Skipping..."
        continue
    fi

    echo "--- Pushing $service ---"
    echo "Tagging $LOCAL_TAG as $REMOTE_TAG"
    docker tag "$LOCAL_TAG" "$REMOTE_TAG"

    echo "Pushing $REMOTE_TAG"
    docker push "$REMOTE_TAG"
done

echo "All images built and pushed successfully!"
