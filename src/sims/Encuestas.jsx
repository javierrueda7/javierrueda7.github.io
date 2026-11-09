import { useRef, useState } from 'react'
import { LI } from '../lib/lineicons.jsx'
import './encuestas.css'

// Formularios, personas y mediciones de ejemplo (inventados). Las encuestas las arma un administrador.
const TODAY = '2026-11-09'
const fd = (d) => (d ? d.split('-').reverse().join('/') : '—')
const TYPES = { text: 'Texto', number: 'Número', select: 'Selección', date: 'Fecha', bool: 'Sí / No' }
const nid = () => Math.random().toString(36).slice(2, 8)

const SEED = [
  {
    id: 's1', code: 'ENC-001', name: 'Medición de ruido ambiental', start: '2026-11-01', end: '2026-11-30', closed: false,
    fields: [
      { id: 'punto', label: 'Punto de medición', type: 'text', req: true },
      { id: 'db', label: 'Nivel de ruido (dB)', type: 'number', req: true, min: 20, max: 140 },
      { id: 'jornada', label: 'Jornada', type: 'select', opts: ['Diurna', 'Nocturna'], req: true },
      { id: 'obs', label: 'Observaciones', type: 'text', req: false },
    ],
    rows: [
      { id: 'r1', who: 'Camilo Restrepo', date: '2026-11-03', state: 'Enviada', vals: { punto: 'P-01 Parque central', db: '58', jornada: 'Diurna', obs: '' } },
      { id: 'r2', who: 'Marta Ibarra', date: '2026-11-04', state: 'Enviada', vals: { punto: 'P-02 Colegio', db: '63', jornada: 'Diurna', obs: 'Hora de salida de estudiantes' } },
      { id: 'r3', who: 'Camilo Restrepo', date: '2026-11-05', state: 'Enviada', vals: { punto: 'P-03 Esquina vía principal', db: '71', jornada: 'Nocturna', obs: '' } },
    ],
  },
  {
    id: 's2', code: 'ENC-002', name: 'Calidad de agua en quebradas', start: '2026-11-01', end: '2026-12-15', closed: false,
    fields: [
      { id: 'fuente', label: 'Fuente', type: 'text', req: true },
      { id: 'ph', label: 'pH', type: 'number', req: true, min: 0, max: 14 },
      { id: 'turb', label: 'Turbidez (NTU)', type: 'number', req: false, min: 0, max: 1000 },
      { id: 'aspecto', label: 'Aspecto', type: 'select', opts: ['Clara', 'Turbia', 'Con espuma'], req: true },
      { id: 'olor', label: '¿Presenta olor?', type: 'bool', req: false },
    ],
    rows: [
      { id: 'r4', who: 'Marta Ibarra', date: '2026-11-02', state: 'Enviada', vals: { fuente: 'Quebrada La Honda', ph: '7.1', turb: '4', aspecto: 'Clara', olor: 'No' } },
      { id: 'r5', who: 'Camilo Restrepo', date: '2026-11-06', state: 'Enviada', vals: { fuente: 'Río Bajo', ph: '6.4', turb: '19', aspecto: 'Turbia', olor: 'Sí' } },
    ],
  },
  {
    id: 's3', code: 'ENC-003', name: 'Registro de horas · octubre', start: '2026-10-01', end: '2026-10-31', closed: true,
    fields: [
      { id: 'proy', label: 'Proyecto', type: 'select', cat: 'proyectos', req: true },
      { id: 'act', label: 'Actividad', type: 'select', cat: 'actividades', req: true },
      { id: 'horas', label: 'Horas', type: 'number', req: true, min: 0, max: 200 },
    ],
    rows: [
      { id: 'r6', who: 'Laura Gómez', date: '2026-10-30', state: 'Enviada', vals: { proy: 'Línea base de fauna', act: 'Trabajo de campo', horas: '46' } },
      { id: 'r7', who: 'Camilo Restrepo', date: '2026-10-31', state: 'Enviada', vals: { proy: 'Monitoreo de ruido', act: 'Informe', horas: '32' } },
    ],
  },
]
const CAT0 = { proyectos: ['Línea base de fauna', 'Monitoreo de ruido', 'Plan de manejo hídrico'], actividades: ['Trabajo de campo', 'Informe', 'Reunión con la comunidad', 'Análisis de laboratorio'] }

const optsOf = (f, cat) => (f.cat ? cat[f.cat] : f.opts || [])
const EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

function validate(f, v, cat) {
  const s = String(v ?? '').trim()
  if (!s) return f.req ? 'Este campo es obligatorio' : ''
  if (f.type === 'number') {
    if (!/^-?\d+([.,]\d+)?$/.test(s)) return 'Ingresa un número válido'
    const n = parseFloat(s.replace(',', '.'))
    if (f.min != null && n < f.min) return `Debe ser mayor o igual a ${f.min}`
    if (f.max != null && n > f.max) return `Debe ser menor o igual a ${f.max}`
  }
  if (f.type === 'select' && !optsOf(f, cat).includes(s)) return 'Elige una opción de la lista'
  return ''
}
const csvCell = (x) => '"' + String(x ?? '').replace(/"/g, '""') + '"'

export default function Encuestas() {
  const [logged, setLogged] = useState(true)
  const [surveys, setSurveys] = useState(SEED)
  const [cat, setCat] = useState(CAT0)
  const [stack, setStack] = useState([{ s: 'menu' }])
  const [toast, setToast] = useState('')
  const [dlg, setDlg] = useState(null)
  const tt = useRef()
  const say = (m) => { setToast(m); clearTimeout(tt.current); tt.current = setTimeout(() => setToast(''), 2400) }
  const cur = stack[stack.length - 1]
  const push = (s, p) => setStack((st) => [...st, { s, ...p }])
  const pop = () => setStack((st) => (st.length > 1 ? st.slice(0, -1) : st))
  const home = () => setStack([{ s: 'menu' }])
  const upd = (id, fn) => setSurveys((l) => l.map((x) => (x.id === id ? fn(x) : x)))
  const ctx = { surveys, setSurveys, upd, cat, setCat, push, pop, say, setDlg }

  if (!logged) return <Login onEnter={() => { setLogged(true); home() }} />

  const sv = surveys.find((x) => x.id === cur.id)
  const TITLES = { menu: 'Encuestas de campo', mias: 'Tus encuestas', admin: 'Administrar encuestas', consultas: 'Consultas', cat: cur.k === 'actividades' ? 'Actividades' : 'Proyectos' }
  const sub = (cur.s === 'form' || cur.s === 'resp' || cur.s === 'campos') && sv ? `${sv.code} · del ${fd(sv.start)} al ${fd(sv.end)}` : ''
  const title = TITLES[cur.s] || (sv ? sv.name : '')
  const big = !!sub

  return (
    <div className="en">
      <header className={'en-bar' + (big ? ' big' : '')}>
        {cur.s !== 'menu' && <button className="en-bbtn" aria-label="Atrás" onClick={pop}><LI n="left" size={22} /></button>}
        {cur.s === 'menu' && <LI n="assign" size={22} />}
        <div className="en-bt"><b>{cur.s === 'campos' ? 'Editar campos' : cur.s === 'resp' ? 'Respuestas' : title}</b>{sub && <small>{cur.s === 'campos' || cur.s === 'resp' ? sv.name + ' · ' + sub.split(' · ')[1] : sub}</small>}</div>
        {cur.s === 'menu' && <span className="en-role">Administrador</span>}
        <button className="en-out" onClick={() => setLogged(false)}><LI n="logout" size={18} /> <span>Salir</span></button>
      </header>
      <div className="en-body"><div className="en-page">
        {cur.s === 'menu' && <Menu {...ctx} />}
        {cur.s === 'mias' && <Mias {...ctx} />}
        {cur.s === 'form' && sv && <Form {...ctx} sv={sv} />}
        {cur.s === 'admin' && <Admin {...ctx} />}
        {cur.s === 'campos' && sv && <Campos {...ctx} sv={sv} />}
        {cur.s === 'resp' && sv && <Resp {...ctx} sv={sv} />}
        {cur.s === 'consultas' && <Consultas {...ctx} />}
        {cur.s === 'cat' && <Catalogo {...ctx} k={cur.k} />}
        {['form', 'campos', 'resp'].includes(cur.s) && !sv && <div className="en-empty">Esta encuesta ya no existe.</div>}
      </div></div>
      {toast && <div className="en-snack" role="status">{toast}</div>}
      {dlg && (
        <div className="en-scrim" onClick={() => setDlg(null)}>
          <div className="en-dlg" role="dialog" aria-label={dlg.title} onClick={(e) => e.stopPropagation()}>
            <h3>{dlg.title}</h3>
            {dlg.body && <p>{dlg.body}</p>}
            {dlg.node && dlg.node(setDlg)}
            {!dlg.node && (
              <div className="en-dact"><button className="en-tbtn" onClick={() => setDlg(null)}>{dlg.cancel || 'Cancelar'}</button>{dlg.onOk && <button className="en-btn" onClick={() => { dlg.onOk(); setDlg(null) }}>{dlg.ok || 'Confirmar'}</button>}</div>
            )}
          </div>
        </div>
      )}
    </div>
  )
}

function Login({ onEnter }) {
  const [em, setEm] = useState('laura.gomez@campo.test')
  const [pw, setPw] = useState('demo1234')
  const [err, setErr] = useState('')
  const [show, setShow] = useState(false)
  const [help, setHelp] = useState(false)
  const submit = (e) => {
    e.preventDefault()
    if (!EMAIL.test(em.trim())) return setErr('Escribe un correo válido.')
    if (pw.length < 6) return setErr('La contraseña debe tener al menos 6 caracteres.')
    setErr(''); onEnter()
  }
  return (
    <div className="en en-loginbg">
      <div className="en-lcol">
        <svg viewBox="0 0 80 64" width="70" height="56" aria-hidden="true"><path d="M40 4l30 50H10z" fill="#2D5B89" /><path d="M40 4l30 50H40z" fill="#143D66" /><circle cx="26" cy="30" r="7" fill="#DCC28A" /><path d="M8 58h64" stroke="#0F2F4F" strokeWidth="3" /></svg>
        <h1>Encuestas de campo</h1>
        <p>Registro de mediciones y horas por proyecto</p>
        <form className="en-card" onSubmit={submit} noValidate>
          <b>Iniciar sesión</b>
          <label className="en-fld"><span>Correo electrónico</span><input value={em} onChange={(e) => setEm(e.target.value)} placeholder="nombre@empresa.com" /></label>
          <label className="en-fld"><span>Contraseña</span><input type={show ? 'text' : 'password'} value={pw} onChange={(e) => setPw(e.target.value)} /><button type="button" className="en-eye" aria-label="Mostrar contraseña" onClick={() => setShow(!show)}><LI n="eye" size={18} /></button></label>
          <button type="button" className="en-tbtn right" onClick={() => setHelp(true)}>¿Olvidaste tu contraseña?</button>
          {err && <div className="en-err"><LI n="alert" size={16} /> {err}</div>}
          <button className="en-btn full" type="submit">Entrar</button>
        </form>
        <button className="en-obtn" type="button" onClick={() => setErr('En esta demo la cuenta ya existe: pulsa «Entrar».')}>Crear una cuenta</button>
        <small>Empresa ficticia de consultoría ambiental</small>
      </div>
      {help && <div className="en-scrim" onClick={() => setHelp(false)}><div className="en-dlg" onClick={(e) => e.stopPropagation()}><h3>Recuperar contraseña</h3><p>Te enviaremos un enlace al correo registrado.</p><div className="en-dact"><button className="en-btn" onClick={() => setHelp(false)}>Entendido</button></div></div></div>}
    </div>
  )
}

const Tile = ({ ic, t, d, onClick }) => (
  <button className="en-tile" onClick={onClick}><span className="en-tico"><LI n={ic} size={22} /></span><span className="en-tt"><b>{t}</b><small>{d}</small></span><LI n="right" size={18} /></button>
)
function Menu({ push, surveys }) {
  const open = surveys.filter((s) => !s.closed).length
  return (
    <>
      <h2 className="en-h">Hola, Laura</h2>
      <p className="en-sub">¿Qué quieres hacer hoy? Tienes {open} {open === 1 ? 'encuesta abierta' : 'encuestas abiertas'}.</p>
      <h3 className="en-sec">Mis encuestas</h3>
      <div className="en-grid"><Tile ic="edit2" t="Responder encuesta" d="Registra tus mediciones y horas." onClick={() => push('mias')} /></div>
      <h3 className="en-sec">Seguimiento</h3>
      <div className="en-grid"><Tile ic="assign" t="Administrar encuestas" d="Crea formularios, edita campos y revisa respuestas." onClick={() => push('admin')} /><Tile ic="chart" t="Consultas" d="Informes de mediciones y dedicación." onClick={() => push('consultas')} /></div>
      <h3 className="en-sec">Catálogos</h3>
      <div className="en-grid"><Tile ic="folder" t="Proyectos" d="Proyectos en los que se registran horas." onClick={() => push('cat', { k: 'proyectos' })} /><Tile ic="list" t="Actividades" d="Tipos de actividad que se pueden reportar." onClick={() => push('cat', { k: 'actividades' })} /></div>
    </>
  )
}

function Mias({ surveys, push }) {
  if (!surveys.length) return <div className="en-empty">Todavía no tienes encuestas asignadas</div>
  return (
    <>
      <p className="en-sub">Elige una para registrar o revisar tus mediciones.</p>
      <div className="en-list">
        {surveys.map((s) => (
          <article key={s.id} className="en-item">
            <div className="en-ih"><b>{s.name}</b><span className={'en-chip ' + (s.closed ? 'off' : 'ok')}>{s.closed ? 'Cerrada' : 'Abierta'}</span></div>
            <small>{s.code} · del {fd(s.start)} al {fd(s.end)} · {s.rows.filter((r) => r.who === 'Laura Gómez').length} respuestas tuyas</small>
            <div className="en-ia"><button className="en-btn sm" onClick={() => push('form', { id: s.id })}>{s.closed ? 'Consultar' : 'Responder encuesta'}</button></div>
          </article>
        ))}
      </div>
    </>
  )
}

function Form({ sv, cat, upd, say, pop, setDlg }) {
  const [v, setV] = useState({})
  const [er, setEr] = useState({})
  const [banner, setBanner] = useState('')
  const set = (id, x) => { setV((o) => ({ ...o, [id]: x })); setEr((o) => ({ ...o, [id]: '' })); setBanner('') }
  const save = (state) => {
    const row = { id: 'r' + nid(), who: 'Laura Gómez', date: TODAY, state, vals: Object.fromEntries(sv.fields.map((f) => [f.id, v[f.id] ?? ''])) }
    upd(sv.id, (x) => ({ ...x, rows: [...x.rows, row] }))
  }
  const draft = () => { save('Borrador'); say('Borrador guardado'); setV({}) }
  const send = () => {
    const e = {}
    sv.fields.forEach((f) => { const m = validate(f, v[f.id], cat); if (m) e[f.id] = m })
    setEr(e)
    if (Object.keys(e).length) return setBanner('Revisa los campos marcados en rojo.')
    setDlg({ title: '¿Está seguro de que desea enviar la encuesta?', body: 'Después de enviarla se verá en la tabla de respuestas.', ok: 'Confirmar', onOk: () => { save('Enviada'); say('Encuesta enviada. ¡Gracias!'); setV({}); setEr({}) } })
  }
  const closed = sv.closed
  return (
    <form onSubmit={(e) => { e.preventDefault(); send() }} noValidate>
      {closed && <div className="en-warn"><LI n="alert" size={16} /> Esta encuesta ya está cerrada: solo puedes consultarla.</div>}
      <div className="en-card2"><h3>Datos de la persona</h3>
        <div className="en-row2"><label className="en-fld ro"><span>Nombre</span><input value="Laura Gómez" readOnly /></label><label className="en-fld ro"><span>Cargo</span><input value="Profesional de campo" readOnly /></label></div></div>
      <div className="en-card2"><h3>Datos de la encuesta</h3>
        {sv.fields.map((f) => (
          <label key={f.id} className={'en-fld' + (er[f.id] ? ' bad' : '')}>
            <span>{f.label}{f.req ? ' *' : ''}</span>
            {f.type === 'select' ? (
              <select value={v[f.id] ?? ''} disabled={closed} onChange={(e) => set(f.id, e.target.value)} aria-label={f.label}><option value="">Selecciona…</option>{optsOf(f, cat).map((o) => <option key={o}>{o}</option>)}</select>
            ) : f.type === 'bool' ? (
              <select value={v[f.id] ?? ''} disabled={closed} onChange={(e) => set(f.id, e.target.value)} aria-label={f.label}><option value="">Selecciona…</option><option>Sí</option><option>No</option></select>
            ) : (
              <input type={f.type === 'date' ? 'date' : 'text'} inputMode={f.type === 'number' ? 'decimal' : undefined} disabled={closed} value={v[f.id] ?? ''} onChange={(e) => set(f.id, e.target.value)} aria-label={f.label} />
            )}
            {er[f.id] && <em>{er[f.id]}</em>}
          </label>
        ))}
        {sv.fields.length === 0 && <p className="en-sub">Esta encuesta todavía no tiene campos.</p>}
      </div>
      {banner && <div className="en-err" role="alert"><LI n="alert" size={16} /> {banner}</div>}
      {!closed && <div className="en-foot"><button type="button" className="en-obtn auto" onClick={draft}>Guardar borrador</button><button className="en-btn" type="submit">Enviar encuesta</button></div>}
      {closed && <div className="en-foot"><button type="button" className="en-obtn auto" onClick={pop}>Volver</button></div>}
    </form>
  )
}

function Admin({ surveys, setSurveys, push, say, setDlg }) {
  const [q, setQ] = useState('')
  const s = q.trim().toLowerCase()
  const list = surveys.filter((x) => !s || [x.name, x.code, x.start, x.end, fd(x.start), x.closed ? 'cerrada' : 'abierta'].join(' ').toLowerCase().includes(s))
  const create = () => setDlg({ title: 'Nueva encuesta', node: (set) => <NewSurvey onCancel={() => set(null)} onSave={(n) => { setSurveys((l) => [...l, n]); set(null); say('Encuesta creada: ' + n.name); push('campos', { id: n.id }) }} count={surveys.length} /> })
  const remind = (x) => setDlg({ title: 'Enviar recordatorio', node: (set) => <Remind sv={x} onClose={() => set(null)} say={say} /> })
  const del = (x) => setDlg({ title: '¿Eliminar la encuesta?', body: `«${x.name}» y sus ${x.rows.length} respuestas se borrarán.`, ok: 'Eliminar encuesta', onOk: () => { setSurveys((l) => l.filter((y) => y.id !== x.id)); say('Encuesta eliminada') } })
  return (
    <>
      <div className="en-tools"><label className="en-search"><LI n="search" size={18} /><input placeholder="Buscar por nombre, código, fecha o estado" value={q} onChange={(e) => setQ(e.target.value)} aria-label="Buscar encuestas" /></label><button className="en-btn" onClick={create}><LI n="plus" size={18} /> Nueva encuesta</button></div>
      {list.length === 0 && <div className="en-empty">Ninguna encuesta coincide con la búsqueda.</div>}
      <div className="en-list">
        {list.map((x) => (
          <article key={x.id} className="en-item">
            <div className="en-ih"><b>{x.name}</b><span className={'en-chip ' + (x.closed ? 'off' : 'ok')}>{x.closed ? 'Cerrada' : 'Abierta'}</span></div>
            <small>{x.code} · del {fd(x.start)} al {fd(x.end)} · {x.fields.length} campos · {x.rows.length} respuestas</small>
            <div className="en-ia">
              <button className="en-obtn auto sm" onClick={() => push('resp', { id: x.id })}>Respuestas ({x.rows.length})</button>
              <button className="en-obtn auto sm" onClick={() => push('campos', { id: x.id })}>Editar campos</button>
              <button className="en-obtn auto sm" onClick={() => remind(x)}><LI n="bell" size={16} /> Enviar recordatorio</button>
              <button className="en-obtn auto sm" onClick={() => { setSurveys((l) => l.map((y) => (y.id === x.id ? { ...y, closed: !y.closed } : y))); say(x.closed ? 'Encuesta reabierta' : 'Encuesta cerrada') }}>{x.closed ? 'Reabrir' : 'Cerrar'}</button>
              <button className="en-obtn auto sm dng" onClick={() => del(x)}><LI n="trash" size={16} /> Eliminar encuesta</button>
            </div>
          </article>
        ))}
      </div>
    </>
  )
}

function NewSurvey({ onSave, onCancel, count }) {
  const [name, setName] = useState('')
  const [start, setStart] = useState(TODAY)
  const [end, setEnd] = useState('2026-12-31')
  const [err, setErr] = useState('')
  const go = (e) => {
    e.preventDefault()
    if (!name.trim()) return setErr('Escribe el nombre de la encuesta')
    if (end < start) return setErr('La fecha final debe ser posterior a la inicial')
    onSave({ id: 's' + nid(), code: 'ENC-' + String(count + 1).padStart(3, '0'), name: name.trim(), start, end, closed: false, fields: [{ id: 'f' + nid(), label: 'Observaciones', type: 'text', req: false }], rows: [] })
  }
  return (
    <form onSubmit={go} noValidate>
      <label className="en-fld"><span>Nombre de la encuesta</span><input value={name} onChange={(e) => { setName(e.target.value); setErr('') }} aria-label="Nombre de la encuesta" /></label>
      <div className="en-row2"><label className="en-fld"><span>Desde</span><input type="date" value={start} onChange={(e) => setStart(e.target.value)} /></label><label className="en-fld"><span>Hasta</span><input type="date" value={end} onChange={(e) => setEnd(e.target.value)} /></label></div>
      {err && <div className="en-err" role="alert"><LI n="alert" size={16} /> {err}</div>}
      <div className="en-dact"><button type="button" className="en-tbtn" onClick={onCancel}>Cancelar</button><button className="en-btn" type="submit">Crear encuesta</button></div>
    </form>
  )
}
function Remind({ sv, onClose, say }) {
  const [msg, setMsg] = useState('Recuerda diligenciar la encuesta antes de que cierre.')
  const [who, setWho] = useState('Todos')
  return (
    <div>
      <p>«{sv.name}»</p>
      <label className="en-fld"><span>Mensaje</span><input value={msg} onChange={(e) => setMsg(e.target.value)} /></label>
      <b className="en-q">¿Para quién es esta encuesta?</b>
      <div className="en-radios">{['Todos', 'Usuarios', 'Gerentes'].map((w) => <label key={w}><input type="radio" name="who" checked={who === w} onChange={() => setWho(w)} /> {w}</label>)}</div>
      <div className="en-dact"><button className="en-tbtn" onClick={onClose}>Cancelar</button><button className="en-btn" onClick={() => { onClose(); say(`Recordatorio enviado a: ${who.toLowerCase()}`) }}>Enviar</button></div>
    </div>
  )
}

function Campos({ sv, upd, say, setDlg }) {
  const [nf, setNf] = useState({ label: '', type: 'text', opts: '', req: false })
  const [err, setErr] = useState('')
  const setF = (id, p) => upd(sv.id, (x) => ({ ...x, fields: x.fields.map((f) => (f.id === id ? { ...f, ...p } : f)) }))
  const move = (i, d) => upd(sv.id, (x) => { const a = [...x.fields]; const j = i + d; if (j < 0 || j >= a.length) return x; [a[i], a[j]] = [a[j], a[i]]; return { ...x, fields: a } })
  const del = (f) => setDlg({ title: '¿Quitar el campo «' + f.label + '»?', body: 'Las respuestas ya guardadas conservan el dato, pero el campo ya no se verá.', ok: 'Quitar', onOk: () => { upd(sv.id, (x) => ({ ...x, fields: x.fields.filter((y) => y.id !== f.id) })); say('Campo quitado') } })
  const add = (e) => {
    e.preventDefault()
    if (!nf.label.trim()) return setErr('Escribe el nombre del campo')
    const opts = nf.opts.split(',').map((o) => o.trim()).filter(Boolean)
    if (nf.type === 'select' && opts.length < 2) return setErr('Escribe al menos dos opciones separadas por coma')
    upd(sv.id, (x) => ({ ...x, fields: [...x.fields, { id: 'f' + nid(), label: nf.label.trim(), type: nf.type, req: nf.req, ...(nf.type === 'select' ? { opts } : {}) }] }))
    say('Campo agregado: ' + nf.label.trim()); setNf({ label: '', type: 'text', opts: '', req: false }); setErr('')
  }
  return (
    <>
      <div className="en-card2"><h3>Campos del formulario ({sv.fields.length})</h3>
        {sv.fields.length === 0 && <p className="en-sub">Todavía no hay campos. Agrega el primero abajo.</p>}
        {sv.fields.map((f, i) => (
          <div key={f.id} className="en-frow">
            <div className="en-fmain"><input value={f.label} onChange={(e) => setF(f.id, { label: e.target.value })} aria-label={'Nombre del campo ' + (i + 1)} />
              <span className="en-ftype">{TYPES[f.type]}{f.type === 'select' && !f.cat ? ' · ' + f.opts.join(' / ') : ''}</span></div>
            <label className="en-chk"><input type="checkbox" checked={!!f.req} onChange={(e) => setF(f.id, { req: e.target.checked })} /> Obligatorio</label>
            <button className="en-ibtn" aria-label="Subir" disabled={i === 0} onClick={() => move(i, -1)}><LI n="up" size={16} /></button>
            <button className="en-ibtn" aria-label="Bajar" disabled={i === sv.fields.length - 1} onClick={() => move(i, 1)}><LI n="down" size={16} /></button>
            <button className="en-ibtn dng" aria-label={'Quitar ' + f.label} onClick={() => del(f)}><LI n="trash" size={16} /></button>
          </div>
        ))}
      </div>
      <form className="en-card2" onSubmit={add} noValidate>
        <h3>Agregar campo</h3>
        <div className="en-row2"><label className="en-fld"><span>Nombre del campo</span><input value={nf.label} onChange={(e) => { setNf({ ...nf, label: e.target.value }); setErr('') }} aria-label="Nombre del campo nuevo" /></label>
          <label className="en-fld"><span>Tipo</span><select value={nf.type} onChange={(e) => setNf({ ...nf, type: e.target.value })} aria-label="Tipo de campo">{Object.entries(TYPES).map(([k, l]) => <option key={k} value={k}>{l}</option>)}</select></label></div>
        {nf.type === 'select' && <label className="en-fld"><span>Opciones (separadas por coma)</span><input value={nf.opts} onChange={(e) => setNf({ ...nf, opts: e.target.value })} aria-label="Opciones" /></label>}
        <label className="en-chk"><input type="checkbox" checked={nf.req} onChange={(e) => setNf({ ...nf, req: e.target.checked })} /> Obligatorio</label>
        {err && <div className="en-err" role="alert"><LI n="alert" size={16} /> {err}</div>}
        <div className="en-dact"><button className="en-btn" type="submit"><LI n="plus" size={18} /> Agregar campo</button></div>
      </form>
    </>
  )
}

function Resp({ sv, upd, say, setDlg }) {
  const [q, setQ] = useState('')
  const s = q.trim().toLowerCase()
  const rows = sv.rows.filter((r) => !s || (r.who + ' ' + r.state + ' ' + Object.values(r.vals).join(' ')).toLowerCase().includes(s))
  const exportCsv = () => {
    const head = ['Persona', 'Fecha', 'Estado', ...sv.fields.map((f) => f.label)]
    const lines = sv.rows.map((r) => [r.who, r.date, r.state, ...sv.fields.map((f) => r.vals[f.id] ?? '')].map(csvCell).join(','))
    const a = document.createElement('a')
    a.href = URL.createObjectURL(new Blob(['﻿' + [head.map(csvCell).join(','), ...lines].join('\r\n')], { type: 'text/csv;charset=utf-8' }))
    a.download = sv.code.toLowerCase() + '-respuestas.csv'
    a.click()
    say('Exportado: ' + a.download)
  }
  const del = (r) => setDlg({ title: '¿Eliminar esta respuesta?', body: `${r.who} · ${fd(r.date)}`, ok: 'Eliminar', onOk: () => { upd(sv.id, (x) => ({ ...x, rows: x.rows.filter((y) => y.id !== r.id) })); say('Respuesta eliminada') } })
  return (
    <>
      <div className="en-tools"><label className="en-search"><LI n="search" size={18} /><input placeholder="Buscar en las respuestas" value={q} onChange={(e) => setQ(e.target.value)} aria-label="Buscar respuestas" /></label><button className="en-btn" onClick={exportCsv} disabled={!sv.rows.length}><LI n="download" size={18} /> Exportar CSV</button></div>
      {rows.length === 0 ? <div className="en-empty">{sv.rows.length ? 'Ninguna respuesta coincide con la búsqueda.' : 'Todavía no hay respuestas.'}</div> : (
        <div className="en-tablew"><table className="en-table">
          <thead><tr><th>Persona</th><th>Fecha</th><th>Estado</th>{sv.fields.map((f) => <th key={f.id}>{f.label}</th>)}<th /></tr></thead>
          <tbody>{rows.map((r) => (
            <tr key={r.id}><td>{r.who}</td><td>{fd(r.date)}</td><td><span className={'en-chip ' + (r.state === 'Enviada' ? 'ok' : 'warn')}>{r.state}</span></td>{sv.fields.map((f) => <td key={f.id}>{r.vals[f.id] || '—'}</td>)}<td><button className="en-ibtn dng" aria-label="Eliminar respuesta" onClick={() => del(r)}><LI n="trash" size={16} /></button></td></tr>
          ))}</tbody></table></div>
      )}
    </>
  )
}

function Consultas({ surveys }) {
  const [id, setId] = useState(surveys[0]?.id || '')
  const sv = surveys.find((x) => x.id === id)
  if (!sv) return <div className="en-empty">No hay encuestas para consultar.</div>
  const sent = sv.rows.filter((r) => r.state === 'Enviada')
  const nums = sv.fields.filter((f) => f.type === 'number')
  return (
    <>
      <label className="en-fld"><span>Encuesta</span><select value={id} onChange={(e) => setId(e.target.value)} aria-label="Encuesta">{surveys.map((x) => <option key={x.id} value={x.id}>{x.name}</option>)}</select></label>
      <div className="en-stats"><div><b>{sent.length}</b><span>Respuestas enviadas</span></div><div><b>{sv.rows.length - sent.length}</b><span>Borradores</span></div><div><b>{new Set(sent.map((r) => r.who)).size}</b><span>Personas</span></div></div>
      {nums.map((f) => {
        const v = sent.map((r) => parseFloat(String(r.vals[f.id]).replace(',', '.'))).filter((n) => !isNaN(n))
        const sum = v.reduce((a, b) => a + b, 0)
        return (
          <div className="en-card2" key={f.id}><h3>{f.label}</h3>
            {v.length ? <div className="en-stats"><div><b>{(sum / v.length).toFixed(1)}</b><span>Promedio</span></div><div><b>{Math.min(...v)}</b><span>Mínimo</span></div><div><b>{Math.max(...v)}</b><span>Máximo</span></div><div><b>{Math.round(sum * 10) / 10}</b><span>Suma</span></div></div> : <p className="en-sub">Sin datos todavía.</p>}</div>
        )
      })}
      {nums.length === 0 && <div className="en-empty">Esta encuesta no tiene campos numéricos para resumir.</div>}
    </>
  )
}

function Catalogo({ k, cat, setCat, say }) {
  const [v, setV] = useState('')
  const list = cat[k]
  const add = (e) => {
    e.preventDefault()
    const t = v.trim()
    if (!t) return
    if (list.some((x) => x.toLowerCase() === t.toLowerCase())) return say('Ya existe: ' + t)
    setCat({ ...cat, [k]: [...list, t] }); setV(''); say('Agregado: ' + t)
  }
  return (
    <>
      <p className="en-sub">{k === 'proyectos' ? 'Aparecen como opciones en las encuestas de horas.' : 'Tipos de actividad que se pueden reportar.'}</p>
      <form className="en-tools" onSubmit={add}><label className="en-search"><input placeholder={k === 'proyectos' ? 'Nuevo proyecto' : 'Nueva actividad'} value={v} onChange={(e) => setV(e.target.value)} aria-label="Nuevo elemento" /></label><button className="en-btn" type="submit"><LI n="plus" size={18} /> Agregar</button></form>
      <div className="en-card2 flush">{list.length === 0 && <p className="en-sub pad">No hay elementos.</p>}{list.map((x) => <div key={x} className="en-li"><span>{x}</span><button className="en-ibtn dng" aria-label={'Quitar ' + x} onClick={() => { setCat({ ...cat, [k]: list.filter((y) => y !== x) }); say('Quitado: ' + x) }}><LI n="trash" size={16} /></button></div>)}</div>
    </>
  )
}
