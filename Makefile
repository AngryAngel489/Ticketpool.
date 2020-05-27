# build the docker images for any environment
build:
	docker build --tag attendize_base --target base .
	docker build --tag attendize_worker --target worker --cache-from attendize_base:latest .
	docker build --tag attendize_web --target web --cache-from attendize_worker:latest .

# set up docker images and run containers for local development with docker-compose only
setup: build
	docker-compose up -d
	docker-compose exec web ./scripts/setup
	open https://localhost:8081/install
	docker-compose exec web tail -f /var/log/nginx/access.log /var/log/nginx/error.log /var/log/php-fpm.log storage/logs/*
