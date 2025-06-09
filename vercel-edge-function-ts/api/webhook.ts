import { VercelRequest, VercelResponse } from '@vercel/node';
import { createClient } from '@supabase/supabase-js';

// 타입 정의
interface TradingViewWebhookPayload {
  symbol: string;
  action: 'buy' | 'sell' | 'close';
  price?: number;
  quantity?: number;
  strategy?: string;
  timeframe?: string;
  indicators?: Record<string, number>;
  message?: string;
  time?: string;
  volume?: number;
}

interface TradingSignal {
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

// 환경 변수 타입 체크
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;
const WEBHOOK_SECRET = process.env.WEBHOOK_SECRET;

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  throw new Error('Missing required environment variables');
}

// Supabase 클라이언트 초기화
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// 웹훅 데이터 검증 함수
function validateWebhookData(data: any): data is TradingViewWebhookPayload {
  if (!data || typeof data !== 'object') {
    return false;
  }

  // 필수 필드 검증
  if (!data.symbol || !data.action) {
    return false;
  }

  // action 타입 검증
  const validActions = ['buy', 'sell', 'close'];
  if (!validActions.includes(data.action)) {
    return false;
  }

  // 선택적 필드 타입 검증
  if (data.price !== undefined && typeof data.price !== 'number') {
    return false;
  }

  if (data.quantity !== undefined && typeof data.quantity !== 'number') {
    return false;
  }

  return true;
}

// 웹훅 데이터를 DB 스키마에 맞게 변환
function transformWebhookData(webhookData: TradingViewWebhookPayload): TradingSignal {
  return {
    symbol: webhookData.symbol,
    action: webhookData.action,
    price: webhookData.price ?? null,
    quantity: webhookData.quantity ?? null,
    strategy_name: webhookData.strategy ?? null,
    timeframe: webhookData.timeframe ?? null,
    indicator_values: webhookData.indicators ?? {},
    message: webhookData.message ?? '',
    raw_payload: webhookData as Record<string, any>
  };
}

// 메인 핸들러
export default async function handler(
  req: VercelRequest,
  res: VercelResponse
): Promise<VercelResponse> {
  // CORS 헤더 설정
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  // OPTIONS 요청 처리 (CORS preflight)
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  // POST 요청만 허용
  if (req.method !== 'POST') {
    return res.status(405).json({ 
      error: 'Method not allowed',
      message: 'Only POST requests are accepted'
    });
  }

  // 인증 검증
  const authHeader = req.headers['authorization'];
  if (WEBHOOK_SECRET && authHeader !== `Bearer ${WEBHOOK_SECRET}`) {
    console.error('Authentication failed');
    return res.status(401).json({ 
      error: 'Unauthorized',
      message: 'Invalid authentication token'
    });
  }

  try {
    // 요청 본문 파싱
    let webhookData: any;
    
    // Content-Type에 따른 처리
    const contentType = req.headers['content-type'];
    
    if (contentType?.includes('application/json')) {
      webhookData = req.body;
    } else if (typeof req.body === 'string') {
      // 텍스트로 전송된 경우 JSON 파싱 시도
      try {
        webhookData = JSON.parse(req.body);
      } catch (parseError) {
        console.error('JSON parsing error:', parseError);
        return res.status(400).json({ 
          error: 'Invalid JSON',
          message: 'Failed to parse request body as JSON'
        });
      }
    } else {
      webhookData = req.body;
    }

    // 데이터 검증
    if (!validateWebhookData(webhookData)) {
      console.error('Invalid webhook data:', webhookData);
      return res.status(400).json({ 
        error: 'Invalid data',
        message: 'Webhook data does not match expected format'
      });
    }

    // 데이터 변환
    const signalData = transformWebhookData(webhookData);

    // 가격 범위 검증 (선택적)
    if (signalData.price !== null && (signalData.price <= 0 || signalData.price > 10000000)) {
      console.warn('Price out of expected range:', signalData.price);
    }

    // Supabase에 데이터 저장
    const { data, error } = await supabase
      .from('trading_signals')
      .insert([signalData])
      .select()
      .single();

    if (error) {
      console.error('Supabase error:', error);
      return res.status(500).json({ 
        error: 'Database error',
        message: 'Failed to save trading signal',
        details: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }

    console.log('Signal saved successfully:', {
      id: data.id,
      symbol: data.symbol,
      action: data.action,
      timestamp: new Date().toISOString()
    });

    // 성공 응답
    return res.status(200).json({ 
      success: true,
      data: {
        id: data.id,
        symbol: data.symbol,
        action: data.action,
        created_at: data.created_at
      }
    });

  } catch (error) {
    console.error('Webhook handler error:', error);
    
    // 에러 타입에 따른 처리
    if (error instanceof Error) {
      return res.status(500).json({ 
        error: 'Internal server error',
        message: process.env.NODE_ENV === 'development' ? error.message : 'An unexpected error occurred'
      });
    }
    
    return res.status(500).json({ 
      error: 'Internal server error',
      message: 'An unexpected error occurred'
    });
  }
}

// Edge 런타임 설정 (선택적)
export const config = {
  runtime: 'edge',
}