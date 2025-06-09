import { TradingViewWebhookPayload, WebhookError } from '../types';

// 유효한 트레이딩 액션 목록
const VALID_ACTIONS = ['buy', 'sell', 'close'] as const;

// 유효한 타임프레임 목록
const VALID_TIMEFRAMES = ['1', '3', '5', '15', '30', '45', '60', '120', '180', '240', 'D', 'W', 'M'];

/**
 * 웹훅 페이로드 검증
 */
export function validatePayload(data: any): asserts data is TradingViewWebhookPayload {
  if (!data || typeof data !== 'object') {
    throw new WebhookError('Invalid payload format', 400);
  }

  // 필수 필드 검증
  if (!data.symbol || typeof data.symbol !== 'string') {
    throw new WebhookError('Missing or invalid symbol', 400);
  }

  if (!data.action || !VALID_ACTIONS.includes(data.action)) {
    throw new WebhookError(`Invalid action. Must be one of: ${VALID_ACTIONS.join(', ')}`, 400);
  }

  // 선택적 필드 타입 검증
  if (data.price !== undefined) {
    const price = Number(data.price);
    if (isNaN(price) || price <= 0) {
      throw new WebhookError('Invalid price value', 400);
    }
  }

  if (data.quantity !== undefined) {
    const quantity = Number(data.quantity);
    if (isNaN(quantity) || quantity <= 0) {
      throw new WebhookError('Invalid quantity value', 400);
    }
  }

  if (data.timeframe !== undefined && !VALID_TIMEFRAMES.includes(data.timeframe)) {
    throw new WebhookError(`Invalid timeframe. Must be one of: ${VALID_TIMEFRAMES.join(', ')}`, 400);
  }

  if (data.indicators !== undefined && typeof data.indicators !== 'object') {
    throw new WebhookError('Invalid indicators format', 400);
  }
}

/**
 * 가격 범위 검증
 */
export function validatePriceRange(price: number | null, min: number = 0, max: number = 10000000): boolean {
  if (price === null) return true;
  return price > min && price <= max;
}

/**
 * 심볼 형식 검증
 */
export function validateSymbolFormat(symbol: string): boolean {
  // 알파벳, 숫자, 일부 특수문자만 허용
  const symbolRegex = /^[A-Z0-9\-._\/]+$/i;
  return symbolRegex.test(symbol) && symbol.length <= 20;
}

/**
 * Bearer 토큰 검증
 */
export function validateBearerToken(authHeader: string | undefined, expectedToken: string): boolean {
  if (!authHeader || !expectedToken) return false;
  
  const tokenMatch = authHeader.match(/^Bearer\s+(.+)$/);
  if (!tokenMatch) return false;
  
  return tokenMatch[1] === expectedToken;
}

/**
 * 날짜/시간 문자열 검증
 */
export function validateDateTime(dateString: string): boolean {
  const date = new Date(dateString);
  return !isNaN(date.getTime());
}

/**
 * JSON 안전 파싱
 */
export function safeJsonParse<T = any>(jsonString: string): T | null {
  try {
    return JSON.parse(jsonString);
  } catch {
    return null;
  }
}