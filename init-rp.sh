#!/bin/bash

# RP 자동화 시스템 초기화 스크립트
# 사용법: ./init-rp.sh

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# RP 파일 정의
declare -A RP_FILES=(
    ["product-manager"]="Product Manager - 제품의 비전을 정의하고 요구사항을 구체화"
    ["ux-ui-designer"]="UX/UI Designer - 사용자 경험을 최적화하고 인터페이스를 설계"
    ["frontend-developer"]="Frontend Developer - 사용자 인터페이스를 구현"
    ["backend-developer"]="Backend Developer - 서버 애플리케이션과 비즈니스 로직을 구현"
    ["devops-engineer"]="DevOps Engineer - 빌드, 배포, 운영을 자동화"
    ["qa-engineer"]="QA Engineer - 소프트웨어 품질을 보장"
    ["technical-writer"]="Technical Writer - 기술 문서를 작성"
    ["project-manager"]="Project Manager - 프로젝트 전체를 관리하고 조율"
)

# RP 순서 (작업 흐름에 따른 순서)
RP_ORDER=(
    "product-manager"
    "ux-ui-designer"
    "frontend-developer"
    "backend-developer"
    "devops-engineer"
    "qa-engineer"
    "technical-writer"
    "project-manager"
)

# 선택된 RP 저장
declare -a SELECTED_RPS=()

# 헤더 출력
print_header() {
    clear
    echo -e "${PURPLE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}            ${CYAN}RP 자동화 시스템 초기화 도구${NC}                   ${PURPLE}║${NC}"
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
    
    printf "\r["
    printf "%${filled_length}s" | tr ' ' '='
    printf "%$((bar_length - filled_length))s" | tr ' ' '-'
    printf "] %d%%" $percent
}

# RP 선택 메뉴
select_rps() {
    print_header
    echo -e "${GREEN}어떤 RP를 프로젝트에 적용하시겠습니까?${NC}"
    echo
    echo -e "${YELLOW}1)${NC} 전체 RP 적용 (권장)"
    echo -e "${YELLOW}2)${NC} 개별 RP 선택"
    echo -e "${YELLOW}3)${NC} 종료"
    echo
    read -p "선택하세요 (1-3): " choice

    case $choice in
        1)
            SELECTED_RPS=("${RP_ORDER[@]}")
            echo -e "\n${GREEN}✓ 전체 RP가 선택되었습니다.${NC}"
            ;;
        2)
            select_individual_rps
            ;;
        3)
            echo -e "\n${YELLOW}초기화를 취소합니다.${NC}"
            exit 0
            ;;
        *)
            echo -e "\n${RED}잘못된 선택입니다. 다시 시도해주세요.${NC}"
            sleep 2
            select_rps
            ;;
    esac
}

# 개별 RP 선택
select_individual_rps() {
    print_header
    echo -e "${GREEN}적용할 RP를 선택하세요 (Space로 선택, Enter로 완료):${NC}"
    echo

    # 선택 상태 저장
    declare -A selected_status
    for rp in "${RP_ORDER[@]}"; do
        selected_status[$rp]=false
    done

    # 현재 선택 인덱스
    current_index=0
    
    # 선택 루프
    while true; do
        # 화면 지우고 헤더 다시 출력
        clear
        print_header
        echo -e "${GREEN}적용할 RP를 선택하세요 (Space로 선택, Enter로 완료):${NC}"
        echo -e "${YELLOW}↑/↓: 이동, Space: 선택/해제, Enter: 완료, q: 취소${NC}"
        echo

        # RP 목록 출력
        for i in "${!RP_ORDER[@]}"; do
            local rp="${RP_ORDER[$i]}"
            local desc="${RP_FILES[$rp]}"
            
            # 현재 선택된 항목 표시
            if [ $i -eq $current_index ]; then
                echo -n -e "${CYAN}→ ${NC}"
            else
                echo -n "  "
            fi
            
            # 선택 상태 표시
            if [ "${selected_status[$rp]}" = "true" ]; then
                echo -e "[${GREEN}✓${NC}] ${YELLOW}$rp${NC} - $desc"
            else
                echo -e "[ ] ${YELLOW}$rp${NC} - $desc"
            fi
        done

        # 키 입력 받기
        read -rsn1 key
        
        case "$key" in
            "A") # 위 화살표
                ((current_index--))
                if [ $current_index -lt 0 ]; then
                    current_index=$((${#RP_ORDER[@]} - 1))
                fi
                ;;
            "B") # 아래 화살표
                ((current_index++))
                if [ $current_index -ge ${#RP_ORDER[@]} ]; then
                    current_index=0
                fi
                ;;
            " ") # 스페이스바
                local current_rp="${RP_ORDER[$current_index]}"
                if [ "${selected_status[$current_rp]}" = "true" ]; then
                    selected_status[$current_rp]=false
                else
                    selected_status[$current_rp]=true
                fi
                ;;
            "") # Enter
                # 선택된 RP들을 SELECTED_RPS에 추가
                SELECTED_RPS=()
                for rp in "${RP_ORDER[@]}"; do
                    if [ "${selected_status[$rp]}" = "true" ]; then
                        SELECTED_RPS+=("$rp")
                    fi
                done
                
                if [ ${#SELECTED_RPS[@]} -eq 0 ]; then
                    echo -e "\n${RED}최소 하나 이상의 RP를 선택해주세요.${NC}"
                    sleep 2
                else
                    echo -e "\n${GREEN}✓ ${#SELECTED_RPS[@]}개의 RP가 선택되었습니다.${NC}"
                    return
                fi
                ;;
            "q"|"Q") # 종료
                echo -e "\n${YELLOW}초기화를 취소합니다.${NC}"
                exit 0
                ;;
        esac
    done
}

# 프로젝트 디렉토리 확인
check_project_directory() {
    print_header
    echo -e "${GREEN}현재 디렉토리: ${BLUE}$(pwd)${NC}"
    echo
    read -p "이 디렉토리에 RP 시스템을 설정하시겠습니까? (y/N): " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "\n${YELLOW}다른 디렉토리로 이동한 후 다시 실행해주세요.${NC}"
        exit 0
    fi
    
    # 프로젝트 정보 수집
    echo
    read -p "프로젝트 이름을 입력하세요: " PROJECT_NAME
    read -p "프로젝트 설명을 입력하세요 (한 줄): " PROJECT_DESC
    
    # 프로젝트 타입 선택
    echo -e "\n${GREEN}프로젝트 타입을 선택하세요:${NC}"
    echo "1) 웹 애플리케이션"
    echo "2) 모바일 앱"
    echo "3) API 서버"
    echo "4) 데스크톱 애플리케이션"
    echo "5) 기타"
    read -p "선택 (1-5): " PROJECT_TYPE_NUM
    
    case $PROJECT_TYPE_NUM in
        1) PROJECT_TYPE="웹 애플리케이션" ;;
        2) PROJECT_TYPE="모바일 앱" ;;
        3) PROJECT_TYPE="API 서버" ;;
        4) PROJECT_TYPE="데스크톱 애플리케이션" ;;
        5) 
            read -p "프로젝트 타입을 입력하세요: " PROJECT_TYPE
            ;;
        *) PROJECT_TYPE="일반 프로젝트" ;;
    esac
}

# RP 파일 복사
copy_rp_files() {
    print_header
    echo -e "${GREEN}RP 파일을 복사하는 중...${NC}"
    echo
    
    # RP 파일이 있는 소스 디렉토리
    SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # .rp 디렉토리 생성
    mkdir -p .rp
    
    local total=${#SELECTED_RPS[@]}
    local current=0
    
    for rp in "${SELECTED_RPS[@]}"; do
        ((current++))
        
        # 진행 상황 표시
        echo -e "${CYAN}[$current/$total]${NC} $rp.md 복사 중..."
        
        if [ -f "$SOURCE_DIR/$rp.md" ]; then
            cp "$SOURCE_DIR/$rp.md" ".rp/$rp.md"
            echo -e "${GREEN}✓${NC} $rp.md 복사 완료"
        else
            echo -e "${RED}✗${NC} $rp.md 파일을 찾을 수 없습니다."
        fi
        
        show_progress $current $total
        echo
    done
    
    # SYSTEM 파일도 복사
    if [ -f "$SOURCE_DIR/SYSTEM.md" ]; then
        cp "$SOURCE_DIR/SYSTEM.md" ".rp/SYSTEM.md"
        echo -e "\n${GREEN}✓${NC} SYSTEM.md 복사 완료"
    fi
    
    echo -e "\n${GREEN}모든 RP 파일이 복사되었습니다.${NC}"
}

# .gitignore 업데이트
update_gitignore() {
    if [ -f .gitignore ]; then
        # .rp가 이미 있는지 확인
        if ! grep -q "^\.rp/$" .gitignore; then
            echo -e "\n# RP 자동화 시스템 파일" >> .gitignore
            echo ".rp/" >> .gitignore
            echo -e "${GREEN}✓${NC} .gitignore 업데이트 완료"
        fi
    else
        # .gitignore 생성
        echo "# RP 자동화 시스템 파일" > .gitignore
        echo ".rp/" >> .gitignore
        echo -e "${GREEN}✓${NC} .gitignore 생성 완료"
    fi
}

# 프로젝트 컨텍스트 파일 생성
create_project_context() {
    cat > .rp/PROJECT_CONTEXT.md << EOF
# 프로젝트 컨텍스트

## 프로젝트 정보
- **프로젝트명**: $PROJECT_NAME
- **설명**: $PROJECT_DESC
- **타입**: $PROJECT_TYPE
- **생성일**: $(date +%Y-%m-%d)

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

    echo -e "${GREEN}✓${NC} 프로젝트 컨텍스트 파일 생성 완료"
}

# RP 사용 가이드 생성
create_usage_guide() {
    cat > .rp/README.md << EOF
# RP 자동화 시스템 사용 가이드

## 🚀 시작하기

이 프로젝트에는 RP(Role-Playing) 자동화 시스템이 설정되어 있습니다.

### 프로젝트 정보
- **프로젝트명**: $PROJECT_NAME
- **설명**: $PROJECT_DESC
- **타입**: $PROJECT_TYPE

### 설정된 RP 목록
EOF

    for rp in "${SELECTED_RPS[@]}"; do
        echo "- **$rp**: ${RP_FILES[$rp]}" >> .rp/README.md
    done

    cat >> .rp/README.md << 'EOF'

## 📖 사용 방법

### 1. Claude Code에서 RP 활용하기

각 RP 파일과 프로젝트 컨텍스트를 함께 사용하여 작업을 수행합니다:

```bash
# 프로젝트 컨텍스트와 함께 사용 (권장)
claude-code ".rp/PROJECT_CONTEXT.md와 .rp/product-manager.md를 참고해서 
            이 프로젝트의 PRD를 작성해줘"

# 특정 RP만 사용
claude-code ".rp/frontend-developer.md를 참고해서 컴포넌트를 개발해줘"
```

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
RP들이 최신 프로젝트 상태를 반영할 수 있도록 합니다:

```bash
# PROJECT_CONTEXT.md 편집
vim .rp/PROJECT_CONTEXT.md
```

### 4. RP 파일 커스터마이징

프로젝트 특성에 맞게 RP 파일을 수정할 수 있습니다:

```bash
# 예: Backend Developer RP에 프로젝트 특화 기술 스택 추가
vim .rp/backend-developer.md
```

## 🔧 추가 설정

### RP 추가/제거

```bash
# RP 재설정
./init-rp.sh
```

### 커스텀 RP 생성

`.rp/` 디렉토리에 새로운 `.md` 파일을 추가하여 커스텀 RP를 생성할 수 있습니다.

## 📚 팁

1. **프로젝트 컨텍스트 우선**: 항상 PROJECT_CONTEXT.md를 함께 참조하도록 하세요
2. **단계별 진행**: 복잡한 작업은 여러 RP를 순차적으로 활용하세요
3. **피드백 반영**: RP의 출력물을 검토하고 필요시 컨텍스트를 업데이트하세요

## 📚 참고 자료

- [RP 자동화 시스템 전체 문서](https://github.com/jung-wan-kim/rp-automation)
- [Claude Code 사용법](https://docs.anthropic.com/claude-code)
EOF

    echo -e "${GREEN}✓${NC} 사용 가이드 생성 완료"
}

# 완료 메시지
show_completion() {
    print_header
    echo -e "${GREEN}✅ RP 자동화 시스템 설정이 완료되었습니다!${NC}"
    echo
    echo -e "${CYAN}프로젝트 정보:${NC}"
    echo -e "  • 프로젝트명: ${BLUE}$PROJECT_NAME${NC}"
    echo -e "  • 타입: ${BLUE}$PROJECT_TYPE${NC}"
    echo
    echo -e "${CYAN}설정된 내용:${NC}"
    echo -e "  • RP 파일 위치: ${BLUE}.rp/${NC}"
    echo -e "  • 선택된 RP: ${YELLOW}${#SELECTED_RPS[@]}개${NC}"
    for rp in "${SELECTED_RPS[@]}"; do
        echo -e "    - $rp"
    done
    echo
    echo -e "${CYAN}생성된 파일:${NC}"
    echo -e "  • ${YELLOW}.rp/PROJECT_CONTEXT.md${NC} - 프로젝트 컨텍스트"
    echo -e "  • ${YELLOW}.rp/README.md${NC} - 사용 가이드"
    echo -e "  • ${YELLOW}.rp/*.md${NC} - RP 파일들"
    echo
    echo -e "${CYAN}다음 단계:${NC}"
    echo -e "  1. ${YELLOW}.rp/PROJECT_CONTEXT.md${NC}를 편집하여 기술 스택과 주요 기능을 추가하세요"
    echo -e "  2. Claude Code에서 다음과 같이 사용하세요:"
    echo -e "     ${GREEN}claude-code \".rp/PROJECT_CONTEXT.md와 .rp/product-manager.md를 참고해서 PRD를 작성해줘\"${NC}"
    echo -e "  3. 필요시 RP 파일을 프로젝트에 맞게 수정하세요"
    echo
    echo -e "${GREEN}Happy Coding with RP Automation! 🚀${NC}"
}

# 메인 실행 함수
main() {
    # 프로젝트 디렉토리 확인
    check_project_directory
    
    # RP 선택
    select_rps
    
    # RP 파일 복사
    copy_rp_files
    
    # .gitignore 업데이트
    update_gitignore
    
    # 프로젝트 컨텍스트 파일 생성
    create_project_context
    
    # 사용 가이드 생성
    create_usage_guide
    
    # 완료 메시지
    show_completion
}

# 스크립트 실행
main