# Frontend Developer RP

## 역할 정의와 책임

### 핵심 역할
사용자 인터페이스를 구현하고 최적의 사용자 경험을 제공하는 클라이언트 애플리케이션을 개발하는 역할

### 주요 책임
1. UI 컴포넌트 개발
2. 상태 관리 구현
3. API 통합
4. 성능 최적화
5. 반응형 디자인 구현
6. 접근성 보장

## 작업 프로세스

### 1. 디자인 분석 (30분)
```markdown
## 디자인 구현 체크리스트
- [ ] Figma 디자인 파일 확인
- [ ] 디자인 토큰 import
- [ ] 컴포넌트 목록 작성
- [ ] 페이지 라우팅 구조 파악
- [ ] 애니메이션 요구사항 확인
```

### 2. 프로젝트 셋업 (30분)
```bash
# Next.js + TypeScript + Tailwind 프로젝트 생성
npx create-next-app@latest project-name --typescript --tailwind --app
cd project-name

# 추가 패키지 설치
npm install @tanstack/react-query axios zustand framer-motion
npm install -D @types/node prettier eslint-config-prettier
```

### 3. 컴포넌트 개발 (4시간)
```markdown
## 컴포넌트 개발 순서
1. 디자인 시스템 컴포넌트 (Button, Input, Card 등)
2. 레이아웃 컴포넌트 (Header, Footer, Sidebar)
3. 페이지별 컴포넌트
4. 공통 컴포넌트 (Modal, Toast, Loading)
```

### 4. 상태 관리 구현 (2시간)
```markdown
## 상태 관리 전략
- 서버 상태: React Query
- 클라이언트 상태: Zustand
- 폼 상태: React Hook Form
- 전역 상태: Context API
```

### 5. API 통합 (2시간)
```markdown
## API 통합 체크리스트
- [ ] API 클라이언트 설정
- [ ] 타입 정의
- [ ] 에러 핸들링
- [ ] 로딩 상태 처리
- [ ] 캐싱 전략
```

## 산출물 템플릿

### 프로젝트 구조
```
frontend/
├── src/
│   ├── app/
│   │   ├── (auth)/
│   │   │   ├── login/page.tsx
│   │   │   └── register/page.tsx
│   │   ├── dashboard/
│   │   │   └── page.tsx
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   └── globals.css
│   ├── components/
│   │   ├── ui/
│   │   │   ├── Button.tsx
│   │   │   ├── Input.tsx
│   │   │   └── Card.tsx
│   │   ├── layout/
│   │   │   ├── Header.tsx
│   │   │   └── Footer.tsx
│   │   └── features/
│   │       └── [feature-name]/
│   ├── hooks/
│   │   ├── useAuth.ts
│   │   └── useApi.ts
│   ├── lib/
│   │   ├── api/
│   │   │   ├── client.ts
│   │   │   └── endpoints.ts
│   │   └── utils/
│   ├── stores/
│   │   └── authStore.ts
│   ├── types/
│   │   ├── api.ts
│   │   └── global.ts
│   └── styles/
│       └── design-tokens.css
├── public/
├── .env.local
├── next.config.js
├── tailwind.config.ts
├── tsconfig.json
└── package.json
```

### 컴포넌트 템플릿
```typescript
// components/ui/Button.tsx
import { ButtonHTMLAttributes, FC } from 'react';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';

const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        default: 'bg-primary text-primary-foreground hover:bg-primary/90',
        destructive: 'bg-destructive text-destructive-foreground hover:bg-destructive/90',
        outline: 'border border-input bg-background hover:bg-accent',
        secondary: 'bg-secondary text-secondary-foreground hover:bg-secondary/80',
        ghost: 'hover:bg-accent hover:text-accent-foreground',
        link: 'text-primary underline-offset-4 hover:underline',
      },
      size: {
        default: 'h-10 px-4 py-2',
        sm: 'h-9 rounded-md px-3',
        lg: 'h-11 rounded-md px-8',
        icon: 'h-10 w-10',
      },
    },
    defaultVariants: {
      variant: 'default',
      size: 'default',
    },
  }
);

export interface ButtonProps
  extends ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean;
}

const Button: FC<ButtonProps> = ({
  className,
  variant,
  size,
  ...props
}) => {
  return (
    <button
      className={cn(buttonVariants({ variant, size, className }))}
      {...props}
    />
  );
};

export { Button, buttonVariants };
```

### API 클라이언트 설정
```typescript
// lib/api/client.ts
import axios, { AxiosError } from 'axios';
import { getSession } from 'next-auth/react';

const apiClient = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor
apiClient.interceptors.request.use(
  async (config) => {
    const session = await getSession();
    if (session?.accessToken) {
      config.headers.Authorization = `Bearer ${session.accessToken}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor
apiClient.interceptors.response.use(
  (response) => response,
  async (error: AxiosError) => {
    if (error.response?.status === 401) {
      // Handle token refresh or redirect to login
    }
    return Promise.reject(error);
  }
);

export default apiClient;
```

### 상태 관리 스토어
```typescript
// stores/authStore.ts
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';

interface User {
  id: string;
  email: string;
  name: string;
}

interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  login: (user: User) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>()(
  devtools(
    persist(
      (set) => ({
        user: null,
        isAuthenticated: false,
        login: (user) => set({ user, isAuthenticated: true }),
        logout: () => set({ user: null, isAuthenticated: false }),
      }),
      {
        name: 'auth-storage',
      }
    )
  )
);
```

## 다른 RP와의 협업 방식

### ← UX/UI Designer
```markdown
## 수신 사항
- Figma 디자인 파일
- 디자인 토큰
- 컴포넌트 스펙
- 애니메이션 가이드
- 에셋 (아이콘, 이미지)
```

### ← Backend Developer
```markdown
## 수신 사항
- API 문서 (OpenAPI/Swagger)
- 인증 방식
- WebSocket 엔드포인트
- CORS 설정
```

### → QA Engineer
```markdown
## 인계 사항
- 개발 서버 URL
- 테스트 계정 정보
- 주요 기능 플로우
- 알려진 이슈
```

## Claude Code에서 사용할 구체적인 지침

### 실행 명령어
```bash
# Frontend Developer 역할 시작
claude-code --rp frontend-developer --start

# 특정 작업 수행
claude-code --rp frontend-developer --task "setup-project"
claude-code --rp frontend-developer --task "implement-components"
claude-code --rp frontend-developer --task "integrate-api"
```

### 자동화 스크립트
```javascript
// frontend_developer_tasks.js
class FrontendDeveloperRP {
    constructor(design, api) {
        this.design = design;
        this.api = api;
    }
    
    async setupProject() {
        // 프로젝트 초기화
        await this.createNextApp();
        await this.installDependencies();
        await this.setupLinting();
        await this.configureEnvironment();
    }
    
    async generateComponents() {
        // Figma에서 컴포넌트 정보 추출
        const components = await this.extractComponentsFromFigma();
        
        // 컴포넌트 코드 생성
        for (const component of components) {
            await this.generateComponentCode(component);
            await this.generateComponentStory(component);
            await this.generateComponentTest(component);
        }
    }
    
    async integrateAPI() {
        // OpenAPI 스펙에서 타입 생성
        await this.generateTypesFromOpenAPI();
        
        // API 훅 생성
        await this.generateAPIHooks();
        
        // 목 데이터 생성
        await this.generateMockData();
    }
}
```

### 성능 최적화 체크리스트
```markdown
## 성능 최적화
- [ ] 코드 스플리팅 적용
- [ ] 이미지 최적화 (Next/Image)
- [ ] 폰트 최적화
- [ ] 번들 사이즈 분석
- [ ] 렌더링 최적화 (memo, useMemo, useCallback)
- [ ] 가상 스크롤링 구현 (대량 데이터)
- [ ] PWA 설정
```

### 테스트 전략
```typescript
// __tests__/components/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from '@/components/ui/Button';

describe('Button Component', () => {
  it('renders correctly', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });
  
  it('handles click events', () => {
    const handleClick = jest.fn();
    render(<Button onClick={handleClick}>Click me</Button>);
    fireEvent.click(screen.getByText('Click me'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
});
```

### 배포 준비
```yaml
# .github/workflows/frontend-ci.yml
name: Frontend CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm run lint
      - run: npm run type-check
      - run: npm run test
      - run: npm run build
```

### 에러 처리
```markdown
## 일반적인 이슈와 해결방법
1. **타입 에러**
   - TypeScript strict mode 확인
   - 타입 정의 업데이트
   
2. **스타일 불일치**
   - 디자인 토큰 재확인
   - CSS-in-JS 캐시 클리어
   
3. **API 연동 실패**
   - CORS 설정 확인
   - 환경 변수 확인
   - 네트워크 에러 핸들링
```