import { useState } from 'react'
import { cop } from '../lib/ui.jsx'

// Empresas, usuarios y cifras inventados.
const COMPANIES = ['Tienda La Esquina', 'Constructora Delta', 'Café Montaña']
const MODELS = [
  { id: 'ventas', name: 'Ventas por mes', kind: 'bar' },
  { id: 'margen', name: 'Margen por categoría', kind: 'bar2' },
  { id: 'tendencia', name: 'Tendencia semanal', kind: 'line' },
]
const DATA = {
  ventas: { 'Tienda La Esquina': [42, 51, 47, 60, 66, 72], 'Constructora Delta': [210, 180, 260, 240, 300, 280], 'Café Montaña': [18, 22, 25, 24, 31, 35] },
  margen: { 'Tienda La Esquina': [['Abarrotes', 18], ['Aseo', 31], ['Bebidas', 24], ['Snacks', 38]], 'Constructora Delta': [['Obra civil', 14], ['Acabados', 22], ['Diseño', 41]], 'Café Montaña': [['Café', 62], ['Panadería', 44], ['Merch', 55]] },
  tendencia: { 'Tienda La Esquina': [30, 34, 33, 40, 44, 41, 52], 'Constructora Delta': [80, 70, 90, 85, 100, 95, 110], 'Café Montaña': [12, 15, 14, 19, 22, 21, 27] },
}
const MONTHS = ['Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov']

function Chart({ kind, values, labels }) {
  const W = 420, H = 190, pad = 28
  const max = Math.max(...values.map((v) => (Array.isArray(v) ? v[1] : v))) * 1.15
  if (kind === 'line') {
    const pts = values.map((v, i) => `${pad + (i * (W - pad * 2)) / (values.length - 1)},${H - pad - (v / max) * (H - pad * 2)}`)
    return <svg viewBox={`0 0 ${W} ${H}`} width="100%" role="img" aria-label="Gráfico de línea"><polyline points={pts.join(' ')} fill="none" stroke="#7c3aed" strokeWidth="3" />{pts.map((p, i) => <circle key={i} cx={p.split(',')[0]} cy={p.split(',')[1]} r="4" fill="#7c3aed" />)}</svg>
  }
  const n = values.length
  const bw = (W - pad * 2) / n
  return (
    <svg viewBox={`0 0 ${W} ${H}`} width="100%" role="img" aria-label="Gráfico de barras">
      {values.map((v, i) => {
        const val = Array.isArray(v) ? v[1] : v
        const h = (val / max) * (H - pad * 2)
        return <g key={i}><rect x={pad + i * bw + 6} y={H - pad - h} width={bw - 12} height={h} rx="4" fill="#7c3aed" /><text x={pad + i * bw + bw / 2} y={H - 10} textAnchor="middle" fontSize="11" fill="#666">{labels?.[i] ?? v[0]}</text><text x={pad + i * bw + bw / 2} y={H - pad - h - 5} textAnchor="middle" fontSize="11" fill="#333">{val}</text></g>
      })}
    </svg>
  )
}

export default function Analitica() {
  const [role, setRole] = useState('user')
  const [company, setCompany] = useState(COMPANIES[0])
  const [assigned, setAssigned] = useState({ 'Tienda La Esquina': ['ventas', 'tendencia'], 'Constructora Delta': ['ventas'], 'Café Montaña': ['margen'] })
  const [open, setOpen] = useState(null)
  const mine = MODELS.filter((m) => assigned[company].includes(m.id))
  const m = MODELS.find((x) => x.id === open)
  const toggle = (c, id) => setAssigned((a) => ({ ...a, [c]: a[c].includes(id) ? a[c].filter((x) => x !== id) : [...a[c], id] }))

  return (
    <div className="app" style={{ '--app': '#6d28d9' }}>
      <div className="app-top" style={{ background: '#6d28d9' }}>
        <h3>Portal de analítica</h3>
        <div style={{ display: 'flex', gap: 4 }}>{[['user', 'Cliente'], ['admin', 'Administrador']].map(([id, l]) => <button key={id} onClick={() => { setRole(id); setOpen(null) }} className="sbtn sm" style={{ background: role === id ? '#fff' : 'transparent', color: role === id ? '#6d28d9' : '#fff', border: '1px solid #ffffff88' }}>{l}</button>)}</div>
      </div>
      <div className="app-body">
        {role === 'user' && !m && (
          <>
            <label className="field" style={{ maxWidth: 260 }}>Ingresar como<select value={company} onChange={(e) => setCompany(e.target.value)}>{COMPANIES.map((c) => <option key={c}>{c}</option>)}</select></label>
            <div className="h">Mis modelos ({mine.length})</div>
            {mine.length === 0 && <div className="empty">Aún no tienes modelos asignados. Pídelos al administrador.</div>}
            {mine.map((x) => <button key={x.id} onClick={() => setOpen(x.id)} className="card row" style={{ textAlign: 'left', width: '100%' }}><strong>{x.name}</strong><span className="pill">Abrir</span></button>)}
          </>
        )}
        {role === 'user' && m && (
          <>
            <button className="sbtn ghost sm" style={{ alignSelf: 'flex-start' }} onClick={() => setOpen(null)}>← Mis modelos</button>
            <div className="card">
              <div className="row"><strong>{m.name}</strong><span className="pill">{company}</span></div>
              <Chart kind={m.kind === 'bar2' ? 'bar' : m.kind} values={DATA[m.id][company]} labels={m.id === 'ventas' ? MONTHS : m.id === 'tendencia' ? ['L', 'M', 'X', 'J', 'V', 'S', 'D'] : undefined} />
              {m.id === 'ventas' && <div className="sub">Ventas en millones de pesos · {cop(DATA.ventas[company].reduce((a, b) => a + b, 0) * 1e6)} en el semestre (cifras de ejemplo)</div>}
            </div>
          </>
        )}
        {role === 'admin' && (
          <>
            <div className="h">Asignar modelos a cada cliente</div>
            <div className="sub">Marca o desmarca y cambia a la vista Cliente para ver el efecto.</div>
            {COMPANIES.map((c) => (
              <div key={c} className="card">
                <strong>{c}</strong>
                <div style={{ display: 'flex', gap: 12, flexWrap: 'wrap', marginTop: 6 }}>
                  {MODELS.map((x) => <label key={x.id} style={{ display: 'flex', gap: 6, alignItems: 'center', fontSize: 13 }}><input type="checkbox" checked={assigned[c].includes(x.id)} onChange={() => toggle(c, x.id)} />{x.name}</label>)}
                </div>
              </div>
            ))}
          </>
        )}
      </div>
    </div>
  )
}
