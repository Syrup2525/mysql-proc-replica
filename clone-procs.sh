#!/bin/bash
set -e

KEYWORD="$FILTER_KEYWORD"

echo "🎯 키워드 기반 프로시저 복제 시작!"
echo "🔎 포함 키워드: '${KEYWORD}'"
echo "📤 FROM: ${SOURCE_MYSQL_DATABASE}@${SOURCE_MYSQL_HOST}"
echo "📥 TO:   ${TARGET_MYSQL_DATABASE}@${TARGET_MYSQL_HOST}"
echo ""

PROCS=$(mysql -h "$SOURCE_MYSQL_HOST" -P "$SOURCE_MYSQL_PORT" -u "$SOURCE_MYSQL_USER" -p"$SOURCE_MYSQL_PASSWORD" -N -B -e \
  "SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE ROUTINE_TYPE='PROCEDURE' 
     AND ROUTINE_SCHEMA='${SOURCE_MYSQL_DATABASE}' 
     AND ROUTINE_NAME LIKE '%${KEYWORD}%';")

for PROC in $PROCS; do
  echo "🔄 복제 대상 발견: $PROC"

  RAW_FILE="/tmp/raw_proc_${PROC}.txt"
  mysql --default-character-set=utf8mb4 \
    -h "$SOURCE_MYSQL_HOST" -P "$SOURCE_MYSQL_PORT" -u "$SOURCE_MYSQL_USER" -p"$SOURCE_MYSQL_PASSWORD" \
    -e "SHOW CREATE PROCEDURE \`${SOURCE_MYSQL_DATABASE}\`.\`${PROC}\` \G" > "$RAW_FILE"

  node clone-proc.js "$PROC" "$PROC" "$RAW_FILE" "/tmp/create_proc_${PROC}.sql"

  echo "📦 실행 중: /tmp/create_proc_${PROC}.sql"
  mysql --default-character-set=utf8mb4 \
    -h "$TARGET_MYSQL_HOST" -P "$TARGET_MYSQL_PORT" \
    -u "$TARGET_MYSQL_USER" -p"$TARGET_MYSQL_PASSWORD" \
    "$TARGET_MYSQL_DATABASE" < "/tmp/create_proc_${PROC}.sql"

  echo "✅ ${PROC} 생성 완료 in ${TARGET_MYSQL_DATABASE}!"
done

echo ""
echo "🎉 키워드 '${KEYWORD}'를 포함하는 모든 프로시저 복제 완료!"
