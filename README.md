# swupdate-builder as docker container

https://hub.docker.com/r/jneuhauser/swupdate-builder/

### build container
docker build . -t jneuhauser/swupdate-builder:jessie

### build container with the same proxy as from host
docker build --build-arg HTTP_PROXY --build-arg HTTPS_PROXY --build-arg http_proxy --build-arg https_proxy . -t jneuhauser/swupdate-builder:jessie

### run container
docker run -i -t -v /home/devel/dev/swupdate:/swupdate jneuhauser/swupdate-builder:jessie

### run container with the same proxy as from host
docker run -e HTTP_PROXY -e HTTPS_PROXY -e http_proxy -e https_proxy -i -t -v /home/devel/dev/swupdate:/swupdate jneuhauser/swupdate-builder:jessie
