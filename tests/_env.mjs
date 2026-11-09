// Utilidades compartidas por las pruebas de los demos.
// En CI usa el Chrome instalado en el runner; en local puedes fijar CHROME_PATH.
import { chromium } from 'playwright-core'

export const BASE = process.env.BASE_URL || 'http://localhost:4173/demos/index.html'
export const ROUTES = ['playr', 'slothy', 'backline', 'boleteria', 'menu', 'apex', 'atdoor', 'sofia', 'polizas', 'lotes', 'analitica', 'ambiental', 'encuestas']

export async function launch(viewport = { width: 1280, height: 900 }) {
  const opts = process.env.CHROME_PATH
    ? { executablePath: process.env.CHROME_PATH }
    : process.platform === 'win32' && !process.env.CI
      ? { executablePath: 'C:/Program Files/Google/Chrome/Application/chrome.exe' }
      : { channel: 'chrome' }
  const browser = await chromium.launch(opts)
  const page = await browser.newPage({ viewport })
  const errs = []
  page.on('pageerror', (e) => errs.push(e.message))
  page.on('console', (m) => m.type() === 'error' && errs.push(m.text()))
  return { browser, page, errs }
}

export function checker(name) {
  let fails = 0
  const ok = (cond, msg) => {
    if (!cond) fails++
    console.log(`${cond ? 'OK  ' : 'FAIL'} [${name}] ${msg}`)
  }
  const done = () => {
    console.log(fails ? `${name}: ${fails} fallo(s)` : `${name}: todo OK`)
    if (fails) process.exitCode = 1
  }
  return { ok, done }
}
