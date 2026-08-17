---
name: d0-hyperframe
description: 用 HyperFrames 制作 D0 品牌视频。包含素材提取、项目搭建、场景布局、GSAP 动画、TG 组件规范、转场规则。当用户说"做一个 D0 视频"、"d0 hyperframe"、"用 hyperframes 做视频"、"/d0-hyperframe" 时使用。
---

# D0 HyperFrame 视频制作

用 HyperFrames HTML + GSAP 制作 D0 品牌视频的完整工作流。
以本文件为**唯一权威**——字体、色彩、布局、动画、转场规则均在此定义。

> **字体规范以 `d0-brand` skill 为最终权威，本 skill 仅复写视频制作相关的补充规定。**

---

## 触发词

- "做一个 D0 视频" / "d0 hyperframe"
- "用 hyperframes 做视频" / "/d0-hyperframe"

---

## Step 0 — 初始化项目与素材

### 推荐：使用随 Skill 提供的初始化脚本

安装仓库后，运行本 Skill 内的脚本。它会初始化 HyperFrames 项目，并复制 D0 Logo、D0 头像和全部所需字体：

```bash
bash "${CODEX_HOME:-$HOME/.codex}/skills/d0-hyperframe/scripts/bootstrap_project.sh" .
```

如果项目已经初始化，只同步品牌素材：

```bash
bash "${CODEX_HOME:-$HOME/.codex}/skills/d0-hyperframe/scripts/bootstrap_project.sh" . --assets-only
```

脚本依赖 Node.js 18+ 与 `npx`。HyperFrames CLI 通过 `npx hyperframes@latest` 按需运行，不在 Skill 仓库中复制第三方包。

### 可选：从源 HTML 覆盖 D0_AVATAR 和 Logo

### 从源 HTML 提取 D0_AVATAR 和 Logo

源海报 HTML 通常内嵌两类 base64 图片：

| 资产 | 类型 | 特征 | 用途 |
|------|------|------|------|
| D0 Logo | PNG，约 12–16 KB | `.brand img` 或最短 PNG | 所有场景左上角 |
| D0_AVATAR | JPEG，约 100 KB | `.av` 或最长 JPEG | TG 组件头像 |

```python
python3 - << 'EOF'
import re, base64, os

with open('SOURCE.html', 'r') as f:
    src = f.read()

os.makedirs('assets', exist_ok=True)

# Logo (最短 PNG)
pngs = re.findall(r'(data:image/png;base64,[A-Za-z0-9+/=]+)', src)
logo_b64 = min(pngs, key=len)
with open('assets/d0-logo.png', 'wb') as f:
    f.write(base64.b64decode(logo_b64.split(',')[1]))

# D0_AVATAR (最长 JPEG)
jpegs = re.findall(r'data:image/jpeg;base64,([A-Za-z0-9+/=]+)', src)
avatar = max(jpegs, key=len)
with open('assets/d0-avatar.jpg', 'wb') as f:
    f.write(base64.b64decode(avatar))

print("assets/ ready:", os.listdir('assets'))
EOF
```

### 字体（手动方式）

```bash
mkdir -p fonts
cp /path/to/d0-hyperframe/assets/fonts/*.woff2 fonts/
# 需要：InstrumentSerif-Regular.woff2, InstrumentSerif-Italic.woff2
#       OpenSans-400/600/700/800-normal.woff2
```

### 项目初始化（手动方式）

```bash
npx hyperframes@latest init . --non-interactive --example blank --skill=d0-hyperframe
```

---

## Step 1 — 品牌 Token（CSS）

```css
:root {
  --bg:    #06060d;
  --pu2:   #b3a8f7;
  --white: #f2f2f5;
  --t2:    #8d8d98;
  --t3:    #5a5a66;
  --green: #3ddc84;
  --red:   #f87171;
  --gold:  #f7a93a;
  --bdr:   #23232c;
  --bdr2:  #2e2e39;
  --grad:  linear-gradient(120deg, #5468F5 0%, #9B4FD6 34%, #C25C9A 62%, #DD8B57 100%);
}

@font-face { font-family:'Instrument Serif'; src:url('fonts/InstrumentSerif-Regular.woff2') format('woff2'); font-weight:400; font-style:normal; }
@font-face { font-family:'Instrument Serif'; src:url('fonts/InstrumentSerif-Italic.woff2')  format('woff2'); font-weight:400; font-style:italic; }
@font-face { font-family:'Open Sans'; src:url('fonts/OpenSans-400-normal.woff2') format('woff2'); font-weight:400; }
@font-face { font-family:'Open Sans'; src:url('fonts/OpenSans-600-normal.woff2') format('woff2'); font-weight:600; }
@font-face { font-family:'Open Sans'; src:url('fonts/OpenSans-700-normal.woff2') format('woff2'); font-weight:700; }
@font-face { font-family:'Open Sans'; src:url('fonts/OpenSans-800-normal.woff2') format('woff2'); font-weight:800; }
```

---

## Step 2 — 舞台结构（持久 stage + 组件层）

> **核心模型:一层固定背景舞台,内容拆成组件。**
> 背景 + 固定元素(logo/footer/顶部轨道)属于**持久层**,全程不动;标题、数据、TG 面板、图表等每个都是独立的 `.blk` 组件,各自入场/退场。转场发生在**组件级**,不是整屏级——这是摆脱"PPT 硬切"的根本。

### HTML 骨架

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>D0 · [视频标题]</title>
<style>/* tokens + scene CSS */</style>
</head>
<body>
<div id="main"
  data-composition-id="main"
  data-start="0"
  data-duration="[总秒数]"
  data-width="1920"
  data-height="1080">

  <!-- ── 持久层：全程不动，不写任何 tl 动画（见 Step 3） ── -->
  <div class="bg"></div>
  <div class="rail"></div>
  <div class="logo"></div>
  <div class="foot-tag">Agentic Trading for Every Market.</div>
  <div class="foot-url">getdonut.ai</div>

  <!-- ── 内容层：按 beat 分组，组件各自交错进出（见 Step 6） ── -->
  <!-- beat 1 -->
  <div class="blk" id="b1-title">...</div>
  <div class="blk" id="b1-sub">...</div>
  <!-- beat 2 -->
  <div class="blk" id="b2-stat">...</div>
  <div class="blk" id="b2-tg">...</div>

</div>
<script src="https://cdn.jsdelivr.net/npm/gsap@3.14.2/dist/gsap.min.js"></script>
<script>/* GSAP timeline */</script>
</body>
</html>
```

### 舞台 CSS（持久层 + 内容层）

```css
/* 舞台容器 */
#main {
  position: absolute; inset: 0; overflow: hidden;
  font-family: 'Open Sans', sans-serif; color: var(--white);
}

/* 持久背景 — 全程固定，永不进入 tl 动画 */
.bg {
  position: absolute; inset: 0; width: 1920px; height: 1080px; z-index: 0;
  background: var(--bg);
  background-image:
    radial-gradient(ellipse 46% 58% at 76% 50%, rgba(150,128,255,.16) 0%, transparent 60%),
    radial-gradient(ellipse 62% 50% at 8%   4%, rgba(110,100,255,.10) 0%, transparent 56%);
}

/* 顶部渐变轨道 — 固定，全片只需一条 */
.rail {
  position: absolute; top: 0; left: 0; right: 0; height: 5px; z-index: 10;
  background: var(--grad);
}

/* 内容组件 — 动画的最小单元，默认隐藏，各自进出 */
.blk { position: absolute; opacity: 0; z-index: 2; }
```

> 旧模型每个整屏 `.scene` 自带背景、整块滑动 → PPT 感 + 卡点。
> 新模型只有**一层固定背景**,内容拆成 `.blk` 组件,转场发生在组件级(见 Step 6)。

---

## Step 3 — 固定元素规范（非协商）

以下三个元素在**所有场景**中保持一致，**不写入场或出场动画**：

| 元素 | 位置 | 字号 | 说明 |
|------|------|------|------|
| Donut Logo | 左上 `top:40px left:72px` | 200×76px | CSS background，不用 `<img>` |
| Agentic Trading for Every Market. | 左下 `bottom:48px left:72px` | 27px | Instrument Serif italic，`--pu2` |
| getdonut.ai | 右下 `bottom:50px right:72px` | 14px | Open Sans，`--t3` |

```css
/* Logo — CSS background，不写 opacity:0 */
.logo {
  position: absolute; top: 40px; left: 72px; z-index: 10;
  width: 200px; height: 76px;
  background: url('assets/d0-logo.png') left center / contain no-repeat;
}

/* Footer — 直接可见，无动画 */
.foot-tag {
  position: absolute; bottom: 48px; left: 72px; z-index: 10;
  font-family: 'Instrument Serif', serif; font-style: italic;
  font-size: 27px; color: var(--pu2);
}

.foot-url {
  position: absolute; bottom: 50px; right: 72px; z-index: 10;
  font-size: 14px; font-weight: 700; letter-spacing: .06em; color: var(--t3); opacity: 0;
}
```

> 固定元素属于**持久层**，从第 0 帧即可见，**全程不写任何 tl 动画**。
> `foot-tag` 直接可见;`foot-url` 可保留一次性轻微淡入，但不强制。

---

## Step 4 — 布局原则

### 左右均衡，消除中心空白

- **双列布局优先**：文案 / 数据在左，TG 组件 / 图像在右
- **右侧有角色背景图时**：绝对定位铺满右侧，叠加从左到右的渐变遮罩

```css
.scene-char {
  position: absolute; top:0; right:0; bottom:0; width:62%;
  background: url('assets/bg-char.png') right center / cover no-repeat;
  z-index: 0;
}
.scene-char::after {
  content:''; position:absolute; inset:0;
  background: linear-gradient(to right,
    var(--bg) 0%, rgba(6,6,13,.82) 18%, rgba(6,6,13,.45) 45%, transparent 100%);
}
```

- 左侧文案区设 `position: relative; z-index: 2` 确保叠在背景图之上

### 字号最小标准

以 D0 Thorp Engine 视频为基准，不得低于：

| 层级 | 最小字号 | 字体 |
|------|----------|------|
| 主标题 | 80px | Instrument Serif |
| 场景副标题 | 56px | Instrument Serif |
| Kick label / eyebrow | 18px | Open Sans 700 uppercase |
| 正文 / feature bullet | 22px | Open Sans |
| 数据锚点 (stat-val) | 48px | Instrument Serif |
| Footer tag | 27px | Instrument Serif italic |
| TG 组件内文字 | 13px（可接受最小值）| Open Sans |

---

## Step 5 — TG 组件规范

### 头像：必须使用 D0_AVATAR

```css
/* 大头像（header，40px） */
.av  { width:40px; height:40px; border-radius:50%; flex:none;
       background: url('assets/d0-avatar.jpg') center/cover no-repeat; }

/* 小头像（消息行，28px） */
.mav { width:28px; height:28px; border-radius:50%; flex:none; margin-top:2px;
       background: url('assets/d0-avatar.jpg') center/cover no-repeat; }
```

**不使用 `<img>` 标签**，避免 HyperFrames 检测到重复 media 节点（lint warning）。
**不使用渐变 fallback**，必须是真实 D0_AVATAR 文件。

### TG Panel 结构

```html
<div id="tg-panel">
  <div class="tg-chrome">
    <div class="dot r"></div><div class="dot y"></div><div class="dot g"></div>
    <div class="tg-url">t.me / D0_Bot</div>
  </div>
  <div class="tg-hdr">
    <div class="av"></div>
    <div>
      <div class="tg-nm">D0</div>
      <div class="tg-st">bot · online</div>
    </div>
  </div>
  <div class="tg-body">
    <div class="msg-user">用户 prompt</div>
    <div class="msg-bot">
      <div class="mav"></div>
      <div class="bbubble">D0 回复内容</div>
    </div>
  </div>
</div>
```

---

## Step 6 — 转场规则（非协商）

> **核心原则:背景不动,组件动。**
> "PPT 感"来自**整块 scene(含背景)一起滑走**——观众失去稳定锚点;
> "卡点"来自 out 动画和 in 动画**首尾相接**——中间有一瞬全静止。
> 两者的解法都是同一句话:**固定背景 + 组件交错、进出重叠**。

### 默认转场:组件级交错进出（element cross-stagger）

背景 + 固定元素(logo/footer/rail)**全程不动**。每次 beat 切换只让**内容组件**动:

- 旧 beat 组件**依次**退场(stagger,`.in` ease,细微位移 + 淡出)
- 新 beat 组件**依次**入场(stagger,`.out` ease)
- 两者时间上**重叠 ≈ 0.2–0.3s**——旧的还没退完,新的已经开始进。**这是消除卡点的关键。**

```js
// beat 切换:旧组交错退场，新组交错入场，时间交叠（不是首尾相接）
function beat(outEls, inEls, t) {
  outEls.forEach((el, i) =>
    tl.to(el, { opacity:0, y:-30, duration:0.45, ease:'power2.in' }, t + i*0.06));
  inEls.forEach((el, i) =>
    tl.fromTo(el, { opacity:0, y:40 },
      { opacity:1, y:0, duration:0.6, ease:'expo.out' }, t + 0.2 + i*0.08));  // +0.2 = 重叠
}
// 用法：beat(['#b1-title','#b1-sub'], ['#b2-stat','#b2-tg'], 4.0);
```

- 位移量小(20–40px);方向可统一(如都向上走)营造"翻页气流",但**背景绝不参与**。
- 组件多时靠 stagger 让画面持续有动作,避免"同时入场 → 一起冻住"。

### 何时才用整屏转场

仅在**大分段**(如品牌标题卡 → 数据段)偶尔使用,且**只推内容层,不推背景**——把该段组件包进一个 `#grp` 容器再推:

```js
// Push-slide（仅推内容容器，背景 .bg 不动）
tl.to('#grpA',     { x:-1920, duration:0.55, ease:'power3.inOut' }, t);
tl.fromTo('#grpB', { x:1920, opacity:1 }, { x:0, duration:0.55, ease:'power3.inOut' }, t);

// Blur crossfade（情绪转场，通常用于最后一次过渡）
tl.to('#grpC', { filter:'blur(20px)', opacity:0, duration:0.65, ease:'power2.in' }, t);
tl.fromTo('#grpD', { filter:'blur(20px)', opacity:0 },
  { filter:'blur(0px)', opacity:1, duration:0.65, ease:'power2.out' }, t);
```

❌ **禁止**:整块 scene(含背景)滑走、角落缩放、整屏 zoom、out/in 首尾相接无重叠。

---

## Step 7 — GSAP 动画规则

### 必须遵守

```js
const tl = gsap.timeline({ paused: true });
// ...tweens...
window.__timelines['main'] = tl;
```

- 用 `tl.fromTo()` 而非 `tl.from()`（确保 HyperFrames seek 确定性）
- 重复动画用 `Math.floor(duration / cycle) - 1`，禁止 `repeat: -1`
- 同一元素多组动画加 `overwrite: 'auto'`
- 入场用 `.out` easing，出场用 `.in` easing

### 布局优先，动画其次

先写元素的**最终状态**（CSS 定位），再用 `fromTo` 描述入场路径：

```js
// ✅ 正确
tl.fromTo('#title', { opacity:0, y:40 }, { opacity:1, y:0, duration:0.8, ease:'expo.out' }, 0.3);
```

### 持久层不加动画

`.bg`、`.rail`、`.logo`、`.foot-tag`、`.foot-url` 全程固定，动画只发生在 `.blk` 组件上。**背景一旦参与移动，立刻回到 PPT 感**——转场只动内容层（见 Step 6 `beat()`）。

---

## Step 8 — Lint & 预览

```bash
npx hyperframes lint     # 必须 0 errors
npx hyperframes preview  # http://localhost:300x，热重载
```

| 常见 warning | 处理 |
|---|---|
| `overlapping_gsap_tweens` | 加 `overwrite:'auto'` |
| `duplicate_media_discovery_risk` | 改用 CSS `background:url()` 替代 `<img>` |
| `composition_file_too_large` | 单文件 <500 行时可忽略 |

---

## 依赖与资产来源

- `d0-brand` Skill：字体、字号和品牌原则的最终权威，必须与本 Skill 一起安装。
- HyperFrames CLI：通过 `npx hyperframes@latest` 按需获取。
- GSAP：示例固定使用 `3.14.2` CDN 版本；如升级版本，先重新执行 lint 与 seek 验证。
- `assets/fonts/`：Instrument Serif 与 Open Sans；许可文件位于对应字体目录。
- `assets/brand/`：D0 Logo 与 D0 头像，仅供获得授权的 Donut 团队成员用于 D0 品牌内容。
