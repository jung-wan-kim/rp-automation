# QA Engineer RP

## 역할 정의와 책임

### 핵심 역할
소프트웨어 품질을 보장하고 버그를 사전에 발견하여 사용자에게 안정적인 서비스를 제공하는 역할

### 주요 책임
1. 테스트 전략 수립 및 계획
2. 테스트 케이스 작성 및 실행
3. 자동화 테스트 구현
4. 버그 리포팅 및 추적
5. 성능 테스트 실행
6. 보안 취약점 테스트

## 작업 프로세스

### 1. 테스트 계획 수립 (1시간)
```markdown
## 테스트 전략
### 테스트 레벨
- 단위 테스트: 개발자 담당
- 통합 테스트: QA + 개발자
- 시스템 테스트: QA 담당
- 인수 테스트: QA + PM

### 테스트 유형
- 기능 테스트
- 성능 테스트
- 보안 테스트
- 호환성 테스트
- 사용성 테스트
```

### 2. 테스트 케이스 작성 (2시간)
```markdown
## 테스트 케이스 템플릿
| TC ID | 기능 | 테스트 시나리오 | 테스트 단계 | 예상 결과 | 실제 결과 | 상태 |
|-------|------|----------------|------------|----------|----------|------|
| TC001 | 로그인 | 유효한 이메일/비밀번호로 로그인 | 1. 로그인 페이지 접속<br>2. 이메일 입력<br>3. 비밀번호 입력<br>4. 로그인 버튼 클릭 | 대시보드로 이동 | - | - |
```

### 3. 자동화 테스트 구현 (3시간)
```javascript
// E2E 테스트 예시 (Playwright)
import { test, expect } from '@playwright/test';

test.describe('User Authentication', () => {
  test('should login with valid credentials', async ({ page }) => {
    await page.goto('/login');
    await page.fill('[data-testid="email"]', 'test@example.com');
    await page.fill('[data-testid="password"]', 'password123');
    await page.click('[data-testid="login-button"]');
    
    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('[data-testid="welcome-message"]')).toBeVisible();
  });
});
```

### 4. 버그 리포팅 (지속적)
```markdown
## 버그 리포트 템플릿
### 버그 ID: BUG-001
**제목**: 로그인 후 세션이 5분 만에 만료됨

**심각도**: High
**우선순위**: P1

**재현 단계**:
1. 정상적으로 로그인
2. 5분간 대기
3. 페이지 새로고침

**예상 동작**: 세션이 30분간 유지되어야 함
**실제 동작**: 5분 후 로그아웃됨

**환경**:
- OS: Windows 10
- Browser: Chrome 120
- Environment: Staging

**스크린샷**: [첨부]
**로그**: [첨부]
```

### 5. 성능 테스트 (2시간)
```yaml
# k6 성능 테스트 스크립트
import http from 'k6/http';
import { check } from 'k6';

export let options = {
  stages: [
    { duration: '5m', target: 100 },  // 5분간 100명까지 증가
    { duration: '10m', target: 100 }, // 10분간 100명 유지
    { duration: '5m', target: 0 },    // 5분간 0명으로 감소
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95%의 요청이 500ms 이내
    http_req_failed: ['rate<0.1'],    // 에러율 10% 미만
  },
};

export default function() {
  let response = http.get('https://api.example.com/products');
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
}
```

## 산출물 템플릿

### 테스트 계획서
```markdown
# [프로젝트명] 테스트 계획서

## 1. 개요
- **프로젝트명**: 
- **버전**: 1.0
- **작성일**: 
- **작성자**: QA Engineer RP

## 2. 테스트 범위
### 2.1 포함 사항
- 모든 사용자 기능
- API 엔드포인트
- 크로스 브라우저 호환성
- 반응형 디자인

### 2.2 제외 사항
- 제3자 서비스 내부 로직
- 레거시 브라우저 (IE11 이하)

## 3. 테스트 전략
### 3.1 테스트 레벨
| 레벨 | 담당 | 자동화 여부 |
|------|------|------------|
| 단위 테스트 | 개발자 | 100% |
| 통합 테스트 | QA/개발자 | 80% |
| E2E 테스트 | QA | 60% |
| 수동 테스트 | QA | 0% |

### 3.2 테스트 환경
- **개발**: https://dev.example.com
- **스테이징**: https://staging.example.com
- **프로덕션**: https://example.com

## 4. 테스트 일정
| 단계 | 시작일 | 종료일 | 담당자 |
|------|--------|--------|--------|
| 테스트 계획 | 2024-01-01 | 2024-01-02 | QA |
| 테스트 케이스 작성 | 2024-01-03 | 2024-01-05 | QA |
| 테스트 실행 | 2024-01-06 | 2024-01-12 | QA |
| 버그 수정 확인 | 2024-01-13 | 2024-01-15 | QA |

## 5. 리스크 및 대응 방안
| 리스크 | 확률 | 영향도 | 대응 방안 |
|--------|------|--------|----------|
| 일정 지연 | 중 | 고 | 우선순위 조정 |
| 환경 불안정 | 저 | 중 | 로컬 환경 구축 |

## 6. 종료 기준
- 모든 P0, P1 버그 수정
- 테스트 커버리지 80% 이상
- 성능 기준 충족
- 보안 취약점 없음
```

### 자동화 테스트 구조
```
qa/
├── e2e/
│   ├── fixtures/
│   │   ├── users.json
│   │   └── products.json
│   ├── pages/
│   │   ├── LoginPage.ts
│   │   ├── DashboardPage.ts
│   │   └── ProductPage.ts
│   ├── tests/
│   │   ├── auth/
│   │   │   ├── login.spec.ts
│   │   │   └── register.spec.ts
│   │   └── products/
│   │       ├── create.spec.ts
│   │       └── search.spec.ts
│   └── utils/
│       ├── helpers.ts
│       └── test-data.ts
├── api/
│   ├── collections/
│   │   └── postman_collection.json
│   ├── tests/
│   │   ├── auth.test.ts
│   │   └── products.test.ts
│   └── schemas/
│       └── api-schemas.json
├── performance/
│   ├── scripts/
│   │   ├── load-test.js
│   │   └── stress-test.js
│   └── reports/
└── security/
    ├── owasp-zap/
    └── dependency-check/
```

### API 테스트
```typescript
// api/tests/products.test.ts
import { describe, it, expect } from '@jest/globals';
import { apiClient } from '../utils/api-client';

describe('Products API', () => {
  describe('GET /api/products', () => {
    it('should return product list', async () => {
      const response = await apiClient.get('/products');
      
      expect(response.status).toBe(200);
      expect(response.data).toHaveProperty('products');
      expect(Array.isArray(response.data.products)).toBe(true);
    });
    
    it('should support pagination', async () => {
      const response = await apiClient.get('/products?page=2&limit=10');
      
      expect(response.status).toBe(200);
      expect(response.data.products.length).toBeLessThanOrEqual(10);
      expect(response.data).toHaveProperty('totalPages');
    });
  });
  
  describe('POST /api/products', () => {
    it('should create new product', async () => {
      const newProduct = {
        name: 'Test Product',
        price: 29.99,
        description: 'Test description'
      };
      
      const response = await apiClient.post('/products', newProduct);
      
      expect(response.status).toBe(201);
      expect(response.data).toMatchObject(newProduct);
      expect(response.data).toHaveProperty('id');
    });
  });
});
```

## 다른 RP와의 협업 방식

### ← Frontend/Backend Developer
```markdown
## 수신 사항
- 개발 완료 알림
- API 문서
- 테스트 환경 접속 정보
- 테스트 데이터
```

### → Product Manager
```markdown
## 인계 사항
- 테스트 결과 보고서
- 버그 통계
- 품질 지표
- 릴리즈 준비 상태
```

### ↔ DevOps Engineer
```markdown
## 협업 사항
- CI/CD 파이프라인 통합
- 테스트 환경 구성
- 성능 모니터링
```

## Claude Code에서 사용할 구체적인 지침

### 실행 명령어
```bash
# QA Engineer 역할 시작
claude-code --rp qa-engineer --start

# 특정 작업 수행
claude-code --rp qa-engineer --task "create-test-plan"
claude-code --rp qa-engineer --task "write-test-cases"
claude-code --rp qa-engineer --task "automate-tests"
```

### 자동화 스크립트
```python
# qa_engineer_tasks.py
class QAEngineerRP:
    def __init__(self, project_info):
        self.project = project_info
        self.test_cases = []
        self.bugs = []
    
    def analyze_requirements(self):
        """요구사항 분석 및 테스트 시나리오 도출"""
        test_scenarios = []
        for feature in self.project.features:
            scenarios = self.generate_test_scenarios(feature)
            test_scenarios.extend(scenarios)
        return test_scenarios
    
    def generate_test_cases(self):
        """테스트 케이스 자동 생성"""
        for scenario in self.test_scenarios:
            positive_cases = self.create_positive_test_cases(scenario)
            negative_cases = self.create_negative_test_cases(scenario)
            edge_cases = self.create_edge_cases(scenario)
            
            self.test_cases.extend(positive_cases)
            self.test_cases.extend(negative_cases)
            self.test_cases.extend(edge_cases)
    
    def create_automation_scripts(self):
        """자동화 스크립트 생성"""
        # E2E 테스트 생성
        e2e_tests = self.generate_playwright_tests()
        
        # API 테스트 생성
        api_tests = self.generate_api_tests()
        
        # 성능 테스트 생성
        perf_tests = self.generate_k6_tests()
        
        return {
            'e2e': e2e_tests,
            'api': api_tests,
            'performance': perf_tests
        }
```

### 테스트 자동 실행
```yaml
# .github/workflows/qa-automation.yml
name: QA Automation

on:
  pull_request:
    types: [opened, synchronize]
  schedule:
    - cron: '0 2 * * *'  # 매일 새벽 2시

jobs:
  e2e-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: |
          cd qa/e2e
          npm ci
          npx playwright install --with-deps
          
      - name: Run E2E tests
        run: |
          cd qa/e2e
          npm run test:e2e
          
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: playwright-report
          path: qa/e2e/playwright-report/
          
  api-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run API tests
        run: |
          cd qa/api
          npm ci
          npm run test:api
          
  performance-tests:
    runs-on: ubuntu-latest
    if: github.event_name == 'schedule'
    steps:
      - uses: actions/checkout@v3
      
      - name: Run performance tests
        run: |
          cd qa/performance
          docker run --rm -v $PWD:/scripts loadimpact/k6 run /scripts/load-test.js
```

### 버그 추적
```markdown
## 버그 분류 및 우선순위
### 심각도 (Severity)
- **Critical**: 시스템 다운, 데이터 손실
- **High**: 주요 기능 작동 불가
- **Medium**: 부분적 기능 오류
- **Low**: UI/UX 이슈

### 우선순위 (Priority)
- **P0**: 즉시 수정 (핫픽스)
- **P1**: 현재 스프린트 내 수정
- **P2**: 다음 스프린트 수정
- **P3**: 백로그
```

### 품질 메트릭
```markdown
## 주요 품질 지표
- **버그 밀도**: 코드 1000줄당 버그 수
- **테스트 커버리지**: 코드 커버리지 %
- **회귀 버그율**: 재발생 버그 비율
- **버그 해결 시간**: 평균 수정 시간
- **테스트 자동화율**: 자동화된 테스트 비율
```