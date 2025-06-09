# Supabase Edge Functions - TradingView Webhook Handler

Supabase Edge Functions를 사용하여 TradingView 웹훅을 처리하는 TypeScript 함수입니다.

## 특징

- **Supabase 내장 환경**: 별도의 환경 변수 설정 불필요
- **자동 인증**: Supabase 클라이언트가 자동으로 인증 처리
- **Deno 런타임**: 빠르고 안전한 실행 환경
- **TypeScript 지원**: 타입 안전한 코드

## Supabase Edge Functions의 장점

1. **환경 변수 자동 제공**
   - `SUPABASE_URL`: 자동으로 제공됨
   - `SUPABASE_ANON_KEY`: 자동으로 제공됨
   - 추가 환경 변수만 설정하면 됨

2. **통합된 인증**
   - Supabase Auth와 자동 통합
   - RLS(Row Level Security) 정책 적용 가능

3. **간편한 배포**
   - Supabase CLI로 한 번에 배포

## 설치 및 설정

### 1. Supabase CLI 설치

```bash
# npm
npm install -g supabase

# Homebrew (macOS)
brew install supabase/tap/supabase
```

### 2. 프로젝트 초기화

```bash
# Supabase 프로젝트에 연결
supabase login
supabase link --project-ref your-project-ref
```

### 3. 함수 배포

```bash
# 단일 함수 배포
supabase functions deploy trading-webhook

# 환경 변수와 함께 배포 (WEBHOOK_SECRET 등)
supabase functions deploy trading-webhook --env-file .env.local
```

## 환경 변수

Supabase Edge Functions에서는 다음 변수가 자동으로 제공됩니다:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY` (서버 사이드 작업용)

추가로 필요한 환경 변수만 설정:

```bash
# .env.local 파일
WEBHOOK_SECRET=your_webhook_secret
```

배포 시 환경 변수 설정:

```bash
supabase secrets set WEBHOOK_SECRET=your_webhook_secret
```

## 사용 방법

### 엔드포인트 URL

```
https://[PROJECT_REF].supabase.co/functions/v1/trading-webhook
```

### TradingView Alert 설정

1. Webhook URL: `https://[PROJECT_REF].supabase.co/functions/v1/trading-webhook`
2. Message 형식:

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
  }
}
```

3. Authorization 헤더 (선택적):
```
Authorization: Bearer your_webhook_secret
```

## 로컬 개발

### 1. 로컬 실행

```bash
# 함수 실행
supabase functions serve trading-webhook --env-file .env.local

# 다른 터미널에서 테스트
curl -X POST http://localhost:54321/functions/v1/trading-webhook \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_webhook_secret" \
  -d '{
    "symbol": "BTCUSDT",
    "action": "buy",
    "price": 50000,
    "strategy": "MA_Cross"
  }'
```

### 2. 로그 확인

```bash
# 실시간 로그
supabase functions logs trading-webhook --tail

# 특정 시간 범위
supabase functions logs trading-webhook --since 1h
```

## 보안 설정

### 1. CORS 설정
함수에 이미 CORS 헤더가 포함되어 있습니다.

### 2. 인증 옵션

**옵션 1: Bearer Token (현재 구현)**
```typescript
const webhookSecret = Deno.env.get('WEBHOOK_SECRET')
if (authHeader !== `Bearer ${webhookSecret}`) {
  // 거부
}
```

**옵션 2: Supabase Auth**
```typescript
// JWT 토큰 검증
const { data: { user } } = await supabaseClient.auth.getUser()
if (!user) {
  // 거부
}
```

### 3. RLS 정책 예시

```sql
-- 인증된 사용자만 자신의 시그널 읽기
CREATE POLICY "Users can read own signals" ON trading_signals
  FOR SELECT USING (auth.uid() = user_id);

-- 서비스 역할만 삽입 가능
CREATE POLICY "Service role can insert" ON trading_signals
  FOR INSERT WITH CHECK (auth.role() = 'service_role');
```

## 모니터링

### Supabase 대시보드
1. Functions 탭에서 실행 통계 확인
2. Logs에서 실시간 로그 확인
3. Metrics에서 성능 지표 확인

### 알림 설정
```sql
-- 실시간 알림을 위한 트리거
CREATE OR REPLACE FUNCTION notify_new_signal()
RETURNS trigger AS $$
BEGIN
  PERFORM pg_notify('new_signal', row_to_json(NEW)::text);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_new_signal
AFTER INSERT ON trading_signals
FOR EACH ROW EXECUTE FUNCTION notify_new_signal();
```

## 문제 해결

### 일반적인 오류

1. **500 Internal Server Error**
   - 로그 확인: `supabase functions logs trading-webhook`
   - 환경 변수 확인: `supabase secrets list`

2. **401 Unauthorized**
   - WEBHOOK_SECRET 확인
   - Authorization 헤더 형식 확인

3. **CORS 오류**
   - 브라우저에서 직접 호출 시 발생
   - TradingView는 서버 사이드에서 호출하므로 문제없음

## 프로젝트 구조

```
supabase-edge-function-ts/
├── functions/
│   └── trading-webhook/
│       └── index.ts       # 메인 함수
├── .env.local            # 로컬 환경 변수
└── README.md             # 이 파일
```

## 추가 기능 아이디어

1. **다중 전략 지원**
```typescript
// 전략별 라우팅
switch (webhookData.strategy) {
  case 'MA_Cross':
    // MA 전략 처리
    break
  case 'RSI_Oversold':
    // RSI 전략 처리
    break
}
```

2. **실시간 알림**
```typescript
// Telegram, Discord 등으로 알림 전송
await sendNotification(signalData)
```

3. **자동 거래 실행**
```typescript
// 거래소 API 연동
if (webhookData.action === 'buy') {
  await executeTrade(webhookData)
}
```