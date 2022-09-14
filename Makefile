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
	@[ -f "./.env.local" ] || cp .env.example .env.local

dc:
	docker compose --env-file=.env.local up -d app
	docker compose --env-file=.env.local run --rm --entrypoint=/bin/sh app

dc-clean:
	rm -rf ./log* ./tmp* ./.local/.setup-complete
	docker compose --env-file=.env.local down -v
	docker system prune -f
	clear

dc-reset: dc-clean
	docker compose --env-file=.env.local up --build

dc-reset-bg: dc-clean
	docker compose --env-file=.env.local up -d --build

dc-build: # no cleaning
	docker compose --env-file=.env.local up -d --build

down:
	docker compose --env-file=.env.local down

up: env
	docker compose --env-file=.env.local up

upd: env
	docker compose --env-file=.env.local --env-file=.env.local up -d

setup:
	docker compose --env-file=.env.local exec app /usr/bin/install.sh

spec-setup:
	@/usr/bin/install-spec.sh

browser-sync:
	docker compose --env-file=.env.local exec -d app /usr/bin/browserSync.sh

server:
	docker compose --env-file=.env.local exec app /usr/bin/app-server-start.sh

restart:
	docker-compose --env-file=.env.local down
	make dc

# Remove ignored git files
clean:
	@if [ -d ".git" ]; then git clean -xdf --exclude ".env" --exclude ".idea"; fi

shell:
	docker compose --env-file=.env.local exec --workdir /usr/src/app app /bin/sh

worker:
	clear
	@docker compose --env-file=.env.local exec --workdir /usr/src/app app bundle exec rake jobs:work

specs: docker-check
	clear
	@chmod +x .local/bin/spec-intro.sh && .local/bin/spec-intro.sh
	@docker compose --env-file=.env.local exec --workdir /usr/src/app spec bash

docker-check:
	@chmod +x ./.local/bin/check-docker-running.sh
	@./.local/bin/check-docker-running.sh
