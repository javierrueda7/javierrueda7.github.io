import { useEffect, useRef, useState } from 'react'

// "IPS Sendero Vital" y sus pacientes son inventados.
const EXAMS = [
  { id: 'eco', name: 'Ecografía abdominal', prep: 'Ayuno de 6 horas y vejiga llena.' },
  { id: 'rm', name: 'Resonancia de rodilla', prep: 'Sin objetos metálicos; llegar 20 minutos antes.' },
  { id: 'rx', name: 'Radiografía de tórax', prep: 'No requiere preparación.' },
]
const SLOTS = ['Lun 9:00', 'Lun 11:30', 'Mar 8:00', 'Mar 15:00', 'Mié 10:00']
const TIERS = {
  eco: { label: 'Eco', per: 0.004, note: 'Modelo económico, caché y respuestas cortas' },
  medio: { label: 'Medio', per: 0.012, note: 'Mejor comprensión de notas de voz y órdenes' },
  premium: { label: 'Premium', per: 0.035, note: 'Casos complejos y razonamiento largo' },
}

const SEED = [
  { id: 1, who: 'Paciente 0041', exam: 'Radiografía de tórax', slot: 'Lun 9:00', via: 'WhatsApp' },
  { id: 2, who: 'Paciente 0057', exam: 'Ecografía abdominal', slot: 'Mar 8:00', via: 'Llamada' },
]

function Chat({ onBook, onTurn }) {
  const [log, setLog] = useState([{ f: 'bot', t: 'Hola, soy Sofía, asistente de IPS Sendero Vital. Antes de empezar: ¿autorizas el tratamiento de tus datos para gestionar tu cita? (Ley 1581)' }])
  const [step, setStep] = useState('consent')
  const [pick, setPick] = useState({})
  const [lastBooked, setLastBooked] = useState(null)
  const end = useRef(null)
  useEffect(() => { end.current?.scrollIntoView({ block: 'end' }) }, [log])
  const say = (f, t) => setLog((l) => [...l, { f, t }])
  const bot = (t) => setTimeout(() => say('bot', t), 350)
  const me = (t) => { say('me', t); onTurn() }

  const menu = (
    <div style={{ display: 'grid', gap: 6 }}>
      <button className="sbtn ghost sm" onClick={() => { me('Quiero agendar un examen'); setStep('exam'); bot('¿Qué examen necesitas?') }}>Agendar un examen</button>
      <button className="sbtn ghost sm" onClick={() => { me('Envío mi orden médica'); setStep('order'); bot('Envíame la foto o el PDF de la orden y yo leo los datos.') }}>Enviar orden médica (foto)</button>
      <button className="sbtn ghost sm" onClick={() => { me('Quiero hablar con una persona'); setStep('human'); bot('Te paso con una persona del equipo. Ya les dejé tu conversación para que no repitas nada.') }}>Hablar con una persona</button>
    </div>
  )

  return (
    <div className="app" style={{ background: '#e7ded4' }}>
      <div className="app-top" style={{ background: '#1f7a5c' }}><div><h3>Sofía · IPS Sendero Vital</h3><small>chat de WhatsApp (simulado)</small></div></div>
      <div className="app-body">
        {log.map((m, i) => <div key={i} style={{ alignSelf: m.f === 'me' ? 'flex-end' : 'flex-start', maxWidth: '88%', background: m.f === 'me' ? '#d8f4c9' : '#fff', padding: '8px 12px', borderRadius: 12, fontSize: 13 }}>{m.t}</div>)}
        {step === 'consent' && <button className="sbtn sm" onClick={() => { me('Sí, autorizo'); setStep('menu'); bot('Gracias. ¿En qué te ayudo hoy?') }}>Sí, autorizo</button>}
        {step === 'menu' && menu}
        {step === 'exam' && EXAMS.map((e) => <button key={e.id} className="sbtn ghost sm" onClick={() => { me(e.name); setPick({ exam: e }); setStep('slot'); bot(`${e.name}. ${e.prep} Estos son los horarios libres:`) }}>{e.name}</button>)}
        {step === 'slot' && <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>{SLOTS.map((s) => <button key={s} className="sbtn ghost sm" onClick={() => { me(s); onBook({ who: 'Paciente nuevo', exam: pick.exam.name, slot: s, via: 'WhatsApp' }); setLastBooked(s); setStep('menu'); bot(`Listo, quedó tu ${pick.exam.name} el ${s}. Te escribo un día antes para recordarte la preparación.`) }}>{s}</button>)}</div>}
        {step === 'order' && <button className="sbtn sm" onClick={() => { me('📎 orden_medica.jpg'); setStep('menu'); bot('Leí la orden: Resonancia de rodilla derecha, solicitada por Dr. A. Ramírez (ficticio). ¿Quieres que busque horario?') }}>Adjuntar orden de ejemplo</button>}
        {step === 'human' && <div className="pill warn" style={{ alignSelf: 'flex-start' }}>Conversación transferida a una persona</div>}
        {step === 'human' && <button className="sbtn ghost sm" onClick={() => setStep('menu')}>Volver al asistente</button>}
        {lastBooked && step === 'menu' && <div className="sub">Último agendamiento: {lastBooked}</div>}
        <div ref={end} />
      </div>
    </div>
  )
}

export default function Sofia() {
  const [appts, setAppts] = useState(SEED)
  const [turns, setTurns] = useState(214)
  const [tier, setTier] = useState('eco')
  const [view, setView] = useState('agenda')
  const T = TIERS[tier]
  const monthly = (conv) => (conv * T.per * 6).toFixed(2)
  const book = (a) => setAppts((l) => [...l, { ...a, id: Date.now() }])

  return (
    <div className="slothy-split" style={{ gridTemplateColumns: 'minmax(0, 5fr) minmax(0, 6fr)' }}>
      <div className="slothy-chat"><Chat onBook={book} onTurn={() => setTurns((n) => n + 1)} /></div>
      <div className="slothy-panel">
        <div className="app" style={{ '--app': '#1f7a5c' }}>
          <div className="app-top" style={{ background: '#1f7a5c' }}><h3>Administración</h3><small>datos de ejemplo</small></div>
          <div style={{ display: 'flex', gap: 6, padding: '10px 14px 0' }}>
            {[['agenda', 'Agenda'], ['consumo', 'Consumo de IA']].map(([id, l]) => <button key={id} className={`sbtn sm ${view === id ? '' : 'ghost'}`} onClick={() => setView(id)}>{l}</button>)}
          </div>
          <div className="app-body">
            {view === 'agenda' && (
              <>
                <div className="sub">{appts.length} citas esta semana</div>
                {[...appts].sort((a, b) => SLOTS.concat(['Lun 9:00']).indexOf(a.slot) - SLOTS.concat(['Lun 9:00']).indexOf(b.slot)).map((a) => (
                  <div key={a.id} className="card row"><div><strong>{a.slot} · {a.exam}</strong><div className="sub">{a.who}</div></div><span className={`pill ${a.via === 'WhatsApp' ? 'ok' : ''}`}>{a.via}</span></div>
                ))}
              </>
            )}
            {view === 'consumo' && (
              <>
                <div className="h">Nivel de IA</div>
                <div style={{ display: 'flex', gap: 6 }}>{Object.entries(TIERS).map(([k, v]) => <button key={k} className={`sbtn sm ${tier === k ? '' : 'ghost'}`} onClick={() => setTier(k)}>{v.label}</button>)}</div>
                <div className="sub">{T.note}</div>
                <div className="row">
                  <div className="card" style={{ flex: 1 }}><div className="sub">Mensajes atendidos</div><strong style={{ fontSize: 22 }}>{turns}</strong></div>
                  <div className="card" style={{ flex: 1 }}><div className="sub">Costo estimado / mes</div><strong style={{ fontSize: 22 }}>US$ {monthly(turns)}</strong></div>
                </div>
                <div className="sub">Cada mensaje que escribes en el chat suma al contador. El costo cambia según el nivel de IA elegido.</div>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
