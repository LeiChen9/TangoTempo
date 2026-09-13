# TangoTempo

> Drive the task the way two dance steps mesh — one small step of implementation, one small step of understanding, and neither moves on without the other's feedback.

TangoTempo is a set of **agent skills** that keeps an AI coding agent and you in rhythm: small steps, immediate feedback, never spinning free. Four skills, one loop, three ecosystems — the same `SKILL.md` file runs on **GitHub Copilot, OpenAI Codex, and OpenCode** (and most other Agent Skills hosts).

中文：这是一套「小步快跑、即时反馈」的 AI agent 技能集合，让实现节奏和你的理解节奏始终咬合。

## Skills 技能组成

| Skill | Origin 归属 | Invocation 调用 | What it does |
|---|---|---|---|
| `tango-tempo` | **self-developed 自研** — this repo's core | always-on (auto) | the orchestrator: the small-steps meshing rhythm |
| `grilling` | adapted from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT) | auto (`...grill...`) or via `grill-me` | the interview: design tree, rounds, frontier, recommended answers |
| `grill-me` | from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT) | user-only (`/grill-me`) | the front door: starts a grilling session |
| `ponytail` | **self-developed 自研** | auto + `/ponytail lite\|full\|ultra` | build the laziest solution that actually works |

```
┌─────────────────────────────────────────────────┐
│  tango-tempo (always-on orchestrator)            │
│                                                  │
│    grill ──► implement ──► feedback ──► repeat   │
│   (grilling)  (ponytail)   (stop & wait)         │
│        ▲                                         │
│  grill-me (user-invoked front door)              │
└─────────────────────────────────────────────────┘
```

The loop, as small as possible:

1. **Grill** — any unclear requirement, ask via the grilling skill (`/grilling`). Don't guess.
2. **Implement** — the smallest next step (≤25 net added lines) following ponytail (`/ponytail`).
3. **Feedback** — stop, hand the change and your reasoning to the user, wait for a word.

中文：`tango-tempo` 把这个「澄清 → 最小实现 → 停下等反馈」的循环钉在每一次响应里；`grilling` 负责把含糊的想法追问成明确的决定；`ponytail` 负责把每个实现步骤做到最懒、最短、够用就停；`grill-me` 是你手动发起追问的入口。

## Install 安装

### One command, all three ecosystems（一条命令，三个生态）

Requires GitHub CLI with `gh skill` (preview):

```bash
gh skill install LeiChen9/TangoTempo --all --agent github-copilot --agent codex --agent opencode
```

- Add `--scope user` to install for every project you work on.
- Add `--scope project` to install into the current repo's `.agents/skills/` — that directory is shared by Copilot, Codex, and OpenCode, so one install serves all three.

### OpenCode via skills.sh

```bash
npx skills add LeiChen9/TangoTempo
```

### Manual（手动安装）

Clone once, symlink (or copy) each skill folder into your host's skills directory:

| Host | Personal 个人级 | Project 项目级 (in your repo) |
|---|---|---|
| OpenCode | `~/.config/opencode/skills/` | `.opencode/skills/`, `.agents/skills/` |
| OpenAI Codex | `~/.codex/skills/` | `.agents/skills/` |
| GitHub Copilot | `~/.copilot/skills/` | `.github/skills/`, `.agents/skills/` |
| Claude Code (bonus) | `~/.claude/skills/` | `.claude/skills/` |

```bash
git clone git@github.com:LeiChen9/TangoTempo.git ~/TangoTempo

ln -s ~/TangoTempo/skills/tango-tempo ~/.config/opencode/skills/tango-tempo
ln -s ~/TangoTempo/skills/grilling   ~/.config/opencode/skills/grilling
ln -s ~/TangoTempo/skills/grill-me   ~/.config/opencode/skills/grill-me
ln -s ~/TangoTempo/skills/ponytail   ~/.config/opencode/skills/ponytail
```

Restart your agent — `tango-tempo` is active from the first message.

中文：两种方式 —— ① `gh skill install` 一条命令装到三个生态；② 手工把 `skills/` 里四个文件夹软链到各生态的 skills 目录（`~/.config/opencode/skills/`、`~/.codex/skills/`、`~/.copilot/skills/` 等）。装完重启即可，`tango-tempo` 自动生效。

## Usage 用法

- **Just work.** `tango-tempo` is always on: steps stay small, results come back often, and the agent volunteers its reading of the system so you can correct it early.
- **`/grill-me`** — you have a loose idea you haven't decided anything about yet. It is user-only: the agent won't invoke it on its own.
- **`/ponytail lite|full|ultra`** — tune how hard the implementation step resists over-engineering (default `full`).
- **Slipped rhythm?** If the agent keeps getting corrected or says the same thing twice, slow down on purpose: split an even smaller step, or grill before touching code.

中文：正常用就行。`tango-tempo` 常驻生效；想法还很模糊时先 `/grill-me` 追问成明确的决定；`/ponytail` 三档可调实现有多懒；节奏脱节就要求「拆更小步 / 先追问」。

## Compatibility 兼容性

All four skills are plain **Agent Skills** — a `SKILL.md` with YAML frontmatter, following the open standard shared by GitHub Copilot, OpenAI Codex, OpenCode, Claude Code, and others.

- `agents/openai.yaml` drives the display name and invocation policy in Codex / Copilot agent UIs.
- OpenCode-specific frontmatter keys (`disable-model-invocation`) are simply ignored by hosts that don't read them.
- Every skill passes the checks `gh skill` runs before install: `name` equals its directory, `description` is ≤1024 chars, `license: MIT` declared.

中文：四份技能都是标准 Agent Skills（`SKILL.md` + frontmatter），Copilot / Codex / OpenCode 等生态通用；`agents/openai.yaml` 是 Codex 侧的界面元数据，不识别它的生态会忽略。

## Credits & license 致谢与许可

- **`tango-tempo`** and **`ponytail`** are original work.
- **`grill-me`** and **`grilling`** (including their `agents/openai.yaml`) are derived from [mattpocock/skills](https://github.com/mattpocock/skills) — MIT, © 2026 Matt Pocock. See [NOTICE.md](./NOTICE.md).

MIT © 2026 Riceball. See [LICENSE](./LICENSE).