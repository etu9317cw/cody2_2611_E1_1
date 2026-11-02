# 04. Docker 운영 명령 로그 (이미지 · 컨테이너 · 로그 · 리소스)

이미지 받기·목록(`docker pull`, `docker images`), 컨테이너 실행·중지·시작·삭제(`docker run -d`, `ps`, `ps -a`, `stop`, `start`, `rm`), 로그(`docker logs`), 리소스(`docker stats --no-stream`)를 한 흐름으로 실행했다. 컨테이너 `ops1`은 1초마다 한 줄씩 찍는 `alpine` 컨테이너다.

- 실행 위치: Git Bash, 기록일 2026-11-02

```text
$ docker pull alpine:3.20
3.20: Pulling from library/alpine
25f1d6b1951a: Pulling fs layer
25f1d6b1951a: Download complete
d4050d56ebf2: Download complete
25f1d6b1951a: Pull complete
3a030ca3f633: Download complete
Digest: sha256:d9e853e87e55526f6b2917df91a2115c36dd7c696a35be12163d44e6e2a4b6bc
Status: Downloaded newer image for alpine:3.20
docker.io/library/alpine:3.20

$ docker images
IMAGE              ID             DISK USAGE   CONTENT SIZE   EXTRA
alpine:3.20        d9e853e87e55       12.2MB         3.71MB        
python:3.12-slim   aa943ce41142        180MB         45.5MB        
python:3.8-slim    1d52838af602        191MB         49.6MB        
ubuntu:latest      6a06111c3b0a        163MB         45.9MB        

$ docker run -d --name ops1 alpine:3.20 sh -c "i=0; while true; do i=\$((i+1)); echo tick \$i; sleep 1; done"
c8c5d62baadae7a130dd5d914de2590f8d3c43b18be8223a52c4ba52a3c0024b

$ sleep 4; docker ps
CONTAINER ID   IMAGE         COMMAND                   CREATED         STATUS         PORTS     NAMES
c8c5d62baada   alpine:3.20   "sh -c 'i=0; while t…"   4 seconds ago   Up 4 seconds             ops1

$ docker logs ops1
tick 1
tick 2
tick 3
tick 4
tick 5

$ docker logs --tail 2 ops1
tick 4
tick 5

$ docker stats --no-stream ops1
CONTAINER ID   NAME      CPU %     MEM USAGE / LIMIT     MEM %     NET I/O         BLOCK I/O   PIDS
c8c5d62baada   ops1      0.16%     1.789MiB / 15.18GiB   0.01%     1.17kB / 126B   0B / 0B     2

$ docker stop ops1
ops1

$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

$ docker ps -a
CONTAINER ID   IMAGE         COMMAND                   CREATED         STATUS                                PORTS     NAMES
c8c5d62baada   alpine:3.20   "sh -c 'i=0; while t…"   9 seconds ago   Exited (137) Less than a second ago             ops1

$ docker start ops1
ops1

$ sleep 2; docker ps
CONTAINER ID   IMAGE         COMMAND                   CREATED          STATUS         PORTS     NAMES
c8c5d62baada   alpine:3.20   "sh -c 'i=0; while t…"   12 seconds ago   Up 2 seconds             ops1

$ docker stop ops1 && docker rm ops1
ops1
ops1

$ docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

$ docker images
IMAGE              ID             DISK USAGE   CONTENT SIZE   EXTRA
alpine:3.20        d9e853e87e55       12.2MB         3.71MB        
python:3.12-slim   aa943ce41142        180MB         45.5MB        
python:3.8-slim    1d52838af602        191MB         49.6MB        
ubuntu:latest      6a06111c3b0a        163MB         45.9MB        

```
