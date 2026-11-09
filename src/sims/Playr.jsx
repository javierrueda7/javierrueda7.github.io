import { useMemo, useState } from 'react'
import './playr.css'

// Todo es inventado: jugadores, canchas, grupos y chats. La interfaz sigue la app real.
const PATHS = {
  home: 'M3 11l9-8 9 8M5 10v10h5v-6h4v6h5V10',
  search: 'M11 4a7 7 0 100 14 7 7 0 000-14zm9 16l-4-4',
  chat: 'M21 12a8 8 0 01-11.5 7.2L4 20l1-4.4A8 8 0 1121 12z',
  user: 'M12 12a4 4 0 100-8 4 4 0 000 8zm-8 9c0-4 4-6 8-6s8 2 8 6',
  plus: 'M12 5v14M5 12h14',
  bell: 'M6 9a6 6 0 1112 0c0 6 2 7 2 7H4s2-1 2-7zm4 10a2 2 0 004 0',
  cup: 'M8 4h8v5a4 4 0 01-8 0V4zM8 6H4v1a4 4 0 004 4m8-5h4v1a4 4 0 01-4 4M12 13v4m-4 3h8',
  users: 'M9 11a3 3 0 100-6 3 3 0 000 6zm-6 8c0-3 3-5 6-5s6 2 6 5m1-8a3 3 0 100-6m5 14c0-2-1.5-3.6-4-4.4',
  filter: 'M4 7h10M18 7h2M4 17h2M10 17h10M14 4v6M6 14v6',
  map: 'M9 4L3 6v14l6-2 6 2 6-2V4l-6 2-6-2zm0 0v14m6-12v14',
  list: 'M8 6h13M8 12h13M8 18h13M3 6h.01M3 12h.01M3 18h.01',
  cal: 'M4 7h16v13H4zM4 11h16M8 3v4M16 3v4',
  pin: 'M12 21s7-6 7-11a7 7 0 10-14 0c0 5 7 11 7 11zm0-8a3 3 0 100-6 3 3 0 000 6z',
  cash: 'M3 7h18v10H3zM12 9.5a2.5 2.5 0 100 5 2.5 2.5 0 000-5z',
  back: 'M19 12H5m6-6l-6 6 6 6',
  send: 'M22 2L11 13M22 2l-7 20-4-9-9-4 20-7z',
  clock: 'M12 3a9 9 0 100 18 9 9 0 000-18zm0 5v5l3 2',
  edit: 'M4 20h4L19 9l-4-4L4 16v4z',
  key: 'M15 7a4 4 0 11-3.5 6L4 20v-3H1v-3h3l2-2a4 4 0 019-5z',
}
const Ico = ({ n }) => <svg viewBox="0 0 24 24" className="pl-ico" aria-hidden="true"><path d={PATHS[n]} /></svg>

const NAMES = ['Mateo Salcedo', 'Laura Beltrán', 'Camilo Ortiz', 'Daniela Prieto', 'Nicolás Mejía', 'Valentina Rojas', 'Esteban Gil', 'Sara Quintero', 'Felipe Arango', 'Juliana Cruz', 'Sebastián Rey', 'Mariana Peña']
const COLORS = ['#047857', '#c2410c', '#1d4ed8', '#6d28d9', '#0f766e', '#be185d']
const initials = (n) => n.split(' ').map((p) => p[0]).slice(0, 2).join('')
const Av = ({ name, size = 40 }) => <span className="pl-av" style={{ width: size, height: size, background: COLORS[(name.charCodeAt(0) + name.length) % COLORS.length], fontSize: size * 0.38 }}>{initials(name)}</span>
const LV = { Principiante: ['#d6f3e8', '#047857'], Intermedio: ['#fdecd0', '#b45309'], Avanzado: ['#fde0e0', '#b91c1c'] }

const SEED = [
  { id: 1, title: 'Futbolito de oficina', fmt: 'Fútbol 6', cap: 12, when: 'mar 10 nov · 18:00', place: 'Cancha El Mirador', addr: 'Cra. 10 #20-30', price: 8000, lv: 'Principiante', code: 'PL4821', joined: NAMES.slice(0, 5), x: 34, y: 38 },
  { id: 2, title: 'Partido amistoso', fmt: 'Fútbol 7', cap: 14, when: 'mar 10 nov · 19:00', place: 'Cancha Los Pinos', addr: 'Calle 45 #12-08', price: 10000, lv: 'Principiante', code: 'PL7305', joined: NAMES.slice(1, 9), x: 62, y: 56 },
  { id: 3, title: 'Banquitas con los parceros', fmt: 'Fútbol 5', cap: 10, when: 'mié 11 nov · 20:00', place: 'Sintética La 45', addr: 'Av. 27 #45-10', price: 9000, lv: 'Intermedio', code: 'PL1190', joined: NAMES.slice(4, 8), x: 48, y: 74 },
  { id: 4, title: 'Pachanga de jueves', fmt: 'Fútbol 5', cap: 10, when: 'jue 12 nov · 21:00', place: 'Cancha El Mirador', addr: 'Cra. 10 #20-30', price: 12000, lv: 'Avanzado', code: 'PL5562', joined: NAMES.slice(2, 10), x: 22, y: 58 },
]
const GROUPS = [
  { id: 1, name: 'Parceros del Sábado', desc: 'Partido fijo todos los sábados a las 6 pm.', members: NAMES.slice(0, 8) },
  { id: 2, name: 'Futbolito Cabecera', desc: 'Para los que viven por el norte de la ciudad.', members: NAMES.slice(3, 10) },
  { id: 3, name: 'Los de la Oficina', desc: 'Jueves después del trabajo.', members: NAMES.slice(5, 12) },
]
const CHATS = [
  { id: 1, who: 'Mateo Salcedo', ago: 'hace 43 minutos', unread: 2, msgs: [['in', 'Falta uno para el sábado, ¿te sumas?'], ['in', 'Dale, llevo el balón']] },
  { id: 2, who: 'Laura Beltrán', ago: 'hace 5 horas', unread: 1, msgs: [['in', 'Gracias por el pase en el último partido']] },
  { id: 3, who: 'Camilo Ortiz', ago: 'hace 1 día', unread: 0, msgs: [['out', '¿Hay cupo a las 8?'], ['in', 'Sí, hay cupo a las 8 pm']] },
]
const NOTIFS = [
  { t: 'Nuevo jugador en tu partido', d: 'Laura Beltrán se unió a Futbolito de oficina.', ago: 'hace 12 minutos', k: 'p' },
  { t: 'Te invitaron a un grupo', d: 'Mateo Salcedo te invitó a Parceros del Sábado.', ago: 'hace 1 hora', k: 's' },
  { t: 'Recordatorio', d: 'Tu partido empieza mañana a las 6:00 pm.', ago: 'hace 3 horas', k: 'p' },
]
const cupos = (g) => g.cap - g.joined.length

export default function Playr() {
  const [theme, setTheme] = useState('light')
  const [tab, setTab] = useState('home')
  const [scr, setScr] = useState(null) // {n:'game'|'groups'|'group'|'notifs'|'chat'|'create'|'ranking', id}
  const [games, setGames] = useState(SEED)
  const [mine, setMine] = useState([1])
  const [view, setView] = useState('list')
  const [filter, setFilter] = useState('all')
  const [mapSel, setMapSel] = useState(null)
  const [q, setQ] = useState('')
  const [pos, setPos] = useState('Todas')
  const [gtab, setGtab] = useState('mine')
  const [mtab, setMtab] = useState('Amigos')
  const [chats, setChats] = useState(CHATS)
  const [draft, setDraft] = useState('')
  const [ntab, setNtab] = useState('Todas')
  const [toast, setToast] = useState('')
  const [form, setForm] = useState({ title: '', fmt: 'Fútbol 5', place: 'Cancha El Mirador', price: 8000, lv: 'Principiante' })
  const [joinedGroups, setJoinedGroups] = useState([1, 2, 3])
  const [banner, setBanner] = useState(true)

  const say = (m) => { setToast(m); setTimeout(() => setToast(''), 2000) }
  const me = 'Jugador Demo'
  const go = (t) => { setTab(t); setScr(null) }
  const toggleJoin = (id) => {
    const g = games.find((x) => x.id === id)
    const inn = mine.includes(id)
    if (!inn && cupos(g) === 0) return say('El partido está lleno')
    setGames(games.map((x) => (x.id === id ? { ...x, joined: inn ? x.joined.filter((n) => n !== me) : [...x.joined, me] } : x)))
    setMine(inn ? mine.filter((i) => i !== id) : [...mine, id])
    say(inn ? 'Saliste del partido' : '¡Te uniste al partido!')
  }
  const list = filter === 'mine' ? games.filter((g) => mine.includes(g.id)) : games
  const game = games.find((g) => g.id === scr?.id)
  const people = useMemo(() => NAMES.filter((n) => n.toLowerCase().includes(q.toLowerCase())), [q])

  const Header = ({ back, title, right }) => (
    <div className="pl-head" style={{ padding: '38px 14px 10px' }}>
      <div className="pl-row" style={{ gap: 10 }}>
        {back && <button className="pl-ic" aria-label="Volver" onClick={back}><Ico n="back" /></button>}
        <b style={{ fontSize: 18 }}>{title}</b>
      </div>
      {right}
    </div>
  )

  let content
  if (scr?.n === 'game' && game) {
    const inn = mine.includes(game.id)
    const lv = LV[game.lv]
    content = (
      <>
        <div className="pl-hero">
          <button className="pl-ic" aria-label="Volver" onClick={() => setScr(null)} style={{ position: 'absolute', left: 12, top: 36 }}><Ico n="back" /></button>
          <div style={{ fontSize: 46 }}>⚽</div>
          <h2>{game.title}</h2>
          <span className="pl-chip">Fútbol</span> <span className="pl-chip">{game.fmt}</span> <span className="pl-chip">{game.lv}</span>
        </div>
        <div className="pl-body">
          <div className="pl-stat"><div><b>{game.joined.length}/{game.cap}</b><span>Jugadores</span></div><div><b>{cupos(game)}</b><span>Cupos</span></div><div><b>${game.price.toLocaleString('es-CO')}</b><span>Por persona</span></div></div>
          <div className="pl-card" style={{ display: 'grid', gap: 10 }}>
            <div className="pl-row"><span><Ico n="key" /> Código <b style={{ marginLeft: 6, letterSpacing: 1 }}>{game.code}</b></span></div>
            {[['Fecha y hora', game.when], ['Categoría', 'Mixto'], ['Lugar', game.place], ['Dirección', game.addr]].map(([k, v]) => <div key={k}><div className="pl-sub">{k}</div><div style={{ fontSize: 14 }}>{v}</div></div>)}
          </div>
          <div className="pl-card">
            <div className="pl-h" style={{ marginBottom: 8 }}>Jugadores ({game.joined.length})</div>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>{game.joined.map((n) => <span key={n} className="pl-chip"><Av name={n} size={20} /> {n.split(' ')[0]}</span>)}</div>
          </div>
          <span className="pl-lv" style={{ background: lv[0], color: lv[1], alignSelf: 'flex-start' }}>Nivel {game.lv}</span>
          <button className={`pl-btn ${inn ? 'out' : ''}`} onClick={() => toggleJoin(game.id)} disabled={!inn && cupos(game) === 0}>{inn ? 'Salirme del partido' : cupos(game) === 0 ? 'Partido lleno' : 'Unirme al partido'}</button>
          {inn && <button className="pl-btn out" onClick={() => setScr({ n: 'chat', id: 'game' })}>Chat del partido</button>}
        </div>
      </>
    )
  } else if (scr?.n === 'create') {
    content = (
      <>
        <Header back={() => setScr(null)} title="Crear partido" />
        <div className="pl-body">
          <label className="pl-sub">Nombre del partido<input className="pl-in" value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} placeholder="Ej. Pichanga de viernes" /></label>
          <label className="pl-sub">Formato<select className="pl-in" value={form.fmt} onChange={(e) => setForm({ ...form, fmt: e.target.value })}>{['Fútbol 5', 'Fútbol 6', 'Fútbol 7', 'Fútbol 11'].map((x) => <option key={x}>{x}</option>)}</select></label>
          <label className="pl-sub">Cancha<select className="pl-in" value={form.place} onChange={(e) => setForm({ ...form, place: e.target.value })}>{['Cancha El Mirador', 'Cancha Los Pinos', 'Sintética La 45'].map((x) => <option key={x}>{x}</option>)}</select></label>
          <div className="pl-sub">Nivel</div>
          <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>{Object.keys(LV).map((l) => <button key={l} className={`pl-pill ${form.lv === l ? 'on' : ''}`} onClick={() => setForm({ ...form, lv: l })}>{l}</button>)}</div>
          <label className="pl-sub">Precio por persona<input className="pl-in" type="number" value={form.price} onChange={(e) => setForm({ ...form, price: +e.target.value })} /></label>
          <button className="pl-btn" disabled={!form.title.trim()} onClick={() => {
            const id = Date.now()
            const cap = +form.fmt.replace(/\D/g, '') * 2
            setGames([{ id, title: form.title.trim(), fmt: form.fmt, cap, when: 'sáb 14 nov · 18:00', place: form.place, addr: 'Dirección de ejemplo', price: form.price, lv: form.lv, code: 'PL' + String(id).slice(-4), joined: [me], x: 50, y: 50 }, ...games])
            setMine([...mine, id]); setForm({ ...form, title: '' }); setView('list'); setFilter('all'); go('home'); say('Partido creado')
          }}>Publicar partido</button>
        </div>
      </>
    )
  } else if (scr?.n === 'groups') {
    content = (
      <>
        <Header back={() => setScr(null)} title="Grupos" />
        <div className="pl-body">
          <div style={{ display: 'flex', gap: 8 }}>{[['mine', 'Mis grupos'], ['disc', 'Descubrir']].map(([id, l]) => <button key={id} className={`pl-pill ${gtab === id ? 'on' : ''}`} style={{ flex: 1 }} onClick={() => setGtab(id)}>{l}</button>)}</div>
          {GROUPS.filter((g) => (gtab === 'mine') === joinedGroups.includes(g.id)).map((g) => (
            <div key={g.id} className="pl-card pl-row" style={{ alignItems: 'flex-start' }}>
              <button style={{ all: 'unset', cursor: 'pointer', display: 'flex', gap: 12, flex: 1 }} onClick={() => setScr({ n: 'group', id: g.id })}>
                <Av name={g.name} size={48} />
                <span><b>{g.name}</b><br /><span className="pl-chip" style={{ padding: '1px 8px', margin: '3px 0' }}>⚽ Fútbol</span><br /><span className="pl-sub">{g.desc}</span></span>
              </button>
              {gtab === 'disc' && <button className="pl-pill solid" onClick={() => { setJoinedGroups([...joinedGroups, g.id]); say('Te uniste al grupo') }}>Unirme</button>}
            </div>
          ))}
          {GROUPS.filter((g) => (gtab === 'mine') === joinedGroups.includes(g.id)).length === 0 && <div className="pl-sub" style={{ textAlign: 'center', padding: 24 }}>{gtab === 'mine' ? 'Aún no estás en ningún grupo.' : 'Ya estás en todos los grupos.'}</div>}
        </div>
      </>
    )
  } else if (scr?.n === 'group') {
    const g = GROUPS.find((x) => x.id === scr.id)
    content = (
      <>
        <Header back={() => setScr({ n: 'groups' })} title={g.name} />
        <div className="pl-body">
          <div className="pl-card"><div className="pl-sub">{g.desc}</div></div>
          <div className="pl-h">Miembros ({g.members.length})</div>
          {g.members.map((n) => <div key={n} className="pl-card pl-row" style={{ padding: 10 }}><span className="pl-row" style={{ gap: 10 }}><Av name={n} size={34} />{n}</span></div>)}
          <button className="pl-btn" onClick={() => setScr({ n: 'create' })}>Crear partido del grupo</button>
        </div>
      </>
    )
  } else if (scr?.n === 'notifs') {
    content = (
      <>
        <Header back={() => setScr(null)} title="Notificaciones" right={<button className="pl-pill" style={{ color: '#fff', borderColor: 'transparent' }} onClick={() => say('Todas marcadas como leídas')}>Marcar todo</button>} />
        <div className="pl-body">
          <div style={{ display: 'flex', gap: 6 }}>{['Todas', 'Partidos', 'Social'].map((x) => <button key={x} className={`pl-pill ${ntab === x ? 'solid' : ''}`} onClick={() => setNtab(x)}>{x}</button>)}</div>
          {NOTIFS.filter((n) => ntab === 'Todas' || (ntab === 'Partidos') === (n.k === 'p')).map((n) => (
            <div key={n.t} className="pl-card" style={{ display: 'flex', gap: 10 }}><span className="pl-ic" style={{ background: 'var(--pl)', color: 'var(--p)', flex: 'none' }}><Ico n="bell" /></span><div><b>{n.t}</b><div className="pl-sub">{n.d}</div><div className="pl-sub" style={{ marginTop: 2 }}>{n.ago}</div></div></div>
          ))}
        </div>
      </>
    )
  } else if (scr?.n === 'ranking') {
    content = (
      <>
        <Header back={() => setScr(null)} title="Ranking del mes" />
        <div className="pl-body">
          {NAMES.slice(0, 8).map((n, i) => <div key={n} className="pl-card pl-row" style={{ padding: 10 }}><span className="pl-row" style={{ gap: 10 }}><b style={{ width: 18 }}>{i + 1}</b><Av name={n} size={34} />{n}</span><b>{18 - i * 2} goles</b></div>)}
        </div>
      </>
    )
  } else if (scr?.n === 'chat') {
    const c = scr.id === 'game' ? { who: game ? game.title : 'Partido', msgs: [['in', 'Bienvenidos al chat del partido ⚽'], ['in', '¿Alguien lleva petos?']] } : chats.find((x) => x.id === scr.id)
    const msgs = scr.id === 'game' ? (chats.find((x) => x.id === 'g')?.msgs ?? c.msgs) : c.msgs
    const send = (e) => {
      e.preventDefault()
      if (!draft.trim()) return
      if (scr.id === 'game') setChats((l) => [...l.filter((x) => x.id !== 'g'), { id: 'g', who: c.who, msgs: [...msgs, ['out', draft.trim()]] }])
      else setChats((l) => l.map((x) => (x.id === c.id ? { ...x, unread: 0, msgs: [...x.msgs, ['out', draft.trim()]] } : x)))
      setDraft('')
    }
    content = (
      <>
        <Header back={() => setScr(scr.id === 'game' ? { n: 'game', id: game.id } : null)} title={c.who} />
        <div className="pl-body">{msgs.map(([d, t], i) => <div key={i} className={`pl-msg ${d === 'out' ? 'me' : ''}`}>{t}</div>)}</div>
        <form onSubmit={send} className="pl-row" style={{ padding: 10, background: 'var(--card)', borderTop: '1px solid var(--dv)' }}>
          <input className="pl-in" aria-label="Mensaje" placeholder="Escribe un mensaje…" value={draft} onChange={(e) => setDraft(e.target.value)} />
          <button className="pl-ic" style={{ background: 'var(--p)' }} aria-label="Enviar"><Ico n="send" /></button>
        </form>
      </>
    )
  } else if (tab === 'home') {
    content = (
      <>
        <div className="pl-head">
          <span className="pl-word">PlayR</span>
          <div className="pl-row" style={{ gap: 8 }}>
            <button className="pl-ic" aria-label="Ranking" onClick={() => setScr({ n: 'ranking' })} style={{ color: '#ffc94d' }}><Ico n="cup" /></button>
            <button className="pl-ic" aria-label="Grupos" onClick={() => setScr({ n: 'groups' })}><Ico n="users" /></button>
            <button className="pl-ic" aria-label="Notificaciones" onClick={() => setScr({ n: 'notifs' })}><Ico n="bell" /><span className="pl-badge">3</span></button>
          </div>
        </div>
        <div className="pl-body">
          <div className="pl-row">
            <div style={{ whiteSpace: 'nowrap', minWidth: 0 }}><b style={{ fontSize: 15 }}>Hola, Jugador 👋</b><div style={{ color: 'var(--p)', fontWeight: 600, fontSize: 12 }}>Todas las ciudades ⌄</div></div>
            <div className="pl-row" style={{ gap: 5 }}>
              <button className="pl-pill" style={{ background: 'var(--card)', boxShadow: 'var(--sh)', borderColor: 'transparent', padding: '6px 10px' }} onClick={() => go('search')}>Reservar</button>
              <button className="pl-ic" aria-label="Filtros" style={{ background: 'var(--pl)', color: 'var(--p)', width: 32, height: 32 }} onClick={() => say('Filtros por nivel, formato y fecha')}><Ico n="filter" /></button>
              <button className="pl-ic" aria-label={view === 'list' ? 'Ver mapa' : 'Ver lista'} style={{ background: 'var(--pl)', color: 'var(--p)', width: 32, height: 32 }} onClick={() => setView(view === 'list' ? 'map' : 'list')}><Ico n={view === 'list' ? 'map' : 'list'} /></button>
            </div>
          </div>
          {banner && <div className="pl-banner"><span>⚽</span><div style={{ flex: 1 }}><b>¡Estás debutando en Playr!</b><div className="pl-sub" style={{ color: 'var(--tx)' }}>En esta temporada de debut todo es gratis y los más activos ganarán premios.</div></div><button style={{ all: 'unset', cursor: 'pointer', fontSize: 16 }} aria-label="Cerrar aviso" onClick={() => setBanner(false)}>✕</button></div>}
          <div style={{ display: 'flex', gap: 8 }}>
            <button className={`pl-pill ${filter === 'all' ? 'solid' : ''}`} style={{ flex: 1, padding: 12 }} onClick={() => setFilter('all')}>Partidos existentes</button>
            <button className={`pl-pill alt ${filter === 'mine' ? 'on' : ''}`} style={{ flex: 1, padding: 12 }} onClick={() => setFilter('mine')}>Tus próximos partidos<span className="pl-badge" style={{ background: 'var(--card)', color: 'var(--s)' }}>{mine.length}</span></button>
          </div>
          {view === 'list' && list.map((g) => {
            const lv = LV[g.lv]
            return (
              <button key={g.id} className="pl-card" style={{ textAlign: 'left', border: 0, cursor: 'pointer', display: 'grid', gap: 8 }} onClick={() => setScr({ n: 'game', id: g.id })}>
                <div className="pl-row"><span className="pl-chip">⚽ {g.fmt}</span><span className="pl-lv" style={{ background: lv[0], color: lv[1] }}>{g.lv}</span></div>
                <b style={{ fontSize: 16 }}>{g.title}</b>
                <div className="pl-sub"><Ico n="cal" /> {g.when}</div>
                <div className="pl-sub"><Ico n="pin" /> {g.place}</div>
                <div className="pl-bar2"><i style={{ width: `${(g.joined.length / g.cap) * 100}%` }} /></div>
                <div className="pl-row"><span className="pl-sub">{g.joined.length}/{g.cap} jugadores</span><span className="pl-chip">{cupos(g)} cupos</span></div>
                <b style={{ color: 'var(--s)' }}>${g.price.toLocaleString('es-CO')}/persona</b>
              </button>
            )
          })}
          {view === 'list' && list.length === 0 && <div className="pl-sub" style={{ textAlign: 'center', padding: 24 }}>Aún no te has unido a ningún partido.</div>}
          {view === 'map' && (
            <div className="pl-map">
              <svg viewBox="0 0 300 380" width="100%" height="100%" preserveAspectRatio="none" aria-hidden="true">
                <rect width="300" height="380" fill="none" />
                <path d="M0 120 Q90 90 170 150 T300 130" stroke="#fff" strokeWidth="14" fill="none" opacity=".8" />
                <path d="M80 0 Q120 140 70 380" stroke="#fff" strokeWidth="10" fill="none" opacity=".7" />
                <path d="M0 270 Q150 230 300 300" stroke="#fff" strokeWidth="9" fill="none" opacity=".7" />
                <ellipse cx="230" cy="70" rx="46" ry="30" fill="#b9d9a8" opacity=".6" />
              </svg>
              {games.map((g) => <button key={g.id} className={`pl-pin ${mapSel === g.id ? 'on' : ''}`} style={{ left: `${g.x}%`, top: `${g.y}%` }} aria-label={g.title} onClick={() => setMapSel(g.id)}><span>⚽</span></button>)}
              {mapSel && (() => { const g = games.find((x) => x.id === mapSel); return <button className="pl-card" style={{ position: 'absolute', left: 10, right: 10, bottom: 10, textAlign: 'left', border: 0 }} onClick={() => setScr({ n: 'game', id: g.id })}><b>{g.title}</b><div className="pl-sub">{g.when} · {cupos(g)} cupos</div></button> })()}
            </div>
          )}
        </div>
      </>
    )
  } else if (tab === 'search') {
    content = (
      <>
        <div style={{ background: 'var(--card)', padding: '38px 14px 10px', flex: 'none', display: 'grid', gap: 8 }}>
          <b style={{ fontSize: 24 }}>Buscar</b>
          <div className="pl-banner" style={{ borderRadius: 12, padding: '8px 12px' }}><Ico n="key" /> <span className="pl-sub" style={{ color: 'var(--tx)' }}>¿Tienes el código de un partido? Escríbelo aquí</span></div>
          <input className="pl-in" aria-label="Buscar jugadores" placeholder="Busca jugadores…" value={q} onChange={(e) => setQ(e.target.value)} />
          <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>{['Todas', 'Portero', 'Defensa', 'Mediocampista', 'Delantero'].map((x) => <button key={x} className={`pl-pill ${pos === x ? 'on' : ''}`} style={{ padding: '4px 10px' }} onClick={() => setPos(x)}>{x}</button>)}</div>
        </div>
        <div className="pl-body">
          <div className="pl-sub">{people.length} jugadores</div>
          {people.map((n, i) => <div key={n} className="pl-card pl-row"><span className="pl-row" style={{ gap: 12 }}><Av name={n} size={44} /><span><b>{n}</b><br /><span className="pl-sub">@{n.split(' ')[0].toLowerCase()} · Bucaramanga · {24 + (i % 9)} años</span><br /><b style={{ color: 'var(--p)', fontSize: 12 }}>{8 + (i * 3) % 12} partidos jugados</b></span></span></div>)}
          {people.length === 0 && <div className="pl-sub" style={{ textAlign: 'center', padding: 24 }}>Ningún jugador coincide con «{q}».</div>}
        </div>
      </>
    )
  } else if (tab === 'msgs') {
    const tabs = ['Amigos', 'Grupos', 'Equipos', 'Partidos', 'Reservas']
    content = (
      <>
        <div style={{ background: 'var(--card)', padding: '38px 14px 10px', flex: 'none' }}>
          <div className="pl-row"><b style={{ fontSize: 18, flex: 1, textAlign: 'center' }}>Mensajes</b></div>
          <div style={{ display: 'flex', gap: 6, overflowX: 'auto', marginTop: 8 }}>{tabs.map((x) => <button key={x} className={`pl-pill ${mtab === x ? 'solid' : ''}`} style={{ flex: 'none' }} onClick={() => setMtab(x)}>{x}{x === 'Amigos' && <span className="pl-badge" style={{ position: 'static', display: 'inline-grid', marginLeft: 5 }}>{chats.reduce((s, c) => s + (c.unread || 0), 0)}</span>}</button>)}</div>
        </div>
        <div className="pl-body">
          {mtab === 'Amigos' ? chats.filter((c) => c.id !== 'g').map((c) => (
            <button key={c.id} className="pl-card pl-row" style={{ border: 0, textAlign: 'left', cursor: 'pointer' }} onClick={() => { setChats(chats.map((x) => (x.id === c.id ? { ...x, unread: 0 } : x))); setScr({ n: 'chat', id: c.id }) }}>
              <span className="pl-row" style={{ gap: 12 }}><Av name={c.who} size={44} /><span><b>{c.who}</b><br /><span className="pl-sub">{c.msgs[c.msgs.length - 1][1]}</span></span></span>
              <span style={{ textAlign: 'right' }}><span className="pl-sub">{c.ago}</span>{c.unread > 0 && <><br /><span className="pl-badge" style={{ position: 'static', display: 'inline-grid', background: 'var(--p)' }}>{c.unread}</span></>}</span>
            </button>
          )) : <div className="pl-sub" style={{ textAlign: 'center', padding: 30 }}>No tienes conversaciones en «{mtab}» todavía.</div>}
        </div>
      </>
    )
  } else {
    const modes = [['light', 'Claro'], ['dark', 'Oscuro']]
    content = (
      <>
        <div className="pl-hero" style={{ paddingBottom: 14 }}>
          <span className="pl-av" style={{ width: 76, height: 76, background: '#047857', fontSize: 28, margin: '0 auto' }}>JD</span>
          <h2 style={{ marginBottom: 2 }}>Jugador Demo</h2>
          <div style={{ opacity: .85 }}>@jugadordemo</div>
          <div style={{ marginTop: 6 }}><span className="pl-chip">🌱 Nuevo</span> <span className="pl-chip">🎯 Muy confiable (100%)</span></div>
        </div>
        <div className="pl-body">
          <div className="pl-stat" style={{ '--n': 4 }}>{[['6', 'Partidos'], ['6', 'Goles'], ['2', 'Asist.'], ['11', 'Amigos']].map(([a, b]) => <div key={b}><b>{a}</b><span>{b}</span></div>)}</div>
          <div className="pl-h">Palmarés · 3 premios mensuales</div>
          <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>{['1 × Balón de Oro', '1 × Bota de Oro', '1 × Rey de las Asistencias'].map((x) => <span key={x} className="pl-pill">{x}</span>)}</div>
          <div className="pl-card"><div className="pl-h" style={{ marginBottom: 8 }}>Insignias</div><span className="pl-chip" style={{ padding: '10px 14px', borderRadius: 14 }}>👟 Primeros pasos</span></div>
          <div className="pl-card pl-row"><span><div className="pl-h">Mi perfil de juego</div><span className="pl-lv" style={{ background: LV.Intermedio[0], color: LV.Intermedio[1] }}>Intermedio</span> <span className="pl-sub">⚽ Delantero</span></span><Ico n="edit" /></div>
          <div className="pl-card">
            <div className="pl-h" style={{ marginBottom: 8 }}>Apariencia</div>
            <div style={{ display: 'flex', gap: 8 }}>{modes.map(([id, l]) => <button key={id} className={`pl-pill ${theme === id ? 'solid' : ''}`} style={{ flex: 1, padding: 12 }} onClick={() => setTheme(id)}>{theme === id ? '✓ ' : ''}{l}</button>)}</div>
          </div>
        </div>
      </>
    )
  }

  const showBar = !scr || scr.n === 'chat' ? !scr : false
  const tabs = [['home', 'Inicio', 'home'], ['search', 'Buscar', 'search'], null, ['msgs', 'Mensajes', 'chat'], ['me', 'Perfil', 'user']]
  const unread = chats.reduce((s, c) => s + (c.unread || 0), 0)

  return (
    <div className={`pl ${theme === 'dark' ? 'dark' : ''}`}>
      {content}
      {toast && <div className="pl-toast" role="status">{toast}</div>}
      {showBar && (
        <div className="pl-bar" role="tablist">
          {tabs.map((t, i) => t ? (
            <button key={t[0]} role="tab" aria-selected={tab === t[0]} className={`pl-tab ${tab === t[0] ? 'on' : ''}`} onClick={() => go(t[0])}>
              <svg viewBox="0 0 24 24" aria-hidden="true"><path d={PATHS[t[2]]} /></svg>{t[1]}
              {t[0] === 'msgs' && unread > 0 && <span className="pl-badge">{unread}</span>}
            </button>
          ) : <button key="fab" className="pl-fab" aria-label="Crear partido" onClick={() => setScr({ n: 'create' })}><svg viewBox="0 0 24 24" aria-hidden="true"><path d={PATHS.plus} /></svg></button>)}
        </div>
      )}
    </div>
  )
}
