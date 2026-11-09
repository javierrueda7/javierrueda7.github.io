import { useState } from 'react'
import { cop } from '../lib/ui.jsx'

const SERVICES = [
  { id: 1, title: 'Reparación de fuga', pro: 'Marta P.', cat: 'Plomería', price: 80000, rate: 4.9, km: 1.2 },
  { id: 2, title: 'Instalación de lámpara', pro: 'Julián R.', cat: 'Electricidad', price: 60000, rate: 4.7, km: 2.8 },
  { id: 3, title: 'Limpieza profunda', pro: 'Daniela S.', cat: 'Aseo', price: 110000, rate: 4.8, km: 3.5 },
]
const PIN = '4821'
const FLOW = ['Solicitada', 'Aceptada', 'Pago en custodia', 'En el sitio', 'Completada']

export default function Atdoor() {
  const [role, setRole] = useState('client')
  const [svc, setSvc] = useState(null)
  const [step, setStep] = useState(-1) // índice en FLOW
  const [pinIn, setPinIn] = useState('')
  const [pinErr, setPinErr] = useState(false)
  const [sos, setSos] = useState(false)
  const [disputes, setDisputes] = useState([{ id: 1, who: 'Laura M. vs. Sergio T.', why: 'Servicio incompleto', amount: 95000, state: 'Abierta' }])
  const [verifs, setVerifs] = useState([{ id: 1, who: 'Paola V.', doc: 'Cédula + selfie', state: 'Pendiente' }, { id: 2, who: 'Iván C.', doc: 'Cédula + antecedentes', state: 'Pendiente' }])

  const book = (s) => { setSvc(s); setStep(0); setPinIn(''); setPinErr(false) }
  const reset = () => { setSvc(null); setStep(-1); setSos(false) }
  const tryPin = (e) => { e.preventDefault(); if (pinIn === PIN) { setStep(4); setPinErr(false) } else setPinErr(true) }

  return (
    <div className="app" style={{ background: '#f2f4f7' }}>
      <div className="app-top">
        <h3>Atdoor</h3>
        <div style={{ display: 'flex', gap: 4 }}>
          {[['client', 'Cliente'], ['pro', 'Proveedora'], ['admin', 'Admin']].map(([id, l]) => (
            <button key={id} onClick={() => setRole(id)} aria-pressed={role === id} className="sbtn sm" style={{ background: role === id ? '#fff' : 'transparent', color: role === id ? 'var(--app)' : '#fff', border: '1px solid #ffffff88' }}>{l}</button>
          ))}
        </div>
      </div>
      <div className="app-body">
        {svc && (
          <div className="card">
            <div className="row"><strong>{svc.title}</strong><span className="pill">{FLOW[step]}</span></div>
            <div style={{ display: 'flex', gap: 3, margin: '8px 0' }}>{FLOW.map((_, i) => <div key={i} style={{ flex: 1, height: 5, borderRadius: 9, background: i <= step ? 'var(--app)' : '#dfe3e8' }} />)}</div>
            <div className="sub">{svc.pro} · {cop(svc.price)}</div>
          </div>
        )}

        {role === 'client' && step === -1 && (
          <>
            <div className="h">Servicios cerca de ti</div>
            {SERVICES.map((s) => (
              <div key={s.id} className="card">
                <div className="row"><strong>{s.title}</strong><strong>{cop(s.price)}</strong></div>
                <div className="sub">{s.pro} · {s.cat} · ★ {s.rate} · {s.km} km · <span style={{ color: '#25623d' }}>identidad verificada</span></div>
                <button className="sbtn sm" style={{ marginTop: 8 }} onClick={() => book(s)}>Solicitar</button>
              </div>
            ))}
          </>
        )}
        {role === 'client' && step === 0 && <div className="empty">Esperando que {svc.pro} acepte. Cambia a <b>Proveedora</b>.</div>}
        {role === 'client' && step === 1 && (
          <div className="card"><div className="h">{svc.pro} aceptó</div><div className="sub" style={{ margin: '4px 0 8px' }}>Tu dinero queda en custodia y solo se libera cuando confirmes el servicio.</div><button className="sbtn" onClick={() => setStep(2)}>Pagar {cop(svc.price)} (pasarela de prueba)</button></div>
        )}
        {role === 'client' && step === 2 && (
          <div className="card" style={{ textAlign: 'center' }}><div className="sub">Tu PIN de seguridad</div><div style={{ fontSize: 40, fontWeight: 800, letterSpacing: 6 }}>{PIN}</div><div className="sub">Díselo a {svc.pro} solo cuando llegue y empiece el trabajo.</div></div>
        )}
        {role === 'client' && step === 3 && <div className="empty">{svc.pro} está en el sitio. Cuando termine, ella libera el pago con tu PIN.</div>}
        {role === 'client' && step === 4 && <div className="card"><div className="h">Servicio completado</div><div className="sub">Pago liberado a {svc.pro}. Comisión de la plataforma: {cop(svc.price * 0.1)}.</div><button className="sbtn" style={{ marginTop: 8 }} onClick={reset}>Nueva solicitud</button></div>}
        {role === 'client' && step >= 0 && step < 4 && (
          <button className="sbtn ghost" style={{ borderColor: '#b3402e', color: '#b3402e' }} onClick={() => setSos(true)}>Botón SOS</button>
        )}
        {sos && <div className="card" style={{ background: '#fbe4df' }}><strong>SOS enviado (simulado)</strong><div className="sub">En la app real avisa al equipo de seguridad y a tus contactos de confianza.</div></div>}

        {role === 'pro' && step === -1 && <div className="empty">No tienes solicitudes. Pide un servicio como <b>Cliente</b>.</div>}
        {role === 'pro' && step === 0 && <div className="card"><div className="h">Nueva solicitud de Laura M.</div><div className="sub">{svc.title} · {cop(svc.price)}</div><button className="sbtn" style={{ marginTop: 8 }} onClick={() => setStep(1)}>Aceptar</button></div>}
        {role === 'pro' && step === 1 && <div className="empty">Esperando que la clienta pague.</div>}
        {role === 'pro' && step === 2 && <div className="card"><div className="h">Pago en custodia</div><div className="sub" style={{ margin: '4px 0 8px' }}>Ya puedes ir. Pide el PIN al llegar.</div><button className="sbtn" onClick={() => setStep(3)}>Llegué al sitio</button></div>}
        {role === 'pro' && step === 3 && (
          <form onSubmit={tryPin} className="card" style={{ display: 'grid', gap: 8 }}>
            <div className="h">Termina y libera el pago</div>
            <label className="field">PIN de la clienta (prueba con {PIN})<input inputMode="numeric" maxLength={4} value={pinIn} onChange={(e) => setPinIn(e.target.value)} /></label>
            {pinErr && <div style={{ color: '#b3402e', fontSize: 12 }}>PIN incorrecto.</div>}
            <button className="sbtn">Confirmar</button>
          </form>
        )}
        {role === 'pro' && step === 4 && <div className="card"><div className="h">Cobraste {cop(svc.price * 0.9)}</div><div className="sub">Se descontó la comisión del 10%.</div></div>}

        {role === 'admin' && (
          <>
            <div className="h">Disputas</div>
            {disputes.map((d) => (
              <div key={d.id} className="card">
                <div className="row"><strong>{d.who}</strong><span className={`pill ${d.state === 'Abierta' ? 'warn' : 'ok'}`}>{d.state}</span></div>
                <div className="sub">{d.why} · {cop(d.amount)}</div>
                {d.state === 'Abierta' && <div className="row" style={{ justifyContent: 'flex-start', marginTop: 8 }}>
                  <button className="sbtn sm" onClick={() => setDisputes((l) => l.map((x) => x.id === d.id ? { ...x, state: 'Reembolsada' } : x))}>Reembolsar</button>
                  <button className="sbtn ghost sm" onClick={() => setDisputes((l) => l.map((x) => x.id === d.id ? { ...x, state: 'Liberada' } : x))}>Liberar al proveedor</button>
                </div>}
              </div>
            ))}
            <div className="h">Verificaciones de identidad</div>
            {verifs.map((v) => (
              <div key={v.id} className="card row">
                <div><strong>{v.who}</strong><div className="sub">{v.doc}</div></div>
                {v.state === 'Pendiente' ? <button className="sbtn sm" onClick={() => setVerifs((l) => l.map((x) => x.id === v.id ? { ...x, state: 'Aprobada' } : x))}>Aprobar</button> : <span className="pill ok">{v.state}</span>}
              </div>
            ))}
          </>
        )}
      </div>
    </div>
  )
}
