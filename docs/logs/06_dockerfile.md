# 06. 커스텀 이미지 — Dockerfile 작성·빌드·실행 로그

원문 4장 7번. **(A)안: 웹 서버 베이스 이미지 + 정적 콘텐츠 교체**를 골랐다.

- 실행 위치: Git Bash (Windows 11, Docker Desktop 4.97.0 / Docker 29.9.2, WSL2 백엔드), 기록일 2026-11-02
- 파일: `Dockerfile`, `site/index.html` (저장소 루트)

## 베이스 이미지 선택

| 항목 | 내용 |
|---|---|
| 선택한 기존 이미지 | `nginx:alpine` (Docker Hub 공식 이미지) |
| 선택 이유 | 정적 페이지만 보여 주면 되므로 웹 서버가 이미 들어 있는 공식 이미지에 내 파일만 얹는 편이 가장 짧고 재현하기 쉽다. alpine 판은 이미지가 작고(내려받기 26MB 안팎) 빌드가 빠르다. |
| 선택하지 않은 방식 | (B) `ubuntu` 베이스에 패키지·사용자를 직접 추가 — 웹 서버를 직접 설치해야 해서 과제 초점(Dockerfile·포트·볼륨)보다 설치에 시간이 든다. |

## Dockerfile (직접 작성)

```dockerfile
FROM nginx:alpine

LABEL org.opencontainers.image.title="e1-1-web" \
      org.opencontainers.image.description="E1_1 practice: nginx:alpine + static site" \
      org.opencontainers.image.authors="etu9317cw"

ENV APP_ENV=dev

COPY site/ /usr/share/nginx/html/

HEALTHCHECK --interval=10s --timeout=3s --start-period=3s --retries=3 \
  CMD wget -qO- http://localhost/ > /dev/null || exit 1
```

## 커스텀 포인트와 목적

| 포인트 | 목적 | 확인한 방법 |
|---|---|---|
| `COPY site/ /usr/share/nginx/html/` | nginx 기본 환영 페이지를 **내 정적 페이지로 교체**한다. 이미지에 콘텐츠가 구워지므로 어느 PC에서 실행해도 같은 화면이 나온다. | `curl` 응답이 내 페이지(`Hello from my custom nginx image`) |
| `LABEL` | 이미지가 무엇인지(이름·설명·작성자) **메타데이터로 남긴다**. `docker inspect`로 누구나 확인할 수 있다. | `docker inspect` 의 `Labels` |
| `ENV APP_ENV=dev` | 실행 모드를 **코드 밖 설정값**으로 둔다. 이미지는 그대로 두고 `-e APP_ENV=prod`로 덮어쓸 수 있다(10번 로그에서 실제로 바꿈). | 컨테이너 안 `printenv APP_ENV` |
| `HEALTHCHECK` | "프로세스가 떠 있음"이 아니라 **"실제로 응답함"**을 Docker가 주기적으로 확인한다. `docker ps`에 `(healthy)`로 표시된다. | `docker ps`, `docker inspect` 의 `Health.Status` |

## 빌드 · 실행 · 확인 (명령 + 출력)

```text
$ docker build --progress=plain -t e1-1-web:1.0 .   # 첫 빌드는 베이스 이미지 내려받기 포함, 아래는 --no-cache 재빌드 출력
#0 building with "desktop-linux" instance using docker driver
#1 transferring dockerfile: 858B done
#3 transferring context: 2B done
#4 transferring context: 61B done
#5 [1/2] FROM docker.io/library/nginx:alpine@sha256:785835ea65db4bba6f021acc0f3be91b0fef76a53fe41f8588c6698d2aed0606
#5 resolve docker.io/library/nginx:alpine@sha256:785835ea65db4bba6f021acc0f3be91b0fef76a53fe41f8588c6698d2aed0606 0.0s done
#5 CACHED
#6 [2/2] COPY site/ /usr/share/nginx/html/
#7 exporting to image
#7 exporting layers 0.1s done
#7 exporting manifest sha256:52af15e08f0297366561f42564a186ca5bfd13f87f6743a950771a6b90703e0a 0.0s done
#7 exporting config sha256:79c9fbf58c39d7b82b9312a3d47cf16eb41aea4d7bc86c6925a75026a6cdd82a 0.0s done
#7 exporting attestation manifest sha256:16e22e3d6547e2c1aa0ddd80d83f380610774054bcf27704ba86894ab160e4c1 0.0s done
#7 exporting manifest list sha256:174cf7291265c1e0f870894ac2121d8af4b5d69de079c5968b0c46310677333b 0.0s done
#7 naming to docker.io/library/e1-1-web:1.0 done
#7 unpacking to docker.io/library/e1-1-web:1.0 done
#7 DONE 0.2s

$ docker images e1-1-web
IMAGE          ID             DISK USAGE   CONTENT SIZE   EXTRA
e1-1-web:1.0   7c460ef9060a       93.6MB         26.3MB        

$ docker exec web-8080 printenv APP_ENV
dev

$ docker inspect --format "{{json .Config.Labels}}" e1-1-web:1.0
{"maintainer":"NGINX Docker Maintainers <docker-maint@nginx.com>","org.opencontainers.image.authors":"etu9317cw","org.opencontainers.image.description":"E1_1 practice: nginx:alpine + static site","org.opencontainers.image.title":"e1-1-web"}

$ docker inspect --format "{{.State.Health.Status}}" web-8080
healthy

```

결과: 빌드 성공, `e1-1-web:1.0`(디스크 93.6MB / 내려받는 크기 26.3MB). 컨테이너 안 `APP_ENV`는 `dev`, 라벨 3개가 내가 쓴 값으로 들어갔고(`maintainer`는 베이스 이미지에서 물려받음), 헬스체크 상태는 `healthy`.
