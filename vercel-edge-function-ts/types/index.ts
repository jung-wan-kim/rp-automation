// TradingView 웹훅 페이로드 타입
export interface TradingViewWebhookPayload {
  // 필수 필드
  symbol: string;
  action: 'buy' | 'sell' | 'close';
  
  // 선택적 필드
  price?: number;
  quantity?: number;
  strategy?: string;
  timeframe?: string;
  indicators?: Record<string, number>;
  message?: string;
  time?: string;
  volume?: number;
  
  // 추가 커스텀 필드
  [key: string]: any;
}

// Supabase 데이터베이스 스키마 타입
export interface TradingSignalDB {
  id?: number;
  created_at?: string;
  symbol: string;
  action: string;
  price: number | null;
  quantity: number | null;
  strategy_name: string | null;
  timeframe: string | null;
  indicator_values: Record<string, any>;
  message: string;
  raw_payload: Record<string, any>;
}

// API 응답 타입
export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
  details?: any;
}

// 웹훅 응답 데이터 타입
export interface WebhookResponseData {
  id: number;
  symbol: string;
  action: string;
  created_at: string;
}

// Pine Script 인디케이터 값 타입
export interface IndicatorValues {
  rsi?: number;
  macd?: number;
  macd_signal?: number;
  macd_histogram?: number;
  ema?: number;
  sma?: number;
  volume?: number;
  atr?: number;
  adx?: number;
  stochastic_k?: number;
  stochastic_d?: number;
  bollinger_upper?: number;
  bollinger_middle?: number;
  bollinger_lower?: number;
  [key: string]: number | undefined;
}

// 트레이딩 액션 타입
export type TradingAction = 'buy' | 'sell' | 'close';

// 타임프레임 타입
export type Timeframe = '1' | '3' | '5' | '15' | '30' | '45' | '60' | '120' | '180' | '240' | 'D' | 'W' | 'M';

// 환경 변수 타입
export interface EnvironmentVariables {
  SUPABASE_URL: string;
  SUPABASE_ANON_KEY: string;
  WEBHOOK_SECRET?: string;
  NODE_ENV?: 'development' | 'production' | 'test';
}

// 에러 타입
export class WebhookError extends Error {
  constructor(
    message: string,
    public statusCode: number,
    public details?: any
  ) {
    super(message);
    this.name = 'WebhookError';
  }
}

// Supabase 에러 타입
export interface SupabaseError {
  message: string;
  details?: string;
  hint?: string;
  code?: string;
}