# RP(Role Play) 자동화 시스템 v2 - 실행 가능한 버전

## 개요
Claude Code의 실제 기능을 활용한 현실적인 RP 자동화 시스템입니다.

## 실행 가능한 워크플로우

### 1. Context7 MCP를 활용한 RP 체인

#### 초기 설정
```bash
# 1. 프로젝트 초기화
mkdir -p ~/Project/Claude/my-service
cd ~/Project/Claude/my-service

# 2. RP 컨텍스트 파일 생성
mkdir -p .rp-contexts
```

#### 각 RP별 CLAUDE.md 파일 생성
```bash
# Product Manager 컨텍스트
cat > .rp-contexts/product-manager.md << 'EOF'
# Product Manager Role
- 나는 제품 기획자로서 작동한다
- 아이디어를 받으면 PRD(Product Requirements Document)를 작성한다
- 산출물은 docs/requirements/PRD.md에 저장한다
- 작업 완료 후 context7에 "PM 작업 완료" 태그로 저장한다
EOF

# UX/UI Designer 컨텍스트
cat > .rp-contexts/ux-ui-designer.md << 'EOF'
# UX/UI Designer Role
- 나는 UX/UI 디자이너로서 작동한다
- PRD를 읽고 디자인 시스템을 설계한다
- Figma MCP를 사용해 실제 디자인을 생성한다
- 산출물은 docs/design/에 저장한다
- 작업 완료 후 context7에 "Design 작업 완료" 태그로 저장한다
EOF
```

### 2. 실제 실행 방법

#### Step 1: Product Manager 역할 실행
```bash
# Claude Code 실행
claude

# RP 활성화
@.rp-contexts/product-manager.md
use context7

# 아이디어 전달
"온라인 중고서점 플랫폼을 만들고 싶어. 사용자가 책을 사고팔 수 있는 서비스야."
```

#### Step 2: 컨텍스트 전달
```bash
# 이전 작업 결과 조회
mcp__context7__context7_search --query "PM 작업 완료"

# 다음 RP로 전환
@.rp-contexts/ux-ui-designer.md
use context7

# 이전 단계 결과물 읽기
Read docs/requirements/PRD.md
```

### 3. 반자동화 스크립트

#### RP 체인 헬퍼 스크립트
```bash
#!/bin/bash
# rp-helper.sh

function switch_rp() {
    local role=$1
    echo "Switching to $role..."
    echo "@.rp-contexts/$role.md" > .current-rp
    echo "use context7" >> .current-rp
}

function save_checkpoint() {
    local role=$1
    local tag=$2
    echo "Saving checkpoint: $tag"
    # Context7에 저장하는 명령 실행
}

# 사용 예
switch_rp "product-manager"
# 작업 수행...
save_checkpoint "product-manager" "PRD 완료"
```

### 4. 실용적인 통합 방법

#### A. TodoWrite를 활용한 작업 관리
```markdown
# 각 RP 시작 시
TodoWrite:
- [ ] PRD 작성
- [ ] 사용자 스토리 정의
- [ ] 기술 요구사항 분석
- [ ] Context7에 결과 저장
```

#### B. Git을 활용한 산출물 관리
```bash
# 각 RP 작업 완료 시
git add .
git commit -m "[PM] PRD 작성 완료"
git tag "rp-pm-complete"
```

#### C. 실제 실행 예제
```bash
# 1. PM 역할로 시작
claude
> @.rp-contexts/product-manager.md
> "중고서점 플랫폼 아이디어가 있어"

# 2. Designer 역할로 전환
> @.rp-contexts/ux-ui-designer.md
> Read docs/requirements/PRD.md
> mcp__TalkToFigma__create_frame...

# 3. Developer 역할로 전환
> @.rp-contexts/frontend-developer.md
> 이전 디자인을 기반으로 Next.js 앱 생성
```

### 5. 한계와 해결책

#### 한계점
1. 완전 자동화 불가 - 사용자 개입 필요
2. 컨텍스트 크기 제한
3. MCP 도구 간 직접 통신 불가

#### 해결책
1. 체크포인트 시스템으로 단계별 저장
2. 중요 정보만 Context7에 저장
3. 파일 시스템과 Git을 통한 데이터 공유

## 결론
이 방식은 Claude Code의 실제 기능을 활용하여 RP 체인을 구현하는 현실적인 방법입니다.
완전 자동화는 아니지만, 구조화된 프로세스로 효율적인 개발이 가능합니다.