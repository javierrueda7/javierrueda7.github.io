import { useState } from 'react'
import { TabBar, useToast, cop } from '../lib/ui.jsx'

const TYPES = [
  { id: 'pre', name: 'Preventa', price: 30000, left: 40 },
  { id: 'taq', name: 'Taquilla', price: 35000, left: 120 },
]
const FAKE = ['Laura Gómez', 'Jhon Ríos', 'Natalia Pardo', 'Camilo Duarte', 'Sara Ochoa', 'Brayan Mora']

const seed = FAKE.map((n, i) => ({
  id: 1001 + i, name: n, type: i % 2 ? 'taq' : 'pre', qty: 1 + (i % 3 === 0 ? 1 : 0),
  status: i < 4 ? 'paid' : 'pending', entered: i < 2 ? 1 : 0,
}))

// QR de ejemplo: patrón determinista (no codifica nada real).
function Qr({ code }) {
  const n = 21
  let h = 0
  for (const c of String(code)) h = (h * 31 + c.charCodeAt(0)) >>> 0
  const cells = []
  for (let y = 0; y < n; y++) for (let x = 0; x < n; x++) {
    const finder = (x < 7 && y < 7) || (x > n - 8 && y < 7) || (x < 7 && y > n - 8)
    let on
    if (finder) {
      const fx = x % (n - 7) < 7 ? x % (n - 7) : x - (n - 7)
      const fy = y % (n - 7) < 7 ? y % (n - 7) : y - (n - 7)
      on = fx === 0 || fx === 6 || fy === 0 || fy === 6 || (fx > 1 && fx < 5 && fy > 1 && fy < 5)
    } else { h = (h * 1103515245 + 12345) >>> 0; on = (h >> 16) & 1 }
    if (on) cells.push(<rect key={`${x}-${y}`} x={x} y={y} width="1" height="1" />)
  }
  return <svg viewBox={`0 0 ${n} ${n}`} width="150" height="150" role="img" aria-label="Código QR de ejemplo" style={{ background: '#fff', padding: 6, borderRadius: 8 }}>{cells}</svg>
}

export default function Boleteria() {
  const [role, setRole] = useState('public')
  const [orders, setOrders] = useState(seed)
  const [mine, setMine] = useState(null)
  const [next, setNext] = useState(1007)
  const [tab, setTab] = useState('pedidos')
  const [toast, toastNode] = useToast()
  const [scan, setScan] = useState('')
  const [scanMsg, setScanMsg] = useState(null)
  const [form, setForm] = useState({ type: 'pre', qty: 1, name: '' })
  const t = (id) => TYPES.find((x) => x.id === id)

  const buy = (e) => {
    e.preventDefault()
    if (!form.name.trim()) return toast('Escribe tu nombre')
    const o = { id: next, name: form.name.trim(), type: form.type, qty: form.qty, status: 'pending', entered: 0, proof: false }
    setOrders((l) => [o, ...l]); setMine(o.id); setNext(next + 1)
  }
  const upd = (id, patch) => setOrders((l) => l.map((o) => (o.id === id ? { ...o, ...patch } : o)))
  const my = orders.find((o) => o.id === mine)

  const doScan = (e) => {
    e.preventDefault()
    const o = orders.find((x) => String(x.id) === scan.trim())
    if (!o) return setScanMsg({ ok: false, t: 'Código no existe' })
    if (o.status !== 'paid') return setScanMsg({ ok: false, t: `Pedido ${o.id}: pago sin validar` })
    if (o.entered >= o.qty) return setScanMsg({ ok: false, t: `Ya ingresaron ${o.entered}/${o.qty}. Entrada repetida.` })
    upd(o.id, { entered: o.entered + 1 })
    setScanMsg({ ok: true, t: `Adelante, ${o.name} (${o.entered + 1}/${o.qty})` })
  }
  const sold = orders.filter((o) => o.status === 'paid').reduce((s, o) => s + o.qty, 0)
  const entered = orders.reduce((s, o) => s + o.entered, 0)
  const money = orders.filter((o) => o.status === 'paid').reduce((s, o) => s + o.qty * t(o.type).price, 0)

  const staffTabs = [
    { id: 'pedidos', label: 'Pedidos', icon: 'list' },
    { id: 'scan', label: 'Escáner', icon: 'ball' },
    { id: 'board', label: 'Tablero', icon: 'chart' },
  ]

  return (
    <div className="app" style={{ background: '#f4f3f1' }}>
      <div className="app-top"><h3>Noche de Rock</h3><small>evento de ejemplo</small></div>
      <div style={{ display: 'flex', gap: 6, padding: '10px 14px 0' }}>
        {[['public', 'Público'], ['staff', 'Staff']].map(([id, l]) => <button key={id} className={`sbtn sm ${role === id ? '' : 'ghost'}`} onClick={() => setRole(id)}>{l}</button>)}
      </div>
      <div className="app-body">
        {role === 'public' && !my && (
          <form onSubmit={buy} style={{ display: 'grid', gap: 10 }}>
            <div className="h">Comprar entradas</div>
            {TYPES.map((x) => (
              <label key={x.id} className="card row" style={{ cursor: 'pointer', outline: form.type === x.id ? '2px solid var(--app)' : 'none' }}>
                <span><input type="radio" name="tt" checked={form.type === x.id} onChange={() => setForm({ ...form, type: x.id })} /> <strong>{x.name}</strong><div className="sub">Quedan {x.left}</div></span>
                <strong>{cop(x.price)}</strong>
              </label>
            ))}
            <label className="field">Cantidad<select value={form.qty} onChange={(e) => setForm({ ...form, qty: +e.target.value })}>{[1, 2, 3, 4].map((n) => <option key={n}>{n}</option>)}</select></label>
            <label className="field">Nombre completo<input value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} placeholder="Ej. Ana Pérez" /></label>
            <div className="row"><span className="sub">Total</span><strong>{cop(t(form.type).price * form.qty)}</strong></div>
            <button className="sbtn">Crear pedido</button>
            <div className="sub">Pagas por transferencia (Bre-B o Nequi) y subes el comprobante. Sin pasarela.</div>
          </form>
        )}
        {role === 'public' && my && (
          <>
            <div className="h">Tu pedido #{my.id}</div>
            <div className="card">
              <div className="row"><span>{my.qty} × {t(my.type).name}</span><span className={`pill ${my.status === 'paid' ? 'ok' : 'warn'}`}>{my.status === 'paid' ? 'Pago validado' : my.proof ? 'Comprobante en revisión' : 'Falta comprobante'}</span></div>
              <strong style={{ fontSize: 20 }}>{cop(my.qty * t(my.type).price)}</strong>
            </div>
            {my.status !== 'paid' && !my.proof && <button className="sbtn" onClick={() => { upd(my.id, { proof: true }); toast('Comprobante enviado') }}>Subir comprobante (de ejemplo)</button>}
            {my.status !== 'paid' && my.proof && <div className="empty">Ve a <b>Staff → Pedidos</b> y valida tu pago para recibir el QR.</div>}
            {my.status === 'paid' && <div className="card" style={{ display: 'grid', placeItems: 'center', gap: 6 }}><Qr code={my.id} /><div className="sub">Código {my.id} · muéstralo en la puerta</div></div>}
            <button className="sbtn ghost" onClick={() => setMine(null)}>Hacer otro pedido</button>
          </>
        )}
        {role === 'staff' && tab === 'pedidos' && (
          <>
            <div className="h">Validar comprobantes</div>
            {orders.map((o) => (
              <div key={o.id} className="card row">
                <div><strong>#{o.id} · {o.name}</strong><div className="sub">{o.qty} × {t(o.type).name} · {cop(o.qty * t(o.type).price)}</div></div>
                {o.status === 'paid' ? <span className="pill ok">Validado</span> : <button className="sbtn sm" onClick={() => { upd(o.id, { status: 'paid' }); toast(`Pedido ${o.id} validado`) }}>Validar</button>}
              </div>
            ))}
          </>
        )}
        {role === 'staff' && tab === 'scan' && (
          <>
            <div className="h">Escáner de puerta</div>
            <div className="sub">Escribe el código del QR (prueba con 1001, 1002 o uno que acabas de crear).</div>
            <form onSubmit={doScan} className="row"><input aria-label="Código" value={scan} onChange={(e) => setScan(e.target.value)} placeholder="Código del pedido" style={{ flex: 1, border: '1px solid #d6d6d0', borderRadius: 8, padding: 8 }} /><button className="sbtn">Escanear</button></form>
            {scanMsg && <div className="card" style={{ background: scanMsg.ok ? '#e1f1e7' : '#fbe4df', fontWeight: 600 }}>{scanMsg.ok ? '✔ ' : '✖ '}{scanMsg.t}</div>}
          </>
        )}
        {role === 'staff' && tab === 'board' && (
          <>
            <div className="h">Tablero en vivo</div>
            <div className="row">
              <div className="card" style={{ flex: 1 }}><div className="sub">Vendidas</div><strong style={{ fontSize: 24 }}>{sold}</strong></div>
              <div className="card" style={{ flex: 1 }}><div className="sub">Ingresaron</div><strong style={{ fontSize: 24 }}>{entered}</strong></div>
            </div>
            <div className="card"><div className="sub">Recaudo</div><strong style={{ fontSize: 24 }}>{cop(money)}</strong>
              <div style={{ background: '#e6e6e1', borderRadius: 99, height: 8, marginTop: 8 }}><div style={{ width: `${sold ? (entered / sold) * 100 : 0}%`, height: 8, borderRadius: 99, background: 'var(--app)' }} /></div>
              <div className="sub" style={{ marginTop: 4 }}>{sold ? Math.round((entered / sold) * 100) : 0}% ya entró</div>
            </div>
          </>
        )}
      </div>
      {toastNode}
      {role === 'staff' && <TabBar tabs={staffTabs} value={tab} onChange={setTab} />}
    </div>
  )
}
