import { useEffect, useRef, useState } from 'react'
import { TabBar, useToast } from '../lib/ui.jsx'

// Ruta pregrabada e inventada (no es un recorrido real de nadie).
const ROUTE = [[20, 150], [60, 120], [95, 135], [130, 95], [170, 105], [205, 60], [245, 75], [280, 35]]
const pointAt = (p) => {
  const f = Math.min(p, 0.999) * (ROUTE.length - 1)
  const i = Math.floor(f), t = f - i
  return [ROUTE[i][0] + (ROUTE[i + 1][0] - ROUTE[i][0]) * t, ROUTE[i][1] + (ROUTE[i + 1][1] - ROUTE[i][1]) * t]
}
const KINDS = { cruise: 'Paseo', track: 'Pista', drag: 'Drag', hillclimb: 'Subida' }

const VEHICLES = [
  { id: 1, nick: 'Mochi', name: 'Mazda MX-5 1994', kind: 'Auto', hp: 133, kg: 960, mods: ['Escape deportivo', 'Barra de torre'] },
  { id: 2, nick: 'La Roja', name: 'Yamaha R6 2012', kind: 'Moto', hp: 123, kg: 190, mods: ['Slip-on'] },
]

export default function Apex() {
  const [tab, setTab] = useState('garage')
  const [vehicles, setVehicles] = useState(VEHICLES)
  const [sel, setSel] = useState(1)
  const [kind, setKind] = useState('cruise')
  const [run, setRun] = useState(false)
  const [p, setP] = useState(0)
  const [stat, setStat] = useState({ km: 0, max: 0, sum: 0, n: 0, spd: 0 })
  const [history, setHistory] = useState([{ id: 1, v: 'Mochi', kind: 'Paseo', km: 18.4, max: 92, when: 'Domingo' }])
  const [friends, setFriends] = useState([{ n: 'Tatiana', car: 'Subaru WRX', on: true }, { n: 'Héctor', car: 'Honda Civic Si', on: false }, { n: 'Dayana', car: 'Ducati Monster', on: false }])
  const [toast, toastNode] = useToast()
  const [f, setF] = useState({ nick: '', name: '', hp: '', kg: '' })
  const tick = useRef(0)

  useEffect(() => {
    if (!run) return
    const id = setInterval(() => {
      tick.current += 1
      setP((x) => { const n = x + 0.004; if (n >= 1) { setRun(false); return 1 } return n })
      setStat((s) => {
        const spd = 45 + 35 * Math.sin(tick.current / 9) + (kind === 'track' ? 25 : kind === 'drag' ? 40 : 0)
        return { km: s.km + spd / 3600 * 4, max: Math.max(s.max, spd), sum: s.sum + spd, n: s.n + 1, spd }
      })
    }, 60)
    return () => clearInterval(id)
  }, [run, kind])

  const veh = vehicles.find((v) => v.id === sel)
  const finish = () => {
    setRun(false)
    if (stat.n < 5) return toast('Recorre un poco más')
    setHistory((h) => [{ id: Date.now(), v: veh.nick, kind: KINDS[kind], km: +stat.km.toFixed(1), max: Math.round(stat.max), when: 'Ahora' }, ...h])
    setP(0); setStat({ km: 0, max: 0, sum: 0, n: 0, spd: 0 }); tick.current = 0
    toast('Sesión guardada en tu historial')
  }
  const addVehicle = (e) => {
    e.preventDefault()
    if (!f.name.trim()) return toast('Pon el modelo')
    const hp = +f.hp || 100, kg = +f.kg || 1200
    setVehicles((l) => [...l, { id: Date.now(), nick: f.nick || f.name.split(' ')[0], name: f.name, kind: 'Auto', hp, kg, mods: [] }])
    setF({ nick: '', name: '', hp: '', kg: '' }); toast('Vehículo agregado al garaje')
  }
  const path = ROUTE.map((q) => q.join(',')).join(' ')
  const [cx, cy] = pointAt(p)
  const tabs = [
    { id: 'garage', label: 'Garaje', icon: 'store' },
    { id: 'session', label: 'Sesión', icon: 'pin' },
    { id: 'friends', label: 'Amigos', icon: 'users' },
  ]

  return (
    <div className="app">
      <div className="app-top"><h3>Apex</h3><small>datos de ejemplo</small></div>
      <div className="app-body">
        {tab === 'garage' && (
          <>
            {vehicles.map((v) => (
              <div key={v.id} className="card">
                <div className="row"><strong>{v.nick}</strong><span className="pill">{v.kind}</span></div>
                <div className="sub">{v.name}</div>
                <div className="row" style={{ marginTop: 8 }}>
                  <div><div className="sub">Potencia</div><strong>{v.hp} hp</strong></div>
                  <div><div className="sub">Peso</div><strong>{v.kg} kg</strong></div>
                  <div><div className="sub">Rel. peso/pot.</div><strong>{(v.kg / v.hp).toFixed(1)}</strong></div>
                </div>
                {v.mods.length > 0 && <div style={{ display: 'flex', gap: 4, flexWrap: 'wrap', marginTop: 8 }}>{v.mods.map((m) => <span key={m} className="pill">{m}</span>)}</div>}
              </div>
            ))}
            <form onSubmit={addVehicle} className="card" style={{ display: 'grid', gap: 8 }}>
              <div className="h">Agregar vehículo</div>
              <label className="field">Modelo<input value={f.name} onChange={(e) => setF({ ...f, name: e.target.value })} placeholder="Ej. Toyota GR86 2023" /></label>
              <label className="field">Apodo<input value={f.nick} onChange={(e) => setF({ ...f, nick: e.target.value })} /></label>
              <div className="row"><label className="field">hp<input type="number" value={f.hp} onChange={(e) => setF({ ...f, hp: e.target.value })} /></label><label className="field">kg<input type="number" value={f.kg} onChange={(e) => setF({ ...f, kg: e.target.value })} /></label></div>
              <button className="sbtn">Guardar</button>
            </form>
          </>
        )}
        {tab === 'session' && (
          <>
            <div className="row">
              <label className="field" style={{ flex: 1 }}>Vehículo<select value={sel} onChange={(e) => setSel(+e.target.value)} disabled={run}>{vehicles.map((v) => <option key={v.id} value={v.id}>{v.nick}</option>)}</select></label>
              <label className="field" style={{ flex: 1 }}>Tipo<select value={kind} onChange={(e) => setKind(e.target.value)} disabled={run}>{Object.entries(KINDS).map(([k, l]) => <option key={k} value={k}>{l}</option>)}</select></label>
            </div>
            <div className="card" style={{ padding: 0, overflow: 'hidden', background: '#e8ecef' }}>
              <svg viewBox="0 0 300 180" width="100%" role="img" aria-label="Mapa de la ruta simulada">
                <polyline points={path} fill="none" stroke="#c4ccd2" strokeWidth="8" strokeLinecap="round" strokeLinejoin="round" />
                <polyline points={path} fill="none" stroke="#9aa5ad" strokeWidth="1.5" strokeDasharray="4 4" />
                <circle cx={cx} cy={cy} r="7" fill="var(--app)" stroke="#fff" strokeWidth="2.5" />
              </svg>
            </div>
            <div className="row">
              <div className="card" style={{ flex: 1 }}><div className="sub">Velocidad</div><strong style={{ fontSize: 22 }}>{Math.round(stat.spd)}</strong> <span className="sub">km/h</span></div>
              <div className="card" style={{ flex: 1 }}><div className="sub">Distancia</div><strong style={{ fontSize: 22 }}>{stat.km.toFixed(2)}</strong> <span className="sub">km</span></div>
            </div>
            <div className="row">
              {!run ? <button className="sbtn" style={{ flex: 1 }} onClick={() => { if (p >= 1) { setP(0); setStat({ km: 0, max: 0, sum: 0, n: 0, spd: 0 }) } setRun(true) }}>{stat.n ? 'Continuar' : 'Iniciar sesión'}</button> : <button className="sbtn ghost" style={{ flex: 1 }} onClick={() => setRun(false)}>Pausar</button>}
              <button className="sbtn" style={{ flex: 1 }} disabled={!stat.n} onClick={finish}>Terminar y guardar</button>
            </div>
            <div className="sub">Ruta pregrabada. En la app real usa el GPS en segundo plano.</div>
            <div className="h">Historial</div>
            {history.map((h) => <div key={h.id} className="card row"><div><strong>{h.v} · {h.kind}</strong><div className="sub">{h.when}</div></div><div style={{ textAlign: 'right' }}><div>{h.km} km</div><div className="sub">máx {h.max} km/h</div></div></div>)}
          </>
        )}
        {tab === 'friends' && friends.map((fr, i) => (
          <div key={fr.n} className="card row">
            <div><strong>{fr.n}</strong><div className="sub">{fr.car}</div></div>
            <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
              {fr.on && <span className="pill ok">en sesión</span>}
              <button className="sbtn ghost sm" onClick={() => { setFriends((l) => l.filter((_, j) => j !== i)); toast(`Quitaste a ${fr.n}`) }}>Quitar</button>
            </div>
          </div>
        ))}
        {tab === 'friends' && friends.length === 0 && <div className="empty">Sin amigos todavía.</div>}
      </div>
      {toastNode}
      <TabBar tabs={tabs} value={tab} onChange={setTab} />
    </div>
  )
}
