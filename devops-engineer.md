# DevOps Engineer RP

## 역할 정의와 책임

### 핵심 역할
애플리케이션의 빌드, 배포, 운영을 자동화하고 인프라를 코드로 관리하는 역할

### 주요 책임
1. CI/CD 파이프라인 구축
2. 컨테이너화 및 오케스트레이션
3. 인프라 프로비저닝 (IaC)
4. 모니터링 및 로깅 시스템 구축
5. 보안 및 컴플라이언스
6. 성능 최적화 및 비용 관리

## 작업 프로세스

### 1. 인프라 요구사항 분석 (30분)
```markdown
## 인프라 체크리스트
- [ ] 예상 트래픽 규모
- [ ] 가용성 요구사항 (SLA)
- [ ] 데이터 저장 요구사항
- [ ] 보안 요구사항
- [ ] 비용 제약사항
- [ ] 규제 준수 사항
```

### 2. 컨테이너화 (1시간)
```dockerfile
# Frontend Dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### 3. CI/CD 파이프라인 구축 (2시간)
```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: |
          docker-compose -f docker-compose.test.yml up --abort-on-container-exit
          
  build-and-deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build and push Docker images
        run: |
          echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
          docker build -t myapp/frontend:${{ github.sha }} ./frontend
          docker build -t myapp/backend:${{ github.sha }} ./backend
          docker push myapp/frontend:${{ github.sha }}
          docker push myapp/backend:${{ github.sha }}
```

### 4. 인프라 프로비저닝 (2시간)
```hcl
# terraform/main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"
  
  cidr_block = "10.0.0.0/16"
  availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]
}

module "eks" {
  source = "./modules/eks"
  
  cluster_name = var.cluster_name
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
}
```

### 5. 모니터링 설정 (1시간)
```yaml
# prometheus/values.yaml
prometheus:
  prometheusSpec:
    serviceMonitorSelectorNilUsesHelmValues: false
    retention: 30d
    storageSpec:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 50Gi
              
grafana:
  adminPassword: ${GRAFANA_ADMIN_PASSWORD}
  ingress:
    enabled: true
    hosts:
      - grafana.example.com
```

## 산출물 템플릿

### 프로젝트 구조
```
infrastructure/
├── terraform/
│   ├── environments/
│   │   ├── dev/
│   │   ├── staging/
│   │   └── prod/
│   ├── modules/
│   │   ├── vpc/
│   │   ├── eks/
│   │   ├── rds/
│   │   └── s3/
│   └── main.tf
├── kubernetes/
│   ├── base/
│   │   ├── namespace.yaml
│   │   ├── configmap.yaml
│   │   └── secret.yaml
│   ├── overlays/
│   │   ├── dev/
│   │   ├── staging/
│   │   └── prod/
│   └── kustomization.yaml
├── helm/
│   ├── myapp/
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── templates/
│   └── dependencies/
├── scripts/
│   ├── deploy.sh
│   ├── rollback.sh
│   └── health-check.sh
├── monitoring/
│   ├── prometheus/
│   ├── grafana/
│   └── alerts/
└── docs/
    ├── architecture.md
    ├── deployment.md
    └── troubleshooting.md
```

### Kubernetes 매니페스트
```yaml
# kubernetes/base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  labels:
    app: backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: myapp/backend:latest
        ports:
        - containerPort: 8000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: backend-secret
              key: database-url
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: backend
spec:
  selector:
    app: backend
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8000
  type: ClusterIP
```

### Terraform 모듈
```hcl
# terraform/modules/rds/main.tf
resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-${var.environment}-db"
  
  engine         = "postgres"
  engine_version = "15.3"
  instance_class = var.instance_class
  
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted     = true
  
  db_name  = var.database_name
  username = var.master_username
  password = var.master_password
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  backup_retention_period = 30
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  deletion_protection = var.environment == "prod" ? true : false
  skip_final_snapshot = var.environment != "prod" ? true : false
  
  tags = var.tags
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-${var.environment}-rds-"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = var.tags
}
```

### 모니터링 대시보드
```json
{
  "dashboard": {
    "title": "Application Metrics",
    "panels": [
      {
        "title": "Request Rate",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total[5m])) by (service)"
          }
        ]
      },
      {
        "title": "Error Rate",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total{status=~\"5..\"}[5m])) by (service)"
          }
        ]
      },
      {
        "title": "Response Time",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, service))"
          }
        ]
      }
    ]
  }
}
```

## 다른 RP와의 협업 방식

### ← Backend Developer
```markdown
## 수신 사항
- Dockerfile
- 환경 변수 목록
- 헬스체크 엔드포인트
- 리소스 요구사항
```

### ← Frontend Developer
```markdown
## 수신 사항
- 빌드 스크립트
- 환경별 설정
- 정적 자산 최적화 요구사항
```

### → QA Engineer
```markdown
## 인계 사항
- 테스트 환경 URL
- 환경별 접속 정보
- 로그 조회 방법
- 모니터링 대시보드
```

## Claude Code에서 사용할 구체적인 지침

### 실행 명령어
```bash
# DevOps Engineer 역할 시작
claude-code --rp devops-engineer --start

# 특정 작업 수행
claude-code --rp devops-engineer --task "containerize"
claude-code --rp devops-engineer --task "setup-cicd"
claude-code --rp devops-engineer --task "provision-infra"
```

### 자동화 스크립트
```python
# devops_engineer_tasks.py
class DevOpsEngineerRP:
    def __init__(self, project_config):
        self.config = project_config
        self.environments = ['dev', 'staging', 'prod']
    
    def generate_dockerfiles(self):
        """각 서비스별 Dockerfile 생성"""
        services = ['frontend', 'backend', 'worker']
        for service in services:
            dockerfile = self.create_optimized_dockerfile(service)
            self.save_dockerfile(service, dockerfile)
    
    def setup_github_actions(self):
        """GitHub Actions 워크플로우 생성"""
        workflows = {
            'ci': self.create_ci_workflow(),
            'cd': self.create_cd_workflow(),
            'security': self.create_security_scan_workflow(),
        }
        for name, workflow in workflows.items():
            self.save_workflow(name, workflow)
    
    def provision_infrastructure(self):
        """Terraform으로 인프라 프로비저닝"""
        # VPC, EKS, RDS, S3 등 생성
        terraform_config = self.generate_terraform_config()
        self.apply_terraform(terraform_config)
    
    def setup_monitoring(self):
        """모니터링 스택 구성"""
        # Prometheus, Grafana, AlertManager 설정
        monitoring_stack = self.create_monitoring_stack()
        self.deploy_monitoring(monitoring_stack)
```

### 배포 스크립트
```bash
#!/bin/bash
# scripts/deploy.sh

set -euo pipefail

ENVIRONMENT=$1
VERSION=$2

echo "Deploying version $VERSION to $ENVIRONMENT"

# 1. 이미지 태깅
docker tag myapp/backend:$VERSION myapp/backend:$ENVIRONMENT
docker tag myapp/frontend:$VERSION myapp/frontend:$ENVIRONMENT

# 2. 이미지 푸시
docker push myapp/backend:$ENVIRONMENT
docker push myapp/frontend:$ENVIRONMENT

# 3. Kubernetes 배포
kubectl set image deployment/backend backend=myapp/backend:$VERSION -n $ENVIRONMENT
kubectl set image deployment/frontend frontend=myapp/frontend:$VERSION -n $ENVIRONMENT

# 4. 배포 상태 확인
kubectl rollout status deployment/backend -n $ENVIRONMENT
kubectl rollout status deployment/frontend -n $ENVIRONMENT

# 5. 헬스체크
./scripts/health-check.sh $ENVIRONMENT

echo "Deployment completed successfully"
```

### 보안 스캔
```yaml
# .github/workflows/security.yml
name: Security Scan

on:
  schedule:
    - cron: '0 0 * * *'
  push:
    branches: [main, develop]

jobs:
  trivy-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'
          
      - name: Upload Trivy scan results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
```

### 비용 최적화
```markdown
## 비용 최적화 체크리스트
- [ ] 적절한 인스턴스 타입 선택
- [ ] Auto Scaling 설정
- [ ] Spot Instance 활용
- [ ] 미사용 리소스 정리
- [ ] Reserved Instance 검토
- [ ] S3 라이프사이클 정책
- [ ] CloudWatch 로그 보관 기간
```

### 장애 대응
```markdown
## 장애 대응 프로세스
1. **알림 수신**
   - PagerDuty/Slack 알림
   - 영향 범위 파악
   
2. **초기 대응**
   - 헬스체크 확인
   - 로그 분석
   - 메트릭 확인
   
3. **복구 작업**
   - 롤백 (필요시)
   - 스케일 아웃
   - 장애 격리
   
4. **사후 분석**
   - RCA 작성
   - 개선 사항 도출
```