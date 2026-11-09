// Humo: las 13 rutas cargan con contenido, sin errores de consola ni desbordes, en escritorio y celular.
import { launch, checker, BASE, ROUTES } from './_env.mjs'

const { ok, done } = checker('humo')
for (const [label, vp] of [['escritorio', { width: 1440, height: 900 }], ['celular 390', { width: 390, height: 844 }]]) {
  const { browser, page, errs } = await launch(vp)
  for (const id of ROUTES) {
    errs.length = 0
    await page.goto(`${BASE}#/${id}`)
    await page.waitForSelector('.screen > *:not(.loading)', { timeout: 10000 }).catch(() => {})
    await page.waitForTimeout(400)
    const r = await page.evaluate(() => ({
      over: document.documentElement.scrollWidth > document.documentElement.clientWidth,
      empty: document.querySelector('.screen').innerText.trim().length < 20,
    }))
    ok(!errs.length && !r.over && !r.empty, `${label} ${id}${r.over ? ' (desborde)' : ''}${r.empty ? ' (vacío)' : ''}${errs.length ? ' ' + errs[0].slice(0, 80) : ''}`)
  }
  await browser.close()
}
done()
