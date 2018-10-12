docker:
	docker build . -t foos_tournament

run:
	docker run -p 80:4567 foos_tournament
