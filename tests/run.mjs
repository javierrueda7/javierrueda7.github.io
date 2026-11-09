// Corre todas las pruebas de los demos en orden y falla si alguna falla.
import { spawnSync } from 'node:child_process'
let fail = 0
for (const f of ['smoke', 'links', 'playr', 'slothy', 'apex', 'atdoor']) {
  const r = spawnSync(process.execPath, ['tests/' + f + '.mjs'], { stdio: 'inherit' })
  if (r.status !== 0) fail++
}
if (fail) { console.error(fail + ' archivo(s) de prueba fallaron'); process.exit(1) }
console.log('Todas las pruebas pasaron')
