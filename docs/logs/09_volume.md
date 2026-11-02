# 09. Docker 볼륨 — 생성 · 연결 · 컨테이너 삭제 전/후

원문 4장 9번. Docker가 관리하는 저장 공간 `mydata`를 만들고 컨테이너에 연결해 데이터를 쓴 뒤, **컨테이너를 지우고 새 컨테이너에 같은 볼륨을 연결해도 데이터가 남는지** 확인했다. 마지막에는 볼륨 없이 쓴 데이터가 어떻게 되는지 대조했다.

- 기록일 2026-11-02, 컨테이너는 `ubuntu:latest` + `sleep infinity`

## 개념 한 줄

컨테이너의 쓰기 공간은 컨테이너와 같이 사라진다. **볼륨은 컨테이너와 수명이 분리된 저장소**라서 컨테이너를 지워도 남고, 다음 컨테이너에 다시 붙일 수 있다(영속성).

## 명령 + 출력

```text
$ docker volume create mydata
mydata

$ docker volume ls
DRIVER    VOLUME NAME
local     mydata

$ docker run -d --name vol-test -v mydata:/data ubuntu sleep infinity
7a2f9a908fc2efc454399ebffc4a0389a6a0da8f45ad18451113a46fa708872c

### 삭제 전: 쓰기 + 확인
$ docker exec vol-test bash -lc "echo hi-from-vol-test > /data/hello.txt && cat /data/hello.txt"
hi-from-vol-test

$ docker inspect --format "{{json .Mounts}}" vol-test
[{"Type":"volume","Name":"mydata","Source":"/var/lib/docker/volumes/mydata/_data","Destination":"/data","Driver":"local","Mode":"z","RW":true,"Propagation":""}]

### 컨테이너 삭제
$ docker rm -f vol-test
vol-test
$ docker ps -a --filter name=vol-test
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
$ docker volume ls   # 볼륨은 남아 있음
DRIVER    VOLUME NAME
local     mydata

### 삭제 후: 새 컨테이너에 같은 볼륨 연결
$ docker run -d --name vol-test2 -v mydata:/data ubuntu sleep infinity
de05d5ded533603426a996c32d8048030c60657e7ffb1e234084915034fab0f0
$ docker exec vol-test2 bash -lc "cat /data/hello.txt"
hi-from-vol-test

### 대조: 볼륨 없이 쓴 데이터는 컨테이너 삭제와 함께 사라진다
$ docker run -d --name no-vol ubuntu sleep infinity
ad1f507d85998cafc94892c3def914b96f7533656cefaaa65dac0344ef1137ed
$ docker exec no-vol bash -lc "echo temp > /data-none.txt && cat /data-none.txt"
temp
$ docker rm -f no-vol && docker run --rm ubuntu bash -lc "cat /data-none.txt"
no-vol
cat: /data-none.txt: No such file or directory
```

## 결과 정리

| 시점 | 볼륨 `mydata` | `/data/hello.txt` |
|---|---|---|
| 컨테이너 `vol-test`에 연결, 파일 쓰기 | 있음 | `hi-from-vol-test` |
| `docker rm -f vol-test` (컨테이너 삭제) | **남아 있음** (`docker volume ls`) | — |
| 새 컨테이너 `vol-test2`에 같은 볼륨 연결 | 있음 | **`hi-from-vol-test` 그대로** |
| (대조) 볼륨 없이 쓴 `/data-none.txt` | 없음 | 컨테이너 삭제 뒤 `No such file or directory` |
