# TradingView 웹훅 시그널을 Supabase에 저장하는 가이드

이 가이드는 TradingView의 웹훅(Webhook) 시그널을 받아서 Supabase 데이터베이스에 저장하는 방법을 설명합니다.

## 목차
1. [개요](#개요)
2. [필요 사항](#필요-사항)
3. [Supabase 설정](#supabase-설정)
4. [웹훅 엔드포인트 구현](#웹훅-엔드포인트-구현)
5. [TradingView Alert 설정](#tradingview-alert-설정)
6. [테스트 및 디버깅](#테스트-및-디버깅)

## 개요

TradingView에서 발생하는 트레이딩 시그널을 웹훅을 통해 전송하고, 이를 Supabase 데이터베이스에 자동으로 저장하는 시스템을 구축합니다.

### 작동 흐름
1. TradingView에서 조건에 따른 Alert 발생
2. Alert가 웹훅을 통해 서버로 전송
3. 서버가 데이터를 처리하여 Supabase에 저장
4. 저장된 데이터를 활용한 추가 작업 수행

## 필요 사항

- TradingView Pro 이상 계정 (웹훅 기능 사용)
- Supabase 계정
- 웹 서버 (Vercel, Netlify, 또는 자체 서버)
- Node.js 환경

## Supabase 설정

### 1. Supabase 프로젝트 생성

1. [Supabase](https://supabase.com) 접속 후 로그인
2. "New Project" 클릭하여 새 프로젝트 생성
3. 프로젝트 이름과 데이터베이스 비밀번호 설정

### 2. 데이터베이스 테이블 생성

SQL Editor에서 다음 쿼리를 실행하여 시그널 저장 테이블을 생성합니다:

```sql
-- 트레이딩 시그널 테이블
CREATE TABLE trading_signals (
    id BIGSERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    symbol VARCHAR(50) NOT NULL,
    action VARCHAR(20) NOT NULL, -- 'buy', 'sell', 'close'
    price DECIMAL(20, 8),
    quantity DECIMAL(20, 8),
    strategy_name VARCHAR(100),
    timeframe VARCHAR(20),
    indicator_values JSONB,
    message TEXT,
    raw_payload JSONB
);

-- 인덱스 생성 (성능 향상)
CREATE INDEX idx_trading_signals_symbol ON trading_signals(symbol);
CREATE INDEX idx_trading_signals_created_at ON trading_signals(created_at DESC);
CREATE INDEX idx_trading_signals_action ON trading_signals(action);
```

### 3. API 키 획득

1. 프로젝트 Settings > API 메뉴 접속
2. `URL`과 `anon public` 키 복사
3. 안전한 곳에 저장

## 웹훅 엔드포인트 구현

### 옵션 1: Vercel Edge Functions 사용

#### 1. 프로젝트 초기화

```bash
mkdir tradingview-webhook
cd tradingview-webhook
npm init -y
npm install @supabase/supabase-js
```

#### 2. 환경 변수 설정

`.env` 파일 생성:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
WEBHOOK_SECRET=your_webhook_secret_key
```

#### 3. 웹훅 핸들러 구현

`api/webhook.js` 파일 생성:

```javascript
import { createClient } from '@supabase/supabase-js';

// Supabase 클라이언트 초기화
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY
);

export default async function handler(req, res) {
  // POST 요청만 허용
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  // 보안 검증 (옵션)
  const authHeader = req.headers['authorization'];
  if (authHeader !== `Bearer ${process.env.WEBHOOK_SECRET}`) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  try {
    // TradingView에서 전송된 데이터
    const webhookData = req.body;
    
    // 데이터 파싱 및 검증
    const signalData = parseWebhookData(webhookData);
    
    // Supabase에 데이터 저장
    const { data, error } = await supabase
      .from('trading_signals')
      .insert([signalData]);

    if (error) {
      console.error('Supabase error:', error);
      return res.status(500).json({ error: 'Failed to save signal' });
    }

    // 성공 응답
    return res.status(200).json({ 
      success: true, 
      id: data[0].id 
    });

  } catch (error) {
    console.error('Webhook error:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

// 웹훅 데이터 파싱 함수
function parseWebhookData(webhookData) {
  // TradingView Alert 메시지 포맷에 따라 파싱
  // 예시 포맷: {"symbol":"BTCUSDT","action":"buy","price":50000,"strategy":"MA_Cross"}
  
  return {
    symbol: webhookData.symbol || 'UNKNOWN',
    action: webhookData.action || 'unknown',
    price: parseFloat(webhookData.price) || null,
    quantity: parseFloat(webhookData.quantity) || null,
    strategy_name: webhookData.strategy || null,
    timeframe: webhookData.timeframe || null,
    indicator_values: webhookData.indicators || {},
    message: webhookData.message || '',
    raw_payload: webhookData
  };
}
```

### 옵션 2: Express.js 서버 사용

#### 1. Express 서버 설정

```bash
npm install express @supabase/supabase-js dotenv cors body-parser
```

#### 2. 서버 구현

`server.js` 파일 생성:

```javascript
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { createClient } = require('@supabase/supabase-js');

const app = express();
const PORT = process.env.PORT || 3000;

// Supabase 클라이언트
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY
);

// 미들웨어
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.text());

// 웹훅 엔드포인트
app.post('/webhook', async (req, res) => {
  // 인증 검증
  const authHeader = req.headers['authorization'];
  if (authHeader !== `Bearer ${process.env.WEBHOOK_SECRET}`) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  try {
    let webhookData;
    
    // Content-Type에 따른 처리
    if (typeof req.body === 'string') {
      // Pine Script에서 직접 문자열로 전송한 경우
      webhookData = JSON.parse(req.body);
    } else {
      webhookData = req.body;
    }

    // 데이터 파싱
    const signalData = {
      symbol: webhookData.symbol,
      action: webhookData.action,
      price: parseFloat(webhookData.price) || null,
      quantity: parseFloat(webhookData.quantity) || null,
      strategy_name: webhookData.strategy,
      timeframe: webhookData.timeframe,
      indicator_values: webhookData.indicators || {},
      message: webhookData.message || '',
      raw_payload: webhookData
    };

    // Supabase에 저장
    const { data, error } = await supabase
      .from('trading_signals')
      .insert([signalData])
      .select();

    if (error) {
      console.error('Supabase error:', error);
      return res.status(500).json({ error: 'Failed to save signal' });
    }

    console.log('Signal saved:', data[0]);
    res.status(200).json({ success: true, id: data[0].id });

  } catch (error) {
    console.error('Webhook error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 헬스 체크
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

## TradingView Alert 설정

### 1. Pine Script에 Alert 조건 추가

```pinescript
//@version=5
indicator("웹훅 시그널 예시", overlay=true)

// 이동평균선 계산
ma20 = ta.sma(close, 20)
ma50 = ta.sma(close, 50)

// 매수/매도 조건
buySignal = ta.crossover(ma20, ma50)
sellSignal = ta.crossunder(ma20, ma50)

// Alert 조건 설정
if buySignal
    alert('{"symbol":"' + syminfo.ticker + '","action":"buy","price":' + str.tostring(close) + ',"strategy":"MA_Cross","timeframe":"' + timeframe.period + '"}', alert.freq_once_per_bar)

if sellSignal
    alert('{"symbol":"' + syminfo.ticker + '","action":"sell","price":' + str.tostring(close) + ',"strategy":"MA_Cross","timeframe":"' + timeframe.period + '"}', alert.freq_once_per_bar)

// 시각화
plot(ma20, color=color.blue, linewidth=2)
plot(ma50, color=color.red, linewidth=2)
plotshape(buySignal, style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(sellSignal, style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)
```

### 2. Alert 생성

1. 차트에서 Alert 버튼 클릭 (시계 아이콘)
2. Condition 설정
3. Alert actions에서 "Webhook URL" 체크
4. 웹훅 URL 입력: `https://your-domain.com/webhook`
5. Message 필드에 JSON 형식 데이터 입력:

```json
{
  "symbol": "{{ticker}}",
  "action": "{{strategy.order.action}}",
  "price": {{close}},
  "volume": {{volume}},
  "time": "{{time}}",
  "strategy": "Your Strategy Name",
  "timeframe": "{{interval}}",
  "indicators": {
    "rsi": {{plot_0}},
    "macd": {{plot_1}}
  }
}
```

### 3. 웹훅 헤더 설정 (Pro+ 이상)

Authorization 헤더 추가:
```
Authorization: Bearer your_webhook_secret_key
```

## 테스트 및 디버깅

### 1. 로컬 테스트

cURL을 사용한 테스트:

```bash
curl -X POST http://localhost:3000/webhook \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_webhook_secret_key" \
  -d '{
    "symbol": "BTCUSDT",
    "action": "buy",
    "price": 50000,
    "strategy": "MA_Cross",
    "timeframe": "1h"
  }'
```

### 2. 로그 모니터링

서버에 로깅 추가:

```javascript
// 요청 로깅 미들웨어
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  if (req.method === 'POST') {
    console.log('Headers:', req.headers);
    console.log('Body:', req.body);
  }
  next();
});
```

### 3. Supabase 데이터 확인

```javascript
// 최근 시그널 조회
async function getRecentSignals() {
  const { data, error } = await supabase
    .from('trading_signals')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(10);
    
  if (error) {
    console.error('Error:', error);
  } else {
    console.log('Recent signals:', data);
  }
}
```

### 4. 에러 처리

일반적인 문제와 해결 방법:

1. **401 Unauthorized**: Authorization 헤더 확인
2. **500 Internal Server Error**: 서버 로그 확인
3. **데이터 누락**: TradingView Alert 메시지 포맷 확인
4. **Supabase 연결 실패**: API 키와 URL 확인

## 고급 기능

### 1. 실시간 알림

```javascript
// Supabase Realtime 구독
const subscription = supabase
  .channel('trading_signals')
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'public',
    table: 'trading_signals'
  }, (payload) => {
    console.log('New signal:', payload.new);
    // 추가 작업 수행 (이메일, 텔레그램 알림 등)
  })
  .subscribe();
```

### 2. 데이터 검증 및 필터링

```javascript
function validateSignal(data) {
  // 필수 필드 확인
  if (!data.symbol || !data.action) {
    throw new Error('Missing required fields');
  }
  
  // 액션 타입 검증
  const validActions = ['buy', 'sell', 'close'];
  if (!validActions.includes(data.action)) {
    throw new Error('Invalid action type');
  }
  
  // 가격 범위 검증
  if (data.price && (data.price <= 0 || data.price > 1000000)) {
    throw new Error('Invalid price range');
  }
  
  return true;
}
```

### 3. 백업 및 아카이빙

```sql
-- 오래된 시그널 아카이빙
CREATE TABLE trading_signals_archive AS 
SELECT * FROM trading_signals 
WHERE created_at < NOW() - INTERVAL '90 days';

-- 원본 테이블에서 삭제
DELETE FROM trading_signals 
WHERE created_at < NOW() - INTERVAL '90 days';
```

## 보안 고려사항

1. **API 키 보호**: 환경 변수 사용, 절대 코드에 하드코딩 금지
2. **HTTPS 사용**: 모든 통신은 암호화된 연결 사용
3. **Rate Limiting**: 과도한 요청 방지
4. **입력 검증**: 모든 입력 데이터 검증
5. **Row Level Security**: Supabase RLS 정책 설정

```sql
-- RLS 활성화
ALTER TABLE trading_signals ENABLE ROW LEVEL SECURITY;

-- 정책 생성 (예: 인증된 사용자만 읽기)
CREATE POLICY "Authenticated users can read signals" 
ON trading_signals FOR SELECT 
TO authenticated 
USING (true);
```

## 결론

이 가이드를 따라 TradingView 웹훅 시그널을 Supabase에 안전하게 저장하는 시스템을 구축할 수 있습니다. 추가로 다음과 같은 기능을 구현할 수 있습니다:

- 자동 트레이딩 실행
- 포트폴리오 추적
- 성과 분석 대시보드
- 멀티 전략 관리
- 리스크 관리 시스템

문제가 발생하거나 추가 기능이 필요한 경우, Supabase와 TradingView 문서를 참고하시기 바랍니다.