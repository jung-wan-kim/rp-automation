import { VercelRequest, VercelResponse } from '@vercel/node';
import { createClient } from '@supabase/supabase-js';
import type { 
  TradingViewWebhookPayload, 
  TradingSignalDB, 
  ApiResponse, 
  WebhookResponseData 
} from '../types';
import { validatePayload, validateBearerToken, safeJsonParse } from '../utils/validation';

// 환경 변수 검증 및 초기화
const { SUPABASE_URL, SUPABASE_ANON_KEY, WEBHOOK_SECRET } = process.env;

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  throw new Error('Missing required Supabase environment variables');
}

// Supabase 클라이언트 (싱글톤)
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: { persistSession: false }
});

/**
 * 최적화된 웹훅 핸들러
 * - 더 나은 에러 처리
 * - 유틸리티 함수 활용
 * - 타입 안정성 강화
 */
export default async function handler(
  req: VercelRequest,
  res: VercelResponse
): Promise<VercelResponse<ApiResponse>> {
  // CORS 처리
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  // 메서드 검증
  if (req.method !== 'POST') {
    return res.status(405).json({
      success: false,
      error: 'Method not allowed',
      message: 'Only POST requests are accepted'
    });
  }

  // 인증 검증
  if (WEBHOOK_SECRET) {
    const authHeader = req.headers.authorization as string | undefined;
    if (!validateBearerToken(authHeader, WEBHOOK_SECRET)) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized',
        message: 'Invalid or missing authentication token'
      });
    }
  }

  try {
    // 페이로드 파싱
    const payload = parseRequestBody(req);
    
    // 페이로드 검증 (throw on invalid)
    validatePayload(payload);
    
    // DB 데이터 준비
    const signalData: TradingSignalDB = {
      symbol: payload.symbol.toUpperCase(),
      action: payload.action,
      price: payload.price ?? null,
      quantity: payload.quantity ?? null,
      strategy_name: payload.strategy ?? null,
      timeframe: payload.timeframe ?? null,
      indicator_values: payload.indicators ?? {},
      message: payload.message ?? '',
      raw_payload: payload
    };

    // Supabase에 저장
    const { data, error } = await supabase
      .from('trading_signals')
      .insert(signalData)
      .select('id, symbol, action, created_at')
      .single();

    if (error) {
      console.error('[Supabase Error]', error);
      return res.status(500).json({
        success: false,
        error: 'Database error',
        message: 'Failed to save trading signal',
        details: process.env.NODE_ENV === 'development' ? error : undefined
      });
    }

    // 성공 로깅
    console.log('[Signal Saved]', {
      id: data.id,
      symbol: data.symbol,
      action: data.action,
      timestamp: new Date().toISOString()
    });

    // 성공 응답
    const responseData: WebhookResponseData = {
      id: data.id,
      symbol: data.symbol,
      action: data.action,
      created_at: data.created_at
    };

    return res.status(200).json({
      success: true,
      data: responseData
    });

  } catch (error) {
    console.error('[Webhook Error]', error);
    
    // 에러 응답
    if (error instanceof Error) {
      const statusCode = (error as any).statusCode || 500;
      return res.status(statusCode).json({
        success: false,
        error: error.name,
        message: error.message,
        details: process.env.NODE_ENV === 'development' ? error.stack : undefined
      });
    }
    
    return res.status(500).json({
      success: false,
      error: 'Internal server error',
      message: 'An unexpected error occurred'
    });
  }
}

/**
 * 요청 본문 파싱 헬퍼
 */
function parseRequestBody(req: VercelRequest): TradingViewWebhookPayload {
  const contentType = req.headers['content-type'] || '';
  
  // JSON 콘텐츠
  if (contentType.includes('application/json')) {
    return req.body;
  }
  
  // 텍스트 콘텐츠
  if (typeof req.body === 'string') {
    const parsed = safeJsonParse<TradingViewWebhookPayload>(req.body);
    if (!parsed) {
      throw new Error('Failed to parse JSON from text body');
    }
    return parsed;
  }
  
  // 기타
  return req.body;
}

// Edge 런타임 설정
export const config = {
  runtime: 'edge',
  regions: ['iad1'], // US East (기본값)
}