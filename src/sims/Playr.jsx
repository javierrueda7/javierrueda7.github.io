import { useMemo, useReducer, useState } from 'react'
import { TabBar, useToast, cop } from '../lib/ui.jsx'

const ME = 'Tú (Camilo)'
const NAMES = ['Mateo R.', 'Santi P.', 'Dani G.', 'Juanjo L.', 'Nico B.', 'Esteban M.', 'Andrés C.', 'Fabio T.', 'Leo V.', 'Sebas H.']

const VENUES = [
  { id: 'v1', name: 'La Bombonera Norte', zone: 'Cabecera', price: 120000, x: 28, y: 32 },
  { id: 'v2', name: 'Cancha El Potrero', zone: 'Cañaveral', price: 90000, x: 66, y: 58 },
  { id: 'v3', name: 'Sintética La 45', zone: 'Centro', price: 105000, x: 42, y: 74 },
]
const HOURS = ['6 pm', '7 pm', '8 pm', '9 pm', '10 pm']
const DAYS = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom']
const SEED_HEAT = [
  [1, 2, 3, 2, 0], [0, 1, 2, 2, 1], [1, 1, 3, 3, 1], [1, 2, 3, 3, 2],
  [2, 3, 3, 3, 3], [3, 3, 3, 2, 2], [1, 2, 2, 1, 0],
]

const initial = {
  games: [
    { id: 1, venue: 'La Bombonera Norte', when: 'Hoy · 8:00 pm', format: 'Fútbol 5', cap: 10, joined: NAMES.slice(0, 7), result: null },
    { id: 2, venue: 'Cancha El Potrero', when: 'Mañana · 7:00 pm', format: 'Fútbol 7', cap: 14, joined: NAMES.slice(2, 5), result: null },
    { id: 3, venue: 'Sintética La 45', when: 'Hace 2 días', format: 'Fútbol 5', cap: 10, joined: [], result: { a: 4, b: 3, A: ['Mateo R.', 'Santi P.', 'Dani G.', 'Nico B.', ME], B: ['Juanjo L.', 'Esteban M.', 'Andrés C.', 'Fabio T.', 'Leo V.'] } },
    { id: 4, venue: 'La Bombonera Norte', when: 'Hace 6 días', format: 'Fútbol 5', cap: 10, joined: [], result: { a: 2, b: 2, A: ['Mateo R.', 'Juanjo L.', 'Dani G.', 'Sebas H.', 'Leo V.'], B: ['Santi P.', ME, 'Nico B.', 'Fabio T.', 'Andrés C.'] } },
    { id: 5, venue: 'Cancha El Potrero', when: 'Hace 9 días', format: 'Fútbol 5', cap: 10, joined: [], result: { a: 1, b: 5, A: ['Esteban M.', 'Andrés C.', 'Dani G.', 'Sebas H.', 'Leo V.'], B: ['Mateo R.', ME, 'Nico B.', 'Fabio T.', 'Santi P.'] } },
  ],
  bookings: [], // {venue, d, h}
  nextId: 6,
}

function reducer(s, a) {
  switch (a.type) {
    case 'toggleJoin':
      return {
        ...s,
        games: s.games.map((g) => {
          if (g.id !== a.id) return g
          const inn = g.joined.includes(ME)
          if (!inn && g.joined.length >= g.cap) return g
          return { ...g, joined: inn ? g.joined.filter((n) => n !== ME) : [...g.joined, ME] }
        }),
      }
    case 'create':
      return { ...s, nextId: s.nextId + 1, games: [{ id: s.nextId, joined: [ME], result: null, ...a.game }, ...s.games] }
    case 'result':
      return {
        ...s,
        games: s.games.map((g) => {
          if (g.id !== a.id) return g
          const A = g.joined.filter((_, i) => i % 2 === 0)
          const B = g.joined.filter((_, i) => i % 2 === 1)
          return { ...g, result: { a: a.a, b: a.b, A, B } }
        }),
      }
    case 'book':
      return { ...s, bookings: [...s.bookings, a.b] }
    default:
      return s
  }
}

function table(games) {
  const t = {}
  const add = (n, pts, w, d, l) => {
    t[n] ??= { n, pj: 0, g: 0, e: 0, p: 0, pts: 0 }
    t[n].pj++; t[n].pts += pts; t[n].g += w; t[n].e += d; t[n].p += l
  }
  games.filter((g) => g.result).forEach(({ result: r }) => {
    const [pa, pb, wa, wb, d] = r.a > r.b ? [3, 0, 1, 0, 0] : r.a < r.b ? [0, 3, 0, 1, 0] : [1, 1, 0, 0, 1]
    r.A.forEach((n) => add(n, pa, wa, d, wb))
    r.B.forEach((n) => add(n, pb, wb, d, wa))
  })
  return Object.values(t).sort((x, y) => y.pts - x.pts || y.g - x.g || x.n.localeCompare(y.n))
}

function GameCard({ g, onOpen, dispatch }) {
  const inn = g.joined.includes(ME)
  const full = g.joined.length >= g.cap
  return (
    <div className="card">
      <div className="row">
        <strong>{g.venue}</strong>
        {g.result ? <span className="pill ok">{g.result.a} - {g.result.b}</span> : <span className={`pill ${full ? 'warn' : ''}`}>{g.joined.length}/{g.cap}</span>}
      </div>
      <div className="sub">{g.format} · {g.when}</div>
      <div className="row" style={{ marginTop: 10 }}>
        <button className="sbtn ghost sm" onClick={() => onOpen(g.id)}>Ver partido</button>
        {!g.result && (
          <button className="sbtn sm" disabled={!inn && full} onClick={() => dispatch({ type: 'toggleJoin', id: g.id })}>
            {inn ? 'Salirme' : full ? 'Lleno' : 'Apuntarme'}
          </button>
        )}
      </div>
    </div>
  )
}

function Detail({ g, dispatch, back, toast }) {
  const [a, setA] = useState(0)
  const [b, setB] = useState(0)
  return (
    <>
      <button className="sbtn ghost sm" style={{ alignSelf: 'flex-start' }} onClick={back}>← Volver</button>
      <div className="card">
        <strong>{g.venue}</strong>
        <div className="sub">{g.format} · {g.when}</div>
      </div>
      {g.result ? (
        <div className="card">
          <div className="h">Resultado</div>
          <div style={{ fontSize: 32, fontWeight: 800, textAlign: 'center', margin: '6px 0' }}>{g.result.a} <span className="sub">-</span> {g.result.b}</div>
          <div className="row" style={{ alignItems: 'flex-start' }}>
            <div><div className="h">Equipo A</div>{g.result.A.map((n) => <div key={n} className="sub">{n}</div>)}</div>
            <div style={{ textAlign: 'right' }}><div className="h">Equipo B</div>{g.result.B.map((n) => <div key={n} className="sub">{n}</div>)}</div>
          </div>
        </div>
      ) : (
        <>
          <div className="card">
            <div className="h">Jugadores ({g.joined.length}/{g.cap})</div>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, marginTop: 8 }}>
              {g.joined.map((n) => <span key={n} className={`pill ${n === ME ? 'ok' : ''}`}>{n}</span>)}
              {g.joined.length === 0 && <span className="sub">Nadie todavía</span>}
            </div>
          </div>
          <div className="card">
            <div className="h">Registrar resultado</div>
            <div className="row" style={{ margin: '8px 0' }}>
              <label className="field">Equipo A<input type="number" min="0" max="30" value={a} onChange={(e) => setA(+e.target.value)} /></label>
              <label className="field">Equipo B<input type="number" min="0" max="30" value={b} onChange={(e) => setB(+e.target.value)} /></label>
            </div>
            <button className="sbtn" style={{ width: '100%' }} disabled={g.joined.length < 2} onClick={() => { dispatch({ type: 'result', id: g.id, a, b }); toast('Resultado guardado. Mira la tabla.') }}>
              Guardar y actualizar tabla
            </button>
            {g.joined.length < 2 && <div className="sub" style={{ marginTop: 6 }}>Se necesitan al menos 2 jugadores.</div>}
          </div>
        </>
      )}
    </>
  )
}

function Create({ dispatch, done }) {
  const [f, setF] = useState({ venue: VENUES[0].name, when: 'Sábado · 6:00 pm', format: 'Fútbol 5' })
  const cap = f.format === 'Fútbol 5' ? 10 : f.format === 'Fútbol 7' ? 14 : 22
  const set = (k) => (e) => setF({ ...f, [k]: e.target.value })
  return (
    <>
      <div className="h">Crear partido</div>
      <label className="field">Cancha<select value={f.venue} onChange={set('venue')}>{VENUES.map((v) => <option key={v.id}>{v.name}</option>)}</select></label>
      <label className="field">Cuándo<select value={f.when} onChange={set('when')}>{['Sábado · 6:00 pm', 'Sábado · 8:00 pm', 'Domingo · 10:00 am', 'Viernes · 9:00 pm'].map((x) => <option key={x}>{x}</option>)}</select></label>
      <label className="field">Formato<select value={f.format} onChange={set('format')}>{['Fútbol 5', 'Fútbol 7', 'Fútbol 11'].map((x) => <option key={x}>{x}</option>)}</select></label>
      <div className="sub">Cupos: {cap} jugadores</div>
      <button className="sbtn" onClick={() => { dispatch({ type: 'create', game: { ...f, cap } }); done() }}>Publicar partido</button>
    </>
  )
}

function Courts({ s, dispatch, toast }) {
  const [sel, setSel] = useState(VENUES[0].id)
  const v = VENUES.find((x) => x.id === sel)
  const taken = (d, h) => SEED_HEAT[d][h] >= 3 || s.bookings.some((b) => b.venue === sel && b.d === d && b.h === h)
  return (
    <>
      <div className="h">Canchas cerca de ti</div>
      <div className="card" style={{ position: 'relative', height: 150, background: 'linear-gradient(#e8efe6,#dfe8dc)', overflow: 'hidden' }}>
        <svg width="100%" height="100%" style={{ position: 'absolute', inset: 0 }} aria-hidden="true">
          <path d="M0 90 Q120 50 340 110" stroke="#c9d5c4" strokeWidth="10" fill="none" />
          <path d="M120 0 Q150 80 90 160" stroke="#c9d5c4" strokeWidth="7" fill="none" />
        </svg>
        {VENUES.map((x) => (
          <button key={x.id} aria-label={x.name} onClick={() => setSel(x.id)} style={{ position: 'absolute', left: `${x.x}%`, top: `${x.y}%`, transform: 'translate(-50%,-100%)', border: 0, background: x.id === sel ? 'var(--app)' : '#fff', color: x.id === sel ? '#fff' : '#333', borderRadius: 99, padding: '3px 9px', fontSize: 11, fontWeight: 600, boxShadow: '0 1px 4px rgba(0,0,0,.25)' }}>
            {cop(x.price / 1000)}k
          </button>
        ))}
      </div>
      <div className="card">
        <div className="row"><strong>{v.name}</strong><span className="pill">{v.zone}</span></div>
        <div className="sub">{cop(v.price)} la hora · toca una franja libre para reservar</div>
      </div>
      <div className="card" style={{ overflowX: 'auto' }}>
        <table style={{ borderCollapse: 'separate', borderSpacing: 3, width: '100%', fontSize: 11 }}>
          <thead><tr><th />{DAYS.map((d) => <th key={d} style={{ fontWeight: 500, color: '#777' }}>{d}</th>)}</tr></thead>
          <tbody>
            {HOURS.map((h, hi) => (
              <tr key={h}>
                <td style={{ color: '#777', whiteSpace: 'nowrap' }}>{h}</td>
                {DAYS.map((d, di) => {
                  const t = taken(di, hi)
                  return (
                    <td key={d}>
                      <button disabled={t} aria-label={`${d} ${h}`} onClick={() => { dispatch({ type: 'book', b: { venue: sel, d: di, h: hi } }); toast(`Reservada: ${d} ${h}`) }} style={{ width: '100%', height: 26, border: 0, borderRadius: 5, background: t ? '#e4e4df' : '#cfe9d8', cursor: t ? 'default' : 'pointer' }} />
                    </td>
                  )
                })}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  )
}

function Owner({ s }) {
  const grid = useMemo(() => SEED_HEAT.map((row, d) => row.map((n, h) => n + s.bookings.filter((b) => b.d === d && b.h === h).length)), [s.bookings])
  const total = grid.flat().reduce((a, b) => a + b, 0)
  const income = total * 105000 / 3
  const color = (n) => `color-mix(in srgb, var(--app) ${Math.min(n, 4) * 24 + 4}%, #f0f0ec)`
  return (
    <>
      <div className="h">Panel de dueño · La Bombonera Norte</div>
      <div className="row">
        <div className="card" style={{ flex: 1 }}><div className="sub">Reservas semana</div><strong style={{ fontSize: 22 }}>{Math.round(total / 3)}</strong></div>
        <div className="card" style={{ flex: 1 }}><div className="sub">Ingresos</div><strong style={{ fontSize: 22 }}>{cop(income)}</strong></div>
      </div>
      <div className="card">
        <div className="h">Mapa de calor de ocupación</div>
        <table style={{ borderCollapse: 'separate', borderSpacing: 3, width: '100%', fontSize: 11, marginTop: 6 }}>
          <tbody>
            {HOURS.map((h, hi) => (
              <tr key={h}>
                <td style={{ color: '#777', whiteSpace: 'nowrap' }}>{h}</td>
                {DAYS.map((d, di) => <td key={d} title={`${d} ${h}: ${grid[di][hi]}`} style={{ height: 26, borderRadius: 5, background: color(grid[di][hi]) }} />)}
              </tr>
            ))}
            <tr><td />{DAYS.map((d) => <td key={d} style={{ textAlign: 'center', color: '#777' }}>{d}</td>)}</tr>
          </tbody>
        </table>
        <div className="sub" style={{ marginTop: 8 }}>Reserva una franja en la pestaña Canchas y vuelve: el mapa se actualiza.</div>
      </div>
    </>
  )
}

export default function Playr() {
  const [s, dispatch] = useReducer(reducer, initial)
  const [tab, setTab] = useState('home')
  const [open, setOpen] = useState(null)
  const [toast, toastNode] = useToast()
  const tabs = [
    { id: 'home', label: 'Partidos', icon: 'ball' },
    { id: 'create', label: 'Crear', icon: 'home' },
    { id: 'table', label: 'Tabla', icon: 'users' },
    { id: 'courts', label: 'Canchas', icon: 'pin' },
    { id: 'owner', label: 'Dueño', icon: 'chart' },
  ]
  const standings = table(s.games)
  const game = s.games.find((g) => g.id === open)
  const go = (t) => { setTab(t); setOpen(null) }

  return (
    <div className="app">
      <div className="app-top"><h3>Playr</h3><small>Bucaramanga · datos de ejemplo</small></div>
      <div className="app-body">
        {tab === 'home' && !game && (
          <>
            <div className="h">Próximos y recientes</div>
            {s.games.map((g) => <GameCard key={g.id} g={g} onOpen={setOpen} dispatch={dispatch} />)}
          </>
        )}
        {tab === 'home' && game && <Detail g={game} dispatch={dispatch} back={() => setOpen(null)} toast={toast} />}
        {tab === 'create' && <Create dispatch={dispatch} done={() => { go('home'); toast('Partido publicado') }} />}
        {tab === 'table' && (
          <>
            <div className="h">Tabla · Los Jueves FC</div>
            <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
              <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 12 }}>
                <thead><tr style={{ background: '#f1f2ee', color: '#666' }}><th style={{ textAlign: 'left', padding: 8 }}>Jugador</th><th>PJ</th><th>G</th><th>E</th><th>P</th><th>Pts</th></tr></thead>
                <tbody>
                  {standings.map((r, i) => (
                    <tr key={r.n} style={{ borderTop: '1px solid #eee', background: r.n === ME ? '#eaf5ee' : undefined, textAlign: 'center' }}>
                      <td style={{ textAlign: 'left', padding: '7px 8px' }}>{i + 1}. {r.n}</td><td>{r.pj}</td><td>{r.g}</td><td>{r.e}</td><td>{r.p}</td><td><strong>{r.pts}</strong></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </>
        )}
        {tab === 'courts' && <Courts s={s} dispatch={dispatch} toast={toast} />}
        {tab === 'owner' && <Owner s={s} />}
      </div>
      {toastNode}
      <TabBar tabs={tabs} value={tab} onChange={go} />
    </div>
  )
}
