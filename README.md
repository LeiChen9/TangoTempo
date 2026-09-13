# TangoTempo

<div align="center">

<img src="assets/tango-tempo.jpg" width="150" alt="TangoTempo logo">

**English** · [简体中文](./README-zh.md)

> Drive the task the way two dance steps mesh — one small step of implementation, one small step of understanding, and *neither moves on without the other's feedback*.

[![license](https://img.shields.io/badge/license-MIT-green)](./LICENSE)
[![runs on](https://img.shields.io/badge/runs%20on-GitHub%20Copilot%20%7C%20OpenAI%20Codex%20%7C%20OpenCode-blue)](./README.md)

</div>

## What is it

**TangoTempo** is a set of **agent skills** that keeps an AI coding agent and you in rhythm — small steps, immediate feedback, never spinning free. Four skills, one loop, three ecosystems: the same `SKILL.md` runs unchanged on **GitHub Copilot**, **OpenAI Codex**, and **OpenCode** (plus the wider Agent Skills ecosystem — Claude Code, Cursor, and more).

> **Why** — Big-bang prompts finish one breath and misfire the next. TangoTempo trades that for a meshed rhythm: the agent takes one small step, hands it back, and only moves on when it has your word. It is a working *tempo*, not a prompt.

## How it works

<img src="assets/the-loop.svg" width="860" alt="The tango-tempo loop">

The loop is as small as possible: **grill** any unclear requirement, **implement** the smallest next step (≤ 25 net lines), then **stop and hand it over for feedback**. Repeat. When the agent's reading and yours diverge, it goes back to grilling instead of pushing more steps.

## Skills

| Skill | Origin | Invocation | What it does |
|---|---|---|---|
| `tango-tempo` | **self-developed — this repo's core** | always-on (auto) | the orchestrator: the small-steps meshing rhythm |
| `grilling` | adapted from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT) | auto (`...grill...`) or via `grill-me` | the interview: design tree, rounds, frontier, recommended answers |
| `grill-me` | from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT) | user-only (`/grill-me`) | the front door — starts a grilling session |
| `ponytail` | adapted from [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) (MIT) | auto + `/ponytail lite\|full\|ultra` | build the laziest solution that actually works |

## Install

**Option 1 — one command, all three ecosystems** *(requires GitHub CLI with `gh skill`, preview)*

```bash
gh skill install LeiChen9/TangoTempo --all --agent github-copilot --agent codex --agent opencode
```

- Add `--scope user` to install for every project you work on.
- Add `--scope project` to install into the current repo's `.agents/skills/` — that directory is shared by Copilot, Codex, and OpenCode, so one install serves all three.

**Option 2 — OpenCode via skills.sh**

```bash
npx skills add LeiChen9/TangoTempo
```

**Option 3 — manual** *(clone once, symlink each folder into your host's skills dir)*

| Host | Personal | Project (in your repo) |
|---|---|---|
| OpenCode | `~/.config/opencode/skills/` | `.opencode/skills/`, `.agents/skills/` |
| OpenAI Codex | `~/.codex/skills/` | `.agents/skills/` |
| GitHub Copilot | `~/.copilot/skills/` | `.github/skills/`, `.agents/skills/` |

```bash
git clone git@github.com:LeiChen9/TangoTempo.git ~/TangoTempo

ln -s ~/TangoTempo/skills/tango-tempo ~/.config/opencode/skills/tango-tempo
ln -s ~/TangoTempo/skills/grilling   ~/.config/opencode/skills/grilling
ln -s ~/TangoTempo/skills/grill-me   ~/.config/opencode/skills/grill-me
ln -s ~/TangoTempo/skills/ponytail   ~/.config/opencode/skills/ponytail
```

Restart your agent — `tango-tempo` is active from the first message.

## Usage

- **Just work.** `tango-tempo` is always on: steps stay small, results come back often, and the agent volunteers its reading of the system so you can correct it early.
- **`/grill-me`** — you have a loose idea but haven't decided anything yet. It is user-only: the agent won't invoke it on its own.
- **`/ponytail lite|full|ultra`** — tune how aggressively the implementation step resists over-engineering (default `full`).
- **Slipped rhythm?** If the agent keeps getting corrected or repeats itself, slow down on purpose: split an even smaller step, or grill before touching code.

## Compatibility

All four skills are plain **Agent Skills** — a `SKILL.md` with YAML frontmatter, following the open standard shared by GitHub Copilot, OpenAI Codex, OpenCode, Claude Code, and others.

- `agents/openai.yaml` drives the display name and invocation policy in Codex/Copilot agent UIs.
- OpenCode-specific frontmatter keys (`disable-model-invocation`) are simply ignored by hosts that don't read them.
- Every skill passes the checks `gh skill` runs before install: `name` equals its directory, `description` ≤ 1024 chars, `license: MIT` declared.

## Credits & license

- **`tango-tempo`** is original work — this repo's core.
- **`ponytail`** is derived from [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) — MIT, © 2026 DietrichGebert.
- **`grill-me`** and **`grilling`** (including their `agents/openai.yaml`) are derived from [mattpocock/skills](https://github.com/mattpocock/skills) — MIT, © 2026 Matt Pocock.

See [NOTICE.md](./NOTICE.md) for full attribution.

MIT © 2026 Riceball. See [LICENSE](./LICENSE).