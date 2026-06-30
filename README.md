# Business App Agent Team

Agent Team Kit สำหรับสร้างทีม AI agents แบบมีระบบ เหมาะกับงานสร้าง web app, internal tool, dashboard, approval workflow, CRM/ERP-lite และ business process software

Repo นี้ไม่ได้เป็นแค่ prompt เดี่ยว แต่เป็น package กลางที่รวม:

- วิธีคิดของ supervisor agent
- role ของ specialist agents
- phase gate ตั้งแต่ discovery ถึง delivery
- artifact templates
- agent result contract
- approval policy
- scripts สำหรับเริ่มโปรเจคใหม่และตรวจ phase

เป้าหมายคือให้ทุกโปรเจคใหม่ติดตั้ง workflow เดียวกันได้ แล้วลดปัญหา AI รีบออกแบบระบบหรือเขียนโค้ดก่อนเข้าใจโจทย์จริง

```text
Intake -> Discovery -> Scope -> Flow -> Requirements -> Blueprint -> Implementation Plan -> Implementation -> QA -> Delivery
```

## เหมาะกับใคร

- คนที่อยากใช้ AI agents หลายตัวช่วยทำงานโปรเจค software
- ทีมที่อยากให้ AI เริ่มจาก discovery, scope, requirement, UX flow ก่อนเขียนโค้ด
- คนที่ใช้ Pi, Herdr, Codex, Claude หรือ coding agents อื่นๆ อยู่แล้ว
- มือใหม่ด้าน AI agents ที่อยากมี workflow ชัด ไม่ปล่อยให้ agent ทำงานมั่วหรือข้ามขั้น

## แนวคิดแบบง่าย

ให้คิดว่า repo นี้สร้าง "ทีมงาน AI" แบบนี้:

- `supervisor-orchestrator`: หัวหน้าทีม คุม phase, แตก task, ตรวจงาน, ขอ approval
- `discovery-analyst`: นักวิเคราะห์โจทย์ ถามคำถามก่อนออกแบบ
- `product-manager`: แปลง discovery เป็น scope และ requirements
- `ux-flow-designer`: ทำ user journey, screen flow, state ต่างๆ
- `solution-architect`: ทำ architecture, API, permission, integration
- `data-modeler`: ทำ data model หลังจาก flow ชัดแล้ว
- `qa-risk-reviewer`: ตรวจ requirement, risk, test gap, edge case
- `implementation-worker`: เขียนโค้ดหลังจาก blueprint ผ่านแล้ว
- `code-reviewer`: review implementation ก่อนส่งมอบ

หลักสำคัญ: supervisor ไม่เชื่อคำว่า "done" เฉยๆ ต้องมี artifact, test/check, risk, decision log และ open questions ที่เคลียร์แล้ว

## สิ่งที่อยู่ใน repo

```text
business-app-agent-team/
  skills/       # Skills สำหรับ Pi/Codex style agents
  prompts/      # Prompt ของ supervisor และ worker agents
  templates/    # Template เอกสารและ state files
  schemas/      # JSON schema สำหรับ task/result/approval
  scripts/      # init, spawn, validate, status, close phase
  docs/         # operating model, phase gates, approval policy
  examples/     # ตัวอย่างโจทย์สำหรับลองใช้
```

## ต้องติดตั้งอะไรบ้าง

ขั้นต่ำ:

- `git`
- `bash`
- `python3`

แนะนำสำหรับใช้งานเต็มรูปแบบ:

- `gh` GitHub CLI สำหรับ clone/create/push repo
- `pi` สำหรับรัน supervisor และ workers
- `herdr` สำหรับเปิดหลาย agent ใน terminal panes

เช็คเครื่องมือ:

```bash
git --version
python3 --version
bash --version
gh --version
```

ถ้าใช้ Pi/Herdr:

```bash
pi --version
herdr --version
```

ถ้ายังไม่มี `gh`:

```bash
brew install gh
gh auth login
```

## วิธีติดตั้ง

### วิธีที่ 1: Clone จาก GitHub

```bash
cd ~/Documents/PROJECTS
git clone https://github.com/SuphakornP/business-app-agent-team.git
cd business-app-agent-team
```

ตรวจว่า package พร้อมใช้:

```bash
bash scripts/validate-package.sh
```

ถ้าผ่านจะเห็นประมาณนี้:

```text
validating JSON files
validating shell syntax
validating skills
package validation passed
```

### วิธีที่ 2: ใช้เป็น Pi package

ถ้า Pi environment ของคุณรองรับ package install:

```bash
pi install -l git:github.com/SuphakornP/business-app-agent-team@main
```

หรือใช้ path local หลังจาก clone:

```bash
pi install -l /path/to/business-app-agent-team
```

ถ้า command นี้ใช้ไม่ได้ในเครื่องคุณ ให้ใช้วิธี clone repo แล้วเรียก scripts ด้วย path ตรงๆ แทน

## เริ่มใช้กับโปรเจคใหม่

สมมติคุณมีโปรเจคอยู่ที่:

```bash
~/Documents/PROJECTS/my-new-app
```

ให้ init agent team state:

```bash
bash ~/Documents/PROJECTS/business-app-agent-team/scripts/init-project.sh ~/Documents/PROJECTS/my-new-app
```

script จะสร้างโครงนี้ในโปรเจค:

```text
my-new-app/
  .agent-team/
    state.md
    current-phase.md
    task-board.md
    decision-log.md
    risk-register.md
    open-questions.md
    phase-history.md
    agent-results/
    tasks/
    templates/
  docs/
    product/
    ux/
    architecture/
    data/
    qa/
    agent/
```

หลังจากนั้นเข้าโปรเจค:

```bash
cd ~/Documents/PROJECTS/my-new-app
```

ดูสถานะ:

```bash
bash ~/Documents/PROJECTS/business-app-agent-team/scripts/collect-agent-status.sh .
```

ตรวจ phase intake:

```bash
bash ~/Documents/PROJECTS/business-app-agent-team/scripts/validate-artifacts.sh . intake
```

หมายเหตุ: ครั้งแรก validator อาจ fail เพราะไฟล์ยังเป็น template ที่มี `TBD` อยู่ นี่ตั้งใจให้เป็นแบบนั้น เพื่อบังคับให้เติมข้อมูลจริงก่อนปิด phase

## วิธีใช้งานแบบง่ายที่สุด

ถ้าคุณยังไม่พร้อมใช้ Herdr หรือ Pi ให้ใช้ repo นี้แบบ manual ก่อน

1. เปิดไฟล์ `docs/product/00-intake.md`
2. เติม problem statement, primary user, current workflow, pain point, success metric
3. เปิด `docs/product/01-discovery.md`
4. เติม scenario จริง, user roles, workflow, risks
5. เปิด `docs/product/02-clarifying-questions.md`
6. เขียนคำถามที่ยังไม่ชัด
7. ให้ AI agent ที่คุณใช้ เช่น Codex, ChatGPT, Claude อ่าน prompt ใน `prompts/supervisor.md`
8. ให้ agent ทำงานตาม phase และเขียน output ลง docs

ตัวอย่าง prompt:

```text
Use the supervisor prompt from prompts/supervisor.md.
Start from Intake and Discovery.
Do not design or implement yet.
Read docs/product/00-intake.md and create the discovery artifacts.
If something is unclear, ask clarifying questions before scope or system design.
```

## วิธีใช้กับ Pi

เปิด Pi ในโปรเจคเป้าหมาย:

```bash
cd ~/Documents/PROJECTS/my-new-app
pi --prompt-template ~/Documents/PROJECTS/business-app-agent-team/prompts/supervisor.md --name supervisor_my-new-app
```

แล้วบอก supervisor:

```text
Start with Intake and Discovery.
Do not design or implement until the relevant phase gate is approved.
Use the artifacts in docs/ and .agent-team/.
```

ถ้าจะใช้ specialist prompt:

```bash
pi --prompt-template ~/Documents/PROJECTS/business-app-agent-team/prompts/discovery-analyst.md --name discovery_my-new-app
```

## วิธีใช้กับ Herdr

Herdr เหมาะเมื่ออยากเปิด agent หลายตัวเป็น panes และให้ supervisor คุมงาน

เข้าโปรเจค:

```bash
cd ~/Documents/PROJECTS/my-new-app
herdr
```

เตรียม task สำหรับ phase discovery โดยยังไม่เปิด agent:

```bash
bash ~/Documents/PROJECTS/business-app-agent-team/scripts/spawn-agent-team.sh . discovery --dry-run
```

คำสั่งนี้จะสร้างไฟล์ task ใน:

```text
.agent-team/tasks/
```

ถ้าพร้อมเปิด agent จริง:

```bash
bash ~/Documents/PROJECTS/business-app-agent-team/scripts/spawn-agent-team.sh . discovery --execute
```

phase อื่นๆ:

```bash
bash ~/Documents/PROJECTS/business-app-agent-team/scripts/spawn-agent-team.sh . scope --dry-run
bash ~/Documents/PROJECTS/business-app-agent-team/scripts/spawn-agent-team.sh . flow --dry-run
bash ~/Documents/PROJECTS/business-app-agent-team/scripts/spawn-agent-team.sh . blueprint --dry-run
bash ~/Documents/PROJECTS/business-app-agent-team/scripts/spawn-agent-team.sh . implementation --dry-run
```

ถ้าต้องการเลือก role เอง:

```bash
bash ~/Documents/PROJECTS/business-app-agent-team/scripts/spawn-agent-team.sh . blueprint --roles solution-architect,data-modeler,qa-risk-reviewer --dry-run
```

## Workflow ที่แนะนำ

### 1. Intake

เติม:

- problem statement
- primary user
- current workflow
- pain point
- success metric

ตรวจ:

```bash
bash ~/Documents/PROJECTS/business-app-agent-team/scripts/validate-artifacts.sh . intake
```

ปิด phase:

```bash
bash ~/Documents/PROJECTS/business-app-agent-team/scripts/close-phase.sh . intake
```

### 2. Discovery

ใช้ `discovery-analyst` เพื่อสร้าง:

- `docs/product/01-discovery.md`
- `docs/product/02-clarifying-questions.md`
- `docs/product/03-use-cases.md`

ตรวจ:

```bash
bash ~/Documents/PROJECTS/business-app-agent-team/scripts/validate-artifacts.sh . discovery
```

### 3. Scope

ใช้ `product-manager` และ `qa-risk-reviewer` เพื่อสร้าง:

- `docs/product/04-scope.md`
- `docs/product/05-requirements.md`

### 4. Flow

ใช้ `ux-flow-designer` เพื่อสร้าง:

- `docs/ux/01-user-journey.md`
- `docs/ux/02-screen-flow.md`
- `docs/ux/03-state-and-empty-cases.md`

### 5. Blueprint

ใช้ `solution-architect`, `data-modeler`, `qa-risk-reviewer` เพื่อสร้าง:

- `docs/architecture/01-system-blueprint.md`
- `docs/architecture/02-api-contract.md`
- `docs/architecture/03-security-and-permission.md`
- `docs/data/01-entity-model.md`
- `docs/data/02-data-dictionary.md`
- `docs/data/03-migration-plan.md`

### 6. Implementation

เริ่ม implementation หลังจาก blueprint ผ่านแล้วเท่านั้น

ใช้:

- `implementation-worker`
- `code-reviewer`
- `qa-risk-reviewer`

## Agent Result Contract

ทุก worker ต้องจบงานด้วย format นี้:

```markdown
STATUS: done | blocked | needs_approval | failed
CONFIDENCE: 0-100
TASK_RECEIVED:
WHAT_I_DID:
ARTIFACTS_CREATED_OR_UPDATED:
KEY_DECISIONS:
ASSUMPTIONS:
RISKS:
TESTS_OR_CHECKS:
OPEN_QUESTIONS:
NEXT_RECOMMENDED_ACTION:
```

ถ้า agent ตอบว่า `STATUS: done` แต่ไม่มี artifact, checks, risk, decision หรือยังมีคำถามสำคัญค้างอยู่ supervisor ต้องถือว่ายังไม่ done

## Human Approval Policy

ต้องหยุดและขอ approval ก่อนทำสิ่งเหล่านี้:

- เปลี่ยน database migration
- ลบไฟล์หรือข้อมูล
- เปลี่ยน authentication หรือ authorization
- เพิ่ม paid API, external service, credential
- แตะ production deployment settings
- เปลี่ยน business rule ที่ยังไม่ได้ approve
- จัดการข้อมูล sensitive, financial, legal, health
- refactor ใหญ่เกิน scope
- ติดตั้ง dependency ใหม่
- ทำ irreversible git operation

อ่านรายละเอียดใน:

```text
docs/agent/human-approval-policy.md
```

## คำสั่งสำคัญ

ตรวจ package นี้:

```bash
bash scripts/validate-package.sh
```

init โปรเจค:

```bash
bash scripts/init-project.sh /path/to/project
```

ดูสถานะโปรเจค:

```bash
bash scripts/collect-agent-status.sh /path/to/project
```

เตรียม agent tasks:

```bash
bash scripts/spawn-agent-team.sh /path/to/project discovery --dry-run
```

เปิด agents จริงผ่าน Herdr:

```bash
bash scripts/spawn-agent-team.sh /path/to/project discovery --execute
```

ตรวจ phase:

```bash
bash scripts/validate-artifacts.sh /path/to/project discovery
```

ปิด phase:

```bash
bash scripts/close-phase.sh /path/to/project discovery
```

## ตัวอย่างโจทย์

ดูตัวอย่างใน:

- `examples/approval-workflow/`
- `examples/crm-lite/`
- `examples/internal-dashboard/`

ตัวอย่าง approval workflow:

```text
We need an approval request system for the operations team.
Users submit requests with amount, vendor, category, attachments, and justification.
Team leads approve or reject.
Finance reviews approved requests before payment.
We currently use chat messages and spreadsheets.
Start with discovery. Do not design the system yet.
```

## Troubleshooting

### `validate-artifacts.sh` fail เพราะมี TBD

แปลว่า artifact ยังเป็น template อยู่ ให้เติมข้อมูลจริงก่อน แล้วรันใหม่

### `herdr` command not found

แปลว่ายังไม่ได้ติดตั้ง Herdr หรือ shell หา command ไม่เจอ ใช้ `--dry-run` ไปก่อน หรือเปิด agent แบบ manual ด้วย Pi

### `pi` command not found

แปลว่ายังไม่ได้ติดตั้ง Pi ใช้ prompts ใน `prompts/` กับ AI tool ที่คุณมีไปก่อน

### `gh auth status` fail

ให้ login GitHub CLI:

```bash
gh auth login
```

### ไม่อยากใช้หลาย agent

ใช้ agent ตัวเดียวเป็น supervisor ได้ โดยให้มันอ่าน:

- `prompts/supervisor.md`
- `docs/operating-model.md`
- `docs/phase-gates.md`
- `docs/agent-contract.md`

แล้วให้ทำทีละ phase

## Design Choice

เวอร์ชันนี้ตั้งใจเป็น MVP ที่เสถียร:

- ใช้ skills, prompts, templates, schemas, scripts ก่อน
- ยังไม่ทำ Pi extension ใหญ่
- ใช้ Herdr เป็น optional control plane
- ใช้งานแบบ manual ได้ถ้าเครื่องยังไม่พร้อม

เมื่อใช้กับหลายโปรเจคจน pattern นิ่งแล้ว ค่อยเพิ่ม extension เช่น:

- `/agent-team:start`
- `/agent-team:status`
- `/agent-team:close-phase`
- approval gate UI
- git checkpoint
- Herdr API integration ที่ลึกขึ้น

## License

MIT License

คุณสามารถนำไปใช้ แก้ไข แจกจ่าย หรือ fork ต่อได้ โดยคง copyright notice และ license notice ตามไฟล์ `LICENSE`
