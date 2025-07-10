const fs = require('fs');

const [, , procName, newProcName, rawFilePath, outputFilePath] = process.argv;

// 🔹 파일 읽기
const rawText = fs.readFileSync(rawFilePath, 'utf8');

// 🔹 CREATE PROCEDURE 본문 추출
function extractCreateSQL(text) {
  const result = [];
  let insideCreate = false;

  for (const line of text.split('\n')) {
    const trimmed = line.trim();

    if (!insideCreate && trimmed.startsWith('Create Procedure:')) {
      insideCreate = true;
      result.push(trimmed.replace('Create Procedure: ', ''));
    } else if (insideCreate) {
      result.push(line);
      if (/^\s*END\s*$/i.test(trimmed)) break; // END 만나면 종료
    }
  }

  if (!result.length || !result[0].startsWith('CREATE')) {
    console.error(`❌ ${procName} 파싱 실패: CREATE PROCEDURE 본문 인식 실패`);
    process.exit(1);
  }

  return result.join('\n');
}

// 🔹 CREATE SQL 추출 및 이름 치환
let createSQL = extractCreateSQL(rawText).replace(
  new RegExp(`PROCEDURE\\s+\`${procName}\``, 'g'),
  `PROCEDURE \`${newProcName}\``
);

// 🔹 최종 SQL 생성
const finalSQL = `
DELIMITER $$
DROP PROCEDURE IF EXISTS \`${newProcName}\`$$
${createSQL.trim()}$$
DELIMITER ;
`;

// 🔹 파일 저장
fs.writeFileSync(outputFilePath, finalSQL);
console.log(`📝 ${newProcName} 생성 SQL 저장 완료: ${outputFilePath}`);
