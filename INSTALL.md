# RP 자동화 시스템 설치 가이드

## 🚀 빠른 시작

### 1. 스크립트 다운로드 및 실행

```bash
# 방법 1: curl을 사용한 설치
curl -fsSL https://raw.githubusercontent.com/jung-wan-kim/rp-automation/master/init-rp.sh | bash

# 방법 2: git clone 후 실행
git clone https://github.com/jung-wan-kim/rp-automation.git
cd rp-automation
./init-rp.sh
```

### 2. 프로젝트에 직접 복사하여 사용

```bash
# 프로젝트 디렉토리로 이동
cd your-project

# init-rp.sh와 RP 파일들을 복사
cp /path/to/rp-automation/init-rp.sh .
cp /path/to/rp-automation/*.md .

# 스크립트 실행
./init-rp.sh
```

## 📋 스크립트 기능

### 주요 기능

1. **전체 RP 적용**: 모든 8개의 RP를 한 번에 설정
2. **개별 RP 선택**: 필요한 RP만 선택하여 설정
3. **인터랙티브 UI**: 화살표 키와 스페이스바로 쉽게 선택
4. **자동 설정**: .gitignore 업데이트, 사용 가이드 생성

### 선택 가능한 RP 목록

- **product-manager**: Product Manager - 제품의 비전을 정의하고 요구사항을 구체화
- **ux-ui-designer**: UX/UI Designer - 사용자 경험을 최적화하고 인터페이스를 설계
- **frontend-developer**: Frontend Developer - 사용자 인터페이스를 구현
- **backend-developer**: Backend Developer - 서버 애플리케이션과 비즈니스 로직을 구현
- **devops-engineer**: DevOps Engineer - 빌드, 배포, 운영을 자동화
- **qa-engineer**: QA Engineer - 소프트웨어 품질을 보장
- **technical-writer**: Technical Writer - 기술 문서를 작성
- **project-manager**: Project Manager - 프로젝트 전체를 관리하고 조율

## 🎮 사용 방법

### 1. 전체 RP 적용 (권장)

```bash
./init-rp.sh
# 옵션 1 선택
```

### 2. 개별 RP 선택

```bash
./init-rp.sh
# 옵션 2 선택
# 화살표 키로 이동, 스페이스바로 선택/해제, Enter로 완료
```

### 3. 설정 후 디렉토리 구조

```
your-project/
├── .rp/                    # RP 파일들이 저장되는 디렉토리
│   ├── product-manager.md
│   ├── ux-ui-designer.md
│   ├── frontend-developer.md
│   ├── backend-developer.md
│   ├── devops-engineer.md
│   ├── qa-engineer.md
│   ├── technical-writer.md
│   ├── project-manager.md
│   ├── SYSTEM.md          # 전체 시스템 프롬프트
│   └── README.md          # 사용 가이드
├── .gitignore             # .rp/ 디렉토리 제외 설정
└── init-rp.sh             # 초기화 스크립트 (선택사항)
```

## 🔧 고급 사용법

### RP 재설정

```bash
# 기존 설정을 변경하고 싶을 때
./init-rp.sh
```

### 커스텀 RP 추가

```bash
# .rp 디렉토리에 새로운 RP 파일 추가
echo "# Custom RP" > .rp/custom-role.md
```

### 스크립트 커스터마이징

`init-rp.sh` 파일을 수정하여 프로젝트에 맞게 커스터마이징할 수 있습니다:

```bash
# RP_FILES 배열에 새로운 RP 추가
declare -A RP_FILES=(
    ["custom-role"]="Custom Role - 프로젝트 특화 역할"
    # ...
)

# RP_ORDER 배열에도 추가
RP_ORDER=(
    # ...
    "custom-role"
)
```

## 📝 Claude Code와 함께 사용하기

### 1. 특정 RP로 작업 시작

```bash
# Product Manager로 PRD 작성
claude-code ".rp/product-manager.md를 참고해서 이 프로젝트의 PRD를 작성해줘"

# Frontend Developer로 컴포넌트 개발
claude-code ".rp/frontend-developer.md를 참고해서 로그인 컴포넌트를 만들어줘"
```

### 2. 여러 RP 협업

```bash
# Backend와 Frontend 협업
claude-code ".rp/backend-developer.md와 .rp/frontend-developer.md를 참고해서 
            API 설계와 프론트엔드 통합을 진행해줘"
```

### 3. 전체 워크플로우 실행

```bash
# 전체 개발 프로세스 진행
claude-code ".rp/ 디렉토리의 모든 RP를 순서대로 활용해서 
            MVP 개발을 진행해줘"
```

## ❓ 문제 해결

### 권한 오류

```bash
# 실행 권한이 없을 때
chmod +x init-rp.sh
```

### 파일을 찾을 수 없음

```bash
# RP 파일들이 같은 디렉토리에 있는지 확인
ls *.md
```

### 화살표 키가 작동하지 않음

일부 터미널에서는 화살표 키 대신 다음 키를 사용하세요:
- `j`: 아래로 이동
- `k`: 위로 이동
- `space`: 선택/해제
- `enter`: 완료

## 🤝 기여하기

이 프로젝트에 기여하고 싶으시다면:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-rp`)
3. Commit your changes (`git commit -m 'Add some amazing RP'`)
4. Push to the branch (`git push origin feature/amazing-rp`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다.