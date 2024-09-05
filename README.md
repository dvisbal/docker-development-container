# Build

docker build -f .\Dockerfile -t dev --build-arg USER_NAME=boulder .

or

docker-compose build


# Run

docker-compose run --rm devserver
docker exec -it CONTAINER_NAME /bin/bash

or on windows

.\rundevshell.ps1