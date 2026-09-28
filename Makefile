build:
	docker build -t win32-srcds .

run: build
	docker run --rm -it -p 27015:27015/udp -p 27015:27015/tcp -p 8080:8080 win32-srcds
