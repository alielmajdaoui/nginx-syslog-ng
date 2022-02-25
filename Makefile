NGINX_CONTAINER_NAME := nginx-syslog-ng
SYSLOG_NG_CONTAINER_NAME := syslog-ng-server

# Available options: tcp, udp
ADDRESS_PROTOCOL := tcp
# Available options: 601 for tcp, 514 for udp
ADDRESS_PORT := 601

# Netcat command requires the '-u' flag when communicating to a UDP server.
ifeq ($(ADDRESS_PROTOCOL), udp)
    NETCAT_FLAGS=-u
else
    NETCAT_FLAGS=
endif

up:
	docker build -t alielm/syslog-ng-alpine . ; \
	docker run \
		-d \
		--name $(SYSLOG_NG_CONTAINER_NAME) \
		-p 127.0.0.1:601:601/tcp \
		-p 127.0.0.1:514:514/udp \
		alielm/syslog-ng-alpine; \
	sleep 2; \
	docker run \
		-d \
		--name $(NGINX_CONTAINER_NAME) \
		-p '8080:80' \
		--log-driver syslog \
		--log-opt syslog-address=$(ADDRESS_PROTOCOL)://127.0.0.1:$(ADDRESS_PORT) \
		nginx:alpine

down:
	docker stop $(SYSLOG_NG_CONTAINER_NAME) 2> /dev/null; \
	docker stop $(NGINX_CONTAINER_NAME) 2> /dev/null; \
	docker rm $(SYSLOG_NG_CONTAINER_NAME) 2> /dev/null; \
	docker rm $(NGINX_CONTAINER_NAME) 2> /dev/null;

shell-syslog:
	docker exec -it $(SYSLOG_NG_CONTAINER_NAME) sh

tail-syslog:
	docker exec -it $(SYSLOG_NG_CONTAINER_NAME) tail -f /var/log/messages

shell-nginx:
	docker exec -it $(NGINX_CONTAINER_NAME) sh

syslog-logs:
	docker logs $(SYSLOG_NG_CONTAINER_NAME)

nginx-logs:
	docker logs $(NGINX_CONTAINER_NAME)

test-log:
	echo -n "this log was sent from your Docker host :-D" \
	    | nc $(NETCAT_FLAGS) -w1 localhost $(ADDRESS_PORT)

test-log-via-container:
	docker run -d --rm \
		--log-driver syslog \
		--log-opt syslog-address=$(ADDRESS_PROTOCOL)://127.0.0.1:$(ADDRESS_PORT) \
		alpine echo "this log was sent by a docker container ;-)"

test-log-with-logger:
	docker exec -it $(SYSLOG_NG_CONTAINER_NAME) \
		logger --port $(ADDRESS_PORT) --$(ADDRESS_PROTOCOL) --server 127.0.0.1 \
		"hey from logger!"