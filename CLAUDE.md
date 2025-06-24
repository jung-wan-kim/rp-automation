# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

RP(Role-Playing) 자동화 시스템 - AI 에이전트가 특정 IT 역할을 수행할 수 있도록 설계된 프롬프트 템플릿 모음입니다.

## 주요 빌드 및 개발 명령어

### Vercel Edge Function (TypeScript)
```bash
# 개발 서버 실행
cd vercel-edge-function-ts
npm run dev

# 타입 체크
npm run type-check

# 린트
npm run lint

# 테스트
npm run test

# 프로덕션 배포
npm run deploy
```

### Supabase Edge Function
```bash
# Supabase 함수 배포
supabase functions deploy trading-webhook --env-file .env.local

# 로컬 실행
supabase functions serve trading-webhook --env-file .env.local

# 로그 확인
supabase functions logs trading-webhook --tail
```

### RP 초기화 스크립트
```bash
# 다른 프로젝트에 RP 시스템 설치
./init-rp.sh

# 자동 설치 (원격)
curl -fsSL https://raw.githubusercontent.com/jung-wan-kim/rp-automation/master/init-rp.sh | bash
```

## 코드 아키텍처

### 1. RP 시스템 구조
- **SYSTEM.md**: 전체 시스템 프롬프트 - 다중 역할 전환을 관리
- **역할별 .md 파일들**: 각 IT 역할의 전문성과 응답 패턴을 정의
  - product-manager.md
  - ux-ui-designer.md
  - frontend-developer.md
  - backend-developer.md
  - devops-engineer.md
  - qa-engineer.md
  - technical-writer.md
  - project-manager.md

### 2. 웹훅 핸들러 구조
- **Vercel Edge Function**: `/vercel-edge-function-ts/`
  - TypeScript 기반
  - Bearer 토큰 인증
  - Supabase 클라이언트 연동

- **Supabase Edge Function**: `/supabase-edge-function-ts/`
  - Deno 런타임
  - 자동 환경 변수 제공
  - 내장 인증 처리

### 3. 역할 간 협업 워크플로우
```
PM → UX/UI → Frontend/Backend → DevOps → QA → Technical Writer
```
- 각 역할은 명확한 책임과 산출물을 가짐
- WORKFLOW.md에 상세 협업 패턴 정의
- Project Manager는 전체 프로세스를 관리하고 조율

## 환경 설정

### 필수 환경 변수
```env
# Vercel Edge Function
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
WEBHOOK_SECRET=your_secure_webhook_secret

# Supabase Edge Function (WEBHOOK_SECRET만 필요)
WEBHOOK_SECRET=your_webhook_secret
```

## Development Workflow

### RP 시스템 활용 시
1. `.rp/` 디렉토리에 역할별 프롬프트 파일 배치
2. Claude Code에서 특정 역할 참조: `.rp/backend-developer.md를 참고해서 API를 설계해줘`
3. 여러 역할 협업: `.rp/ 디렉토리의 모든 RP를 활용해서 프로젝트를 진행해줘`
4. 역할 체인 실행: `Product Manager로 시작해서 모든 RP를 순차적으로 활용해`

### Trading Webhook 개발 시
1. TradingView Alert에서 JSON 형식으로 웹훅 데이터 전송
2. Edge Function이 데이터를 받아 Supabase에 저장
3. 환경변수 필수: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `WEBHOOK_SECRET`

## Key Implementation Details

### RP 프롬프트 구조
각 역할 프롬프트는 다음 섹션으로 구성:
- **역할 정의**: 전문성과 경력 설정
- **핵심 가치**: 해당 역할의 우선순위
- **기술 스택**: 사용하는 도구와 기술
- **업무 방식**: 구체적인 작업 프로세스
- **커뮤니케이션**: 다른 역할과의 협업 방식
- **산출물**: 생성하는 문서나 코드

### Trading Signal 데이터 구조
```typescript
interface TradingSignal {
  symbol: string;          // 거래 심볼 (예: BTCUSDT)
  action: string;          // 'buy', 'sell', 'close'
  price?: number;          // 거래 가격
  quantity?: number;       // 거래 수량
  strategy_name?: string;  // 전략 이름
  timeframe?: string;      // 시간 프레임
  indicator_values?: any;  // 지표 값들 (JSON)
  message?: string;        // 추가 메시지
  raw_payload: any;        // 원본 페이로드
}
```

### 보안 고려사항
- 모든 웹훅 요청은 `Authorization: Bearer {WEBHOOK_SECRET}` 헤더로 인증
- Supabase Row Level Security (RLS) 정책 적용 권장
- API 키는 환경변수로 관리, 절대 하드코딩 금지

## Testing Approach

### Vercel Edge Functions
- Jest를 사용한 단위 테스트
- `npm run test` 또는 `npm run test:watch`
- 테스트 파일은 `*.test.ts` 패턴

### 웹훅 로컬 테스트
```bash
curl -X POST http://localhost:3000/webhook \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_webhook_secret_key" \
  -d '{"symbol": "BTCUSDT", "action": "buy", "price": 50000}'
```

## 개발 가이드라인

1. **RP 프롬프트 수정 시**:
   - 역할의 핵심 가치와 전문성 유지
   - 응답 구조와 형식 준수
   - 다른 역할과의 협업 포인트 고려

2. **웹훅 핸들러 수정 시**:
   - TypeScript 타입 안전성 유지
   - 에러 처리 및 로깅 강화
   - Bearer 토큰 인증 필수

3. **새로운 역할 추가 시**:
   - WORKFLOW.md에 협업 관계 정의
   - init-rp.sh 스크립트에 추가
   - RP_작업_결과_요약.md 업데이트

## Notes

- RP 시스템은 완전 자동화가 아닌 구조화된 프로세스로 효율적인 개발 지원
- Trading webhook 프로젝트는 TradingView Pro+ 계정 필요 (웹훅 기능)
- Supabase Edge Functions는 Deno 런타임 사용 (npm 대신 Deno 모듈)
- 각 역할은 독립적으로 사용하거나 체인으로 연결하여 사용 가능