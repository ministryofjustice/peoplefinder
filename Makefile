.PHONY: docker-shell

# run docker in the background and open an interactive shell on the app container
docker-shell: env dc

# build the application
build: env dc-build servers

# start docker and the app server
launch: docker-check upd servers

# destroy everything and start again
rebuild: dc-reset-bg servers

# a collection of server starters
servers: docker-check setup browser-sync server

env:
	@[ -f "./.env" ] || cp .env.example .env

dc:
	docker compose up -d app
	docker compose run --rm --entrypoint=/bin/sh app

dc-clean:
	rm -rf ./log* ./tmp* ./.local/.setup-complete
	docker compose down -v
	docker system prune -f
	clear

dc-reset: dc-clean
	docker compose up --build

dc-reset-bg: dc-clean
	docker compose up -d --build

dc-build: # no cleaning
	docker compose up -d --build

down:
	docker compose down

up: env
	docker compose up

upd: env
	docker compose up -d

setup:
	docker compose exec app /usr/bin/install.sh

spec-setup:
	@/usr/bin/install-spec.sh

browser-sync:
	docker compose exec -d app /usr/bin/browserSync.sh

server:
	docker compose exec app /usr/bin/app-server-start.sh

restart:
	docker-compose down
	make dc

# Remove ignored git files
clean:
	@if [ -d ".git" ]; then git clean -xdf --exclude ".env" --exclude ".idea"; fi

shell:
	docker compose exec --workdir /usr/src/app app /bin/sh

worker:
	clear
	@docker compose exec --workdir /usr/src/app app bundle exec rake jobs:work

specs: docker-check
	clear
	@chmod +x .local/bin/spec-intro.sh && .local/bin/spec-intro.sh
	@docker compose exec --workdir /usr/src/app spec bash

docker-check:
	@chmod +x ./.local/bin/check-docker-running.sh
	@./.local/bin/check-docker-running.sh

# Used exclusively to manage docker environment drop-in files; pre-commit only
# Can be removed when committed to source
hidden:
	rm -rf __MACOSX
	echo '' >> .gitignore
	echo '# TEMP - docker environment files' >> .gitignore
	echo '.local' >> .gitignore
	echo 'cts-dev*' >> .gitignore
	echo 'docker-*' >> .gitignore
	echo 'Makefile' >> .gitignore
	echo 'README.docker.md' >> .gitignore
