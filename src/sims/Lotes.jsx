import { useEffect, useLayoutEffect, useMemo, useRef, useState } from 'react'
import { LI } from '../lib/lineicons.jsx'
import './lotes.css'

// Proyecto «Lotes del Valle», compradores, precios y recibos son inventados.
const TODAY = '2026-11-09'
const money = (n) => '$' + Math.round(n).toLocaleString('es-CO')
const fd = (d) => (d ? d.split('-').reverse().join('/') : '—')
const addDays = (d, n) => new Date(new Date(d + 'T00:00:00Z').getTime() + n * 864e5).toISOString().slice(0, 10)
const addMonths = (d, n) => { const x = new Date(d + 'T00:00:00Z'); x.setUTCMonth(x.getUTCMonth() + n); return x.toISOString().slice(0, 10) }
const MES = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic']
const mlabel = (k) => MES[+k.slice(5, 7) - 1] + ' ' + k.slice(2, 4)
const initials = (n) => n.split(' ').filter(Boolean).map((p) => p[0]).slice(0, 2).join('').toUpperCase()
const MEDIOS = ['Transferencia', 'Consignación', 'Efectivo', 'Cheque', 'Tarjeta', 'Otro']
const ASESORES = ['Camila Duarte', 'Felipe Garzón']
const ST = { disponible: ['Disponible', '#1e7fc2', '#dcecf8'], separado: ['Separado', '#d86a06', '#fbe6d3'], vendido: ['Vendido', '#7b4fb8', '#ece4f7'], bloqueado: ['No disponible', '#6b7280', '#eceae3'] }

// --- Plano: 44 lotes en 4 manzanas, 2 etapas
const AREAS = [182, 195, 168, 210, 176, 224, 190, 205, 172, 186, 240, 198, 180, 215, 170, 192, 228, 184, 200, 176, 235, 188, 196, 212, 174, 206, 183, 221, 169, 194, 202, 178, 230, 187, 199, 175, 218, 191, 207, 173, 226, 185, 197, 164]
const BLOCKS = [
  { mz: 'A', et: 'Etapa 1', x: 36, y: 34, cols: 6, w: 58, h: 50 },
  { mz: 'B', et: 'Etapa 1', x: 36, y: 168, cols: 6, w: 58, h: 50 },
  { mz: 'C', et: 'Etapa 2', x: 446, y: 34, cols: 5, w: 62, h: 50 },
  { mz: 'D', et: 'Etapa 2', x: 446, y: 168, cols: 5, w: 62, h: 50 },
]
const LOTS = (() => {
  const out = []
  let n = 0
  BLOCKS.forEach((b) => {
    const per = b.cols * 2
    for (let i = 0; i < per; i++) {
      const r = Math.floor(i / b.cols), c = i % b.cols
      const x = b.x + c * (b.w + 2), y = b.y + r * (b.h + 3), j = ((n * 7) % 5) - 2
      const pts = [[x, y], [x + b.w, y + (r ? 0 : j)], [x + b.w, y + b.h], [x, y + b.h + (r ? j : 0)]]
      out.push({ id: n + 1, mz: b.mz, et: b.et, area: AREAS[n], m2: b.et === 'Etapa 1' ? 1850000 : 2150000, pts, cx: x + b.w / 2, cy: y + b.h / 2 + 1, base: [24, 44].includes(n + 1) ? 'bloqueado' : 'disponible' })
      n++
    }
  })
  return out
})()
const priceOf = (l) => (l.id === 44 ? null : l.area * l.m2)

const person = (name, doc, tel, city = 'Villa del Valle') => ({ name, doc, tel, city, email: name.toLowerCase().normalize('NFD').replace(/[^a-z ]/g, '').replace(/ /g, '.') + '@correo.test' })
const lot = (id) => LOTS.find((l) => l.id === id)
const sepSeed = (id, lotId, p, date, pct, months, disc, asesor, sepAmt, pays) => {
  const price = Math.round(priceOf(lot(lotId)) * (1 - disc / 100))
  return { id, lot: lotId, buyer: p, date, pct, months, price, asesor, sepAmt, status: 'activa', pays: pays.map(([d, a, m], i) => ({ rc: id * 10 + i, date: d, amount: a === 'rest' ? price - pays.slice(0, i).reduce((s, x) => s + x[1], 0) : a, medio: m })) }
}
const SEPS0 = [
  sepSeed(1, 3, person('Sebastián Arango', 'CC 1.012.340.221', '300 111 0001'), '2025-06-02', 30, 12, 0, ASESORES[0], 6000000, [['2025-06-02', 6000000, 'Transferencia'], ['2025-07-01', 'rest', 'Consignación']]),
  sepSeed(2, 4, person('Mónica Salazar Ruiz', 'CC 52.411.907', '300 111 0002'), '2025-07-14', 40, 12, 3, ASESORES[1], 6000000, [['2025-07-14', 6000000, 'Transferencia'], ['2025-09-01', 'rest', 'Transferencia']]),
  sepSeed(3, 15, person('Inversiones Lagos SAS', 'NIT 901.222.333-1', '300 111 0003'), '2025-09-20', 50, 12, 5, ASESORES[0], 8000000, [['2025-09-20', 8000000, 'Cheque'], ['2025-12-02', 'rest', 'Transferencia']]),
  sepSeed(4, 16, person('Gloria Patricia Mejía', 'CC 41.600.882', '300 111 0004'), '2026-01-12', 30, 12, 0, ASESORES[1], 5000000, [['2026-01-12', 5000000, 'Efectivo'], ['2026-04-08', 'rest', 'Transferencia']]),
  sepSeed(5, 28, person('Camilo Ortiz Peña', 'CC 79.800.145', '300 111 0005'), '2025-08-30', 30, 12, 0, ASESORES[0], 6000000, [['2025-08-30', 6000000, 'Transferencia'], ['2025-10-20', 'rest', 'Transferencia']]),
  sepSeed(6, 34, person('Familia Ibáñez Rojas', 'CC 80.231.664', '300 111 0006'), '2026-02-03', 40, 12, 2, ASESORES[1], 7000000, [['2026-02-03', 7000000, 'Transferencia'], ['2026-05-15', 'rest', 'Consignación']]),
  sepSeed(7, 7, person('Valentina Cruz Herrera', 'CC 1.098.452.310', '300 111 0007'), '2026-09-15', 30, 36, 0, ASESORES[0], 5000000, [['2026-09-15', 5000000, 'Transferencia']]),
  sepSeed(8, 12, person('Mauricio Peña Londoño', 'CC 98.552.071', '300 111 0008'), '2026-10-20', 30, 48, 4, ASESORES[1], 5000000, [['2026-10-20', 5000000, 'Efectivo']]),
  sepSeed(9, 20, person('Diana Lozano Cárdenas', 'CC 63.470.918', '300 111 0009'), '2026-06-05', 40, 24, 0, ASESORES[0], 6000000, [['2026-06-05', 6000000, 'Transferencia'], ['2026-07-04', 124240000, 'Transferencia'], ['2026-09-08', 40700000, 'Transferencia']]),
  sepSeed(10, 31, person('Rafael Montoya Gil', 'CC 71.340.226', '300 111 0010'), '2026-08-12', 30, 36, 0, ASESORES[1], 5000000, [['2026-08-12', 5000000, 'Cheque'], ['2026-09-14', 25000000, 'Transferencia']]),
  sepSeed(11, 38, person('Laura Beltrán Vega', 'CC 1.014.220.670', '300 111 0011'), '2026-11-02', 30, 36, 0, ASESORES[0], 4000000, [['2026-11-02', 4000000, 'Efectivo']]),
]
const QUOTES0 = [
  { n: 7, date: '2026-09-10', lot: 7, client: SEPS0[6].buyer, asesor: ASESORES[0], pct: 30, months: 36, disc: 0, status: 'Separada', sep: 7 },
  { n: 8, date: '2026-10-14', lot: 12, client: SEPS0[7].buyer, asesor: ASESORES[1], pct: 30, months: 48, disc: 4, status: 'Separada', sep: 8 },
  { n: 9, date: '2026-10-28', lot: 9, client: person('Paola Rincón Duque', 'CC 52.987.001', '300 222 0001'), asesor: ASESORES[0], pct: 30, months: 36, disc: 0, status: 'Creada' },
  { n: 10, date: '2026-11-03', lot: 10, client: person('Héctor Valencia Mora', 'CC 80.112.334', '300 222 0002'), asesor: ASESORES[1], pct: 40, months: 24, disc: 3, status: 'Autorizada' },
  { n: 11, date: '2026-08-21', lot: 1, client: person('Ferretería Nuevo Sol SAS', 'NIT 901.777.888-9', '300 222 0003'), asesor: ASESORES[1], pct: 20, months: 60, disc: 0, status: 'Anulada' },
]

// --- Plan de pagos
const priceQ = (q) => Math.round(priceOf(lot(q.lot)) * (1 - q.disc / 100))
const minSep = (price) => Math.max(2000000, Math.round((price * 0.01) / 500000) * 500000)
function plan(s, today = TODAY) {
  const down = Math.round((s.price * s.pct) / 100)
  const cuota = Math.round((s.price - down) / s.months)
  const items = [{ n: 0, label: 'Separación', due: s.date, amount: s.sepAmt }, { n: 1, label: 'Cuota inicial', due: addDays(s.date, 30), amount: down - s.sepAmt }]
  for (let i = 1; i <= s.months; i++) items.push({ n: i + 1, label: 'Cuota ' + i, due: addMonths(s.date, i + 1), amount: i === s.months ? s.price - down - cuota * (s.months - 1) : cuota })
  let left = (s.pays || []).reduce((t, p) => t + p.amount, 0)
  return items.map((it) => {
    const paid = Math.min(it.amount, left)
    left -= paid
    const st = paid >= it.amount ? 'Pagada' : it.due < today ? 'Vencida' : paid > 0 ? 'Abono parcial' : 'Pendiente'
    return { ...it, paid, st }
  })
}
const paidOf = (s) => s.pays.reduce((t, p) => t + p.amount, 0)
const cartera = (s) => (s.status === 'cancelada' ? '—' : paidOf(s) >= s.price ? 'Pagada' : plan(s).some((i) => i.st === 'Vencida') ? 'En mora' : 'Al día')
const lotState = (l, seps) => {
  const s = seps.find((x) => x.lot === l.id && x.status === 'activa')
  return s ? (paidOf(s) >= s.price ? 'vendido' : 'separado') : l.base
}

function useNarrow(ref) {
  const [n, setN] = useState(900)
  useLayoutEffect(() => {
    const el = ref.current
    const f = () => setN(el.clientWidth)
    f()
    const ro = new ResizeObserver(f)
    ro.observe(el)
    return () => ro.disconnect()
  }, [ref])
  return n
}
const Logo = ({ s = 36 }) => (
  <svg viewBox="0 0 48 52" width={s * 0.92} height={s} aria-hidden="true">
    <path d="M24 2l19 6v16c0 13-8 22-19 26C13 46 5 37 5 24V8z" fill="#d0af47" /><path d="M24 6l15 5v13c0 10-6 18-15 22-9-4-15-12-15-22V11z" fill="#f6edd2" />
    <path d="M13 31c4-7 8-12 11-12s7 5 11 12" fill="none" stroke="#064851" strokeWidth="2.6" strokeLinecap="round" /><path d="M24 19v12M18 25l6-6 6 6" fill="none" stroke="#1e8a4c" strokeWidth="2.2" strokeLinecap="round" />
  </svg>
)

const NAV = [['mapa', 'Mapa', 'map'], ['cotiz', 'Cotizaciones', 'file'], ['sep', 'Separaciones', 'sign'], ['cartera', 'Cartera', 'cash'], ['recibos', 'Recibos', 'receipt'], ['clientes', 'Clientes', 'users'], ['tablero', 'Tablero', 'bars']]

export default function Lotes() {
  const [logged, setLogged] = useState(true)
  const [recover, setRecover] = useState(false)
  const [sent, setSent] = useState(false)
  const [seps, setSeps] = useState(SEPS0)
  const [quotes, setQuotes] = useState(QUOTES0)
  const [page, setPage] = useState({ p: 'mapa' })
  const [menu, setMenu] = useState(false)
  const [toast, setToast] = useState('')
  const [modal, setModal] = useState(null)
  const root = useRef(null)
  const width = useNarrow(root)
  const narrow = width < 520
  const rail = !narrow && width < 760
  const tt = useRef()
  const say = (m) => { setToast(m); clearTimeout(tt.current); tt.current = setTimeout(() => setToast(''), 2400) }
  const go = (p, id, extra) => { setPage({ p, id, ...extra }); setMenu(false) }
  const lots = useMemo(() => LOTS.map((l) => ({ ...l, state: lotState(l, seps), price: priceOf(l) })), [seps])
  const receipts = useMemo(() => seps.flatMap((s) => s.pays.map((p) => ({ ...p, sep: s }))).sort((a, b) => b.date.localeCompare(a.date) || b.rc - a.rc), [seps])
  const ctx = { seps, setSeps, quotes, setQuotes, lots, receipts, go, say, setModal, narrow }

  if (!logged) {
    return (
      <div className="lt lt-loginbg" ref={root}>
        <form className="lt-login" onSubmit={(e) => { e.preventDefault(); if (recover) setSent(true); else { setLogged(true); setPage({ p: 'mapa' }) } }}>
          <Logo s={52} />
          <h1>{recover ? 'Recuperar contraseña' : 'Ingresar'}</h1>
          <p>{recover ? 'Le enviaremos un enlace a su correo.' : 'Venta de lotes, cartera y documentos'}</p>
          <label>Correo electrónico<input defaultValue="tatiana@lotesdelvalle.test" /></label>
          {!recover && <label>Contraseña<input type="password" defaultValue="demo1234" /></label>}
          {sent && <div className="lt-ok" role="status">Revise su correo (también la carpeta de spam).</div>}
          <button className="lt-btn pri full" type="submit">{recover ? 'Enviar enlace' : 'Ingresar'}</button>
          <button type="button" className="lt-link" onClick={() => { setRecover(!recover); setSent(false) }}>{recover ? 'Volver a ingresar' : '¿Olvidó su contraseña?'}</button>
        </form>
      </div>
    )
  }

  const active = { cotizdet: 'cotiz', nuevacot: 'cotiz', sepdet: 'sep' }[page.p] || page.p
  const side = (
    <>
      <div className="lt-brand"><Logo s={38} /><div><b>Lotes del Valle</b><small>Villa del Valle</small></div></div>
      <nav>{NAV.map(([id, l, ic]) => <button key={id} title={l} className={'lt-item' + (active === id ? ' on' : '')} onClick={() => go(id)}><LI n={ic} /> <span>{l}</span></button>)}</nav>
      <div className="lt-user"><span className="lt-av">TR</span><div><b>Tatiana Ruiz</b><small>Administradora</small></div><button className="lt-ibtn" aria-label="Cerrar sesión" title="Cerrar sesión" onClick={() => setLogged(false)}><LI n="logout" size={17} /></button></div>
    </>
  )
  const bar = [['mapa', 'Mapa', 'map'], ['cotiz', 'Cotizaciones', 'file'], ['sep', 'Separaciones', 'sign']]
  return (
    <div className={'lt' + (narrow ? ' narrow' : '') + (rail ? ' rail' : '')} ref={root}>
      {!narrow && <aside className="lt-side">{side}</aside>}
      {narrow && menu && (<><div className="lt-ov" onClick={() => setMenu(false)} /><aside className="lt-side lt-drawer">{side}</aside></>)}
      <main className="lt-main">
        {page.p === 'mapa' ? <Mapa {...ctx} focus={page.lot} /> : (
          <div className="lt-scroll"><div className="lt-page">
            {page.p === 'cotiz' && <Cotizaciones {...ctx} />}
            {page.p === 'nuevacot' && <NuevaCot {...ctx} lot0={page.lot} />}
            {page.p === 'cotizdet' && <CotDet {...ctx} n={page.id} />}
            {page.p === 'sep' && <Separaciones {...ctx} />}
            {page.p === 'sepdet' && <SepDet {...ctx} id={page.id} fresh={page.fresh} />}
            {page.p === 'cartera' && <Cartera {...ctx} />}
            {page.p === 'recibos' && <Recibos {...ctx} />}
            {page.p === 'clientes' && <Clientes {...ctx} />}
            {page.p === 'tablero' && <Tablero {...ctx} />}
          </div></div>
        )}
        {narrow && (
          <nav className="lt-bottom">
            {bar.map(([id, l, ic]) => <button key={id} className={active === id ? 'on' : ''} onClick={() => go(id)}><LI n={ic} size={20} /><span>{l}</span></button>)}
            <button className={!bar.some((b) => b[0] === active) ? 'on' : ''} onClick={() => setMenu(true)}><LI n="menu" size={20} /><span>Más</span></button>
          </nav>
        )}
      </main>
      {toast && <div className="lt-toast" role="status">{toast}</div>}
      {modal && (
        <div className="lt-modalbg" onClick={() => setModal(null)}>
          <div className="lt-modal" role="dialog" aria-label={modal.title} onClick={(e) => e.stopPropagation()}>{typeof modal.body === 'function' ? modal.body(() => setModal(null)) : modal.body}</div>
        </div>
      )}
    </div>
  )
}

const Badge = ({ s }) => <span className="lt-badge" style={{ background: ST[s][2], color: ST[s][1] }}>{ST[s][0]}</span>
const Head = ({ t, sub, children }) => <div className="lt-head"><div><h1>{t}</h1>{sub && <p>{sub}</p>}</div>{children}</div>
const Sec = ({ t, children }) => <section className="lt-sec"><div className="lt-sech"><b>{t}</b></div>{children}</section>

// ---------- Mapa
function Mapa({ lots, seps, go, narrow, focus }) {
  const [sel, setSel] = useState(focus || null)
  const [q, setQ] = useState('')
  const [on, setOn] = useState({ disponible: true, separado: true, vendido: true })
  const [et, setEt] = useState('')
  const [tf, setTf] = useState({ k: 1, x: 0, y: 0 })
  const box = useRef(null)
  const drag = useRef(null)
  const L = lots.find((l) => l.id === sel)
  const sep = L && seps.find((s) => s.lot === L.id && s.status === 'activa')
  const counts = (s) => lots.filter((l) => l.state === s).length
  const match = (l) => (on[l.state] ?? true) && (!et || l.et === et) && (!q.trim() || String(l.id) === q.trim())
  const zoom = (f, cx = 400, cy = 260) => setTf((t) => { const k = Math.min(4, Math.max(1, t.k * f)); const r = k / t.k; return k === 1 ? { k, x: 0, y: 0 } : { k, x: cx - (cx - t.x) * r, y: cy - (cy - t.y) * r } })
  useEffect(() => {
    const el = box.current
    const w = (e) => { e.preventDefault(); const b = el.getBoundingClientRect(); zoom(e.deltaY < 0 ? 1.15 : 0.87, ((e.clientX - b.left) / b.width) * 800, ((e.clientY - b.top) / b.height) * 520) }
    el.addEventListener('wheel', w, { passive: false })
    return () => el.removeEventListener('wheel', w)
  }, [])
  const down = (e) => { drag.current = { sx: e.clientX, sy: e.clientY, tx: tf.x, ty: tf.y, moved: false } }
  const move = (e) => {
    const d = drag.current
    if (!d) return
    const b = box.current.getBoundingClientRect()
    const dx = e.clientX - d.sx, dy = e.clientY - d.sy
    if (Math.abs(dx) + Math.abs(dy) > 4) d.moved = true
    if (d.moved && tf.k > 1) setTf((t) => ({ ...t, x: d.tx + (dx * 800) / b.width, y: d.ty + (dy * 520) / b.height }))
  }
  const up = () => setTimeout(() => { drag.current = null }, 0)
  const pick = (id) => { if (drag.current?.moved) return; setSel(id === sel ? null : id) }
  const onQ = (v) => { setQ(v); const l = lots.find((x) => String(x.id) === v.trim()); if (l) setSel(l.id) }
  return (
    <div className="lt-map">
      <div className="lt-ctl">
        <label className="lt-sbox"><LI n="search" size={16} /><input placeholder="Lote #" value={q} onChange={(e) => onQ(e.target.value)} inputMode="numeric" aria-label="Buscar lote" /></label>
        <div className="lt-pills">
          {['disponible', 'separado', 'vendido'].map((s) => (
            <button key={s} className={'lt-pill' + (on[s] ? ' on' : '')} aria-pressed={on[s]} onClick={() => setOn((o) => ({ ...o, [s]: !o[s] }))}><i style={{ background: ST[s][1] }} />{ST[s][0]} <b>{counts(s)}</b></button>
          ))}
        </div>
        <select value={et} onChange={(e) => setEt(e.target.value)} aria-label="Etapa"><option value="">Todas las etapas</option><option>Etapa 1</option><option>Etapa 2</option></select>
      </div>
      <div className="lt-zoom"><button aria-label="Acercar" onClick={() => zoom(1.4)}><LI n="plus" size={16} /></button><button aria-label="Alejar" onClick={() => zoom(1 / 1.4)}><LI n="minus" size={16} /></button></div>
      <div className="lt-canvas" ref={box} onPointerDown={down} onPointerMove={move} onPointerUp={up} onPointerLeave={up}>
        <svg viewBox="0 0 800 520" preserveAspectRatio="xMidYMid meet" role="img" aria-label="Plano del proyecto">
          <rect width="800" height="520" fill="#eef2ea" />
          <g transform={`translate(${tf.x} ${tf.y}) scale(${tf.k})`}>
            <rect x="0" y="0" width="800" height="520" fill="#eef2ea" onClick={() => !drag.current?.moved && setSel(null)} />
            <rect x="0" y="136" width="800" height="26" fill="#d9d7cd" /><rect x="0" y="262" width="800" height="22" fill="#d9d7cd" /><rect x="412" y="0" width="26" height="520" fill="#d9d7cd" />
            <path d="M0 470 C120 430 220 500 340 456 S600 420 800 470 L800 520 L0 520Z" fill="#cfe3ef" />
            <rect x="40" y="304" width="340" height="104" rx="18" fill="#cfe2c2" /><text x="210" y="360" textAnchor="middle" className="lt-ptxt">Zona verde / parque</text>
            <rect x="446" y="304" width="316" height="104" rx="18" fill="#e4e1d3" /><text x="604" y="360" textAnchor="middle" className="lt-ptxt">Club y portería</text>
            <text x="92" y="30" className="lt-mz">MZ A · ETAPA 1</text><text x="92" y="164" className="lt-mz" dy="-2">MZ B</text><text x="450" y="30" className="lt-mz">MZ C · ETAPA 2</text><text x="450" y="164" className="lt-mz" dy="-2">MZ D</text>
            {lots.map((l) => (
              <g key={l.id} className={'lt-lot' + (sel === l.id ? ' sel' : '') + (match(l) ? '' : ' dim')} onClick={() => pick(l.id)} role="button" tabIndex={0} aria-label={`Lote ${l.id}, ${ST[l.state][0]}`} onKeyDown={(e) => e.key === 'Enter' && pick(l.id)}>
                <polygon points={l.pts.map((p) => p.join(',')).join(' ')} fill={ST[l.state][1]} />
                <text x={l.cx} y={l.cy} textAnchor="middle" dominantBaseline="middle">{l.id}</text>
              </g>
            ))}
          </g>
        </svg>
      </div>
      {L && (
        <aside className={'lt-panel' + (narrow ? ' sheet' : '')} aria-label={'Lote ' + L.id}>
          <div className="lt-photo"><LI n="image" size={30} /><button className="lt-x" aria-label="Cerrar" onClick={() => setSel(null)}><LI n="x" size={16} /></button></div>
          <div className="lt-pbody">
            <div className="lt-ptitle"><div><h2>Lote {L.id}</h2><small>Manzana {L.mz} · {L.et}</small></div><Badge s={L.state} /></div>
            <div className="lt-two"><div className="lt-box"><small>Área</small><b className="num">{L.area} m²</b></div><div className="lt-box"><small>Precio de lista</small><b className="num">{L.price ? money(L.price) : 'A consultar'}</b></div></div>
            {L.price && <p className="lt-m2">{money(L.m2)} por m²</p>}
            {L.state === 'disponible' && L.price && (
              <>
                <button className="lt-btn pri full" onClick={() => go('nuevacot', null, { lot: L.id })}><LI n="file" size={16} /> Cotizar este lote</button>
              </>
            )}
            {L.state === 'disponible' && !L.price && <p className="lt-note">Precio a consultar con la administración.</p>}
            {L.state === 'bloqueado' && <p className="lt-note">Este lote no está disponible para la venta.</p>}
            {sep && (
              <button className="lt-sepcard" onClick={() => go('sepdet', sep.id)}>
                <small>Separación #{sep.id}</small><b>{sep.buyer.name}</b>
                <span>Pagado <b className="num">{money(paidOf(sep))}</b> · Saldo <b className="num">{money(sep.price - paidOf(sep))}</b></span>
              </button>
            )}
            <details className="lt-lind"><summary>Linderos</summary><p>Norte: lote {Math.max(1, L.id - 6)}. Sur: vía interna. Oriente: lote {L.id + 1}. Occidente: lote {Math.max(1, L.id - 1)}. Cabida aproximada {L.area} m².</p></details>
          </div>
        </aside>
      )}
    </div>
  )
}

// ---------- Cotizaciones
const QTAG = { Creada: 'info', Autorizada: 'ok', Separada: 'warn', Anulada: 'gray' }
const Tag = ({ c, children }) => <span className={'lt-tag ' + c}>{children}</span>

function Cotizaciones({ quotes, go }) {
  const [q, setQ] = useState('')
  const s = q.trim().toLowerCase()
  const list = quotes.filter((x) => !s || ['C-' + x.n, x.lot, x.client.name, x.client.doc].join(' ').toLowerCase().includes(s)).sort((a, b) => b.n - a.n)
  return (
    <>
      <Head t="Cotizaciones" sub="Ofertas a clientes interesados"><button className="lt-btn pri" onClick={() => go('nuevacot')}><LI n="plus" size={16} /> Nueva cotización</button></Head>
      <label className="lt-sbox flat"><LI n="search" size={16} /><input placeholder="Número, lote, cliente o documento" value={q} onChange={(e) => setQ(e.target.value)} aria-label="Buscar cotizaciones" /></label>
      {list.length === 0 ? <div className="lt-empty">No hay cotizaciones<button className="lt-btn" onClick={() => go('nuevacot')}>Crear la primera</button></div> : (
        <div className="lt-card"><div className="lt-tw"><table className="lt-table">
          <thead><tr><th>#</th><th>Fecha</th><th>Lote</th><th>Cliente</th><th>Asesor</th><th className="r">Precio final</th><th>Estado</th></tr></thead>
          <tbody>{list.map((x) => (
            <tr key={x.n} className="click" onClick={() => go('cotizdet', x.n)}><td className="num">C-{String(x.n).padStart(4, '0')}</td><td className="num">{fd(x.date)}</td><td>Lote {x.lot}</td><td><b>{x.client.name}</b></td><td>{x.asesor}</td><td className="num r">{money(priceQ(x))}</td><td><Tag c={QTAG[x.status]}>{x.status}</Tag></td></tr>
          ))}</tbody></table></div></div>
      )}
    </>
  )
}

function NuevaCot({ lots, quotes, setQuotes, go, say, lot0 }) {
  const free = lots.filter((l) => l.state === 'disponible' && l.price)
  const [f, setF] = useState({ lot: lot0 || '', name: '', doc: '', tel: '', asesor: ASESORES[0] })
  const [pct, setPct] = useState(30)
  const [months, setMonths] = useState(36)
  const [disc, setDisc] = useState(0)
  const [err, setErr] = useState({})
  const L = lots.find((l) => l.id === +f.lot)
  const price = L ? Math.round(L.price * (1 - disc / 100)) : 0
  const down = Math.round((price * pct) / 100)
  const prev = L ? plan({ date: TODAY, pct, months, price, sepAmt: minSep(price), pays: [] }) : []
  const set = (k, v) => { setF((x) => ({ ...x, [k]: v })); setErr((e) => ({ ...e, [k]: '' })) }
  const save = (e) => {
    e.preventDefault()
    const er = {}
    if (!L) er.lot = 'Elija un lote disponible'
    if (!f.name.trim()) er.name = 'Escriba el nombre del cliente'
    if (!f.doc.trim()) er.doc = 'Escriba el documento'
    setErr(er)
    if (Object.keys(er).length) return
    const n = Math.max(...quotes.map((x) => x.n)) + 1
    setQuotes((l) => [...l, { n, date: TODAY, lot: L.id, client: person(f.name.trim(), f.doc.trim(), f.tel || '—'), asesor: f.asesor, pct, months, disc, status: 'Creada' }])
    say('Cotización C-' + String(n).padStart(4, '0') + ' creada')
    go('cotizdet', n)
  }
  return (
    <>
      <button className="lt-back" onClick={() => go('cotiz')}><LI n="left" size={16} /> Cotizaciones</button>
      <Head t="Nueva cotización" sub="Simule la cuota inicial y el plazo" />
      <form className="lt-cot" onSubmit={save} noValidate>
        <div className="lt-card pad">
          <h3>Cliente y lote</h3>
          <label className={'lt-f' + (err.lot ? ' bad' : '')}>Lote<select value={f.lot} onChange={(e) => set('lot', e.target.value)} aria-label="Lote"><option value="">Seleccione un lote…</option>{free.map((l) => <option key={l.id} value={l.id}>Lote {l.id} · MZ {l.mz} · {l.area} m²</option>)}</select>{err.lot && <em>{err.lot}</em>}</label>
          <label className={'lt-f' + (err.name ? ' bad' : '')}>Nombre del cliente<input value={f.name} onChange={(e) => set('name', e.target.value)} aria-label="Nombre del cliente" />{err.name && <em>{err.name}</em>}</label>
          <div className="lt-two"><label className={'lt-f' + (err.doc ? ' bad' : '')}>Documento<input value={f.doc} onChange={(e) => set('doc', e.target.value)} aria-label="Documento" />{err.doc && <em>{err.doc}</em>}</label><label className="lt-f">Teléfono<input value={f.tel} onChange={(e) => set('tel', e.target.value)} /></label></div>
          <label className="lt-f">Asesor<select value={f.asesor} onChange={(e) => set('asesor', e.target.value)}>{ASESORES.map((a) => <option key={a}>{a}</option>)}</select></label>
        </div>
        <div className="lt-card pad">
          <h3>Condiciones y plan de pagos</h3>
          <label className="lt-f"><span>Cuota inicial: <b>{pct}%</b></span><input type="range" min="10" max="60" step="5" value={pct} onChange={(e) => setPct(+e.target.value)} aria-label="Cuota inicial" /></label>
          <div className="lt-two"><label className="lt-f">Plazo<select value={months} onChange={(e) => setMonths(+e.target.value)} aria-label="Plazo">{[12, 24, 36, 48, 60].map((m) => <option key={m} value={m}>{m} meses</option>)}</select></label><label className="lt-f">Descuento<select value={disc} onChange={(e) => setDisc(+e.target.value)}>{[0, 2, 3, 4, 5, 8, 10].map((m) => <option key={m} value={m}>{m}%</option>)}</select></label></div>
          {L ? (
            <div className="lt-sum">
              <div><span>Precio final</span><b className="num" data-t="price">{money(price)}</b></div>
              <div><span>Cuota inicial ({pct}%)</span><b className="num" data-t="down">{money(down)}</b></div>
              <div><span>Saldo a financiar</span><b className="num">{money(price - down)}</b></div>
              <div className="hi"><span>Cuota mensual ({months})</span><b className="num" data-t="fee">{money((price - down) / months)}</b></div>
              <small>Separación mínima {money(minSep(price))} · {prev.length - 2} cuotas mensuales.</small>
            </div>
          ) : <p className="lt-note">Elija un lote para calcular.</p>}
          <button className="lt-btn pri full" type="submit">Guardar cotización</button>
        </div>
      </form>
    </>
  )
}

function CotDet({ n, quotes, setQuotes, seps, setSeps, go, say, setModal, lots }) {
  const q = quotes.find((x) => x.n === n)
  if (!q) return <div className="lt-empty">Cotización no encontrada</div>
  const price = priceQ(q)
  const L = lots.find((l) => l.id === q.lot)
  const rows = plan({ date: TODAY, pct: q.pct, months: q.months, price, sepAmt: minSep(price), pays: [] })
  const setSt = (status, m) => { setQuotes((l) => l.map((x) => (x.n === n ? { ...x, status } : x))); say(m) }
  const separate = () => setModal({ title: 'Separar lote', body: (close) => <SepForm q={q} price={price} onDone={(s) => { close(); say('Lote ' + q.lot + ' separado a nombre de ' + s.buyer.name); go('sepdet', s.id, { fresh: true }) }} seps={seps} setSeps={setSeps} setQuotes={setQuotes} close={close} /> })
  return (
    <>
      <button className="lt-back" onClick={() => go('cotiz')}><LI n="left" size={16} /> Cotizaciones</button>
      <Head t={'Cotización C-' + String(q.n).padStart(4, '0')} sub={'Creada el ' + fd(q.date)}><Tag c={QTAG[q.status]}>{q.status}</Tag></Head>
      <div className="lt-cot">
        <div className="lt-card pad"><h3>Cliente</h3><dl className="lt-dl"><dt>Nombre</dt><dd>{q.client.name}</dd><dt>Documento</dt><dd className="num">{q.client.doc}</dd><dt>Teléfono</dt><dd className="num">{q.client.tel}</dd><dt>Asesor</dt><dd>{q.asesor}</dd></dl>
          <h3 className="mt">Lote</h3><dl className="lt-dl"><dt>Lote</dt><dd>Lote {q.lot} · MZ {L.mz} · {L.et}</dd><dt>Área</dt><dd className="num">{L.area} m²</dd><dt>Precio de lista</dt><dd className="num">{money(L.price)}</dd><dt>Estado actual</dt><dd><Badge s={L.state} /></dd></dl></div>
        <div className="lt-card pad"><h3>Condiciones y plan de pagos</h3>
          <div className="lt-sum"><div><span>Precio final{q.disc ? ` (−${q.disc}%)` : ''}</span><b className="num">{money(price)}</b></div><div><span>Cuota inicial ({q.pct}%)</span><b className="num">{money(price * q.pct / 100)}</b></div><div className="hi"><span>Cuota mensual ({q.months})</span><b className="num">{money((price - price * q.pct / 100) / q.months)}</b></div></div>
          <table className="lt-table s"><thead><tr><th>Concepto</th><th>Vence</th><th className="r">Valor</th></tr></thead><tbody>{rows.slice(0, 4).map((r) => <tr key={r.n}><td>{r.label}</td><td className="num">{fd(r.due)}</td><td className="num r">{money(r.amount)}</td></tr>)}<tr><td colSpan="3" className="mut">… y {rows.length - 4} cuotas más</td></tr></tbody></table>
        </div>
      </div>
      <div className="lt-actions">
        {q.status === 'Creada' && <button className="lt-btn pri" onClick={() => setSt('Autorizada', 'Cotización autorizada')}><LI n="check" size={16} /> Autorizar</button>}
        {q.status === 'Autorizada' && (L.state === 'disponible' ? <button className="lt-btn gold" onClick={separate}><LI n="sign" size={16} /> Separar lote</button> : <span className="lt-note">El lote ya no está disponible.</span>)}
        {(q.status === 'Creada' || q.status === 'Autorizada') && <button className="lt-btn dngo" onClick={() => setSt('Anulada', 'Cotización anulada')}>Anular cotización</button>}
        {q.status === 'Separada' && q.sep && <button className="lt-btn" onClick={() => go('sepdet', q.sep)}>Ver separación #{q.sep}</button>}
      </div>
    </>
  )
}

function SepForm({ q, price, seps, setSeps, setQuotes, onDone, close }) {
  const [name, setName] = useState(q.client.name)
  const [doc, setDoc] = useState(q.client.doc)
  const [amt, setAmt] = useState(String(minSep(price)))
  const [medio, setMedio] = useState('Transferencia')
  const [err, setErr] = useState('')
  const submit = (e) => {
    e.preventDefault()
    if (!name.trim() || !doc.trim()) return setErr('Escriba el nombre y el documento del comprador')
    if (+amt < minSep(price)) return setErr('La separación mínima es ' + money(minSep(price)))
    if (+amt > Math.round((price * q.pct) / 100)) return setErr('No puede superar la cuota inicial')
    const id = Math.max(...seps.map((s) => s.id)) + 1
    const rc = Math.max(...seps.flatMap((s) => s.pays.map((p) => p.rc))) + 1
    const s = { id, lot: q.lot, buyer: { ...q.client, name: name.trim(), doc: doc.trim() }, date: TODAY, pct: q.pct, months: q.months, price, asesor: q.asesor, sepAmt: +amt, status: 'activa', pays: [{ rc, date: TODAY, amount: +amt, medio }] }
    setSeps((l) => [...l, s])
    setQuotes((l) => l.map((x) => (x.n === q.n ? { ...x, status: 'Separada', sep: id } : x)))
    onDone(s)
  }
  return (
    <form onSubmit={submit} noValidate className="lt-mform">
      <h3>Separar el lote {q.lot}</h3>
      <p className="lt-note">El lote queda a nombre del comprador y se genera el recibo de la separación.</p>
      <label className="lt-f">Nombre del comprador<input value={name} onChange={(e) => { setName(e.target.value); setErr('') }} aria-label="Nombre del comprador" /></label>
      <label className="lt-f">Documento<input value={doc} onChange={(e) => { setDoc(e.target.value); setErr('') }} aria-label="Documento del comprador" /></label>
      <div className="lt-two"><label className="lt-f">Valor de la separación<input type="number" className="num" value={amt} onChange={(e) => { setAmt(e.target.value); setErr('') }} aria-label="Valor de la separación" /></label><label className="lt-f">Medio<select value={medio} onChange={(e) => setMedio(e.target.value)}>{MEDIOS.map((m) => <option key={m}>{m}</option>)}</select></label></div>
      {err && <em className="lt-err" role="alert">{err}</em>}
      <div className="lt-mact"><button type="button" className="lt-btn" onClick={close}>Cancelar</button><button className="lt-btn gold" type="submit">Confirmar separación</button></div>
    </form>
  )
}

// ---------- Separaciones
function Separaciones({ seps, go }) {
  const [f, setF] = useState('todas')
  const list = seps.filter((s) => f === 'todas' || (f === 'mora' ? cartera(s) === 'En mora' : s.status === f)).sort((a, b) => b.id - a.id)
  return (
    <>
      <Head t="Separaciones" sub="Lotes separados, su plan de pagos y su cartera" />
      <div className="lt-chips">{[['todas', 'Todas'], ['activa', 'Activas'], ['mora', 'En mora'], ['cancelada', 'Canceladas']].map(([k, l]) => <button key={k} className={'lt-chip' + (f === k ? ' on' : '')} onClick={() => setF(k)}>{l}</button>)}</div>
      {list.length === 0 ? <div className="lt-empty">No hay separaciones</div> : (
        <div className="lt-card"><div className="lt-tw"><table className="lt-table">
          <thead><tr><th>#</th><th>Lote</th><th>Comprador</th><th className="r">Precio final</th><th className="r">Pagado</th><th className="r">Saldo</th><th>Cartera</th></tr></thead>
          <tbody>{list.map((s) => { const c = cartera(s); return (
            <tr key={s.id} className="click" onClick={() => go('sepdet', s.id)}><td className="num">{s.id}</td><td>Lote {s.lot}</td><td><b>{s.buyer.name}</b></td><td className="num r">{money(s.price)}</td><td className="num r">{money(paidOf(s))}</td><td className="num r">{money(s.price - paidOf(s))}</td><td><Tag c={{ 'En mora': 'bad', 'Al día': 'ok', Pagada: 'info', '—': 'gray' }[c]}>{c === '—' ? 'Cancelada' : c}</Tag></td></tr>) })}</tbody></table></div></div>
      )}
    </>
  )
}

const CT = { Pagada: 'ok', 'Abono parcial': 'warn', Pendiente: 'gray', Vencida: 'bad' }
function SepDet({ id, seps, setSeps, go, say, setModal, fresh }) {
  const s = seps.find((x) => x.id === id)
  const [amt, setAmt] = useState('')
  const [medio, setMedio] = useState('Transferencia')
  const [err, setErr] = useState('')
  useEffect(() => { if (fresh && s) setModal({ title: 'Recibo', body: (close) => <Recibo r={{ ...s.pays[s.pays.length - 1], sep: s }} close={close} /> }) }, []) // eslint-disable-line
  if (!s) return <div className="lt-empty">Separación no encontrada</div>
  const L = lot(s.lot)
  const rows = plan(s)
  const paid = paidOf(s)
  const act = s.status === 'activa'
  const pay = (e) => {
    e.preventDefault()
    const v = +amt
    if (!(v > 0)) return setErr('Escriba un valor mayor a 0')
    if (v > s.price - paid) return setErr('El pago supera el saldo (' + money(s.price - paid) + ')')
    const rc = Math.max(...seps.flatMap((x) => x.pays.map((p) => p.rc))) + 1
    const np = { rc, date: TODAY, amount: v, medio }
    setSeps((l) => l.map((x) => (x.id === s.id ? { ...x, pays: [...x.pays, np] } : x)))
    setAmt(''); setErr('')
    say('Pago de ' + money(v) + ' registrado')
    setModal({ title: 'Recibo', body: (close) => <Recibo r={{ ...np, sep: s }} close={close} /> })
  }
  const cancel = () => setModal({ title: 'Cancelar separación', body: (close) => (
    <div><h3>¿Cancelar la separación #{s.id}?</h3><p className="lt-note">El lote {s.lot} vuelve a quedar disponible. Los pagos recibidos quedan en el historial.</p>
      <div className="lt-mact"><button className="lt-btn" onClick={close}>Volver</button><button className="lt-btn danger" onClick={() => { setSeps((l) => l.map((x) => (x.id === s.id ? { ...x, status: 'cancelada' } : x))); close(); say('Separación cancelada: el lote vuelve a estar disponible') }}>Cancelar separación</button></div></div>) })
  return (
    <>
      <button className="lt-back" onClick={() => go('sep')}><LI n="left" size={16} /> Separaciones</button>
      <Head t={`Separación #${s.id} · Lote ${s.lot}`} sub={`${L.et} · Manzana ${L.mz} · ${L.area} m²`}><Tag c={!act ? 'gray' : { 'En mora': 'bad', 'Al día': 'ok', Pagada: 'info' }[cartera(s)]}>{!act ? 'Cancelada' : cartera(s)}</Tag></Head>
      <div className="lt-stats"><div className="lt-stat"><span>Precio final</span><b className="num">{money(s.price)}</b></div><div className="lt-stat"><span>Pagado</span><b className="num ok">{money(paid)}</b></div><div className="lt-stat"><span>Saldo</span><b className="num">{money(s.price - paid)}</b></div></div>
      <div className="lt-cot">
        <div className="lt-card pad"><h3>Comprador</h3><dl className="lt-dl"><dt>Nombre</dt><dd><b>{s.buyer.name}</b></dd><dt>Documento</dt><dd className="num">{s.buyer.doc}</dd><dt>Teléfono</dt><dd className="num">{s.buyer.tel}</dd><dt>Ciudad</dt><dd>{s.buyer.city}</dd></dl>
          <h3 className="mt">Condiciones</h3><dl className="lt-dl"><dt>Fecha</dt><dd className="num">{fd(s.date)}</dd><dt>Cuota inicial</dt><dd>{s.pct}%</dd><dt>Plazo</dt><dd>{s.months} meses</dd><dt>Asesor</dt><dd>{s.asesor}</dd></dl>
          <h3 className="mt">Documentos firmados</h3><ul className="lt-docs"><li className="ok"><LI n="check" size={14} /> Orden de separación firmada</li><li className={paid >= s.price * s.pct / 100 ? 'ok' : ''}><LI n={paid >= s.price * s.pct / 100 ? 'check' : 'minus'} size={14} /> Promesa firmada</li><li className="ok"><LI n="check" size={14} /> Documento de identidad</li></ul></div>
        <div className="lt-card pad"><h3>Pagos recibidos</h3>
          {s.pays.length === 0 ? <p className="lt-note">Sin pagos registrados</p> : <table className="lt-table s"><thead><tr><th>Fecha</th><th>Medio</th><th className="r">Valor</th></tr></thead><tbody>{s.pays.map((p) => <tr key={p.rc} className="click" onClick={() => setModal({ title: 'Recibo', body: (close) => <Recibo r={{ ...p, sep: s }} close={close} /> })}><td className="num">{fd(p.date)}</td><td>{p.medio}</td><td className="num r">{money(p.amount)}</td></tr>)}</tbody></table>}
          {act && paid < s.price && (
            <form className="lt-payform" onSubmit={pay} noValidate>
              <label className="lt-f">Registrar pago<input type="number" className="num" placeholder="Valor" value={amt} onChange={(e) => { setAmt(e.target.value); setErr('') }} aria-label="Valor del pago" /></label>
              <select value={medio} onChange={(e) => setMedio(e.target.value)} aria-label="Medio de pago">{MEDIOS.map((m) => <option key={m}>{m}</option>)}</select>
              <button className="lt-btn pri" type="submit">Registrar pago</button>
              {err && <em className="lt-err" role="alert">{err}</em>}
            </form>
          )}
        </div>
      </div>
      <Sec t="Plan de pagos"><div className="lt-tw"><table className="lt-table">
        <thead><tr><th>Concepto</th><th>Vence</th><th className="r">Valor</th><th className="r">Pagado</th><th>Estado</th></tr></thead>
        <tbody>{rows.slice(0, 10).map((r) => <tr key={r.n}><td>{r.label}</td><td className="num">{fd(r.due)}</td><td className="num r">{money(r.amount)}</td><td className="num r">{money(r.paid)}</td><td><Tag c={CT[r.st]}>{r.st}</Tag></td></tr>)}{rows.length > 10 && <tr><td colSpan="5" className="mut">… y {rows.length - 10} cuotas más</td></tr>}</tbody></table></div></Sec>
      {act && <button className="lt-btn dngo" onClick={cancel}>Cancelar separación</button>}
    </>
  )
}

// ---------- Recibos
function Recibo({ r, close }) {
  return (
    <div className="lt-rc">
      <div className="lt-rch"><Logo s={34} /><div><b>Lotes del Valle</b><small>Condominio campestre</small></div><span className="lt-rcn num">R-{String(r.rc + 1000).padStart(5, '0')}</span></div>
      <h3>Recibo de caja</h3>
      <dl className="lt-dl"><dt>Fecha</dt><dd className="num">{fd(r.date)}</dd><dt>Recibido de</dt><dd><b>{r.sep.buyer.name}</b></dd><dt>Documento</dt><dd className="num">{r.sep.buyer.doc}</dd><dt>Concepto</dt><dd>Pago del lote {r.sep.lot} · separación #{r.sep.id}</dd><dt>Medio</dt><dd>{r.medio}</dd></dl>
      <div className="lt-rcv"><span>Valor recibido</span><b className="num">{money(r.amount)}</b></div>
      <div className="lt-mact"><button className="lt-btn pri" onClick={close}>Cerrar</button></div>
    </div>
  )
}
function Recibos({ receipts, setModal }) {
  return (
    <>
      <Head t="Recibos" sub="Recibos de caja de los pagos recibidos" />
      <div className="lt-card"><div className="lt-tw"><table className="lt-table">
        <thead><tr><th>Recibo</th><th>Fecha</th><th>Lote</th><th>Comprador</th><th>Medio</th><th className="r">Valor</th></tr></thead>
        <tbody>{receipts.slice(0, 20).map((r) => <tr key={r.rc} className="click" onClick={() => setModal({ title: 'Recibo', body: (close) => <Recibo r={r} close={close} /> })}><td className="num">R-{String(r.rc + 1000).padStart(5, '0')}</td><td className="num">{fd(r.date)}</td><td>Lote {r.sep.lot}</td><td><b>{r.sep.buyer.name}</b></td><td>{r.medio}</td><td className="num r">{money(r.amount)}</td></tr>)}</tbody></table></div></div>
    </>
  )
}

// ---------- Cartera
function Cartera({ seps, go }) {
  const [from, setFrom] = useState('2026-11-01')
  const [to, setTo] = useState('2026-11-30')
  const items = seps.filter((s) => s.status === 'activa').flatMap((s) => plan(s).map((i) => ({ ...i, s })))
  const inR = items.filter((i) => i.due >= from && i.due <= to)
  const over = items.filter((i) => i.st === 'Vencida')
  const esperado = inR.reduce((t, i) => t + i.amount, 0)
  const recaudado = inR.reduce((t, i) => t + i.paid, 0)
  const vencido = over.reduce((t, i) => t + i.amount - i.paid, 0)
  const mora = new Set(over.map((i) => i.s.id)).size
  const list = [...new Map([...over, ...inR.filter((i) => i.paid < i.amount)].map((i) => [i.s.id + '-' + i.n, i])).values()].sort((a, b) => a.due.localeCompare(b.due))
  return (
    <>
      <Head t="Cartera" sub="Pagos esperados, vencidos y recaudo del período" />
      <div className="lt-filters"><label className="lt-f">Desde<input type="date" value={from} onChange={(e) => setFrom(e.target.value)} aria-label="Desde" /></label><label className="lt-f">Hasta<input type="date" value={to} onChange={(e) => setTo(e.target.value)} aria-label="Hasta" /></label></div>
      <div className="lt-stats four"><div className="lt-stat"><span>Esperado en el período</span><b className="num">{money(esperado)}</b></div><div className="lt-stat"><span>Recaudado de esas cuotas</span><b className="num ok">{money(recaudado)}</b></div><div className="lt-stat"><span>Vencido</span><b className="num bad">{money(vencido)}</b></div><div className="lt-stat"><span>Clientes en mora</span><b className="num">{mora}</b></div></div>
      {list.length === 0 ? <div className="lt-empty">Nada por cobrar en este período</div> : (
        <div className="lt-card"><div className="lt-tw"><table className="lt-table"><thead><tr><th>Comprador</th><th>Lote</th><th>Concepto</th><th>Vence</th><th className="r">Pendiente</th><th>Estado</th></tr></thead>
          <tbody>{list.map((i) => <tr key={i.s.id + '-' + i.n} className="click" onClick={() => go('sepdet', i.s.id)}><td><b>{i.s.buyer.name}</b></td><td>Lote {i.s.lot}</td><td>{i.label}</td><td className="num">{fd(i.due)}</td><td className="num r">{money(i.amount - i.paid)}</td><td><Tag c={CT[i.st]}>{i.st}</Tag></td></tr>)}</tbody></table></div></div>
      )}
    </>
  )
}

function Clientes({ seps, quotes }) {
  const [q, setQ] = useState('')
  const all = [...new Map([...quotes.map((x) => x.client), ...seps.map((s) => s.buyer)].map((c) => [c.doc, c])).values()]
  const s = q.trim().toLowerCase()
  const list = all.filter((c) => !s || (c.name + ' ' + c.doc).toLowerCase().includes(s))
  return (
    <>
      <Head t="Clientes" sub="Personas cotizadas y compradores" />
      <label className="lt-sbox flat"><LI n="search" size={16} /><input placeholder="Nombre o documento" value={q} onChange={(e) => setQ(e.target.value)} aria-label="Buscar clientes" /></label>
      {list.length === 0 ? <div className="lt-empty">No hay clientes</div> : <div className="lt-card"><div className="lt-tw"><table className="lt-table"><thead><tr><th>Nombre</th><th>Documento</th><th>Teléfono</th><th>Correo</th><th>Ciudad</th></tr></thead>
        <tbody>{list.map((c) => <tr key={c.doc}><td><b>{c.name}</b></td><td className="num">{c.doc}</td><td className="num">{c.tel}</td><td>{c.email}</td><td>{c.city}</td></tr>)}</tbody></table></div></div>}
    </>
  )
}

function Tablero({ lots, seps, receipts }) {
  const act = seps.filter((s) => s.status === 'activa')
  const ventas = act.reduce((t, s) => t + s.price, 0)
  const rec = act.reduce((t, s) => t + paidOf(s), 0)
  const vencido = act.flatMap((s) => plan(s)).filter((i) => i.st === 'Vencida').reduce((t, i) => t + i.amount - i.paid, 0)
  const months = Array.from({ length: 12 }, (_, i) => addMonths('2025-12-01', i).slice(0, 7))
  const by = months.map((m) => [mlabel(m + '-01'), receipts.filter((r) => r.date.slice(0, 7) === m).reduce((t, r) => t + r.amount, 0)])
  const max = Math.max(...by.map((b) => b[1]), 1)
  const asr = ASESORES.map((a) => [a, act.filter((s) => s.asesor === a).reduce((t, s) => t + s.price, 0)])
  const maxA = Math.max(...asr.map((a) => a[1]), 1)
  return (
    <>
      <Head t="Tablero" sub="Resumen del proyecto" />
      <div className="lt-stats four"><div className="lt-stat"><span>Ventas (separados y vendidos)</span><b className="num">{money(ventas)}</b></div><div className="lt-stat"><span>Recaudado</span><b className="num ok">{money(rec)}</b></div><div className="lt-stat"><span>Por cobrar</span><b className="num">{money(ventas - rec)}</b></div><div className="lt-stat"><span>Vencido</span><b className="num bad">{money(vencido)}</b></div></div>
      <div className="lt-cot">
        <div className="lt-card pad"><h3>Inventario</h3>{['disponible', 'separado', 'vendido', 'bloqueado'].map((s) => { const n = lots.filter((l) => l.state === s).length; return <div key={s} className="lt-hb"><span><i style={{ background: ST[s][1] }} />{ST[s][0]}</span><div><u style={{ width: (n / lots.length) * 100 + '%', background: ST[s][1] }} /></div><b className="num">{n}</b></div> })}</div>
        <div className="lt-card pad"><h3>Ventas por asesor</h3>{asr.map(([a, v]) => <div key={a} className="lt-hb"><span>{a}</span><div><u style={{ width: (v / maxA) * 100 + '%', background: '#064851' }} /></div><b className="num">{money(v)}</b></div>)}</div>
      </div>
      <div className="lt-card pad"><h3>Recaudo de los últimos 12 meses</h3>
        <svg viewBox="0 0 672 150" className="lt-bars" role="img" aria-label="Recaudo mensual">{by.map(([k, v], i) => { const h = Math.round((v / max) * 110); return <g key={k + i}><rect x={i * 56 + 10} y={120 - h} width="36" height={h} rx="4" fill="#064851"><title>{k}: {money(v)}</title></rect><text x={i * 56 + 28} y="138" textAnchor="middle">{k}</text></g> })}</svg></div>
    </>
  )
}
