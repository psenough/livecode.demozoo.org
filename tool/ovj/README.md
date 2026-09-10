# OVJ

A React TypeScript visual tool.

## Project Structure

```
ovj/
├── src/
│   ├── components/       # React components
│   │   ├── HelloWorld/   # Example component with co-located files
│   │   │   ├── HelloWorld.tsx
│   │   │   ├── HelloWorld.css
│   │   │   ├── HelloWorld.types.ts
│   │   │   └── index.ts
│   │   └── index.ts      # Barrel export for components
│   ├── styles/           # Global styles
│   │   ├── index.css     # CSS reset & variables
│   │   └── App.css       # App-level styles
│   ├── types/            # Shared TypeScript types
│   │   └── index.ts
│   ├── App.tsx           # Main App component
│   ├── main.tsx          # Application entry point
│   └── vite-env.d.ts     # Vite type definitions
├── index.html            # HTML entry point
├── package.json          # Dependencies & scripts
├── tsconfig.json         # TypeScript configuration
├── tsconfig.node.json    # TypeScript config for Node
├── vite.config.ts        # Vite configuration
└── README.md
```

## Getting Started

### Install dependencies

```bash
npm install
```

### Development

```bash
npm run dev
```

### Build for production

```bash
npm run build
```

### Preview production build

```bash
npm run preview
```

## Component Structure

Each component follows a co-located file structure:

- `ComponentName.tsx` - Component implementation
- `ComponentName.css` - Component styles
- `ComponentName.types.ts` - TypeScript interfaces/types
- `index.ts` - Barrel export

This structure keeps related files together and makes imports clean:

```tsx
import { HelloWorld } from '@components/HelloWorld';
```
