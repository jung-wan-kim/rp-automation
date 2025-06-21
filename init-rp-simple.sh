#!/bin/bash

# 간단한 버전의 init-rp 스크립트

echo "RP 자동화 시스템 설치 중..."

# .rp 디렉토리 확인
if [ -d ".rp" ]; then
    echo ".rp 디렉토리가 이미 존재합니다."
    exit 0
fi

# .rp 디렉토리 생성
mkdir -p .rp

# GitHub에서 파일 다운로드
BASE_URL="https://raw.githubusercontent.com/jung-wan-kim/rp-automation/master"

FILES=(
    "product-manager.md"
    "ux-ui-designer.md"
    "frontend-developer.md"
    "backend-developer.md"
    "devops-engineer.md"
    "qa-engineer.md"
    "technical-writer.md"
    "project-manager.md"
    "SYSTEM.md"
    "WORKFLOW.md"
)

echo "RP 파일 다운로드 중..."

for file in "${FILES[@]}"; do
    echo "다운로드: $file"
    curl -fsSL "$BASE_URL/$file" -o ".rp/$file" || echo "실패: $file"
done

# PROJECT_CONTEXT.md 생성
cat > .rp/PROJECT_CONTEXT.md << 'EOF'
# 프로젝트 컨텍스트

## 프로젝트 정보
- **프로젝트명**: [프로젝트명]
- **설명**: [프로젝트 설명]
- **타입**: [웹/모바일/API/기타]
- **생성일**: $(date +%Y-%m-%d)

## 기술 스택
- Frontend: 
- Backend: 
- Database: 
- Infrastructure: 

## 주요 기능
1. 
2. 
3. 

## RP 활용 가이드
각 RP 파일과 이 PROJECT_CONTEXT.md를 함께 사용하여 작업을 수행합니다.
EOF

# README.md 생성
cat > .rp/README.md << 'EOF'
# RP 자동화 시스템

이 디렉토리에는 RP(Role-Playing) 자동화 시스템이 설정되어 있습니다.

## 사용 방법

```bash
claude-code ".rp/PROJECT_CONTEXT.md와 .rp/product-manager.md를 참고해서 PRD를 작성해줘"
```

## RP 목록
- product-manager.md
- ux-ui-designer.md
- frontend-developer.md
- backend-developer.md
- devops-engineer.md
- qa-engineer.md
- technical-writer.md
- project-manager.md
EOF

# .gitignore 업데이트
if [ -f .gitignore ]; then
    if ! grep -q "^\.rp/$" .gitignore; then
        echo -e "\n# RP 자동화 시스템 파일" >> .gitignore
        echo ".rp/" >> .gitignore
    fi
else
    echo "# RP 자동화 시스템 파일" > .gitignore
    echo ".rp/" >> .gitignore
fi

echo "✅ RP 자동화 시스템 설치 완료!"
echo "📁 .rp/ 디렉토리에 RP 파일들이 다운로드되었습니다."
echo "📝 .rp/PROJECT_CONTEXT.md를 수정하여 프로젝트 정보를 업데이트하세요."