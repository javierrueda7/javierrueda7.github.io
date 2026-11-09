import { useMemo, useState } from 'react'
import './atdoor.css'

// Servicios, proveedores, clientes y reservas son inventados. La interfaz sigue la app real.
const P = {
  tools: 'M14 6a4 4 0 105 5l-9 9a2.1 2.1 0 01-3-3l9-9zM3 21l3-3',
  cal: 'M4 7h16v13H4zM4 11h16M8 3v4M16 3v4',
  chat: 'M21 12a8 8 0 01-11.5 7.2L4 20l1-4.4A8 8 0 1121 12z',
  user: 'M12 12a4 4 0 100-8 4 4 0 000 8zm-8 9c0-4 4-6 8-6s8 2 8 6',
  map: 'M9 4L3 6v14l6-2 6 2 6-2V4l-6 2-6-2zm0 0v14m6-12v14',
  search: 'M11 4a7 7 0 100 14 7 7 0 000-14zm9 16l-4-4',
}
const Ico = ({ n }) => <svg viewBox="0 0 24 24" aria-hidden="true"><path d={P[n]} /></svg>
const money = (n) => '$ ' + Math.round(n).toLocaleString('es-CO')

const CATS = ['Todos', 'Hogar', 'Reparaciones', 'Vehículos', 'Clases', 'Bienestar']
const SERVICES = [
  { id: 1, cat: 'Bienestar', kind: 'Entrenador personal', title: 'Entrenamiento personal a domicilio', pro: 'Andrés Peña', rate: 4.6, n: 34, price: 55000, unit: '/h', top: false, em: '🏋️', bg: 'linear-gradient(#2b2f55,#e8a79a)', desc: 'Plan de entrenamiento 100% personalizado según tus objetivos. Puedo ir a tu casa, parque o conjunto.', inc: ['Plan nutricional básico', 'Seguimiento por WhatsApp', 'Evaluación física inicial', 'Rutina personalizada'], km: 15 },
  { id: 2, cat: 'Clases', kind: 'Clases particulares', title: 'Clases de guitarra — todos los niveles', pro: 'Laura Gómez', rate: 4.9, n: 52, price: 40000, unit: '/h', top: true, em: '🎸', bg: 'linear-gradient(#5c7fa8,#dfe8ef)', desc: 'Aprende desde cero o mejora tu técnica. Repertorio a tu gusto.', inc: ['Partituras y tablaturas', 'Clase de prueba', 'Seguimiento por audios'], km: 10 },
  { id: 3, cat: 'Hogar', kind: 'Limpieza profunda', title: 'Limpieza profunda post mudanza / post obra', pro: 'Daniela Soto', rate: 4.8, n: 61, price: 120000, unit: '', top: true, em: '🧼', bg: 'linear-gradient(#3b8ed0,#bcd8ee)', desc: 'Dejamos tu espacio listo para habitar. Incluye insumos.', inc: ['Insumos de aseo', 'Equipo de 2 personas', 'Garantía de 48 horas'], km: 20 },
  { id: 4, cat: 'Reparaciones', kind: 'Plomería', title: 'Plomería — reparaciones y urgencias', pro: 'Camilo Arias', rate: 4.7, n: 88, price: 90000, unit: '/h', top: false, em: '🚰', bg: 'linear-gradient(#45806f,#cfe4da)', desc: 'Fugas, grifería, sanitarios y destapes.', inc: ['Diagnóstico gratis', 'Materiales a precio de costo', 'Garantía de 30 días'], km: 12 },
  { id: 5, cat: 'Vehículos', kind: 'Lavado de autos', title: 'Lavado y polichado a domicilio', pro: 'Julián Mora', rate: 4.5, n: 29, price: 60000, unit: '', top: false, em: '🚗', bg: 'linear-gradient(#444,#bbb)', desc: 'Lavamos tu carro en tu parqueadero sin gastar agua de más.', inc: ['Lavado exterior e interior', 'Polichado', 'Aspirado'], km: 10 },
  { id: 6, cat: 'Hogar', kind: 'Instalación', title: 'Instalación de TV en pared y soportes', pro: 'Mateo Cárdenas', rate: 4.8, n: 47, price: 87200, unit: '', top: true, em: '📺', bg: 'linear-gradient(#6b5b95,#d9d2e9)', desc: 'Instalación segura, ocultamos cables si lo necesitas.', inc: ['Soporte incluido', 'Nivelación', 'Prueba final'], km: 18 },
]
const DAYS = [['Hoy', 9], ['Mañana', 10], ['Mié', 11], ['Jue', 12], ['Vie', 13], ['Sáb', 14]]
const HOURS = ['7:00', '8:00', '9:00', '10:00', '11:00', '12:00', '14:00', '15:00', '16:00', '17:00', '18:00']
const STATUS = {
  req: ['Esperando al proveedor', 'amb'], acc: ['Aceptada · falta pagar', 'amb'], paid: ['Pago en custodia', ''], done: ['Completada · pago liberado', ''], cancel: ['Cancelada por el cliente', 'red'], claim: ['Reclamo resuelto', 'amb'],
}
const SEEDB = [
  { id: 'a', svc: 6, when: 'martes, 20 de octubre, 10:42', amount: 87200, st: 'done', mine: false },
  { id: 'b', svc: 4, when: 'martes, 20 de octubre, 15:22', amount: 90000, st: 'cancel', mine: false },
  { id: 'c', svc: 6, when: 'martes, 20 de octubre, 6:10', amount: 87200, st: 'claim', mine: false },
]
const CHATS = [{ id: 1, who: 'Andrés Peña', last: 'Claro, llevo el equipo para la primera sesión.', ago: 'hace 2 h', msgs: [['in', 'Hola, ¿para qué día necesitas la sesión?'], ['out', 'Para el jueves en la tarde'], ['in', 'Claro, llevo el equipo para la primera sesión.']] }, { id: 2, who: 'Laura Gómez', last: 'Perfecto, nos vemos el sábado.', ago: 'ayer', msgs: [['in', 'Perfecto, nos vemos el sábado.']] }]

export default function Atdoor() {
  const [tab, setTab] = useState('svc')
  const [scr, setScr] = useState(null)
  const [cat, setCat] = useState('Todos')
  const [q, setQ] = useState('')
  const [bookings, setBookings] = useState(SEEDB)
  const [rtab, setRtab] = useState('Como cliente')
  const [fav, setFav] = useState([])
  const [hours, setHours] = useState(1)
  const [day, setDay] = useState(9)
  const [hr, setHr] = useState(null)
  const [addr, setAddr] = useState('')
  const [pinIn, setPinIn] = useState('')
  const [verified, setVerified] = useState(false)
  const [sos, setSos] = useState(false)
  const [chats, setChats] = useState(CHATS)
  const [draft, setDraft] = useState('')
  const [toast, setToast] = useState('')
  const say = (m) => { setToast(m); setTimeout(() => setToast(''), 2000) }
  const list = useMemo(() => SERVICES.filter((s) => (cat === 'Todos' || s.cat === cat) && (s.title + s.kind).toLowerCase().includes(q.toLowerCase())), [cat, q])
  const svc = SERVICES.find((s) => s.id === scr?.id)
  const go = (t) => { setTab(t); setScr(null) }
  const upd = (id, patch) => setBookings((l) => l.map((b) => (b.id === id ? { ...b, ...patch } : b)))
  const PIN = '4821'

  let body
  if (scr?.n === 'detail' && svc) {
    body = (
      <>
        <div className="ad-top" style={{ paddingBottom: 8 }}><button style={{ all: 'unset', color: 'var(--g)', fontWeight: 700, cursor: 'pointer' }} onClick={() => setScr(null)}>← Volver</button><span style={{ color: 'var(--tx2)', fontWeight: 600 }}>{svc.kind}</span><button style={{ all: 'unset', cursor: 'pointer', fontSize: 18 }} aria-label="Favorito" aria-pressed={fav.includes(svc.id)} onClick={() => { setFav(fav.includes(svc.id) ? fav.filter((i) => i !== svc.id) : [...fav, svc.id]); say(fav.includes(svc.id) ? 'Quitado de favoritos' : 'Guardado en favoritos') }}>{fav.includes(svc.id) ? '♥' : '♡'}</button></div>
        <div className="ad-body" style={{ padding: 0, gap: 0 }}>
          <div style={{ height: 150, background: svc.bg, display: 'grid', placeItems: 'center', fontSize: 64 }}>{svc.em}</div>
          <div style={{ padding: 14, display: 'grid', gap: 10 }}>
            <b style={{ fontSize: 20, textAlign: 'center' }}>{svc.title}</b>
            <div style={{ textAlign: 'center' }}><span className="ad-soft">{svc.rate} de 5 ({svc.n})</span> <span className="ad-soft">Va a tu domicilio</span></div>
            <div className="ad-card ad-row"><div><div className="ad-lab" style={{ textTransform: 'none', letterSpacing: 0 }}>{svc.unit ? 'Por hora' : 'Precio del servicio'}</div><b style={{ fontSize: 22, color: 'var(--g)' }}>{money(svc.price)}{svc.unit === '/h' ? ' / hora' : ''}</b></div><span className="ad-soft">Duración: 1h</span></div>
            <div className="ad-card"><b style={{ fontSize: 15 }}>Proveedor</b>
              <div className="ad-row" style={{ justifyContent: 'flex-start', gap: 12, marginTop: 8, alignItems: 'flex-start' }}><span className="ad-av" style={{ width: 52, height: 52, fontSize: 18 }}>{svc.pro.split(' ').map((x) => x[0]).join('')}</span><div><b>{svc.pro}</b><div style={{ color: 'var(--g)' }}>Identidad verificada</div><div className="ad-soft" style={{ margin: '4px 0' }}>✔ Identidad verificada</div><div style={{ color: 'var(--tx2)' }}>{svc.rate} · {svc.n} servicios completados</div></div></div>
            </div>
            <div className="ad-card"><b style={{ fontSize: 15 }}>Descripción</b><p style={{ marginTop: 6 }}>{svc.desc}</p></div>
            <div className="ad-card"><b style={{ fontSize: 15 }}>¿Qué incluye?</b>{svc.inc.map((x) => <div key={x} style={{ padding: '5px 0', color: 'var(--tx)' }}><span style={{ color: 'var(--g)' }}>✓</span> &nbsp;{x}</div>)}</div>
            <div className="ad-card"><b style={{ fontSize: 15 }}>Cobertura</b><div style={{ marginTop: 6 }}>📍 Atiende hasta {svc.km} km de su ubicación</div></div>
          </div>
        </div>
        <div className="ad-bar" style={{ padding: 10, gap: 10, height: 'auto', alignItems: 'center' }}>
          <button className="ad-btn out" style={{ flex: 1, padding: 12 }} onClick={() => say('Podrás escribirle cuando envíes la solicitud')}>Mensaje</button>
          <button className="ad-btn" style={{ flex: 1.3, padding: 12 }} onClick={() => { setHr(null); setScr({ n: 'book', id: svc.id }) }}>Solicitar reserva</button>
        </div>
      </>
    )
  } else if (scr?.n === 'book' && svc) {
    body = (
      <>
        <div className="ad-top"><button style={{ all: 'unset', cursor: 'pointer', fontSize: 20 }} aria-label="Cerrar" onClick={() => setScr({ n: 'detail', id: svc.id })}>✕</button><b style={{ fontSize: 17 }}>Solicitar reserva</b><span style={{ width: 20 }} /></div>
        <div className="ad-body">
          <div className="ad-card" style={{ background: '#dcecdf', borderColor: '#9ec9ac', color: 'var(--gd)', fontWeight: 600 }}>No pagas nada hasta que el proveedor acepte. Tu pago queda protegido hasta que confirmes que el servicio salió bien.</div>
          <b>¿Cuántas horas?</b>
          <div className="ad-row" style={{ justifyContent: 'flex-start', gap: 22 }}><button className="ad-ic" style={{ background: 'var(--g)', opacity: hours === 1 ? 0.5 : 1, width: 42, height: 42, borderRadius: '50%' }} aria-label="Menos horas" onClick={() => setHours(Math.max(1, hours - 1))}>−</button><b style={{ fontSize: 16 }}>{hours} {hours === 1 ? 'hora' : 'horas'}</b><button className="ad-ic" style={{ background: 'var(--g)', width: 42, height: 42, borderRadius: '50%' }} aria-label="Más horas" onClick={() => setHours(Math.min(6, hours + 1))}>+</button></div>
          <b>Día</b>
          <div style={{ display: 'flex', gap: 8, overflowX: 'auto' }}>{DAYS.map(([l, d]) => <button key={d} className={`ad-day ${day === d ? 'on' : ''}`} onClick={() => setDay(d)}><small>{l}</small><b>{d}</b><small>Nov</small></button>)}</div>
          <b>Hora</b>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>{HOURS.filter((h) => !(day === 9 && +h.split(':')[0] < 11)).map((h) => <button key={h} className={`ad-hr ${hr === h ? 'on' : ''}`} onClick={() => setHr(h)}>{h}</button>)}</div>
          <b>Dirección del servicio</b>
          <input className="ad-in" aria-label="Dirección" placeholder="Ej: Cra 33 #45-20, Cabecera, Bucaramanga" value={addr} onChange={(e) => setAddr(e.target.value)} />
          <div className="ad-row"><span style={{ color: 'var(--tx2)' }}>Total estimado</span><b style={{ fontSize: 18 }}>{money(svc.price * (svc.unit === '/h' ? hours : 1))}</b></div>
          <button className="ad-btn" disabled={!hr || !addr.trim()} onClick={() => {
            setBookings([{ id: 'n' + Date.now(), svc: svc.id, when: `${DAYS.find((x) => x[1] === day)[0].toLowerCase()} ${day} de noviembre, ${hr}`, amount: svc.price * (svc.unit === '/h' ? hours : 1), st: 'req', mine: true }, ...bookings])
            setRtab('Como cliente'); setScr(null); setTab('res'); say('Solicitud enviada al proveedor')
          }}>{hr ? 'Solicitar reserva' : 'Elige un horario'}</button>
        </div>
      </>
    )
  } else if (scr?.n === 'chat') {
    const c = chats.find((x) => x.id === scr.id)
    body = (
      <>
        <div className="ad-top"><button style={{ all: 'unset', color: 'var(--g)', fontWeight: 700, cursor: 'pointer' }} onClick={() => setScr(null)}>← Volver</button><b>{c.who}</b><span style={{ width: 40 }} /></div>
        <div className="ad-body">{c.msgs.map(([d, t], i) => <div key={i} style={{ alignSelf: d === 'out' ? 'flex-end' : 'flex-start', maxWidth: '82%', background: d === 'out' ? 'var(--g)' : 'var(--card)', color: d === 'out' ? '#fff' : 'inherit', border: d === 'out' ? 0 : '1px solid var(--bd)', padding: '8px 12px', borderRadius: 16 }}>{t}</div>)}</div>
        <form className="ad-row" style={{ padding: 10, background: 'var(--card)', borderTop: '1px solid var(--bd)' }} onSubmit={(e) => { e.preventDefault(); if (!draft.trim()) return; setChats(chats.map((x) => (x.id === c.id ? { ...x, msgs: [...x.msgs, ['out', draft.trim()]], last: draft.trim(), ago: 'ahora' } : x))); setDraft('') }}>
          <input className="ad-in" aria-label="Mensaje" placeholder="Escribe un mensaje…" value={draft} onChange={(e) => setDraft(e.target.value)} /><button className="ad-btn" style={{ width: 'auto', padding: '12px 16px' }}>Enviar</button>
        </form>
      </>
    )
  } else if (scr?.n === 'admin') {
    body = (
      <>
        <div className="ad-top"><button style={{ all: 'unset', color: 'var(--g)', fontWeight: 700, cursor: 'pointer' }} onClick={() => setScr(null)}>← Volver</button><b>Panel de administración</b><span style={{ width: 40 }} /></div>
        <div className="ad-body"><div className="ad-lab">Disputas</div>
          {[['Laura M. vs. Sergio T.', 'Servicio incompleto', 95000]].map(([w, why, a]) => <Dispute key={w} w={w} why={why} a={a} />)}
          <div className="ad-lab" style={{ marginTop: 6 }}>Verificaciones de identidad</div>
          {['Paola V. · cédula y selfie', 'Iván C. · cédula y antecedentes'].map((x) => <Verif key={x} x={x} />)}
        </div>
      </>
    )
  } else if (tab === 'svc') {
    body = (
      <>
        <div className="ad-hero">
          <div className="ad-row"><div><h2>Hola, Cliente</h2><div style={{ opacity: 0.85, fontSize: 13 }}>📍 Bucaramanga, Santander</div></div><button className="ad-ic" aria-label="Mapa" onClick={() => say('Mapa de proveedores cercanos (GPS real en la app)')}><Ico n="map" /></button></div>
          <input className="ad-search" aria-label="Buscar servicio" placeholder="¿Qué servicio necesitas?" value={q} onChange={(e) => setQ(e.target.value)} />
        </div>
        <div className="ad-body">
          <div className="ad-row" style={{ justifyContent: 'flex-start', gap: 8, color: 'var(--tx2)' }}><span style={{ color: 'var(--g)' }}>🛡</span> Pago protegido hasta que confirmes el servicio</div>
          <div className="ad-lab">Categorías</div>
          <div style={{ display: 'flex', gap: 8, overflowX: 'auto', paddingBottom: 2 }}>{CATS.map((c) => <button key={c} className={`ad-chip ${cat === c ? 'on' : ''}`} onClick={() => setCat(c)}>{c}</button>)}</div>
          <div className="ad-row"><span className="ad-lab">Servicios cerca</span><span style={{ color: 'var(--tx2)' }}>{list.length} disponibles</span></div>
          {list.map((s) => (
            <button key={s.id} className="ad-card ad-svc" onClick={() => setScr({ n: 'detail', id: s.id })}>
              <div className="ad-ph" style={{ background: s.bg }}>{s.em}<i>✓</i></div>
              <div style={{ padding: 12, flex: 1, display: 'grid', gap: 3 }}>
                <div className="ad-row"><span className="ad-lab" style={{ fontWeight: 500 }}>{s.kind}</span><span className="ad-soft">Verificado</span></div>
                <b style={{ fontSize: 14 }}>{s.title}</b>
                <span className="ad-soft" style={{ justifySelf: 'start' }}>✔ Identidad verificada</span>
                <div className="ad-row" style={{ justifyContent: 'flex-start', gap: 6 }}><span style={{ color: '#d8920c' }}>★ {s.rate}</span>{s.top && <span className="ad-soft amb">🏆 Top</span>}</div>
                <div className="ad-row"><b style={{ color: 'var(--g)', fontSize: 15 }}>{money(s.price)}{s.unit}</b><span style={{ color: 'var(--tx2)' }}>{s.pro.split(' ')[0]} {s.pro.split(' ')[1][0]}.</span></div>
              </div>
            </button>
          ))}
          {list.length === 0 && <div style={{ textAlign: 'center', color: 'var(--tx2)', padding: 30 }}>Ningún servicio coincide con tu búsqueda.</div>}
        </div>
      </>
    )
  } else if (tab === 'res') {
    const mine = bookings.filter((b) => (rtab === 'Como cliente' ? true : b.mine))
    body = (
      <>
        <div className="ad-top" style={{ background: 'var(--bg)', border: 0 }}><h2>Mis reservas</h2></div>
        <div className="ad-tabs2">{['Como cliente', 'Como proveedor'].map((x) => <button key={x} className={rtab === x ? 'on' : ''} onClick={() => setRtab(x)}>{x}</button>)}</div>
        <div className="ad-body">
          {mine.length === 0 && <div style={{ textAlign: 'center', color: 'var(--tx2)', padding: 30 }}>{rtab === 'Como cliente' ? 'Aún no tienes reservas.' : 'Cuando un cliente te pida un servicio, lo verás aquí.'}</div>}
          {mine.map((b) => {
            const s = SERVICES.find((x) => x.id === b.svc)
            const [label, tone] = STATUS[b.st]
            return (
              <div key={b.id} className="ad-card" style={{ display: 'grid', gap: 8 }}>
                <div style={{ display: 'flex', gap: 12 }}><span style={{ width: 54, height: 54, borderRadius: 14, background: 'var(--gs)', display: 'grid', placeItems: 'center', fontSize: 26, flex: 'none' }}>{s.em}</span><div><b>{s.title}</b><div style={{ color: 'var(--tx2)' }}>{rtab === 'Como cliente' ? s.pro : 'Cliente Demo'}</div><div style={{ color: 'var(--tx2)' }}>📅 {b.when}</div><b style={{ color: 'var(--g)' }}>{money(b.amount)}</b></div></div>
                <div><span className={`ad-soft ${tone}`}>{label}</span></div>
                {rtab === 'Como proveedor' && b.st === 'req' && <button className="ad-btn" onClick={() => { upd(b.id, { st: 'acc' }); say('Aceptaste la reserva') }}>Aceptar reserva</button>}
                {rtab === 'Como cliente' && b.mine && b.st === 'acc' && <button className="ad-btn" onClick={() => { upd(b.id, { st: 'paid' }); say('Pago en custodia (pasarela de prueba)') }}>Pagar {money(b.amount)} (queda en custodia)</button>}
                {rtab === 'Como cliente' && b.mine && b.st === 'paid' && <div className="ad-card" style={{ textAlign: 'center', background: 'var(--gs)', borderColor: '#9ec9ac' }}><div className="ad-lab">Tu PIN de seguridad</div><div style={{ fontSize: 36, fontWeight: 800, letterSpacing: 6 }}>{PIN}</div><div style={{ color: 'var(--tx2)' }}>Díselo al proveedor solo cuando llegue y termine el trabajo.</div></div>}
                {rtab === 'Como proveedor' && b.st === 'paid' && (
                  <form style={{ display: 'grid', gap: 8 }} onSubmit={(e) => { e.preventDefault(); if (pinIn === PIN) { upd(b.id, { st: 'done' }); setPinIn(''); say('Pago liberado a tu cuenta') } else { say('PIN incorrecto'); setPinIn('') } }}>
                    <div className="ad-lab">PIN que te da el cliente al terminar</div>
                    <input className="ad-in" aria-label="PIN del cliente" inputMode="numeric" maxLength={4} placeholder="Escribe el PIN (en la demo: 4821)" value={pinIn} onChange={(e) => setPinIn(e.target.value)} />
                    <button className="ad-btn">Confirmar y liberar pago</button>
                  </form>
                )}
                {rtab === 'Como proveedor' && b.st === 'done' && <div style={{ color: 'var(--gd)', fontWeight: 600 }}>Cobraste {money(b.amount * 0.9)} (comisión del 10% descontada)</div>}
              </div>
            )
          })}
        </div>
      </>
    )
  } else if (tab === 'msg') {
    body = (
      <>
        <div className="ad-top" style={{ background: 'var(--bg)', border: 0 }}><h2>Mensajes</h2></div>
        <div className="ad-body">{chats.map((c) => <button key={c.id} className="ad-card ad-row" style={{ textAlign: 'left', cursor: 'pointer', width: '100%' }} onClick={() => setScr({ n: 'chat', id: c.id })}><span className="ad-row" style={{ gap: 12 }}><span className="ad-av" style={{ width: 44, height: 44 }}>{c.who.split(' ').map((x) => x[0]).join('')}</span><span><b>{c.who}</b><br /><span style={{ color: 'var(--tx2)' }}>{c.last}</span></span></span><span style={{ color: 'var(--tx2)', fontSize: 11 }}>{c.ago}</span></button>)}</div>
      </>
    )
  } else {
    body = (
      <>
        <div className="ad-body">
          <div style={{ textAlign: 'center', paddingTop: 30, display: 'grid', gap: 6, justifyItems: 'center' }}>
            <span className="ad-av" style={{ width: 84, height: 84, fontSize: 30 }}>CD</span>
            <b style={{ fontSize: 20 }}>Cliente Demo</b><span style={{ color: 'var(--tx2)' }}>cliente@ejemplo.co</span><span className="ad-soft">Cliente</span>
          </div>
          <div className="ad-card"><div className="ad-lab">Verificación</div>
            <div className="ad-row" style={{ marginTop: 8 }}><b>{verified ? '✔ Identidad verificada' : '○ Sin verificar'}</b>{!verified && <button className="ad-chip on" onClick={() => { setVerified(true); say('Identidad verificada (documento de ejemplo)') }}>Verificar</button>}</div></div>
          <div className="ad-card" style={{ display: 'grid', gap: 8 }}><div className="ad-lab">Seguridad</div>
            <div className="ad-row"><div><b>Contacto de emergencia</b><div style={{ color: 'var(--tx2)' }}>Contacto Demo · +57 300 000 0000</div></div><span style={{ color: 'var(--g)', fontWeight: 700 }}>Editar</span></div>
            <div style={{ color: 'var(--tx2)' }}>¿Te sientes en peligro, aunque no estés en un servicio? Activa el SOS: avisamos a seguridad y a tu contacto con tu ubicación en vivo.</div>
            <button className="ad-btn red" onClick={() => setSos(true)}>❗ Activar SOS</button>
            {sos && <div className="ad-card" style={{ background: 'var(--redbg)', borderColor: '#e8aaa4' }}><b>SOS enviado (simulado)</b><div style={{ color: 'var(--tx2)' }}>En la app real se avisa al equipo de seguridad y a tu contacto, con tu ubicación en vivo.</div></div>}
          </div>
          <div className="ad-card"><div className="ad-lab" style={{ marginBottom: 6 }}>Cuenta</div>
            {[['Mis reservas', () => go('res')], ['Favoritos', () => say(fav.length ? `Tienes ${fav.length} favorito(s)` : 'Aún no tienes favoritos')], ['Mis mensajes', () => go('msg')], ['Panel de administración (web)', () => setScr({ n: 'admin' })]].map(([l, fn]) => <button key={l} onClick={fn} className="ad-row" style={{ width: '100%', border: 0, background: 'none', padding: '12px 0', borderTop: '1px solid var(--bd)', cursor: 'pointer' }}>{l}<span style={{ color: 'var(--tx2)' }}>›</span></button>)}
          </div>
        </div>
      </>
    )
  }

  const tabs = [['svc', 'Servicios', 'tools'], ['res', 'Reservas', 'cal'], ['msg', 'Mensajes', 'chat'], ['me', 'Perfil', 'user']]
  const showBar = !scr
  return (
    <div className="ad">
      {body}
      {toast && <div className="ad-toast" role="status">{toast}</div>}
      {showBar && <div className="ad-bar" role="tablist">{tabs.map(([id, l, ic]) => <button key={id} role="tab" aria-selected={tab === id} className={`ad-tab ${tab === id ? 'on' : ''}`} onClick={() => go(id)}><Ico n={ic} />{l}</button>)}</div>}
    </div>
  )
}

function Dispute({ w, why, a }) {
  const [st, setSt] = useState('Abierta')
  return (
    <div className="ad-card" style={{ display: 'grid', gap: 6 }}>
      <div className="ad-row"><b>{w}</b><span className={`ad-soft ${st === 'Abierta' ? 'amb' : ''}`}>{st}</span></div>
      <div style={{ color: 'var(--tx2)' }}>{why} · {money(a)}</div>
      {st === 'Abierta' && <div style={{ display: 'flex', gap: 8 }}><button className="ad-btn" style={{ padding: 10 }} onClick={() => setSt('Reembolsada')}>Reembolsar</button><button className="ad-btn out" style={{ padding: 10 }} onClick={() => setSt('Liberada al proveedor')}>Liberar al proveedor</button></div>}
    </div>
  )
}
function Verif({ x }) {
  const [ok, setOk] = useState(false)
  return <div className="ad-card ad-row"><span>{x}</span>{ok ? <span className="ad-soft">Aprobada</span> : <button className="ad-chip on" onClick={() => setOk(true)}>Aprobar</button>}</div>
}
