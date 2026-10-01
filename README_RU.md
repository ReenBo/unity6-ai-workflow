# Unity 6 AI Workflow & Antigravity Agents Repository

![Версия](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Автор](https://img.shields.io/badge/author-Reen__Bo-purple.svg)
![Лицензия](https://img.shields.io/badge/license-MIT-green.svg)
![Unity](https://img.shields.io/badge/unity-6.0%2B-black.svg)
![Архитектура](https://img.shields.io/badge/architecture-VContainer%20POCO-purple.svg)
![Платформа](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-orange.svg)

Экосистема глобальных и проектных правил, самообучающихся субагентов (Workflow Creator), защиты персональных данных (Security Auditor), кроссплатформенного Python-раннера (`ci/runner.py`), универсальных CI/CD шаблонов (GitHub, GitLab, Bitbucket, Azure), автоматического отката (Git State Guard), синхронизации памяти (Memory Sync), самоисправления ошибок (Auto-Fixer), прогона тестов (Unity Test Runner) и 3-уровневого стандарта протоколирования для командных разработок приложений на **Unity 6** с помощью **Antigravity IDE (Gemini 3.6 Flash / Claude 3.7)**.

*Документ на английском языке: [README.md](README.md)*  
*Полная документация (Русский): [DOCUMENTATION_RU.md](DOCUMENTATION_RU.md)* | *(English): [DOCUMENTATION.md](DOCUMENTATION.md)*

---

## 🎯 Цели и Архитектурная Идеология

1. **Мультимодальный Анализ ТЗ и Ветки (Task Analyzer)**: Прием задач в форме текста, ссылок или **скриншотов**, интервьюирование разработчика, авто-создание Git-ветки (`feature/...`) и трекинг в `PROJECT_MEMORY.md`.
2. **Единый Кроссплатформенный Python Runner (`ci/runner.py`)**: 100% одинаковое исполнение аудитов VContainer, PII-утечек и GC-аллокаций на **Windows**, **macOS** и **Linux**.
3. **Инфраструктурная Независимость (Provider-Agnostic CI/CD)**: Единый скрипт проверок `ci/run-all-checks.ps1` / `ci/run-all-checks.sh` / `ci/runner.py` с готовыми шаблонами под **GitHub Actions**, **GitLab CI**, **Bitbucket Pipelines** и **Azure DevOps**.
4. **Безопасность и Контрольные Точки (Git State Guard)**: Автоматическое создание `git stash` / `ai-checkpoint` перед крупными изменениями для отката в 1 клик.
5. **Синхронизация Памяти (Memory Sync)**: Автоматическое синхронизирование `PROJECT_MEMORY.md` из `git status` и `git diff`.
6. **Защита Данных и Согласование (Security Auditor)**: Субагент `Security Auditor` гарантирует отсутствие утечек персональных данных (PII), локальных путей и секретных API-ключей с обязательным согласованием с разработчиком.
7. **Авто-Отладка и Прогон Тестов (Auto-Fixer & Unity Test Runner)**: Автономная локализация багов по стек-трейсам (до 2 попыток) и headless-прогон тестов Unity.
8. **Обучение и Запоминание (Knowledge Learner /learn)**: Мгновенная фиксация замечаний разработчика в память проекта.
9. **Экономия Токенов (Context Isolation)**: Передача между субагентами только C# контрактов (интерфейсов) и лимитирование контекстных окон.
10. **Трехуровневая Система Логирования (Triple-Tier Logging)**: Четкое разделение информации для разработчиков (Tier 2 Markdown), агентов (Tier 1 Memory) и системных дампов IDE (Tier 3).

---

## ⚡ Быстрый Старт

### 1. Подключение пакета как Submodule в Unity 6 проект
```bash
cd /path/to/your/UnityProject
git submodule add https://github.com/ReenBo/unity6-ai-workflow.git .agents
```

### 2. Установка локальных Git-хуков (в 1 клик)
* **Windows (PowerShell)**:
  ```powershell
  .\.agents\hooks\install-hooks.ps1
  ```
* **macOS / Linux / Git Bash**:
  ```bash
  bash ./.agents/hooks/install-hooks.sh
  ```

---

## 📁 Структура Репозитория

```text
Unity6-AI-Workflow/
├── package.json                        # Манифест пакета и Версионирование (unity6-ai-workflow v1.0.0 by Reen_Bo)
├── CHANGELOG.md                        # История изменений и релизов
├── LICENSE                             # Лицензия MIT (Автор Reen_Bo)
├── AGENTS.md                           # Главный конфигуратор Antigravity (Маршрутизация, 5 Механик и 3-уровневые логи)
├── PROJECT_MEMORY_TEMPLATE.md          # Шаблон сухой памяти проекта (State & Architecture)
├── mcp_config.json.template            # Конфигурация MCP серверов (Git, Filesystem, Unity)
├── README.md                           # README на английском языке
├── README_RU.md                        # README на русском языке
├── DOCUMENTATION.md                    # Мастер-документация (English)
├── DOCUMENTATION_RU.md                 # Мастер-документация (Русский)
│
├── ci/                                 # 🚀 УНИВЕРСАЛЬНЫЙ CI/CD МОДУЛЬ (Python + Dual Shell)
│   ├── runner.py                      # 🐍 PYTHON RUNNER: 100% кроссплатформенный запуск всех проверок
│   ├── run-all-checks.ps1             # PowerShell скрипт-обертка
│   ├── run-all-checks.sh              # Bash скрипт-обертка (Linux / macOS / Git Bash)
│   └── templates/                      # Шаблоны конфигураций под разные платформы
│
├── rules/                              # Модульные правила разработки
│   ├── unity6-vcontainer-architecture.md  # VContainer POCO, LifetimeScopes, ITickable
│   ├── unity6-performance-gc.md           # Zero-Alloc Update, NativeArray, Burst/Jobs
│   ├── unity6-ui-framework.md             # CSS Architecture, UI Toolkit, Binding
│   └── context-and-token-budget.md        # Правила токеномики и изоляции контекста
│
├── subagents/                          # Определения специализированных субагентов
│   ├── task-analyzer.md               # 📋 АНАЛИТИК ТЗ И ВЕТОК: Анализ текста, скриншотов, ссылок + авто-ветка Git
│   ├── git-state-guard.md                 # 🛡️ СНАПШОТЫ И ОТКАТ: Безопасное сохранение состояния перед рефакторингом
│   ├── auto-fixer.md                      # 🔧 АВТО-ОТЛАДЧИК: Автономное исправление ошибок сборок по стек-трейсу
│   ├── workflow-creator.md                # 🤖 МЕТА-АГЕНТ: Креатор новых навыков и ролей
│   ├── security-privacy-auditor.md        # 🔒 АУДИТОР БЕЗОПАСНОСТИ и Персональных данных (Human-in-the-loop)
│   ├── code-architect.md                  # Субагент-Архитектор (Контракты и ТЗ)
│   ├── code-writer.md                     # Субагент-Разработчик (Изолированный C# кодинг)
│   ├── code-reviewer.md                   # Субагент-Ревьюер (Аудит diff, VContainer и GC)
│   ├── test-engineer.md                   # Субагент-Тестировщик (Unit/Integration тесты)
│   └── execution-logger.md                # Субагент-Протоколист (Генерация логов Tier 2)
│
├── skills/                             # Кастомные Навыки (Skills)
│   ├── task-tracker/                      # 📌 ТРЕКЕР: Управление карточками задач и переключением веток
│   ├── memory-sync/                       # 🧠 СИНХРОНИЗАЦИЯ: Авто-обновление PROJECT_MEMORY.md из git diff
│   ├── knowledge-learner/                 # 🧠 ОБУЧЕНИЕ: Запоминание замечаний разработчика через /learn
│   ├── unity-test-runner/                 # 🧪 ТЕСТЫ: Headless прогон Unity Test Runner (batchmode)
│   ├── security-pii-scanner/              # 🔒 PII СКАНЕР: Поиск PII утечек, API-ключей и личных путей C:\Users\
│   ├── workflow-evolver/                  # 🧬 МЕТА-НАВЫК: Навык генерации новых навыков
│   ├── vcontainer-auditor/                # Авто-проверка DI связок
│   ├── ui-builder-validator/              # Проверка UI Framework & CSS rules
│   ├── memory-gc-profiler/                # Поиск аллокаций в Update/Tick и NativeArray
│   └── execution-logger-skill/            # Формирование отчетов Tier 2 в logs/
│
├── logs/                               # Хранилище отчетов Tier 2 (Task Protocols)
│   ├── README.md                          # Спецификация формата отчетов
│   └── schema_execution_log.json          # JSON Schema для валидации логов
│
└── hooks/                              # Git hooks & Установка
    ├── install-hooks.ps1              # Инсталлятор PowerShell
    ├── install-hooks.sh               # Инсталлятор Bash (macOS/Linux)
    ├── pre-commit-audit.ps1
    ├── pre-commit-audit.sh
    └── hooks.json
```
