which docker >/dev/null 2>&1
if [[ $? -ne 0 ]]; then 
	curl -sSL https://get.docker.com/ | sh
fi

gpasswd -a vagrant docker
docker info

# pull us some images to play with
docker pull busybox:latest

