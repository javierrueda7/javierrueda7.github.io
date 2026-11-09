import { useEffect, useMemo, useRef, useState } from 'react'
import './boleteria.css'

// El show "Madrugada Eléctrica", las bandas, el lugar, los clientes y los pedidos son inventados.
const EVENT = { name: 'Madrugada Eléctrica · Rock & Metal', date: 'DOMINGO · 20 DE DICIEMBRE DE 2026', long: 'domingo, 20 de diciembre de 2026, 7:00 p. m.', place: 'Bodega La Ceiba, Cra. 20 # 10-30, Centro, Bucaramanga' }
const money = (n) => '$ ' + Math.round(n).toLocaleString('es-CO')
const money2 = (n) => '$' + Math.round(n).toLocaleString('es-CO')
const METHODS = { breb: 'Bre-B', nequi: 'Nequi', efectivo: 'Efectivo', otra: 'Otra transferencia', cortesia: 'Cortesía' }
const STATUS = { porvalidar: ['POR VALIDAR', 'warn'], porpagar: ['FALTA PAGAR', 'gr'], confirmada: ['CONFIRMADA', 'ok'], rechazada: ['RECHAZADA', 'mal'], anulada: ['ANULADA', 'gr'] }
const AL = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789'

function rng(seed) { let a = seed; return () => { a |= 0; a = (a + 0x6d2b79f5) | 0; let t = Math.imul(a ^ (a >>> 15), 1 | a); t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t; return ((t ^ (t >>> 14)) >>> 0) / 4294967296 } }
const NAMES = ['Luz Marina Pardo', 'Hernán Cadavid', 'Isabel Cuesta', 'Mauricio Lozano', 'Paola Andrade', 'Camilo Sarmiento', 'Natalia Bermúdez', 'Óscar Villamizar', 'Diana Carrillo', 'Julián Ardila', 'Marcela Ospina', 'Fabián Torres', 'Sandra Mejía', 'Ricardo Navas', 'Yolanda Peña', 'Gustavo Rangel', 'Alejandra Duarte', 'Wilson Becerra', 'Karen Santos', 'Esteban Cortés', 'Liliana Mora', 'Andrés Gómez', 'Tatiana Rueda', 'Jorge Plata', 'Carolina Vega', 'Iván Rojas', 'Mónica Zambrano', 'Daniel Pinzón', 'Viviana Cely', 'Cristian Ortega']
const codeGen = (r) => { const p = () => Array.from({ length: 3 }, () => AL[Math.floor(r() * AL.length)]).join(''); return p() + '-' + p() }
const stamp = () => { const d = new Date(); const h = d.getHours(); return `20/12/26, ${h % 12 || 12}:${String(d.getMinutes()).padStart(2, '0')} ${h < 12 ? 'a. m.' : 'p. m.'}` }
const stampNow = () => { const d = new Date(); const h = d.getHours(); return `9/11/26, ${h % 12 || 12}:${String(d.getMinutes()).padStart(2, '0')} ${h < 12 ? 'a. m.' : 'p. m.'}` }

const TIPOS0 = [
  { id: 'pre', name: 'Preventa', price: 30000, cupo: 150, active: true, soloTaq: false },
  { id: 'taq', name: 'Taquilla', price: 35000, cupo: 100, active: true, soloTaq: true },
]

function seed() {
  const r = rng(7)
  const orders = []
  let n = 900
  const mk = (o) => {
    const code = 'ME-' + ++n
    const tickets = Array.from({ length: o.qty }, (_, i) => ({ code: codeGen(r), n: i + 1, used: false, usedAt: null }))
    orders.push({ code, email: 'demo@ejemplo.test', ced: String(10000000 + Math.floor(r() * 9e6)), phone: '300 000 ' + String(1000 + Math.floor(r() * 8999)), receipt: o.status === 'porpagar' ? null : 'comprobante.jpg', origin: 'web', method: 'breb', created: stampNow(), ...o, total: o.qty * o.price, tickets })
    return orders[orders.length - 1]
  }
  // confirmadas web preventa: 118 personas, 36 ya ingresaron
  const sizes = [2, 4, 3, 1, 5, 2, 3, 2, 1, 4]
  let left = 118; let k = 0
  while (left > 0) { const q = Math.min(left, sizes[k % sizes.length]); mk({ name: NAMES[k % NAMES.length], tipo: 'Preventa', price: 30000, qty: q, status: 'confirmada' }); left -= q; k++ }
  let ing = 36
  orders.forEach((o) => o.tickets.forEach((t) => { if (ing > 0) { t.used = true; t.usedAt = '20/12/26, 7:' + String(10 + (ing % 50)).padStart(2, '0') + ' p. m.'; ing-- } }))
  // taquilla: 14 personas (10 efectivo, 4 cortesía), 5 ingresaron
  const t1 = mk({ name: 'Venta en puerta', tipo: 'Taquilla', price: 35000, qty: 10, status: 'confirmada', origin: 'taquilla', method: 'efectivo' })
  const t2 = mk({ name: 'Cortesía banda', tipo: 'Taquilla', price: 0, qty: 4, status: 'confirmada', origin: 'taquilla', method: 'cortesia' })
  t1.tickets.slice(0, 3).forEach((t) => { t.used = true; t.usedAt = '20/12/26, 7:05 p. m.' }); t2.tickets.slice(0, 2).forEach((t) => { t.used = true; t.usedAt = '20/12/26, 7:08 p. m.' })
  mk({ name: 'Luz Marina Pardo', tipo: 'Preventa', price: 30000, qty: 2, status: 'porvalidar' })
  mk({ name: 'Hernán Cadavid', tipo: 'Preventa', price: 30000, qty: 4, status: 'porvalidar' })
  mk({ name: 'Isabel Cuesta', tipo: 'Preventa', price: 30000, qty: 1, status: 'porvalidar' })
  mk({ name: 'Mauricio Lozano', tipo: 'Preventa', price: 30000, qty: 3, status: 'porpagar' })
  mk({ name: 'Paola Andrade', tipo: 'Preventa', price: 30000, qty: 2, status: 'porpagar' })
  mk({ name: 'Camilo Sarmiento', tipo: 'Preventa', price: 30000, qty: 1, status: 'rechazada' })
  // los pedidos pendientes quedan al final de la lista de "por validar" con sus códigos 1041..: reasigno códigos
  const pend = orders.filter((o) => o.status === 'porvalidar')
  pend.forEach((o, i) => { o.code = 'ME-' + (1041 + i) })
  const pp = orders.filter((o) => o.status === 'porpagar'); pp.forEach((o, i) => { o.code = 'ME-' + (1051 + i) })
  return orders
}

// QR de demostración: matriz determinista a partir del código (no es un QR real).
function Qr({ value }) {
  const cells = useMemo(() => {
    let h = 2166136261; for (const c of value) h = Math.imul(h ^ c.charCodeAt(0), 16777619)
    const r = rng(h >>> 0); const N = 25; const m = Array.from({ length: N }, () => Array.from({ length: N }, () => r() > 0.52))
    const finder = (x, y) => { for (let i = -1; i < 8; i++) for (let j = -1; j < 8; j++) { const X = x + i, Y = y + j; if (X < 0 || Y < 0 || X >= N || Y >= N) continue; const on = i >= 0 && i < 7 && j >= 0 && j < 7 && (i === 0 || i === 6 || j === 0 || j === 6 || (i >= 2 && i <= 4 && j >= 2 && j <= 4)); m[Y][X] = on } }
    finder(0, 0); finder(N - 7, 0); finder(0, N - 7)
    return m
  }, [value])
  return <svg className="qr" viewBox="0 0 25 25" shapeRendering="crispEdges" role="img" aria-label={`Código QR ${value}`}>{cells.map((row, y) => row.map((v, x) => v ? <rect key={x + '-' + y} x={x} y={y} width="1.02" height="1.02" fill="#151312" /> : null))}</svg>
}

function Skull() {
  return <svg className="skull" viewBox="0 0 40 40" fill="none" stroke="#efe9dc" strokeWidth="2" aria-hidden="true"><path d="M20 4c-8 0-13 5-13 12 0 4 2 7 5 9v6h16v-6c3-2 5-5 5-9 0-7-5-12-13-12z" /><circle cx="14" cy="17" r="3" fill="#c1121f" stroke="none" /><circle cx="26" cy="17" r="3" fill="#c1121f" stroke="none" /><path d="M18 26v4m4-4v4m-8-12h0" /></svg>
}

export default function Boleteria() {
  const [role, setRole] = useState('pub')
  const [logged, setLogged] = useState(false)
  const [pv, setPv] = useState({ n: 'landing' })
  const [sp, setSp] = useState('escaner')
  const [tipos, setTipos] = useState(TIPOS0)
  const [orders, setOrders] = useState(seed)
  const [web, setWeb] = useState({ open: true, aforo: 250 })
  const [cfg, setCfg] = useState({ nombre: EVENT.name, lugar: EVENT.place, breb: '@demo-breb', nequi: '3000000000', titular: 'Titular de Ejemplo', resp: 'Responsable Demo' })
  const [toast, setToast] = useState(null)
  const [tick, setTick] = useState(0)
  const [myOrder, setMyOrder] = useState(null)
  const [scan, setScan] = useState({ res: null, cam: false })
  const [code, setCode] = useState('')
  const [form, setForm] = useState({ tipo: 'pre', qty: 1, name: '', ced: '', phone: '', mail: '', ok: false })
  const [err, setErr] = useState('')
  const [pf, setPf] = useState('porvalidar')
  const [rc, setRc] = useState(null)
  const [vf, setVf] = useState({ tipo: 'taq', qty: 1, method: 'efectivo', name: '', ced: '', phone: '', mail: '', now: false })
  const [vres, setVres] = useState(null)
  const [edit, setEdit] = useState(null)
  const [nt, setNt] = useState({ name: '', price: '', cupo: '', taq: false })
  const [accs, setAccs] = useState([{ mail: 'admin@ejemplo.test', role: 'admin' }, { mail: 'puerta@ejemplo.test', role: 'taquilla' }])
  const [na, setNa] = useState({ mail: '', role: 'taquilla' })
  const scroller = useRef(null)
  const say = (t) => { setToast(t); setTimeout(() => setToast(null), 2200) }
  useEffect(() => { const id = setInterval(() => setTick((x) => x + 1), 30000); return () => clearInterval(id) }, [])
  useEffect(() => { scroller.current?.scrollTo?.(0, 0) }, [role, pv.n, sp])
  void tick

  const tipoBy = (name) => tipos.find((t) => t.name === name)
  const counted = (o) => ['confirmada', 'porvalidar', 'porpagar'].includes(o.status)
  const soldOf = (name) => orders.filter((o) => o.tipo === name && counted(o)).reduce((a, o) => a + o.qty, 0)
  const confirmed = orders.filter((o) => o.status === 'confirmada')
  const tks = confirmed.flatMap((o) => o.tickets)
  const used = tks.filter((t) => t.used).length
  const pendV = orders.filter((o) => o.status === 'porvalidar')
  const copy = (t, msg = 'Copiado') => { try { navigator.clipboard?.writeText(t) } catch { /* sin portapapeles */ } say(msg) }
  const linkOf = (o) => `boleteria.demo/pedido/${o.code.toLowerCase()}-x7k2`

  // ---------- público
  const webTipos = tipos.filter((t) => t.active && !t.soloTaq)
  const sel = tipos.find((t) => t.id === form.tipo) ?? webTipos[0]
  const quedan = (t) => Math.max(0, (t.cupo ?? 9999) - soldOf(t.name))
  const formOk = form.name.trim() && form.ced.trim() && form.phone.trim() && /\S+@\S+\.\S+/.test(form.mail) && form.ok && sel && web.open && quedan(sel) >= form.qty
  const reservar = (e) => {
    e.preventDefault()
    if (!formOk) return
    const r = rng(Date.now() % 100000)
    const num = 1060 + orders.length
    const o = { code: 'ME-' + num, name: form.name.trim(), ced: form.ced.trim(), phone: form.phone.trim(), email: form.mail.trim(), tipo: sel.name, price: sel.price, qty: +form.qty, total: sel.price * form.qty, origin: 'web', method: 'breb', status: 'porpagar', receipt: null, created: stampNow(), exp: Date.now() + 24 * 3600e3, tickets: Array.from({ length: +form.qty }, (_, i) => ({ code: codeGen(r), n: i + 1, used: false, usedAt: null })) }
    setOrders((l) => [...l, o]); setMyOrder(o.code); setPv({ n: 'order', code: o.code })
    setForm({ ...form, name: '', ced: '', phone: '', mail: '', ok: false, qty: 1 })
  }
  const Foot = () => (
    <div className="bo-foot">
      <div><b>Organizan y venden:</b> Colectivo Demo y Banda Ejemplo · {cfg.resp} (1000000000).</div>
      <div><b>Contacto:</b> WhatsApp 3000000000 · demo@ejemplo.test</div>
      <div>Evento para mayores de 18 años. Podemos pedirte la cédula en la puerta.</div>
      <div><a className="bo-lk" onClick={() => setPv({ n: 'terms' })}>Términos y condiciones</a> · <a className="bo-lk" onClick={() => setPv({ n: 'priv' })}>Política de privacidad</a></div>
    </div>
  )
  const Where = () => (
    <div className="bo-sec" style={{ paddingBottom: 0 }}>
      <h2>Cómo llegar</h2>
      <div>{cfg.lugar}</div>
      <button className="bo-btn" style={{ justifySelf: 'start' }} onClick={() => say('Aquí se abriría el mapa (ubicación de ejemplo)')}>Cómo llegar</button>
      <div className="bo-map" aria-hidden="true"><svg viewBox="0 0 300 120" width="100%" height="100%" preserveAspectRatio="none"><path d="M0 40h300M0 85h300M70 0v120M180 0v120M250 0v120" stroke="#c9c2b2" strokeWidth="6" fill="none" /><circle cx="180" cy="62" r="9" fill="#c1121f" stroke="#151312" strokeWidth="2" /></svg></div>
    </div>
  )

  const landing = () => (
    <div className="bo-frame">
      <div className="bo-ribbon">{EVENT.date} · Bucaramanga · Puertas 7:00 p.m.</div>
      <div className="bo-hero">
        <div className="bo-poster"><small>CRA. 20 # 10-30 · CENTRO</small><div className="big">Madrugada<br />Eléctrica</div><div className="mid">ROCK &amp; METAL</div><Skull /></div>
        <div className="bo-bands">Cuervo Seco · Marea Negra · Polvo de Cobre · Radio Ciega · Los Últimos Faros</div>
        <div className="bo-logo">COLECTIVO · DEMO</div>
        <button className="bo-btn acc" onClick={() => document.getElementById('bo-form')?.scrollIntoView({ block: 'start' })}>Comprar boletas</button>
      </div>
      <div className="bo-info"><div>Apertura de puertas<b>7:00 p.m.</b></div><div>Inicio del show<b>8:30 p.m.</b></div></div>
      <div className="bo-price">Entrada<br />Preventa <b>$ 30.000</b><br />Taquilla <b style={{ color: 'var(--ink2)' }}>$ 35.000</b><br /><span className="sv">Ahorra $ 5.000 comprando antes</span></div>
      {myOrder && <div className="bo-sec" style={{ paddingBottom: 0 }}><div className="bo-av warn">Tienes el pedido {myOrder}. <a onClick={() => setPv({ n: 'order', code: myOrder })}>Ver mi pedido</a></div></div>}
      <form id="bo-form" onSubmit={reservar} noValidate>
        <div className="bo-sec">
          <div className="bo-av info"><b>Evento para mayores de 18 años.</b><br />Podemos pedirte la cédula en la puerta.</div>
          {!web.open && <div className="bo-av mal">La venta en línea está cerrada por ahora.</div>}
          <h2>1. Escoge tu entrada</h2>
          {webTipos.length === 0 && <div className="bo-av warn">No hay entradas disponibles en la web.</div>}
          {webTipos.map((t) => (
            <label key={t.id} className={`bo-opt ${sel?.id === t.id ? '' : 'off'}`}><input type="radio" name="tipo" checked={sel?.id === t.id} onChange={() => setForm({ ...form, tipo: t.id, qty: 1 })} />{t.name} · {t.cupo ? `Quedan ${quedan(t)}` : 'Disponible'}<span className="p">{money(t.price)}</span></label>
          ))}
          <label className="bo-f">¿Cuántas personas?<select value={form.qty} onChange={(e) => setForm({ ...form, qty: +e.target.value })}>{Array.from({ length: 10 }, (_, i) => i + 1).map((n) => <option key={n}>{n}</option>)}</select><small>Cada persona recibe su propio QR.</small></label>
          {sel && quedan(sel) < form.qty && <div className="bo-av mal">Solo quedan {quedan(sel)} entradas de {sel.name}.</div>}
          <h2>2. Tus datos</h2>
          <label className="bo-f">Nombre completo<input value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} autoComplete="off" /></label>
          <label className="bo-f">Cédula<input inputMode="numeric" value={form.ced} onChange={(e) => setForm({ ...form, ced: e.target.value.replace(/\D/g, '') })} /></label>
          <label className="bo-f">Celular<input inputMode="tel" value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} /></label>
          <label className="bo-f">Correo<small>Aquí te enviamos tus boletas cuando confirmemos tu pago. Revisa también la carpeta de spam.</small><input type="email" value={form.mail} onChange={(e) => setForm({ ...form, mail: e.target.value })} /></label>
          <label className="bo-chk"><input type="checkbox" checked={form.ok} onChange={(e) => setForm({ ...form, ok: e.target.checked })} /><span>Acepto los <a className="bo-lk" onClick={(e) => { e.preventDefault(); setPv({ n: 'terms' }) }}>términos y condiciones</a> y autorizo el uso de mis datos (nombre, cédula, celular, correo y comprobante) para gestionar mi entrada, enviarla a mi correo y controlar el ingreso, según la <a className="bo-lk" onClick={(e) => { e.preventDefault(); setPv({ n: 'priv' }) }}>política de privacidad</a>.</span></label>
          {err && <div className="bo-av mal">{err}</div>}
          <button className="bo-btn acc blk" disabled={!formOk}>Reservar · {sel ? money(sel.price * form.qty) : '$ 0'}</button>
          <p className="bo-note">Después de reservar te mostramos cómo pagar por Bre-B o Nequi. Tienes 24 horas para pagar; si no, la reserva se cancela. Confirmamos tu pago en un plazo máximo de 24 horas y entonces te enviamos las boletas a tu correo. <b>Revisa la carpeta de spam o correo no deseado:</b> nuestros correos pueden llegar ahí.</p>
        </div>
      </form>
      <Where /><Foot />
    </div>
  )

  const legal = (kind) => (
    <div className="bo-frame"><div className="bo-pg">
      {kind === 'priv' ? (
        <>
          <h1>Política de privacidad</h1><p className="bo-note">Tratamiento de datos personales (Ley 1581 de 2012) · Versión de ejemplo del 9 de noviembre de 2026</p>
          <h2>Quién es el responsable</h2><p>Colectivo Demo y Banda Ejemplo, representadas por {cfg.resp}, organizadoras y vendedoras de las entradas. Contacto: WhatsApp 3000000000.</p>
          <h2>Qué datos pedimos</h2><p>Tu nombre, cédula, celular y correo, necesarios para vender, confirmar tu pago, enviarte las boletas y controlar el ingreso; y la imagen o PDF de tu comprobante. No recogemos datos de menores. La venta es para mayores de 18 años.</p>
          <h2>Para qué los usamos</h2><p>Reservar y validar tu pedido, generar tu entrada con QR, controlar el ingreso y contactarte si hay un problema. No usamos tus datos para publicidad.</p>
          <h2>Cuánto tiempo los guardamos</h2><p>Hasta 90 días después del evento. Luego anonimizamos los pedidos y borramos los comprobantes.</p>
          <h2>Tus derechos</h2><p>Puedes conocer, actualizar, rectificar y pedir que borremos tus datos, y revocar tu autorización. Escríbenos con tu nombre y el código de tu pedido.</p>
          <h2>El enlace de tu pedido</h2><p>Quien tenga el enlace de tu pedido puede ver tus entradas. Es privado: no lo compartas.</p>
        </>
      ) : (
        <>
          <h1>Términos y condiciones</h1><p className="bo-note">Compra de entradas · Versión de ejemplo del 9 de noviembre de 2026</p>
          <h2>1. Quién vende</h2><p>Las entradas las venden Colectivo Demo y Banda Ejemplo. El lugar del show no es el vendedor.</p>
          <h2>2. Qué compras</h2><p>Una entrada al show {cfg.nombre} el 20 de diciembre de 2026. Cada persona recibe su propio código QR, que sirve para un solo ingreso.</p>
          <h2>3. Precio</h2><p>Los precios están en pesos colombianos y son el valor final. La preventa termina cuando la desactivemos o se agoten las entradas.</p>
          <h2>4. Cómo se paga</h2><p>Por Bre-B o Nequi. Tu entrada se activa cuando validamos tu comprobante, en máximo 24 horas. Tienes 24 horas desde que reservas para pagar.</p>
          <h2>5. Ingreso al evento</h2><p>Evento para mayores de 18 años. Presenta tu QR o el código corto en la puerta. Cada QR entra una sola vez.</p>
          <h2>6. Devoluciones</h2><p>Solo hay devolución si el show se cancela o se aplaza.</p>
        </>
      )}
      <a className="bo-lk" onClick={() => setPv({ n: 'landing' })}>Volver a las entradas</a>
    </div><Foot /></div>
  )

  const orderV = (o) => {
    if (!o) return (
      <div className="bo-frame"><div className="bo-pg"><h1>No encontramos este pedido</h1><p>Revisa que el enlace esté completo. Si el problema sigue, escríbenos.</p><button className="bo-btn" style={{ justifySelf: 'start' }} onClick={() => setPv({ n: 'landing' })}>Volver</button></div></div>
    )
    const left = o.exp ? Math.max(0, o.exp - Date.now()) : 24 * 3600e3 - 3 * 60e3
    const hh = Math.floor(left / 3600e3), mm = Math.floor((left % 3600e3) / 60e3)
    const [lab, cls] = STATUS[o.status]
    const stepsA = o.status === 'confirmada' ? ['Reserva recibida', 'Comprobante recibido', 'Pago confirmado'] : o.status === 'porvalidar' ? ['Reserva recibida', 'Comprobante recibido', 'Validamos tu pago (máx. 24 h)'] : ['Reserva recibida', 'Sube tu comprobante', 'Validamos tu pago (máx. 24 h)']
    const cur = o.status === 'confirmada' ? 3 : o.status === 'porvalidar' ? 2 : 1
    const upload = (e) => { const f = e.target.files?.[0]; if (!f) return; if (f.size > 5 * 1024 * 1024) { say('El archivo pasa de 5 MB'); return } setOrders((l) => l.map((x) => (x.code === o.code ? { ...x, receipt: f.name, status: 'porvalidar' } : x))); say('Comprobante recibido') }
    const conf = o.status === 'confirmada'
    const guardaBox = (
      <div className="bo-box l"><div className="bo-lbl">Guarda este enlace</div><div className="bo-note">Es la forma de ver tus boletas en cualquier momento, aunque el correo no te llegue. Cópialo o envíatelo por WhatsApp.</div>
          <div className="bo-acts"><button className="bo-btn sm cl" onClick={() => copy(linkOf(o), 'Enlace copiado')}>Copiar enlace</button><button className="bo-btn sm cl" onClick={() => say('Se abriría WhatsApp con tu enlace')}>Envíamelo por WhatsApp</button></div></div>
    )
    return (
      <div className="bo-frame"><div className="bo-pg" style={{ gap: 11 }}>
        <a className="bo-lk" style={{ fontSize: 13, justifySelf: 'start', textDecoration: 'none' }} onClick={() => setPv({ n: 'landing' })}>← Inicio</a>
        <div className="bo-note">{cfg.nombre}</div>
        <h1 style={{ border: 0, paddingBottom: 0 }}>Pedido {o.code}</h1>
        <div><span className={`bo-tag ${cls}`}>{lab}</span> &nbsp;<b>{o.qty} × {o.tipo} · {money2(o.total)}</b></div>
        <div className="bo-note">{EVENT.long} · <u>{cfg.lugar}</u></div>
        {conf && guardaBox}
        {o.status !== 'anulada' && o.status !== 'rechazada' && (
          <div className="bo-box"><div className="bo-lbl">Estado de tu pago</div>
            <div className="bo-steps">{stepsA.map((s, i) => <div key={s} className={`bo-step ${i < cur ? '' : i === cur ? 'cur' : 'todo'}`}><i>{i < cur ? '✓' : i + 1}</i>{s}</div>)}</div>
            {o.status === 'confirmada' && <div className="bo-note">Tu QR está activo.</div>}{o.status === 'porpagar' && <div className="bo-note">Paga y sube la captura de tu comprobante para activar tu entrada.</div>}</div>
        )}
        {o.status === 'confirmada' && <div className="bo-av ok">Pago validado. Presenta estos QR en la entrada.</div>}
        {o.status === 'confirmada' && <div className="bo-note">También te enviamos las boletas por correo. Si no llegan, <b>revisa la carpeta de spam o correo no deseado</b>; aquí siempre las tienes.</div>}
        {o.status === 'porvalidar' && <div className="bo-av warn">Recibimos tu comprobante. Lo estamos validando; esta página se actualiza sola cuando se confirme.</div>}
        {o.status === 'rechazada' && <div className="bo-av mal">No pudimos validar tu comprobante. Sube uno nuevo para que lo revisemos otra vez.</div>}
        {o.status === 'anulada' && <div className="bo-av mal">Este pedido fue anulado y las entradas se liberaron.</div>}
        {(o.status === 'porpagar' || o.status === 'rechazada') && (
          <>
            <div className="bo-av warn"><b>Tienes hasta el martes, 10 de noviembre, 3:00 p. m. para pagar (te quedan {hh} h {mm} min).</b> Pasado ese plazo la reserva se cancela y las entradas se liberan para otras personas.</div>
            <div className="bo-av warn">Te enviamos un correo con estos datos. Si no lo ves, <b>revisa la carpeta de spam o correo no deseado.</b></div>
            <div className="bo-box dash"><div className="bo-lbl">Paga por Bre-B o Nequi</div>
              <div className="bo-pay"><div className="bo-note">BRE-B · LLAVE<br /><b style={{ color: 'var(--ink)' }}>{cfg.breb}</b></div><button className="bo-btn sm cl" onClick={() => copy(cfg.breb)}>Copiar</button>
                <div className="bo-note">NEQUI · NÚMERO<br /><b style={{ color: 'var(--ink)' }}>{cfg.nequi}</b></div><button className="bo-btn sm cl" onClick={() => copy(cfg.nequi)}>Copiar</button></div>
              <div className="bo-note">A nombre de {cfg.titular}</div><div><b>Valor exacto: {money(o.total)}</b></div>
              <div className="bo-note">En la descripción de la transferencia escribe este código para ubicarla rápido:</div>
              <div className="bo-pay"><b>{o.code}</b><button className="bo-btn sm cl" onClick={() => copy(o.code)}>Copiar</button></div></div>
            <div className="bo-box"><div className="bo-lbl">Sube tu comprobante</div>
              <label className="bo-btn blk" style={{ cursor: 'pointer' }}>Elegir captura o foto<input type="file" accept="image/*,application/pdf" hidden onChange={upload} aria-label="Elegir comprobante" /></label>
              <button className="bo-btn cl sm" style={{ justifySelf: 'start' }} onClick={() => { setOrders((l) => l.map((x) => (x.code === o.code ? { ...x, receipt: 'comprobante-demo.png', status: 'porvalidar' } : x))); say('Comprobante de ejemplo enviado') }}>Usar comprobante de ejemplo</button>
              <div className="bo-note">Imagen o PDF, máximo 5 MB.</div></div>
          </>
        )}
        {!conf && o.status !== 'anulada' && guardaBox}
        {o.status !== 'anulada' && <div className="bo-lbl" style={{ marginTop: 4 }}>{o.status === 'confirmada' ? 'Tus entradas' : 'Tus entradas'}</div>}
        {o.status === 'porpagar' && <div className="bo-note">Ya están reservadas con su QR, pero no sirven para entrar hasta que confirmemos tu pago. Cuando se confirme, esta página se actualiza sola y el QR se activa.</div>}
        {o.status !== 'anulada' && o.tickets.map((t) => {
          const act = o.status === 'confirmada'
          return (
            <div key={t.code} className={`bo-tk ${!act ? 'pend' : t.used ? 'used' : ''}`} data-code={t.code}>
              <header>{cfg.nombre}<small>{EVENT.date}</small></header>
              <div className="bd">
                <Qr value={t.code} />
                {act && t.used && <div className="bo-stamp">YA INGRESÓ</div>}
                {!act && <div className="bo-pend-t">PENDIENTE DE PAGO</div>}
                <div className="cd">{t.code}</div><div className="nm">{o.name} · {t.n} de {o.qty}</div>
                <div className="sub">{o.tipo}{act ? (t.used ? ' · Ya ingresó' : '') : ' · se activa al confirmar el pago'}</div>
                {act && <button className="bo-btn sm cl" onClick={() => say('Imagen guardada (demo)')}>Guardar imagen</button>}
              </div>
            </div>
          )
        })}
        {o.status === 'confirmada' && <div className="bo-note" style={{ textAlign: 'center' }}>Tip: sube el brillo del celular al llegar.</div>}
        <div className="bo-box" style={{ textAlign: 'center' }}><h3>{conf ? '¿Van más amigos?' : '¿Quieres más boletas?'}</h3><div className="bo-note">Haz otra reserva para más personas. Cada pedido tiene su propio enlace y su propio pago.</div><button className="bo-btn acc blk" onClick={() => setPv({ n: 'landing' })}>Comprar más boletas</button></div>
        <a className="bo-lk" style={{ textAlign: 'center' }} onClick={() => setPv({ n: 'landing' })}>Volver a la página de inicio</a>
      </div><Where /><Foot /></div>
    )
  }

  // ---------- staff
  const validate = (raw) => {
    let c = raw.trim().toUpperCase().replace(/\s/g, ''); if (/^[A-Z0-9]{6}$/.test(c)) c = c.slice(0, 3) + '-' + c.slice(3)
    if (!c) return
    const o = orders.find((x) => x.tickets.some((t) => t.code === c))
    if (!o) { setScan((s) => ({ ...s, res: { k: 'mal', h: 'CÓDIGO NO VÁLIDO', a: 'No encontramos esa entrada.', b: 'Revisa que esté bien escrito.' } })); return }
    const t = o.tickets.find((x) => x.code === c)
    if (o.status !== 'confirmada') { setScan((s) => ({ ...s, res: { k: 'warn', h: 'PAGO NO CONFIRMADO', a: `${o.name} · ${o.tipo}`, b: 'El pedido aún no se valida. No dejar pasar.' } })); return }
    if (t.used) { setScan((s) => ({ ...s, res: { k: 'mal', h: 'YA INGRESÓ', a: `${o.name} · entrada ${t.n} de ${o.qty}`, b: `Entró ${t.usedAt}` } })); return }
    const at = stamp()
    setOrders((l) => l.map((x) => (x.code === o.code ? { ...x, tickets: x.tickets.map((y) => (y.code === c ? { ...y, used: true, usedAt: at } : y)) } : x)))
    const group = o.tickets.filter((y) => y.used || y.code === c).length
    setScan((s) => ({ ...s, res: { k: 'ok', h: 'PASA. DALE MANILLA', a: `${o.name} · ${o.tipo}`, b: `Entrada ${t.n} de ${o.qty} · ya entraron ${group} del grupo` } }))
    setCode('')
  }
  const escaner = () => {
    const r = scan.res
    return (
      <div className="bo-pg">
        <div className="bo-g2"><div className="bo-stat"><b>{used}</b><span>ya ingresaron</span></div><div className="bo-stat"><b>{tks.length - used}</b><span>faltan por entrar</span></div></div>
        {r && <div className={`bo-res ${r.k}`} role="status"><h2>{r.h}</h2><div><b>{r.a}</b></div><div>{r.b}</div></div>}
        {scan.cam ? (
          <>
            <div className="bo-cam"><span>Cámara simulada. Apunta al QR de una entrada.</span></div>
            <div className="bo-acts" style={{ justifyContent: 'center' }}>
              <button className="bo-btn sm" onClick={() => { const nx = confirmed.flatMap((o) => o.tickets).find((t) => !t.used); if (nx) validate(nx.code); else say('No quedan entradas por leer') }}>Leer un QR de ejemplo</button>
              <button className="bo-btn sm cl" onClick={() => setScan({ ...scan, cam: false })}>Apagar cámara</button></div>
          </>
        ) : <button className="bo-btn dk" onClick={() => setScan({ ...scan, cam: true })}>Encender cámara</button>}
        <form onSubmit={(e) => { e.preventDefault(); validate(code) }} style={{ display: 'grid', gap: 8 }}>
          <h3 style={{ textTransform: 'none', letterSpacing: 0, fontFamily: 'inherit', fontWeight: 700, fontSize: 16 }}>Código manual</h3>
          <div className="bo-note">Si el QR no se lee, escribe el código corto de la entrada (ej. K7M-4PX).</div>
          <input className="bo-in" value={code} onChange={(e) => setCode(e.target.value)} aria-label="Código manual" autoCapitalize="characters" />
          <button className="bo-btn cl blk" disabled={!code.trim()}>Validar</button>
        </form>
      </div>
    )
  }

  const venta = () => {
    const t = tipos.find((x) => x.id === vf.tipo) ?? tipos[0]
    const total = vf.method === 'cortesia' ? 0 : t.price * vf.qty
    const submit = (e) => {
      e.preventDefault()
      if (!vf.name.trim()) return
      if (quedan(t) < vf.qty) { say(`Solo quedan ${quedan(t)} de ${t.name}`); return }
      const r = rng(Date.now() % 99991)
      const at = stamp()
      const o = { code: 'ME-' + (1060 + orders.length), name: vf.name.trim(), ced: vf.ced, phone: vf.phone, email: vf.mail, tipo: t.name, price: vf.method === 'cortesia' ? 0 : t.price, qty: vf.qty, total, origin: 'taquilla', method: vf.method, status: 'confirmada', receipt: null, created: stampNow(), tickets: Array.from({ length: vf.qty }, (_, i) => ({ code: codeGen(r), n: i + 1, used: vf.now, usedAt: vf.now ? at : null })) }
      setOrders((l) => [...l, o]); setVres(o); setVf({ ...vf, name: '', ced: '', phone: '', mail: '', now: false, qty: 1 })
    }
    return (
      <div className="bo-pg">
        <h1>Venta en puerta</h1>
        {vres && <div className="bo-av ok" role="status"><b>Venta registrada · {vres.code}</b> · {vres.qty} × {vres.tipo} · {money2(vres.total)}<br />Códigos: {vres.tickets.map((x) => x.code).join(' · ')}</div>}
        <form onSubmit={submit} style={{ display: 'grid', gap: 10 }}>
          <label className="bo-f">Tipo de entrada<select value={vf.tipo} onChange={(e) => setVf({ ...vf, tipo: e.target.value })}>{tipos.filter((x) => x.active).map((x) => <option key={x.id} value={x.id}>{x.name} · {money(x.price)}</option>)}</select></label>
          <label className="bo-f">Personas<select value={vf.qty} onChange={(e) => setVf({ ...vf, qty: +e.target.value })}>{Array.from({ length: 10 }, (_, i) => i + 1).map((n) => <option key={n}>{n}</option>)}</select></label>
          <label className="bo-f">Forma de pago<select value={vf.method} onChange={(e) => setVf({ ...vf, method: e.target.value })}>{['efectivo', 'breb', 'otra', 'cortesia'].map((m) => <option key={m} value={m}>{METHODS[m]}</option>)}</select></label>
          <label className="bo-f">Nombre<input value={vf.name} onChange={(e) => setVf({ ...vf, name: e.target.value })} /></label>
          <label className="bo-f">Cédula<input inputMode="numeric" placeholder="Opcional" value={vf.ced} onChange={(e) => setVf({ ...vf, ced: e.target.value })} /></label>
          <label className="bo-f">Celular<input inputMode="tel" placeholder="Opcional" value={vf.phone} onChange={(e) => setVf({ ...vf, phone: e.target.value })} /></label>
          <label className="bo-f">Correo<small>Opcional. Si lo pones, enviamos las boletas ahí (útil para cortesías).</small><input type="email" value={vf.mail} onChange={(e) => setVf({ ...vf, mail: e.target.value })} /></label>
          <label className="bo-chk"><input type="checkbox" checked={vf.now} onChange={(e) => setVf({ ...vf, now: e.target.checked })} /><span>Entra ahora mismo (marca el ingreso y entrego la manilla)</span></label>
          <button className="bo-btn acc blk" disabled={!vf.name.trim()}>Cobrar {money(total)}</button>
        </form>
      </div>
    )
  }

  const upd = (code, patch) => setOrders((l) => l.map((x) => (x.code === code ? { ...x, ...patch } : x)))
  const pedidos = () => {
    const list = orders.filter((o) => pf === 'todos' || o.status === pf).slice().reverse()
    const csv = () => {
      const rows = [['codigo', 'cliente', 'cedula', 'celular', 'entrada', 'personas', 'total', 'estado', 'origen', 'pago']].concat(orders.map((o) => [o.code, o.name, o.ced, o.phone, o.tipo, o.qty, o.total, o.status, o.origin, o.method]))
      const blob = new Blob([rows.map((r) => r.map((c) => `"${String(c).replace(/"/g, '""')}"`).join(',')).join('\n')], { type: 'text/csv' })
      const a = document.createElement('a'); a.href = URL.createObjectURL(blob); a.download = 'pedidos.csv'; a.click(); say('Pedidos exportados a CSV')
    }
    return (
      <div className="bo-pg">
        <div className="bo-inl" style={{ alignItems: 'center', justifyContent: 'space-between' }}><h1 style={{ border: 0, padding: 0 }}>Pedidos</h1><button className="bo-btn sm" onClick={csv}>Exportar CSV</button></div>
        <div className="bo-pills">{[['porvalidar', 'Por validar'], ['porpagar', 'Falta pagar'], ['confirmada', 'Confirmadas'], ['rechazada', 'Rechazadas'], ['anulada', 'Anuladas'], ['todos', 'Todos']].map(([id, l]) => <button key={id} className={`bo-pill ${pf === id ? 'on' : ''}`} aria-pressed={pf === id} onClick={() => setPf(id)}>{l} </button>)}</div>
        {list.length === 0 && <div className="bo-note">No hay pedidos en este estado.</div>}
        {list.slice(0, 40).map((o) => {
          const [lab, cls] = STATUS[o.status]
          return (
            <div key={o.code} className="bo-ord" data-order={o.code}>
              <div className="top"><b>{o.code}</b><span className={`bo-tag ${cls}`}>{lab}</span></div>
              <div className="sm">{o.created}</div>
              <div><b>{o.name}</b></div>
              <div className="sm">{o.ced} · {o.phone}<br />{o.email}</div>
              <div className="sm"><b style={{ color: 'var(--ink)' }}>{o.qty} × {o.tipo}</b> · {o.origin === 'web' ? 'Web' : 'Taquilla'} · {o.method} · <b style={{ color: 'var(--ink)' }}>{money(o.total)}</b></div>
              {rc === o.code && <div className="bo-rc">{o.receipt ? `Comprobante: ${o.receipt}` : 'Sin comprobante'}</div>}
              <div className="bo-acts">
                {o.status !== 'confirmada' || o.receipt ? <button className="bo-btn sm cl" onClick={() => setRc(rc === o.code ? null : o.code)}>Ver comprobante</button> : null}
                <button className="bo-btn sm cl" onClick={() => copy(linkOf(o), 'Enlace copiado')}>Copiar enlace</button>
                <button className="bo-btn sm cl" onClick={() => say('Se abriría WhatsApp con el enlace')}>Enviar por WhatsApp</button>
                {o.status === 'porvalidar' && <><button className="bo-btn sm acc" onClick={() => upd(o.code, { status: 'confirmada' })}>Confirmar</button><button className="bo-btn sm bad" onClick={() => upd(o.code, { status: 'rechazada' })}>Rechazar</button></>}
                {o.status === 'porpagar' && <button className="bo-btn sm bad" onClick={() => upd(o.code, { status: 'anulada' })}>Anular</button>}
              </div>
            </div>
          )
        })}
      </div>
    )
  }

  const tablero = () => {
    const pers = (f) => confirmed.filter(f).reduce((a, o) => a + o.qty, 0)
    const rec = (f) => confirmed.filter(f).reduce((a, o) => a + o.total, 0)
    const conf = confirmed.reduce((a, o) => a + o.qty, 0)
    const unpaid = orders.filter((o) => o.status === 'porpagar').reduce((a, o) => a + o.qty, 0)
    const pendP = pendV.reduce((a, o) => a + o.qty, 0), pendT = pendV.reduce((a, o) => a + o.total, 0)
    const byM = Object.keys(METHODS).map((m) => [m, pers((o) => o.method === m), rec((o) => o.method === m)]).filter((x) => x[1] > 0)
    const byO = [['web', 'Web (preventa)'], ['taquilla', 'Taquilla']].map(([k, l]) => [l, pers((o) => o.origin === k), rec((o) => o.origin === k)])
    return (
      <div className="bo-pg">
        <h1>Tablero</h1>
        {pendV.length > 0 && <div className="bo-av warn">Hay <b>{pendV.length}</b> pedido(s) esperando validación ({pendP} personas, {money(pendT)}). <a onClick={() => { setPf('porvalidar'); setSp('pedidos') }}>Revisar ahora</a></div>}
        <div className="bo-g2">
          <div className="bo-stat"><b>{conf}</b><span>entradas confirmadas de {web.aforo}</span><div className="pr"><i style={{ width: `${Math.min(100, (conf / web.aforo) * 100)}%` }} /></div></div>
          <div className="bo-stat"><b>{used}</b><span>ya ingresaron · faltan {conf - used}</span></div>
          <div className="bo-stat"><b style={{ fontSize: 23, whiteSpace: 'nowrap' }}>{money2(rec(() => true))}</b><span>recaudo confirmado</span></div>
          <div className="bo-stat w"><b>{pendV.length}</b><span>pedidos por validar</span></div>
          <div className="bo-stat"><b>{unpaid}</b><span>reservados sin pagar</span></div>
        </div>
        <h2>Por tipo de entrada</h2>
        <div className="bo-tw"><table className="bo-t"><thead><tr><th>Tipo</th><th className="r">Precio</th><th className="r">Vend.</th><th className="r">Cupo</th><th className="r">Ingr.</th><th className="r">Recaudo</th></tr></thead><tbody>
          {tipos.map((t) => <tr key={t.id}><td>{t.name}</td><td className="r">{money(t.price)}</td><td className="r">{pers((o) => o.tipo === t.name)}</td><td className="r">{t.cupo ?? '∞'}</td><td className="r">{confirmed.filter((o) => o.tipo === t.name).flatMap((o) => o.tickets).filter((x) => x.used).length}</td><td className="r">{money(rec((o) => o.tipo === t.name))}</td></tr>)}</tbody></table></div>
        <h2>Por forma de pago</h2>
        <div className="bo-tw"><table className="bo-t"><thead><tr><th>Método</th><th className="r">Personas</th><th className="r">Recaudo</th></tr></thead><tbody>{byM.map(([m, p, r]) => <tr key={m}><td>{METHODS[m]}</td><td className="r">{p}</td><td className="r">{money(r)}</td></tr>)}</tbody></table></div>
        <h2>Dónde se vendió</h2>
        <div className="bo-tw"><table className="bo-t"><thead><tr><th>Origen</th><th className="r">Personas</th><th className="r">Recaudo</th></tr></thead><tbody>{byO.map(([l, p, r]) => <tr key={l}><td>{l}</td><td className="r">{p}</td><td className="r">{money(r)}</td></tr>)}</tbody></table></div>
        <div className="bo-note">Se actualiza solo cada pocos segundos.</div>
      </div>
    )
  }

  const equipo = () => (
    <div className="bo-pg">
      <h1>Equipo</h1>
      <div className="bo-note">Crea cuentas con correo y contraseña para tus socios.</div>
      <div className="bo-box">{accs.map((a) => <div key={a.mail} className="bo-inl" style={{ alignItems: 'center', justifyContent: 'space-between' }}><span>{a.mail}</span><span className="bo-tag gr">{a.role}</span></div>)}</div>
      <form className="bo-set" onSubmit={(e) => { e.preventDefault(); if (!na.mail.includes('@')) return; setAccs([...accs, { ...na }]); setNa({ mail: '', role: 'taquilla' }); say('Cuenta creada') }}>
        <div className="bo-lbl">Nueva cuenta</div>
        <label className="bo-f">Correo<input type="email" value={na.mail} onChange={(e) => setNa({ ...na, mail: e.target.value })} /></label>
        <label className="bo-f">Rol<select value={na.role} onChange={(e) => setNa({ ...na, role: e.target.value })}><option value="taquilla">taquilla (escáner y venta)</option><option value="validador">validador (+ pedidos y tablero)</option><option value="admin">admin</option></select></label>
        <button className="bo-btn" disabled={!na.mail.includes('@')}>Crear cuenta</button>
      </form>
    </div>
  )

  const ajustes = () => (
    <div className="bo-pg">
      <h1>Ajustes</h1>
      <div className="bo-set"><div className="bo-lbl">Venta en la web</div><div>{web.open ? 'Abierta: la gente puede reservar.' : 'Cerrada: nadie puede reservar.'}</div><button className="bo-btn" onClick={() => setWeb({ ...web, open: !web.open })}>{web.open ? 'Cerrar ventas' : 'Abrir ventas'}</button></div>
      <div className="bo-set"><div className="bo-lbl">Tipos de entrada</div><div className="bo-note">Para cerrar la preventa, desactiva su tipo. Para abrir la general, actívala. El cupo vacío es sin límite.</div>
        {tipos.map((t) => (
          <div key={t.id} className="bo-box" style={{ opacity: t.active ? 1 : 0.6 }}>
            <b>{t.name} · {money(t.price)}</b><div className="bo-note">Cupo: {t.cupo ?? 'sin límite'}{t.soloTaq ? ' · solo taquilla' : ''}{t.active ? '' : ' · desactivado'}</div>
            {edit?.id === t.id ? (
              <div className="bo-inl"><input className="bo-in" inputMode="numeric" aria-label={edit.f === 'cupo' ? 'Nuevo cupo' : 'Nuevo precio'} value={edit.v} onChange={(e) => setEdit({ ...edit, v: e.target.value.replace(/\D/g, '') })} /><button className="bo-btn sm" onClick={() => { setTipos(tipos.map((x) => (x.id === t.id ? { ...x, [edit.f]: edit.v === '' ? (edit.f === 'cupo' ? null : x.price) : +edit.v } : x))); setEdit(null) }}>Guardar</button></div>
            ) : (
              <div className="bo-acts"><button className="bo-btn sm cl" onClick={() => setEdit({ id: t.id, f: 'cupo', v: String(t.cupo ?? '') })}>Cupo</button><button className="bo-btn sm cl" onClick={() => setEdit({ id: t.id, f: 'price', v: String(t.price) })}>Precio</button><button className="bo-btn sm bad" onClick={() => setTipos(tipos.map((x) => (x.id === t.id ? { ...x, active: !x.active } : x)))}>{t.active ? 'Desactivar' : 'Activar'}</button></div>
            )}
          </div>
        ))}
        <form style={{ display: 'grid', gap: 8 }} onSubmit={(e) => { e.preventDefault(); if (!nt.name.trim() || !nt.price) return; setTipos([...tipos, { id: 't' + Date.now(), name: nt.name.trim(), price: +nt.price, cupo: nt.cupo ? +nt.cupo : null, active: true, soloTaq: nt.taq }]); setNt({ name: '', price: '', cupo: '', taq: false }); say('Tipo agregado') }}>
          <div className="bo-lbl">Nuevo tipo</div>
          <label className="bo-f">Nombre<input value={nt.name} onChange={(e) => setNt({ ...nt, name: e.target.value })} /></label>
          <label className="bo-f">Precio (COP)<input inputMode="numeric" value={nt.price} onChange={(e) => setNt({ ...nt, price: e.target.value.replace(/\D/g, '') })} /></label>
          <label className="bo-f">Cupo<input inputMode="numeric" placeholder="Opcional" value={nt.cupo} onChange={(e) => setNt({ ...nt, cupo: e.target.value.replace(/\D/g, '') })} /></label>
          <label className="bo-chk"><input type="checkbox" checked={nt.taq} onChange={(e) => setNt({ ...nt, taq: e.target.checked })} /><span>Solo en taquilla</span></label>
          <button className="bo-btn" disabled={!nt.name.trim() || !nt.price}>Agregar tipo</button>
        </form>
      </div>
      <div className="bo-set"><div className="bo-lbl">Ajustes del evento · El show</div>
        <label className="bo-f">Nombre<input value={cfg.nombre} onChange={(e) => setCfg({ ...cfg, nombre: e.target.value })} /></label>
        <label className="bo-f">Lugar<small>Con ciudad: alimenta el mapa y el botón Cómo llegar.</small><input value={cfg.lugar} onChange={(e) => setCfg({ ...cfg, lugar: e.target.value })} /></label>
        <label className="bo-f">Aforo máximo<small>Vacío = sin tope.</small><input inputMode="numeric" value={web.aforo} onChange={(e) => setWeb({ ...web, aforo: +e.target.value.replace(/\D/g, '') || 1 })} /></label>
        <div className="bo-lbl" style={{ marginTop: 4 }}>Cobro</div>
        <label className="bo-f">Llave Bre-B<input value={cfg.breb} onChange={(e) => setCfg({ ...cfg, breb: e.target.value })} /></label>
        <label className="bo-f">Número Nequi<input value={cfg.nequi} onChange={(e) => setCfg({ ...cfg, nequi: e.target.value })} /></label>
        <label className="bo-f">Titular de la cuenta<small>Nombre que le sale a quien paga al confirmar.</small><input value={cfg.titular} onChange={(e) => setCfg({ ...cfg, titular: e.target.value })} /></label>
        <button className="bo-btn" onClick={() => say('Ajustes guardados')}>Guardar</button>
      </div>
      <div className="bo-set"><div className="bo-lbl">Después del evento: borrar datos personales</div><div className="bo-note">La política de privacidad promete conservar los datos hasta 90 días después del evento. Antes de esa fecha este botón no hace nada y te dice desde cuándo se puede.</div><button className="bo-btn bad" onClick={() => say('Todavía no: se puede desde el 20 de marzo de 2027')}>Anonimizar datos y borrar comprobantes</button></div>
    </div>
  )

  const login = () => (
    <div className="bo-frame"><div className="bo-pg" style={{ paddingTop: 30 }}>
      <h1>Equipo</h1><p>Acceso para validar pagos, vender en taquilla y escanear.</p>
      <label className="bo-f">Correo<input type="email" defaultValue="admin@ejemplo.test" /></label>
      <label className="bo-f">Contraseña<input type="password" defaultValue="demo1234" /></label>
      <button className="bo-btn acc blk" onClick={() => { setLogged(true); setSp('escaner') }}>Entrar</button>
      <button className="bo-btn cl blk" onClick={() => say('Crear cuentas no está disponible en la demo')}>Crear cuenta nueva</button>
    </div></div>
  )

  const NAV = [['escaner', 'Escáner'], ['venta', 'Venta'], ['pedidos', 'Pedidos'], ['tablero', 'Tablero'], ['equipo', 'Equipo'], ['ajustes', 'Ajustes']]
  const STAFF = { escaner, venta, pedidos, tablero, equipo, ajustes }

  return (
    <div className="bo">
      <div className="bo-sw">
        {[['pub', 'Público'], ['staff', 'Staff']].map(([id, l]) => <button key={id} className={role === id ? 'on' : ''} aria-pressed={role === id} onClick={() => setRole(id)}>{l}</button>)}
        <span>demo · datos inventados</span>
      </div>
      {role === 'staff' && logged && (
        <nav className="bo-nav" aria-label="Staff">
          {NAV.map(([id, l]) => <button key={id} className={sp === id ? 'on' : ''} onClick={() => setSp(id)}>{l}</button>)}
          <span className="role">admin</span><button className="out" onClick={() => { setLogged(false); setRole('pub') }}>Salir</button>
        </nav>
      )}
      <div className="bo-scroll" ref={scroller}>
        {role === 'pub' ? (pv.n === 'landing' ? landing() : pv.n === 'order' ? orderV(orders.find((o) => o.code === pv.code)) : legal(pv.n)) : logged ? STAFF[sp]() : login()}
      </div>
      {toast && <div className="bo-toast" role="status">{toast}</div>}
    </div>
  )
}
