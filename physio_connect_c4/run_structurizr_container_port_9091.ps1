docker pull structurizr/lite:latest
docker run -it --rm -p 9091:8080 -v ${PWD}:/usr/local/structurizr structurizr/lite:latest
