# TradingView Webhook Handler for Vercel (TypeScript)

TypeScript로 작성된 TradingView 웹훅을 처리하고 Supabase에 저장하는 Vercel Edge Function입니다.

## 기능

- TypeScript로 작성된 타입 안전한 코드
- Vercel Edge Function으로 빠른 응답 시간
- Supabase 데이터베이스 연동
- 웹훅 데이터 검증 및 변환
- Bearer 토큰 인증
- 상세한 에러 처리

## 설치

```bash
# 의존성 설치
npm install

# 또는 yarn 사용
yarn install
```

## 환경 변수 설정

1. `.env.example` 파일을 `.env.local`로 복사:

```bash
cp .env.example .env.local
```

2. `.env.local` 파일을 편집하여 실제 값으로 변경:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
WEBHOOK_SECRET=your_secure_webhook_secret
```

3. Vercel CLI를 사용한 환경 변수 설정:

```bash
vercel env add SUPABASE_URL
vercel env add SUPABASE_ANON_KEY
vercel env add WEBHOOK_SECRET
```

## 개발

로컬 개발 서버 실행:

```bash
npm run dev
# 또는
vercel dev
```

타입 체크:

```bash
npm run type-check
```

## 배포

```bash
# Vercel에 배포
npm run deploy

# 또는 Vercel CLI 직접 사용
vercel --prod
```

## 사용 방법

### TradingView Alert 설정

1. TradingView에서 Alert 생성
2. Webhook URL 설정: `https://your-domain.vercel.app/api/webhook`
3. Message 형식:

```json
{
  "symbol": "{{ticker}}",
  "action": "buy",
  "price": {{close}},
  "quantity": 1,
  "strategy": "MA_Cross",
  "timeframe": "{{interval}}",
  "indicators": {
    "rsi": {{plot_0}},
    "macd": {{plot_1}}
  },
  "message": "Golden cross detected"
}
```

4. Authorization 헤더 추가 (Pro+ 이상):
```
Authorization: Bearer your_webhook_secret
```

### 테스트

cURL을 사용한 테스트:

```bash
curl -X POST https://your-domain.vercel.app/api/webhook \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_webhook_secret" \
  -d '{
    "symbol": "BTCUSDT",
    "action": "buy",
    "price": 50000,
    "strategy": "MA_Cross",
    "timeframe": "1h"
  }'
```

## 프로젝트 구조

```
vercel-edge-function-ts/
├── api/
│   └── webhook.ts          # 메인 웹훅 핸들러
├── types/
│   └── index.ts           # TypeScript 타입 정의
├── package.json           # 프로젝트 설정
├── tsconfig.json          # TypeScript 설정
├── vercel.json            # Vercel 설정
├── .env.example           # 환경 변수 예시
└── README.md              # 이 파일
```

## 타입 정의

주요 타입들은 `types/index.ts`에 정의되어 있습니다:

- `TradingViewWebhookPayload`: TradingView에서 전송하는 데이터 타입
- `TradingSignalDB`: Supabase 데이터베이스 스키마 타입
- `ApiResponse<T>`: API 응답 타입
- `WebhookError`: 커스텀 에러 클래스

## 보안 고려사항

1. **환경 변수 보호**: 절대 API 키를 코드에 하드코딩하지 마세요
2. **Bearer 토큰 인증**: `WEBHOOK_SECRET`을 설정하여 인증된 요청만 처리
3. **데이터 검증**: 모든 입력 데이터는 검증 후 처리
4. **HTTPS 사용**: Vercel은 자동으로 HTTPS를 제공합니다

## 문제 해결

### 일반적인 오류

1. **401 Unauthorized**: Authorization 헤더와 WEBHOOK_SECRET 확인
2. **400 Invalid data**: 웹훅 페이로드 형식 확인
3. **500 Database error**: Supabase 연결 정보 확인

### 디버깅

Vercel 대시보드에서 Function 로그를 확인하거나:

```bash
vercel logs
```

## 라이선스

MIT