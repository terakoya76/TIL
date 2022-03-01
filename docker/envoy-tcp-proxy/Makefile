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

app.build:
	sudo docker build -t nginx -f Dockerfile.nginx .
	sudo docker build -t envoy -f Dockerfile.envoy .

app.run:
	sudo docker run -d \
		--name envoy-tcpproxy1 \
		-v $(shell pwd)/tcpproxy1.yaml:/etc/envoy/envoy.yaml \
		-p 12345:12345 \
		--net mynet-a \
		--ip 10.0.7.10 \
		envoy;
	sudo docker network connect mynet-c envoy-tcpproxy1
	sudo docker run -d \
		--name envoy-tcpproxy2 \
		-v $(shell pwd)/tcpproxy2.yaml:/etc/envoy/envoy.yaml \
		-p 12346:12346 \
		--net mynet-b \
		--ip 10.0.8.10 \
		envoy;
	sudo docker network connect mynet-c envoy-tcpproxy2
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

app.check:
	sudo docker ps \
		| awk '{print $$1}' \
		| xargs -I{} sudo docker inspect --format='{{json .NetworkSettings.Networks}}' {} \
		| jq .

app.log:
	sudo docker ps \
		| awk '{print $$1}' \
		| xargs -I{} sudo docker logs {}

app.rm:
	sudo docker ps -a | awk 'NR>1 {print $$1}' | xargs -I{} sudo docker rm -f {}
