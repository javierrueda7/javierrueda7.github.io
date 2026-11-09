import { useState } from 'react'

// Proyecto "Vía Ficticia Km 12". Documento y hallazgos inventados para la demo.
const PARAS = [
  { id: 1, t: 'El proyecto contempla el mejoramiento de 12 km de vía existente, con ampliación de calzada a 7,3 m y construcción de cuatro alcantarillas de cajón.' },
  { id: 2, t: 'Se estima un uso de agua de 18 m³/día para humectación de vías durante la fase constructiva, captada de una quebrada cercana.' },
  { id: 3, t: 'La línea base de fauna se levantó en una sola jornada de campo de dos días, en temporada seca.' },
  { id: 4, t: 'El plan de manejo de residuos de construcción prevé la disposición en sitios autorizados dentro del área de influencia.' },
  { id: 5, t: 'Las comunidades del área de influencia directa fueron informadas mediante una reunión de socialización.' },
]
const FINDINGS = [
  { id: 'a', p: 3, sev: 'Alta', cat: 'Línea base', msg: 'Una sola jornada en temporada seca no representa la variación estacional de fauna. Se esperan al menos dos temporadas.', fix: 'Agregar muestreo en temporada de lluvias o justificar técnicamente.' },
  { id: 'b', p: 2, sev: 'Alta', cat: 'Recurso hídrico', msg: 'Se declara captación sin citar la solicitud de concesión de aguas ni el caudal ecológico de la quebrada.', fix: 'Incluir trámite de concesión y cálculo de caudal ecológico.' },
  { id: 'c', p: 5, sev: 'Media', cat: 'Participación', msg: 'Una sola reunión es insuficiente para soportar la participación de las comunidades del área de influencia.', fix: 'Anexar actas, listados de asistencia y evidencia de convocatoria.' },
  { id: 'd', p: 4, sev: 'Baja', cat: 'Residuos', msg: 'No se cuantifican volúmenes de material sobrante ni se nombran los sitios de disposición.', fix: 'Tabla de volúmenes estimados y sitios autorizados.' },
]
const SEV = { Alta: '#b3402e', Media: '#a8641a', Baja: '#4b6b8f' }

export default function Ambiental() {
  const [stage, setStage] = useState('idle')
  const [prog, setProg] = useState(0)
  const [filter, setFilter] = useState('Todas')
  const [focus, setFocus] = useState(null)
  const [done, setDone] = useState([])

  const run = () => {
    setStage('run'); setProg(0)
    let p = 0
    const id = setInterval(() => { p += 12; setProg(Math.min(p, 100)); if (p >= 100) { clearInterval(id); setStage('done') } }, 160)
  }
  const shown = FINDINGS.filter((f) => filter === 'Todas' || f.sev === filter)
  const download = () => {
    const txt = ['Informe de revisión (demo)', 'Proyecto: Vía Ficticia Km 12', '', ...FINDINGS.map((f) => `[${f.sev}] ${f.cat}: ${f.msg}\n  Sugerencia: ${f.fix}`)].join('\n')
    const a = document.createElement('a')
    a.href = URL.createObjectURL(new Blob([txt], { type: 'text/plain' }))
    a.download = 'informe-demo.txt'
    a.click()
    URL.revokeObjectURL(a.href)
  }

  return (
    <div className="app" style={{ '--app': '#0f766e' }}>
      <div className="app-top" style={{ background: '#0f766e' }}><div><h3>Revisor de estudios ambientales</h3><small>Vía Ficticia Km 12 · EIA de ejemplo</small></div>
        {stage === 'idle' && <button className="sbtn sm" style={{ background: '#fff', color: '#0f766e' }} onClick={run}>Analizar con IA</button>}
      </div>
      <div className="app-body" style={{ display: 'grid', gridTemplateColumns: 'minmax(0, 1fr) minmax(0, 1fr)', alignItems: 'start' }}>
        <div className="card" style={{ display: 'grid', gap: 8 }}>
          <div className="h">Documento</div>
          {PARAS.map((p) => {
            const f = stage === 'done' && FINDINGS.find((x) => x.p === p.id)
            const on = focus === p.id
            return <p key={p.id} style={{ fontSize: 13, padding: 8, borderRadius: 6, background: on ? '#fff3c4' : f ? '#fdf0ee' : 'transparent', borderLeft: f ? `3px solid ${SEV[f.sev]}` : '3px solid transparent' }}>{p.t}</p>
          })}
        </div>
        <div style={{ display: 'grid', gap: 8 }}>
          {stage === 'idle' && <div className="empty">Pulsa «Analizar con IA» para que el revisor lea el estudio y marque hallazgos.</div>}
          {stage === 'run' && <div className="card"><div className="sub">Leyendo y contrastando con la normativa… {prog}%</div><div style={{ background: '#e6e6e1', borderRadius: 99, height: 8, marginTop: 8 }}><div style={{ width: `${prog}%`, height: 8, borderRadius: 99, background: 'var(--app)', transition: 'width .15s' }} /></div></div>}
          {stage === 'done' && (
            <>
              <div className="row"><div className="h">{shown.length} hallazgos</div>
                <div style={{ display: 'flex', gap: 4 }}>{['Todas', 'Alta', 'Media', 'Baja'].map((s) => <button key={s} className={`sbtn sm ${filter === s ? '' : 'ghost'}`} onClick={() => setFilter(s)}>{s}</button>)}</div>
              </div>
              {shown.map((f) => (
                <div key={f.id} className="card" style={{ outline: focus === f.p ? '2px solid var(--app)' : 'none', opacity: done.includes(f.id) ? 0.55 : 1 }}>
                  <div className="row"><span className="pill" style={{ background: SEV[f.sev] + '22', color: SEV[f.sev] }}>{f.sev}</span><span className="sub">{f.cat}</span></div>
                  <div style={{ margin: '6px 0', fontSize: 13 }}>{f.msg}</div>
                  <div className="sub"><b>Sugerencia:</b> {f.fix}</div>
                  <div className="row" style={{ justifyContent: 'flex-start', marginTop: 8 }}>
                    <button className="sbtn ghost sm" onClick={() => setFocus(focus === f.p ? null : f.p)}>Ver en el texto</button>
                    <button className="sbtn sm" onClick={() => setDone((d) => (d.includes(f.id) ? d.filter((x) => x !== f.id) : [...d, f.id]))}>{done.includes(f.id) ? 'Reabrir' : 'Marcar resuelto'}</button>
                  </div>
                </div>
              ))}
              <button className="sbtn" onClick={download}>Descargar informe (.txt)</button>
              <div className="sub">{done.length} de {FINDINGS.length} resueltos. La app real exporta a PDF, Word y Excel.</div>
            </>
          )}
        </div>
      </div>
    </div>
  )
}
