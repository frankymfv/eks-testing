build-auth-app-image:
	docker build -t hbc08/k8s-auth-app:latest ./auth-app

push-auth-app-image:
	docker push hbc08/k8s-auth-app:latest

build-user-app-image:
	docker build -t hbc08/k8s-user-app ./user-app
push-user-app-image:
	docker push hbc08/k8s-user-app

build-helloworld-image:
	docker build -t hbc08/k8s-helloworld ./helloworld
push-helloworld-image:
	docker push hbc08/k8s-helloworld




build-all: build-auth-app-image build-user-app-image build-helloworld-image

build-and-push-all: build-all push-auth-app-image push-user-app-image push-helloworld-image
push-all: push-auth-app-image push-user-app-image push-helloworld-image

build-and-push-auth-app-image:
	docker build -t ./auth_app .
	docker tag auth_app $(DOCKER_USERNAME)/auth_app
	docker push $(DOCKER_USERNAME)/auth_app


docker-compose-up:
	docker-compose up -d