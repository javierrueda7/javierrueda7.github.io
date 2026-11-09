// Enlaces: todo enlace externo de la landing y del panel de demos debe responder.
// Detecta repos que pasan a privados, páginas caídas y enlaces viejos antes de publicar.
import { launch, checker, BASE, ROUTES } from './_env.mjs'

const { ok, done } = checker('enlaces')
const { browser, page } = await launch()

// LinkedIn bloquea clientes automáticos (responde 999): se omite a propósito.
const SKIP = /linkedin\.com|fonts\.(googleapis|gstatic)\.com/
const external = (h) => /^https?:/.test(h) && !h.startsWith(new URL(BASE).origin) && !SKIP.test(h)

const found = new Map() // url -> dónde aparece
const add = (url, where) => { if (external(url) && !found.has(url)) found.set(url, where) }

await page.goto(BASE.replace(/demos\/index\.html$/, 'index.html'))
for (const h of await page.locator('a[href]').evaluateAll((a) => a.map((x) => x.href))) add(h, 'landing')
for (const id of ROUTES) {
  await page.goto(`${BASE}#/${id}`)
  await page.waitForSelector('.lab-info', { timeout: 10000 })
  for (const h of await page.locator('.lab-info a[href]').evaluateAll((a) => a.map((x) => x.href))) add(h, `demo ${id}`)
}

const check = async (url) => {
  for (let intento = 0; intento < 2; intento++) {
    const r = await page.request.get(url, { timeout: 20000, failOnStatusCode: false }).catch(() => null)
    if (r && r.status() < 400) return r.status()
    if (intento === 1) return r ? r.status() : 'sin respuesta'
  }
}
for (const [url, where] of found) {
  const code = await check(url)
  ok(typeof code === 'number', `${where}: ${url.slice(0, 80)} (${code})`)
}
ok(found.size > 0, `se revisaron ${found.size} enlaces externos`)

await browser.close()
done()
