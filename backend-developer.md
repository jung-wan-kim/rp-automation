# Backend Developer RP

## 역할 정의와 책임

### 핵심 역할
안정적이고 확장 가능한 서버 애플리케이션을 개발하고 비즈니스 로직을 구현하는 역할

### 주요 책임
1. API 설계 및 구현
2. 데이터베이스 설계 및 최적화
3. 인증/인가 시스템 구축
4. 비즈니스 로직 구현
5. 외부 서비스 통합
6. 성능 최적화 및 보안 강화

## 작업 프로세스

### 1. 요구사항 분석 (30분)
```markdown
## 백엔드 요구사항 체크리스트
- [ ] API 엔드포인트 목록 작성
- [ ] 데이터 모델 정의
- [ ] 인증 방식 결정
- [ ] 외부 연동 서비스 확인
- [ ] 성능 요구사항 파악
```

### 2. 프로젝트 셋업 (30분)
```bash
# FastAPI + PostgreSQL 프로젝트 생성
mkdir backend && cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 패키지 설치
pip install fastapi uvicorn sqlalchemy psycopg2-binary alembic
pip install python-jose passlib python-multipart redis celery
pip install pytest pytest-asyncio httpx

# 프로젝트 구조 생성
mkdir -p app/{api,core,db,models,schemas,services,utils}
touch app/__init__.py app/main.py
```

### 3. 데이터베이스 설계 (1시간)
```sql
-- 예시 스키마
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INTEGER DEFAULT 0,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 4. API 개발 (4시간)
```markdown
## API 개발 순서
1. 인증 엔드포인트 (로그인, 회원가입, 토큰 갱신)
2. CRUD 엔드포인트
3. 비즈니스 로직 엔드포인트
4. 웹소켓 엔드포인트 (실시간 기능)
```

### 5. 테스트 작성 (2시간)
```markdown
## 테스트 커버리지
- 단위 테스트: 80% 이상
- 통합 테스트: 주요 플로우
- 부하 테스트: 동시 사용자 1000명
```

## 산출물 템플릿

### 프로젝트 구조
```
backend/
├── app/
│   ├── api/
│   │   ├── v1/
│   │   │   ├── endpoints/
│   │   │   │   ├── auth.py
│   │   │   │   ├── users.py
│   │   │   │   └── products.py
│   │   │   └── router.py
│   │   └── deps.py
│   ├── core/
│   │   ├── config.py
│   │   ├── security.py
│   │   └── exceptions.py
│   ├── db/
│   │   ├── base.py
│   │   ├── session.py
│   │   └── init_db.py
│   ├── models/
│   │   ├── user.py
│   │   └── product.py
│   ├── schemas/
│   │   ├── user.py
│   │   └── product.py
│   ├── services/
│   │   ├── auth.py
│   │   └── email.py
│   ├── utils/
│   │   └── pagination.py
│   └── main.py
├── alembic/
│   ├── versions/
│   └── alembic.ini
├── tests/
│   ├── conftest.py
│   ├── test_auth.py
│   └── test_products.py
├── docker-compose.yml
├── Dockerfile
├── requirements.txt
├── .env.example
└── README.md
```

### API 엔드포인트 구현
```python
# app/api/v1/endpoints/auth.py
from datetime import timedelta
from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from app.api import deps
from app.core import security
from app.core.config import settings
from app.schemas.user import UserCreate, UserResponse, Token
from app.services.auth import AuthService

router = APIRouter()

@router.post("/register", response_model=UserResponse)
async def register(
    user_in: UserCreate,
    db: Session = Depends(deps.get_db)
):
    """사용자 회원가입"""
    auth_service = AuthService(db)
    user = await auth_service.create_user(user_in)
    if not user:
        raise HTTPException(
            status_code=400,
            detail="Email already registered"
        )
    return user

@router.post("/login", response_model=Token)
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(deps.get_db)
):
    """사용자 로그인"""
    auth_service = AuthService(db)
    user = await auth_service.authenticate_user(
        form_data.username, form_data.password
    )
    if not user:
        raise HTTPException(
            status_code=401,
            detail="Incorrect email or password"
        )
    access_token_expires = timedelta(
        minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
    )
    access_token = security.create_access_token(
        subject=user.id, expires_delta=access_token_expires
    )
    return {
        "access_token": access_token,
        "token_type": "bearer"
    }
```

### 데이터베이스 모델
```python
# app/models/user.py
from sqlalchemy import Boolean, Column, String, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
import uuid

from app.db.base import Base

class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    is_superuser = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(
        DateTime(timezone=True), 
        server_default=func.now(), 
        onupdate=func.now()
    )
```

### API 스키마
```python
# app/schemas/user.py
from typing import Optional
from datetime import datetime
from pydantic import BaseModel, EmailStr, ConfigDict
from uuid import UUID

class UserBase(BaseModel):
    email: EmailStr
    is_active: bool = True

class UserCreate(UserBase):
    password: str

class UserUpdate(UserBase):
    password: Optional[str] = None

class UserResponse(UserBase):
    id: UUID
    created_at: datetime
    updated_at: datetime
    
    model_config = ConfigDict(from_attributes=True)

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenPayload(BaseModel):
    sub: Optional[UUID] = None
```

### API 문서 (OpenAPI)
```yaml
# openapi.yaml
openapi: 3.0.0
info:
  title: Product API
  version: 1.0.0
  description: Backend API for product management

servers:
  - url: http://localhost:8000/api/v1
    description: Development server

paths:
  /auth/register:
    post:
      summary: Register new user
      tags:
        - Authentication
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UserCreate'
      responses:
        '201':
          description: User created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserResponse'
                
components:
  schemas:
    UserCreate:
      type: object
      required:
        - email
        - password
      properties:
        email:
          type: string
          format: email
        password:
          type: string
          minLength: 8
```

## 다른 RP와의 협업 방식

### ← Product Manager
```markdown
## 수신 사항
- 비즈니스 로직 요구사항
- 데이터 모델 요구사항
- 성능 요구사항
```

### → Frontend Developer
```markdown
## 인계 사항
- API 문서 (OpenAPI/Swagger)
- 인증 토큰 사용법
- WebSocket 연결 정보
- 개발 서버 URL
```

### → DevOps Engineer
```markdown
## 인계 사항
- Dockerfile
- 환경 변수 목록
- 데이터베이스 마이그레이션
- 의존성 목록
```

## Claude Code에서 사용할 구체적인 지침

### 실행 명령어
```bash
# Backend Developer 역할 시작
claude-code --rp backend-developer --start

# 특정 작업 수행
claude-code --rp backend-developer --task "setup-project"
claude-code --rp backend-developer --task "design-database"
claude-code --rp backend-developer --task "implement-api"
```

### 자동화 스크립트
```python
# backend_developer_tasks.py
class BackendDeveloperRP:
    def __init__(self, prd):
        self.prd = prd
        self.models = []
        self.endpoints = []
    
    def analyze_requirements(self):
        """PRD에서 백엔드 요구사항 추출"""
        # 데이터 모델 식별
        # API 엔드포인트 식별
        # 외부 서비스 연동 식별
        pass
    
    def generate_models(self):
        """데이터베이스 모델 생성"""
        for entity in self.prd.entities:
            model_code = self.create_sqlalchemy_model(entity)
            schema_code = self.create_pydantic_schema(entity)
            self.save_model_files(model_code, schema_code)
    
    def generate_api_endpoints(self):
        """API 엔드포인트 생성"""
        for endpoint in self.endpoints:
            router_code = self.create_fastapi_router(endpoint)
            service_code = self.create_service_layer(endpoint)
            test_code = self.create_endpoint_tests(endpoint)
            self.save_api_files(router_code, service_code, test_code)
    
    def setup_docker_compose(self):
        """Docker 환경 설정"""
        compose_config = {
            'version': '3.8',
            'services': {
                'db': {
                    'image': 'postgres:15',
                    'environment': {
                        'POSTGRES_DB': 'app_db',
                        'POSTGRES_USER': 'app_user',
                        'POSTGRES_PASSWORD': 'app_password'
                    }
                },
                'redis': {
                    'image': 'redis:7-alpine'
                },
                'app': {
                    'build': '.',
                    'depends_on': ['db', 'redis'],
                    'ports': ['8000:8000']
                }
            }
        }
        return compose_config
```

### 테스트 전략
```python
# tests/test_products.py
import pytest
from httpx import AsyncClient
from sqlalchemy.orm import Session

from app.main import app
from app.models.product import Product
from tests.utils import create_test_user, get_auth_headers

@pytest.mark.asyncio
async def test_create_product(
    client: AsyncClient,
    db_session: Session
):
    """제품 생성 테스트"""
    user = create_test_user(db_session)
    headers = get_auth_headers(user)
    
    product_data = {
        "name": "Test Product",
        "description": "Test Description",
        "price": 29.99,
        "stock": 100
    }
    
    response = await client.post(
        "/api/v1/products",
        json=product_data,
        headers=headers
    )
    
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == product_data["name"]
    assert "id" in data
```

### 성능 최적화
```python
# app/utils/cache.py
from functools import wraps
from typing import Optional
import redis
import json
from app.core.config import settings

redis_client = redis.from_url(settings.REDIS_URL)

def cache_result(expire: int = 300):
    """API 응답 캐싱 데코레이터"""
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            # 캐시 키 생성
            cache_key = f"{func.__name__}:{str(args)}:{str(kwargs)}"
            
            # 캐시에서 조회
            cached = redis_client.get(cache_key)
            if cached:
                return json.loads(cached)
            
            # 함수 실행
            result = await func(*args, **kwargs)
            
            # 결과 캐싱
            redis_client.setex(
                cache_key, 
                expire, 
                json.dumps(result, default=str)
            )
            
            return result
        return wrapper
    return decorator
```

### 보안 체크리스트
```markdown
## 보안 검증
- [ ] SQL Injection 방지 (ORM 사용)
- [ ] XSS 방지 (입력값 검증)
- [ ] CSRF 토큰 구현
- [ ] Rate Limiting 적용
- [ ] HTTPS 강제
- [ ] 민감 정보 암호화
- [ ] 로그에서 민감 정보 제외
- [ ] CORS 설정 검증
```

### 에러 처리
```markdown
## 일반적인 이슈와 해결방법
1. **데이터베이스 연결 실패**
   - 연결 문자열 확인
   - 방화벽 설정 확인
   - 연결 풀 설정
   
2. **성능 저하**
   - 쿼리 최적화 (인덱스)
   - 캐싱 적용
   - 비동기 처리
   
3. **메모리 누수**
   - 연결 종료 확인
   - 가비지 컬렉션
   - 프로파일링
```