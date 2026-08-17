# D0 HyperFrame Skill

供 Donut 团队在 Codex 中制作 D0 品牌 HyperFrames 视频的内部 Skill 包。仓库同时包含品牌规范依赖、字体、D0 Logo、D0 头像、安装脚本和项目初始化脚本。

## 一键安装

需要 Git、Python 3，以及 Node.js 18+（创建视频项目时使用）。

```bash
git clone https://github.com/scof-real/d0-hyperframe-skill.git
cd d0-hyperframe-skill
./install.sh
```

安装脚本会把 `d0-brand` 和 `d0-hyperframe` 安装到 `${CODEX_HOME:-$HOME/.codex}/skills`。如果已有同名 Skill，会先备份到 `.d0-skill-backups/<时间戳>/`。

安装后重启 Codex，然后直接说：

```text
使用 d0-hyperframe 做一个 D0 品牌视频：……
```

## 创建项目

Skill 会优先调用随包提供的初始化脚本。也可以手动运行：

```bash
bash "${CODEX_HOME:-$HOME/.codex}/skills/d0-hyperframe/scripts/bootstrap_project.sh" ./my-video
```

它会：

1. 通过 `npx hyperframes@latest init . --non-interactive --example blank --skill=d0-hyperframe` 初始化项目；
2. 复制 Instrument Serif 与 Open Sans 字体；
3. 复制 D0 Logo 和 D0 头像；
4. 让项目可以直接按 Skill 中的布局、动画和 TG 组件规范制作。

已有 HyperFrames 项目只同步素材：

```bash
bash "${CODEX_HOME:-$HOME/.codex}/skills/d0-hyperframe/scripts/bootstrap_project.sh" ./existing-video --assets-only
```

## 包含内容

- `skills/d0-hyperframe/`：完整制作流程、品牌素材、字体、初始化脚本。
- `skills/d0-brand/`：字体、字号、品牌原则的全局权威依赖。
- `install.sh`：可重复执行的本机安装器，并自动备份旧版本。
- `scripts/validate.py`：仓库与安装结果自检。

## 验证

```bash
python3 scripts/validate.py
bash -n install.sh skills/d0-hyperframe/scripts/bootstrap_project.sh
```

## 权限与第三方依赖

本仓库面向获得授权的 Donut 团队成员。D0 Logo 和头像不授予团队外使用权。Instrument Serif 与 Open Sans 分别按随字体附带的 SIL Open Font License 1.1 分发。HyperFrames CLI 与 GSAP 不复制进仓库：前者由 `npx` 按需获取，后者由生成的视频按 Skill 固定版本从 CDN 加载。
