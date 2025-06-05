# RP(Role Play) 자동화 시스템

## 개요
이 시스템은 아이디어를 받아서 서비스 개발, 기획, 테스트까지 자동화하는 통합 개발 프로세스입니다.
각 역할(RP)은 Claude Code에서 구체적인 지침에 따라 작동하며, 협업을 통해 완전한 제품을 만들어냅니다.

## 시스템 아키텍처

### 1. 워크플로우
```
아이디어 입력
    ↓
Product Manager (요구사항 분석)
    ↓
UX/UI Designer (디자인 설계)
    ↓
Frontend/Backend Developer (구현)
    ↓
DevOps Engineer (배포 준비)
    ↓
QA Engineer (테스트)
    ↓
Technical Writer (문서화)
    ↓
Project Manager (전체 관리)
```

### 2. 역할별 담당자
- **Product Manager**: 제품 비전과 요구사항 정의
- **UX/UI Designer**: 사용자 경험과 인터페이스 설계
- **Frontend Developer**: 클라이언트 구현
- **Backend Developer**: 서버 및 API 구현
- **DevOps Engineer**: 인프라 및 배포 자동화
- **QA Engineer**: 품질 보증 및 테스트
- **Technical Writer**: 기술 문서 작성
- **Project Manager**: 프로젝트 전체 관리

### 3. 통합 규칙

#### 파일 구조
```
project-root/
├── docs/
│   ├── requirements/
│   ├── design/
│   ├── api/
│   └── user-guide/
├── frontend/
├── backend/
├── infrastructure/
├── tests/
└── .github/workflows/
```

#### 네이밍 컨벤션
- 브랜치: `feature/role-task-name`
- 커밋: `[ROLE] 작업 내용`
- 파일: `kebab-case`
- 변수/함수: `camelCase`
- 클래스/컴포넌트: `PascalCase`

#### 커뮤니케이션 프로토콜
1. 각 RP는 작업 시작 시 `## 작업 시작: [역할명]` 로그 남기기
2. 다른 RP에게 전달 시 `## 인계: [보내는 역할] → [받는 역할]` 사용
3. 이슈 발생 시 `## 이슈: [역할명] - [이슈 내용]` 기록

### 4. 자동화 스크립트

#### 프로젝트 초기화
```bash
#!/bin/bash
# init-project.sh
PROJECT_NAME=$1
mkdir -p $PROJECT_NAME/{docs,frontend,backend,infrastructure,tests}
cd $PROJECT_NAME
git init
echo "# $PROJECT_NAME" > README.md
```

#### RP 체인 실행
```bash
#!/bin/bash
# run-rp-chain.sh
IDEA=$1
echo "Starting RP Chain for: $IDEA"
claude-code --rp product-manager --input "$IDEA"
claude-code --rp ux-ui-designer --continue
claude-code --rp frontend-developer --continue
claude-code --rp backend-developer --continue
claude-code --rp devops-engineer --continue
claude-code --rp qa-engineer --continue
claude-code --rp technical-writer --continue
claude-code --rp project-manager --finalize
```

### 5. 품질 기준

#### 코드 품질
- 테스트 커버리지: 80% 이상
- 린트 오류: 0개
- 타입 안정성: 100%
- 성능: 응답시간 200ms 이하

#### 문서 품질
- 모든 API 엔드포인트 문서화
- 사용자 가이드 완성도 100%
- 코드 주석 coverage 70% 이상

### 6. 모니터링 및 피드백

#### 진행 상황 추적
```yaml
status:
  product-manager: ✓ completed
  ux-ui-designer: ⚡ in-progress
  frontend-developer: ⏳ waiting
  backend-developer: ⏳ waiting
  devops-engineer: ⏳ waiting
  qa-engineer: ⏳ waiting
  technical-writer: ⏳ waiting
  project-manager: ⚡ monitoring
```

#### 피드백 루프
1. 각 단계 완료 시 자동 검증
2. 이슈 발생 시 해당 RP로 롤백
3. 전체 완료 후 통합 테스트
4. 사용자 피드백 수집 및 반영

## 사용 방법

### 1. 단일 RP 실행
```bash
claude-code --rp [role-name] --task "[task description]"
```

### 2. 전체 체인 실행
```bash
claude-code --rp-chain --idea "[your idea]"
```

### 3. 특정 단계부터 재개
```bash
claude-code --rp-chain --resume-from [role-name]
```

## 주의사항
- 각 RP는 독립적으로 작동하지만 의존성을 고려해야 함
- 산출물은 다음 RP가 이해할 수 있는 형식으로 작성
- 에러 발생 시 즉시 Project Manager에게 보고
- 모든 코드는 즉시 커밋되어야 함