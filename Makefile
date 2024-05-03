DOCKER_COMPOSE_COMMAND = docker-compose -p wms -f build/docker-compose.yml
TEST_LOCAL_DOCKER_COMPOSE_COMMAND = docker-compose -p wms_test -f build/docker-compose.test.local.yml

.PHONY: makemigrations
makemigrations:
	$(DOCKER_COMPOSE_COMMAND) exec api ./manage.py makemigrations

.PHONY: makemigrations_empty
makemigrations_empty:
	$(DOCKER_COMPOSE_COMMAND) exec api ./manage.py makemigrations --empty

.PHONY: makemigrations_merge
makemigrations_merge:
	$(DOCKER_COMPOSE_COMMAND) exec api ./manage.py makemigrations --merge

.PHONY: migrate
migrate:
	$(DOCKER_COMPOSE_COMMAND) exec api ./manage.py migrate

.PHONY: celery_purge
celery_purge:
	$(DOCKER_COMPOSE_COMMAND) exec api celery -A wms_project purge -f

.PHONY: clean
clean:
	$(DOCKER_COMPOSE_COMMAND) down

.PHONY: shell
shell:
	$(DOCKER_COMPOSE_COMMAND) exec api ./manage.py shell

.PHONY: bash
bash:
	$(DOCKER_COMPOSE_COMMAND) exec api bash

.PHONY: up
up:
	$(DOCKER_COMPOSE_COMMAND) up -d

.PHONY: stop
stop:
	$(DOCKER_COMPOSE_COMMAND) stop

.PHONY: logs
logs:
	$(DOCKER_COMPOSE_COMMAND) logs -f --tail=10

.PHONY: restart
restart:
	$(DOCKER_COMPOSE_COMMAND) restart $(APP)

.PHONY: command_script
command_script:
	$(DOCKER_COMPOSE_COMMAND) exec api ./manage.py $(SCRIPT)

.PHONY: test
test:
	./test.sh -t local $(ARGS)

.PHONY: test_clean
test_clean:
	$(TEST_LOCAL_DOCKER_COMPOSE_COMMAND) down

.PHONY: test_up
test_up:
	$(TEST_LOCAL_DOCKER_COMPOSE_COMMAND) up -d $(APP)

.PHONY: test_bash
test_bash:
	$(TEST_LOCAL_DOCKER_COMPOSE_COMMAND) exec api bash

.PHONY: psql
psql:
	$(DOCKER_COMPOSE_COMMAND) exec postgres_db psql -U postgres wms

.PHONY: build
build:
	./build.sh -i api -b dev -v "1"
	./build.sh -i celery -b dev -v "1"

.PHONY: create_network
create_network:
	docker network create wms_shared