import { useEffect, useRef, useState } from 'react'
import { cop } from '../lib/ui.jsx'

const SERVICES = [
  { id: 's1', name: 'Corte clásico', min: 40, price: 35000 },
  { id: 's2', name: 'Corte y barba', min: 60, price: 55000 },
  { id: 's3', name: 'Tinte', min: 90, price: 120000 },
  { id: 's4', name: 'Manicure', min: 45, price: 40000 },
]
const TEAM = ['Valeria', 'Camilo', 'Ximena']
const SLOTS = ['9:00', '10:30', '12:00', '2:30', '4:00', '5:30']

const SEED = [
  { id: 1, time: '9:00', who: 'Marcela Quintero', svc: 'Corte clásico', pro: 'Valeria', price: 35000 },
  { id: 2, time: '10:30', who: 'Andrés Cifuentes', svc: 'Corte y barba', pro: 'Camilo', price: 55000 },
  { id: 3, time: '12:00', who: 'Sofía Ardila', svc: 'Tinte', pro: 'Ximena', price: 120000 },
]

const hhmm = (t) => {
  const [h, m] = t.split(':').map(Number)
  const hh = h < 8 ? h + 12 : h
  return hh * 60 + m
}

function Chat({ taken, onBook }) {
  const [log, setLog] = useState([{ from: 'bot', text: 'Hola, soy la recepcionista virtual de Corte Fino. ¿Qué te gustaría agendar hoy?' }])
  const [step, setStep] = useState('svc')
  const [pick, setPick] = useState({})
  const [text, setText] = useState('')
  const end = useRef(null)
  useEffect(() => { end.current?.scrollIntoView({ block: 'end' }) }, [log])

  const say = (from, t) => setLog((l) => [...l, { from, text: t }])
  const reply = (t) => setTimeout(() => say('bot', t), 350)

  const chooseSvc = (s) => {
    say('me', s.name)
    setPick({ svc: s })
    setStep('pro')
    reply(`${s.name}, ${s.min} min, ${cop(s.price)}. ¿Con quién prefieres?`)
  }
  const choosePro = (pro) => {
    say('me', pro)
    setPick((p) => ({ ...p, pro }))
    setStep('time')
    reply('Estas son las horas libres de hoy:')
  }
  const chooseTime = (t) => {
    say('me', t)
    setPick((p) => ({ ...p, time: t }))
    setStep('name')
    reply('Perfecto. ¿A nombre de quién la dejo?')
  }
  const submitName = (e) => {
    e.preventDefault()
    const n = text.trim()
    if (!n) return
    say('me', n)
    setText('')
    onBook({ who: n, svc: pick.svc.name, pro: pick.pro, time: pick.time, price: pick.svc.price })
    setStep('done')
    reply(`Listo, ${n.split(' ')[0]}. Quedaste hoy a las ${pick.time} con ${pick.pro}. Te llegará un recordatorio.`)
  }
  const again = () => { setLog([{ from: 'bot', text: '¿Quieres agendar otra cita?' }]); setStep('svc'); setPick({}) }

  const free = (t) => !taken.some((a) => a.pro === pick.pro && a.time === t)

  return (
    <div className="app" style={{ background: '#eef3f3' }}>
      <div className="app-top"><div><h3>Corte Fino</h3><small>Chat de reservas · enlace público</small></div><span style={{ fontSize: 22 }} aria-hidden="true">✂</span></div>
      <div className="app-body">
        {log.map((m, i) => (
          <div key={i} style={{ alignSelf: m.from === 'me' ? 'flex-end' : 'flex-start', maxWidth: '85%', background: m.from === 'me' ? 'var(--app)' : '#fff', color: m.from === 'me' ? '#fff' : '#1a1a1a', padding: '8px 12px', borderRadius: 14, border: m.from === 'me' ? 0 : '1px solid #dfe6e6' }}>{m.text}</div>
        ))}
        {step === 'svc' && SERVICES.map((s) => <button key={s.id} className="sbtn ghost" style={{ textAlign: 'left' }} onClick={() => chooseSvc(s)}>{s.name} · {cop(s.price)}</button>)}
        {step === 'pro' && <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>{TEAM.map((p) => <button key={p} className="sbtn ghost sm" onClick={() => choosePro(p)}>{p}</button>)}</div>}
        {step === 'time' && <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>{SLOTS.map((t) => <button key={t} className="sbtn ghost sm" disabled={!free(t)} onClick={() => chooseTime(t)}>{t}</button>)}</div>}
        {step === 'done' && <button className="sbtn sm" style={{ alignSelf: 'flex-start' }} onClick={again}>Agendar otra</button>}
        <div ref={end} />
      </div>
      {step === 'name' && (
        <form onSubmit={submitName} className="row" style={{ padding: 10, borderTop: '1px solid #dfe6e6', background: '#fff' }}>
          <input autoFocus aria-label="Tu nombre" placeholder="Tu nombre" value={text} onChange={(e) => setText(e.target.value)} style={{ flex: 1, border: '1px solid #d6d6d0', borderRadius: 8, padding: 8 }} />
          <button className="sbtn">Enviar</button>
        </form>
      )}
    </div>
  )
}

function Panel({ appts, flash }) {
  const [view, setView] = useState('agenda')
  const sorted = [...appts].sort((a, b) => hhmm(a.time) - hhmm(b.time))
  const income = appts.reduce((s, a) => s + a.price, 0)
  const clients = new Set(appts.map((a) => a.who)).size
  return (
    <div className="app">
      <div className="app-top"><div><h3>Panel · Corte Fino</h3><small>Hoy · datos de ejemplo</small></div></div>
      <div className="row" style={{ padding: '10px 14px 0' }}>
        <div className="card" style={{ flex: 1 }}><div className="sub">Citas hoy</div><strong style={{ fontSize: 22 }}>{appts.length}</strong></div>
        <div className="card" style={{ flex: 1 }}><div className="sub">Ingresos</div><strong style={{ fontSize: 22 }}>{cop(income)}</strong></div>
        <div className="card" style={{ flex: 1 }}><div className="sub">Clientes</div><strong style={{ fontSize: 22 }}>{clients}</strong></div>
      </div>
      <div style={{ display: 'flex', gap: 6, padding: '10px 14px 0' }}>
        {[['agenda', 'Agenda'], ['team', 'Por profesional']].map(([id, l]) => <button key={id} className={`sbtn sm ${view === id ? '' : 'ghost'}`} onClick={() => setView(id)}>{l}</button>)}
      </div>
      <div className="app-body">
        {view === 'agenda' && sorted.map((a) => (
          <div key={a.id} className="card row" style={a.id === flash ? { outline: '2px solid var(--app)' } : undefined}>
            <div><strong>{a.time}</strong> · {a.who}<div className="sub">{a.svc} · {a.pro}</div></div>
            <span className="pill ok">{cop(a.price)}</span>
          </div>
        ))}
        {view === 'team' && TEAM.map((p) => {
          const mine = sorted.filter((a) => a.pro === p)
          return (
            <div key={p} className="card">
              <div className="row"><strong>{p}</strong><span className="pill">{mine.length} citas</span></div>
              {mine.length === 0 ? <div className="sub">Sin citas</div> : mine.map((a) => <div key={a.id} className="sub">{a.time} · {a.who} · {a.svc}</div>)}
            </div>
          )
        })}
      </div>
    </div>
  )
}

export default function Slothy() {
  const [appts, setAppts] = useState(SEED)
  const [flash, setFlash] = useState(null)
  const book = (a) => {
    const id = Date.now()
    setAppts((l) => [...l, { ...a, id }])
    setFlash(id)
  }
  return (
    <div className="slothy-split">
      <div className="slothy-chat"><Chat taken={appts} onBook={book} /></div>
      <div className="slothy-panel"><Panel appts={appts} flash={flash} /></div>
    </div>
  )
}
