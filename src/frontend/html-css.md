# HTML and CSS

## Semantic HTML

Use elements for their meaning, not their appearance: `<header>`, `<nav>`, `<main>`, `<article>`, `<section>`, `<aside>`, `<footer>`. Benefits include accessibility, SEO, and maintainability.

## CSS Layout

- **Flexbox:** One-dimensional layout for rows or columns. Good for navigation, centering, card rows.
- **Grid:** Two-dimensional layout with explicit rows and columns. Good for page-level layouts and complex alignments.
- **Positioning:** static, relative, absolute, fixed, sticky.
- **Box model:** content, padding, border, margin. `box-sizing: border-box` includes padding and border in width.

## Responsive Design

- Media queries with breakpoints based on content, not device widths.
- Mobile-first: base styles for small screens, `min-width` queries add larger layouts.
- Relative units (`rem`, `em`, `%`, `vh`, `vw`) over fixed pixels.
- `clamp()` for fluid typography and spacing.

## CSS Preprocessors and Modern CSS

- PostCSS, Sass, or Less provide variables, nesting, mixins.
- Modern CSS now supports custom properties, `nesting`, container queries, `:has()` selector, `@scope`.
- Prefer native CSS where supported to reduce build complexity.

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between inline, block, and inline-block elements?

**Answer:** Block elements occupy full width and start on a new line. Inline elements flow within text and ignore width/height. Inline-block flows inline but respects width, height, and margins.

### 2. How does the cascade and specificity work in CSS?

**Answer:** The cascade resolves conflicting declarations by importance, specificity, and source order. Specificity is calculated as inline styles > IDs > classes/attributes/pseudo-classes > elements/pseudo-elements. `!important` overrides all but should be avoided.

### 3. When would you use Grid over Flexbox?

**Answer:** Grid for two-dimensional layouts where you control both rows and columns. Flexbox for one-dimensional layouts along a single axis. Many pages use both.

### 4. What is the stacking context and how do you create one?

**Answer:** A stacking context groups elements with a common z-axis order. Created by `position` + `z-index`, `opacity < 1`, `transform`, `filter`, `isolation: isolate`. Elements inside share the same z-index relative to siblings.

### 5. What are container queries and when are they useful?

**Answer:** Container queries (`@container`) apply styles based on a parent container's size instead of the viewport. Useful for reusable components that must adapt to different layout contexts.

### 6. What is the difference between `rem` and `em`?

**Answer:** `rem` is relative to the root font size, predictable and consistent. `em` is relative to the parent font size, compounding with nesting. Use `rem` for most spacing and typography; `em` for components that should scale with their own font size.
