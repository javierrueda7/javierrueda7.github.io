import { useEffect, useMemo, useRef, useState } from 'react'
import './analitica.css'

// Empresas, personas, códigos y cifras inventados. La interfaz sigue el portal real.
const COMPANY0 = 'Portal Demo'
const P = {
  grid: 'M3 3h7v7H3zM14 3h7v7h-7zM14 14h7v7h-7zM3 14h7v7H3z',
  users: 'M16 21v-2a4 4 0 00-4-4H6a4 4 0 00-4 4v2M9 11a4 4 0 100-8 4 4 0 000 8zM22 21v-2a4 4 0 00-3-3.9M16 3.1a4 4 0 010 7.8',
  chart: 'M3 3v18h18M18 17V9M13 17V5M8 17v-3',
  out: 'M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4M16 17l5-5-5-5M21 12H9',
  pencil: 'M17 3a2.8 2.8 0 114 4L7.5 20.5 2 22l1.5-5.5L17 3z',
  checks: 'M10 6h11M10 12h11M10 18h11M3 6l1 1 2-2M3 12l1 1 2-2M3 18l1 1 2-2',
  eye: 'M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12zM12 9a3 3 0 100 6 3 3 0 000-6z',
  eyeoff: 'M17.9 17.9A10.7 10.7 0 0112 19c-6 0-10-7-10-7a18 18 0 015-5.9M9.9 5.2A9 9 0 0112 5c6 0 10 7 10 7a18 18 0 01-2.2 3.2M1 1l22 22M14.1 14.1a3 3 0 11-4.2-4.2',
  search: 'M11 4a7 7 0 100 14 7 7 0 000-14zM21 21l-4.3-4.3',
  plus: 'M12 5v14M5 12h14',
  x: 'M18 6L6 18M6 6l12 12',
  shield: 'M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10zM9 12l2 2 4-4',
  chev: 'M9 6l6 6-6 6',
  back: 'M19 12H5M12 19l-7-7 7-7',
  mail: 'M3 5h18v14H3zM3 7l9 6 9-6',
  wa: 'M3 21l1.7-5A8.5 8.5 0 1112 20.5a8.4 8.4 0 01-4-1zM9 8.5c0 3 2.5 6 6 6.5l1.5-1.5-2-1-1 .8c-1-.4-2-1.4-2.4-2.4l.8-1-1-2z',
  max: 'M8 3H5a2 2 0 00-2 2v3M21 8V5a2 2 0 00-2-2h-3M3 16v3a2 2 0 002 2h3M16 21h3a2 2 0 002-2v-3',
}
const Ic = ({ n }) => (
  <svg className="an-ic" viewBox="0 0 24 24" aria-hidden="true">
    <path d={P[n]} />
  </svg>
)

const norm = (s) => (s || '').normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase()
const MESES = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sept', 'oct', 'nov', 'dic']
const fdate = (d) => (d ? `${d[2]} de ${MESES[d[1] - 1]} de ${d[0]}` : '—')
const dur = (m) => (m >= 60 ? `${Math.floor(m / 60)} h${m % 60 ? ` ${m % 60} min` : ''}` : `${m} min`)
const DOCS = ['CÉDULA DE CIUDADANÍA', 'CÉDULA DE EXTRANJERÍA', 'PASAPORTE', 'NIT']

const SEED_USERS = [
  { id: 'u0', name: 'Administrador Demo', email: 'admin@demo.com', phone: '3001234567', company: COMPANY0, role: 'admin', active: true, reg: [2026, 7, 12], last: 'hace un momento', logins: 49, min: 0, consent: true },
  { id: 'u1', name: 'Ana Gómez', email: 'ana@demo.com', phone: '3001234567', company: 'Tienda La Esquina', role: 'user', active: true, reg: [2026, 8, 11], last: 'hace 1 h', logins: 37, min: 140, consent: false },
  { id: 'u2', name: 'Beto Ruiz', email: 'beto@demo.com', phone: '3001234567', company: 'Tienda La Esquina', role: 'user', active: true, reg: [2026, 9, 10], last: 'hace 6 días', logins: 9, min: 8, consent: true },
  { id: 'u3', name: 'Carla Mejía', email: 'carla@demo.com', phone: '3001234567', company: 'Constructora Delta', role: 'user', active: true, reg: [2026, 10, 20], last: 'hace 45 días', logins: 2, min: 0, consent: true },
  { id: 'u4', name: 'Diego Parra', email: 'diego@demo.com', phone: '3001234567', company: 'Constructora Delta', role: 'user', active: true, reg: [2026, 11, 8], last: null, logins: 0, min: 0, consent: true },
  { id: 'u5', name: 'Elena Soto', email: 'elena@demo.com', phone: '3001234567', company: 'Café Montaña', role: 'user', active: true, reg: null, last: 'sin', logins: 0, min: 0, consent: true },
  { id: 'u6', name: 'Felipe Torres', email: 'felipe@demo.com', phone: '3001234567', company: 'Café Montaña', role: 'user', active: false, reg: [2026, 6, 12], last: 'hace 3 meses', logins: 15, min: 0, consent: true },
]
const SEED_MODELS = [
  { id: 'DB0001', name: 'Ventas', active: true, url: 'https://app.powerbi.com/view?r=eyJrIjoiVkVOVEFTLURFTU8i', openedBy: ['u1', 'u3'], opens: 10, min: 136 },
  { id: 'DB0002', name: 'Costos', active: true, url: 'https://app.powerbi.com/view?r=eyJrIjoiQ09TVE9TLURFTU8i', openedBy: ['u1'], opens: 1, min: 12 },
  { id: 'DB0003', name: 'Inventario', active: true, url: 'https://app.powerbi.com/view?r=eyJrIjoiSU5WLURFTU8i', openedBy: [], opens: 0, min: 0 },
  { id: 'DB0004', name: 'Nómina (antiguo)', active: false, url: 'https://app.powerbi.com/view?r=eyJrIjoiTk9NLURFTU8i', openedBy: [], opens: 0, min: 0 },
]
const SEED_ACC = { u1: ['DB0001', 'DB0002'], u2: ['DB0001', 'DB0003'], u3: ['DB0001'], u4: ['DB0002', 'DB0003'], u5: ['DB0002'] }

/* ---------- Gráficos de ejemplo (tienda ficticia) ---------- */
const SERIES = {
  DB0001: { kpi: [['Ventas del año', '$ 482 M'], ['Pedidos', '12.940'], ['Ticket promedio', '$ 37.200']], bars: [42, 51, 47, 60, 66, 72, 69, 78, 74, 85, 91, 98], ttl: 'Ventas por mes (millones)', pie: [['Abarrotes', 38], ['Bebidas', 27], ['Aseo', 21], ['Snacks', 14]] },
  DB0002: { kpi: [['Costos del año', '$ 311 M'], ['Proveedores', '48'], ['Variación', '-3,2 %']], bars: [30, 33, 31, 38, 40, 44, 41, 47, 45, 50, 53, 57], ttl: 'Costos por mes (millones)', pie: [['Mercancía', 55], ['Nómina', 24], ['Arriendo', 12], ['Servicios', 9]] },
  DB0003: { kpi: [['Referencias', '1.284'], ['Rotación', '5,6 x'], ['Agotados', '23']], bars: [64, 61, 66, 59, 62, 70, 68, 71, 66, 73, 70, 76], ttl: 'Unidades en bodega (miles)', pie: [['Abarrotes', 41], ['Bebidas', 25], ['Aseo', 22], ['Snacks', 12]] },
  DB0004: { kpi: [['Empleados', '24'], ['Costo mensual', '$ 58 M'], ['Rotación', '4 %']], bars: [52, 52, 53, 53, 55, 56, 56, 57, 57, 58, 58, 58], ttl: 'Costo de nómina (millones)', pie: [['Operación', 60], ['Ventas', 25], ['Admin.', 15]] },
}
const COLORS = ['#2d5b89', '#b3914f', '#5fa8d3', '#8a9bb0']

function Bars({ data }) {
  const max = Math.max(...data) * 1.1
  const w = 300, h = 120
  return (
    <svg viewBox={`0 0 ${w} ${h + 16}`} className="an-svg" role="img" aria-label="Gráfico de barras">
      {[0, 1, 2, 3].map((i) => <line key={i} x1="0" x2={w} y1={(h / 4) * i + 4} y2={(h / 4) * i + 4} stroke="#e2e8f0" />)}
      {data.map((v, i) => {
        const bh = (v / max) * h
        return (
          <g key={i}>
            <rect x={i * 25 + 4} y={h + 4 - bh} width="17" height={bh} rx="2" fill="#2d5b89" />
            <text x={i * 25 + 12.5} y={h + 15} fontSize="7.5" textAnchor="middle" fill="#64748b">{MESES[i]}</text>
          </g>
        )
      })}
    </svg>
  )
}
function Line({ data }) {
  const max = Math.max(...data) * 1.1, min = Math.min(...data) * 0.8
  const pts = data.map((v, i) => `${i * (300 / 11) + 2},${120 - ((v - min) / (max - min)) * 110}`)
  return (
    <svg viewBox="0 0 300 130" className="an-svg" role="img" aria-label="Gráfico de línea">
      {[0, 1, 2, 3].map((i) => <line key={i} x1="0" x2="300" y1={30 * i + 5} y2={30 * i + 5} stroke="#e2e8f0" />)}
      <polygon points={`2,125 ${pts.join(' ')} 300,125`} fill="#2d5b89" opacity=".1" />
      <polyline points={pts.join(' ')} fill="none" stroke="#b3914f" strokeWidth="2.5" strokeLinejoin="round" />
      {pts.map((p, i) => <circle key={i} cx={p.split(',')[0]} cy={p.split(',')[1]} r="2.6" fill="#b3914f" />)}
    </svg>
  )
}
function Donut({ data }) {
  const tot = data.reduce((a, d) => a + d[1], 0)
  let acc = 0
  const R = 40, C = 2 * Math.PI * R
  return (
    <div className="an-donut">
      <svg viewBox="0 0 100 100" role="img" aria-label="Gráfico circular">
        <circle cx="50" cy="50" r={R} fill="none" stroke="#eef3f8" strokeWidth="16" />
        {data.map((d, i) => {
          const len = (d[1] / tot) * C
          const el = <circle key={d[0]} cx="50" cy="50" r={R} fill="none" stroke={COLORS[i]} strokeWidth="16" strokeDasharray={`${len} ${C - len}`} strokeDashoffset={-acc} transform="rotate(-90 50 50)" />
          acc += len
          return el
        })}
      </svg>
      <ul>
        {data.map((d, i) => <li key={d[0]}><i style={{ background: COLORS[i] }} />{d[0]} <b>{d[1]} %</b></li>)}
      </ul>
    </div>
  )
}

function Illustration() {
  const win = (x, y, w, h, k) => (
    <g key={x + y}>
      <rect x={x} y={y} width={w} height={h} rx="2" fill="#fff" />
      <rect x={x} y={y} width={w} height="5" fill="#d9f1f8" />
      {k === 0 && [0, 1, 2, 3, 4, 5].map((i) => <rect key={i} x={x + 5 + i * 8} y={y + h - 6 - (8 + ((i * 7) % 20))} width="4" height={8 + ((i * 7) % 20)} fill={i % 2 ? '#ef6a4c' : '#2d5b89'} />)}
      {k === 1 && <><circle cx={x + w / 2} cy={y + h / 2 + 2} r="12" fill="none" stroke="#f26b4f" strokeWidth="7" /><circle cx={x + w / 2} cy={y + h / 2 + 2} r="12" fill="none" stroke="#4cba6a" strokeWidth="7" strokeDasharray="30 80" /></>}
      {k === 2 && <polyline points={`${x + 5},${y + h - 8} ${x + w * 0.3},${y + h - 18} ${x + w * 0.5},${y + h - 12} ${x + w * 0.75},${y + h - 26} ${x + w - 5},${y + 12}`} fill="none" stroke="#ef6a4c" strokeWidth="2" />}
      {k === 3 && <path d={`M${x + 4} ${y + h - 4} q10 -22 22 -8 t24 -2 v10z`} fill="#6aa7e0" />}
    </g>
  )
  return (
    <svg viewBox="0 0 400 220" className="an-illu" role="img" aria-label="Persona frente a tableros de datos">
      <rect width="400" height="220" fill="#5bc9e4" />
      <rect y="190" width="400" height="30" fill="#3bb4cc" />
      {win(8, 80, 80, 52, 3)}{win(52, 24, 70, 54, 0)}{win(120, 8, 72, 50, 2)}{win(180, 22, 72, 50, 1)}{win(262, 56, 70, 50, 0)}{win(302, 96, 78, 56, 2)}
      <rect x="140" y="92" width="110" height="68" rx="3" fill="#25465f" /><rect x="146" y="98" width="98" height="56" fill="#f1f5f9" />
      <polyline points="150,140 172,128 192,134 214,118 238,108" fill="none" stroke="#4cba6a" strokeWidth="2" />
      <rect x="94" y="164" width="214" height="6" fill="#e3ebf1" /><rect x="98" y="170" width="3" height="30" fill="#fff" /><rect x="300" y="170" width="3" height="30" fill="#fff" />
      <rect x="262" y="170" width="38" height="28" fill="#cfd8e1" />
      <rect x="168" y="124" width="26" height="40" rx="6" fill="#fff" /><circle cx="181" cy="118" r="9" fill="#7a4b32" /><rect x="170" y="164" width="22" height="24" rx="4" fill="#1d2b3a" />
      <rect x="176" y="188" width="10" height="10" fill="#334" /><ellipse cx="181" cy="204" rx="22" ry="4" fill="#1d6f86" />
    </svg>
  )
}

function Eye({ shown, onToggle }) {
  return <button type="button" className="an-eye" aria-label={shown ? 'Ocultar contraseña' : 'Mostrar contraseña'} onClick={onToggle}><Ic n={shown ? 'eyeoff' : 'eye'} /></button>
}
function Field({ label, hint, children, wide }) {
  return (
    <label className={`an-field ${wide ? 'wide' : ''}`}>
      <span>{label}</span>
      {children}
      {hint && <small>{hint}</small>}
    </label>
  )
}

function Contacto({ onSoon, tight }) {
  return (
    <div className={`an-contact ${tight ? 'tight' : ''}`}>
      <b>Consultoría y Servicios Informáticos</b>
      <span>Equipo de analítica</span>
      <p>Analítica de datos (Power BI)<br />Desarrollo de software a la medida<br />Automatización de procesos e implementaciones IA</p>
      <div className="an-cbtns">
        <button type="button" className="an-wa" onClick={onSoon}><Ic n="wa" />+57 300 000 0000</button>
        <button type="button" className="an-ghostb" onClick={onSoon}><Ic n="mail" />contacto@ejemplo.com</button>
        <button type="button" className="an-ghostb" onClick={onSoon}>Conozca más</button>
      </div>
      <button type="button" className="an-link" onClick={onSoon}>Política de privacidad</button>
    </div>
  )
}

/* ---------- Pantallas públicas ---------- */
function Publica({ mode, setMode, users, onLogin, onRegister, onSoon }) {
  const [f, setF] = useState({ email: '', pass: '', tipo: DOCS[0], doc: '', name: '', company: '', phone: '', ok: false })
  const [show, setShow] = useState(false)
  const [err, setErr] = useState('')
  const [sent, setSent] = useState(false)
  const set = (k) => (e) => setF({ ...f, [k]: e.target.type === 'checkbox' ? e.target.checked : e.target.value })
  const go = (m) => { setMode(m); setErr(''); setSent(false) }
  const submit = (e) => {
    e.preventDefault()
    if (mode === 'login') {
      const r = onLogin(f.email.trim(), f.pass)
      if (r) setErr(r)
    } else if (mode === 'registro') {
      if (users.some((u) => norm(u.email) === norm(f.email.trim()))) return setErr('Ya existe un usuario con ese correo.')
      if (f.pass.length < 6) return setErr('La contraseña debe tener al menos 6 caracteres.')
      onRegister(f)
    } else setSent(true)
  }
  const valid = mode === 'login' ? f.email && f.pass : mode === 'registro' ? f.doc && f.name && f.company && f.phone && f.email && f.pass && f.ok : f.email
  return (
    <div className="an-pub">
      <aside className="an-left">
        <p className="an-brand">ANALÍTICA DEMO</p>
        <h2>Sus modelos de Power BI, en un solo lugar.</h2>
        <Illustration />
        <Contacto onSoon={onSoon} tight />
      </aside>
      <section className="an-right">
        <form className="an-formw" onSubmit={submit} noValidate>
          {mode === 'login' && <><h1>Iniciar sesión</h1><p className="an-sub">Ingrese con el correo y la contraseña de su cuenta.</p></>}
          {mode === 'registro' && <><h1>Crear usuario</h1><p className="an-sub">Regístrese y nuestro equipo le habilitará los modelos que le correspondan.</p></>}
          {mode === 'recuperar' && <><h1>Recuperar contraseña</h1><p className="an-sub">Le enviaremos un enlace para crear una nueva contraseña.</p></>}
          {mode === 'recuperar' && sent ? (
            <div className="an-okbox"><b>Revise su correo</b><span>Si {f.email} tiene cuenta, recibirá un enlace para restablecer su contraseña. (En esta demo no se envía ningún correo.)</span></div>
          ) : (
            <div className="an-grid2">
              {mode === 'registro' && (
                <>
                  <Field label="Tipo de documento"><select value={f.tipo} onChange={set('tipo')}>{DOCS.map((d) => <option key={d}>{d}</option>)}</select></Field>
                  <Field label="Número de identificación"><input value={f.doc} onChange={set('doc')} inputMode="numeric" /></Field>
                  <Field label="Nombre completo" wide><input value={f.name} onChange={set('name')} autoComplete="name" /></Field>
                  <Field label="Empresa"><input value={f.company} onChange={set('company')} /></Field>
                  <Field label="Celular"><input value={f.phone} onChange={set('phone')} inputMode="tel" /></Field>
                </>
              )}
              <Field label="Correo electrónico" wide hint={mode === 'registro' ? 'Será su usuario para iniciar sesión.' : null}>
                <input type="email" value={f.email} onChange={set('email')} placeholder="nombre@empresa.com" autoComplete="email" />
              </Field>
              {mode !== 'recuperar' && (
                <Field label="Contraseña" wide hint={mode === 'registro' ? 'Mínimo 6 caracteres.' : null}>
                  <span className="an-pw"><input type={show ? 'text' : 'password'} value={f.pass} onChange={set('pass')} autoComplete="current-password" /><Eye shown={show} onToggle={() => setShow(!show)} /></span>
                </Field>
              )}
            </div>
          )}
          {mode === 'login' && <div className="an-forgot"><button type="button" className="an-lk" onClick={() => go('recuperar')}>¿Olvidó su contraseña?</button></div>}
          {mode === 'registro' && (
            <label className="an-chk"><input type="checkbox" checked={f.ok} onChange={set('ok')} /><span>Soy mayor de edad y autorizo el tratamiento de mis datos personales según la <button type="button" className="an-lk" onClick={onSoon}>política de tratamiento de datos</button>.</span></label>
          )}
          {err && <p className="an-err" role="alert">{err}</p>}
          {!(mode === 'recuperar' && sent) && (
            <button className="an-btn full" disabled={!valid}>{mode === 'login' ? 'Iniciar sesión' : mode === 'registro' ? 'Crear usuario' : 'Enviar enlace'}</button>
          )}
          {mode === 'login' ? (
            <>
              <p className="an-alt">¿No tiene cuenta? <button type="button" className="an-lk" onClick={() => go('registro')}>Crear usuario</button></p>
              <div className="an-try"><span>Probar como</span>
                <button type="button" onClick={() => { setF({ ...f, email: 'ana@demo.com', pass: 'demo123' }); setErr('') }}>Cliente (Ana)</button>
                <button type="button" onClick={() => { setF({ ...f, email: 'admin@demo.com', pass: 'demo123' }); setErr('') }}>Administrador</button>
              </div>
            </>
          ) : (
            <button type="button" className="an-lk back" onClick={() => go('login')}><Ic n="back" />Ya tengo cuenta</button>
          )}
        </form>
      </section>
    </div>
  )
}

function Consent({ onOk, onOut }) {
  const [ok, setOk] = useState(false)
  return (
    <div className="an-consent">
      <div className="an-card an-cc">
        <h1><Ic n="shield" />Antes de continuar</h1>
        <p>Para usar el portal necesitamos su autorización para tratar sus datos personales. Allí explicamos qué datos guardamos, para qué y cómo ejercer sus derechos, incluido que registramos cuándo y cuánto usa cada modelo.</p>
        <label className="an-chk"><input type="checkbox" checked={ok} onChange={(e) => setOk(e.target.checked)} /><span>Soy mayor de edad y autorizo el tratamiento de mis datos personales según la <b className="an-lk">política de tratamiento de datos</b>.</span></label>
        <div className="an-row"><button className="an-btn" disabled={!ok} onClick={onOk}>Aceptar y continuar</button><button className="an-lk bold" onClick={onOut}>Salir</button></div>
        <p className="an-note">Si no desea autorizar el tratamiento, puede salir. Para consultas o para pedir la eliminación de sus datos escriba a <b>contacto@ejemplo.com</b>.</p>
      </div>
    </div>
  )
}

/* ---------- Diálogos ---------- */
function Dialog({ title, desc, onClose, foot, children, wide }) {
  useEffect(() => {
    const k = (e) => e.key === 'Escape' && onClose()
    window.addEventListener('keydown', k)
    return () => window.removeEventListener('keydown', k)
  }, [onClose])
  return (
    <div className="an-ov" onMouseDown={(e) => e.target === e.currentTarget && onClose()}>
      <div className={`an-dlg ${wide ? 'w2' : ''}`} role="dialog" aria-modal="true" aria-label={title}>
        <header><div><h3>{title}</h3>{desc && <p>{desc}</p>}</div><button className="an-xb" aria-label="Cerrar" onClick={onClose}><Ic n="x" /></button></header>
        <div className="an-dbody">{children}</div>
        <footer>{foot}</footer>
      </div>
    </div>
  )
}

function UserDialog({ user, onClose, onSave }) {
  const [f, setF] = useState(user || { tipo: DOCS[0], doc: '', name: '', company: '', phone: '', email: '', role: 'user', active: true })
  const set = (k) => (e) => setF({ ...f, [k]: e.target.value })
  const ok = f.doc && f.name && f.company && f.phone && f.email
  return (
    <Dialog title={user ? 'Editar usuario' : 'Nuevo usuario'} desc={user ? 'Actualice los datos y el estado de la cuenta.' : 'La persona recibirá un correo para crear su contraseña.'} onClose={onClose}
      foot={<><button className="an-btn ghost" onClick={onClose}>Cancelar</button><button className="an-btn" disabled={!ok} onClick={() => onSave({ ...f, role: f.role, active: f.active === true || f.active === 'true' })}>{user ? 'Guardar cambios' : 'Crear usuario'}</button></>}>
      <div className="an-grid2">
        <Field label="Tipo de documento"><select value={f.tipo} onChange={set('tipo')}>{DOCS.map((d) => <option key={d}>{d}</option>)}</select></Field>
        <Field label="Número de identificación"><input value={f.doc} onChange={set('doc')} /></Field>
        <Field label="Nombre completo" wide><input value={f.name} onChange={set('name')} /></Field>
        <Field label="Empresa"><input value={f.company} onChange={set('company')} /></Field>
        <Field label="Celular"><input value={f.phone} onChange={set('phone')} /></Field>
        <Field label="Correo electrónico" wide hint="Será su usuario para iniciar sesión."><input type="email" value={f.email} onChange={set('email')} disabled={!!user} /></Field>
        <Field label="Rol"><select value={f.role} onChange={set('role')}><option value="user">Usuario</option><option value="admin">Administrador</option></select></Field>
        <Field label="Estado"><select value={String(f.active)} onChange={set('active')}><option value="true">Activo</option><option value="false">Inactivo</option></select></Field>
      </div>
    </Dialog>
  )
}

function ModelDialog({ model, onClose, onSave }) {
  const [f, setF] = useState(model || { name: '', url: '', active: true })
  const set = (k) => (e) => setF({ ...f, [k]: e.target.value })
  const ok = f.name.trim() && /^https:\/\/app\.powerbi\.com\//.test(f.url.trim())
  return (
    <Dialog title={model ? `Editar modelo ${model.id}` : 'Nuevo modelo'} desc="El link se obtiene en Power BI con «Publicar en la web»." onClose={onClose}
      foot={<><button className="an-btn ghost" onClick={onClose}>Cancelar</button><button className="an-btn" disabled={!ok} onClick={() => onSave({ ...f, active: f.active === true || f.active === 'true' })}>{model ? 'Guardar cambios' : 'Agregar modelo'}</button></>}>
      <div className="an-grid2">
        <Field label="Nombre" wide><input value={f.name} onChange={set('name')} /></Field>
        <Field label="Link de Power BI" wide hint={f.url && !ok ? 'Debe empezar por https://app.powerbi.com/' : null}><input className="mono" value={f.url} onChange={set('url')} placeholder="https://app.powerbi.com/view?r=…" /></Field>
        <Field label="Estado"><select value={String(f.active)} onChange={set('active')}><option value="true">Activo</option><option value="false">Inactivo</option></select></Field>
      </div>
    </Dialog>
  )
}

function AssignDialog({ title, desc, options, initial, onClose, onSave }) {
  const [sel, setSel] = useState(new Set(initial))
  const [q, setQ] = useState('')
  const vis = options.filter((o) => norm(`${o.title} ${o.detail || ''} ${o.id}`).includes(norm(q.trim())))
  const changes = [...sel].filter((x) => !initial.has(x)).length + [...initial].filter((x) => !sel.has(x)).length
  const toggle = (id) => { const n = new Set(sel); n.has(id) ? n.delete(id) : n.add(id); setSel(n) }
  const mark = (on) => { const n = new Set(sel); vis.forEach((o) => (on ? n.add(o.id) : n.delete(o.id))); setSel(n) }
  return (
    <Dialog title={title} desc={desc} onClose={onClose} wide
      foot={<><span className="an-cnt">{sel.size} seleccionado{sel.size === 1 ? '' : 's'}{changes > 0 && ` · ${changes} cambio${changes === 1 ? '' : 's'} sin guardar`}</span><button className="an-btn ghost" onClick={onClose}>Cancelar</button><button className="an-btn" disabled={changes === 0} onClick={() => onSave(sel)}>Guardar</button></>}>
      <div className="an-asrow">
        <span className="an-search"><Ic n="search" /><input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Buscar…" aria-label="Buscar" /></span>
        <button className="an-btn sec" onClick={() => mark(true)} disabled={!vis.length}>Marcar todos</button>
        <button className="an-btn ghost" onClick={() => mark(false)} disabled={!vis.length}>Quitar todos</button>
      </div>
      {vis.length === 0 ? <p className="an-empty-s">No hay resultados.</p> : (
        <ul className="an-chlist">
          {vis.map((o) => (
            <li key={o.id}><label className={sel.has(o.id) ? 'on' : ''}>
              <input type="checkbox" checked={sel.has(o.id)} onChange={() => toggle(o.id)} />
              <span><b>{o.title}</b>{o.detail && <small>{o.detail}</small>}</span>
              {!o.active && <em className="an-pill off"><i />Inactivo</em>}
            </label></li>
          ))}
        </ul>
      )}
    </Dialog>
  )
}

/* ---------- Aplicación ---------- */
const Pill = ({ on }) => <span className={`an-pill ${on ? 'on' : 'off'}`}><i />{on ? 'Activo' : 'Inactivo'}</span>
const Seg = ({ v, set }) => (
  <div className="an-seg" role="group" aria-label="Filtrar por estado">
    {[['todos', 'Todos'], ['activos', 'Activos'], ['inactivos', 'Inactivos']].map(([k, l]) => <button key={k} className={v === k ? 'on' : ''} onClick={() => set(k)}>{l}</button>)}
  </div>
)

function Viewer({ model, user, onBack, onFull, full }) {
  const d = SERIES[model.id]
  const mul = user.company === 'Tienda La Esquina' ? 1 : user.company === 'Constructora Delta' ? 1.3 : 0.8
  return (
    <div className={`an-viewer ${full ? 'full' : ''}`}>
      <header>
        <button className="an-vb" onClick={onBack} aria-label="Volver a mis modelos"><Ic n="back" /><span>Mis modelos</span></button>
        <h1>{model.name}</h1>
        <button className="an-vb" onClick={onFull}><Ic n="max" /><span>Pantalla completa</span></button>
      </header>
      <div className="an-vcan">
        <div className="an-rep">
          <div className="an-rep-h"><b>Tienda La Esquina · {model.name}</b><span>Datos de ejemplo</span></div>
          <div className="an-kpis">{d.kpi.map(([l, v]) => <div key={l}><small>{l}</small><b>{v}</b></div>)}</div>
          <div className="an-charts">
            <div className="an-chart"><h4>{d.ttl}</h4><Bars data={d.bars.map((x) => Math.round(x * mul))} /></div>
            <div className="an-chart"><h4>Participación por categoría</h4><Donut data={d.pie} /></div>
            <div className="an-chart wide"><h4>Tendencia mensual</h4><Line data={d.bars.map((x) => x * mul)} /></div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default function Analitica() {
  const [users, setUsers] = useState(SEED_USERS)
  const [models, setModels] = useState(SEED_MODELS)
  const [acc, setAcc] = useState(SEED_ACC)
  const [me, setMe] = useState(null)
  const [mode, setMode] = useState('login')
  const [pend, setPend] = useState(null)
  const [view, setView] = useState('inicio')
  const [open, setOpen] = useState(null)
  const [full, setFull] = useState(false)
  const [dlg, setDlg] = useState(null)
  const [q, setQ] = useState('')
  const [fs, setFs] = useState('todos')
  const [toast, setToast] = useState('')
  const tt = useRef(0)
  const soon = () => { setToast('No disponible en la demo.'); clearTimeout(tt.current); tt.current = setTimeout(() => setToast(''), 1800) }
  const me2 = me && users.find((u) => u.id === me)
  const admin = me2?.role === 'admin'

  const nav = (v) => { setView(v); setQ(''); setFs('todos'); setOpen(null); setFull(false) }
  const enter = (id) => { setUsers((us) => us.map((u) => (u.id === id ? { ...u, last: 'hace un momento', logins: u.logins + 1 } : u))); setMe(id); setPend(null); nav('inicio') }
  const login = (email, pass) => {
    const u = users.find((x) => norm(x.email) === norm(email))
    if (!u || !pass) return 'Correo o contraseña incorrectos.'
    if (!u.active) return 'Su usuario está inactivo. Comuníquese con el administrador.'
    if (!u.consent) return setPend(u.id)
    enter(u.id)
  }
  const register = (f) => {
    const id = 'u' + Date.now()
    setUsers((us) => [...us, { id, name: f.name, email: f.email.trim(), phone: f.phone, company: f.company, role: 'user', active: true, reg: [2026, 11, 9], last: null, logins: 0, min: 0, consent: true, tipo: f.tipo, doc: f.doc }])
    enter(id)
  }
  const out = () => { setMe(null); setPend(null); setMode('login') }
  const myModels = useMemo(() => (me2 ? models.filter((m) => m.active && (acc[me2.id] || []).includes(m.id)) : []), [me2, models, acc])
  const usersOf = (mid) => Object.keys(acc).filter((u) => acc[u].includes(mid))
  const openModel = (m) => {
    setModels((ms) => ms.map((x) => (x.id === m.id ? { ...x, opens: x.opens + 1, min: x.min + 1, openedBy: x.openedBy.includes(me2.id) ? x.openedBy : [...x.openedBy, me2.id] } : x)))
    setOpen(m.id); setFull(false)
  }

  let body
  if (!me2 && !pend) {
    body = <Publica mode={mode} setMode={setMode} users={users} onLogin={login} onRegister={register} onSoon={soon} />
  } else if (!me2 && pend) {
    body = <Consent onOk={() => { setUsers((us) => us.map((u) => (u.id === pend ? { ...u, consent: true } : u))); enter(pend) }} onOut={out} />
  } else if (open) {
    const m = models.find((x) => x.id === open)
    body = (
      <Viewer model={m} user={me2} full={full} onBack={() => { setOpen(null); setFull(false) }} onFull={() => setFull(!full)} />
    )
  } else {
    const first = me2.name.split(' ')[0]
    let page
    if (view === 'inicio') {
      page = (
        <>
          <h1 className="an-h1">Hola, {first}</h1>
          <p className="an-sub">Estos son los modelos de Power BI que tiene disponibles.</p>
          {myModels.length === 0 ? (
            <div className="an-card an-vacio"><span><Ic n="chart" /></span><b>Aún no tiene modelos disponibles</b><p>{admin ? 'Asígnese modelos desde Modelos, o ábralos directamente desde allí.' : 'Nuestro equipo le habilitará los modelos que le correspondan.'}</p></div>
          ) : (
            <div className="an-cards">
              {myModels.map((m) => (
                <button key={m.id} className="an-card an-mc" onClick={() => openModel(m)}>
                  <span className="an-mi"><Ic n="chart" /></span>
                  <span className="an-mt"><b>{m.name.toUpperCase()}</b><small>{m.id}</small></span>
                  <Ic n="chev" />
                </button>
              ))}
            </div>
          )}
        </>
      )
    } else if (view === 'usuarios') {
      const list = users.filter((u) => (fs === 'todos' || (fs === 'activos') === u.active) && norm(`${u.name} ${u.email} ${u.company} ${u.doc || ''}`).includes(norm(q.trim())))
      page = (
        <>
          <div className="an-th"><div><h1 className="an-h1">Administración de usuarios</h1><p className="an-sub">Cree usuarios, edite sus datos y asígneles los modelos que pueden ver.</p></div><button className="an-btn" onClick={() => setDlg({ t: 'user' })}><Ic n="plus" />Nuevo usuario</button></div>
          <div className="an-tools">
            <span className="an-search"><Ic n="search" /><input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Buscar por nombre, correo, empresa o documento…" aria-label="Buscar usuarios" /></span>
            <Seg v={fs} set={setFs} /><span className="an-rc">{list.length} resultado{list.length === 1 ? '' : 's'}</span>
          </div>
          {list.length === 0 ? <div className="an-card an-vacio"><b>No hay usuarios que coincidan</b></div> : (
            <div className="an-card an-tw"><table>
              <thead><tr><th>Usuario</th><th>Empresa</th><th>Rol</th><th>Estado</th><th>Actividad (30 días)</th><th className="c">Modelos</th><th className="r">Acciones</th></tr></thead>
              <tbody>{list.map((u) => (
                <tr key={u.id}>
                  <td className="u"><b>{u.name.toUpperCase()}{u.id === me2.id && <em> (usted)</em>}</b><small>{u.email} · {u.phone}</small><small>Registro: {fdate(u.reg)}</small></td>
                  <td className="co">{u.company.toUpperCase()}</td>
                  <td className="ro">{u.role === 'admin' ? 'Administrador' : 'Usuario'}</td>
                  <td><Pill on={u.active} /></td>
                  <td className="ac"><b>{u.last === 'sin' ? 'Sin datos de ingreso' : u.last ? `Último ingreso ${u.last}` : 'Aún no ha ingresado'}</b><small>{u.logins} ingreso{u.logins === 1 ? '' : 's'} · {dur(u.min)} de uso</small></td>
                  <td className="c nm" data-l="Modelos">{(acc[u.id] || []).length}</td>
                  <td className="r"><button className="an-ib" aria-label={`Editar usuario ${u.name}`} title="Editar usuario" onClick={() => setDlg({ t: 'user', id: u.id })}><Ic n="pencil" /></button><button className="an-ib" aria-label={`Asignar modelos a ${u.name}`} title="Asignar modelos" onClick={() => setDlg({ t: 'amod', id: u.id })}><Ic n="checks" /></button></td>
                </tr>))}</tbody>
            </table></div>
          )}
        </>
      )
    } else {
      const list = models.filter((m) => (fs === 'todos' || (fs === 'activos') === m.active) && norm(`${m.name} ${m.id}`).includes(norm(q.trim())))
      page = (
        <>
          <div className="an-th"><div><h1 className="an-h1">Administración de modelos</h1><p className="an-sub">Registre los dashboards de Power BI y elija qué usuarios pueden verlos.</p></div><button className="an-btn" onClick={() => setDlg({ t: 'model' })}><Ic n="plus" />Nuevo modelo</button></div>
          <div className="an-tools">
            <span className="an-search"><Ic n="search" /><input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Buscar por nombre o código…" aria-label="Buscar modelos" /></span>
            <Seg v={fs} set={setFs} /><span className="an-rc">{list.length} resultado{list.length === 1 ? '' : 's'}</span>
          </div>
          {list.length === 0 ? <div className="an-card an-vacio"><b>No hay modelos que coincidan</b></div> : (
            <div className="an-card an-tw"><table>
              <thead><tr><th>Código</th><th>Nombre</th><th>Estado</th><th className="c">Usuarios</th><th>Uso (30 días)</th><th className="r">Acciones</th></tr></thead>
              <tbody>{list.map((m) => {
                const n = usersOf(m.id).length
                return (
                  <tr key={m.id}>
                    <td className="cd">{m.id}</td><td className="mn">{m.name.toUpperCase()}</td><td><Pill on={m.active} /></td><td className="c nm" data-l="Usuarios">{n}</td>
                    <td className="ac">{m.opens === 0 ? (m.active && n > 0 ? <span className="warn">Sin uso en 30 días</span> : '—') : <><b>Lo abrieron {m.openedBy.length} de {Math.max(n, m.openedBy.length)}</b><small>{m.opens} apertura{m.opens === 1 ? '' : 's'} · {dur(m.min)} de uso</small></>}</td>
                    <td className="r"><button className="an-ib" aria-label={`Ver modelo ${m.name}`} title="Ver modelo" onClick={() => { setOpen(m.id); setFull(false) }}><Ic n="eye" /></button><button className="an-ib" aria-label={`Editar modelo ${m.name}`} title="Editar modelo" onClick={() => setDlg({ t: 'model', id: m.id })}><Ic n="pencil" /></button><button className="an-ib" aria-label={`Asignar usuarios a ${m.name}`} title="Asignar usuarios" onClick={() => setDlg({ t: 'ause', id: m.id })}><Ic n="checks" /></button></td>
                  </tr>)
              })}</tbody>
            </table></div>
          )}
        </>
      )
    }
    body = (
      <>
        <header className="an-top">
          <span className="an-logo"><Ic n="chart" /><b>POWER BI</b></span>
          <nav>
            <button className={view === 'inicio' ? 'on' : ''} onClick={() => nav('inicio')}><Ic n="grid" /><span>Mis modelos</span></button>
            {admin && <button className={view === 'usuarios' ? 'on' : ''} onClick={() => nav('usuarios')}><Ic n="users" /><span>Usuarios</span></button>}
            {admin && <button className={view === 'modelos' ? 'on' : ''} onClick={() => nav('modelos')}><Ic n="chart" /><span>Modelos</span></button>}
          </nav>
          <span className="an-who">{me2.name.toUpperCase()}</span>
          <button className="an-exit" onClick={out}><Ic n="out" /><span>Salir</span></button>
        </header>
        <div className="an-scroll"><main className="an-main">{page}</main><footer className="an-foot"><Contacto onSoon={soon} /></footer></div>
      </>
    )
  }

  // diálogos
  let dialog = null
  if (dlg?.t === 'user') {
    const u = dlg.id && users.find((x) => x.id === dlg.id)
    dialog = <UserDialog user={u} onClose={() => setDlg(null)} onSave={(f) => {
      if (u) setUsers((us) => us.map((x) => (x.id === u.id ? { ...x, ...f } : x)))
      else setUsers((us) => [...us, { ...f, id: 'u' + Date.now(), reg: [2026, 11, 9], last: null, logins: 0, min: 0, consent: false }])
      setDlg(null)
    }} />
  } else if (dlg?.t === 'model') {
    const m = dlg.id && models.find((x) => x.id === dlg.id)
    dialog = <ModelDialog model={m} onClose={() => setDlg(null)} onSave={(f) => {
      if (m) setModels((ms) => ms.map((x) => (x.id === m.id ? { ...x, ...f } : x)))
      else setModels((ms) => [...ms, { ...f, id: 'DB' + String(ms.length + 1).padStart(4, '0'), openedBy: [], opens: 0, min: 0 }])
      setDlg(null)
    }} />
  } else if (dlg?.t === 'amod') {
    const u = users.find((x) => x.id === dlg.id)
    dialog = <AssignDialog title="Modelos habilitados" desc={`Elija los modelos que puede ver ${u.name}.`} initial={new Set(acc[u.id] || [])}
      options={models.map((m) => ({ id: m.id, title: m.name, detail: m.id, active: m.active }))} onClose={() => setDlg(null)}
      onSave={(s) => { setAcc((a) => ({ ...a, [u.id]: [...s] })); setDlg(null) }} />
  } else if (dlg?.t === 'ause') {
    const m = models.find((x) => x.id === dlg.id)
    dialog = <AssignDialog title="Usuarios habilitados" desc={`Elija quién puede ver el modelo ${m.name}.`} initial={new Set(usersOf(m.id))}
      options={users.map((u) => ({ id: u.id, title: `${u.name} · ${u.company}`, detail: u.email, active: u.active }))} onClose={() => setDlg(null)}
      onSave={(s) => { setAcc((a) => { const n = {}; users.forEach((u) => { const cur = (a[u.id] || []).filter((x) => x !== m.id); n[u.id] = s.has(u.id) ? [...cur, m.id] : cur }); return n }); setDlg(null) }} />
  }

  return (
    <div className="an">
      {body}
      {dialog}
      {toast && <div className="an-toast" role="status">{toast}</div>}
    </div>
  )
}
