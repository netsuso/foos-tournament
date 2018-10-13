docker_tag = foos-tournament
external_port = 80

docker:
	docker build . -t $(docker_tag)

run:
	docker run -p $(external_port):4567 $(docker_tag)

run_localdb:
	docker run -u $(shell id -u):$(shell id -g) -p $(external_port):4567 -v $(PWD)/foos.db:/usr/src/app/foos.db $(docker_tag)
