# 02. 권한 실습 로그 (파일 1개 + 디렉토리 1개)

파일 `report.txt`(644 → 600 → 644)와 `run.sh`(실행 권한 추가), 디렉토리 `shared`(755 → 000 → 755)의 권한을 `chmod`로 바꾸고 `ls -l`·`stat`로 전/후를 비교했다.

- 실행 위치: 컨테이너 `ubuntu:latest` 안 (사용자 `ubuntu`, 홈 `/home/ubuntu`), 기록일 2026-11-02
- 컨테이너 시계는 UTC라 날짜·시각이 Windows와 다르게 보인다.

```text
$ mkdir -p perm_lab && cd perm_lab && pwd
/home/ubuntu/perm_lab

$ echo "secret memo" > report.txt

$ mkdir shared

$ echo "in shared" > shared/inside.txt

### [파일] report.txt — 변경 전
$ ls -l report.txt
-rw-r--r-- 1 ubuntu ubuntu 12 Nov  2 10:48 report.txt

$ stat -c "%a %A %n" report.txt
644 -rw-r--r-- report.txt

### [파일] 644 -> 600 (소유자만 읽기/쓰기)
$ chmod 600 report.txt

$ ls -l report.txt
-rw------- 1 ubuntu ubuntu 12 Nov  2 10:48 report.txt

$ stat -c "%a %A %n" report.txt
600 -rw------- report.txt

### [파일] 실행 권한 실험: 스크립트 만들기
$ printf "#!/bin/bash\necho script ran\n" > run.sh

$ ls -l run.sh
-rw-r--r-- 1 ubuntu ubuntu 28 Nov  2 10:48 run.sh

$ ./run.sh
bash: line 1: ./run.sh: Permission denied

$ chmod u+x run.sh

$ ls -l run.sh
-rwxr--r-- 1 ubuntu ubuntu 28 Nov  2 10:48 run.sh

$ ./run.sh
script ran

### [디렉토리] shared — 변경 전
$ ls -ld shared
drwxr-xr-x 2 ubuntu ubuntu 4096 Nov  2 10:48 shared

$ stat -c "%a %A %n" shared
755 drwxr-xr-x shared

### [디렉토리] 755 -> 000 (아무도 못 들어감)
$ chmod 000 shared

$ ls -ld shared
d--------- 2 ubuntu ubuntu 4096 Nov  2 10:48 shared

$ ls shared
ls: cannot open directory 'shared': Permission denied

$ cat shared/inside.txt
cat: shared/inside.txt: Permission denied

### [디렉토리] 000 -> 755 되돌리기
$ chmod 755 shared

$ ls -ld shared
drwxr-xr-x 2 ubuntu ubuntu 4096 Nov  2 10:48 shared

$ ls shared
inside.txt

$ cat shared/inside.txt
in shared

### 같은 파일을 다른 사용자(nobody)가 읽을 때: 600 vs 644
$ ls -l report.txt
-rw------- 1 ubuntu ubuntu 12 Nov  2 10:48 report.txt

$ chmod 644 report.txt

$ ls -l report.txt
-rw-r--r-- 1 ubuntu ubuntu 12 Nov  2 10:48 report.txt

```
