# Accessibility

## Core Principles

Accessibility means building interfaces usable by people with diverse abilities. It benefits everyone — keyboard users, screen reader users, low-vision users, and users on slow connections.

## Semantic HTML

Use the correct element for the job: `<button>` for actions, `<a>` for navigation, `<nav>` for navigation blocks, `<h1>`-`<h6>` for headings. Semantic HTML provides built-in keyboard support and screen reader announcements.

## ARIA

ARIA attributes supplement HTML semantics when native elements are insufficient. Use `aria-label`, `aria-labelledby`, `aria-describedby`, `aria-expanded`, `aria-hidden`, `role`. First rule: if a native HTML element works, do not add ARIA.

## Keyboard Navigation

All interactive elements must be reachable and operable by keyboard. Use `tabindex="0"` for focusable non-interactive elements. Manage focus for modals, dialogs, and single-page app route transitions. Visible focus indicators are mandatory.

## Color and Contrast

- Text must have at least 4.5:1 contrast ratio (3:1 for large text).
- Do not rely on color alone to convey information.
- Support prefers-reduced-motion for animations.
- Support prefers-color-scheme for dark mode.

## Screen Readers

Users navigate by headings, landmarks, links, and form controls. Test with NVDA (Windows), VoiceOver (Mac/iOS), or TalkBack (Android). Common issues: missing labels, empty links, unclear error messages, images without alt text.

## Mid/Senior Interview Questions and Answers

### 1. What accessibility concerns should every frontend engineer understand?

**Answer:** Semantic HTML, keyboard navigation, focus management, color contrast, labels, ARIA only when needed, visible error messages, and screen reader behavior. Accessibility is not a final polish step — it affects component choice, layout, forms, modals, navigation, and testing.

### 2. How do you test for accessibility?

**Answer:** Automated tools catch ~30% of issues (axe, Lighthouse, WAVE). Manual testing covers the rest: keyboard-only navigation, screen reader testing (NVDA, VoiceOver), zoom to 200%, prefers-reduced-motion, and color contrast checkers. Involve users with disabilities for real-world validation.

### 3. What is the difference between `aria-label` and `aria-labelledby`?

**Answer:** `aria-label` directly provides an accessible name on an element. `aria-labelledby` references the ID of another element that contains the label text. `aria-labelledby` takes precedence and is useful when the visible label is separate from the element it describes.

### 4. How do you handle focus management in a single-page app?

**Answer:** After a route change, move focus to the page heading or main content area. For modals, trap focus inside the modal and restore focus to the trigger on close. Use `useRef` and `focus()` explicitly. SPA routing often breaks focus without manual management.
