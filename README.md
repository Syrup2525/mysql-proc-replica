# Node.js 기반 MySQL Stored Procedure 복제

---

### 특정 Stored Procedure 를 다른 DB로 복제합니다.

---

### 사용 방법

1. 프로젝트 최상단 디렉터리에 .env 파일을 생성하고 다음과 같이 작성합니다
- 아래는 `rest_api_v0_13_1` 문자열을 포함하는 프로시저를 `Source` 에서 `Target` 으로 복제하는 예시입니다.

``` txt
# 🔹 Source (복사할 프로시저가 존재하는 DB)
SOURCE_MYSQL_HOST=source.example.com
SOURCE_MYSQL_PORT=3306
SOURCE_MYSQL_USER=testuser
SOURCE_MYSQL_PASSWORD=testpassword
SOURCE_MYSQL_DATABASE=testdatabase

# 🔹 Target (복사 대상 DB)
TARGET_MYSQL_HOST=target.example.com
TARGET_MYSQL_PORT=3306
TARGET_MYSQL_USER=testuser
TARGET_MYSQL_PASSWORD=testpassword
TARGET_MYSQL_DATABASE=testdatabase

# 🔹 필터 키워드 (프로시저명에 이 문자열이 포함된 경우에만 복사)
FILTER_KEYWORD=rest_api_v0_13_1
```

2. Docker Container 를 build 합니다.
``` bash
docker build -t proc-replica . 
```

3. Container 를 실행합니다.
``` bash
docker run --rm --env-file .env -v "$(pwd)/output:/tmp" proc-replica
```