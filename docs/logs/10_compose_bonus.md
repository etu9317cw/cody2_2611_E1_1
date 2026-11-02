# 10. (보너스) Docker Compose 단일 서비스 · 운영 명령 · 환경 변수

원문 5장 보너스 1·3·4. `docker run`에 길게 붙이던 옵션(이미지·포트·환경 변수)을 `compose.yaml`로 적어 두면 **실행 설정이 파일로 남아** 같은 명령 한 줄(`docker compose up -d`)로 재현된다. 환경 변수로 호스트 포트와 모드를 바꿔 봤다. (멀티 컨테이너·SSH 키는 하지 않았다.)

- 기록일 2026-11-02, Docker Compose v5.6.1

## compose.yaml

```yaml
services:
  web:
    build: .
    image: e1-1-web:compose
    container_name: e1-1-compose
    ports:
      - "${WEB_PORT:-8090}:80"
    environment:
      APP_ENV: ${APP_ENV:-dev}
    restart: unless-stopped
```

`${변수:-기본값}`: 환경 변수가 없으면 기본값(포트 8090, 모드 dev)을 쓴다. **설정은 파일 밖에서, 코드는 그대로** 두는 방식이다.

## 명령 + 출력 (up · ps · logs · exec · down)

```text
$ docker compose version
Docker Compose version v5.6.1

### 기본값으로 실행
$ docker compose up -d --build
 Network e1_1_default Creating 
 Network e1_1_default Creating 
 Network e1_1_default Created 
 Network e1_1_default Created 
 Container e1-1-compose Creating 
 Container e1-1-compose Created 
 Container e1-1-compose Starting 
 Container e1-1-compose Started 

$ docker compose ps
NAME           IMAGE              COMMAND                   SERVICE   CREATED          STATUS                    PORTS
e1-1-compose   e1-1-web:compose   "/docker-entrypoint.…"   web       11 seconds ago   Up 10 seconds (healthy)   0.0.0.0:8090->80/tcp, [::]:8090->80/tcp

$ curl -s http://localhost:8090 | grep h1
    h1 { color: #0b6e4f; }
  <h1>Hello from my custom nginx image</h1>
$ docker compose exec web printenv APP_ENV
dev

$ docker compose logs --tail 5 web
e1-1-compose  | 2026/11/02 10:57:38 [notice] 1#1: start worker process 43
e1-1-compose  | 2026/11/02 10:57:38 [notice] 1#1: start worker process 44
e1-1-compose  | 2026/11/02 10:57:38 [notice] 1#1: start worker process 45
e1-1-compose  | ::1 - - [02/Nov/2026:10:57:41 +0000] "GET / HTTP/1.1" 200 544 "-" "Wget" "-"
e1-1-compose  | 172.18.0.1 - - [02/Nov/2026:10:57:49 +0000] "GET / HTTP/1.1" 200 544 "-" "curl/8.21.0" "-"

### 환경 변수로 포트·모드 바꾸기
$ docker compose down
 Container e1-1-compose Stopping 
 Container e1-1-compose Stopped 
 Container e1-1-compose Removing 
 Container e1-1-compose Removed 
 Network e1_1_default Removing 
 Network e1_1_default Removed 
$ WEB_PORT=9000 APP_ENV=prod docker compose up -d
 Container e1-1-compose Created 
 Container e1-1-compose Starting 
 Container e1-1-compose Started 
$ docker compose ps
NAME           IMAGE              COMMAND                   SERVICE   CREATED         STATUS                   PORTS
e1-1-compose   e1-1-web:compose   "/docker-entrypoint.…"   web       9 seconds ago   Up 8 seconds (healthy)   0.0.0.0:9000->80/tcp, [::]:9000->80/tcp
$ curl -sI http://localhost:9000 | head -1
HTTP/1.1 200 OK
$ docker compose exec web printenv APP_ENV
prod

$ docker compose down
 Container e1-1-compose Stopping 
 Container e1-1-compose Stopped 
 Container e1-1-compose Removing 
 Container e1-1-compose Removed 
 Network e1_1_default Removing 
 Network e1_1_default Removed 
$ docker compose ps
NAME      IMAGE     COMMAND   SERVICE   CREATED   STATUS    PORTS
```

## 결과

| 실행 | 호스트 포트 | `APP_ENV` |
|---|---|---|
| `docker compose up -d` (기본값) | 8090 | `dev` |
| `WEB_PORT=9000 APP_ENV=prod docker compose up -d` | 9000 | `prod` |

운영 명령 4개(`up` 실행 · `ps` 상태 · `logs` 로그 · `down` 종료)를 모두 사용했고, `down` 뒤 `ps`가 비어 있음을 확인했다.
