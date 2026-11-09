import { useEffect, useRef, useState } from 'react'
import './apex.css'

// Pilotos, vehículos, sesiones y publicaciones son inventados. La interfaz sigue la app real.
const PATHS = {
  feed: 'M13 2L4 14h7l-1 8 9-12h-7l1-8z',
  car: 'M5 16l1.5-5.5A2 2 0 018.4 9h7.2a2 2 0 011.9 1.5L19 16M3 16h18v3H3zM7 19v1M17 19v1M7.5 13h.01M16.5 13h.01',
  users: 'M9 11a3 3 0 100-6 3 3 0 000 6zm-6 8c0-3 3-5 6-5s6 2 6 5m1-8a3 3 0 100-6m5 14c0-2-1.5-3.6-4-4.4',
  user: 'M12 12a4 4 0 100-8 4 4 0 000 8zm-8 9c0-4 4-6 8-6s8 2 8 6',
}
const Ico = ({ n }) => <svg viewBox="0 0 24 24" aria-hidden="true"><path d={PATHS[n]} /></svg>

const POSTS = [
  { id: 1, who: 'curva_norte', ago: '9 de nov', t: 'Domingo de curvas y café por la carretera vieja. Nada como un buen asfalto y el motor sonando limpio.', likes: 11, comments: 3 },
  { id: 2, who: 'rpm_lucas', ago: '8 de nov', t: '¿Alguien más tiene el Civic Type R con downpipe? Busco recomendaciones de tune, el mío deja una zona muerta entre 3000 y 3500 rpm.', likes: 10, comments: 2 },
  { id: 3, who: 'dani_boxer', ago: '8 de nov', t: 'Primera salida con la nueva reprogramación. El WRX respira distinto, se siente mucho más lleno a medio régimen.', likes: 8, comments: 4 },
  { id: 4, who: 'moto_santi', ago: '7 de nov', t: 'Rodada de domingo en grupo, 12 motos y cero sustos. Gracias a todos los que vinieron.', likes: 15, comments: 6 },
]
const PILOTS = ['Valeria Montoya', 'Lucas Herrera', 'Daniel Paredes', 'Santiago Mora', 'Camila Ortega', 'Andrés Vélez']
const ROUTE = [[48, 450], [92, 370], [76, 300], [132, 262], [188, 282], [220, 214], [200, 156], [236, 126]]
const at = (p) => { const f = Math.min(p, 0.999) * (ROUTE.length - 1), i = Math.floor(f), t = f - i; return [ROUTE[i][0] + (ROUTE[i + 1][0] - ROUTE[i][0]) * t, ROUTE[i][1] + (ROUTE[i + 1][1] - ROUTE[i][1]) * t] }
const clock = (s) => `${Math.floor(s / 60)}m ${String(Math.round(s % 60)).padStart(2, '0')}s`

export default function Apex() {
  const [tab, setTab] = useState('feed')
  const [scr, setScr] = useState(null)
  const [posts, setPosts] = useState(POSTS)
  const [liked, setLiked] = useState([])
  const [draft, setDraft] = useState('')
  const [vehicles, setVehicles] = useState([
    { id: 1, name: '1994 Mazda MX-5', kind: 'Auto', eng: '1.8L i4', fuel: 'Corriente', trans: 'Manual', color: 'Rojo clásico', specs: null, mods: [] },
    { id: 2, name: '2012 Yamaha R6', kind: 'Moto', eng: '600cc i4', fuel: 'Corriente', trans: 'Manual', color: 'Azul', specs: { hp: 123, nm: 66, kg: 190, z100: '3.4 s' }, mods: ['Escape slip-on'] },
  ])
  const [adding, setAdding] = useState(false)
  const [nv, setNv] = useState({ year: '2020', make: '', model: '', kind: 'Auto' })
  const [ptab, setPtab] = useState('Mis amigos')
  const [friends, setFriends] = useState(['Valeria Montoya', 'Lucas Herrera'])
  const [reqs, setReqs] = useState(['Daniel Paredes'])
  const [q, setQ] = useState('')
  const [bio, setBio] = useState('')
  const [editBio, setEditBio] = useState(false)
  const [sessions, setSessions] = useState([{ id: 1, n: 'Crucero — 29/5/2026', km: 18.4, time: '31m 12s', when: '29 de may', icon: '🛣️' }, { id: 2, n: 'Pista — 2/6/2026', km: 7.1, time: '12m 40s', when: '2 de jun', icon: '🏁' }])
  const [run, setRun] = useState(false)
  const [started, setStarted] = useState(false)
  const [setup, setSetup] = useState(false)
  const [sType, setSType] = useState('cruise')
  const [sVeh, setSVeh] = useState(null)
  const [share, setShare] = useState(true)
  const [summary, setSummary] = useState(null)
  const [spd, setSpd] = useState(0)
  const [mx, setMx] = useState(0)
  const [p, setP] = useState(0)
  const [toast, setToast] = useState('')
  const say = (m) => { setToast(m); setTimeout(() => setToast(''), 2000) }
  const tk = useRef(0)

  useEffect(() => {
    if (!run) return
    const bonus = { cruise: 0, track: 28, drag: 48, hillclimb: -12 }[sType]
    const id = setInterval(() => {
      tk.current++
      const v = Math.max(8, 52 + bonus + 30 * Math.sin(tk.current / 7))
      setSpd(v); setMx((m) => Math.max(m, v))
      setP((x) => { if (x >= 1) { setRun(false); return 1 } return x + 0.006 })
    }, 70)
    return () => clearInterval(id)
  }, [run, sType])

  const km = p * 6.4, secs = p * 1320
  const TYPES = { cruise: ['Crucero', '🛣️'], track: ['Pista', '🏁'], drag: ['Arrancón', '🚦'], hillclimb: ['Subida', '⛰️'] }
  const resetSession = () => { setRun(false); setStarted(false); setP(0); setSpd(0); setMx(0); tk.current = 0 }
  const finish = () => {
    setRun(false)
    if (p < 0.03) return say('Recorre un poco más')
    setSummary({ km, secs, mx, avg: secs ? km / (secs / 3600) : 0 })
  }
  const saveSession = () => {
    const [name, icon] = TYPES[sType]
    setSessions((list) => [{ id: Date.now(), n: name + ' — 9/11/2026', km: +summary.km.toFixed(1), time: clock(summary.secs), when: '9 de nov', icon }, ...list])
    setSummary(null); resetSession(); setScr(null); setTab('me'); say('Sesión guardada en tu perfil')
  }
  const veh = vehicles.find((v) => v.id === scr?.id)
  const go = (t) => { setTab(t); setScr(null) }

  let body
  if (scr?.n === 'session') {
    const [cx, cy] = at(p)
    const pts = ROUTE.map((r) => r.join(',')).join(' ')
    const live = started && friends.length > 0
    const pals = friends.slice(0, 3).map((n, i) => { const pos = at((p * 0.85 + 0.12 + i * 0.22) % 1); return { n, x: pos[0] + (i - 1) * 16, y: pos[1] + 14 * (i % 2 ? 1 : -1), v: Math.round(48 + 28 * Math.sin(tk.current / 9 + i * 2)) } })
    body = (
      <>
        <div className="ax-map">
          <svg viewBox="0 0 280 520" width="100%" height="100%" preserveAspectRatio="xMidYMid slice" aria-label="Mapa de la sesión">
            {[[0, 165, 280, 137], [0, 342, 280, 315], [90, 0, 70, 520], [200, 0, 230, 520], [0, 55, 280, 96]].map(([x1, y1, x2, y2], i) => <line key={i} x1={x1} y1={y1} x2={x2} y2={y2} stroke="#303030" strokeWidth={i % 2 ? 7 : 10} />)}
            {[['Calle 45', 20, 155], ['Carrera 27', 98, 100], ['Av. Norte', 150, 335]].map(([t, x, y]) => <text key={t} x={x} y={y} fill="#666" fontSize="8" letterSpacing="1.5">{t.toUpperCase()}</text>)}
            <polyline points={pts} fill="none" stroke="#e8384f" strokeWidth="3" opacity={started ? 1 : 0.3} strokeLinejoin="round" />
            {live && pals.map((f) => <g key={f.n} aria-label={f.n + ' ' + f.v + ' km/h'}><circle cx={f.x} cy={f.y} r="9" fill="#22c55e" stroke="#fff" strokeWidth="2" /><text x={f.x} y={f.y + 3.5} textAnchor="middle" fontSize="10" fontWeight="700" fill="#fff">{f.n[0]}</text><rect x={f.x - 17} y={f.y + 12} width="34" height="12" rx="6" fill="#0a0a0acc" /><text x={f.x} y={f.y + 21} textAnchor="middle" fontSize="8" fontWeight="600" fill="#22c55e">{f.v} km/h</text></g>)}
            {started && <g><circle cx={cx} cy={cy} r="11" fill="#e8384f" stroke="#fff" strokeWidth="2.5" /><text x={cx} y={cy + 4} textAnchor="middle" fontSize="11" fill="#fff">▲</text></g>}
          </svg>
        </div>
        {!started ? (
          <>
            <button className="ax-ghost" style={{ position: 'absolute', top: 36, left: 12, width: 'auto', padding: '6px 12px', background: '#000a', zIndex: 3 }} onClick={() => { resetSession(); setScr(null) }}>‹ Cerrar</button>
            <div className="ax-sheet"><h3>SESIÓN GPS</h3><div className="ax-sub">Registra tu ruta con precisión</div><button className="ax-go" onClick={() => setSetup(true)}>◉  INICIAR SESIÓN</button></div>
          </>
        ) : (
          <div className="ax-hud">
            <div className="ax-hudtop">
              <div className="ax-hc"><b>{Math.round(spd)}</b><span>km/h</span></div>
              <div className="ax-hc" style={{ flex: 1.3, flexDirection: 'row', gap: 8, borderColor: run ? 'var(--bd)' : '#f59e0b' }}><i className="ax-dot" style={{ background: run ? 'var(--red)' : '#f59e0b' }} /><div><b style={{ fontSize: 18 }}>{String(Math.floor(secs / 60)).padStart(2, '0')}:{String(Math.round(secs % 60)).padStart(2, '0')}</b>{!run && <span style={{ color: '#f59e0b', display: 'block' }}>EN PAUSA</span>}</div></div>
              <div className="ax-hc"><b>{Math.round(mx)}</b><span>V. Máx</span></div>
            </div>
            <button className="ax-priv" aria-pressed={share} onClick={() => { setShare(!share); say(share ? 'Ahora tus amigos no te ven' : 'Tus amigos te ven en el mapa') }}>{share ? '👁 Visible para amigos · toca para ocultar' : '🔒 Ubicación oculta · toca para compartir'}</button>
            {live && <div className="ax-near">🟢 {pals.length} {pals.length === 1 ? 'piloto cercano' : 'pilotos cercanos'}</div>}
            <div style={{ flex: 1 }} />
            <div className="ax-row" style={{ gap: 8, padding: '0 0 14px' }}>
              <button className="ax-ghost" style={{ width: 'auto', padding: '14px 18px', background: '#000c', fontWeight: 700 }} onClick={() => setRun(!run)}>{run ? '❚❚ PAUSA' : '▶ SEGUIR'}</button>
              <button className="ax-go" style={{ marginTop: 0, flex: 1 }} onClick={finish}>■ FINALIZAR</button>
            </div>
          </div>
        )}
        {setup && (
          <div className="ax-modal">
            <div className="ax-card" style={{ borderRadius: '22px 22px 0 0', display: 'grid', gap: 10, paddingBottom: 18 }}>
              <b style={{ fontSize: 18 }}>Nueva Sesión</b>
              <div className="ax-sub">Tipo de sesión</div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>{Object.entries(TYPES).map(([k, [l, ic]]) => <button key={k} className={'ax-type ' + (sType === k ? 'on' : '')} aria-pressed={sType === k} onClick={() => setSType(k)}><span style={{ fontSize: 24 }}>{ic}</span>{l}</button>)}</div>
              <div className="ax-sub">Vehículo (opcional)</div>
              <div style={{ display: 'flex', gap: 8, overflowX: 'auto' }}>{[{ id: null, name: '— Sin vehículo' }, ...vehicles].map((v) => <button key={v.id ?? 'n'} className={'ax-type ' + (sVeh === v.id ? 'on' : '')} style={{ flex: 'none', padding: '8px 12px' }} onClick={() => setSVeh(v.id)}>{v.name}</button>)}</div>
              <div className="ax-row" style={{ gap: 8 }}><button className="ax-ghost" onClick={() => setSetup(false)}>Cancelar</button><button className="ax-go" style={{ marginTop: 0 }} onClick={() => { setSetup(false); setStarted(true); setRun(true) }}>◉  ARRANCAR</button></div>
            </div>
          </div>
        )}
        {summary && (
          <div className="ax-modal" style={{ alignItems: 'center', padding: 24 }}>
            <div className="ax-card" style={{ display: 'grid', gap: 8, width: '100%' }}>
              <b style={{ fontSize: 17 }}>Sesión terminada</b>
              {[['Distancia', summary.km.toFixed(2) + ' km'], ['Tiempo', clock(summary.secs)], ['Velocidad máx.', Math.round(summary.mx) + ' km/h'], ['Velocidad media', Math.round(summary.avg) + ' km/h']].map(([k, v]) => <div key={k} className="ax-row"><span className="ax-sub">{k}</span><b>{v}</b></div>)}
              <button className="ax-go" onClick={saveSession}>GUARDAR EN MI PERFIL</button>
              <button className="ax-ghost" onClick={() => { setSummary(null); resetSession() }}>Descartar</button>
            </div>
          </div>
        )}
      </>
    )
  } else if (scr?.n === 'vehicle' && veh) {
    body = (
      <div className="ax-body" style={{ paddingTop: 38 }}>
        <button style={{ all: 'unset', color: 'var(--red)', cursor: 'pointer' }} onClick={() => setScr(null)}>‹ Garaje</button>
        <div><div className="ax-h">{veh.name}</div><div className="ax-sub">{veh.eng} · {veh.fuel} · {veh.trans} · {veh.color}</div></div>
        <div className="ax-card"><b>Specs actuales</b>
          {veh.specs ? <div className="ax-row" style={{ marginTop: 10, textAlign: 'center' }}>{[[veh.specs.hp, 'hp'], [veh.specs.nm, 'Nm'], [veh.specs.kg, 'kg'], [veh.specs.z100, '0-100']].map(([a, b]) => <div key={b}><b style={{ fontSize: 18 }}>{a}</b><div className="ax-sub">{b}</div></div>)}</div> : (
            <><div className="ax-sub" style={{ margin: '8px 0 10px' }}>Este vehículo aún no tiene ficha técnica.</div>
              <button className="ax-ghost" onClick={() => { setVehicles(vehicles.map((v) => (v.id === veh.id ? { ...v, specs: { hp: 133, nm: 160, kg: 960, z100: '8.8 s' } } : v))); say('Ficha estimada con IA (ejemplo)') }}>🤖 Estimar ficha con IA</button></>
          )}
        </div>
        <div className="ax-card"><div className="ax-row"><b>Modificaciones</b><button style={{ all: 'unset', color: 'var(--red)', fontWeight: 700, cursor: 'pointer' }} onClick={() => { const m = ['Suspensión deportiva', 'Barra de torre', 'Filtro de alto flujo', 'Llantas 17"'][veh.mods.length % 4]; setVehicles(vehicles.map((v) => (v.id === veh.id ? { ...v, mods: [...v.mods, m] } : v))); say(`Agregaste: ${m}`) }}>+ Agregar</button></div>
          {veh.mods.length === 0 ? <div className="ax-sub" style={{ marginTop: 8 }}>Sin modificaciones registradas.</div> : veh.mods.map((m, i) => <div key={i} style={{ padding: '8px 0', borderTop: i ? '1px solid var(--bd)' : 0 }}>{m}</div>)}
        </div>
      </div>
    )
  } else if (tab === 'feed') {
    body = (
      <>
        <div className="ax-top"><span className="ax-logo">APEX</span></div>
        <div className="ax-body">
          <div className="ax-card" style={{ borderRadius: 20, padding: 14 }}>
            <textarea className="ax-in" aria-label="Publicación" style={{ background: 'transparent', border: 0, resize: 'none', height: 64, padding: 4 }} placeholder="¿Qué hay en el paddock?" value={draft} onChange={(e) => setDraft(e.target.value)} />
            <div className="ax-row"><span style={{ fontSize: 20 }}>📷</span><button className="ax-red" disabled={!draft.trim()} onClick={() => { setPosts([{ id: Date.now(), who: 'tu_usuario', ago: 'ahora', t: draft.trim(), likes: 0, comments: 0 }, ...posts]); setDraft('') }}>Publicar</button></div>
          </div>
          {posts.map((x) => (
            <div key={x.id} className="ax-card" style={{ borderRadius: 20 }}>
              <div className="ax-row"><div className="ax-row" style={{ gap: 10 }}><span className="ax-av" style={{ width: 40, height: 40 }}>{x.who[0].toUpperCase()}</span><div><b>@{x.who}</b><div className="ax-sub" style={{ fontSize: 11 }}>{x.ago}</div></div></div><span className="ax-sub">•••</span></div>
              <p style={{ margin: '10px 0' }}>{x.t}</p>
              <div className="ax-row" style={{ justifyContent: 'flex-start', gap: 18 }}>
                <button style={{ all: 'unset', cursor: 'pointer' }} aria-label="Me gusta" aria-pressed={liked.includes(x.id)} onClick={() => setLiked(liked.includes(x.id) ? liked.filter((i) => i !== x.id) : [...liked, x.id])}>{liked.includes(x.id) ? '❤️' : '🤍'} <span className="ax-sub">{x.likes + (liked.includes(x.id) ? 1 : 0)}</span></button>
                <span>💬 <span className="ax-sub">{x.comments}</span></span>
              </div>
            </div>
          ))}
        </div>
      </>
    )
  } else if (tab === 'garage') {
    body = (
      <>
        <div className="ax-top"><span className="ax-h">Mi Garaje</span><button className="ax-red" onClick={() => setAdding(true)}>+ Agregar</button></div>
        <div className="ax-body">
          {vehicles.map((v) => (
            <button key={v.id} className="ax-card" style={{ padding: 0, overflow: 'hidden', textAlign: 'left', cursor: 'pointer', color: 'inherit' }} onClick={() => setScr({ n: 'vehicle', id: v.id })}>
              <div style={{ height: 150, background: '#1f1f1f', display: 'grid', placeItems: 'center', fontSize: 52 }}>{v.kind === 'Moto' ? '🏍️' : '🏎️'}</div>
              <div style={{ padding: 14 }}><div className="ax-row"><b style={{ fontSize: 16 }}>{v.name}</b><span className="ax-chip">{v.kind}</span></div><div className="ax-sub" style={{ marginTop: 6 }}>⚙ {v.eng} · ⛽ {v.fuel} · 🔧 {v.trans}</div></div>
            </button>
          ))}
        </div>
        {adding && (
          <div style={{ position: 'absolute', inset: 0, background: '#000b', display: 'grid', alignItems: 'end', zIndex: 15 }}>
            <form className="ax-card" style={{ borderRadius: '22px 22px 0 0', display: 'grid', gap: 8, paddingBottom: 20 }} onSubmit={(e) => { e.preventDefault(); if (!nv.make.trim() || !nv.model.trim()) return; setVehicles([...vehicles, { id: Date.now(), name: `${nv.year} ${nv.make.trim()} ${nv.model.trim()}`, kind: nv.kind, eng: '—', fuel: 'Corriente', trans: 'Manual', color: '—', specs: null, mods: [] }]); setAdding(false); setNv({ ...nv, make: '', model: '' }); say('Vehículo agregado') }}>
              <b style={{ fontSize: 16 }}>Agregar vehículo</b>
              <div className="ax-row"><input className="ax-in" aria-label="Año" type="number" value={nv.year} onChange={(e) => setNv({ ...nv, year: e.target.value })} style={{ width: 90 }} /><select className="ax-in" aria-label="Tipo" value={nv.kind} onChange={(e) => setNv({ ...nv, kind: e.target.value })}><option>Auto</option><option>Moto</option><option>Camioneta</option></select></div>
              <input className="ax-in" aria-label="Marca" placeholder="Marca (ej. Toyota)" value={nv.make} onChange={(e) => setNv({ ...nv, make: e.target.value })} />
              <input className="ax-in" aria-label="Modelo" placeholder="Modelo (ej. GR86)" value={nv.model} onChange={(e) => setNv({ ...nv, model: e.target.value })} />
              <div className="ax-row"><button type="button" className="ax-ghost" onClick={() => setAdding(false)}>Cancelar</button><button className="ax-red" style={{ padding: 13, flex: 1 }}>Guardar</button></div>
            </form>
          </div>
        )}
      </>
    )
  } else if (tab === 'pilots') {
    const results = PILOTS.filter((n) => !friends.includes(n) && n.toLowerCase().includes(q.toLowerCase()))
    body = (
      <>
        <div className="ax-top"><span className="ax-h">Pilotos</span></div>
        <div className="ax-tabs">{['Mis amigos', 'Solicitudes', 'Buscar'].map((x) => <button key={x} className={ptab === x ? 'on' : ''} onClick={() => setPtab(x)}>{x}{x === 'Solicitudes' && reqs.length > 0 ? ` (${reqs.length})` : ''}</button>)}</div>
        <div className="ax-body">
          {ptab === 'Mis amigos' && (friends.length === 0 ? <div className="ax-sub" style={{ textAlign: 'center', padding: 40 }}>🏎️<br />Aún no tienes amigos. ¡Busca pilotos!</div> : friends.map((n) => <div key={n} className="ax-card ax-row"><span className="ax-row" style={{ gap: 10 }}><span className="ax-av" style={{ width: 38, height: 38 }}>{n[0]}</span>{n}</span><button className="ax-ghost" style={{ width: 'auto', padding: '6px 12px' }} onClick={() => { setFriends(friends.filter((f) => f !== n)); say('Dejaste de seguir a ' + n.split(' ')[0]) }}>Quitar</button></div>))}
          {ptab === 'Solicitudes' && (reqs.length === 0 ? <div className="ax-sub" style={{ textAlign: 'center', padding: 40 }}>No tienes solicitudes pendientes.</div> : reqs.map((n) => <div key={n} className="ax-card ax-row"><span className="ax-row" style={{ gap: 10 }}><span className="ax-av" style={{ width: 38, height: 38 }}>{n[0]}</span>{n}</span><button className="ax-red" onClick={() => { setReqs(reqs.filter((r) => r !== n)); setFriends([...friends, n]); say('Ahora son amigos') }}>Aceptar</button></div>))}
          {ptab === 'Buscar' && (<><input className="ax-in" aria-label="Buscar pilotos" placeholder="Buscar pilotos…" value={q} onChange={(e) => setQ(e.target.value)} />{results.map((n) => <div key={n} className="ax-card ax-row"><span className="ax-row" style={{ gap: 10 }}><span className="ax-av" style={{ width: 38, height: 38 }}>{n[0]}</span>{n}</span><button className="ax-red" onClick={() => { setFriends([...friends, n]); say('Solicitud enviada') }}>Agregar</button></div>)}{results.length === 0 && <div className="ax-sub" style={{ textAlign: 'center', padding: 30 }}>Sin resultados.</div>}</>)}
        </div>
      </>
    )
  } else {
    body = (
      <div className="ax-body" style={{ paddingTop: 38 }}>
        <div className="ax-row" style={{ justifyContent: 'flex-start', gap: 16 }}><span className="ax-av" style={{ width: 84, height: 84, fontSize: 34 }}>T</span><div><b style={{ fontSize: 20 }}>Piloto Demo</b><div className="ax-sub">@piloto_demo</div><div className="ax-sub">📍 Bucaramanga</div></div></div>
        <div className="ax-stat">{[[sessions.length, 'Sesiones'], [vehicles.length, 'Vehículos'], [friends.length, 'Amigos']].map(([a, b]) => <div key={b}><b>{a}</b><span className="ax-sub">{b}</span></div>)}</div>
        <div className="ax-card"><div className="ax-row"><b>Bio</b><button style={{ all: 'unset', color: 'var(--red)', cursor: 'pointer' }} onClick={() => setEditBio(!editBio)}>{editBio ? 'Listo' : 'Editar'}</button></div>
          {editBio ? <textarea className="ax-in" aria-label="Bio" style={{ marginTop: 8, height: 60 }} value={bio} onChange={(e) => setBio(e.target.value)} /> : <div className="ax-sub" style={{ marginTop: 8 }}>{bio || 'Sin bio todavía. ¡Agrega una!'}</div>}
        </div>
        <div className="ax-card"><b>Últimas sesiones</b>{sessions.map((s) => <div key={s.id} className="ax-row" style={{ padding: '10px 0', borderTop: '1px solid var(--bd)', marginTop: 8 }}><span className="ax-row" style={{ gap: 12 }}><span style={{ fontSize: 28 }}>{s.icon}</span><span><b>{s.n}</b><div className="ax-sub">{s.km} km · {s.time}</div></span></span><span className="ax-sub" style={{ fontSize: 11 }}>{s.when}</span></div>)}</div>
        <div className="ax-card" style={{ display: 'grid', gap: 14 }}>{['Política de privacidad', 'Términos y condiciones', 'Usuarios bloqueados'].map((x) => <div key={x} className="ax-row">{x}<span className="ax-sub">›</span></div>)}<span style={{ color: 'var(--red)' }}>Eliminar cuenta</span></div>
        <button className="ax-ghost" onClick={() => say('Es una demo: no hay sesión real')}>Cerrar sesión</button>
      </div>
    )
  }

  const tabs = [['feed', 'Feed', 'feed'], ['garage', 'Garaje', 'car'], null, ['pilots', 'Pilotos', 'users'], ['me', 'Perfil', 'user']]
  return (
    <div className="ax">
      {body}
      {toast && <div className="ax-toast" role="status">{toast}</div>}
      {scr?.n !== 'session' && (
        <div className="ax-bar" role="tablist">
          {tabs.map((t) => t ? <button key={t[0]} role="tab" aria-selected={tab === t[0] && !scr} className={`ax-tab ${tab === t[0] ? 'on' : ''}`} onClick={() => go(t[0])}><Ico n={t[2]} />{t[1]}</button>
            : <button key="rec" className="ax-rec" aria-label="Iniciar sesión GPS" onClick={() => setScr({ n: 'session' })}><i /></button>)}
        </div>
      )}
    </div>
  )
}
