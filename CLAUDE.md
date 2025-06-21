# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RP(Role-Playing) 자동화 시스템 - AI 에이전트가 특정 역할(Product Manager, UX/UI Designer, Developer 등)을 수행할 수 있도록 설계된 프롬프트 템플릿 모음입니다.

## Key Architecture

### Project Structure
- **역할별 프롬프트 파일**: `*.md` 파일들이 각 IT 역할의 전문성과 업무 프로세스를 정의
- **SYSTEM.md**: 전체 RP 시스템의 통합 프롬프트
- **WORKFLOW.md**: 역할 간 협업 관계와 워크플로우 정의
- **init-rp.sh**: 다른 프로젝트에 RP 시스템을 자동으로 설치하는 스크립트
- **Trading Webhook 프로젝트**: 
  - `supabase-edge-function-ts/`: Supabase Edge Functions (Deno 런타임)
  - `vercel-edge-function-ts/`: Vercel Edge Functions (TypeScript)

### 역할 체인 시스템
프로젝트는 다음 순서로 역할이 협업합니다:
1. Product Manager → UX/UI Designer (기획)
2. UX/UI Designer → Frontend/Backend Developer (개발)
3. Developers → DevOps Engineer (배포)
4. DevOps → QA Engineer (검증)
5. QA → Technical Writer (문서화)

Project Manager는 전체 프로세스를 관리하고 조율합니다.

## Common Commands

### RP 시스템 초기화 (다른 프로젝트에 적용)
```bash
# 자동 설치 스크립트 사용
curl -fsSL https://raw.githubusercontent.com/jung-wan-kim/rp-automation/master/init-rp.sh | bash
```

### Vercel Edge Function 개발
```bash
cd vercel-edge-function-ts
npm install          # 의존성 설치
npm run dev         # 로컬 개발 서버 실행
npm run build       # TypeScript 타입 체크
npm run lint        # ESLint 실행
npm run test        # Jest 테스트 실행
npm run deploy      # Vercel에 배포
```

### Supabase Edge Function 개발
```bash
cd supabase-edge-function-ts
# Supabase CLI 필요 (Deno 런타임 사용)
supabase functions serve trading-webhook    # 로컬 실행
supabase functions deploy trading-webhook   # 배포
supabase functions logs trading-webhook     # 로그 확인
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

## Notes

- RP 시스템은 완전 자동화가 아닌 구조화된 프로세스로 효율적인 개발 지원
- Trading webhook 프로젝트는 TradingView Pro+ 계정 필요 (웹훅 기능)
- Supabase Edge Functions는 Deno 런타임 사용 (npm 대신 Deno 모듈)
- 각 역할은 독립적으로 사용하거나 체인으로 연결하여 사용 가능