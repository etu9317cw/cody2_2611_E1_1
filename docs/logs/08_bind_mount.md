# 08. 바인드 마운트 — 호스트 파일 변경 전/후

원문 2장 7번 · 4장 7번 일부. **내 PC 폴더(`mount-demo/`)를 컨테이너 안 nginx 웹 루트에 그대로 연결**하고, 호스트에서 파일만 고쳤을 때 컨테이너를 다시 띄우지 않고도 바뀌는지 확인했다.

- 이미지는 `nginx:alpine` 그대로, 연결할 폴더만 다르다(`Dockerfile`의 `COPY`로 굽는 방식과 대비되는 "실행 시 연결" 방식).
- 기록일 2026-11-02

## 바인드 마운트 vs COPY

| | `COPY`(06번) | 바인드 마운트(이번) |
|---|---|---|
| 파일이 들어가는 때 | 이미지 **빌드할 때** 구워짐 | 컨테이너 **실행할 때** 연결 |
| 호스트에서 파일 수정 | 다시 빌드해야 반영 | **바로 반영** |
| 쓰임 | 배포 | 개발 중 코드 수정 |

## 명령 + 출력

```text
$ cat mount-demo/index.html   # 호스트(내 PC) 파일
<h1>bind mount: BEFORE (host file v1)</h1>

$ docker run -d -p 8082:80 --name bind-test -v "C:/co/1_cody2/2_mine/2611/E1_1/mount-demo:/usr/share/nginx/html:ro" nginx:alpine
Unable to find image 'nginx:alpine' locally
alpine: Pulling from library/nginx
Digest: sha256:785835ea65db4bba6f021acc0f3be91b0fef76a53fe41f8588c6698d2aed0606
Status: Downloaded newer image for nginx:alpine
c988a6700ccda0fe314cd1d1b8fc87dcc7d796efc776637414f4d95e4d8d0654

### 변경 전
$ curl -s http://localhost:8082
<h1>bind mount: BEFORE (host file v1)</h1>
$ docker exec bind-test cat /usr/share/nginx/html/index.html
<h1>bind mount: BEFORE (host file v1)</h1>

### 호스트에서 파일 수정 (컨테이너는 그대로 실행 중)
$ echo "<h1>bind mount: AFTER (host file edited, container not restarted)</h1>" > mount-demo/index.html

### 변경 후
$ curl -s http://localhost:8082
<h1>bind mount: AFTER (host file edited, container not restarted)</h1>
$ docker exec bind-test cat /usr/share/nginx/html/index.html
<h1>bind mount: AFTER (host file edited, container not restarted)</h1>

### 읽기 전용(:ro) 확인 — 컨테이너 안에서 쓰기 시도
$ docker exec bind-test sh -c "echo x > /usr/share/nginx/html/new.txt"
sh: can't create /usr/share/nginx/html/new.txt: Read-only file system

$ docker inspect --format "{{json .Mounts}}" bind-test
[{"Type":"bind","Source":"C:/co/1_cody2/2_mine/2611/E1_1/mount-demo","Destination":"/usr/share/nginx/html","Mode":"ro","RW":false,"Propagation":"rprivate"}]
```

결과: 호스트 파일을 고친 뒤 컨테이너를 건드리지 않았는데 `curl` 응답과 컨테이너 안 `cat` 결과가 모두 바뀌었다. `:ro`(읽기 전용)로 연결했으므로 컨테이너 안에서 쓰기는 `Read-only file system`으로 거절된다 — 호스트→컨테이너 방향만 열린다.

## PC 종속 경로 (원문 7장)

`docker inspect`의 `Source`가 `C:/co/1_cody2/2_mine/2611/E1_1/mount-demo`로 **이 PC의 Windows 경로**다. 다른 PC에서 재현하려면 저장소를 받은 폴더의 `mount-demo/`를 가리키면 된다.

```bash
# Linux/macOS/WSL
docker run -d -p 8082:80 -v "$PWD/mount-demo:/usr/share/nginx/html:ro" nginx:alpine
# Windows Git Bash (경로 자동 변환 끄기)
MSYS_NO_PATHCONV=1 docker run -d -p 8082:80 -v "C:/경로/E1_1/mount-demo:/usr/share/nginx/html:ro" nginx:alpine
```
