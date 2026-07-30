# Build and Tooling

## Bundlers

- **Vite:** Fast dev server with ES module-based HMR. Uses Rollup for production builds. Modern default for new projects.
- **Webpack:** Mature ecosystem, extensive plugin system, code splitting, loaders. More configuration overhead.
- **Turbopack:** Experimental Rust-based bundler from the Next.js team. Fast incremental builds.
- **esbuild:** Extremely fast bundler written in Go. Used internally by Vite.

## Transpilers

Babel transpiles modern JavaScript (and JSX/TypeScript) to backwards-compatible versions. Presets (`@babel/preset-env`, `@babel/preset-react`) configure target environments. Most projects now use SWC or esbuild for faster transpilation.

## TypeScript

TypeScript adds static typing to JavaScript. Catches common bugs at build time. Requires a build step (tsc, esbuild, swc, or Babel plugin). Strict mode is recommended for production projects.

## Linting and Formatting

- **ESLint:** Lints JavaScript/TypeScript for errors, style violations, and anti-patterns.
- **Prettier:** Opinionated code formatter. Integrates with ESLint via `eslint-config-prettier`.
- Run both in CI and as pre-commit hooks with lint-staged + husky.

## Module Systems

- **ES Modules (ESM):** `import`/`export`. Static, tree-shakeable. Standard for browsers and modern Node.
- **CommonJS:** `require()`/`module.exports`. Dynamic, used by legacy Node packages.
- Most bundlers handle both and output a single bundle for the browser.

## Mid/Senior Interview Questions and Answers

### 1. What is tree shaking and how does it work?

**Answer:** Tree shaking removes unused exports from the final bundle. It works because ESM imports/exports are static — the bundler can determine which exports are used at build time. Side effects in modules can break tree shaking. Mark modules as `"sideEffects": false` in package.json.

### 2. What is the difference between dev dependencies and regular dependencies?

**Answer:** Dev dependencies are tools needed only during development and build (ESLint, Prettier, testing libraries, bundlers). Regular dependencies are libraries required at runtime (React, Vue, UI component libraries). Only regular deps are bundled into the production build.

### 3. How does hot module replacement work?

**Answer:** HMR updates modules in the browser without a full page reload. When a file changes, the dev server sends only the updated module to the client, which applies the change while preserving application state. Vite does this via ESM; Webpack uses a custom runtime.

### 4. When would you use a monorepo for frontend projects?

**Answer:** Monorepos help when multiple apps or packages share code, types, and configuration. Tools like Turborepo, Nx, or pnpm workspaces manage dependency hoisting, caching, and parallel task execution. Not necessary for single-app projects.
