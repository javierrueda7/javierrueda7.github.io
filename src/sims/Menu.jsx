import { useState } from 'react'
import { cop } from '../lib/ui.jsx'

const THEMES = {
  costeno: { label: 'Costeño', name: 'Sazón Costeña', bg: '#fff6e5', ink: '#4a2b0b', accent: '#e8590c', font: 'Sora' },
  elegante: { label: 'Elegante', name: 'Maison Roble', bg: '#16130f', ink: '#efe6d3', accent: '#c9a45c', font: 'Sora' },
  bar: { label: 'Bar', name: 'La Esquina Bar', bg: '#0f1a24', ink: '#e4eef7', accent: '#37b6c9', font: 'IBM Plex Mono' },
}
const MENU = {
  costeno: [
    ['Platos', [['Arepa de huevo', 9000], ['Mojarra frita', 32000], ['Arroz de coco con pescado', 28000]]],
    ['Bebidas', [['Limonada de coco', 9500], ['Jugo de lulo', 7000]]],
  ],
  elegante: [
    ['Entradas', [['Carpaccio de res', 36000], ['Crema de zapallo', 22000]]],
    ['Fuertes', [['Lomo al vino tinto', 68000], ['Risotto de hongos', 54000]]],
  ],
  bar: [
    ['Para picar', [['Nachos', 24000], ['Alitas BBQ', 28000]]],
    ['Tragos', [['Mojito', 22000], ['Cerveza artesanal', 16000]]],
  ],
}
const STAGES = ['Nuevo', 'Preparando', 'Listo']

export default function Menu() {
  const [th, setTh] = useState('costeno')
  const [mode, setMode] = useState('Mesa')
  const [cart, setCart] = useState({})
  const [orders, setOrders] = useState([{ id: 1, table: 'Mesa 3', lines: ['2 × Limonada de coco', '1 × Arepa de huevo'], stage: 0 }])
  const [id, setId] = useState(2)
  const [pin, setPin] = useState('')
  const [unlocked, setUnlocked] = useState(false)
  const T = THEMES[th]
  const items = Object.entries(cart).filter(([, q]) => q > 0)
  const total = items.reduce((s, [n, q]) => s + q * MENU[th].flatMap(([, l]) => l).find(([x]) => x === n)[1], 0)
  const add = (n, d) => setCart((c) => ({ ...c, [n]: Math.max(0, (c[n] || 0) + d) }))
  const send = () => {
    if (!items.length) return
    setOrders((o) => [...o, { id, table: mode === 'Mesa' ? `Mesa ${1 + (id % 6)}` : mode, lines: items.map(([n, q]) => `${q} × ${n}`), stage: 0 }])
    setId(id + 1); setCart({})
  }
  const changeTheme = (k) => { setTh(k); setCart({}) }

  return (
    <div className="menu-split">
      <div className="menu-cust" style={{ background: T.bg, color: T.ink, '--mc': T.accent }}>
        <div className="menu-head">
          <strong style={{ fontFamily: T.font, fontSize: 18 }}>{T.name}</strong>
          <div style={{ display: 'flex', gap: 4 }}>{Object.entries(THEMES).map(([k, v]) => <button key={k} onClick={() => changeTheme(k)} aria-pressed={th === k} className="mchip" style={{ background: th === k ? T.accent : 'transparent', color: th === k ? '#fff' : T.ink, borderColor: T.accent }}>{v.label}</button>)}</div>
        </div>
        <div style={{ display: 'flex', gap: 6, padding: '0 14px' }}>{['Mesa', 'Para llevar', 'Domicilio'].map((m) => <button key={m} onClick={() => setMode(m)} className="mchip" style={{ background: mode === m ? T.accent : 'transparent', color: mode === m ? '#fff' : T.ink, borderColor: T.accent }}>{m}</button>)}</div>
        <div className="menu-list">
          {MENU[th].map(([cat, list]) => (
            <div key={cat}>
              <div style={{ fontFamily: T.font, fontWeight: 700, margin: '10px 0 6px', color: T.accent }}>{cat}</div>
              {list.map(([n, p]) => (
                <div key={n} className="row" style={{ padding: '7px 0', borderBottom: `1px solid ${T.accent}33` }}>
                  <div><div>{n}</div><div style={{ opacity: 0.7, fontSize: 12 }}>{cop(p)}</div></div>
                  <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
                    {cart[n] > 0 && <><button className="mchip" aria-label={`Quitar ${n}`} onClick={() => add(n, -1)} style={{ borderColor: T.accent, color: T.ink }}>−</button><span>{cart[n]}</span></>}
                    <button className="mchip" aria-label={`Agregar ${n}`} onClick={() => add(n, 1)} style={{ background: T.accent, color: '#fff', borderColor: T.accent }}>+</button>
                  </div>
                </div>
              ))}
            </div>
          ))}
        </div>
        <div className="menu-foot" style={{ borderTop: `1px solid ${T.accent}55` }}>
          <div className="row"><span>{items.length ? `${items.reduce((s, [, q]) => s + q, 0)} productos` : 'Carrito vacío'}</span><strong>{cop(total)}</strong></div>
          <button disabled={!items.length} onClick={send} className="mchip" style={{ width: '100%', padding: 10, marginTop: 6, background: T.accent, color: '#fff', borderColor: T.accent, opacity: items.length ? 1 : 0.5 }}>Enviar pedido a cocina</button>
        </div>
      </div>

      <div className="menu-kitchen">
        <div className="app-top"><div><h3>Cocina</h3><small>PIN de la demo: 1234</small></div></div>
        {!unlocked ? (
          <form className="app-body" style={{ justifyContent: 'center', alignItems: 'center' }} onSubmit={(e) => { e.preventDefault(); if (pin === '1234') setUnlocked(true); else setPin('') }}>
            <label className="field">PIN de cocina<input inputMode="numeric" maxLength={4} value={pin} onChange={(e) => setPin(e.target.value)} autoComplete="off" /></label>
            <button className="sbtn">Entrar</button>
          </form>
        ) : (
          <div className="app-body" style={{ display: 'grid', gridTemplateColumns: 'minmax(0, 1fr)', alignContent: 'start' }}>
            {STAGES.map((s, si) => (
              <div key={s} style={{ display: 'grid', gap: 8 }}>
                <div className="h">{s} ({orders.filter((o) => o.stage === si).length})</div>
                {orders.filter((o) => o.stage === si).map((o) => (
                  <div key={o.id} className="card">
                    <strong>{o.table}</strong>
                    {o.lines.map((l) => <div key={l} className="sub">{l}</div>)}
                    {si < 2 ? <button className="sbtn sm" style={{ marginTop: 6 }} onClick={() => setOrders((l) => l.map((x) => x.id === o.id ? { ...x, stage: si + 1 } : x))}>{si === 0 ? 'Preparar' : 'Marcar listo'}</button> : <button className="sbtn ghost sm" style={{ marginTop: 6 }} onClick={() => setOrders((l) => l.filter((x) => x.id !== o.id))}>Entregado</button>}
                  </div>
                ))}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}
