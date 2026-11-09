import { useState } from 'react'

// Formularios y respuestas inventados (mediciones de campo de ejemplo).
const FORMS = {
  ruido: {
    name: 'Medición de ruido',
    fields: [
      { id: 'punto', label: 'Punto de medición', type: 'text', req: true },
      { id: 'db', label: 'Nivel (dB)', type: 'number', req: true },
      { id: 'jornada', label: 'Jornada', type: 'select', opts: ['Diurna', 'Nocturna'], req: true },
    ],
    rows: [
      { punto: 'P-01 Parque central', db: '58', jornada: 'Diurna' },
      { punto: 'P-02 Colegio', db: '63', jornada: 'Diurna' },
      { punto: 'P-03 Esquina vía principal', db: '71', jornada: 'Nocturna' },
    ],
  },
  agua: {
    name: 'Calidad de agua',
    fields: [
      { id: 'fuente', label: 'Fuente', type: 'text', req: true },
      { id: 'ph', label: 'pH', type: 'number', req: true },
      { id: 'turbidez', label: 'Turbidez (NTU)', type: 'number', req: false },
      { id: 'aspecto', label: 'Aspecto', type: 'select', opts: ['Clara', 'Turbia', 'Con espuma'], req: true },
    ],
    rows: [
      { fuente: 'Quebrada La Honda', ph: '7.1', turbidez: '4', aspecto: 'Clara' },
      { fuente: 'Río Bajo', ph: '6.4', turbidez: '19', aspecto: 'Turbia' },
    ],
  },
}

export default function Encuestas() {
  const [forms, setForms] = useState(FORMS)
  const [cur, setCur] = useState('ruido')
  const [tab, setTab] = useState('fill')
  const [vals, setVals] = useState({})
  const [errs, setErrs] = useState({})
  const [msg, setMsg] = useState('')
  const [nf, setNf] = useState({ label: '', type: 'text' })
  const f = forms[cur]

  const change = (id, v) => { setVals({ ...vals, [id]: v }); setErrs({ ...errs, [id]: false }) }
  const submit = (e) => {
    e.preventDefault()
    const bad = {}
    f.fields.forEach((x) => { if (x.req && !String(vals[x.id] ?? '').trim()) bad[x.id] = true })
    setErrs(bad)
    if (Object.keys(bad).length) return setMsg('Faltan campos obligatorios')
    setForms({ ...forms, [cur]: { ...f, rows: [...f.rows, Object.fromEntries(f.fields.map((x) => [x.id, vals[x.id] ?? '']))] } })
    setVals({}); setMsg('Respuesta guardada'); setTab('rows')
  }
  const addField = (e) => {
    e.preventDefault()
    if (!nf.label.trim()) return
    const id = 'c' + Date.now()
    setForms({ ...forms, [cur]: { ...f, fields: [...f.fields, { id, label: nf.label.trim(), type: nf.type, opts: nf.type === 'select' ? ['Sí', 'No'] : undefined, req: false }], rows: f.rows.map((r) => ({ ...r, [id]: '' })) } })
    setNf({ label: '', type: 'text' })
  }
  const removeField = (id) => setForms({ ...forms, [cur]: { ...f, fields: f.fields.filter((x) => x.id !== id) } })
  const exportCsv = () => {
    const head = f.fields.map((x) => `"${x.label}"`).join(',')
    const body = f.rows.map((r) => f.fields.map((x) => `"${String(r[x.id] ?? '').replace(/"/g, '""')}"`).join(',')).join('\n')
    const a = document.createElement('a')
    a.href = URL.createObjectURL(new Blob(['﻿' + head + '\n' + body], { type: 'text/csv;charset=utf-8' }))
    a.download = `${cur}-demo.csv`
    a.click()
    URL.revokeObjectURL(a.href)
  }
  const switchForm = (k) => { setCur(k); setVals({}); setErrs({}); setMsg('') }

  return (
    <div className="app" style={{ '--app': '#b45309' }}>
      <div className="app-top" style={{ background: '#b45309' }}>
        <h3>Encuestas de campo</h3>
        <select aria-label="Formulario" value={cur} onChange={(e) => switchForm(e.target.value)} style={{ borderRadius: 8, padding: '5px 8px', border: 0 }}>{Object.entries(forms).map(([k, v]) => <option key={k} value={k}>{v.name}</option>)}</select>
      </div>
      <div style={{ display: 'flex', gap: 6, padding: '10px 14px 0', flexWrap: 'wrap' }}>
        {[['fill', 'Llenar'], ['rows', `Respuestas (${f.rows.length})`], ['edit', 'Editar formulario']].map(([id, l]) => <button key={id} className={`sbtn sm ${tab === id ? '' : 'ghost'}`} onClick={() => { setTab(id); setMsg('') }}>{l}</button>)}
      </div>
      <div className="app-body">
        {tab === 'fill' && (
          <form onSubmit={submit} noValidate className="card" style={{ display: 'grid', gap: 10, maxWidth: 520 }}>
            {f.fields.map((x) => (
              <label key={x.id} className="field" style={errs[x.id] ? { color: '#b3402e' } : undefined}>
                {x.label}{x.req ? ' *' : ''}
                {x.type === 'select'
                  ? <select value={vals[x.id] ?? ''} onChange={(e) => change(x.id, e.target.value)}><option value="">Elige…</option>{x.opts.map((o) => <option key={o}>{o}</option>)}</select>
                  : <input type={x.type} step="any" value={vals[x.id] ?? ''} onChange={(e) => change(x.id, e.target.value)} aria-invalid={!!errs[x.id]} />}
              </label>
            ))}
            {msg && <div role="status" style={{ fontSize: 13, color: msg.startsWith('Faltan') ? '#b3402e' : '#25623d' }}>{msg}</div>}
            <button className="sbtn">Guardar respuesta</button>
          </form>
        )}
        {tab === 'rows' && (
          <>
            {msg && <div role="status" style={{ fontSize: 13, color: '#25623d' }}>{msg}</div>}
            <div className="card" style={{ padding: 0, overflowX: 'auto' }}>
              <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
                <thead><tr style={{ background: '#f1f2ee', textAlign: 'left' }}>{f.fields.map((x) => <th key={x.id} style={{ padding: 8, whiteSpace: 'nowrap' }}>{x.label}</th>)}</tr></thead>
                <tbody>{f.rows.map((r, i) => <tr key={i} style={{ borderTop: '1px solid #eee' }}>{f.fields.map((x) => <td key={x.id} style={{ padding: 8 }}>{r[x.id] || '—'}</td>)}</tr>)}</tbody>
              </table>
            </div>
            <button className="sbtn" style={{ alignSelf: 'flex-start' }} onClick={exportCsv}>Exportar a Excel (.csv)</button>
          </>
        )}
        {tab === 'edit' && (
          <>
            <div className="h">Campos de «{f.name}»</div>
            {f.fields.map((x) => <div key={x.id} className="card row"><div><strong>{x.label}</strong><div className="sub">{x.type === 'select' ? 'Lista' : x.type === 'number' ? 'Número' : 'Texto'}{x.req ? ' · obligatorio' : ''}</div></div><button className="sbtn ghost sm" onClick={() => removeField(x.id)} aria-label={`Quitar ${x.label}`}>Quitar</button></div>)}
            <form onSubmit={addField} className="card row" style={{ alignItems: 'flex-end' }}>
              <label className="field" style={{ flex: 1 }}>Nuevo campo<input value={nf.label} onChange={(e) => setNf({ ...nf, label: e.target.value })} placeholder="Ej. Temperatura" /></label>
              <label className="field">Tipo<select value={nf.type} onChange={(e) => setNf({ ...nf, type: e.target.value })}><option value="text">Texto</option><option value="number">Número</option><option value="select">Lista (Sí/No)</option></select></label>
              <button className="sbtn">Agregar</button>
            </form>
          </>
        )}
      </div>
    </div>
  )
}
