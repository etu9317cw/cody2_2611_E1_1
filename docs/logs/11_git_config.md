# 11. Git 설정 · GitHub 연동 로그

Git 사용자 정보와 기본 브랜치를 설정하고 `git config --list`로 확인했다. 민감정보는 마스킹했다(이메일 앞부분은 `***`, 토큰은 출력 자체를 `****`로 치환).

- 실행 위치: Windows 11 Pro 노트북, Git Bash, 기록일 2026-11-02
- Git 2.55.0.windows.5

## 설정 명령

```text
$ git config --global user.name  "etu9317cw"        # 이미 설정돼 있어 값 확인만 함 (GitHub 계정 ID와 같음)
$ git config --global user.email "<본인 이메일>"     # 이미 설정돼 있음 (아래 출력에서는 마스킹)
$ git config --global init.defaultBranch main       # 이번에 설정 (설정 전에는 Git 시스템 기본값 master)
$ git config --global --get init.defaultBranch
main
```

기본 브랜치를 `main`으로 정해 두면 앞으로 `git init`이 처음부터 `main` 브랜치를 만든다. 이 저장소는 `git init -b main`으로 만들어 처음부터 `main`이다.

## `git config --list --show-origin` (마스킹)

```text
$ git config --list --show-origin | sed -E 's/(user\.email=)(.)[^@]*(@.*)/\1\2***\3/'
file:C:/Program Files/Git/etc/gitconfig   core.autocrlf=true
file:C:/Program Files/Git/etc/gitconfig   credential.helper=manager
file:C:/Program Files/Git/etc/gitconfig   init.defaultbranch=master
file:C:/Users/MSI/.gitconfig              user.name=etu9317cw
file:C:/Users/MSI/.gitconfig              user.email=e***@gmail.com
file:C:/Users/MSI/.gitconfig              init.defaultbranch=main
file:.git/config                          remote.origin.url=https://github.com/etu9317cw/cody2_2611_E1_1.git
file:.git/config                          remote.origin.fetch=+refs/heads/*:refs/remotes/origin/*
(그 밖에 core.*·filter.lfs.*·http.sslbackend 등 Git 설치 기본값은 생략)
```

읽는 법: 같은 키가 여러 층에 있으면 **아래(더 좁은 범위) 값이 이긴다**. `init.defaultbranch`는 시스템층 `master`를 사용자층 `main`이 덮어쓴다.

## GitHub 로그인 확인 (GitHub CLI)

```text
$ git branch --show-current
main
$ git remote -v
origin  https://github.com/etu9317cw/cody2_2611_E1_1.git (fetch)
origin  https://github.com/etu9317cw/cody2_2611_E1_1.git (push)
$ gh auth status        # 토큰 줄은 치환
github.com
  ✓ Logged in to github.com account etu9317cw (keyring)
  - Git operations protocol: https
  - Token: ****(masked)
  - Token scopes: 'gist', 'read:org', 'repo'
```

- 토큰은 Windows 자격 증명 관리자(keyring)에 저장돼 있고 이 저장소 파일에는 없다.
- 원격 저장소 `cody2_2611_E1_1`은 공개로 만들어 로컬에 연결해 두었다. **push는 제출 직전에 한 번에 한다**(이 문서를 쓰는 시점에는 아직 push 전).

## VSCode GitHub 연동 증거

VSCode에서 GitHub 계정 로그인 화면 캡처는 `docs/img/vscode-github.png`에 둔다(토큰·이메일은 가려서 저장).
