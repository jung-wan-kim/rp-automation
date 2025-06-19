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