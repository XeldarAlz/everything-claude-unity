[English](../../README.md) | [日本語](README.ja.md) | [中文](README.zh-CN.md) | [한국어](README.ko.md) | [Español](README.es.md) | **Português** | [Deutsch](README.de.md) | [Français](README.fr.md) | [Türkçe](README.tr.md)

<!-- last-synced-version: 1.2.0 -->

# everything-claude-unity

**O kit de ferramentas definitivo do Claude Code para desenvolvimento de jogos com Unity.**

Um sistema pronto para producao, plug-and-play, que da ao Claude Code um conhecimento profundo de Unity: desde escrever C# de alto desempenho ate construir cenas, analisar performance e executar builds para iOS/Android, tudo por linguagem natural.

Feito para **desenvolvedores indie solo de jogos mobile**. Coloque em qualquer projeto Unity e funciona.

---

## O que voce recebe

| Componente | Quantidade | Finalidade |
|-----------|-------|---------|
| **Agents** | 18 | Sub-agentes especializados para programacao, verificacao, construcao de cenas, profiling e testes |
| **Commands** | 22 | Comandos slash como `/unity-workflow`, `/unity-ralph`, `/unity-team` |
| **Skills** | 41 | Modulos de conhecimento sobre sistemas Unity, padroes de gameplay e generos mobile |
| **Hooks** | 24 | Rede de seguranca, quality gates, persistencia de sessao, auto-aprendizado |
| **Rules** | 5 | Padroes de codigo C#, regras de performance, padroes de arquitetura MVS |
| **Scripts** | 8 | Ferramentas de validacao para arquivos meta, qualidade de codigo, serializacao e arquitetura |
| **Templates** | 10 | Templates C# para o padrao MVS (Model, View, System, LifetimeScope, Message) |
| **Tests** | 46 | Suite de testes automatizados para hooks, utilitarios de lib e instalacao |

---

## Destaques

### `/unity-workflow` — Pipeline de desenvolvimento completo

Um pipeline estruturado de 4 fases para qualquer funcionalidade: **Esclarecer** requisitos, **Planejar** a implementacao, **Executar** com agentes especializados, **Verificar** com revisao automatica + loop de correcao.

```
/unity-workflow "add a combo scoring system with multipliers and visual feedback"
```

### `/unity-prototype` — De um prompt a jogavel

Descreva uma mecanica e o Claude escreve os scripts C#, constroi a cena via MCP, configura as camadas de fisica, ajusta a camera e verifica que compila.

```
/unity-prototype "2D platformer with wall jumping and dash"
```

### `/unity-ralph` — Loop persistente de verificacao e correcao

Executa o loop de verificacao-correcao de forma persistente: recusa-se a parar ate que o projeto esteja limpo ou atinja o limite de seguranca. Ate 30 passadas de verificacao efetivas com deteccao de estagnacao.

```
/unity-ralph --max-iterations 10
```

### `/unity-team` — Orquestracao paralela de agentes

Lance multiplos agentes simultaneamente: coder + tester + reviewer trabalhando em paralelo para desenvolvimento mais rapido.

```
/unity-team --build "add health system with damage and healing"
```

### Loop de verificacao e correcao

O agente `unity-verifier` revisa automaticamente as mudancas de codigo, corrige problemas seguros (`[FormerlySerializedAs]` faltando, `GetComponent` sem cache, `?.` em objetos Unity) e re-verifica, ate 3 iteracoes ate ficar limpo. Integrado no `/unity-workflow` e disponivel como etapa opcional no `/unity-feature` e `/unity-prototype`.

### Perfis de hooks

Os hooks estao organizados em tres perfis. Configure `UNITY_HOOK_PROFILE` para controlar quais sao executados:

| Perfil | O que esta ativo | Melhor para |
|---------|--------------|----------|
| `minimal` | Apenas hooks de seguranca (bloquear corrupcao de cena/meta, guardas de editor, pre-compact) | Pipelines CI, desenvolvedores experientes |
| `standard` | Seguranca + avisos de qualidade + persistencia de sessao + validacao ao parar (padrao) | Desenvolvimento diario |
| `strict` | Tudo: GateGuard, rastreamento de custos, auto-aprendizado, analise de builds | Projetos novos, aprendizado, auditorias |

```bash
UNITY_HOOK_PROFILE=strict          # Habilitar todos os hooks incluindo GateGuard
UNITY_HOOK_PROFILE=minimal         # Apenas hooks criticos de seguranca
DISABLE_UNITY_HOOKS=1              # Desativar todos os hooks completamente
UNITY_HOOK_MODE=warn               # Rebaixar bloqueios para avisos
DISABLE_HOOK_BLOCK_SCENE_EDIT=1    # Desativar um hook especifico
```

---

## Inicio rapido

### Pre-requisitos
- [Claude Code](https://claude.ai/claude-code) instalado
- Unity 2021.3 LTS ou posterior
- [unity-mcp](https://github.com/CoplayDev/unity-mcp) (opcional, mas recomendado para o pipeline completo)

### Instalacao

```bash
# A partir da raiz do seu projeto Unity:
git clone https://github.com/XeldarAlz/everything-claude-unity.git /tmp/ecu
/tmp/ecu/install.sh --project-dir .
rm -rf /tmp/ecu
```

Ou manualmente:
```bash
git clone https://github.com/XeldarAlz/everything-claude-unity.git
cp -r everything-claude-unity/.claude your-unity-project/.claude
chmod +x your-unity-project/.claude/hooks/*.sh
```

### Atualizar / Desinstalar

```bash
# Atualizar para a versao mais recente (preserva suas customizacoes, cria backup)
./upgrade.sh --project-dir .

# Previsualizar mudancas antes de atualizar
./upgrade.sh --project-dir . --dry-run

# Remocao limpa (com backup)
./uninstall.sh --project-dir .
```

### Configurar Unity MCP (Recomendado)

A ponte MCP da ao Claude controle direto sobre o Editor Unity: construcao de cenas, profiling, builds e mais.

1. No Unity: `Window > Package Manager > + > Add package from git URL`
2. Colar: `https://github.com/CoplayDev/unity-mcp.git?path=/MCPForUnity#main`
3. Abrir `Window > MCP for Unity` e clicar em **Start Server**
4. Claude Code conecta automaticamente via `.claude/settings.json`

### Primeira execucao

```bash
cd your-unity-project
claude

# Verificar a instalacao:
/unity-doctor         # Checar MCP, hooks, estrutura do projeto

# Comecar a trabalhar:
/unity-audit          # Verificacao completa de saude do projeto
/unity-workflow       # Pipeline completo: esclarecer -> planejar -> executar -> verificar
/unity-prototype      # Prototipagem rapida de uma mecanica de jogo
```

---

## Agentes

### Agentes de codigo
| Agente | Modelo | O que faz |
|-------|-------|-------------|
| `unity-coder` | opus | Implementa funcionalidades com conhecimento dos subsistemas Unity, carrega skills relevantes |
| `unity-coder-lite` | sonnet | Variante leve para adicoes simples (campos, metodos, componentes diretos) |
| `unity-fixer` | opus | Diagnostica bugs usando padroes especificos do Unity (referencias faltando, ordem de execucao, ciclo de vida de coroutines) |
| `unity-fixer-lite` | sonnet | Correcoes rapidas para problemas obvios (typos, imports faltando, erros simples) |
| `unity-reviewer` | sonnet | Revisao de codigo verificando seguranca de serializacao, GC em caminhos criticos, ordem do ciclo de vida |
| `unity-shader-dev` | opus | Desenvolvimento HLSL/ShaderGraph otimizado para GPUs mobile, teste ao vivo via MCP |

### Agentes de orquestracao
| Agente | Modelo | O que faz |
|-------|-------|-------------|
| `unity-verifier` | opus | Loop de verificacao-correcao: revisa mudancas, auto-corrige problemas seguros, re-verifica (max 3 iteracoes) |
| `unity-prototyper` | opus | Prototipagem ponta a ponta: escreve codigo + constroi cena + fisica + camera |

### Agentes com MCP
| Agente | Modelo | O que faz | Ferramentas MCP chave |
|-------|-------|-------------|---------------|
| `unity-scene-builder` | opus | Constroi cenas a partir de descricoes | `manage_scene`, `batch_execute` |
| `unity-test-runner` | sonnet | Escreve + executa testes, relata resultados | `run_tests`, `read_console` |
| `unity-build-runner` | sonnet | Configura e dispara builds | `manage_build`, `manage_packages` |
| `unity-optimizer` | opus | Analisa e corrige problemas de performance | `manage_profiler`, `manage_graphics` |

### Agentes hibridos
| Agente | Modelo | O que faz |
|-------|-------|-------------|
| `unity-ui-builder` | opus | Constroi telas UI com codigo + configuracao visual via MCP |
| `unity-network-dev` | opus | Implementa multiplayer com Netcode/Mirror/Photon/Fish-Net |
| `unity-migrator` | sonnet | Migracao de versao Unity e render pipeline |

Os comandos suportam flags `--quick` (direciona para o agente sonnet lite) e `--thorough` (direciona para opus). Consulte [docs/MODEL-ROUTING.md](docs/MODEL-ROUTING.md) para a tabela completa de roteamento.

---

## Comandos

### Pipeline completo
```
/unity-workflow <descricao>   Esclarecer -> Planejar -> Executar -> Verificar (fluxo recomendado)
```

### Fluxo de trabalho diario
```
/unity-feature <descricao>    Planejar + implementar uma funcionalidade (--quick para tarefas simples)
/unity-fix <bug ou erro>      Diagnosticar e corrigir um bug (--quick para correcoes obvias)
/unity-prototype <mecanica>   De um prompt a prototipo jogavel
/unity-scene <descricao>      Construir uma cena via MCP
/unity-shader <descricao>     Criar shaders com preview ao vivo
/unity-ui <descricao tela>    Construir UI com configuracao visual
/unity-network <framework>    Configurar multiplayer
```

### Quality gates
```
/unity-review [escopo]        Revisao de codigo (--thorough para analise profunda)
/unity-optimize               Profiling via MCP + corrigir gargalos
/unity-test                   Escrever + executar testes via MCP
/unity-audit                  Verificacao completa de saude do projeto
/unity-profile                Sessao de profiling profundo
```

### Orquestracao
```
/unity-ralph [opcoes]         Loop persistente de verificacao-correcao (nao para ate ficar limpo)
/unity-team <--preset|--custom> Agentes em paralelo (coder + tester + reviewer simultaneamente)
/unity-interview <topico>     Entrevista socratica profunda de requisitos antes de programar
/unity-learn [subcomando]     Analitica de sessao: revisar, extrair padroes, rascunhar skills
```

### Ciclo de vida do projeto
```
/unity-init                   Escanear projeto + gerar CLAUDE.md
/unity-build                  Configurar + disparar builds
/unity-migrate                Planejar migracao de versao/pipeline
/unity-doctor                 Verificacao diagnostica (MCP, hooks, estrutura do projeto)
```

---

## Hooks

22 hooks em 5 eventos de ciclo de vida, organizados por nivel de perfil.

### Hooks de bloqueio — PreToolUse (perfil minimal)
| Hook | O que previne |
|------|-----------------|
| `block-scene-edit` | Edicao direta de texto em YAML .unity/.prefab (corrompe referencias) |
| `block-meta-edit` | Edicao de arquivos .meta (quebra GUIDs de assets) |
| `block-projectsettings` | Staging de ProjectSettings/ via git (usar MCP em vez disso) |
| `guard-editor-runtime` | Namespace `UnityEditor` em codigo runtime sem `#if UNITY_EDITOR` |
| `guard-project-config` | Enfraquecimento de regras de qualidade de codigo (.editorconfig, configuracoes de analyzers, .csproj NoWarn) |

### GateGuard — PreToolUse (perfil strict)
| Hook | O que faz |
|------|-------------|
| `gateguard` | Bloqueia Edit/Write em arquivos C# ate que o agente os tenha lido (Read) primeiro. Previne mudancas alucinadas. Para arquivos MVS, sugere ler as contrapartes Model/System. |

### Hooks de qualidade — PostToolUse (perfil standard)
| Hook | O que detecta |
|------|----------------|
| `warn-serialization` | Campo renomeado sem `[FormerlySerializedAs]` (perda silenciosa de dados) |
| `warn-filename` | Nome de arquivo C# nao coincide com nome da classe (script nao anexa) |
| `warn-platform-defines` | `#if UNITY_ANDROID` sem fallback `#else` |
| `quality-gate` | GetComponent no Update, LINQ em gameplay, `?.` em objetos Unity, Camera.main sem cache, SendMessage |
| `validate-commit` | Arquivos .meta faltando, problemas de qualidade de codigo no commit |
| `suggest-verify` | Sugere `/unity-review` apos modificar 5+ arquivos C# |
| `build-analyze` | Pos-build: contagem de variantes de shader, tamanho, problemas de stripping, APIs obsoletas |

### Hooks de rastreamento — PostToolUse (perfil standard/strict)
| Hook | O que registra |
|------|----------------|
| `track-edits` | Arquivos modificados durante a sessao (standard) |
| `track-reads` | Arquivos lidos durante a sessao — alimenta GateGuard (strict) |
| `cost-tracker` | Cada chamada de ferramenta com timestamp para metricas de sessao (strict) |

### Hooks de sessao — SessionStart / Stop
| Hook | Ciclo de vida | O que faz |
|------|-----------|-------------|
| `session-restore` | SessionStart | Restaura o branch anterior, fase do workflow, lista de arquivos modificados |
| `session-save` | Stop | Salva o estado da sessao para a proxima conversa (branch, edicoes, duracao) |
| `stop-validate` | Stop | Executa validacao completa em todos os arquivos C# modificados durante a sessao |
| `auto-learn` | Stop | Captura padroes de sessao (separacao MVS, uso de ferramentas, categoria) no log de aprendizado |
| `notify` | Stop | Envia notificacao por webhook (Discord/Slack) quando a sessao excede a duracao minima |

### Hooks de aviso — PreCompact
| Hook | O que faz |
|------|-------------|
| `pre-compact` | Salva o estado do git antes da compactacao de contexto |

Todos os hooks suportam chaves de desativacao via variaveis de ambiente. Consulte [Perfis de hooks](#perfis-de-hooks) acima.

---

## Templates de arquitetura MVS

Templates para o padrao **Model-View-System** com VContainer, MessagePipe e UniTask:

| Template | Finalidade |
|----------|---------|
| `Model.cs.template` | Classe C# pura de dados com `ReactiveProperty<T>` — sem dependencias Unity |
| `System.cs.template` | Classe C# pura com injecao de construtor VContainer, `IDisposable` |
| `View.cs.template` | MonoBehaviour que observa o Model via `Subscribe()`, injecao de metodo |
| `LifetimeScope.cs.template` | Raiz de composicao VContainer com registro de Model/System/View/MessagePipe |
| `Message.cs.template` | `readonly struct` para MessagePipe — zero alocacao no heap |

Alem dos templates originais: `MonoBehaviour.cs`, `ScriptableObject.cs`, `EditModeTest.cs`, `PlayModeTest.cs`, `AssemblyDefinition.asmdef`.

---

## Skills

### Core sempre ativo (8)
- **serialization-safety** — `[FormerlySerializedAs]`, `[SerializeField]`, verificacoes de null no Unity
- **scriptable-objects** — Canais de eventos SO, referencias de variaveis, runtime sets, padrao factory
- **event-systems** — Eventos C#, UnityEvent, canais SO, EventBus sem alocacoes
- **object-pooling** — `ObjectPool<T>`, aquecimento, ciclo de vida de retorno ao pool
- **assembly-definitions** — Quando separar, regras de referencia, separacao Editor/Runtime
- **unity-mcp-patterns** — Como usar as ferramentas MCP eficazmente (`batch_execute`, `read_console`)
- **learner** — Extracao de conhecimento pos-depuracao com quality gates e pontuacao de confianca
- **hud-statusline** — Integracao com a linha de status do Claude Code mostrando fase do workflow e metricas de sessao

### Sistemas Unity (10)
URP pipeline, Input System, Addressables, Cinemachine, Animation, Audio, Physics, NavMesh, UI Toolkit, ShaderGraph

### Padroes de gameplay (6)
Controlador de personagem (2D/3D), sistema de inventario, sistema de dialogo, sistema de save, maquina de estados, geracao procedural

### Blueprints de genero (8) — Foco em mobile
Hyper-casual, Match-3, Idle/Clicker, Endless Runner, Puzzle, RPG, 2D Platformer, Top-down

### Terceiros (5)
DOTween, UniTask, VContainer, TextMeshPro, Odin Inspector

### Plataforma (1)
Otimizacao mobile (iOS + Android) — entrada por toque, areas seguras, texturas ASTC, thermal throttling, gerenciamento de bateria

---

## Regras de programacao

O toolkit aplica as melhores praticas do Unity atraves de 5 arquivos de regras sempre carregados:

- **csharp-unity** — `[SerializeField] private` com prefixo `_lowerCamelCase`, sealed por padrao, tipos explicitos
- **performance** — Zero alocacoes no Update, cachear GetComponent, pool de objetos, sem LINQ em gameplay
- **serialization** — `[FormerlySerializedAs]` ao renomear, `obj == null` em vez de `obj?.`
- **architecture** — Padrao MVS, VContainer para DI, MessagePipe para eventos, UniTask para async
- **unity-specifics** — Separacao Editor/Runtime, threading, ciclo de vida de coroutines, perigo do `?.`

---

## Scripts de validacao

Execute estes para verificar a saude do projeto:

```bash
./scripts/validate-meta-integrity.sh --all    # Arquivos .meta faltando/orfaos, GUIDs duplicados
./scripts/validate-code-quality.sh            # Problemas de performance em codigo C#
./scripts/validate-asmdefs.sh                 # Dependencias circulares em assembly definitions
./scripts/detect-missing-refs.sh              # Referencias quebradas em cenas/prefabs
./scripts/analyze-build-size.sh               # Analise de tamanho de build a partir do Editor.log
./scripts/validate-serialization.sh           # Campos renomeados sem FormerlySerializedAs
./scripts/validate-architecture.sh            # Verificacoes de conformidade com o padrao MVS
./scripts/generate-claude-md.sh > CLAUDE.md   # Auto-gerar CLAUDE.md do projeto
```

---

## Arquivos CLAUDE.md de exemplo

Configuracoes pre-construidas para tipos de jogos mobile:

- `examples/CLAUDE.md.hyper-casual` — Controles de um toque, visuais minimos, monetizacao com anuncios
- `examples/CLAUDE.md.match3` — Sistema de grade, cascatas, tiles especiais, vidas/energia
- `examples/CLAUDE.md.idle-clicker` — Numeros grandes, progresso offline, sistema de prestigio
- `examples/CLAUDE.md.mobile-casual` — Entrada por toque, build pequeno, integracao de anuncios
- `examples/CLAUDE.md.2d-platformer` — Tilemap, joystick virtual, otimizado para mobile
- `examples/CLAUDE.md.rpg` — Atributos, inventario, dialogos, controles por toque

---

## Arquitetura

### Pipeline de workflow

```
/unity-workflow "add combo scoring"
    |
    +-- Phase 1: Clarify   -- Entrevista sobre requisitos, restricoes, plataforma
    +-- Phase 2: Plan      -- Escanear projeto, escolher agentes, apresentar plano de implementacao
    +-- Phase 3: Execute   -- Rotear para unity-coder / unity-prototyper / unity-ui-builder
    +-- Phase 4: Verify    -- unity-verifier executa revisao -> auto-correcao -> re-verificacao
```

### Interacao entre agentes

```
Prompt do usuario
    |
    v
Command (orquestra o workflow)
    |
    +-->  Code Agent (escreve scripts C#, carrega skills relevantes)
    |       |
    |       +--> MCP Tools (cria GameObjects, configura componentes)
    |
    +-->  Verifier Agent (revisa mudancas, auto-corrige, re-verifica)
    |
    +-->  Test Agent (escreve + executa testes via MCP)
    |
    +-->  Optimizer Agent (profiling via MCP, corrige gargalos)
```

### Rede de seguranca de hooks

```
Claude tenta editar PlayerView.cs
    |
    +-->  _lib.sh: verificar nivel de perfil, chaves de desativacao
    +-->  PreToolUse: guard-editor-runtime.sh -- Guarda de UnityEditor
    +-->  PreToolUse: gateguard.sh -- este arquivo foi lido primeiro? [strict]
    |                               sugere ler tambem PlayerModel.cs
    |
    +-->  [A edicao acontece]
    |
    +-->  PostToolUse: warn-serialization.sh -- verificacao de renomeacao de campo
    |                  quality-gate.sh -- GetComponent no Update? LINQ? ?.?
    |                  track-edits.sh -- registrar para metricas de sessao
    |
    +-->  [A sessao termina]
         +-->  stop-validate.sh -- verificacao completa de todos os C# modificados
         +-->  session-save.sh -- persistir estado para a proxima conversa
         +-->  auto-learn.sh -- registrar padroes de sessao
```

### Ciclo de vida da sessao

```
SessionStart
    +-->  session-restore.sh -- carregar estado anterior (branch, fase, arquivos)

[... trabalho em andamento, rastreado por hooks ...]

Stop
    +-->  stop-validate.sh -- validacao em lote de todos os arquivos modificados
    +-->  session-save.sh -- salvar estado em /tmp/unity-claude-hooks/
    +-->  auto-learn.sh -- adicionar metricas de sessao a learnings.jsonl
```

---

## Documentacao

| Guia | Finalidade |
|-------|---------|
| [Getting Started](docs/GETTING-STARTED.md) | Instalacao, primeira execucao, solucao de problemas |
| [Architecture](docs/ARCHITECTURE.md) | Filosofia de design, visao geral de componentes, sistema de hooks, pipeline de workflow |
| [Agent Guide](docs/AGENT-GUIDE.md) | Todos os 18 agentes, quando usar cada um, customizacao |
| [Model Routing](docs/MODEL-ROUTING.md) | Atribuicao de modelos aos agentes, flags `--quick`/`--thorough`, trade-offs de custo |
| [MCP Setup](docs/MCP-SETUP.md) | Instalacao do unity-mcp, verificacao, solucao de problemas |

---

## Contribuindo

Consulte [CONTRIBUTING.md](CONTRIBUTING.md) para as diretrizes.

Areas chave onde contribuicoes sao bem-vindas:
- Novas skills de generos mobile (tower defense, corrida, cartas/gacha, simulacao)
- Novas skills de sistemas (ProBuilder, Spline, 2D Animation)
- Skills de plataforma mobile (ARKit/ARCore, notificacoes, deep links)
- Skills de frameworks de networking para mobile (FishNet, Dark Rift)
- Relatorios de bugs e melhorias de hooks

---

## Licenca

MIT License. Consulte [LICENSE](LICENSE) para detalhes.
