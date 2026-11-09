import { useEffect, useMemo, useRef, useState } from 'react'
import './slothy.css'

// "Peluquería La Esquina", clientes, precios y citas son inventados.
const SERVICES = [
  { id: 'cm', name: 'Corte de mujer', cat: 'Cabello', min: 60, price: 45000, pros: ['Andrés', 'Camila'], desc: 'Lavado, corte y secado.' },
  { id: 'ch', name: 'Corte de hombre', cat: 'Cabello', min: 45, price: 30000, pros: ['Andrés', 'Camila'], desc: 'Lavado, corte y peinado.' },
  { id: 'ab', name: 'Arreglo de barba', cat: 'Cabello', min: 30, price: 20000, pros: ['Andrés', 'Camila'], desc: 'Perfilado y vapor.' },
  { id: 'ti', name: 'Tinte', cat: 'Color', min: 90, price: 120000, pros: ['Andrés', 'Camila'], desc: 'Color completo con tratamiento.' },
  { id: 'ma', name: 'Manicure', cat: 'Uñas', min: 60, price: 35000, pros: ['Valentina (manos y pies)'], desc: 'Limpieza y esmaltado.' },
  { id: 'pe', name: 'Pedicure', cat: 'Uñas', min: 60, price: 40000, pros: ['Valentina (manos y pies)'], desc: 'Limpieza, exfoliación y esmaltado.' },
]
const PROS = ['Andrés', 'Camila', 'Valentina (manos y pies)']
const DOW = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom']
const dow = (d) => (((d - 9) % 7) + 7) % 7
const svc = (id) => SERVICES.find((s) => s.id === id)
const money = (n) => '$' + Math.round(n).toLocaleString('es-CO')
const hm = (t) => { const h = Math.floor(t / 60), m = t % 60; return `${h % 12 || 12}:${String(m).padStart(2, '0')} ${h < 12 ? 'a. m.' : 'p. m.'}` }
const dlabel = (d) => (d === 9 ? 'hoy' : d === 10 ? 'mañana' : `${DOW[dow(d)]} ${d} nov`)
const initials = (n) => n.split(' ').filter(Boolean).map((p) => p[0]).slice(0, 2).join('').toUpperCase()
const SLOTS = Array.from({ length: 10 }, (_, i) => 540 + i * 60)
const FULL = [14]

const seed = [
  [9, 540, 'Rosa Elena Torres', 'cm', 'Andrés'], [9, 900, 'Fabio Nelson Ramírez', 'cm', 'Andrés'], [9, 990, 'Hernando Pérez', 'ti', 'Andrés'], [9, 1080, 'Claudia Patricia Cárdenas', 'ab', 'Camila'],
  [10, 540, 'Rosa Elena Torres', 'ch', 'Andrés'], [10, 600, 'Gloria Esperanza Moreno', 'ma', 'Valentina (manos y pies)'], [10, 780, 'Beatriz Cano', 'ma', 'Valentina (manos y pies)'],
  [11, 600, 'Ximena Duarte', 'pe', 'Valentina (manos y pies)'], [11, 720, 'Andrés Felipe Ruiz', 'ab', 'Camila'], [12, 600, 'Marcela Quintero', 'cm', 'Camila'], [12, 840, 'Julián Mendoza', 'ch', 'Andrés'], [13, 540, 'Sofía Ardila', 'ti', 'Andrés'],
].map(([date, t, client, s, pro], i) => ({ id: i + 1, date, t, client, svc: s, pro, src: 'panel', status: 'prog', dur: svc(s).min, phone: '300 000 00' + String(i).padStart(2, '0') }))

const I = {
  home: 'M3 11l9-8 9 8M5 10v10h5v-6h4v6h5V10', cal: 'M4 7h16v13H4zM4 11h16M8 3v4M16 3v4', list: 'M8 6h13M8 12h13M8 18h13M3 6h.01M3 12h.01M3 18h.01',
  users: 'M16 11a3 3 0 100-6M8 11a3 3 0 100-6M2 20c0-3 3-5 6-5s6 2 6 5M16 15c3 0 6 2 6 5', tag: 'M3 12V4h8l10 10-8 8L3 12zm5-4h.01', cash: 'M3 7h18v10H3zM12 9.5a2.5 2.5 0 100 5 2.5 2.5 0 000-5z',
  moon: 'M20 14A8 8 0 1110 4a7 7 0 0010 10z', user: 'M12 12a4 4 0 100-8 4 4 0 000 8zm-8 9c0-4 4-6 8-6s8 2 8 6',
}
const Ic = ({ n }) => <svg viewBox="0 0 24 24" aria-hidden="true"><path d={I[n]} /></svg>

const overlap = (a, ad, b, bd) => a < b + bd && b < a + ad
function useAvail(appts) {
  const free = (date, t, s) => s.pros.some((p) => !appts.some((a) => a.date === date && a.pro === p && a.status !== 'cancel' && overlap(a.t, a.dur, t, s.min)) && !(date === 9 && t < 600))
  const day = (date, s) => {
    if (date < 9) return 'past'
    if (dow(date) === 6) return 'cerrado'
    if (FULL.includes(date)) return 'lleno'
    const n = SLOTS.filter((t) => free(date, t, s)).length
    return n === 0 ? 'lleno' : n <= 3 ? 'pocos' : 'cupo'
  }
  return { free, day }
}

function Chat({ appts, onBook, onCancel }) {
  const [log, setLog] = useState([])
  const [step, setStep] = useState('consent')
  const [pick, setPick] = useState({})
  const [form, setForm] = useState({ name: '', phone: '' })
  const [month] = useState(0)
  const end = useRef(null)
  const { free, day } = useAvail(appts)
  useEffect(() => { end.current?.scrollIntoView({ block: 'end' }) }, [log, step])
  const say = (f, t) => setLog((l) => [...l, { f, t }])
  const bot = (t) => setTimeout(() => say('bot', t), 250)
  const mine = appts.filter((a) => a.mine && a.status !== 'cancel')
  const reset = () => { setLog([]); setStep('consent'); setPick({}) }
  const toMenu = (t) => { setStep('menu'); if (t) bot(t) }

  const days = useMemo(() => { const a = Array(6).fill(null); for (let d = 1; d <= 30; d++) a.push(d); return a }, [])

  return (
    <div className="sl-chat">
      <div className="sl-chead">
        <span className="sl-cav">P</span>
        <div style={{ flex: 1, minWidth: 0 }}><b style={{ font: '700 15px Sora, sans-serif' }}>Peluquería La Esquina</b><div style={{ fontSize: 12, color: 'var(--muted)' }}><span style={{ color: '#2db57a' }}>●</span> Slothy · en línea las 24 horas</div></div>
        <button className="sl-btn sm" onClick={reset}>Empezar de nuevo</button>
      </div>
      <div className="sl-cmsgs">
        {step === 'consent' ? (
          <div className="sl-card" style={{ padding: 14, display: 'grid', gap: 8 }}>
            <small style={{ color: 'var(--muted)', fontWeight: 600 }}>Antes de empezar</small>
            <b style={{ font: '700 15px Sora, sans-serif' }}>Hola, soy Slothy, el asistente de Peluquería La Esquina.</b>
            <div style={{ fontSize: 13, color: 'var(--ink2)' }}>Para ayudarte a agendar voy a guardar tu nombre y celular. Los usamos solo para gestionar tu cita.</div>
            <div style={{ display: 'flex', gap: 8 }}><button className="sl-btn pri" onClick={() => { setLog([{ f: 'bot', t: 'Gracias, tu autorización quedó registrada.' }, { f: 'bot', t: 'Hola, soy Slothy, asistente virtual de Peluquería La Esquina. Puedo ayudarte a hacer una cita, consultarla o cancelarla, y resolver tus dudas. ¿En qué te ayudo?' }]); setStep('menu') }}>Autorizo</button><button className="sl-btn" onClick={() => setLog([{ f: 'bot', t: 'Sin tu autorización no puedo agendar, pero puedes llamarnos o escribirnos por WhatsApp.' }])}>No autorizo</button></div>
          </div>
        ) : log.map((m, i) => <div key={i} className={`sl-b ${m.f === 'me' ? 'me' : ''}`}>{m.t}</div>)}

        {step === 'menu' && (
          <>
            <button className="sl-opt" onClick={() => { say('me', 'Hacer una cita'); setStep('svc') }}><b>Hacer una cita</b><span>Elige servicio, día y hora</span></button>
            <button className="sl-opt" onClick={() => { say('me', 'Mis citas'); setStep('mine') }}><b>Mis citas</b><span>Consulta, cambia o cancela</span></button>
            <button className="sl-opt" onClick={() => { say('me', 'Servicios y precios'); bot(SERVICES.map((s) => `${s.name} · ${s.min} min · ${money(s.price)}`).join('\n')) }}><b>Servicios y precios</b><span>Qué ofrecemos y cuánto cuesta</span></button>
            <button className="sl-opt" onClick={() => { say('me', 'Tengo una pregunta'); bot('Atendemos de lunes a sábado, de 9:00 a. m. a 7:00 p. m. Estamos en Cabecera, Calle 45 #30-12 (dirección de ejemplo). Hay parqueadero cerca.') }}><b>Tengo una pregunta</b><span>Horarios, ubicación y más</span></button>
          </>
        )}
        {step === 'svc' && (
          <div className="sl-card" style={{ padding: 12, display: 'grid', gap: 8 }}>
            <small style={{ color: 'var(--muted)', fontWeight: 600 }}>Paso 1 de 4</small><b style={{ font: '700 15px Sora, sans-serif' }}>¿Qué servicio quieres?</b>
            {['Cabello', 'Color', 'Uñas'].map((c) => (
              <div key={c} style={{ display: 'grid', gap: 6 }}><div className="sl-gl" style={{ padding: '4px 0 0' }}>{c}</div>
                {SERVICES.filter((s) => s.cat === c).map((s) => <button key={s.id} className="sl-opt" onClick={() => { say('me', s.name); setPick({ s }); setStep('day') }}><b>{s.name}</b><span>{s.min} min · {money(s.price)}</span></button>)}
              </div>
            ))}
            <button className="sl-btn sm" style={{ justifySelf: 'start' }} onClick={() => toMenu()}>← Atrás</button>
          </div>
        )}
        {step === 'day' && (
          <div className="sl-card" style={{ padding: 12, display: 'grid', gap: 8 }}>
            <small style={{ color: 'var(--muted)', fontWeight: 600 }}>Paso 2 de 4</small><b style={{ font: '700 15px Sora, sans-serif' }}>{pick.s.name}: elige el día y la hora</b>
            <div style={{ textAlign: 'center', fontWeight: 700 }}>Noviembre de 2026</div>
            <div className="sl-cal">
              {DOW.map((d) => <b key={d}>{d.toUpperCase()}</b>)}
              {days.map((d, i) => d === null ? <span key={i} /> : (() => { const st = d < 9 ? 'past' : day(d, pick.s); return <button key={d} disabled={st === 'past' || st === 'cerrado' || st === 'lleno'} className={`sl-day ${st === 'cupo' ? '' : st} ${pick.d === d ? 'sel' : ''}`} onClick={() => setPick({ ...pick, d, t: undefined })}>{d}{st === 'lleno' && <small>lleno</small>}{st === 'cerrado' && <small>cerrado</small>}</button> })())}
            </div>
            <div style={{ fontSize: 11, color: 'var(--muted)' }}>Verde: hay cupo · Amarillo: pocos cupos · Rojo: lleno · Rayado: cerrado</div>
            {!pick.d ? <div style={{ color: 'var(--ink2)', fontSize: 13 }}>Toca un día verde o amarillo para ver las horas.</div> : (
              <div style={{ display: 'grid', gap: 6 }}>
                {[['Por la mañana', (t) => t < 720], ['Por la tarde', (t) => t >= 720 && t < 1080], ['Por la noche', (t) => t >= 1080]].map(([g, f]) => { const ts = SLOTS.filter(f).filter((t) => free(pick.d, t, pick.s)); return ts.length ? <div key={g}><div className="sl-gl" style={{ padding: '2px 0' }}>{g}</div><div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>{ts.map((t) => <button key={t} className="sl-btn sm" onClick={() => { setPick({ ...pick, t }); setStep('data'); say('me', `${dlabel(pick.d)} · ${hm(t)}`) }}>{hm(t)}</button>)}</div></div> : null })}
              </div>
            )}
            <button className="sl-btn sm" style={{ justifySelf: 'start' }} onClick={() => setStep('svc')}>← Atrás</button>
          </div>
        )}
        {step === 'data' && (
          <form className="sl-card" style={{ padding: 12, display: 'grid', gap: 8 }} onSubmit={(e) => { e.preventDefault(); if (form.name.trim() && form.phone.trim()) setStep('confirm') }}>
            <small style={{ color: 'var(--muted)', fontWeight: 600 }}>Paso 3 de 4</small><b style={{ font: '700 15px Sora, sans-serif' }}>Tus datos</b>
            <label className="sl-f">Tu nombre<input value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} /></label>
            <label className="sl-f">Tu celular<input inputMode="tel" value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} /></label>
            <button className="sl-btn pri" disabled={!form.name.trim() || !form.phone.trim()}>Continuar</button>
            <button type="button" className="sl-btn sm" style={{ justifySelf: 'start' }} onClick={() => setStep('day')}>← Atrás</button>
          </form>
        )}
        {step === 'confirm' && (
          <div className="sl-card" style={{ padding: 12, display: 'grid', gap: 6 }}>
            <small style={{ color: 'var(--muted)', fontWeight: 600 }}>Paso 4 de 4</small><b style={{ font: '700 15px Sora, sans-serif' }}>Revisa y confirma</b>
            {[['Servicio', pick.s.name], ['Día', `${DOW[dow(pick.d)]} ${pick.d} nov`], ['Hora', hm(pick.t)], ['A nombre de', form.name], ['Precio', money(pick.s.price)]].map(([k, v]) => <div key={k} className="pl-row" style={{ display: 'flex', justifyContent: 'space-between' }}><span style={{ color: 'var(--muted)' }}>{k}</span><b>{v}</b></div>)}
            <button className="sl-btn pri" onClick={() => {
              const pro = pick.s.pros.find((p) => free(pick.d, pick.t, { ...pick.s, pros: [p] }))
              onBook({ date: pick.d, t: pick.t, client: form.name.trim(), phone: form.phone, svc: pick.s.id, pro, dur: pick.s.min })
              say('bot', `Listo, ${form.name.trim().split(' ')[0]}. Tu cita de ${pick.s.name} quedó el ${dlabel(pick.d)} a las ${hm(pick.t)} con ${pro.split(' (')[0]}.`)
              setStep('done')
            }}>Confirmar cita</button>
            <button className="sl-btn sm" style={{ justifySelf: 'start' }} onClick={() => setStep('data')}>← Atrás</button>
          </div>
        )}
        {step === 'done' && <button className="sl-btn pri" onClick={() => toMenu('¿Te ayudo con algo más?')}>Volver al inicio</button>}
        {step === 'mine' && (
          <div className="sl-card" style={{ padding: 12, display: 'grid', gap: 8 }}>
            <b style={{ font: '700 15px Sora, sans-serif' }}>Mis citas</b>
            {mine.length === 0 && <div style={{ color: 'var(--ink2)' }}>No tienes citas todavía. Reserva una desde «Hacer una cita».</div>}
            {mine.map((a) => <div key={a.id} className="sl-row" style={{ padding: '6px 0' }}><div style={{ flex: 1 }}><b>{svc(a.svc).name}</b><div style={{ fontSize: 12, color: 'var(--muted)' }}>{dlabel(a.date)} · {hm(a.t)} · {a.pro.split(' (')[0]}</div></div><button className="sl-btn sm danger" onClick={() => onCancel(a.id)}>Cancelar</button></div>)}
            <button className="sl-btn sm" style={{ justifySelf: 'start' }} onClick={() => toMenu()}>← Atrás</button>
          </div>
        )}
        <div ref={end} />
      </div>
      <div className="sl-foot">Asistente virtual con inteligencia artificial (en esta demo sigue un guion). Tus datos se usan solo para gestionar tu cita.</div>
    </div>
  )
}

function Biz({ appts, setAppts, dark }) {
  const [page, setPage] = useState('resumen')
  const [pro, setPro] = useState('all')
  const [sel, setSel] = useState(null)
  const [nu, setNu] = useState(false)
  const [f, setF] = useState({ client: '', svc: 'ch', date: 9, t: 660 })
  const [tab, setTab] = useState('hoy')
  const { free } = useAvail(appts)

  const live = appts.filter((a) => a.status !== 'cancel')
  const today = live.filter((a) => a.date === 9)
  const upcoming = [...live].filter((a) => a.status === 'prog').sort((a, b) => a.date - b.date || a.t - b.t)
  const revenue = (list) => list.reduce((s, a) => s + svc(a.svc).price, 0)
  const clients = useMemo(() => { const m = {}; appts.forEach((a) => { m[a.client] ??= { n: a.client, v: 0, last: a.date, nolleg: 0 }; m[a.client].v++; if (a.status === 'noshow') m[a.client].nolleg++ }); return Object.values(m).sort((a, b) => b.v - a.v || a.n.localeCompare(b.n)) }, [appts])
  const upd = (id, patch) => { setAppts((l) => l.map((a) => (a.id === id ? { ...a, ...patch } : a))); setSel(null) }
  const create = (e) => {
    e.preventDefault()
    const s = svc(f.svc)
    const p = s.pros.find((x) => free(+f.date, +f.t, { ...s, pros: [x] }))
    if (!f.client.trim()) return
    if (!p) return alert('No hay profesional libre a esa hora.')
    setAppts((l) => [...l, { id: Date.now(), date: +f.date, t: +f.t, dur: s.min, client: f.client.trim(), svc: s.id, pro: p, src: 'panel', status: 'prog', phone: '' }])
    setNu(false); setF({ ...f, client: '' }); setPage('agenda')
  }

  const nav = [[null, [['resumen', 'Resumen', 'home'], ['agenda', 'Agenda', 'cal'], ['citas', 'Citas', 'list'], ['clientes', 'Clientes', 'users']]], ['Mi negocio', [['servicios', 'Servicios', 'tag']]], ['Resultados', [['ingresos', 'Ingresos', 'cash']]]]
  const title = { resumen: 'Resumen', agenda: 'Agenda', citas: 'Citas', clientes: 'Clientes', servicios: 'Servicios', ingresos: 'Ingresos' }[page]
  const byDay = [9, 10, 11, 12, 13, 14, 15].map((d) => ({ d, v: revenue(live.filter((a) => a.date === d)) }))
  const maxV = Math.max(1, ...byDay.map((x) => x.v))

  return (
    <div className="sl-biz">
      <aside className="sl-side">
        <div className="sl-brand"><span className="sl-logo"><i /></span><div><b>Peluquería La Esquina</b><small>Dueño</small></div></div>
        {nav.map(([g, items]) => <div key={g ?? 'x'}>{g && <div className="sl-gl">{g}</div>}{items.map(([id, l, ic]) => <button key={id} className={`sl-item ${page === id ? 'on' : ''}`} onClick={() => setPage(id)}><Ic n={ic} />{l}</button>)}</div>)}
      </aside>
      <div className="sl-main">
        <div className="sl-top"><h2>{title}</h2></div>
        <div className="sl-cont">
          {page === 'resumen' && (
            <>
              <div className="pl-row" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end' }}><div><div style={{ color: 'var(--muted)' }}>Lunes 9 de noviembre</div><b style={{ font: '700 20px Sora, sans-serif' }}>Así va el día</b></div><button className="sl-btn pri" onClick={() => setNu(true)}>+ Nueva cita</button></div>
              <div className="sl-stats">
                <div className="sl-stat"><b>{today.filter((a) => a.status === 'prog').length}</b><span>citas pendientes hoy</span><small>{today.filter((a) => a.status === 'asistio').length} ya atendidas</small></div>
                <div className="sl-stat"><b>{appts.filter((a) => a.status === 'noshow').length}</b><span>No llegaron</span><small>{appts.filter((a) => a.status === 'cancel').length} canceladas</small></div>
                <div className="sl-stat"><b>{appts.filter((a) => a.src === 'chat').length}</b><span>Nuevas por el chat</span><small>reservadas por clientes</small></div>
                <div className="sl-stat"><b>{money(revenue(appts.filter((a) => a.status === 'asistio' && a.date === 9)))}</b><span>Ingresos hoy</span><small>{money(revenue(live))} en la semana</small></div>
              </div>
              <div className="sl-card"><div className="sl-cab">Próximas citas <a onClick={() => setPage('agenda')}>Ver agenda</a></div>
                {upcoming.slice(0, 5).map((a) => <div key={a.id} className="sl-row"><span className="sl-av">{initials(a.client)}</span><div style={{ flex: 1, minWidth: 0 }}><b>{a.client}</b><div style={{ fontSize: 12, color: 'var(--muted)' }}>{svc(a.svc).name} · {a.pro.split(' (')[0]}</div></div><div style={{ textAlign: 'right', fontSize: 12 }}>{dlabel(a.date)}<br /><b>{hm(a.t)}</b></div></div>)}
              </div>
              <div className="sl-card"><div className="sl-cab">Tu plan este mes <span className="sl-tag ok">Dentro del plan</span></div>
                <div style={{ padding: 14 }}><div className="pl-row" style={{ display: 'flex', justifyContent: 'space-between' }}>Citas hechas por el chat<b>{appts.filter((a) => a.src === 'chat').length + 9} de 30</b></div><div className="sl-prog"><i style={{ width: `${((appts.filter((a) => a.src === 'chat').length + 9) / 30) * 100}%` }} /></div></div>
              </div>
            </>
          )}
          {page === 'agenda' && (
            <>
              <div style={{ display: 'flex', gap: 8, alignItems: 'center', flexWrap: 'wrap' }}><b style={{ font: '700 16px Sora, sans-serif' }}>Lun 9 nov – dom 15 nov</b>
                <select className="sl-in" style={{ minHeight: 34 }} aria-label="Profesional" value={pro} onChange={(e) => setPro(e.target.value)}><option value="all">Todos: profesionales</option>{PROS.map((p) => <option key={p}>{p}</option>)}</select>
                <button className="sl-btn pri" onClick={() => setNu(true)}>+ Nueva cita</button></div>
              <div className="sl-card"><div className="sl-grid">
                <div />{[9, 10, 11, 12, 13, 14, 15].map((d) => <div key={d} className={`sl-gh ${d === 9 ? 'today' : ''}`}>{DOW[dow(d)]}<small>{String(d).padStart(2, '0')}</small></div>)}
                <div>{Array.from({ length: 10 }, (_, i) => <div key={i} className="sl-hr">{hm(540 + i * 60).replace(':00 ', ' ')}</div>)}</div>
                {[9, 10, 11, 12, 13, 14, 15].map((d) => (
                  <div key={d} className={`sl-col ${d === 9 ? 'today' : ''}`}>
                    {(() => {
                      const day = appts.filter((x) => x.date === d && x.status !== 'cancel' && (pro === 'all' || x.pro === pro)).sort((x, y) => x.t - y.t)
                      const ends = []
                      const laneOf = new Map()
                      day.forEach((x) => { let l = ends.findIndex((e) => e <= x.t); if (l < 0) { l = ends.length; ends.push(0) } ends[l] = x.t + x.dur; laneOf.set(x.id, l) })
                      const lanes = Math.max(1, ends.length)
                      return day.map((a) => {
                      const lane = laneOf.get(a.id)
                      return <button key={a.id} className={`sl-ev ${a.src === 'chat' ? 'chat' : ''}`} onClick={() => setSel(a)} title={`${a.client} · ${svc(a.svc).name}`} style={{ top: ((a.t - 540) / 60) * 55 + 1, height: Math.max(22, (a.dur / 60) * 55 - 2), left: `${(lane / lanes) * 100}%`, width: `${100 / lanes - 2}%`, opacity: a.status === 'asistio' ? 0.65 : 1, ...(a.status === 'noshow' ? { borderLeftColor: 'var(--bad)', background: 'var(--badbg)' } : {}) }}><b>{hm(a.t).replace(' a. m.', '').replace(' p. m.', '')} {a.client.split(' ')[0]}</b>{svc(a.svc).name}</button>
                      })
                    })()}
                  </div>
                ))}
              </div></div>
              <div style={{ fontSize: 12, color: 'var(--muted)' }}><span style={{ color: 'var(--acc)' }}>■</span> Hecha en el panel · <span style={{ color: 'var(--info)' }}>■</span> Reservada por el chat · <span style={{ color: 'var(--bad)' }}>■</span> No llegó</div>
            </>
          )}
          {page === 'citas' && (
            <>
              <div className="sl-seg">{[['hoy', 'Hoy'], ['semana', 'Esta semana']].map(([id, l]) => <button key={id} className={tab === id ? 'on' : ''} onClick={() => setTab(id)}>{l}</button>)}</div>
              <div className="sl-card">
                {[...appts].filter((a) => tab === 'semana' || a.date === 9).sort((a, b) => a.date - b.date || a.t - b.t).map((a) => (
                  <div key={a.id} className="sl-row"><div style={{ flex: 1, minWidth: 0 }}><b>{a.client}</b><div style={{ fontSize: 12, color: 'var(--muted)' }}>{dlabel(a.date)} · {hm(a.t)} · {svc(a.svc).name} · {a.pro.split(' (')[0]} · {a.src === 'chat' ? 'Chat' : 'Panel'}</div></div>
                    <span className={`sl-tag ${a.status === 'asistio' ? 'ok' : a.status === 'noshow' ? 'mal' : a.status === 'cancel' ? '' : 'info'}`}>{{ prog: 'Programada', asistio: 'Asistió', noshow: 'No llegó', cancel: 'Cancelada' }[a.status]}</span><b>{money(svc(a.svc).price)}</b></div>
                ))}
              </div>
            </>
          )}
          {page === 'clientes' && <div className="sl-card">{clients.map((c) => <div key={c.n} className="sl-row"><span className="sl-av">{initials(c.n)}</span><div style={{ flex: 1 }}><b>{c.n}</b><div style={{ fontSize: 12, color: 'var(--muted)' }}>{c.v} {c.v === 1 ? 'visita' : 'visitas'}</div></div>{c.nolleg > 0 && <span className="sl-tag mal">{c.nolleg} no llegó</span>}</div>)}</div>}
          {page === 'servicios' && ['Cabello', 'Color', 'Uñas'].map((c) => <div key={c} className="sl-card"><div className="sl-cab">{c}</div>{SERVICES.filter((s) => s.cat === c).map((s) => <div key={s.id} className="sl-row"><div style={{ flex: 1 }}><b>{s.name}</b><div style={{ fontSize: 12, color: 'var(--muted)' }}>{s.min} min · {s.pros.length === 1 ? `solo ${s.pros[0].split(' (')[0]}` : `${s.pros.length} profesionales`}</div></div><b>{money(s.price)}</b></div>)}</div>)}
          {page === 'ingresos' && (
            <>
              <div className="sl-stats">
                <div className="sl-stat"><b>{money(revenue(appts.filter((a) => a.status === 'asistio')))}</b><span>Ingresos</span></div>
                <div className="sl-stat"><b>{appts.filter((a) => a.status === 'asistio').length}</b><span>Citas atendidas</span></div>
                <div className="sl-stat"><b>{live.length ? money(revenue(live) / live.length) : '$0'}</b><span>Ticket promedio</span></div>
                <div className="sl-stat"><b>{money(revenue(appts.filter((a) => a.status === 'prog')))}</b><span>Por cobrar (programadas)</span></div>
              </div>
              <div className="sl-card"><div className="sl-cab">Ingresos por día (proyectado)</div><div className="sl-bar">{byDay.map((x) => <div key={x.d}><i style={{ height: `${(x.v / maxV) * 90}px` }} title={money(x.v)} />{DOW[dow(x.d)]}</div>)}</div></div>
              <div className="sl-card"><div className="sl-cab">Por profesional</div><table className="sl-t"><tbody>{PROS.map((p) => <tr key={p}><td>{p.split(' (')[0]}</td><td>{live.filter((a) => a.pro === p).length} citas</td><td style={{ textAlign: 'right' }}><b>{money(revenue(live.filter((a) => a.pro === p)))}</b></td></tr>)}</tbody></table></div>
            </>
          )}
        </div>
      </div>
      {sel && (
        <div className="sl-mod" onClick={() => setSel(null)}><div onClick={(e) => e.stopPropagation()}>
          <b style={{ font: '700 16px Sora, sans-serif' }}>{sel.client}</b>
          <div style={{ color: 'var(--ink2)' }}>{svc(sel.svc).name} · {sel.pro.split(' (')[0]}<br />{dlabel(sel.date)} · {hm(sel.t)} · {money(svc(sel.svc).price)}<br />Origen: {sel.src === 'chat' ? 'chat del cliente' : 'panel'}</div>
          <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}><button className="sl-btn pri sm" onClick={() => upd(sel.id, { status: 'asistio' })}>Asistió</button><button className="sl-btn sm" onClick={() => upd(sel.id, { status: 'noshow' })}>No llegó</button><button className="sl-btn sm danger" onClick={() => upd(sel.id, { status: 'cancel' })}>Cancelar cita</button><button className="sl-btn sm ghost" onClick={() => setSel(null)}>Cerrar</button></div>
        </div></div>
      )}
      {nu && (
        <div className="sl-mod" onClick={() => setNu(false)}><form onClick={(e) => e.stopPropagation()} onSubmit={create} style={{ background: 'var(--surf)', borderRadius: 16, padding: 16, width: 'min(380px,92%)', display: 'grid', gap: 10 }}>
          <b style={{ font: '700 16px Sora, sans-serif' }}>Nueva cita</b>
          <label className="sl-f">Cliente<input value={f.client} onChange={(e) => setF({ ...f, client: e.target.value })} placeholder="Nombre completo" autoFocus /></label>
          <label className="sl-f">Servicio<select value={f.svc} onChange={(e) => setF({ ...f, svc: e.target.value })}>{SERVICES.map((s) => <option key={s.id} value={s.id}>{s.name}</option>)}</select></label>
          <div style={{ display: 'flex', gap: 8 }}><label className="sl-f" style={{ flex: 1 }}>Día<select value={f.date} onChange={(e) => setF({ ...f, date: e.target.value })}>{[9, 10, 11, 12, 13, 14].map((d) => <option key={d} value={d}>{dlabel(d)}</option>)}</select></label>
            <label className="sl-f" style={{ flex: 1 }}>Hora<select value={f.t} onChange={(e) => setF({ ...f, t: e.target.value })}>{SLOTS.map((t) => <option key={t} value={t}>{hm(t)}</option>)}</select></label></div>
          <div style={{ display: 'flex', gap: 6 }}><button className="sl-btn pri">Guardar cita</button><button type="button" className="sl-btn" onClick={() => setNu(false)}>Cancelar</button></div>
        </form></div>
      )}
    </div>
  )
}

export default function Slothy() {
  const [appts, setAppts] = useState(seed)
  const [view, setView] = useState('cust')
  const [dark, setDark] = useState(false)
  const book = (a) => setAppts((l) => [...l, { ...a, id: Date.now(), src: 'chat', status: 'prog', mine: true }])
  const cancel = (id) => setAppts((l) => l.map((a) => (a.id === id ? { ...a, status: 'cancel' } : a)))
  return (
    <div className={`sl ${dark ? 'dark' : ''}`} style={{ position: 'relative' }}>
      <div className="sl-switch">
        <span className="sl-seg">{[['cust', 'Soy un cliente'], ['biz', 'Soy el negocio']].map(([id, l]) => <button key={id} className={view === id ? 'on' : ''} onClick={() => setView(id)}>{l}</button>)}</span>
        <span className="sp" />
        <button className="sl-btn sm ghost" aria-label="Cambiar tema" onClick={() => setDark(!dark)}><svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="1.8" aria-hidden="true"><path d={I.moon} /></svg></button>
      </div>
      {view === 'cust' ? <div className="sl-cust"><Chat appts={appts} onBook={book} onCancel={cancel} /></div> : <Biz appts={appts} setAppts={setAppts} dark={dark} />}
    </div>
  )
}
