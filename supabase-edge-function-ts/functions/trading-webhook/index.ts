import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'

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

// CORS 헤더
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // OPTIONS 요청 처리 (CORS preflight)
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  // POST 요청만 허용
  if (req.method !== 'POST') {
    return new Response(
      JSON.stringify({ error: 'Method not allowed' }),
      { status: 405, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  try {
    // Supabase 클라이언트 생성 - Supabase Edge Functions에서는 자동으로 환경 변수 사용
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    // 웹훅 보안 검증 (선택적)
    const webhookSecret = Deno.env.get('WEBHOOK_SECRET')
    if (webhookSecret) {
      const authHeader = req.headers.get('Authorization')
      if (authHeader !== `Bearer ${webhookSecret}`) {
        return new Response(
          JSON.stringify({ error: 'Unauthorized' }),
          { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
    }

    // 요청 본문 파싱
    const webhookData: TradingViewWebhookPayload = await req.json()

    // 데이터 검증
    if (!webhookData.symbol || !webhookData.action) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: symbol and action' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 유효한 액션 검증
    const validActions = ['buy', 'sell', 'close']
    if (!validActions.includes(webhookData.action)) {
      return new Response(
        JSON.stringify({ error: 'Invalid action. Must be: buy, sell, or close' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // DB에 저장할 데이터 준비
    const signalData: TradingSignal = {
      symbol: webhookData.symbol.toUpperCase(),
      action: webhookData.action,
      price: webhookData.price ?? null,
      quantity: webhookData.quantity ?? null,
      strategy_name: webhookData.strategy ?? null,
      timeframe: webhookData.timeframe ?? null,
      indicator_values: webhookData.indicators ?? {},
      message: webhookData.message ?? '',
      raw_payload: webhookData as Record<string, any>
    }

    // Supabase에 데이터 저장
    const { data, error } = await supabaseClient
      .from('trading_signals')
      .insert(signalData)
      .select()
      .single()

    if (error) {
      console.error('Supabase error:', error)
      return new Response(
        JSON.stringify({ error: 'Failed to save signal', details: error.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 성공 응답
    return new Response(
      JSON.stringify({
        success: true,
        data: {
          id: data.id,
          symbol: data.symbol,
          action: data.action,
          created_at: data.created_at
        }
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Webhook error:', error)
    return new Response(
      JSON.stringify({ 
        error: 'Internal server error',
        message: error instanceof Error ? error.message : 'Unknown error'
      }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})