net.run:
	sudo docker network create -d bridge \
		--subnet=10.0.7.0/24 \
	  	mynet-a;
	sudo docker network create -d bridge \
		--subnet=10.0.8.0/24 \
	  	mynet-b
	sudo docker network create -d bridge \
		--subnet=10.0.9.0/24 \
	  	mynet-c

net.rm:
	sudo docker network rm mynet-a
	sudo docker network rm mynet-b
	sudo docker network rm mynet-c

nginx.build:
	sudo docker build -t nginx .

nginx.run:
	sudo docker run -d \
		--name nginx-tcpproxy1 \
		-v $(shell pwd)/tcpproxy1.conf:/etc/nginx/nginx.conf:ro \
		-p 12345:12345 \
		--net mynet-a \
		--ip 10.0.7.10 \
		nginx;
	sudo docker network connect mynet-c nginx-tcpproxy1
	sudo docker run -d \
		--name nginx-tcpproxy2 \
		-v $(shell pwd)/tcpproxy2.conf:/etc/nginx/nginx.conf:ro \
		-p 12346:12346 \
		--net mynet-b \
		--ip 10.0.8.10 \
		nginx;
	sudo docker network connect mynet-c nginx-tcpproxy2
	sudo docker run -d \
		--name nginx-reverseproxy1 \
		-v $(shell pwd)/reverseproxy.conf:/etc/nginx/nginx.conf:ro \
		-p 8080:8080 \
		--net mynet-c \
		--ip 10.0.9.10 \
		nginx;
	sudo docker run -d \
		--name nginx-app1 \
		-v $(shell pwd)/app.conf:/etc/nginx/nginx.conf:ro \
		--expose 9000 \
		--net mynet-c \
		--ip 10.0.9.11 \
		nginx;
	sudo docker run -d \
		--name nginx-app2 \
		-v $(shell pwd)/app.conf:/etc/nginx/nginx.conf:ro \
		--expose 9000 \
		--net mynet-c \
		--ip 10.0.9.12 \
		nginx

nginx.check:
	sudo docker ps \
		| grep nginx \
		| awk '{print $$1}' \
		| xargs -I{} sudo docker inspect --format='{{json .NetworkSettings.Networks}}' {} \
		| jq .

nginx.log:
	sudo docker ps \
		| grep nginx \
		| awk '{print $$1}' \
		| xargs -I{} sudo docker logs {}

nginx.rm:
	sudo docker ps -a | grep nginx | awk '{print $$1}' | xargs -I{} sudo docker rm -f {}
