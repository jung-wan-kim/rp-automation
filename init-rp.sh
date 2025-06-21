#!/bin/bash

# RP 자동화 시스템 초기화 스크립트 (자동화 버전)
# 사용법: curl -fsSL https://raw.githubusercontent.com/jung-wan-kim/rp-automation/master/init-rp.sh | bash

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# GitHub raw 파일 기본 URL
GITHUB_RAW_URL="https://raw.githubusercontent.com/jung-wan-kim/rp-automation/master"

# 다운로드할 RP 파일 목록
RP_FILES=(
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

# 헤더 출력
print_header() {
    echo -e "${PURPLE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}            ${CYAN}RP 자동화 시스템 초기화${NC}                       ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}            ${YELLOW}Role-Playing Automation Setup${NC}                  ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# 진행 상황 표시
show_progress() {
    local current=$1
    local total=$2
    local percent=$((current * 100 / total))
    local bar_length=40
    local filled_length=$((percent * bar_length / 100))
    
    # 터미널이 아닌 경우 (파이프 실행) 진행 표시 생략
    if [ -t 1 ]; then
        printf "\r["
        printf "%${filled_length}s" | tr ' ' '='
        printf "%$((bar_length - filled_length))s" | tr ' ' '-'
        printf "] %d%%" $percent
    fi
}

# .rp 디렉토리 확인 및 생성
create_rp_directory() {
    if [ -d ".rp" ]; then
        echo -e "${YELLOW}⚠️  .rp 디렉토리가 이미 존재합니다.${NC}"
        # 파이프로 실행 시에는 자동으로 진행
        if [ -t 0 ]; then
            echo -e "${RED}기존 파일들이 덮어쓰기 됩니다. 계속하시겠습니까? (y/N)${NC}"
            read -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo -e "${RED}초기화를 취소합니다.${NC}"
                exit 1
            fi
        else
            echo -e "${YELLOW}기존 파일을 덮어쓰기합니다...${NC}"
        fi
    fi
    
    mkdir -p .rp
    echo -e "${GREEN}✓${NC} .rp 디렉토리 생성 완료"
}

# RP 파일 다운로드
download_rp_files() {
    echo -e "\n${CYAN}RP 파일을 다운로드하는 중...${NC}\n"
    
    local total=${#RP_FILES[@]}
    local current=0
    local failed_files=()
    
    for file in "${RP_FILES[@]}"; do
        current=$((current + 1))
        echo -e "${CYAN}[$current/$total]${NC} $file 다운로드 중..."
        
        if curl -fsSL "${GITHUB_RAW_URL}/${file}" -o ".rp/${file}"; then
            echo -e "${GREEN}✓${NC} $file 다운로드 완료"
        else
            echo -e "${RED}✗${NC} $file 다운로드 실패 (에러: $?)"
            failed_files+=("$file")
        fi
        
        show_progress $current $total
        if [ -t 1 ]; then
            echo -e "\n"
        fi
    done
    
    if [ ${#failed_files[@]} -gt 0 ]; then
        echo -e "\n${RED}다음 파일들을 다운로드하지 못했습니다:${NC}"
        for file in "${failed_files[@]}"; do
            echo -e "  - $file"
        done
    fi
}

# PROJECT_CONTEXT.md 생성
create_project_context() {
    # 프로젝트 이름을 현재 디렉토리명으로 자동 설정
    local PROJECT_NAME=$(basename "$(pwd)")
    local PROJECT_DATE=$(date +%Y-%m-%d)
    
    cat > .rp/PROJECT_CONTEXT.md << EOF
# 프로젝트 컨텍스트

## 프로젝트 정보
- **프로젝트명**: $PROJECT_NAME
- **설명**: [프로젝트 설명을 입력하세요]
- **타입**: [웹 애플리케이션/모바일 앱/API 서버/기타]
- **생성일**: $PROJECT_DATE

## 프로젝트 구조
\`\`\`
$(tree -L 3 2>/dev/null || find . -type d -not -path '*/\.*' | head -20 | sed 's|[^/]*/||g' | sed 's|^|  |')
\`\`\`

## 기술 스택
<!-- 프로젝트에서 사용하는 기술 스택을 추가해주세요 -->
- Frontend: 
- Backend: 
- Database: 
- Infrastructure: 

## 주요 기능
<!-- 프로젝트의 주요 기능을 나열해주세요 -->
1. 
2. 
3. 

## 개발 가이드라인
<!-- 프로젝트별 개발 규칙이나 컨벤션을 추가해주세요 -->
- 코딩 스타일: 
- 브랜치 전략: 
- 커밋 규칙: 

## RP 활용 가이드
이 프로젝트에서는 다음과 같이 RP를 활용합니다:

### 프로젝트 특화 지시사항
각 RP는 이 프로젝트의 컨텍스트를 이해하고 작업을 수행합니다.
- 모든 코드는 프로젝트의 기존 스타일을 따릅니다
- 기술 스택은 위에 명시된 것을 사용합니다
- 프로젝트의 주요 기능을 고려하여 작업합니다

### Claude Code 사용 예시
\`\`\`bash
# 프로젝트 컨텍스트와 함께 특정 RP 활용
claude-code ".rp/PROJECT_CONTEXT.md와 .rp/backend-developer.md를 참고해서 
            새로운 API 엔드포인트를 추가해줘"

# 전체 팀 시뮬레이션
claude-code ".rp/PROJECT_CONTEXT.md를 기반으로 모든 RP를 활용해서 
            새로운 기능을 개발해줘"
\`\`\`
EOF

    echo -e "${GREEN}✓${NC} PROJECT_CONTEXT.md 생성 완료"
}

# README.md 생성
create_readme() {
    local PROJECT_NAME=$(basename "$(pwd)")
    
    cat > .rp/README.md << EOF
# RP 자동화 시스템 사용 가이드

## 🚀 시작하기

이 프로젝트에는 RP(Role-Playing) 자동화 시스템이 설정되어 있습니다.

### 프로젝트 정보
- **프로젝트명**: $PROJECT_NAME
- **RP 시스템 버전**: 1.0

### 설정된 RP 목록
- **product-manager**: Product Manager - 제품의 비전을 정의하고 요구사항을 구체화
- **ux-ui-designer**: UX/UI Designer - 사용자 경험을 최적화하고 인터페이스를 설계
- **frontend-developer**: Frontend Developer - 사용자 인터페이스를 구현
- **backend-developer**: Backend Developer - 서버 애플리케이션과 비즈니스 로직을 구현
- **devops-engineer**: DevOps Engineer - 빌드, 배포, 운영을 자동화
- **qa-engineer**: QA Engineer - 소프트웨어 품질을 보장
- **technical-writer**: Technical Writer - 기술 문서를 작성
- **project-manager**: Project Manager - 프로젝트 전체를 관리하고 조율

## 📖 사용 방법

### 1. Claude Code에서 RP 활용하기

각 RP 파일과 프로젝트 컨텍스트를 함께 사용하여 작업을 수행합니다:

\`\`\`bash
# 프로젝트 컨텍스트와 함께 사용 (권장)
claude-code ".rp/PROJECT_CONTEXT.md와 .rp/product-manager.md를 참고해서 
            이 프로젝트의 PRD를 작성해줘"

# 특정 RP만 사용
claude-code ".rp/frontend-developer.md를 참고해서 컴포넌트를 개발해줘"

# 전체 RP 체인 실행
claude-code ".rp/의 모든 RP를 활용해서 프로젝트를 진행해줘"
\`\`\`

### 2. 전체 프로젝트 워크플로우

1. **Product Manager**: 요구사항 정의 및 PRD 작성
2. **UX/UI Designer**: 디자인 시스템 구축
3. **Frontend Developer**: UI 구현
4. **Backend Developer**: API 개발
5. **DevOps Engineer**: 인프라 구축 및 배포
6. **QA Engineer**: 테스트 및 품질 보증
7. **Technical Writer**: 문서화
8. **Project Manager**: 전체 프로젝트 관리

### 3. 프로젝트 컨텍스트 업데이트

프로젝트가 진행되면서 PROJECT_CONTEXT.md 파일을 업데이트하여 
RP들이 최신 프로젝트 상태를 반영할 수 있도록 합니다.

## 🔧 추가 설정

### RP 재설치
\`\`\`bash
curl -fsSL https://raw.githubusercontent.com/jung-wan-kim/rp-automation/master/init-rp.sh | bash
\`\`\`

### 커스텀 RP 생성
\`.rp/\` 디렉토리에 새로운 \`.md\` 파일을 추가하여 커스텀 RP를 생성할 수 있습니다.

## 📚 참고 자료

- [RP 자동화 시스템 전체 문서](https://github.com/jung-wan-kim/rp-automation)
- [Claude Code 사용법](https://docs.anthropic.com/claude-code)
EOF

    echo -e "${GREEN}✓${NC} README.md 생성 완료"
}

# .gitignore 업데이트
update_gitignore() {
    if [ -f .gitignore ]; then
        # .rp가 이미 있는지 확인
        if ! grep -q "^\.rp/$" .gitignore; then
            echo -e "\n# RP 자동화 시스템 파일" >> .gitignore
            echo ".rp/" >> .gitignore
            echo -e "${GREEN}✓${NC} .gitignore 업데이트 완료"
        else
            echo -e "${YELLOW}ℹ${NC} .gitignore에 .rp/가 이미 포함되어 있습니다"
        fi
    else
        # .gitignore 생성
        echo "# RP 자동화 시스템 파일" > .gitignore
        echo ".rp/" >> .gitignore
        echo -e "${GREEN}✓${NC} .gitignore 생성 완료"
    fi
}

# 완료 메시지
show_completion() {
    local PROJECT_NAME=$(basename "$(pwd)")
    
    echo -e "\n${GREEN}✅ RP 자동화 시스템 설정이 완료되었습니다!${NC}"
    echo
    echo -e "${CYAN}프로젝트 정보:${NC}"
    echo -e "  • 프로젝트: ${BLUE}$PROJECT_NAME${NC}"
    echo -e "  • 위치: ${BLUE}$(pwd)${NC}"
    echo
    echo -e "${CYAN}생성된 파일:${NC}"
    echo -e "  • ${YELLOW}.rp/${NC} - RP 시스템 디렉토리"
    echo -e "  • ${YELLOW}.rp/PROJECT_CONTEXT.md${NC} - 프로젝트 컨텍스트 (수정 필요)"
    echo -e "  • ${YELLOW}.rp/README.md${NC} - 사용 가이드"
    echo -e "  • ${YELLOW}.rp/*.md${NC} - 역할별 RP 파일들"
    echo
    echo -e "${CYAN}다음 단계:${NC}"
    echo -e "  1. ${YELLOW}.rp/PROJECT_CONTEXT.md${NC}를 편집하여 프로젝트 정보를 업데이트하세요"
    echo -e "  2. Claude Code에서 RP를 활용하여 개발을 시작하세요:"
    echo -e "     ${GREEN}claude-code \".rp/의 모든 RP를 활용해서 프로젝트를 진행해줘\"${NC}"
    echo
    echo -e "${GREEN}Happy Coding with RP Automation! 🚀${NC}"
}

# 메인 실행 함수
main() {
    print_header
    
    echo -e "${CYAN}현재 디렉토리: ${BLUE}$(pwd)${NC}"
    echo -e "${YELLOW}RP 자동화 시스템을 설치합니다...${NC}\n"
    
    # .rp 디렉토리 생성
    create_rp_directory
    
    # RP 파일 다운로드
    download_rp_files
    
    # PROJECT_CONTEXT.md 생성
    create_project_context
    
    # README.md 생성
    create_readme
    
    # .gitignore 업데이트
    update_gitignore
    
    # 완료 메시지
    show_completion
}

# 스크립트 실행
main