REPOS_NAME=xxxxx.dkr.ecr.ap-northeast-1.amazonaws.com
IMAGE_NAME=image-name
IMAGE_TAG=latest

build:
	DOCKER_BUILDKIT=1 docker build -t ${IMAGE_NAME} .

deploy: build
	aws ecr get-login-password | docker login --username AWS --password-stdin ${REPOS_NAME}
	docker tag ${IMAGE_NAME} ${REPOS_NAME}/${IMAGE_NAME}:${IMAGE_TAG}
	docker push ${REPOS_NAME}/${IMAGE_NAME}:${IMAGE_TAG}
