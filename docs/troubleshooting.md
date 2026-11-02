# 트러블슈팅 기록

작업 중 실제로 막힌 것만 적는다. 형식은 문제 → 원인 가설 → 확인 → 해결/대안. (S6에서 포트·마운트·Dockerfile 쪽 문제가 생기면 이어서 적는다.)

## 1. `docker attach`로 보낸 명령의 출력이 비어 나옴

- **문제**: `printf "echo attach-shell-start\nexit\n" | docker attach u2`를 실행했더니 아무 출력도 없이 끝났다. 컨테이너는 `Exited (0)`이라 쉘이 `exit`까지 실행된 것은 맞는데 `echo` 결과가 화면에 안 보였다.
- **원인 가설**: 입력을 한 번에 다 밀어 넣으면 `exit`가 바로 이어져 컨테이너(PID 1)가 끝나고, `attach` 클라이언트가 출력 스트림을 다 받기 전에 연결이 닫힌다.
- **확인**: 입력 사이에 1초 쉬게 바꿔 `(printf "echo attach-shell-start\n"; sleep 1; printf "exit\n") | docker attach u2`로 다시 실행했다.
- **해결**: 이번에는 `attach-shell-start`가 출력되고 컨테이너도 `Exited (0)`이 되었다. 가설과 맞는 결과다. 사람이 `-it`로 직접 칠 때는 입력 간격이 길어 생기지 않는 문제다. 로그는 `logs/05_containers.md` D절.

## 2. `wsl -l -v` 출력이 글자 사이에 빈칸이 끼어 깨져 보임

- **문제**: Git Bash에서 `wsl -l -v`를 실행하면 `N A M E   S T A T E   V E R S I O N`처럼 글자 사이마다 빈칸이 들어가 읽기 어려웠다.
- **원인 가설**: `wsl.exe`는 목록을 UTF-16LE로 내보낸다. 글자 하나가 2바이트(영문 뒤에 `\0`)인데 Git Bash 터미널이 `\0`을 빈칸처럼 그린다.
- **확인**: `wsl -l -v | tr -d "\0"`로 널 문자를 지웠다.
- **해결**: 정상 글자로 읽힌다 (`docker-desktop  Running  2`). 앞으로 `wsl` 출력은 `| tr -d "\0"`를 붙인다. 로그는 `logs/03_docker_check.md`.

## 3. 실습 스크립트에서 `cd`가 한 번 더 실패 (`cd: perm_lab: No such file or directory`)

- **문제**: 권한 실습 스크립트 첫 줄에서 `mkdir -p perm_lab && cd perm_lab && pwd`를 실행하고, 바로 다음 줄에서 `cd perm_lab`을 또 했더니 오류가 났다.
- **원인 가설**: 첫 명령에서 이미 `perm_lab` 안으로 들어가 있어서, 그 안에서 다시 `perm_lab`을 찾았다 (상대 경로는 현재 위치 기준).
- **확인**: 오류 직후 `pwd`가 `/home/ubuntu/perm_lab`이었다 (실행 결과는 지워졌고 로그는 다시 실행해 만들었다).
- **해결**: 중복된 `cd`를 지우고 처음부터 다시 실행했다. 상대 경로가 "지금 있는 곳"을 기준으로 해석된다는 과제 목표 1번의 실제 사례가 되었다.
