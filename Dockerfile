FROM node:20-slim

# 1. mysql-client 및 bash 설치
RUN apt-get update && apt-get install -y \
  default-mysql-client \
  bash \
  && rm -rf /var/lib/apt/lists/*

# 2. 작업 디렉토리
WORKDIR /app

# 3. 스크립트 복사
COPY clone-procs.sh .
COPY clone-proc.js .

# 4. 실행 권한 부여
RUN chmod +x clone-procs.sh

# 5. mysql → mariadb 호환성 링크 생성 (선택사항)
RUN ln -s /usr/bin/mariadb /usr/bin/mysql || true

# 6. 실행
CMD ["./clone-procs.sh"]
