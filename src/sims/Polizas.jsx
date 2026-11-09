import { useMemo, useState } from 'react'
import { cop } from '../lib/ui.jsx'

// Asegurados, aseguradoras y pólizas son inventados.
const INSURERS = ['Aseguradora Andina', 'Seguros del Páramo', 'Protección Cumbre']
const initial = [
  { id: 'P-1001', client: 'Marcela Quintero', line: 'Autos', insurer: INSURERS[0], premium: 1850000, paid: 1850000, due: '2026-12-02' },
  { id: 'P-1002', client: 'Distribuidora El Roble SAS', line: 'Cumplimiento', insurer: INSURERS[2], premium: 6400000, paid: 3200000, due: '2026-11-20' },
  { id: 'P-1003', client: 'Andrés Cifuentes', line: 'Vida', insurer: INSURERS[1], premium: 980000, paid: 490000, due: '2026-11-15' },
  { id: 'P-1004', client: 'Clínica Santa Aurora', line: 'Responsabilidad civil', insurer: INSURERS[0], premium: 9200000, paid: 9200000, due: '2027-02-10' },
  { id: 'P-1005', client: 'Sofía Ardila', line: 'Hogar', insurer: INSURERS[1], premium: 720000, paid: 0, due: '2026-11-12' },
  { id: 'P-1006', client: 'Transportes Río Alto', line: 'Autos', insurer: INSURERS[2], premium: 14300000, paid: 7150000, due: '2026-12-28' },
]
const DEMO_PDF = { client: 'Julián Mendoza', line: 'Autos', insurer: INSURERS[1], premium: 2140000, due: '2027-01-18' }
const daysTo = (d) => Math.ceil((new Date(d) - new Date('2026-11-09')) / 864e5)

export default function Polizas() {
  const [rows, setRows] = useState(initial)
  const [view, setView] = useState('dash')
  const [q, setQ] = useState('')
  const [line, setLine] = useState('Todos')
  const [sel, setSel] = useState(null)
  const [stage, setStage] = useState('idle')
  const [abono, setAbono] = useState('')

  const total = rows.reduce((s, r) => s + r.premium, 0)
  const cartera = rows.reduce((s, r) => s + (r.premium - r.paid), 0)
  const soon = rows.filter((r) => r.premium > r.paid && daysTo(r.due) <= 30).sort((a, b) => a.due.localeCompare(b.due))
  const lines = ['Todos', ...new Set(rows.map((r) => r.line))]
  const list = useMemo(() => rows.filter((r) => (line === 'Todos' || r.line === line) && (r.client + r.id).toLowerCase().includes(q.toLowerCase())), [rows, q, line])
  const cur = rows.find((r) => r.id === sel)

  const extract = () => {
    setStage('reading')
    setTimeout(() => setStage('done'), 1300)
  }
  const save = () => {
    const id = `P-${1001 + rows.length}`
    setRows((r) => [...r, { id, ...DEMO_PDF, paid: 0 }])
    setStage('idle'); setSel(id); setView('list')
  }
  const pay = (e) => {
    e.preventDefault()
    const v = Math.min(+abono || 0, cur.premium - cur.paid)
    if (v <= 0) return
    setRows((r) => r.map((x) => (x.id === cur.id ? { ...x, paid: x.paid + v } : x)))
    setAbono('')
  }

  const nav = [['dash', 'Resumen'], ['list', 'Pólizas'], ['new', 'Nueva con IA']]
  return (
    <div className="app" style={{ '--app': '#1e5aa8' }}>
      <div className="app-top" style={{ background: '#1e5aa8' }}>
        <h3>Gestor de pólizas</h3>
        <div style={{ display: 'flex', gap: 4 }}>{nav.map(([id, l]) => <button key={id} onClick={() => { setView(id); setSel(null) }} className="sbtn sm" style={{ background: view === id ? '#fff' : 'transparent', color: view === id ? '#1e5aa8' : '#fff', border: '1px solid #ffffff88' }}>{l}</button>)}</div>
      </div>
      <div className="app-body">
        {view === 'dash' && (
          <>
            <div className="row">
              <div className="card" style={{ flex: 1 }}><div className="sub">Pólizas activas</div><strong style={{ fontSize: 24 }}>{rows.length}</strong></div>
              <div className="card" style={{ flex: 1 }}><div className="sub">Prima total</div><strong style={{ fontSize: 24 }}>{cop(total)}</strong></div>
              <div className="card" style={{ flex: 1 }}><div className="sub">Cartera pendiente</div><strong style={{ fontSize: 24, color: '#b3402e' }}>{cop(cartera)}</strong></div>
            </div>
            <div className="h">Vencen en los próximos 30 días con saldo</div>
            {soon.length === 0 && <div className="empty">Nada por vencer.</div>}
            {soon.map((r) => <div key={r.id} className="card row"><div><strong>{r.client}</strong><div className="sub">{r.line} · {r.id}</div></div><div style={{ textAlign: 'right' }}><div>{cop(r.premium - r.paid)}</div><span className={`pill ${daysTo(r.due) <= 7 ? 'warn' : ''}`}>{daysTo(r.due)} días</span></div></div>)}
          </>
        )}
        {view === 'list' && !cur && (
          <>
            <div className="row">
              <input aria-label="Buscar" placeholder="Buscar asegurado o póliza…" value={q} onChange={(e) => setQ(e.target.value)} style={{ flex: 1, border: '1px solid #d6d6d0', borderRadius: 8, padding: 8 }} />
              <select aria-label="Ramo" value={line} onChange={(e) => setLine(e.target.value)} style={{ border: '1px solid #d6d6d0', borderRadius: 8, padding: 8 }}>{lines.map((l) => <option key={l}>{l}</option>)}</select>
            </div>
            {list.length === 0 && <div className="empty">Ninguna póliza coincide.</div>}
            {list.map((r) => <button key={r.id} onClick={() => setSel(r.id)} className="card row" style={{ textAlign: 'left', width: '100%' }}><div><strong>{r.client}</strong><div className="sub">{r.id} · {r.line} · {r.insurer}</div></div><span className={`pill ${r.paid >= r.premium ? 'ok' : 'warn'}`}>{r.paid >= r.premium ? 'Al día' : `Debe ${cop(r.premium - r.paid)}`}</span></button>)}
          </>
        )}
        {view === 'list' && cur && (
          <>
            <button className="sbtn ghost sm" style={{ alignSelf: 'flex-start' }} onClick={() => setSel(null)}>← Volver</button>
            <div className="card">
              <div className="row"><strong>{cur.client}</strong><span className="pill">{cur.id}</span></div>
              <div className="sub">{cur.line} · {cur.insurer} · vence {cur.due}</div>
              <div className="row" style={{ marginTop: 10 }}><div><div className="sub">Prima</div><strong>{cop(cur.premium)}</strong></div><div><div className="sub">Pagado</div><strong>{cop(cur.paid)}</strong></div><div><div className="sub">Saldo</div><strong style={{ color: cur.premium > cur.paid ? '#b3402e' : '#25623d' }}>{cop(cur.premium - cur.paid)}</strong></div></div>
              <div style={{ background: '#e6e6e1', borderRadius: 99, height: 8, marginTop: 10 }}><div style={{ width: `${(cur.paid / cur.premium) * 100}%`, height: 8, borderRadius: 99, background: 'var(--app)' }} /></div>
            </div>
            {cur.premium > cur.paid && (
              <form onSubmit={pay} className="card row" style={{ alignItems: 'flex-end' }}>
                <label className="field" style={{ flex: 1 }}>Registrar abono<input type="number" min="0" value={abono} onChange={(e) => setAbono(e.target.value)} placeholder="Ej. 500000" /></label>
                <button className="sbtn">Abonar</button>
              </form>
            )}
          </>
        )}
        {view === 'new' && (
          <>
            <div className="h">Cargar póliza desde PDF</div>
            <div className="sub">La IA lee el PDF y llena los campos. Aquí se usa un PDF de ejemplo con datos inventados.</div>
            {stage === 'idle' && <button className="sbtn" onClick={extract}>Subir poliza_ejemplo.pdf</button>}
            {stage === 'reading' && <div className="card"><div className="sub">Leyendo el documento…</div><div style={{ background: '#e6e6e1', borderRadius: 99, height: 8, marginTop: 8, overflow: 'hidden' }}><div style={{ width: '100%', height: 8, background: 'var(--app)', animation: 'toastin 1.3s linear' }} /></div></div>}
            {stage === 'done' && (
              <div className="card" style={{ display: 'grid', gap: 6 }}>
                <div className="h">Datos extraídos (revísalos antes de guardar)</div>
                {Object.entries({ Asegurado: DEMO_PDF.client, Ramo: DEMO_PDF.line, Aseguradora: DEMO_PDF.insurer, Prima: cop(DEMO_PDF.premium), Vencimiento: DEMO_PDF.due }).map(([k, v]) => <div key={k} className="row"><span className="sub">{k}</span><strong>{v}</strong></div>)}
                <button className="sbtn" onClick={save}>Guardar póliza</button>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  )
}
