# 01. 터미널 기본 조작 로그

현재 위치 확인(`pwd`), 목록(`ls -la`, 숨김 파일 포함), 이동(`cd`), 생성(`mkdir`, `touch`, `echo >`), 복사(`cp`), 이동/이름변경(`mv`), 삭제(`rm`), 내용 확인(`cat`)을 순서대로 실행했다. 절대 경로(`cd /home/ubuntu/...`)와 상대 경로(`cd ..`, `cd ../..`) 이동을 둘 다 넣었다.

- 실행 위치: 컨테이너 `ubuntu:latest` 안 (사용자 `ubuntu`, 홈 `/home/ubuntu`), 기록일 2026-11-02
- 컨테이너 시계는 UTC라 날짜·시각이 Windows와 다르게 보인다.

```text
$ cat /etc/os-release | head -2
PRETTY_NAME="Ubuntu 26.04.1 LTS"
NAME="Ubuntu"

$ echo $SHELL; whoami
/bin/bash
ubuntu

$ pwd
/home/ubuntu

$ ls -la
total 20
drwxr-x--- 2 ubuntu ubuntu 4096 Oct 25 10:26 .
drwxr-xr-x 3 root   root   4096 Oct 25 10:26 ..
-rw-r--r-- 1 ubuntu ubuntu  220 Feb 13  2026 .bash_logout
-rw-r--r-- 1 ubuntu ubuntu 3771 Feb 13  2026 .bashrc
-rw-r--r-- 1 ubuntu ubuntu  807 Feb 13  2026 .profile

$ mkdir -p ~/codyssey/practice/docs

$ cd ~/codyssey/practice && pwd
/home/ubuntu/codyssey/practice

$ echo "hello docker" > note.txt

$ touch empty.txt

$ ls -la
total 16
drwxr-xr-x 3 ubuntu ubuntu 4096 Nov  2 10:48 .
drwxr-xr-x 3 ubuntu ubuntu 4096 Nov  2 10:48 ..
drwxr-xr-x 2 ubuntu ubuntu 4096 Nov  2 10:48 docs
-rw-r--r-- 1 ubuntu ubuntu    0 Nov  2 10:48 empty.txt
-rw-r--r-- 1 ubuntu ubuntu   13 Nov  2 10:48 note.txt

$ cat note.txt
hello docker

$ cat empty.txt; echo "(empty.txt는 출력 없음)"
(empty.txt는 출력 없음)

$ cp note.txt docs/note_copy.txt

$ ls -la docs
total 12
drwxr-xr-x 2 ubuntu ubuntu 4096 Nov  2 10:48 .
drwxr-xr-x 3 ubuntu ubuntu 4096 Nov  2 10:48 ..
-rw-r--r-- 1 ubuntu ubuntu   13 Nov  2 10:48 note_copy.txt

$ mv empty.txt docs/blank.txt

$ mv docs/blank.txt docs/renamed.txt

$ ls -la . docs
.:
total 16
drwxr-xr-x 3 ubuntu ubuntu 4096 Nov  2 10:48 .
drwxr-xr-x 3 ubuntu ubuntu 4096 Nov  2 10:48 ..
drwxr-xr-x 2 ubuntu ubuntu 4096 Nov  2 10:48 docs
-rw-r--r-- 1 ubuntu ubuntu   13 Nov  2 10:48 note.txt

docs:
total 12
drwxr-xr-x 2 ubuntu ubuntu 4096 Nov  2 10:48 .
drwxr-xr-x 3 ubuntu ubuntu 4096 Nov  2 10:48 ..
-rw-r--r-- 1 ubuntu ubuntu   13 Nov  2 10:48 note_copy.txt
-rw-r--r-- 1 ubuntu ubuntu    0 Nov  2 10:48 renamed.txt

$ rm docs/renamed.txt

$ ls -la docs
total 12
drwxr-xr-x 2 ubuntu ubuntu 4096 Nov  2 10:48 .
drwxr-xr-x 3 ubuntu ubuntu 4096 Nov  2 10:48 ..
-rw-r--r-- 1 ubuntu ubuntu   13 Nov  2 10:48 note_copy.txt

$ cd .. && pwd
/home/ubuntu/codyssey

$ cd /home/ubuntu/codyssey/practice && pwd   # 절대 경로
/home/ubuntu/codyssey/practice

$ cd ../.. && pwd                            # 상대 경로 두 단계 위
/home/ubuntu

$ ls -d codyssey
codyssey

$ rm -r codyssey/practice/docs

$ ls -la codyssey/practice
total 12
drwxr-xr-x 2 ubuntu ubuntu 4096 Nov  2 10:48 .
drwxr-xr-x 3 ubuntu ubuntu 4096 Nov  2 10:48 ..
-rw-r--r-- 1 ubuntu ubuntu   13 Nov  2 10:48 note.txt

```
