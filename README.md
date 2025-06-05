# RP(Role-Playing) 자동화 시스템

AI 에이전트가 특정 역할을 수행할 수 있도록 설계된 프롬프트 템플릿 모음입니다.

## 📋 프로젝트 개요

이 프로젝트는 다양한 IT 분야의 전문가 역할을 AI가 수행할 수 있도록 구조화된 프롬프트 템플릿을 제공합니다. 각 템플릿은 해당 역할의 전문성, 업무 프로세스, 의사소통 방식을 반영하여 설계되었습니다.

## 🎭 제공되는 역할

- **Backend Developer** - 서버 개발 및 API 설계 전문가
- **Frontend Developer** - 사용자 인터페이스 개발 전문가
- **DevOps Engineer** - 인프라 자동화 및 배포 전문가
- **Product Manager** - 제품 전략 및 로드맵 관리자
- **Project Manager** - 프로젝트 일정 및 리소스 관리자
- **QA Engineer** - 품질 보증 및 테스트 전문가
- **Technical Writer** - 기술 문서 작성 전문가
- **UX/UI Designer** - 사용자 경험 및 인터페이스 디자이너

## 🚀 다른 프로젝트에 적용하는 방법

### 1. 단일 역할 적용

특정 역할의 프롬프트를 프로젝트에 적용하려면:

```bash
# 원하는 역할의 프롬프트 파일을 복사
cp backend-developer.md /path/to/your/project/prompts/

# 또는 직접 내용을 복사하여 AI 도구에 입력
cat backend-developer.md | pbcopy  # macOS
cat backend-developer.md | xclip   # Linux
```

### 2. 전체 시스템 통합

전체 RP 시스템을 프로젝트에 통합하려면:

```bash
# 이 저장소를 클론
git clone https://github.com/jung-wan-kim/rp-automation.git

# 프로젝트에 prompts 디렉토리 생성
mkdir -p /path/to/your/project/prompts

# 모든 프롬프트 파일 복사
cp rp-automation/*.md /path/to/your/project/prompts/
```

### 3. SYSTEM 프롬프트 활용

`SYSTEM.md` 또는 `SYSTEM-v2.md`를 사용하여 다중 역할 시스템 구축:

```python
# Python 예시
with open('SYSTEM-v2.md', 'r') as f:
    system_prompt = f.read()

# AI API에 시스템 프롬프트로 설정
response = ai_client.chat(
    system_message=system_prompt,
    user_message="백엔드 개발자로서 REST API를 설계해주세요."
)
```

### 4. 커스터마이징

각 프롬프트는 다음과 같이 구성되어 있어 쉽게 수정 가능합니다:

- **역할 정의**: 전문성과 경력 설정
- **핵심 가치**: 해당 역할의 우선순위
- **소프트 스킬**: 커뮤니케이션 스타일
- **응답 구조**: 표준화된 출력 형식

예시:
```markdown
# 역할 정의 수정
당신은 15년 경력의 시니어 백엔드 개발자입니다.
→ 당신은 5년 경력의 주니어 백엔드 개발자입니다.

# 기술 스택 변경
- 주요 기술: Node.js, Python, Java
→ - 주요 기술: Go, Rust, C++
```

## 📁 파일 구조

```
rp-automation/
├── README.md                 # 이 파일
├── SYSTEM.md                # 기본 시스템 프롬프트
├── SYSTEM-v2.md             # 향상된 시스템 프롬프트 (권장)
├── backend-developer.md     # 백엔드 개발자 프롬프트
├── frontend-developer.md    # 프론트엔드 개발자 프롬프트
├── devops-engineer.md       # DevOps 엔지니어 프롬프트
├── product-manager.md       # 제품 관리자 프롬프트
├── project-manager.md       # 프로젝트 관리자 프롬프트
├── qa-engineer.md           # QA 엔지니어 프롬프트
├── technical-writer.md      # 기술 문서 작성자 프롬프트
└── ux-ui-designer.md        # UX/UI 디자이너 프롬프트
```

## 💡 활용 예시

### 1. ChatGPT Custom Instructions
```
1. ChatGPT 설정 → Custom Instructions
2. "How would you like ChatGPT to respond?" 섹션에 원하는 역할 프롬프트 붙여넣기
```

### 2. Claude Projects
```
1. Claude에서 새 프로젝트 생성
2. Project instructions에 SYSTEM-v2.md 내용 입력
3. 대화 시작 시 원하는 역할 지정
```

### 3. API 통합
```javascript
// JavaScript/Node.js 예시
const fs = require('fs');
const OpenAI = require('openai');

const systemPrompt = fs.readFileSync('./SYSTEM-v2.md', 'utf8');
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

async function askExpert(role, question) {
  const response = await openai.chat.completions.create({
    model: "gpt-4",
    messages: [
      { role: "system", content: systemPrompt },
      { role: "user", content: `${role}로서 답변해주세요: ${question}` }
    ]
  });
  return response.choices[0].message.content;
}

// 사용 예시
const answer = await askExpert("백엔드 개발자", "마이크로서비스 아키텍처의 장단점은?");
```

## 🔧 고급 활용

### 팀 시뮬레이션
여러 역할을 동시에 활용하여 가상의 개발팀 구성:

```python
roles = ["product-manager", "backend-developer", "frontend-developer", "qa-engineer"]

for role in roles:
    prompt = load_prompt(f"{role}.md")
    response = ai_chat(prompt, "새로운 기능 X에 대한 의견을 주세요")
    print(f"{role}: {response}")
```

### 역할 체인
순차적으로 여러 역할을 거쳐 작업 진행:

```
1. Product Manager: 요구사항 정의
2. UX/UI Designer: 디자인 작성
3. Frontend Developer: UI 구현
4. Backend Developer: API 개발
5. QA Engineer: 테스트 수행
6. Technical Writer: 문서화
```

## 📝 라이선스

이 프로젝트는 자유롭게 사용, 수정, 배포할 수 있습니다. 상업적 이용도 가능합니다.

## 🤝 기여하기

새로운 역할이나 개선사항이 있다면 PR을 보내주세요!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/new-role`)
3. Commit your changes (`git commit -m 'Add new role: Data Scientist'`)
4. Push to the branch (`git push origin feature/new-role`)
5. Open a Pull Request