// Landing: cada demo debe tener su tarjeta, con estado, y la versión en inglés no puede dejar texto en español.
import { launch, checker, BASE, ROUTES } from './_env.mjs'

const { ok, done } = checker('landing')
const { browser, page, errs } = await launch()
await page.goto(BASE.replace(/demos\/index\.html$/, 'index.html'))

// 1) Todo demo del laboratorio tiene su tarjeta con enlace en la landing.
const linked = await page.locator('a.demo-link[href^="demos/#/"]').evaluateAll((a) => a.map((x) => x.getAttribute('href').split('#/')[1]))
for (const id of ROUTES) ok(linked.includes(id), `el demo «${id}» tiene tarjeta en la landing`)
for (const id of linked) ok(ROUTES.includes(id), `el enlace de la landing «${id}» apunta a un demo que existe`)

// 2) Cada tarjeta muestra un estado.
const sinEstado = await page.locator('.project-card, .other-card').evaluateAll((els) => els.filter((e) => !e.querySelector('.badge')?.innerText.trim()).map((e) => e.querySelector('h3, h4')?.innerText))
ok(sinEstado.length === 0, `todas las tarjetas tienen estado${sinEstado.length ? ' (faltan: ' + sinEstado.join(', ') + ')' : ''}`)

// 3) Español e inglés: nada de español suelto en la versión en inglés.
await page.selectOption('#langSelect', 'en'); await page.waitForTimeout(300)
const txt = await page.locator('#projects').innerText()
const suelto = txt.match(/En producción|En desarrollo|En pruebas|Prototipo|Piloto|Probar demo|Abrir la app|Ver en las tiendas/g)
ok(!suelto, `inglés sin textos en español${suelto ? ': ' + [...new Set(suelto)].join(', ') : ''}`)

// 4) La landing no menciona nombres de clientes (los demos son anónimos).
await page.selectOption('#langSelect', 'es'); await page.waitForTimeout(300)
const todo = (await page.locator('body').innerText()) + (await page.locator('a').evaluateAll((a) => a.map((x) => x.href).join(' ')))
const cliente = todo.match(/segurapp|cyma|albaterra|rueda serrano|rsas|\bspect\b/i)
ok(!cliente, `sin nombres de clientes${cliente ? ': ' + cliente[0] : ''}`)

ok(!errs.length, 'sin errores de consola')
await browser.close()
done()
