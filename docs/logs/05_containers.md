# 05. 컨테이너 실행 실습 로그 (hello-world · ubuntu · attach vs exec)

`hello-world` 실행, `ubuntu` 컨테이너 안에서 `ls`·`echo` 실행, 그리고 컨테이너를 **계속 켜 두는 방식**(`sleep infinity`)에서 `docker exec`와 `docker attach`가 어떻게 다른지 관찰했다.

- 실행 위치: Git Bash, 기록일 2026-11-02
- 자동 기록 환경에는 키보드 터미널(TTY)이 없어서 `-it` 대신 `-i`로 명령을 파이프로 넣었다. 사람 손으로 `docker run -it --rm ubuntu bash`를 치는 것과 같은 일이다(TTY가 없을 뿐이다).

## A. hello-world

```text
$ docker run --rm hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
4f55086f7dd0: Pulling fs layer
4f55086f7dd0: Download complete
4f55086f7dd0: Pull complete
d5e71e642bf5: Download complete
Digest: sha256:c567b231f65614688711a75f31518a064258a51d442117a3e771a3a8fdba78ef
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/


```

## B. ubuntu 컨테이너 안에서 명령 실행

```text
$ docker run --rm ubuntu ls /
bin
boot
dev
etc
home
lib
lib64
media
mnt
opt
proc
root
run
sbin
srv
sys
tmp
usr
var

$ docker run --rm ubuntu echo "hello from ubuntu container"
hello from ubuntu container

$ printf "cat /etc/os-release | head -1\nhostname\nls /home\necho inside-bash\nexit\n" | docker run --rm -i ubuntu bash
PRETTY_NAME="Ubuntu 26.04.1 LTS"
2553027abd95
ubuntu
inside-bash

```

## C. exec: 켜 둔 컨테이너 안으로 들어갔다 나와도 컨테이너는 계속 산다

```text
$ docker run -d --name u1 ubuntu sleep infinity
887fa61179789222ee4e21c6b5aa6807862d682c3f8ab571d979c30f2f85413e

$ docker ps --filter name=u1
CONTAINER ID   IMAGE     COMMAND            CREATED                  STATUS                  PORTS     NAMES
887fa6117978   ubuntu    "sleep infinity"   Less than a second ago   Up Less than a second             u1

$ docker exec u1 ls /
bin
boot
dev
etc
home
lib
lib64
media
mnt
opt
proc
root
run
sbin
srv
sys
tmp
usr
var

$ printf "echo exec-shell-start\nexit\n" | docker exec -i u1 bash
exec-shell-start

$ docker ps --filter name=u1
CONTAINER ID   IMAGE     COMMAND            CREATED                  STATUS                  PORTS     NAMES
887fa6117978   ubuntu    "sleep infinity"   Less than a second ago   Up Less than a second             u1

```

## D. attach: 컨테이너의 메인 프로세스(PID 1)에 붙었다가 그 프로세스를 끝내면 컨테이너도 끝난다

```text
$ docker run -d -i --name u1 ubuntu sleep infinity
e7f8525b3aaa9187dcbb09860851e9616d2a7995791be8a2d3774f57e2c681dc

$ docker run -d -i --name u2 ubuntu bash
36cae64c73c6b7db3fdcdb151aca36e02b50fdeac2abeed33e0cffb121fe1655

$ docker ps
CONTAINER ID   IMAGE     COMMAND            CREATED        STATUS                  PORTS     NAMES
36cae64c73c6   ubuntu    "bash"             1 second ago   Up Less than a second             u2
e7f8525b3aaa   ubuntu    "sleep infinity"   1 second ago   Up Less than a second             u1

$ (printf "echo attach-shell-start\n"; sleep 1; printf "exit\n") | docker attach u2
attach-shell-start

$ sleep 1; docker ps -a
CONTAINER ID   IMAGE     COMMAND            CREATED         STATUS                    PORTS     NAMES
36cae64c73c6   ubuntu    "bash"             3 seconds ago   Exited (0) 1 second ago             u2
e7f8525b3aaa   ubuntu    "sleep infinity"   3 seconds ago   Up 2 seconds                        u1

$ docker rm -f u1 u2
u1
u2

$ docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

```

## E. 관찰 정리 (attach vs exec)

| | `docker exec <컨테이너> bash` | `docker attach <컨테이너>` |
|---|---|---|
| 무엇을 하나 | 이미 켜진 컨테이너 안에 **새 프로세스**를 하나 더 띄운다 | 컨테이너의 **원래 메인 프로세스(PID 1)** 입출력에 붙는다 |
| 쉘에서 `exit` 하면 | 그 새 프로세스만 끝난다. 컨테이너는 **계속 Up** (C절에서 확인) | PID 1이 끝나므로 컨테이너도 **Exited (0)** (D절에서 확인) |
| 언제 쓰나 | 켜 둔 서버 안을 들여다보고 나올 때 | 메인 프로세스의 출력을 그대로 보고 싶을 때 |
| 위험 | 거의 없음 | 실수로 Ctrl+C·`exit`를 하면 컨테이너가 같이 끝날 수 있음 (떼어 내기는 Ctrl+P, Ctrl+Q) |

- `docker run --rm ubuntu ...`는 명령이 끝나면 컨테이너도 끝나고(`--rm`이라 자동 삭제), `sleep infinity`처럼 끝나지 않는 메인 프로세스를 주면 `-d`로 계속 켜 둘 수 있다. 그래서 C절은 `sleep infinity`, D절은 쉘(`bash`)을 PID 1로 썼다.
- 컨테이너는 "프로세스 하나가 살아 있는 동안만 살아 있는 격리된 환경"이라고 정리할 수 있다.
