# TangoTempo

<div align="center">

<img src="assets/tango-tempo.jpg" width="150" alt="TangoTempo logo">

[English](./README.md) · **简体中文**

> 让它像两支舞步一样咬合——实现一小步、理解一小步，*没有对方的反馈，谁都不迈下一步*。

[![license](https://img.shields.io/badge/license-MIT-green)](./LICENSE)
[![runs on](https://img.shields.io/badge/runs%20on-GitHub%20Copilot%20%7C%20OpenAI%20Codex%20%7C%20OpenCode%20%7C%20Cline-blue)](./README.md)

</div>

## 这是什么

**TangoTempo** 是一套 **AI Agent 技能（skills）**，让编码 agent 和你的节奏始终咬合——小步快跑、即时反馈、永不空转。四个技能、一个循环、四个生态：同一份 `SKILL.md` 在 **GitHub Copilot**、**OpenAI Codex**、**OpenCode** 和 **Cline** 上原样运行（也兼容 Claude Code、Cursor 等更广的 Agent Skills 生态）。

> **为什么** —— 一次性大 prompt 一口气做完，下一口气就脱节。TangoTempo 换一种玩法：agent 迈一小步就交回来，收到你的反馈才继续。它定义的是工作的**节奏**，不是一段提示词。

## 工作机制

<img src="assets/the-loop.svg" width="860" alt="tango-tempo 循环图">

循环尽可能小：**澄清**（grilling 追问）任何含糊需求 → **实现**（ponytail）最小的一步（净增 ≤ 25 行）→ **停下，交回给你反馈**。如此往复。一旦 agent 的理解和你的理解出现偏差，它回到追问环节重新对齐，而不是继续硬推。

让它处处生效的是两层设计：**技能**（按需加载的机制）+ **`AGENTS.md` Gate**（常驻强制，Copilot、Codex、OpenCode、Cline 每个会话都会自动加载）。

## 技能一览

| 技能 | 归属 | 调用方式 | 作用 |
|---|---|---|---|
| `tango-tempo` | **自研 —— 本仓库核心** | 常驻（自动） | 编排器：小步咬合节奏 |
| `grilling` | 改编自 [mattpocock/skills](https://github.com/mattpocock/skills)（MIT） | 自动（带 `grill`）或经 `grill-me` | 访谈：设计树、轮次、前沿问题、推荐答案 |
| `grill-me` | 来自 [mattpocock/skills](https://github.com/mattpocock/skills)（MIT） | 仅用户（`/grill-me`） | 入口 —— 发起一次 grilling 会话 |
| `ponytail` | 改编自 [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail)（MIT） | 自动 + `/ponytail lite\|full\|ultra` | 写出真正能用的最懒解 |

## 安装

**方式一 —— 一条脚本，全部接好**（推荐）

```bash
git clone git@github.com:LeiChen9/TangoTempo.git
cd TangoTempo
./install.sh              # 自动检测已装的 agent，软链 4 个技能 + 装 Gate
./install.sh --scope project   # 项目级：装进各平台的项目目录 + $PWD/AGENTS.md
./install.sh --agents cline    # 只装某个平台：opencode | codex | copilot | cline
./uninstall.sh            # 卸载：只删软链和 Gate 标记块，你的文件一个不碰

git pull && ./install.sh  # 已经装过？重新跑一次就是「一键更新」
```

- 技能用**软链**，仓库 `git pull` 即全局更新。
- **Gate**（`AGENTS.md`）以 `<!-- BEGIN tango-tempo gate -->` … `<!-- END tango-tempo gate -->` 标记写进各平台的用户级规则文件（`~/.config/opencode/AGENTS.md`、`~/.codex/AGENTS.md`、`~/.copilot/copilot-instructions.md`、`~/Documents/Cline/Rules/tango-tempo.md`）。重复运行**只刷新这一块**：块外你写的内容绝不被读取、移动或覆盖；标记块不配对时会给出警告并完全不碰该文件。
- 这正是让 `tango-tempo` 真正**常驻**的关键：技能本身是按需加载的，而 Gate 在每个会话都会加载。

**方式二 —— 一条命令，装进 `gh skill` 支持的三个生态**（需 GitHub CLI 的 `gh skill`，预览版）

```bash
gh skill install LeiChen9/TangoTempo --all --agent github-copilot --agent codex --agent opencode
```

- 加 `--scope user` → 装到所有项目。
- 加 `--scope project` → 装进当前仓库的 `.agents/skills/` —— 该目录被 Copilot、Codex、OpenCode 共享，装一次三边生效。

**方式三 —— OpenCode 用 skills.sh**

```bash
npx skills add LeiChen9/TangoTempo
```

**方式四 —— 手动安装**（克隆一次，把各技能文件夹软链到对应目录）

| 生态 | 个人级 | 项目级（你的仓库里） |
|---|---|---|
| OpenCode | `~/.config/opencode/skills/` | `.opencode/skills/`、`.agents/skills/` |
| OpenAI Codex | `~/.codex/skills/` | `.agents/skills/` |
| GitHub Copilot | `~/.copilot/skills/` | `.github/skills/`、`.agents/skills/` |
| Cline | `~/.cline/skills/` | `.cline/skills/` |

```bash
git clone git@github.com:LeiChen9/TangoTempo.git ~/TangoTempo

ln -s ~/TangoTempo/skills/tango-tempo ~/.config/opencode/skills/tango-tempo
ln -s ~/TangoTempo/skills/grilling   ~/.config/opencode/skills/grilling
ln -s ~/TangoTempo/skills/grill-me   ~/.config/opencode/skills/grill-me
ln -s ~/TangoTempo/skills/ponytail   ~/.config/opencode/skills/ponytail
```

重启你的 agent —— `tango-tempo` 从第一句话就开始生效。

**Cline 专属说明** —— Cline 的 **rules 每会话常驻**、**skills 按需加载**，正好对上 TangoTempo 的两层设计：

- Gate 落在 `~/Documents/Cline/Rules/tango-tempo.md` —— 一个**不带 frontmatter** 的常驻规则文件，因此永远不会被 `paths:` 条件过滤掉。这就是 Cline 版的 `copilot-instructions.md`。
- 四个技能落在 `~/.cline/skills/`（项目级为 `.cline/skills/`）。Cline 既不读 `.agents/skills/`，也不读插件式目录，所以它需要独立的目标目录。
- Cline 还会**自动把仓库根目录的 `AGENTS.md` 识别为 workspace 规则**，而 workspace 规则优先级高于 global 规则 —— 所以在任何 clone 了本仓库的目录里，Gate 天生就是最高优先级，零配置。
- 两个边界：Cline 不识别 `disable-model-invocation`，因此 `grill-me` 在 Cline 上无法强制「仅用户可调用」；`install.sh` 是 bash 脚本，Windows 用户请用 Git Bash 或 WSL 运行（规则会落到 `Documents\Cline\Rules`）。

## 用法

- **正常用就行。** `tango-tempo` 常驻：步子小、回交勤，agent 会主动说出自己对系统的理解，让你尽早纠正。
- **`/grill-me`** —— 有了想法但还没想清楚时用。仅限用户调用，agent 不会自作主张。
- **`/ponytail lite|full|ultra`** —— 调节实现阶段抵抗过度工程的强度（默认 `full`）。
- **节奏脱节了？** 如果 agent 不断被纠正或重复自己说的话，就刻意放慢：拆更小的一步，或先追问再动代码。

## 兼容性

四份技能都是标准 **Agent Skills**（`SKILL.md` + YAML frontmatter），遵循 GitHub Copilot、OpenAI Codex、OpenCode、Cline、Claude Code 等共同支持的开放规范。

- `agents/openai.yaml` 提供 Codex / Copilot 侧的显示名与调用策略。
- OpenCode 专属 frontmatter 字段（`disable-model-invocation`）不识别它的生态会自动忽略。
- 每份技能都通过 `gh skill` 安装前的校验：`name` 等于目录名、`description` ≤ 1024 字符、声明 `license: MIT`。

## 致谢与许可

- **`tango-tempo`** 为原创 —— 本仓库核心。
- **`ponytail`** 改编自 [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) —— MIT，© 2026 DietrichGebert。
- **`grill-me`** 和 **`grilling`**（含其 `agents/openai.yaml`）改编自 [mattpocock/skills](https://github.com/mattpocock/skills) —— MIT，© 2026 Matt Pocock。

完整归属见 [NOTICE.md](./NOTICE.md)。

MIT © 2026 Riceball。详见 [LICENSE](./LICENSE)。