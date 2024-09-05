param(
    [string]$envFilePath = (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) ".env")
)

# Function to read the .env file and return a hashtable of key-value pairs
function Get-EnvVariables {
    param([string]$filePath)
    $envVars = @{}
    if (Test-Path $filePath) {
        Get-Content $filePath | ForEach-Object {
            if ($_ -match '^\s*([^#].*?)\s*=\s*(.*?)\s*$') {
                $envVars[$matches[1]] = $matches[2]
            }
        }
    } else {
        Write-Host "The .env file does not exist at path: $filePath"
        exit 1
    }
    return $envVars
}

# Load environment variables from the .env file
$envVars = Get-EnvVariables -filePath $envFilePath

# Ensure the required variables are present
if (-not $envVars.ContainsKey("CONTAINER_NAME")) {
    Write-Host "The .env file must contain CONTAINER_NAME."
    exit 1
}

$containerName = $envVars["CONTAINER_NAME"]
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$composeDir = Split-Path $scriptDir -Leaf

# Check if Docker is installed
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Docker is not installed or not in the system PATH."
    exit 1
}

# Check if the container is running
$container = docker ps --filter "name=$containerName" --format "{{.ID}}"

if (-not $container) {
    Write-Host "Container '$containerName' is not running. Starting the container using Docker Compose..."
    Push-Location $composeDir
    # Run docker-compose as a background process to the container will continue to run in the background
    # after exiting
    docker compose run -d --name $containerName devserver
    Pop-Location
    # Check again if the container started successfully
    $container = docker ps --filter "name=$containerName" --format "{{.ID}}"
    if (-not $container) {
        Write-Host "Failed to start the container. Please check the Docker Compose file."
        exit 1
    } else {
        Write-Host "Container '$containerName' started successfully."
    }
} else {
    Write-Host "Container '$containerName' is already running."
}

# Exec into the container with an interactive shell
docker exec -it $containerName /bin/bash