import { useState } from 'react'
import { cop } from '../lib/ui.jsx'

// Proyecto "Lotes del Valle", compradores y precios inventados.
const COLS = 6
const ROWS = 4
const initial = Array.from({ length: COLS * ROWS }, (_, i) => ({
  id: i + 1,
  area: 180 + ((i * 37) % 9) * 15,
  state: [3, 7, 8, 14, 15, 21].includes(i + 1) ? 'vendido' : [5, 12, 18].includes(i + 1) ? 'separado' : 'disponible',
  buyer: null,
}))
const M2 = 380000
const COLOR = { disponible: '#2f9e5b', separado: '#e0a030', vendido: '#9aa0a6' }

export default function Lotes() {
  const [lots, setLots] = useState(initial)
  const [sel, setSel] = useState(1)
  const [pct, setPct] = useState(30)
  const [months, setMonths] = useState(36)
  const [name, setName] = useState('')
  const [receipt, setReceipt] = useState(null)
  const lot = lots.find((l) => l.id === sel)
  const price = lot.area * M2
  const down = price * pct / 100
  const fee = (price - down) / months
  const count = (s) => lots.filter((l) => l.state === s).length

  const reserve = (e) => {
    e.preventDefault()
    if (!name.trim() || lot.state !== 'disponible') return
    setLots((l) => l.map((x) => (x.id === lot.id ? { ...x, state: 'separado', buyer: name.trim() } : x)))
    setReceipt({ lot: lot.id, name: name.trim(), amount: down * 0.1 })
    setName('')
  }
  const free = () => { setLots((l) => l.map((x) => (x.id === lot.id ? { ...x, state: 'disponible', buyer: null } : x))); setReceipt(null) }

  return (
    <div className="app" style={{ '--app': '#2f7d4f' }}>
      <div className="app-top" style={{ background: '#2f7d4f' }}><h3>Lotes del Valle</h3><small>proyecto de ejemplo · {count('disponible')} disponibles · {count('separado')} separados · {count('vendido')} vendidos</small></div>
      <div className="app-body twocol" style={{ display: 'grid', gridTemplateColumns: 'minmax(0, 1.1fr) minmax(0, 1fr)', alignItems: 'start' }}>
        <div className="card">
          <div className="h" style={{ marginBottom: 8 }}>Plano de lotes</div>
          <div style={{ display: 'grid', gridTemplateColumns: `repeat(${COLS}, 1fr)`, gap: 6 }}>
            {lots.map((l) => (
              <button key={l.id} onClick={() => { setSel(l.id); setReceipt(null) }} aria-label={`Lote ${l.id}, ${l.state}`} aria-pressed={sel === l.id}
                style={{ aspectRatio: '1', border: sel === l.id ? '3px solid #1a1a1a' : '1px solid #0002', borderRadius: 6, background: COLOR[l.state], color: '#fff', fontWeight: 700, fontSize: 13 }}>{l.id}</button>
            ))}
          </div>
          <div className="row" style={{ justifyContent: 'flex-start', marginTop: 10, flexWrap: 'wrap' }}>{Object.entries(COLOR).map(([k, c]) => <span key={k} className="sub"><span style={{ display: 'inline-block', width: 10, height: 10, borderRadius: 3, background: c, marginRight: 4 }} />{k}</span>)}</div>
        </div>
        <div style={{ display: 'grid', gap: 10 }}>
          <div className="card">
            <div className="row"><strong>Lote {lot.id}</strong><span className={`pill ${lot.state === 'disponible' ? 'ok' : 'warn'}`}>{lot.state}</span></div>
            <div className="sub">{lot.area} m² · {cop(M2)}/m²</div>
            <strong style={{ fontSize: 22 }}>{cop(price)}</strong>
          </div>
          <div className="card" style={{ display: 'grid', gap: 8 }}>
            <div className="h">Cotizador</div>
            <label className="field">Cuota inicial: {pct}%<input type="range" min="10" max="50" step="5" value={pct} onChange={(e) => setPct(+e.target.value)} /></label>
            <label className="field">Plazo: {months} meses<input type="range" min="12" max="72" step="12" value={months} onChange={(e) => setMonths(+e.target.value)} /></label>
            <div className="row"><span className="sub">Cuota inicial</span><strong>{cop(down)}</strong></div>
            <div className="row"><span className="sub">Cuota mensual</span><strong>{cop(fee)}</strong></div>
          </div>
          {lot.state === 'disponible' && (
            <form onSubmit={reserve} className="card" style={{ display: 'grid', gap: 8 }}>
              <label className="field">Nombre del comprador<input value={name} onChange={(e) => setName(e.target.value)} placeholder="Ej. Carolina Vega" /></label>
              <button className="sbtn">Separar lote ({cop(down * 0.1)})</button>
            </form>
          )}
          {lot.state === 'separado' && lot.buyer && <div className="card"><div className="sub">Separado por <b>{lot.buyer}</b></div><button className="sbtn ghost sm" style={{ marginTop: 6 }} onClick={free}>Liberar lote</button></div>}
          {receipt && receipt.lot === lot.id && (
            <div className="card" style={{ borderStyle: 'dashed' }}>
              <div className="h">Recibo de separación (ejemplo)</div>
              <div className="sub">Lote {receipt.lot} · {receipt.name}</div>
              <strong>{cop(receipt.amount)}</strong>
              <div className="sub">En la app real se genera el PDF.</div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
