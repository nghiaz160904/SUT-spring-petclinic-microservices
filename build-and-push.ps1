# ===============================
# Config
$DOCKER_USER = "nghiax1609"
$DOCKER_REPO_PREFIX = "$DOCKER_USER/spring-petclinic"
$services = @(
    "customers-service",
    "vets-service",
    "visits-service",
    "api-gateway",
    "config-server",
    "discovery-server",
    "admin-server"
)
# ===============================

# Write-Host "=== Step 1: Build Docker images with Maven ==="
./mvnw clean install -P buildDocker -DskipTests

Write-Host "=== Step 2: Tag and Push images to Docker Hub ==="

foreach ($service in $services) {
    if ([string]::IsNullOrWhiteSpace($service)) {
        Write-Host " Skipping empty service"
        continue
    }

    $LOCAL_TAG = "springcommunity/spring-petclinic-$($service):latest"
    $REMOTE_TAG = "$DOCKER_REPO_PREFIX-$($service):latest"


    # Kiểm tra image có tồn tại chưa
    $exists = docker images -q $LOCAL_TAG
    if (-not $exists) {
        Write-Host "Image $LOCAL_TAG not found. Skipping..."
        continue
    }

    Write-Host "--- Pushing $service ---"
    Write-Host "Tagging $LOCAL_TAG as $REMOTE_TAG"
    docker tag $LOCAL_TAG $REMOTE_TAG

    Write-Host "Pushing $REMOTE_TAG"
    docker push $REMOTE_TAG
}

Write-Host "All images built and pushed successfully!"
