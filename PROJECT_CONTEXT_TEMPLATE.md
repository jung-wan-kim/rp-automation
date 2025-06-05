# 프로젝트 컨텍스트 템플릿

이 파일은 RP 시스템이 프로젝트를 이해하고 적절한 작업을 수행할 수 있도록 
프로젝트 정보를 제공하는 템플릿입니다.

## 프로젝트 정보
- **프로젝트명**: [프로젝트 이름]
- **설명**: [프로젝트에 대한 간단한 설명]
- **타입**: [웹 애플리케이션 / 모바일 앱 / API 서버 / 데스크톱 애플리케이션 / 기타]
- **생성일**: [YYYY-MM-DD]
- **현재 단계**: [계획 / 개발 / 테스트 / 배포 / 운영]

## 프로젝트 구조
```
프로젝트-루트/
├── src/           # 소스 코드
├── tests/         # 테스트 코드
├── docs/          # 문서
└── ...
```

## 기술 스택
### Frontend
- **프레임워크**: [React / Vue / Angular / Next.js / 기타]
- **언어**: [TypeScript / JavaScript]
- **스타일링**: [CSS / SASS / Styled-components / Tailwind CSS]
- **상태관리**: [Redux / MobX / Zustand / Context API]

### Backend
- **언어**: [Node.js / Python / Java / Go / 기타]
- **프레임워크**: [Express / FastAPI / Spring Boot / Gin]
- **API 스타일**: [REST / GraphQL / gRPC]
- **ORM/ODM**: [Prisma / TypeORM / SQLAlchemy / Mongoose]

### Database
- **주 데이터베이스**: [PostgreSQL / MySQL / MongoDB / Redis]
- **캐시**: [Redis / Memcached]
- **검색엔진**: [Elasticsearch / Algolia]

### Infrastructure
- **클라우드**: [AWS / GCP / Azure / 온프레미스]
- **컨테이너**: [Docker / Kubernetes]
- **CI/CD**: [GitHub Actions / Jenkins / GitLab CI]
- **모니터링**: [Prometheus / Grafana / DataDog]

## 주요 기능
1. **핵심 기능 1**: [설명]
2. **핵심 기능 2**: [설명]
3. **핵심 기능 3**: [설명]

## 개발 가이드라인

### 코딩 컨벤션
- **네이밍 규칙**: [camelCase / snake_case / PascalCase]
- **들여쓰기**: [2 spaces / 4 spaces / tabs]
- **최대 줄 길이**: [80 / 100 / 120 characters]
- **파일 구조**: [feature-based / layer-based]

### 브랜치 전략
- **main/master**: 프로덕션 브랜치
- **develop**: 개발 브랜치
- **feature/**: 기능 개발 브랜치
- **hotfix/**: 긴급 수정 브랜치

### 커밋 규칙
```
type: subject

body (optional)

footer (optional)
```

**Type**:
- feat: 새로운 기능
- fix: 버그 수정
- docs: 문서 수정
- style: 코드 포맷팅
- refactor: 코드 리팩토링
- test: 테스트 추가
- chore: 빌드 업무 수정

## API 엔드포인트 (해당되는 경우)
### 인증
- `POST /api/auth/login` - 로그인
- `POST /api/auth/register` - 회원가입
- `POST /api/auth/logout` - 로그아웃

### 리소스
- `GET /api/resources` - 목록 조회
- `GET /api/resources/:id` - 상세 조회
- `POST /api/resources` - 생성
- `PUT /api/resources/:id` - 수정
- `DELETE /api/resources/:id` - 삭제

## 환경 설정
### 개발 환경
```bash
# 환경 변수 예시
DATABASE_URL=postgresql://user:password@localhost:5432/dbname
API_KEY=your-api-key
NODE_ENV=development
```

### 로컬 실행 방법
```bash
# 의존성 설치
npm install  # 또는 yarn install

# 개발 서버 실행
npm run dev  # 또는 yarn dev

# 테스트 실행
npm test     # 또는 yarn test
```

## 현재 이슈 및 TODO
- [ ] 이슈 1: [설명]
- [ ] 이슈 2: [설명]
- [ ] TODO 1: [설명]
- [ ] TODO 2: [설명]

## 참고 문서
- [프로젝트 위키](링크)
- [API 문서](링크)
- [디자인 시스템](링크)

## RP 활용 가이드

### 프로젝트 특화 지시사항
이 프로젝트에서 RP를 활용할 때 주의사항:
1. 모든 코드는 위에 명시된 코딩 컨벤션을 따라야 합니다
2. 새로운 기능은 feature 브랜치에서 개발됩니다
3. 기존 기술 스택을 우선적으로 활용합니다
4. 테스트 코드 작성은 필수입니다

### 예시 사용법
```bash
# Backend Developer RP로 새 API 엔드포인트 추가
claude-code ".rp/PROJECT_CONTEXT.md와 .rp/backend-developer.md를 참고해서 
            사용자 프로필 API를 추가해줘"

# Frontend Developer RP로 컴포넌트 개발
claude-code ".rp/PROJECT_CONTEXT.md와 .rp/frontend-developer.md를 참고해서 
            사용자 프로필 페이지를 만들어줘"

# 전체 팀 협업 시뮬레이션
claude-code ".rp/PROJECT_CONTEXT.md를 기반으로 모든 RP를 활용해서 
            사용자 프로필 기능을 전체적으로 구현해줘"
```