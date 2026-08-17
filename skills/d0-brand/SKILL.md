---
name: d0-brand
description: D0 / Donut 品牌 token 全局参考。所有生成 D0 品牌 HTML、HyperFrames、Remotion 输出的 skill 必须以本文件为字体、字号的唯一权威来源。颜色规范待内部新标准确定后补入。不直接触发，由其他 skill 引用。
---

# D0 Brand Tokens — 全局权威来源

> 本文件是 D0 品牌视觉 token 的唯一真相。
> 所有 skill（d0-poster、HyperFrames、Remotion）产出的字体、字号均应以此为准。
> **颜色规范待内部新标准确定后补入，暂不自行定义。**

---

## 字体系统

### 规则
- 全局**只使用两种字体**：`Instrument Serif` 和 `Open Sans`
- 同一语义区块（headline、body、caption 等）内只用**一种**字体，不混排
- 区块内的变化通过 `font-weight`（400 / 600 / 700 / 800）、`font-style`（normal / italic）、`font-size` 实现

### 字体分工

| 字体 | 用途 |
|------|------|
| `Instrument Serif` | 大数据锚点、Hero 标题、视觉焦点文字 |
| `Open Sans` | 副标题、正文、说明、UI 标签、CTA、脚注 |

> `Noto Sans SC` 仅在有中文内容时作为 `Open Sans` 的 CJK 补充，不作为独立主字体使用。

### Google Fonts 加载（HTML 用）

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1&family=Open+Sans:ital,wght@0,400;0,600;0,700;0,800;1,400;1,600&family=Noto+Sans+SC:wght@400;600;700&display=swap" rel="stylesheet">
```

### CSS 变量

```css
--font-display: 'Instrument Serif', Georgia, serif;
--font-body:    'Open Sans', 'Noto Sans SC', -apple-system, sans-serif;
```

---

## 颜色系统

> **⚠️ 待补入** — 内部新颜色规范制定中，确定后更新此节。
> 在此之前，各 skill 暂时保持现有颜色值，不做新的颜色决策。

---

## 字号系统

### HTML 海报（1600×900 固定画布）

```css
--size-anchor:    300px;   /* 大数据锚点，1-2 位数，Instrument Serif */
--size-anchor-3:  180px;   /* 大数据锚点，3 位数，Instrument Serif */
--size-hero:       58px;   /* Hero 标题，Instrument Serif */
--size-subtitle:   21px;   /* 副标题，Open Sans */
--size-body:       16px;   /* 正文，Open Sans */
--size-label:      13px;   /* 标签、pill，Open Sans */
--size-fine:       11px;   /* 脚注、fine print，Open Sans */
```

### HTML 响应式（clamp，参考宽度 1600px）

```css
--size-hero-resp:     clamp(36px, 3.625vw, 58px);
--size-subtitle-resp: clamp(16px, 1.3125vw, 21px);
--size-body-resp:     clamp(14px, 1vw, 16px);
```

### Remotion 视频（1920×1080 基准）

```css
/* hero: 96px / headline: 64px / title: 48px / subtitle: 36px / body: 24px / caption: 18px */
/* 详见 d0-remotion/src/brand/donut-brand-tokens.ts typography.sizes.video */
```

---

## 视觉风格 token

```css
/* 胶片颗粒（SVG feTurbulence，overlay 混合模式） */
--film-grain-opacity: 0.045;

/* 光晕（发光元素用） */
--halation-blur:    24px;
--halation-opacity: 0.3;

/* 暗角（全出血场景叠加） */
--vignette: radial-gradient(ellipse at 50% 50%, transparent 40%, rgba(0,0,0,0.85) 100%);

/* 色彩分级（仅用于背景底图层，不包裹文字/UI） */
--color-grade: saturate(0.75) contrast(1.15) brightness(0.92);
```

---

## 动效 token（Remotion / HyperFrames）

```
easing
  cinematic:  cubic-bezier(0.16, 1, 0.3, 1)   // 慢入极慢出，品牌标准
  fadeIn:     cubic-bezier(0.4, 0, 0.6, 1)
  snappy:     cubic-bezier(0.4, 0, 1, 1)

timing（30fps 基准）
  ultraFast: 6f   (0.2s)
  fast:      15f  (0.5s)
  normal:    24f  (0.8s)
  slow:      45f  (1.5s)
  hold:      60f  (2.0s)

stagger
  tight: 3f / normal: 6f / loose: 12f
```

---

## 品牌原则（不受颜色规范影响的部分）

1. **字体只有 Instrument Serif 和 Open Sans，同区块内不混排**
2. **动画从极简开始，按需叠加光效，不默认堆砌特效**
3. **colorGrade filter 只用于背景层，不包裹含文字/UI 的容器**
4. **光效（glow / halation）优于实心 UI 元素**
