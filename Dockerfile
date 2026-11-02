# 베이스: 가벼운 정적 웹 서버 이미지 (A안: 웹 서버 베이스 + 정적 콘텐츠 교체)
FROM nginx:alpine

# 이미지 정보 표시용 메타데이터 (docker inspect 로 확인)
LABEL org.opencontainers.image.title="e1-1-web" \
      org.opencontainers.image.description="E1_1 practice: nginx:alpine + static site" \
      org.opencontainers.image.authors="etu9317cw"

# 앱 모드 표시용 환경 변수 (컨테이너 안 printenv 로 확인, 실행 때 -e 로 덮어쓸 수 있음)
ENV APP_ENV=dev

# 기본 nginx 페이지를 내 정적 페이지로 교체
COPY site/ /usr/share/nginx/html/

# 컨테이너가 "떠 있는가"가 아니라 "응답하는가"를 점검
HEALTHCHECK --interval=10s --timeout=3s --start-period=3s --retries=3 \
  CMD wget -qO- http://localhost/ > /dev/null || exit 1
