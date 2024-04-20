# Build

docker build -f .\Dockerfile -t dev .


# Run

docker-compose run --rm devserver

Creates a new container everytime. TODO: wrap this around a script or change the compose file (command?) to bash in if the container already exists. 