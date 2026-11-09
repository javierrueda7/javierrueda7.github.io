import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { realpathSync } from 'node:fs'
import { resolve } from 'node:path'

// En Windows la letra de unidad puede llegar como "c:" o "C:" según desde dónde se
// lance el comando, y Vite falla al cargar el CSS en línea de index.html. Normalizamos.
const root = realpathSync.native(process.cwd())

// Dos entradas: la landing estática (index.html) y el laboratorio de demos (demos/index.html).
// base './' para que funcione igual en javierrueda7.github.io y en cualquier subruta.
export default defineConfig({
  root,
  base: './',
  plugins: [react()],
  build: {
    rollupOptions: {
      input: {
        main: resolve(root, 'index.html'),
        demos: resolve(root, 'demos/index.html'),
      },
    },
  },
})
