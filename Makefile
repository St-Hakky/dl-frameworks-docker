GPU?=0
DOCKER_FILE=Dockerfile
DOCKER=GPU=$(GPU) nvidia-docker
BACKEND=tensorflow
PYTHON_VERSION?=3.5
CUDA_VERSION?=8.0
CUDNN_VERSION?=6
UBUNTU_VERSION?=16.04
IMAGE_NAME_TAG=image-name-tag
SRC?=$(shell dirname `pwd`)

build:
	docker build -t $(IMAGE_NAME_TAG) --build-arg python_version=$(PYTHON_VERSION) --build-arg cuda_version=$(CUDA_VERSION) --build-arg cudnn_version=$(CUDNN_VERSION) --build-arg ubuntu_version=$(UBUNTU_VERSION) -f $(DOCKER_FILE) .

bash:
	$(DOCKER) run -it -v $(SRC):/src/workspace --env KERAS_BACKEND=$(BACKEND) $(IMAGE_NAME_TAG) bash

ipython:
	$(DOCKER) run -it -v $(SRC):/src/workspace --env KERAS_BACKEND=$(BACKEND) $(IMAGE_NAME_TAG) ipython

notebook:
	$(DOCKER) run -it -v $(SRC):/src/workspace --net=host --env KERAS_BACKEND=$(BACKEND) $(IMAGE_NAME_TAG)
