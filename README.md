# E1_1 — 내 컴퓨터에 개발자용 '작업실' 꾸미기

터미널 · Docker · Git/GitHub를 직접 세팅하고, 실행 결과(로그·접속·데이터 유지)로 검증한 기록입니다. 모든 명령과 출력은 `docs/logs/`에 있고, 이 README는 그 목차 겸 요약입니다.

## 1) 프로젝트 개요

- **목표**: "내 컴퓨터에서만 돌아가는" 문제를 줄이고, 누구나 같은 방식으로 실행·검증할 수 있는 환경을 만든다.
- **한 일**: 터미널로 폴더·권한 정리 → Docker 설치·점검 → 컨테이너 실행/관리 → `nginx:alpine` 위에 정적 페이지를 얹은 커스텀 이미지(Dockerfile) → 포트 매핑 2회 → 바인드 마운트 · 볼륨 영속성 검증 → Git 설정 · GitHub 연동 → (보너스) Compose · 환경 변수.
- **구조**

```text
.
├─ README.md            이 문서
├─ Dockerfile           커스텀 이미지 (nginx:alpine + site/)
├─ site/index.html      이미지에 들어가는 정적 페이지
├─ mount-demo/          바인드 마운트 실습용 폴더
├─ compose.yaml         (보너스) Compose 단일 서비스
└─ docs/
   ├─ logs/01~11_*.md   단계별 명령 + 출력 로그
   ├─ img/              포트 접속 캡처 (VSCode 연동 캡처는 7절 참고)
   └─ troubleshooting.md  트러블슈팅 5건
```

## 2) 실행 환경

| 항목 | 값 |
|---|---|
| OS | Windows 11 Pro (10.0.26300) |
| 쉘 / 터미널 | Git Bash (MSYS bash), VS Code 통합 터미널 |
| Docker | Docker 29.9.2 (Docker Desktop 4.97.0, WSL2 백엔드), Compose v5.6.1 |
| Git | 2.55.0.windows.5 |
| 터미널·권한 실습 | `ubuntu:latest` 컨테이너 안 (Ubuntu 26.04 LTS, 일반 사용자 `ubuntu`) |

원문의 OrbStack은 서울 캠퍼스(macOS) 안내라서, 이 PC(Windows)에서는 같은 역할을 하는 Docker Desktop을 썼습니다. `docker` 명령은 동일합니다. 터미널 실습을 컨테이너 안에서 한 것은 Windows 쉘에는 `chmod` 의미가 그대로 없고, 일반 사용자 권한이어야 "권한 거부"가 실제로 보이기 때문입니다.

## 3) 수행 체크리스트

- [x] 터미널 기본 조작 (위치 · 목록 · 이동 · 생성 · 복사 · 이동/이름변경 · 삭제 · 내용 확인) — [로그 01](docs/logs/01_terminal.md)
- [x] 권한 실습 (파일 1개 · 디렉토리 1개, 변경 전/후) — [로그 02](docs/logs/02_permissions.md)
- [x] Docker 설치 · 점검 (`--version`, `version`, `info`) — [로그 03](docs/logs/03_docker_check.md)
- [x] Docker 운영 명령 (`images` · `ps` · `ps -a` · `logs` · `stats`) — [로그 04](docs/logs/04_docker_ops.md)
- [x] `hello-world` · `ubuntu` 진입 · attach vs exec 관찰 — [로그 05](docs/logs/05_containers.md)
- [x] Dockerfile 커스텀 이미지 빌드 · 실행 — [로그 06](docs/logs/06_dockerfile.md)
- [x] 포트 매핑 접속 2회 (8080 · 8081, 브라우저 캡처) — [로그 07](docs/logs/07_ports.md)
- [x] 바인드 마운트 반영 (호스트 수정 전/후) — [로그 08](docs/logs/08_bind_mount.md)
- [x] 볼륨 영속성 (컨테이너 삭제 전/후) — [로그 09](docs/logs/09_volume.md)
- [x] Git 설정 · `git config --list` — [로그 11](docs/logs/11_git_config.md)
- [ ] VSCode GitHub 연동 캡처 — 4번 항목 참고 (`docs/img/vscode-github.png`, 캡처 후 체크)
- [x] 보안 · 개인정보 (토큰 · 이메일 마스킹) — [로그 11](docs/logs/11_git_config.md)
- [x] (보너스) Compose 단일 서비스 · `up/ps/logs/down` · 환경 변수로 포트·모드 변경 — [로그 10](docs/logs/10_compose_bonus.md)

## 4) 검증 방법과 결과 위치

| 무엇을 확인했나 | 어떤 명령으로 | 결과 위치 |
|---|---|---|
| 터미널 조작이 되는가 | `pwd` `ls -la` `cd` `mkdir` `touch` `cp` `mv` `rm` `cat` | [01](docs/logs/01_terminal.md) |
| 권한이 의미대로 동작하는가 | `ls -l` → `chmod 600/000/755` → 다른 사용자(`nobody`)로 읽기 시도 | [02](docs/logs/02_permissions.md) |
| Docker가 설치되고 데몬이 도는가 | `docker --version` · `docker info`(`Server Version`이 나오면 데몬 동작) | [03](docs/logs/03_docker_check.md) |
| 운영 명령을 쓸 수 있는가 | `docker images` `ps -a` `logs` `stats --no-stream` `stop/start/rm` | [04](docs/logs/04_docker_ops.md) |
| 컨테이너를 돌릴 수 있고 attach/exec 차이를 아는가 | `docker run hello-world` · `run -it ubuntu` · `exec` · `attach` | [05](docs/logs/05_containers.md) |
| 커스텀 이미지가 만들어지고 응답하는가 | `docker build -t e1-1-web:1.0 .` → `docker run` → `curl` → `docker inspect` | [06](docs/logs/06_dockerfile.md) |
| 포트 매핑이 되는가 | `docker run -p 8080:80`, `-p 8081:80` → `curl` · 브라우저(주소창 포함) | [07](docs/logs/07_ports.md), [8080](docs/img/port-8080.png), [8081](docs/img/port-8081.png) |
| 호스트 변경이 컨테이너에 바로 보이는가 | `-v <호스트폴더>:/usr/share/nginx/html:ro` → 파일 수정 → `curl` 전/후 | [08](docs/logs/08_bind_mount.md) |
| 컨테이너를 지워도 데이터가 남는가 | `docker volume create` → `-v mydata:/data` → `rm -f` → 새 컨테이너 | [09](docs/logs/09_volume.md) |
| Git 설정이 되었는가 | `git config --list --show-origin` (마스킹) · `gh auth status` | [11](docs/logs/11_git_config.md) |
| Compose로 같은 일이 되는가 | `docker compose up -d / ps / logs / down` | [10](docs/logs/10_compose_bonus.md) |

### 커스텀 이미지 요약

- **기존 베이스**: `nginx:alpine` (Docker Hub 공식 이미지) — 웹 서버가 이미 들어 있어 내 콘텐츠만 교체하는 (A)안.
- **커스텀 포인트와 목적**

| 포인트 | 목적 |
|---|---|
| `COPY site/ /usr/share/nginx/html/` | 기본 환영 페이지를 내 페이지로 교체. 콘텐츠가 이미지에 구워져 어디서 실행해도 같은 화면 |
| `LABEL` | 이름·설명·작성자를 메타데이터로 남김 (`docker inspect`) |
| `ENV APP_ENV=dev` | 실행 모드를 코드 밖 설정값으로 분리 (`-e`로 덮어쓰기 가능) |
| `HEALTHCHECK` | "떠 있음"이 아니라 "응답함"을 확인 (`docker ps`에 `(healthy)`) |

### 빠른 재현 (평가자용)

Windows Git Bash에서는 `/data/...` 같은 인자가 Windows 경로로 바뀌므로 먼저 `export MSYS_NO_PATHCONV=1`을 실행합니다(Linux/macOS/WSL은 필요 없음). 아래 명령은 이 PC에서 그대로 다시 실행해 `200 200`과 `hi`가 나오는 것을 확인했습니다.

```bash
export MSYS_NO_PATHCONV=1   # Windows Git Bash 전용
# 이 저장소 폴더에서
docker build -t e1-1-web:1.0 .
docker run -d -p 8080:80 --name web-8080 e1-1-web:1.0
docker run -d -p 8081:80 --name web-8081 e1-1-web:1.0
curl http://localhost:8080 ; curl http://localhost:8081
docker ps                       # 둘 다 (healthy)
docker rm -f web-8080 web-8081

# 볼륨 영속성
docker volume create mydata
docker run -d --name vol-test -v mydata:/data ubuntu sleep infinity
docker exec vol-test bash -c "echo hi > /data/hello.txt"
docker rm -f vol-test
docker run --rm -v mydata:/data ubuntu cat /data/hello.txt   # hi
docker volume rm mydata
```

바인드 마운트 명령은 PC마다 경로가 달라 [로그 08](docs/logs/08_bind_mount.md)에 Linux/macOS/WSL용(`$PWD`)과 Windows Git Bash용을 나란히 적었습니다.

## 5) 트러블슈팅 (5건, 전문은 [docs/troubleshooting.md](docs/troubleshooting.md))

| # | 문제 | 원인 가설 → 확인 → 해결 |
|---|---|---|
| 1 | `docker attach`로 보낸 명령의 출력이 비어 나옴 | 입력이 한꺼번에 들어가 `exit`로 PID 1이 먼저 끝남 → 입력 사이 `sleep 1` → 출력됨 |
| 2 | `wsl -l -v` 글자 사이에 빈칸 | UTF-16LE 출력 → `\| tr -d "\0"` → 정상 |
| 3 | 실습 스크립트에서 `cd perm_lab` 실패 | 이미 그 안에 있어 상대 경로가 어긋남 → `pwd` 확인 → 중복 `cd` 제거 |
| 4 | 브라우저 캡처에 주소창이 안 나오거나 화면 좌표가 어긋남 | 150% 배율 → 결과 이미지 확인 → 창 핸들 `PrintWindow`로 저장 |
| 5 | 바인드 마운트 `Source`가 이 PC 경로로 남음 | 호스트 경로가 설정에 그대로 들어감 → `MSYS_NO_PATHCONV=1`, `$PWD`판 명령 병기 |

## 6) 과제 목표 — 한 줄 설명

- **절대 경로 vs 상대 경로**: 절대 경로는 `/`부터 시작해 어디서든 같은 곳(`/home/ubuntu/perm_lab`), 상대 경로는 "지금 있는 곳" 기준이라 위치가 바뀌면 뜻이 달라진다(트러블슈팅 3번이 그 사례).
- **r/w/x와 755·644**: r=4, w=2, x=1을 더해 소유자·그룹·그 밖의 순서로 쓴다. 755 = `rwxr-xr-x`(소유자 전부, 나머지는 읽기·실행), 644 = `rw-r--r--`(소유자 읽기·쓰기, 나머지 읽기). 디렉토리의 x는 "안으로 들어갈 수 있음"이다(로그 02에서 000으로 들어가기 실패 확인).
- **커스텀 이미지**: 기존 이미지(`nginx:alpine`) 위에 내 파일·설정층을 쌓는 것. `Dockerfile`의 `FROM`이 출발점, 나머지 줄이 그 위에 쌓는 층이다.
- **포트 매핑이 필요한 이유**: 컨테이너는 격리된 네트워크라 밖에서 안의 80번 포트가 보이지 않는다. `-p 8080:80`이 "내 PC의 8080 → 컨테이너의 80"을 이어 주고, 같은 이미지를 포트만 바꿔 여러 개 띄울 수 있다.
- **Docker 볼륨**: 컨테이너가 지워져도 남는 Docker 관리 저장소. 컨테이너 쓰기 층은 컨테이너와 함께 사라지지만 볼륨은 따로 있어 새 컨테이너에 다시 연결하면 데이터가 이어진다(로그 09의 대조 실험).
- **Git vs GitHub**: Git은 내 PC에서 변경 이력을 기록하는 도구(로컬 버전 관리), GitHub는 그 저장소를 올려 두고 공유·협업하는 원격 플랫폼이다. 이 과제는 둘을 `git remote`(origin)로 이어 두었다.

## 7) GitHub · VSCode 연동

- 사용자 정보 · 기본 브랜치 설정과 `git config --list`(마스킹)는 [로그 11](docs/logs/11_git_config.md).
- GitHub 로그인(GitHub CLI) 확인과 원격 `origin` 연결도 로그 11.
- **VSCode GitHub 연동 캡처**: `docs/img/vscode-github.png` — 본인이 캡처해 둘 항목(토큰·이메일은 가려서 저장). 캡처가 들어오면 위 체크리스트의 빈 칸에 체크한다.

## 8) 보안

로그·이미지에는 토큰·비밀번호·인증 코드가 없습니다. 이메일은 앞부분을 가렸고, GitHub 토큰은 Windows 자격 증명 관리자에만 있으며 `gh auth status` 출력의 토큰 줄도 치환했습니다. Docker는 `docker login` 없이 공개 이미지만 받았습니다.
