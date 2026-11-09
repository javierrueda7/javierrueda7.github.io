import { useLayoutEffect, useMemo, useRef, useState } from 'react'
import { LI } from '../lib/lineicons.jsx'
import './polizas.css'

// Asesoría de seguros ficticia. Asegurados, aseguradoras, pólizas y valores son inventados.
const TODAY = '2026-11-09'
const T0 = new Date(TODAY + 'T00:00:00')
const daysTo = (d) => Math.round((new Date(d + 'T00:00:00') - T0) / 864e5)
const fd = (d) => (d ? d.split('-').reverse().join('/') : '—')
const money = (n) => '$' + Math.round(n).toLocaleString('es-CO')
const ym = (d) => d.slice(0, 7)
const MES = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic']
const mlabel = (k) => MES[+k.slice(5, 7) - 1] + ' ' + k.slice(2, 4)
const addYear = (d) => (+d.slice(0, 4) + 1) + d.slice(4)
const PAL = ['#2a78d6', '#eb6834', '#1baf7a', '#eda100', '#e87ba4', '#4a3aa7']

const ASEG0 = ['Aseguradora Andina', 'Seguros del Páramo', 'Protección Cumbre']
const RAMOS0 = { Autos: ['Todo riesgo', 'Flota pesada', 'Moto'], Vida: ['Vida individual', 'Vida grupo'], Hogar: ['Hogar integral'], Cumplimiento: ['Contrato estatal'], 'Responsabilidad civil': ['RC profesional'], Salud: ['Plan familiar'], Pyme: ['Multiriesgo'], 'Todo riesgo construcción': ['Obra civil'], 'Accidentes personales': ['Estudiantil'] }
const ASES0 = ['Camila Duarte', 'Felipe Garzón', 'Natalia Rojas']
const MEDIOS = ['Transferencia', 'Consignación', 'Efectivo', 'Cheque', 'Tarjeta']

const P = (cod, cliente, doc, aseg, ramo, prod, bien, ini, prima, ases, user, pagado) => ({
  cod, nro: 'AND-' + (480000 + +cod.slice(2) * 17), cliente, doc, aseg, ramo, prod, bien, ini, venc: addYear(ini), prima, total: Math.round(prima * 1.19),
  exp: ini, ases, user, reg: ini, pagado,
})
const SEED = [
  P('P-1001', 'Marcela Quintero', 'CC 52.341.870', ASEG0[0], 'Autos', 'Todo riesgo', 'Mazda 3 · placa KXL 482', '2025-12-02', 1850000, ASES0[0], 'ldiaz', 1),
  P('P-1002', 'Distribuidora El Roble SAS', 'NIT 900.111.222-1', ASEG0[2], 'Cumplimiento', 'Contrato estatal', 'Contrato 045 de suministro', '2026-05-20', 6400000, ASES0[1], 'mpardo', 0.5),
  P('P-1003', 'Andrés Cifuentes', 'CC 79.455.120', ASEG0[1], 'Vida', 'Vida individual', 'Vida individual', '2025-11-15', 980000, ASES0[2], 'ldiaz', 0.5),
  P('P-1004', 'Clínica Santa Aurora', 'NIT 800.222.333-4', ASEG0[0], 'Responsabilidad civil', 'RC profesional', 'Sede norte, 42 médicos', '2026-02-10', 9200000, ASES0[0], 'mpardo', 1),
  P('P-1005', 'Sofía Ardila', 'CC 1.020.455.671', ASEG0[1], 'Hogar', 'Hogar integral', 'Apto 502, Torre B', '2025-11-12', 720000, ASES0[2], 'ldiaz', 0),
  P('P-1006', 'Transportes Río Alto', 'NIT 901.333.444-5', ASEG0[2], 'Autos', 'Flota pesada', '12 vehículos de carga', '2026-06-28', 14300000, ASES0[1], 'mpardo', 0.5),
  P('P-1007', 'Laura Beltrán', 'CC 63.700.912', ASEG0[1], 'Salud', 'Plan familiar', 'Grupo familiar de 4', '2026-08-05', 3100000, ASES0[0], 'ldiaz', 0.75),
  P('P-1008', 'Constructora Mirador SAS', 'NIT 900.555.666-7', ASEG0[0], 'Todo riesgo construcción', 'Obra civil', 'Torre Mirador, fase 1', '2026-09-14', 21800000, ASES0[1], 'mpardo', 0.4),
  P('P-1009', 'Héctor Valencia', 'CC 80.112.334', ASEG0[2], 'Autos', 'Moto', 'Yamaha · placa QRT 91F', '2025-10-30', 420000, ASES0[2], 'ldiaz', 1),
  P('P-1010', 'Ferretería Nuevo Sol', 'NIT 901.777.888-9', ASEG0[1], 'Pyme', 'Multiriesgo', 'Local comercial, Cra. 12', '2026-10-02', 2700000, ASES0[0], 'mpardo', 0),
  P('P-1011', 'Paola Rincón', 'CC 52.987.001', ASEG0[2], 'Vida', 'Vida grupo', 'Grupo de 9 empleados', '2026-03-18', 1450000, ASES0[2], 'ldiaz', 1),
  P('P-1012', 'Colegio Los Cedros', 'NIT 800.909.101-2', ASEG0[0], 'Accidentes personales', 'Estudiantil', '310 estudiantes', '2026-01-22', 5600000, ASES0[0], 'mpardo', 0.66),
]
const seedPays = () => {
  let n = 1
  const out = []
  SEED.forEach((p) => {
    const paid = p.pagado === 1 ? p.total : Math.round((p.total * p.pagado) / 1000) * 1000
    if (!paid) return
    const parts = p.pagado === 1 ? 1 : 2
    for (let i = 0; i < parts; i++) {
      const monto = i === parts - 1 ? paid - Math.round(paid / parts / 1000) * 1000 * (parts - 1) : Math.round(paid / parts / 1000) * 1000
      const d = new Date(new Date(p.ini + 'T00:00:00').getTime() + i * 30 * 864e5).toISOString().slice(0, 10)
      out.push({ id: n++, pol: p.cod, date: d, monto, medio: MEDIOS[(n + i) % 3], user: p.user })
    }
  })
  return out
}
const CASES0 = [
  { id: 1, tipo: 'Pago dudoso', pol: 'P-1005', detalle: 'La clienta dice que transfirió $720.000, pero no aparece ningún abono.', nota: '' },
  { id: 2, tipo: 'Comisión', pol: 'P-1008', detalle: 'La comisión recibida de la aseguradora no coincide con la pactada (10%).', nota: '' },
  { id: 3, tipo: 'Póliza', pol: 'P-1006', detalle: 'Faltan 2 vehículos en la relación de bienes asegurados.', nota: '' },
  { id: 4, tipo: 'Pago dudoso', pol: 'P-1003', detalle: 'Abono duplicado el 30/11/2025.', nota: 'Se devolvió el valor al cliente.', done: true },
]

function useNarrow(ref) {
  const [n, setN] = useState(900)
  useLayoutEffect(() => {
    const el = ref.current
    const f = () => setN(el.clientWidth)
    f()
    const ro = new ResizeObserver(f)
    ro.observe(el)
    return () => ro.disconnect()
  }, [ref])
  return n
}

const Logo = ({ s = 40 }) => (
  <svg className="pz-logo" viewBox="0 0 64 64" width={s} height={s} aria-hidden="true">
    <path d="M32 6l22 8v16c0 14-9 24-22 28C19 54 10 44 10 30V14l22-8z" fill="#1C4870" />
    <path d="M22 32l7 7 14-15" fill="none" stroke="#fff" strokeWidth="5" strokeLinecap="round" strokeLinejoin="round" />
  </svg>
)

const NAV = [
  ['inicio', 'Inicio', 'home'], ['polizas', 'Pólizas', 'receipt'], ['catalogos', 'Catálogos', 'folder'], ['reportes', 'Reportes', 'bars'],
  ['pagos', 'Reportes de Comisiones', 'wallet'], ['casos', 'Casos por revisar', 'clip'], ['dash', 'Dashboard gerencial', 'layout'],
]

export default function Polizas() {
  const [logged, setLogged] = useState(true)
  const [pols, setPols] = useState(SEED)
  const [pays, setPays] = useState(seedPays)
  const [cases, setCases] = useState(CASES0)
  const [cat, setCat] = useState({ aseg: ASEG0, ases: ASES0 })
  const [page, setPage] = useState('inicio')
  const [selId, setSelId] = useState(null)
  const [menu, setMenu] = useState(false)
  const [toast, setToast] = useState('')
  const [dialog, setDialog] = useState(null)
  const root = useRef(null)
  const width = useNarrow(root)
  const narrow = width < 520
  const rail = !narrow && width < 760
  const tt = useRef()
  const say = (m) => { setToast(m); clearTimeout(tt.current); tt.current = setTimeout(() => setToast(''), 2400) }

  const paidOf = (cod) => pays.filter((x) => x.pol === cod).reduce((s, x) => s + x.monto, 0)
  const rows = useMemo(() => pols.map((p) => ({ ...p, paid: paidOf(p.cod), saldo: p.total - paidOf(p.cod) })), [pols, pays]) // eslint-disable-line
  const pending = cases.filter((c) => !c.done).length
  const go = (p) => { setPage(p); setMenu(false); if (p !== 'detalle') setSelId(null) }
  const open = (cod) => { setSelId(cod); setPage('detalle'); setMenu(false) }
  const ctx = { rows, pays, setPays, setPols, cases, setCases, cat, setCat, say, go, open, narrow, setDialog, pending }

  if (!logged) {
    return (
      <div className="pz pz-loginbg" ref={root}>
        <form className="pz-login" onSubmit={(e) => { e.preventDefault(); setLogged(true); setPage('inicio') }}>
          <Logo s={64} />
          <h1>Gestor de pólizas</h1>
          <p className="pz-brand-g">Asesores de Seguros del Valle</p>
          <div className="pz-lcard">
            <label>Usuario<input defaultValue="vospina" /></label>
            <label>Contraseña<input type="password" defaultValue="demo1234" /></label>
            <button className="pz-btn pri full" type="submit"><LI n="login" size={16} /> Ingresar</button>
            <button type="button" className="pz-link" onClick={() => setDialog({ title: '¿Olvidó su contraseña?', body: 'Por seguridad, la contraseña solo la puede restablecer un administrador. Pídale que le asigne una nueva desde Catálogos → Usuarios.', ok: 'Entendido' })}>¿Olvidó su contraseña?</button>
          </div>
        </form>
        <Dialog d={dialog} close={() => setDialog(null)} />
      </div>
    )
  }

  const titles = { inicio: ['Inicio', ''], polizas: ['Pólizas', `${rows.length} de ${rows.length} pólizas`], nueva: ['Nueva póliza', 'Digitar a mano o desde el PDF con IA'], detalle: ['Póliza ' + (selId || ''), 'Detalle, abonos y saldo'], catalogos: ['Catálogos', 'Clientes, aseguradoras, ramos y asesores'], reportes: ['Reportes', 'Tablero, cartera y vencimientos'], pagos: ['Reportes de Comisiones', 'Registrar abonos y pagos'], casos: ['Casos por revisar', 'Pagos, pólizas o comisiones dudosas'], dash: ['Dashboard gerencial', 'Producción, cartera, renovaciones y metas'] }
  const active = page === 'nueva' || page === 'detalle' ? 'polizas' : page
  const sidebar = (
    <>
      <div className="pz-sbrand"><Logo s={34} /><div><b>Gestor de pólizas</b><small>Asesores del Valle</small></div></div>
      <nav>
        {NAV.map(([id, label, ic]) => (
          <button key={id} title={label} className={'pz-item' + (active === id ? ' on' : '')} onClick={() => go(id)}>
            <LI n={ic} /> <span>{label}</span>
            {id === 'casos' && pending > 0 && <em className="pz-badge">{pending}</em>}
          </button>
        ))}
      </nav>
      <div className="pz-user">
        <span className="pz-av">V</span>
        <div><b>vospina</b><small>Administradora</small></div>
        <button className="pz-ibtn" aria-label="Cerrar sesión" title="Cerrar sesión" onClick={() => setLogged(false)}><LI n="logout" size={17} /></button>
      </div>
    </>
  )

  return (
    <div className={'pz' + (narrow ? ' narrow' : '') + (rail ? ' rail' : '')} ref={root}>
      <div className="pz-test">AMBIENTE DE PRUEBAS — los datos no son reales</div>
      <div className="pz-shell">
        {!narrow && <aside className="pz-side">{sidebar}</aside>}
        {narrow && menu && (<><div className="pz-ov" onClick={() => setMenu(false)} /><aside className="pz-side pz-drawer">{sidebar}</aside></>)}
        <section className="pz-mainw">
          {narrow && (
            <header className="pz-mtop"><button className="pz-ibtn" aria-label="Menú" onClick={() => setMenu(true)}><LI n="menu" /></button><Logo s={24} /><b>Gestor de pólizas</b></header>
          )}
          {page !== 'inicio' && page !== 'detalle' && page !== 'nueva' && (
            <header className="pz-head"><div><h1>{titles[page][0]}</h1><p>{titles[page][1]}</p></div>
              {page === 'polizas' && <button className="pz-btn grn" onClick={() => go('nueva')}><LI n="plus" size={16} /> Nueva póliza</button>}
            </header>
          )}
          <div className="pz-content">
            {page === 'inicio' && <Inicio {...ctx} />}
            {page === 'polizas' && <Lista {...ctx} />}
            {page === 'nueva' && <Nueva {...ctx} />}
            {page === 'detalle' && <Detalle {...ctx} cod={selId} />}
            {page === 'catalogos' && <Catalogos {...ctx} />}
            {page === 'reportes' && <Reportes {...ctx} />}
            {page === 'pagos' && <Pagos {...ctx} />}
            {page === 'casos' && <Casos {...ctx} />}
            {page === 'dash' && <Dash {...ctx} />}
          </div>
        </section>
      </div>
      {toast && <div className="pz-toast" role="status">{toast}</div>}
      <Dialog d={dialog} close={() => setDialog(null)} />
    </div>
  )
}

function Dialog({ d, close }) {
  const [val, setVal] = useState('')
  if (!d) return null
  const ok = () => { if (d.onOk) d.onOk(val); close(); setVal('') }
  return (
    <div className="pz-modalbg" onClick={close}>
      <div className="pz-modal" role="dialog" aria-label={d.title} onClick={(e) => e.stopPropagation()}>
        <h3>{d.title}</h3>
        {d.body && <p>{d.body}</p>}
        {d.input && <textarea rows="3" placeholder={d.input} value={val} onChange={(e) => setVal(e.target.value)} />}
        {d.node}
        <div className="pz-mact">
          {d.onOk && <button className="pz-btn" onClick={() => { close(); setVal('') }}>Cancelar</button>}
          <button className={'pz-btn ' + (d.danger ? 'dng' : 'pri')} onClick={ok}>{d.ok || 'Aceptar'}</button>
        </div>
      </div>
    </div>
  )
}

function Inicio({ go, rows, pending, open }) {
  const h = 9
  const hi = h < 12 ? 'Buenos días,' : h < 19 ? 'Buenas tardes,' : 'Buenas noches,'
  const soon = rows.filter((r) => r.saldo > 0 && daysTo(r.venc) >= 0 && daysTo(r.venc) <= 30)
  const cards = [
    ['nueva', 'plus', 'grn', 'Nueva póliza', 'Digitar a mano o desde el PDF con IA'],
    ['polizas', 'receipt', 'nvy', 'Pólizas', 'Buscar, editar y controlar vencimientos'],
    ['catalogos', 'folder', 'grn', 'Catálogos', 'Clientes, asesores, aseguradoras, ramos, productos y más'],
    ['reportes', 'bars', 'nvy', 'Reportes', 'Tablero y exportar a Excel'],
    ['casos', 'clip', 'wrn', 'Casos por revisar', 'Pagos, pólizas o comisiones dudosas que hay que aclarar'],
    ['pagos', 'wallet', 'wrn', 'Reportes de Comisiones', 'Registrar abonos y pagos de comisiones'],
    ['dash', 'layout', 'grn', 'Dashboard gerencial', 'Producción, cartera, renovaciones y metas'],
  ]
  return (
    <div className="pz-home">
      <div className="pz-banner"><small>{hi}</small><b>Valeria Ospina</b><span>¿Qué desea hacer hoy?</span></div>
      {soon.length > 0 && (
        <button className="pz-alert" onClick={() => open(soon[0].cod)}><LI n="alert" size={16} /> {soon.length} {soon.length === 1 ? 'póliza vence' : 'pólizas vencen'} en 30 días y {soon.length === 1 ? 'tiene' : 'tienen'} saldo</button>
      )}
      <div className="pz-cards">
        {cards.map(([id, ic, c, t, d]) => (
          <button key={id} className="pz-acc" onClick={() => go(id)}>
            <span className={'pz-ico ' + c}><LI n={ic} size={22} /></span>
            <span className="pz-acct"><b>{t}</b><small>{d}</small></span>
            {id === 'casos' && pending > 0 && <em className="pz-badge">{pending}</em>}
            <LI n="right" size={16} />
          </button>
        ))}
      </div>
    </div>
  )
}

const state = (r) => { const d = daysTo(r.venc); return d < 0 ? ['Vencida', 'dng'] : d <= 30 ? ['Vence en ' + d + ' d', 'wrn'] : ['Vigente', 'ok'] }

function Lista({ rows, setPols, setPays, open, say, narrow, setDialog, cat }) {
  const [q, setQ] = useState('')
  const [fc, setFc] = useState('')
  const [fa, setFa] = useState('')
  const [fr, setFr] = useState('')
  const [fs, setFs] = useState('')
  const [sort, setSort] = useState({ k: 'cod', dir: -1 })
  const filtered = useMemo(() => {
    const s = q.trim().toLowerCase()
    const c = fc.trim().toLowerCase()
    const r = rows.filter((p) =>
      (!s || [p.cod, p.nro, p.cliente, p.doc, p.aseg, p.ramo, p.prod, p.ases, p.bien].join(' ').toLowerCase().includes(s)) &&
      (!c || (p.cliente + ' ' + p.doc).toLowerCase().includes(c)) && (!fa || p.aseg === fa) && (!fr || p.ramo === fr) && (!fs || p.ases === fs))
    return r.sort((a, b) => (a[sort.k] > b[sort.k] ? 1 : a[sort.k] < b[sort.k] ? -1 : 0) * sort.dir)
  }, [rows, q, fc, fa, fr, fs, sort])
  const clear = () => { setQ(''); setFc(''); setFa(''); setFr(''); setFs('') }
  const del = (p) => setDialog({ title: '¿Eliminar la póliza ' + p.cod + '?', body: `${p.cliente} · ${p.ramo}. Se borrarán también sus abonos.`, ok: 'Eliminar', danger: true, onOk: () => { setPols((l) => l.filter((x) => x.cod !== p.cod)); setPays((l) => l.filter((x) => x.pol !== p.cod)); say('Póliza ' + p.cod + ' eliminada') } })
  const th = (k, label, cls = '') => (
    <th className={cls} aria-sort={sort.k === k ? (sort.dir > 0 ? 'ascending' : 'descending') : 'none'}>
      <button onClick={() => setSort({ k, dir: sort.k === k ? -sort.dir : 1 })}>{label}{sort.k === k && <LI n={sort.dir > 0 ? 'up' : 'down'} size={12} />}</button>
    </th>
  )
  const ramos = [...new Set(rows.map((r) => r.ramo))]
  const any = q || fc || fa || fr || fs
  return (
    <div className="pz-list">
      <div className="pz-search"><LI n="search" size={16} /><input placeholder="Buscar por código, nro. póliza, cliente, documento, aseguradora, ramo, asesor…" value={q} onChange={(e) => setQ(e.target.value)} aria-label="Buscar pólizas" /></div>
      <div className="pz-filters">
        <input placeholder="Cliente o documento" value={fc} onChange={(e) => setFc(e.target.value)} aria-label="Filtrar por cliente" />
        <select value={fa} onChange={(e) => setFa(e.target.value)} aria-label="Aseguradora"><option value="">Aseguradora</option>{cat.aseg.map((a) => <option key={a}>{a}</option>)}</select>
        <select value={fr} onChange={(e) => setFr(e.target.value)} aria-label="Ramo"><option value="">Ramo</option>{ramos.map((a) => <option key={a}>{a}</option>)}</select>
        <select value={fs} onChange={(e) => setFs(e.target.value)} aria-label="Asesor"><option value="">Asesor</option>{cat.ases.map((a) => <option key={a}>{a}</option>)}</select>
      </div>
      <p className="pz-count"><span>{filtered.length} de {rows.length} pólizas · Presiona Alt+N para crear una nueva póliza</span><button className="pz-btn ghost sm" onClick={clear} disabled={!any}>Limpiar</button></p>
      {filtered.length === 0 ? (
        <div className="pz-empty">{rows.length === 0 ? 'No se encontraron pólizas' : 'Ninguna póliza coincide con los filtros'}{any && <button className="pz-btn sm" onClick={clear}>Limpiar filtros</button>}</div>
      ) : narrow ? (
        <div className="pz-pcards">
          {filtered.map((p) => (
            <article key={p.cod} className="pz-pc" onClick={() => open(p.cod)}>
              <div className="pz-pct"><b className="num">{p.nro}</b><span className={'pz-tag ' + state(p)[1]}>{state(p)[0]}</span></div>
              <div className="pz-pcl"><LI n="user" size={14} /> {p.cliente}</div>
              <div className="pz-pcl"><LI n="receipt" size={14} /> {p.aseg} · {p.ramo}</div>
              <div className="pz-pcf"><span>Vence <b className="num">{fd(p.venc)}</b></span><span>Saldo <b className={'num' + (p.saldo > 0 ? ' neg' : '')}>{money(p.saldo)}</b></span></div>
            </article>
          ))}
        </div>
      ) : (
        <div className="pz-tablew">
          <table className="pz-table">
            <thead><tr>
              {th('cod', 'Cód.')}{th('nro', 'Nro. póliza')}{th('bien', 'Bien asegurado')}{th('cliente', 'Cliente')}{th('aseg', 'Aseguradora')}{th('ramo', 'Ramo / Producto')}
              {th('ini', 'F. inicio')}{th('venc', 'F. vence')}{th('prima', 'V. prima', 'r')}{th('total', 'V. total', 'r')}{th('saldo', 'Saldo', 'r')}{th('exp', 'F. exp.')}{th('ases', 'Asesor')}{th('user', 'Usuario')}<th>Acciones</th>
            </tr></thead>
            <tbody>
              {filtered.map((p) => (
                <tr key={p.cod} onDoubleClick={() => open(p.cod)}>
                  <td className="num">{p.cod}</td><td className="num">{p.nro}</td><td>{p.bien}</td>
                  <td><b>{p.cliente}</b><small className="num">{p.doc}</small></td><td>{p.aseg}</td><td>{p.ramo}<small>{p.prod}</small></td>
                  <td className="num">{fd(p.ini)}</td><td className="num">{fd(p.venc)}<small><span className={'pz-tag ' + state(p)[1]}>{state(p)[0]}</span></small></td>
                  <td className="num r">{money(p.prima)}</td><td className="num r">{money(p.total)}</td><td className={'num r' + (p.saldo > 0 ? ' neg' : '')}>{money(p.saldo)}</td>
                  <td className="num">{fd(p.exp)}</td><td>{p.ases}</td><td>{p.user}</td>
                  <td className="acts">
                    <button className="pz-ibtn" title="Ver y editar" aria-label={'Editar ' + p.cod} onClick={() => open(p.cod)}><LI n="edit" size={16} /></button>
                    <button className="pz-ibtn" title="Abonos" aria-label={'Abonos ' + p.cod} onClick={() => open(p.cod)}><LI n="wallet" size={16} /></button>
                    <button className="pz-ibtn dng" title="Eliminar" aria-label={'Eliminar ' + p.cod} onClick={() => del(p)}><LI n="trash" size={16} /></button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}

const EMPTY = { nro: '', cliente: '', doc: '', aseg: '', ramo: '', prod: '', bien: '', ini: '', venc: '', prima: '', ases: '' }

function PolForm({ init, flagged = [], onSave, onCancel, cat, rows, editing }) {
  const [f, setF] = useState({ ...EMPTY, ...init })
  const [err, setErr] = useState({})
  const set = (k, v) => { setF((x) => ({ ...x, [k]: v })); setErr((e) => ({ ...e, [k]: '' })) }
  const submit = (e) => {
    e.preventDefault()
    const er = {}
    if (!f.nro.trim()) er.nro = 'Escriba el número de póliza'
    else if (rows.some((r) => r.nro.toLowerCase() === f.nro.trim().toLowerCase() && r.cod !== editing)) er.nro = 'Ya existe una póliza con ese número'
    if (!f.cliente.trim()) er.cliente = 'Escriba el nombre del cliente'
    if (!f.aseg) er.aseg = 'Elija la aseguradora'
    if (!f.ramo) er.ramo = 'Elija el ramo'
    if (!f.ini) er.ini = 'Falta la fecha de inicio'
    if (!f.venc) er.venc = 'Falta la fecha de vencimiento'
    else if (f.ini && f.venc <= f.ini) er.venc = 'Debe ser posterior al inicio'
    if (!(+f.prima > 0)) er.prima = 'Ingrese una prima mayor a 0'
    setErr(er)
    if (Object.keys(er).length) return
    onSave({ ...f, prima: +f.prima })
  }
  const fld = (k, label, el) => (
    <label className={'pz-f' + (flagged.includes(k) ? ' ia' : '') + (err[k] ? ' bad' : '')}>{label}{el}{err[k] && <em>{err[k]}</em>}</label>
  )
  const inp = (k, type = 'text', extra = {}) => <input type={type} value={f[k]} onChange={(e) => set(k, e.target.value)} {...extra} />
  return (
    <form className="pz-form" onSubmit={submit} noValidate>
      <div className="pz-fgrid">
        {fld('nro', 'Nro. de póliza *', inp('nro', 'text', { className: 'num' }))}
        {fld('cliente', 'Cliente *', inp('cliente'))}
        {fld('doc', 'Documento', inp('doc'))}
        {fld('aseg', 'Aseguradora *', <select value={f.aseg} onChange={(e) => set('aseg', e.target.value)}><option value="">Seleccione…</option>{cat.aseg.map((a) => <option key={a}>{a}</option>)}</select>)}
        {fld('ramo', 'Ramo *', <select value={f.ramo} onChange={(e) => set('ramo', e.target.value)}><option value="">Seleccione…</option>{Object.keys(RAMOS0).map((a) => <option key={a}>{a}</option>)}</select>)}
        {fld('prod', 'Producto', inp('prod'))}
        {fld('bien', 'Bien asegurado', inp('bien'))}
        {fld('ases', 'Asesor', <select value={f.ases} onChange={(e) => set('ases', e.target.value)}><option value="">Seleccione…</option>{cat.ases.map((a) => <option key={a}>{a}</option>)}</select>)}
        {fld('ini', 'Fecha de inicio *', inp('ini', 'date'))}
        {fld('venc', 'Fecha de vencimiento *', inp('venc', 'date'))}
        {fld('prima', 'Valor prima (COP) *', inp('prima', 'number', { min: 0, className: 'num' }))}
        <div className="pz-f"><span>Valor total (prima + IVA 19%)</span><output className="num pz-out">{+f.prima > 0 ? money(f.prima * 1.19) : '—'}</output></div>
      </div>
      <div className="pz-fact"><button type="button" className="pz-btn" onClick={onCancel}>Cancelar</button><button className="pz-btn pri" type="submit">{editing ? 'Guardar cambios' : 'Guardar póliza'}</button></div>
    </form>
  )
}

const PDF = { nro: 'PAR-771204', cliente: 'Julián Mendoza', doc: 'CC 1.018.222.909', aseg: ASEG0[1], ramo: 'Autos', prod: 'Todo riesgo', bien: 'Renault Duster · placa HJT 330', ini: '2026-11-10', venc: '2027-11-10', prima: 2140000, ases: ASES0[0] }

function Nueva({ rows, cat, setPols, open, go, say }) {
  const [tab, setTab] = useState('ia')
  const [stage, setStage] = useState('idle')
  const [step, setStep] = useState(0)
  const timer = useRef()
  const STEPS = ['Subiendo el PDF…', 'Leyendo el texto de la póliza…', 'Identificando asegurado, vigencia y valores…']
  const run = () => {
    setStage('reading'); setStep(0)
    let i = 0
    timer.current = setInterval(() => { i++; if (i >= STEPS.length) { clearInterval(timer.current); setStage('done') } else setStep(i) }, 600)
  }
  const save = (data) => {
    const n = Math.max(...rows.map((r) => +r.cod.slice(2)), 1000) + 1
    const cod = 'P-' + n
    setPols((l) => [{ ...data, cod, venc: data.venc, total: Math.round(data.prima * 1.19), exp: TODAY, reg: TODAY, user: 'vospina', pagado: 0 }, ...l])
    say('Póliza ' + cod + ' guardada')
    open(cod)
  }
  return (
    <div className="pz-new">
      <button className="pz-back" onClick={() => go('polizas')}><LI n="left" size={16} /> Pólizas</button>
      <h1 className="pz-h1">Nueva póliza</h1>
      <div className="pz-tabs" role="tablist">
        <button role="tab" aria-selected={tab === 'ia'} className={tab === 'ia' ? 'on' : ''} onClick={() => setTab('ia')}><LI n="sparkle" size={15} /> Nueva con IA</button>
        <button role="tab" aria-selected={tab === 'man'} className={tab === 'man' ? 'on' : ''} onClick={() => setTab('man')}>Digitar a mano</button>
      </div>
      {tab === 'man' && <div className="pz-card pad"><PolForm cat={cat} rows={rows} onSave={save} onCancel={() => go('polizas')} /></div>}
      {tab === 'ia' && (
        <div className="pz-card pad">
          {stage === 'idle' && (
            <div className="pz-drop">
              <LI n="upload" size={28} />
              <b>Suba el PDF o la imagen de la póliza</b>
              <small>La IA lee el documento y llena el formulario; usted revisa antes de guardar.</small>
              <button className="pz-btn pri" onClick={run}><LI n="file" size={16} /> Usar PDF de ejemplo</button>
              <span className="pz-pdfname">Poliza_Autos_Mendoza.pdf · 184 KB</span>
            </div>
          )}
          {stage === 'reading' && (
            <div className="pz-drop" role="status"><div className="pz-spin" /><b>{STEPS[step]}</b><div className="pz-prog"><i style={{ width: ((step + 1) / STEPS.length) * 100 + '%' }} /></div></div>
          )}
          {stage === 'done' && (
            <>
              <div className="pz-iaok"><LI n="check" size={16} /> Poliza_Autos_Mendoza.pdf leído. Revise los datos marcados en verde antes de guardar.</div>
              <PolForm init={PDF} flagged={Object.keys(PDF)} cat={cat} rows={rows} onSave={save} onCancel={() => setStage('idle')} />
            </>
          )}
        </div>
      )}
    </div>
  )
}

function Detalle({ cod, rows, pays, setPays, setPols, go, say, setDialog, cat }) {
  const p = rows.find((r) => r.cod === cod)
  const [edit, setEdit] = useState(false)
  const [monto, setMonto] = useState('')
  const [fecha, setFecha] = useState(TODAY)
  const [medio, setMedio] = useState('Transferencia')
  const [err, setErr] = useState('')
  if (!p) return <div className="pz-empty">La póliza ya no existe. <button className="pz-btn sm" onClick={() => go('polizas')}>Volver a la lista</button></div>
  const mine = pays.filter((x) => x.pol === p.cod).sort((a, b) => a.date.localeCompare(b.date))
  const pct = Math.min(100, Math.round((p.paid / p.total) * 100))
  const addPay = (e) => {
    e.preventDefault()
    const v = +monto
    if (!(v > 0)) return setErr('Escriba un valor mayor a 0')
    if (v > p.saldo) return setErr('El abono no puede superar el saldo (' + money(p.saldo) + ')')
    if (!fecha) return setErr('Falta la fecha del abono')
    setPays((l) => [...l, { id: Math.max(0, ...l.map((x) => x.id)) + 1, pol: p.cod, date: fecha, monto: v, medio, user: 'vospina' }])
    setMonto(''); setErr('')
    say('Abono de ' + money(v) + ' registrado')
  }
  const del = () => setDialog({ title: '¿Eliminar la póliza ' + p.cod + '?', body: `${p.cliente} · ${p.ramo}. Se borrarán también sus abonos.`, ok: 'Eliminar', danger: true, onOk: () => { setPols((l) => l.filter((x) => x.cod !== p.cod)); setPays((l) => l.filter((x) => x.pol !== p.cod)); say('Póliza eliminada'); go('polizas') } })
  const st = state(p)
  return (
    <div className="pz-det">
      <button className="pz-back" onClick={() => go('polizas')}><LI n="left" size={16} /> Pólizas</button>
      <div className="pz-dh"><div><h1 className="pz-h1">{p.cliente}</h1><p className="pz-sub"><span className="num">{p.nro}</span> · {p.aseg}</p></div>
        <div className="pz-dact"><span className={'pz-tag ' + st[1]}>{st[0]}</span><button className="pz-btn sm" onClick={() => setEdit(true)}><LI n="edit" size={15} /> Editar</button><button className="pz-btn sm dngo" onClick={del}><LI n="trash" size={15} /> Eliminar</button></div></div>
      <div className="pz-dgrid">
        <div className="pz-card pad">
          <h3>Datos de la póliza</h3>
          <dl className="pz-dl">
            <dt>Código</dt><dd className="num">{p.cod}</dd><dt>Documento</dt><dd className="num">{p.doc || '—'}</dd><dt>Ramo / Producto</dt><dd>{p.ramo} · {p.prod}</dd>
            <dt>Bien asegurado</dt><dd>{p.bien || '—'}</dd><dt>Vigencia</dt><dd className="num">{fd(p.ini)} a {fd(p.venc)}</dd><dt>Asesor</dt><dd>{p.ases || '—'}</dd><dt>Expedida</dt><dd className="num">{fd(p.exp)}</dd>
          </dl>
        </div>
        <div className="pz-card pad">
          <h3>Estado de cuenta</h3>
          <div className="pz-kv"><span>Valor prima</span><b className="num">{money(p.prima)}</b></div>
          <div className="pz-kv"><span>Valor total (IVA incl.)</span><b className="num">{money(p.total)}</b></div>
          <div className="pz-kv"><span>Pagado</span><b className="num ok">{money(p.paid)}</b></div>
          <div className="pz-prog"><i style={{ width: pct + '%' }} /></div>
          <div className="pz-kv big"><span>Saldo por pagar</span><b className={'num' + (p.saldo > 0 ? ' neg' : ' ok')}>{money(p.saldo)}</b></div>
        </div>
      </div>
      <div className="pz-card">
        <div className="pz-cab">Abonos registrados</div>
        {mine.length === 0 ? <div className="pz-empty s">Sin abonos registrados</div> : (
          <table className="pz-table s"><thead><tr><th>Fecha</th><th>Medio</th><th>Registró</th><th className="r">Valor</th></tr></thead>
            <tbody>{mine.map((x) => <tr key={x.id}><td className="num">{fd(x.date)}</td><td>{x.medio}</td><td>{x.user}</td><td className="num r">{money(x.monto)}</td></tr>)}</tbody></table>
        )}
        {p.saldo > 0 ? (
          <form className="pz-abono" onSubmit={addPay} noValidate>
            <label className="pz-f">Valor del abono<input type="number" min="0" className="num" placeholder="0" value={monto} onChange={(e) => { setMonto(e.target.value); setErr('') }} aria-label="Valor del abono" /></label>
            <label className="pz-f">Fecha<input type="date" value={fecha} onChange={(e) => setFecha(e.target.value)} /></label>
            <label className="pz-f">Medio<select value={medio} onChange={(e) => setMedio(e.target.value)}>{MEDIOS.map((m) => <option key={m}>{m}</option>)}</select></label>
            <button type="button" className="pz-btn" onClick={() => setMonto(String(p.saldo))}>Todo el saldo</button>
            <button className="pz-btn pri" type="submit"><LI n="wallet" size={16} /> Registrar abono</button>
            {err && <em className="pz-err" role="alert">{err}</em>}
          </form>
        ) : <div className="pz-paid"><LI n="check" size={16} /> Póliza pagada por completo</div>}
      </div>
      {edit && (
        <div className="pz-modalbg" onClick={() => setEdit(false)}>
          <div className="pz-modal wide" role="dialog" aria-label="Editar póliza" onClick={(e) => e.stopPropagation()}>
            <h3>Editar póliza {p.cod}</h3>
            <PolForm editing={p.cod} init={{ ...p, prima: p.prima }} cat={cat} rows={rows} onCancel={() => setEdit(false)}
              onSave={(d) => { setPols((l) => l.map((x) => (x.cod === p.cod ? { ...x, ...d, total: Math.round(d.prima * 1.19) } : x))); setEdit(false); say('Cambios guardados') }} />
          </div>
        </div>
      )}
    </div>
  )
}

function Catalogos({ rows, cat, setCat, say }) {
  const [tab, setTab] = useState('clientes')
  const [v, setV] = useState('')
  const clientes = [...new Map(rows.map((r) => [r.cliente, r])).values()]
  const add = (e) => {
    e.preventDefault()
    const t = v.trim()
    if (!t) return
    const key = tab === 'aseg' ? 'aseg' : 'ases'
    if (cat[key].includes(t)) return say('Ya existe en el catálogo')
    setCat({ ...cat, [key]: [...cat[key], t] }); setV(''); say('Agregado: ' + t)
  }
  const TABS = [['clientes', 'Clientes'], ['aseg', 'Aseguradoras'], ['ramos', 'Ramos y productos'], ['ases', 'Asesores']]
  return (
    <div>
      <div className="pz-tabs">{TABS.map(([k, l]) => <button key={k} className={tab === k ? 'on' : ''} onClick={() => { setTab(k); setV('') }}>{l}</button>)}</div>
      <div className="pz-card">
        {(tab === 'aseg' || tab === 'ases') && <form className="pz-addrow" onSubmit={add}><input placeholder={tab === 'aseg' ? 'Nueva aseguradora' : 'Nuevo asesor'} value={v} onChange={(e) => setV(e.target.value)} aria-label="Nuevo elemento" /><button className="pz-btn pri sm" type="submit"><LI n="plus" size={15} /> Agregar</button></form>}
        {tab === 'clientes' && <table className="pz-table s"><thead><tr><th>Cliente</th><th>Documento</th><th className="r">Pólizas</th></tr></thead><tbody>{clientes.map((c) => <tr key={c.cliente}><td><b>{c.cliente}</b></td><td className="num">{c.doc}</td><td className="num r">{rows.filter((r) => r.cliente === c.cliente).length}</td></tr>)}</tbody></table>}
        {tab === 'aseg' && <ul className="pz-ul">{cat.aseg.map((a) => <li key={a}><b>{a}</b><span>{rows.filter((r) => r.aseg === a).length} pólizas</span></li>)}</ul>}
        {tab === 'ases' && <ul className="pz-ul">{cat.ases.map((a) => <li key={a}><b>{a}</b><span>{rows.filter((r) => r.ases === a).length} pólizas</span></li>)}</ul>}
        {tab === 'ramos' && <ul className="pz-ul">{Object.entries(RAMOS0).map(([r, ps]) => <li key={r}><b>{r}</b><span>{ps.join(', ')}</span></li>)}</ul>}
      </div>
    </div>
  )
}

const sum = (a, f) => a.reduce((s, x) => s + f(x), 0)
const groupBy = (a, f) => { const m = {}; a.forEach((x) => { const k = f(x); (m[k] ||= []).push(x) }); return Object.entries(m) }
const Stat = ({ l, v, c = '' }) => <div className={'pz-stat ' + c}><b className="num">{v}</b><span>{l}</span></div>

function Reportes({ rows, say }) {
  const [tab, setTab] = useState('aseg')
  const vig = rows.filter((r) => daysTo(r.venc) >= 0)
  const venc = rows.filter((r) => daysTo(r.venc) < 0)
  const bucket = (a, b) => rows.filter((r) => daysTo(r.venc) >= a && daysTo(r.venc) <= b && r.saldo > 0)
  const key = { aseg: 'aseg', ramo: 'ramo', ases: 'ases' }[tab]
  const grp = groupBy(rows, (r) => r[key]).map(([k, l]) => [k, l.length, sum(l, (x) => x.prima), sum(l, (x) => x.saldo)]).sort((a, b) => b[2] - a[2])
  const exportCsv = () => {
    const head = ['Cod', 'Nro poliza', 'Cliente', 'Aseguradora', 'Ramo', 'F. vence', 'Prima', 'Total', 'Saldo']
    const lines = rows.map((r) => [r.cod, r.nro, r.cliente, r.aseg, r.ramo, r.venc, r.prima, r.total, r.saldo].map((c) => '"' + String(c).replace(/"/g, '""') + '"').join(','))
    const a = document.createElement('a')
    a.href = URL.createObjectURL(new Blob(['﻿' + [head.join(','), ...lines].join('\n')], { type: 'text/csv' }))
    a.download = 'polizas.csv'; a.click()
    say('Reporte exportado (polizas.csv)')
  }
  return (
    <div className="pz-rep">
      <div className="pz-stats">
        <Stat l="Total pólizas" v={rows.length} /><Stat l="Vigentes" v={vig.length} c="ok" /><Stat l="Vencidas" v={venc.length} c="dng" /><Stat l="Prima total" v={money(sum(rows, (r) => r.prima))} /><Stat l="Cartera por recaudar" v={money(sum(rows, (r) => r.saldo))} c="wrn" />
      </div>
      <h3 className="pz-h3">Por vencer (con saldo pendiente)</h3>
      <div className="pz-buckets">
        {[['0 – 30 días', 0, 30, 'dng'], ['31 – 60 días', 31, 60, 'wrn'], ['61 – 90 días', 61, 90, 'amb']].map(([l, a, b, c]) => {
          const list = bucket(a, b)
          return <div key={l} className={'pz-bk ' + c}><b>{l}</b><span className="num">{list.length} pólizas</span><span className="num">{money(sum(list, (x) => x.saldo))}</span><small>{list.map((x) => x.cliente).slice(0, 2).join(', ') || 'Sin vencimientos para mostrar'}</small></div>
        })}
      </div>
      <div className="pz-card">
        <div className="pz-cab"><div className="pz-tabs mini">{[['aseg', 'Aseguradora'], ['ramo', 'Ramo'], ['ases', 'Asesor']].map(([k, l]) => <button key={k} className={tab === k ? 'on' : ''} onClick={() => setTab(k)}>{l}</button>)}</div>
          <button className="pz-btn sm" onClick={exportCsv}><LI n="download" size={15} /> Exportar a Excel</button></div>
        <table className="pz-table s"><thead><tr><th>{{ aseg: 'Aseguradora', ramo: 'Ramo', ases: 'Asesor' }[tab]}</th><th className="r">Pólizas</th><th className="r">Prima</th><th className="r">Saldo</th></tr></thead>
          <tbody>{grp.map(([k, n, pr, sa]) => <tr key={k}><td><b>{k}</b></td><td className="num r">{n}</td><td className="num r">{money(pr)}</td><td className={'num r' + (sa > 0 ? ' neg' : '')}>{money(sa)}</td></tr>)}</tbody></table>
      </div>
    </div>
  )
}

function Pagos({ rows, pays, setPays, say }) {
  const [pol, setPol] = useState('')
  const [monto, setMonto] = useState('')
  const [medio, setMedio] = useState('Transferencia')
  const [err, setErr] = useState('')
  const open = rows.filter((r) => r.saldo > 0)
  const list = [...pays].sort((a, b) => b.date.localeCompare(a.date) || b.id - a.id)
  const submit = (e) => {
    e.preventDefault()
    const p = rows.find((r) => r.cod === pol)
    if (!p) return setErr('Elija la póliza')
    if (!(+monto > 0)) return setErr('Escriba un valor mayor a 0')
    if (+monto > p.saldo) return setErr('El abono supera el saldo (' + money(p.saldo) + ')')
    setPays((l) => [...l, { id: Math.max(0, ...l.map((x) => x.id)) + 1, pol, date: TODAY, monto: +monto, medio, user: 'vospina' }])
    setMonto(''); setErr(''); say('Abono registrado en ' + pol)
  }
  return (
    <div className="pz-pagos">
      <form className="pz-card pad pz-abono flat" onSubmit={submit} noValidate>
        <label className="pz-f grow">Póliza<select value={pol} onChange={(e) => { setPol(e.target.value); setErr('') }} aria-label="Póliza"><option value="">Seleccione una póliza con saldo…</option>{open.map((r) => <option key={r.cod} value={r.cod}>{r.cod} · {r.cliente} · saldo {money(r.saldo)}</option>)}</select></label>
        <label className="pz-f">Valor<input type="number" min="0" className="num" value={monto} onChange={(e) => { setMonto(e.target.value); setErr('') }} aria-label="Valor del pago" /></label>
        <label className="pz-f">Medio<select value={medio} onChange={(e) => setMedio(e.target.value)}>{MEDIOS.map((m) => <option key={m}>{m}</option>)}</select></label>
        <button className="pz-btn pri" type="submit">Registrar abono</button>
        {err && <em className="pz-err" role="alert">{err}</em>}
      </form>
      <div className="pz-card">
        <div className="pz-cab">Abonos recientes · {list.length}</div>
        <div className="pz-tablew inner"><table className="pz-table s"><thead><tr><th>Fecha</th><th>Póliza</th><th>Cliente</th><th>Medio</th><th className="r">Valor</th><th className="r">Comisión (10%)</th></tr></thead>
          <tbody>{list.slice(0, 12).map((x) => { const p = rows.find((r) => r.cod === x.pol); return <tr key={x.id}><td className="num">{fd(x.date)}</td><td className="num">{x.pol}</td><td>{p ? p.cliente : '—'}</td><td>{x.medio}</td><td className="num r">{money(x.monto)}</td><td className="num r">{money(x.monto * 0.1 / 1.19)}</td></tr> })}</tbody></table></div>
      </div>
    </div>
  )
}

function Casos({ cases, setCases, open, say, setDialog }) {
  const [tab, setTab] = useState('p')
  const list = cases.filter((c) => !!c.done === (tab === 'r'))
  const resolve = (c) => setDialog({ title: 'Marcar como resuelto', body: c.detalle, input: 'Nota de cómo se resolvió (opcional)', ok: 'Marcar como resuelto', onOk: (nota) => { setCases((l) => l.map((x) => (x.id === c.id ? { ...x, done: true, nota } : x))); say('Caso resuelto') } })
  return (
    <div>
      <div className="pz-tabs"><button className={tab === 'p' ? 'on' : ''} onClick={() => setTab('p')}>Pendientes ({cases.filter((c) => !c.done).length})</button><button className={tab === 'r' ? 'on' : ''} onClick={() => setTab('r')}>Resueltos ({cases.filter((c) => c.done).length})</button></div>
      {list.length === 0 && <div className="pz-empty">{tab === 'p' ? 'No hay casos pendientes.' : 'No hay casos resueltos.'}</div>}
      <div className="pz-caselist">
        {list.map((c) => (
          <article key={c.id} className="pz-case">
            <div><span className={'pz-tag ' + (c.tipo === 'Pago dudoso' ? 'wrn' : c.tipo === 'Comisión' ? 'nvy' : 'dng')}>{c.tipo}</span> <button className="pz-link inline num" onClick={() => open(c.pol)}>{c.pol}</button></div>
            <p>{c.detalle}</p>
            {c.nota && <small>Nota: {c.nota}</small>}
            {!c.done && <button className="pz-btn sm" onClick={() => resolve(c)}><LI n="check" size={15} /> Resolver</button>}
          </article>
        ))}
      </div>
    </div>
  )
}

function Bars({ data, fmt = money, h = 120, color = '#1C4870' }) {
  const max = Math.max(...data.map((d) => d[1]), 1)
  return (
    <svg className="pz-bars" viewBox={`0 0 ${data.length * 56} ${h + 22}`} role="img" aria-label="Gráfico de barras">
      {data.map(([k, v], i) => {
        const bh = Math.round((v / max) * h)
        return <g key={k}><rect x={i * 56 + 10} y={h - bh} width="36" height={bh} rx="4" fill={color}><title>{k}: {fmt(v)}</title></rect><text x={i * 56 + 28} y={h + 15} textAnchor="middle">{k}</text></g>
      })}
    </svg>
  )
}

function Dash({ rows, pays, pending }) {
  const [per, setPer] = useState('anio')
  const [tab, setTab] = useState('res')
  const PER = [['mes', 'Este mes'], ['trim', 'Trimestre'], ['anio', 'Este año'], ['todo', 'Todo']]
  const inPer = (r) => (per === 'todo' ? true : per === 'anio' ? r.exp.slice(0, 4) === '2026' : per === 'trim' ? daysTo(r.exp) >= -92 : ym(r.exp) === '2026-11')
  const sel = rows.filter(inPer)
  const prima = sum(sel, (r) => r.prima)
  const recaudo = sum(sel, (r) => r.paid)
  const cartera = sum(sel, (r) => r.saldo)
  const months = [...new Set(rows.map((r) => ym(r.exp)))].sort().slice(-6)
  const byMonth = months.map((m) => [mlabel(m + '-01'), sum(rows.filter((r) => ym(r.exp) === m && inPer(r)), (r) => r.prima)])
  const byAseg = groupBy(sel, (r) => r.aseg).map(([k, l]) => [k, sum(l, (x) => x.prima)]).sort((a, b) => b[1] - a[1])
  const top = groupBy(sel, (r) => r.ases).map(([k, l]) => [k, sum(l, (x) => x.prima)]).sort((a, b) => b[1] - a[1]).slice(0, 5)
  const maxA = Math.max(...byAseg.map((x) => x[1]), 1)
  const ren = Array.from({ length: 6 }, (_, i) => { const d = new Date(T0.getFullYear(), T0.getMonth() + i, 1); const k = d.toISOString().slice(0, 7); return [mlabel(k + '-01'), rows.filter((r) => ym(r.venc) === k).length] })
  const aging = [['Al día', (r) => daysTo(r.ini) > -30], ['30-90 días', (r) => daysTo(r.ini) <= -30 && daysTo(r.ini) > -90], ['Más de 90', (r) => daysTo(r.ini) <= -90]].map(([l, f]) => [l, sum(rows.filter((r) => r.saldo > 0 && f(r)), (r) => r.saldo)])
  const act = rows.filter((r) => daysTo(r.venc) >= 0 && daysTo(r.venc) <= 30).length
  return (
    <div className="pz-dash">
      <div className="pz-filterbar"><div className="pz-chips">{PER.map(([k, l]) => <button key={k} className={'pz-chip' + (per === k ? ' on' : '')} onClick={() => setPer(k)}>{l}</button>)}</div><small>Comparar con: período anterior</small></div>
      <div className="pz-tabs u">{[['res', 'Resumen'], ['car', 'Cartera y recaudo'], ['ren', 'Renovaciones']].map(([k, l]) => <button key={k} className={tab === k ? 'on' : ''} onClick={() => setTab(k)}>{l}</button>)}</div>
      {tab === 'res' && (
        <>
          <div className="pz-stats">
            <Stat l="Prima emitida" v={money(prima)} /><Stat l="Pólizas emitidas" v={sel.length} /><Stat l="Prima promedio" v={sel.length ? money(prima / sel.length) : '—'} /><Stat l="Recaudo de prima" v={money(recaudo)} c="ok" /><Stat l="Cartera por recaudar" v={money(cartera)} c="wrn" />
          </div>
          <div className="pz-two">
            <div className="pz-card pad"><h3>Prima emitida por mes</h3><Bars data={byMonth} /></div>
            <div className="pz-card pad"><h3>Atención del día</h3><p className="pz-att"><LI n="alert" size={16} /> <b>{act}</b> {act === 1 ? 'póliza vence' : 'pólizas vencen'} en 30 días</p><p className="pz-att"><LI n="clip" size={16} /> <b>{pending}</b> {pending === 1 ? 'caso por revisar' : 'casos por revisar'}</p></div>
          </div>
          <div className="pz-two">
            <div className="pz-card pad"><h3>Prima por aseguradora</h3>{byAseg.length === 0 ? <small>Sin datos en este período</small> : byAseg.map(([k, v], i) => <div key={k} className="pz-hb"><span>{k}</span><i style={{ width: (v / maxA) * 100 + '%', background: PAL[i] }} /><b className="num">{money(v)}</b></div>)}</div>
            <div className="pz-card pad"><h3>Top 5 asesores</h3>{top.length === 0 ? <small>Sin datos en este período</small> : top.map(([k, v], i) => <div key={k} className="pz-kv"><span>{i + 1}. {k}</span><b className="num">{money(v)}</b></div>)}</div>
          </div>
        </>
      )}
      {tab === 'car' && (
        <div className="pz-two">
          <div className="pz-card pad"><h3>Antigüedad de la cartera por recaudar</h3><Bars data={aging} color="#B7791B" /></div>
          <div className="pz-card pad"><h3>Recaudo de prima</h3><div className="pz-kv"><span>Recaudado</span><b className="num ok">{money(sum(rows, (r) => r.paid))}</b></div><div className="pz-kv"><span>Por recaudar</span><b className="num neg">{money(sum(rows, (r) => r.saldo))}</b></div><div className="pz-kv"><span>Abonos registrados</span><b className="num">{pays.length}</b></div></div>
        </div>
      )}
      {tab === 'ren' && <div className="pz-card pad"><h3>Vencimientos de los próximos 6 meses</h3><Bars data={ren} fmt={(v) => v + ' pólizas'} color="#1E9B4E" /></div>}
    </div>
  )
}
