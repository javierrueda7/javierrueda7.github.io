import { useEffect, useMemo, useRef, useState } from 'react'
import './sofia.css'

// Panel de administración y chat de Sofía. "IPS Sendero Vital", sus pacientes, precios,
// equipo y cifras son inventados. La interfaz sigue la maqueta real del panel (14 vistas).
const CENTER = 'IPS Sendero Vital'
const USD = 3216
const TODAY = 24 // sáb 24 oct 2026
const NOW = 10 * 60 + 30
const DOW = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom']
const dow = (d) => (((d - 19) % 7) + 7) % 7
const dn = (d) => (d <= 31 ? d : d - 31)
const mon = (d) => (d <= 31 ? 'oct' : 'nov')
const dlabel = (d) => `${DOW[dow(d)]} ${dn(d)} ${mon(d)}`
const hm = (t) => { const h = Math.floor(t / 60), m = t % 60; return `${h % 12 || 12}:${String(m).padStart(2, '0')} ${h < 12 ? 'a. m.' : 'p. m.'}` }
const hh = (t) => { const h = Math.floor(t / 60); return `${h % 12 || 12} ${h < 12 ? 'a. m.' : 'p. m.'}` }
const toMin = (s) => { const [h, m] = s.split(':').map(Number); return h * 60 + m }
const th = (n) => String(Math.round(n)).replace(/\B(?=(\d{3})+(?!\d))/g, '.')
const cop = (n) => `$ ${th(n)}`
const usd = (n, d = 2) => `US$ ${n.toFixed(d).replace('.', ',')}`
const initials = (n) => n.split(' ').filter(Boolean).map((p) => p[0]).slice(0, 2).join('').toUpperCase()
const first = (n) => n.trim().split(' ')[0]

const TIERS = {
  eco: { label: 'Eco', m: 0.4, note: 'Modelo económico, caché y respuestas cortas. Para consultas simples.' },
  medio: { label: 'Medio', m: 1, note: 'Mejor comprensión de notas de voz y órdenes médicas. Recomendado.' },
  premium: { label: 'Premium', m: 2.7, note: 'Casos complejos y razonamiento largo. El más costoso.' },
}
const ROLES = ['Maestro (La Rue)', 'Administrador', 'Atención al cliente', 'Consulta']
const WHO = { 'Maestro (La Rue)': 'Javier Rueda', Administrador: 'Marcela Duque', 'Atención al cliente': 'Laura Pérez', Consulta: 'Carlos Ardila' }
const DENY = {
  'Maestro (La Rue)': [],
  Administrador: ['ajustes'],
  'Atención al cliente': ['gastos', 'procedimientos', 'horarios', 'equipo', 'datos', 'auditoria', 'ajustes'],
  Consulta: ['pacientes', 'citas', 'procedimientos', 'horarios', 'asistente', 'equipo', 'datos', 'auditoria', 'ajustes'],
}
const NAV = [
  ['RESUMEN', [['inicio', 'Inicio', 'home'], ['gastos', 'Gastos', 'db'], ['llamadas', 'Llamadas y chats', 'phone'], ['opinion', 'Opinión de pacientes', 'star'], ['pregunte', 'Pregunte por su centro', 'ask']]],
  ['OPERACIÓN', [['pacientes', 'Pacientes', 'users'], ['citas', 'Citas', 'cal']]],
  ['CONFIGURACIÓN', [['procedimientos', 'Procedimientos', 'list'], ['horarios', 'Horarios y cierres', 'clock'], ['asistente', 'Asistente', 'chat']]],
  ['ADMINISTRACIÓN', [['equipo', 'Equipo y roles', 'team'], ['datos', 'Datos y privacidad', 'db'], ['auditoria', 'Bitácora', 'shield'], ['ajustes', 'Ajustes técnicos', 'gear']]],
]
const TITLES = { inicio: 'Inicio', gastos: 'Gastos', llamadas: 'Llamadas y chats', opinion: 'Opinión de pacientes', pregunte: 'Pregunte por su centro', pacientes: 'Pacientes', citas: 'Citas', procedimientos: 'Procedimientos', horarios: 'Horarios y cierres', asistente: 'Asistente', equipo: 'Equipo y roles', datos: 'Datos y privacidad', auditoria: 'Bitácora de cambios', ajustes: 'Ajustes técnicos' }
const GREET = { 'Maestro (La Rue)': 'Javier', Administrador: 'Marcela', 'Atención al cliente': 'Laura', Consulta: 'Carlos' }

const IC = {
  home: 'M3 11l9-8 9 8M5 10v10h5v-6h4v6h5V10',
  db: 'M4 6c0-1.7 3.6-3 8-3s8 1.3 8 3-3.6 3-8 3-8-1.3-8-3zM4 6v6c0 1.7 3.6 3 8 3s8-1.3 8-3V6M4 12v6c0 1.7 3.6 3 8 3s8-1.3 8-3v-6',
  phone: 'M5 4h4l2 5-2.5 1.5a11 11 0 005 5L15 13l5 2v4a2 2 0 01-2 2A16 16 0 013 6a2 2 0 012-2z',
  star: 'M12 3l2.8 5.8 6.2.9-4.5 4.4 1.1 6.2L12 17.3 6.4 20.3l1.1-6.2L3 9.7l6.2-.9z',
  ask: 'M4 4h16v12H9l-5 4V4zM10 8.5a2 2 0 114 0c0 1.5-2 1.5-2 3M12 13.5h.01',
  users: 'M9 11a3 3 0 100-6 3 3 0 000 6zm-6 8c0-3 3-5 6-5s6 2 6 5m1-8a3 3 0 100-6m5 14c0-2-1.5-3.6-4-4.4',
  cal: 'M4 7h16v13H4zM4 11h16M8 3v4M16 3v4',
  list: 'M8 6h13M8 12h13M8 18h13M3 6h.01M3 12h.01M3 18h.01',
  clock: 'M12 3a9 9 0 100 18 9 9 0 000-18zM12 7v5l3 2',
  chat: 'M4 4h16v12H8l-4 4V4z',
  team: 'M3 5h18v14H3zM3 10h18M9 10v9',
  shield: 'M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6l8-3zM9 12l2 2 4-4',
  gear: 'M12 15a3 3 0 100-6 3 3 0 000 6zM19.4 13a7.5 7.5 0 000-2l2-1.5-2-3.5-2.3.9a7.5 7.5 0 00-1.7-1L15 3.5h-4L10.6 6a7.5 7.5 0 00-1.7 1l-2.3-.9-2 3.5 2 1.5a7.5 7.5 0 000 2l-2 1.5 2 3.5 2.3-.9a7.5 7.5 0 001.7 1l.4 2.5h4l.4-2.5a7.5 7.5 0 001.7-1l2.3.9 2-3.5-2-1.5z',
  search: 'M11 4a7 7 0 100 14 7 7 0 000-14zm9 16l-4-4',
  bell: 'M6 9a6 6 0 1112 0c0 6 2 7 2 7H4s2-1 2-7zm4 10a2 2 0 004 0',
  moon: 'M20 14A8 8 0 1110 4a7 7 0 0010 10z',
  plus: 'M12 5v14M5 12h14',
  lock: 'M6 11h12v9H6zM8 11V8a4 4 0 018 0v3',
  menu: 'M4 6h16M4 12h16M4 18h16',
  down: 'M12 4v11m-4-4l4 4 4-4M5 20h14',
  up: 'M12 16V5m-4 4l4-4 4 4M5 20h14',
  check: 'M5 12.5l4.5 4.5L19 7.5',
  info: 'M12 3a9 9 0 100 18 9 9 0 000-18zM12 11v5M12 8h.01',
  clip: 'M20 11l-8 8a5 5 0 01-7-7l8-8a3.5 3.5 0 015 5l-8 8a2 2 0 01-3-3l7-7',
}
const Ic = ({ n }) => <svg className="sf-ic" viewBox="0 0 24 24" aria-hidden="true"><path d={IC[n]} /></svg>

// ---------- datos inventados ----------
const rng = (seed) => () => { seed |= 0; seed = (seed + 0x6d2b79f5) | 0; let t = Math.imul(seed ^ (seed >>> 15), 1 | seed); t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t; return ((t ^ (t >>> 14)) >>> 0) / 4294967296 }
const NAMES = ['Juliana', 'Julián', 'Sebastián', 'Jairo', 'Carolina', 'Laura', 'Mariana', 'Natalia', 'Nicolás', 'Paula', 'Esteban', 'Valentina', 'Ricardo', 'Lucía', 'David', 'Camila', 'Andrés', 'Daniela', 'Felipe', 'Sara', 'Mateo', 'Isabela', 'Santiago', 'Manuela']
const SURN = ['Rincón', 'Prada', 'Cárdenas', 'Martínez', 'Mendoza', 'Ortiz', 'Leal', 'Quintero', 'Suárez', 'Camacho', 'Acevedo', 'Navarro', 'Gómez', 'Ardila', 'Duarte', 'Rojas', 'Pinzón', 'Villamizar', 'Hernández', 'Ruiz']
const EPS = ['Sanitas', 'Nueva EPS', 'Salud Total', 'Sura', 'Compensar', 'Coosalud', 'Famisanar', 'Particular']

const PROCS0 = [
  { id: 'eco', name: 'Ecografía abdominal', alias: 'eco, eco de abdomen, ecografía de barriga', cat: 'Ecografía', team: 'Ecógrafo', dur: 20, price: 160000, on: true, order: true, arrive: 15, prep: 'Necesita ayuno de 6 horas. Tome 1 litro de agua una hora antes y no orine hasta terminar el estudio.', bring: 'documento de identidad, orden médica vigente y autorización de la EPS', after: 'Puede retomar su dieta y sus actividades normales.' },
  { id: 'obs', name: 'Ecografía obstétrica', alias: 'eco de embarazo, eco obstétrica', cat: 'Ecografía', team: 'Ecógrafo', dur: 20, price: 180000, on: true, order: true, arrive: 15, prep: 'Vejiga llena en el primer trimestre: tome 1 litro de agua una hora antes. Sin ayuno.', bring: 'documento de identidad, orden médica y carné de control prenatal', after: 'Puede retomar sus actividades normales.' },
  { id: 'tir', name: 'Ecografía de tiroides', alias: 'eco de tiroides, eco de cuello', cat: 'Ecografía', team: 'Ecógrafo', dur: 20, price: 150000, on: true, order: true, arrive: 10, prep: 'No requiere ayuno. Use ropa que deje el cuello libre, sin collares.', bring: 'documento de identidad, orden médica y estudios anteriores', after: 'Puede retomar sus actividades normales.' },
  { id: 'rod', name: 'Resonancia de rodilla', alias: 'resonancia de rodilla, rm de rodilla, resonancia', cat: 'Resonancia', team: 'Resonador', dur: 40, price: 780000, on: true, order: true, arrive: 20, prep: 'No requiere ayuno. Sin objetos metálicos: retire joyas, relojes y ropa con cremalleras. Avise si tiene marcapasos, prótesis o implantes.', bring: 'documento de identidad, orden médica, autorización de la EPS y estudios anteriores', after: 'Puede retomar sus actividades normales de inmediato.' },
  { id: 'lum', name: 'Resonancia de columna lumbar', alias: 'resonancia de columna, rm lumbar', cat: 'Resonancia', team: 'Resonador', dur: 60, price: 860000, on: true, order: true, arrive: 20, prep: 'No requiere ayuno. Sin metales encima. Avise si es claustrofóbico para valorar sedación con su médico.', bring: 'documento de identidad, orden médica y autorización de la EPS', after: 'Puede retomar sus actividades normales.' },
  { id: 'tot', name: 'Tomografía de tórax', alias: 'tac de tórax, tomografía de pecho, tac', cat: 'Tomografía', team: 'Tomógrafo', dur: 20, price: 640000, on: true, order: true, arrive: 15, prep: 'No requiere ayuno si es sin contraste. Retire collares y objetos metálicos del tórax.', bring: 'documento de identidad, orden médica y autorización de la EPS', after: 'Puede retomar sus actividades normales.' },
  { id: 'tab', name: 'Tomografía de abdomen con contraste', alias: 'tac de abdomen, tomografía con contraste', cat: 'Tomografía', team: 'Tomógrafo', dur: 40, price: 920000, on: true, order: true, arrive: 30, prep: 'Ayuno de 6 horas. Traiga el resultado de creatinina de los últimos 3 meses. Avise si es alérgico al yodo.', bring: 'documento de identidad, orden médica, autorización de la EPS y creatinina', after: 'Tome abundante agua las 24 horas siguientes para eliminar el contraste.' },
  { id: 'rxt', name: 'Radiografía de tórax', alias: 'rx de tórax, placa de pecho, radiografía de pecho', cat: 'Radiografía', team: 'Rayos X', dur: 20, price: 85000, on: true, order: true, arrive: 10, prep: 'No requiere preparación. Retire collares y cadenas.', bring: 'documento de identidad, orden médica y autorización de la EPS', after: 'Puede retomar sus actividades normales.' },
  { id: 'rxc', name: 'Radiografía de columna', alias: 'rx de columna, placa de columna', cat: 'Radiografía', team: 'Rayos X', dur: 20, price: 110000, on: true, order: true, arrive: 10, prep: 'No requiere preparación. Use ropa cómoda, sin metal en la espalda.', bring: 'documento de identidad, orden médica y autorización de la EPS', after: 'Puede retomar sus actividades normales.' },
  { id: 'mam', name: 'Mamografía bilateral', alias: 'mamografía, mamo', cat: 'Radiografía', team: 'Rayos X', dur: 20, price: 230000, on: true, order: true, arrive: 15, prep: 'Prográmela entre los días 5 y 10 del ciclo. No use desodorante, talco ni cremas en el área ese día.', bring: 'documento de identidad, orden médica, autorización de la EPS y mamografías anteriores', after: 'Puede retomar sus actividades normales.' },
  { id: 'den', name: 'Densitometría ósea', alias: 'densitometría, densito', cat: 'Radiografía', team: 'Rayos X', dur: 20, price: 0, on: true, order: true, arrive: 10, prep: 'No tome suplementos de calcio 24 horas antes. Use ropa sin metal.', bring: 'documento de identidad, orden médica y autorización de la EPS', after: 'Puede retomar sus actividades normales.' },
]
const TEAMS = ['Ecógrafo', 'Resonador', 'Tomógrafo', 'Rayos X']
const CATS = ['Ecografía', 'Resonancia', 'Tomografía', 'Radiografía', 'Cardiología', 'General']

const mkPatients = () => {
  const r = rng(7)
  const out = []
  const used = new Set()
  while (out.length < 46) {
    const nm = `${NAMES[Math.floor(r() * NAMES.length)]} ${SURN[Math.floor(r() * SURN.length)]} ${SURN[Math.floor(r() * SURN.length)]}`
    if (used.has(nm)) continue
    used.add(nm)
    const i = out.length
    out.push({
      id: `P-${1001 + ((i * 7) % 46)}`, name: nm, doc: `CC 1.0${String(10 + Math.floor(r() * 89)).padStart(2, '0')}.${String(100 + Math.floor(r() * 899))}.${String(100 + Math.floor(r() * 899))}`,
      phone: `3${String(100000000 + Math.floor(r() * 199999999)).slice(0, 9)}`, eps: EPS[Math.floor(r() * EPS.length)],
      auth: `${DOW[Math.floor(r() * 6)]} ${1 + Math.floor(r() * 24)} ${r() > 0.5 ? 'oct' : 'sep'} · ${r() > 0.45 ? 'WhatsApp' : 'Llamada'}`,
    })
  }
  return out.sort((a, b) => a.name.split(' ').slice(1).join(' ').localeCompare(b.name.split(' ').slice(1).join(' ')))
}
const OUTS = ['Agendó una cita', 'Resolvió una consulta', 'Pasó a una persona', 'Pidió devolución de llamada', 'Colgó sin atender', 'Reprogramó una cita']
const mkConvs = (patients) => {
  const r = rng(21)
  const out = []
  let d = TODAY, t = 612
  for (let i = 0; i < 78; i++) {
    const call = r() < 0.27
    const w = r()
    const out_ = call ? OUTS[w < 0.4 ? 0 : w < 0.65 ? 2 : w < 0.8 ? 3 : w < 0.9 ? 4 : 1] : OUTS[w < 0.36 ? 0 : w < 0.62 ? 1 : w < 0.82 ? 2 : w < 0.92 ? 5 : 1]
    const p = patients[Math.floor(r() * patients.length)]
    out.push({ id: `c${i}`, d, t, ch: call ? 'Llamada' : 'WhatsApp', name: p.name, tel: `***${p.phone.slice(-4)}`, min: call ? 1.2 + r() * 4.2 : 0, msgs: call ? 0 : 3 + Math.floor(r() * 10), out: out_ })
    t -= 25 + Math.floor(r() * 70)
    if (t < 420) { d -= 1; if (dow(d) === 6) d -= 1; t = 960 - Math.floor(r() * 90) }
  }
  return out
}
const SEED_APPTS = [
  [19, 460, 'Camila Torres Leal', 'tab', 'done', 'Llamada'], [19, 580, 'Lucía Pinzón Ortiz', 'eco', 'done', 'WhatsApp'], [19, 620, 'Ricardo Duarte Rojas', 'tir', 'done', 'Panel'],
  [20, 840, 'Daniela Ardila Ruiz', 'rxc', 'noshow', 'WhatsApp'], [20, 480, 'Mateo Quintero Gómez', 'rod', 'done', 'Llamada'],
  [21, 540, 'Sara Mendoza Navarro', 'mam', 'done', 'WhatsApp'], [22, 500, 'Andrés Camacho Prada', 'tot', 'done', 'Llamada'], [22, 630, 'Isabela Rincón Suárez', 'obs', 'noshow', 'WhatsApp'],
  [23, 720, 'Felipe Villamizar Leal', 'lum', 'done', 'Panel'], [24, 580, 'Manuela Cárdenas Ortiz', 'eco', 'conf', 'WhatsApp'], [24, 840, 'Santiago Hernández Ruiz', 'rxt', 'conf', 'Llamada'],
  [26, 460, 'Natalia Martínez Duarte', 'rod', 'prog', 'WhatsApp'], [26, 560, 'Jairo Acevedo Rojas', 'eco', 'prog', 'Llamada'], [26, 680, 'Paula Gómez Camacho', 'mam', 'prog', 'WhatsApp'],
  [26, 840, 'David Pinzón Quintero', 'tot', 'conf', 'Panel'], [26, 900, 'Valentina Leal Ardila', 'rxt', 'prog', 'WhatsApp'], [27, 520, 'Nicolás Suárez Mendoza', 'tab', 'prog', 'Llamada'],
  [27, 700, 'Juliana Navarro Ortiz', 'tir', 'conf', 'WhatsApp'], [28, 480, 'Esteban Rojas Hernández', 'lum', 'prog', 'Panel'], [29, 600, 'Carolina Ruiz Prada', 'obs', 'prog', 'WhatsApp'],
  [31, 540, 'Julián Duarte Cárdenas', 'eco', 'prog', 'WhatsApp'], [31, 780, 'Laura Villamizar Gómez', 'rxc', 'prog', 'Llamada'],
].map(([date, t, name, proc, status, src], i) => ({ id: 100 + i, date, t, name, proc, status, src, dur: PROCS0.find((p) => p.id === proc).dur }))

const USERS0 = [
  { id: 1, name: 'Javier Rueda', email: 'javier@laruedev.example', role: 'Maestro (La Rue)', last: 'Hoy 09:12', f2: true },
  { id: 2, name: 'Marcela Duque', email: 'gerencia@sendero.example', role: 'Administrador', last: 'Hoy 08:40', f2: true },
  { id: 3, name: 'Laura Pérez', email: 'recepcion@sendero.example', role: 'Atención al cliente', last: 'Ayer 16:55', f2: false },
  { id: 4, name: 'Carlos Ardila', email: 'facturacion@sendero.example', role: 'Consulta', last: '22 oct 10:03', f2: false },
  { id: 5, name: 'Diana Mendoza', email: 'diana@sendero.example', role: 'Atención al cliente', last: 'Invitación enviada', pending: true, f2: false },
]
const AUDIT0 = [
  ['Hoy 09:12', 'Javier Rueda', 'Ajustes', 'Cambió el tope diario de gasto', 'US$ 8,00', 'US$ 10,00'],
  ['Hoy 08:41', 'Marcela Duque', 'Procedimientos', 'Cambió el precio de «Radiografía de columna»', '$ 95.000', '$ 110.000'],
  ['Ayer 17:20', 'Marcela Duque', 'Horarios', 'Agregó un cierre extraordinario', '—', '31 oct, todo el día: jornada de capacitación'],
  ['Ayer 16:48', 'Laura Pérez', 'Pacientes', 'Corrigió el celular de P-1014', '—', 'dato corregido (no se guarda el valor)'],
  ['Ayer 11:05', 'Marcela Duque', 'Información adicional', 'Editó «Cancelaciones y reprogramaciones»', 'versión 3', 'versión 4'],
  ['22 oct 15:30', 'Javier Rueda', 'Datos', 'Importó 38 pacientes desde CSV', '—', '38 nuevos, 2 actualizados, 1 con error'],
  ['22 oct 10:02', 'Marcela Duque', 'Equipo', 'Invitó a Diana Mendoza como Atención al cliente', '—', 'Pendiente'],
  ['21 oct 09:15', 'Javier Rueda', 'Ajustes', 'Activó el aviso de gasto al 80 %', 'Desactivado', 'Activado'],
].map(([when, who, mod, what, before, after], i) => ({ id: i, when, who, mod, what, before, after }))
const INFO0 = [
  { id: 1, t: 'Cancelaciones y reprogramaciones', v: 4, x: 'Se puede cancelar o reprogramar hasta 4 horas antes sin costo. Pasado ese tiempo se avisa a recepción.' },
  { id: 2, t: 'Ubicación y parqueadero', v: 2, x: 'Carrera 27 #48-15, barrio Cabecera (dirección de ejemplo). Hay parqueadero para pacientes en el sótano.' },
  { id: 3, t: 'Medios de pago', v: 1, x: 'Se recibe efectivo, tarjetas débito y crédito y transferencia. Los pacientes de EPS pagan solo la cuota o copago.' },
  { id: 4, t: 'Entrega de resultados', v: 3, x: 'Los informes salen entre 24 y 48 horas hábiles. Se envían al correo o se recogen en recepción con el documento.' },
  { id: 5, t: 'Estudios con contraste', v: 2, x: 'Se necesita creatinina reciente y avisar alergias al yodo. Sofía no valora si el paciente puede recibir el contraste.' },
  { id: 6, t: 'Atención preferencial', v: 1, x: 'Mujeres embarazadas, adultos mayores y personas con discapacidad pasan primero en recepción.' },
]
const AVISO = 'Esta conversación queda registrada por escrito. Para gestionar su cita necesito su autorización para tratar sus datos personales y de salud, que son datos sensibles; usted no está obligado a darlos. Puede conocer, corregir o pedir que borremos sus datos, o retirar su autorización, cuando quiera. Los trata IPS Sendero Vital, con apoyo de proveedores tecnológicos dentro y fuera de Colombia; la política completa está en nuestra página web. ¿Me autoriza?'

const hoursText = (h) => {
  const idx = h.days.map((v, i) => (v ? i : -1)).filter((i) => i >= 0)
  const days = idx.length === 0 ? 'ningún día' : idx.length === 1 ? DOW[idx[0]] : idx.every((v, i) => i === 0 || v === idx[i - 1] + 1) ? `${{ lun: 'lunes', mar: 'martes', mié: 'miércoles', jue: 'jueves', vie: 'viernes', sáb: 'sábado', dom: 'domingo' }[DOW[idx[0]]]} a ${{ lun: 'lunes', mar: 'martes', mié: 'miércoles', jue: 'jueves', vie: 'viernes', sáb: 'sábado', dom: 'domingo' }[DOW[idx[idx.length - 1]]]}` : idx.map((i) => DOW[i]).join(', ')
  return `de ${days}, de ${hm(toMin(h.open))} a ${hm(toMin(h.close))}`
}
const explain = (p) => `Para ${p.name}, por favor llegue ${p.arrive} minutos antes de su hora. ${p.prep} Traiga: ${p.bring}. El estudio en el equipo dura unos ${p.dur} minutos. ${p.price ? `El valor particular es ${cop(p.price)}.` : 'Sobre el valor, una persona del equipo le confirma.'} Después del estudio: ${p.after}`
const filled = (p) => [p.name, p.alias, p.cat, p.team, p.dur, p.price, p.prep, p.bring].filter((v) => v !== '' && v !== 0 && v != null).length

// ---------- piezas pequeñas ----------
const Pill = ({ k = '', children }) => <span className={`sf-pill ${k}`}>{children}</span>
const Sw = ({ on, set, label, sub, id }) => (
  <label className="sf-swrow">
    <button type="button" role="switch" aria-checked={on} aria-label={label} id={id} className={`sf-sw ${on ? 'on' : ''}`} onClick={() => set(!on)}><i /></button>
    <span><b>{label}</b>{sub && <small>{sub}</small>}</span>
  </label>
)
const Card = ({ title, right, children, pad = true, cls = '' }) => (
  <section className={`sf-card ${cls}`}>
    {(title || right) && <div className="sf-ch"><h2>{title}</h2>{right}</div>}
    <div className={pad ? 'sf-cb' : ''}>{children}</div>
  </section>
)
const Intro = ({ children }) => <p className="sf-intro">{children}</p>
const Pager = ({ page, setPage, total, size }) => {
  const from = total === 0 ? 0 : page * size + 1
  const to = Math.min(total, (page + 1) * size)
  return (
    <div className="sf-pager">
      <span>{from}–{to} de {total}</span>
      <button className="sf-btn sm" disabled={page === 0} onClick={() => setPage(page - 1)}>Anterior</button>
      <button className="sf-btn sm" disabled={to >= total} onClick={() => setPage(page + 1)}>Siguiente</button>
    </div>
  )
}
const Modal = ({ title, onClose, children }) => (
  <div className="sf-mod" onClick={onClose}>
    <div role="dialog" aria-label={title} onClick={(e) => e.stopPropagation()}>
      <h2>{title}</h2>
      {children}
    </div>
  </div>
)
const dl = (name, text, type = 'text/csv') => {
  try {
    const a = document.createElement('a')
    a.href = URL.createObjectURL(new Blob([text], { type }))
    a.download = name
    a.click()
    setTimeout(() => URL.revokeObjectURL(a.href), 1000)
  } catch { /* sin descarga */ }
}
const csv = (rows) => rows.map((r) => r.map((c) => `"${String(c).replace(/"/g, '""')}"`).join(',')).join('\n')

// ---------- chat de la paciente ----------
function Chat({ s }) {
  const { procs, hours, msgs, freeSlots, addAppt, cancelAppt, upsertConv, appts, bumpTurn } = s
  const offered = procs.filter((p) => p.on)
  const [log, setLog] = useState(() => [{ f: 'bot', t: msgs.greeting }, { f: 'bot', t: AVISO }])
  const [step, setStep] = useState('consent')
  const [busy, setBusy] = useState(false)
  const [pick, setPick] = useState({})
  const [text, setText] = useState('')
  const conv = useRef(null)
  const timers = useRef([])
  const end = useRef(null)
  const box = useRef(null)
  useEffect(() => { const el = box.current; if (el) el.scrollTop = el.scrollHeight }, [log, step, busy, s.view])
  useEffect(() => () => timers.current.forEach(clearTimeout), [])

  const add = (f, t, extra) => setLog((l) => [...l, { f, t, ...extra }])
  const bot = (arr, then) => {
    const list = [].concat(arr)
    setBusy(true)
    list.forEach((t, i) => timers.current.push(setTimeout(() => {
      add('bot', t)
      if (i === list.length - 1) { setBusy(false); then && then() }
    }, 380 * (i + 1))))
  }
  const me = (t, extra) => { add('me', t, extra); bumpTurn() }
  const track = (patch) => {
    if (!conv.current) conv.current = { id: `chat${Date.now()}`, name: 'Paciente del chat de prueba', out: 'Resolvió una consulta', msgs: 0 }
    conv.current = { ...conv.current, ...patch, msgs: (conv.current.msgs || 0) + 1 }
    upsertConv(conv.current)
  }
  const reset = () => { timers.current.forEach(clearTimeout); setLog([{ f: 'bot', t: msgs.greeting }, { f: 'bot', t: AVISO }]); setStep('consent'); setBusy(false); setPick({}); conv.current = null }
  const menu = (t) => bot(t, () => setStep('menu'))

  const authorize = () => { me('Sí, autorizo.'); track({}); bot('Muchas gracias. ¿En qué le puedo ayudar?', () => setStep('menu')) }
  const refuse = () => {
    me('No autorizo.')
    bot('Entiendo. Sin su autorización no puedo guardar sus datos ni gestionar su cita. Si cambia de opinión, escríbame de nuevo; también puede llamar al centro.', () => setStep('noauth'))
  }
  const toHuman = () => {
    track({ out: 'Pasó a una persona' })
    s.onHandoff()
    bot(msgs.transfer, () => { add('sys', 'Conversación transferida a una persona'); setStep('human') })
  }
  const chooseProc = (p) => {
    setPick({ p })
    if (p.order) {
      me(p.name)
      bot([`${p.name}: ${p.price ? `valor particular ${cop(p.price)}. ` : ''}Necesito la orden médica vigente para agendarlo. ¿Me envía la foto?`], () => setStep('order'))
    } else { me(p.name); bot('Estos son los horarios libres:', () => setStep('slot')) }
  }
  const attach = (proc) => {
    const p = proc || pick.p || offered.find((x) => x.id === 'rod')
    me('📎 orden_medica.jpg', { img: p })
    setPick((x) => ({ ...x, p }))
    bot([`Leí la orden: ${p.name}, solicitada por la Dra. Natalia Beltrán (médica ficticia). No interpreto diagnósticos; solo tomo el examen ordenado.`, `¿Busco horario para ${p.name}?`], () => setStep('order-ok'))
  }
  const faq = (label, answer) => { me(label); bot(answer, () => setStep('menu')) }
  const route = (raw) => {
    const q = raw.toLowerCase()
    const hit = offered.find((p) => [p.name, ...p.alias.split(',')].some((a) => a.trim().length > 2 && q.includes(a.trim().toLowerCase())))
    if (/persona|humano|asesor|alguien/.test(q)) return toHuman()
    if (hit && /prepar|ayuno|necesito|llevar|traer/.test(q)) return bot(explain(hit), () => setStep('menu'))
    if (hit && /precio|cuánto|cuanto|vale|cuesta|costo/.test(q)) return bot(`${hit.name}: ${hit.price ? `valor particular ${cop(hit.price)}` : 'el valor se lo confirma una persona del equipo'}.`, () => setStep('menu'))
    if (/agend|cita|reserv|turno/.test(q)) return hit ? chooseProcSilent(hit) : bot('Claro. ¿Qué examen necesita?', () => setStep('exam'))
    if (/orden|foto/.test(q)) return bot('Envíeme la foto de la orden y yo leo los datos.', () => setStep('order0'))
    if (/dónde|donde|ubic|direcci|horario|abren|atienden/.test(q)) return bot(`Estamos en la Carrera 27 #48-15, barrio Cabecera (dirección de ejemplo). Atendemos ${hoursText(hours)}.`, () => setStep('menu'))
    if (/resultado|informe/.test(q)) return bot('Los informes salen entre 24 y 48 horas hábiles y se envían al correo o se recogen en recepción con su documento. Yo no interpreto resultados: eso lo hace su médico.', () => setStep('menu'))
    return bot('Puedo explicarle la preparación de un examen, agendar su cita o pasarle con una persona del equipo. ¿Cuál prefiere?', () => setStep('menu'))
  }
  const chooseProcSilent = (p) => {
    setPick({ p })
    if (p.order) bot(`${p.name}: ${p.price ? `valor particular ${cop(p.price)}. ` : ''}Necesito la orden médica vigente para agendarlo. ¿Me envía la foto?`, () => setStep('order'))
    else bot('Estos son los horarios libres:', () => setStep('slot'))
  }
  const onSend = (e) => {
    e.preventDefault()
    const v = text.trim()
    if (!v || busy) return
    setText('')
    if (step === 'name') {
      me(v)
      setPick((x) => ({ ...x, name: v }))
      bot(`Gracias, ${first(v)}. Revise los datos de su cita:`, () => setStep('confirm'))
      return
    }
    me(v)
    track({})
    if (step === 'consent') {
      if (/^(s[ií]|autorizo|acepto|ok)/i.test(v)) { bot('Muchas gracias. ¿En qué le puedo ayudar?', () => setStep('menu')) } else bot('Necesito su autorización para continuar. Responda «Sí, autorizo» o «No autorizo».')
      return
    }
    route(v)
  }
  const confirmBook = () => {
    const { p, d, t, name } = pick
    addAppt({ date: d, t, name, proc: p.id, src: 'WhatsApp', status: 'prog', mine: true, dur: p.dur })
    track({ name, out: 'Agendó una cita' })
    me('Confirmo la cita.')
    bot([`Listo, ${first(name)}. Su ${p.name} quedó para el ${dlabel(d)} a las ${hm(t)}. Llegue ${p.arrive} minutos antes con ${p.bring}.`, `Le escribo un día antes para recordarle la preparación: ${p.prep}`], () => setStep('menu'))
  }
  const mine = appts.filter((a) => a.mine && a.status !== 'cancel')
  const days = useMemo(() => [26, 27, 28, 29, 30].filter((d) => pick.p && freeSlots(d, pick.p).length > 0).slice(0, 3), [pick.p, freeSlots])
  const lastMenu = step === 'menu'

  return (
    <div className="sf-chatwrap">
      <div className="sf-chat">
        <div className="sf-chead">
          <span className="sf-cav">S</span>
          <div><b>Asistente virtual</b><small><i /> Sofía · en línea 24/7</small></div>
          <button className="sf-link" onClick={reset}>Nueva conversación</button>
        </div>
        <div className="sf-ctabs"><span className="sf-seg"><button className="on">Pacientes</button><button onClick={() => s.setView('admin')}>Equipo</button></span></div>
        <div className="sf-cmsgs" ref={box} data-testid="chat-log">
          {log.map((m, i) => (
            m.f === 'sys' ? <div key={i} className="sf-sys">{m.t}</div> : (
              <div key={i} className={`sf-b ${m.f === 'me' ? 'me' : ''}`}>
                {m.img ? <div className="sf-photo" aria-label="Foto de la orden médica"><b>ORDEN MÉDICA</b><span>{CENTER} · médica ficticia</span><i /><i /><i /><em>{m.img.name}</em></div> : null}
                {m.t}
              </div>
            )
          ))}
          {busy && <div className="sf-typing" aria-label="Sofía está escribiendo"><i /><i /><i /></div>}
          {!busy && step === 'consent' && (
            <div className="sf-opts row"><button className="sf-btn pri" onClick={authorize}>Sí, autorizo</button><button className="sf-btn" onClick={refuse}>No autorizo</button></div>
          )}
          {!busy && step === 'noauth' && <div className="sf-opts"><button className="sf-opt" onClick={reset}><b>Empezar de nuevo</b></button><button className="sf-opt" onClick={() => { me('Quiero hablar con una persona'); toHuman() }}><b>Hablar con una persona</b></button></div>}
          {!busy && lastMenu && (
            <div className="sf-opts">
              <button className="sf-opt" onClick={() => { me('Agendar una cita'); bot('¿Qué examen necesita?', () => setStep('exam')) }}><b>📅 Agendar una cita</b><span>Reserva en unos segundos</span></button>
              <button className="sf-opt" onClick={() => { me('Mis próximas citas'); setStep('mine') }}><b>🗓️ Mis próximas citas</b><span>Consulta, cambia o cancela</span></button>
              <button className="sf-opt" onClick={() => faq('Tengo una pregunta', `Puede preguntarme por precios, preparación, ubicación u horarios. Atendemos ${hoursText(hours)}.`)}><b>❓ Tengo una pregunta</b><span>Precios, ubicación y más</span></button>
              <button className="sf-opt" onClick={() => { me('Tengo mi orden médica'); bot('Envíeme la foto o el PDF de la orden y yo leo los datos.', () => setStep('order0')) }}><b>📎 Enviar mi orden médica</b><span>Una foto y yo leo los datos</span></button>
              <button className="sf-opt" onClick={() => { me('Quiero hablar con una persona'); toHuman() }}><b>🙋 Hablar con una persona</b><span>Le paso su conversación al equipo</span></button>
            </div>
          )}
          {!busy && step === 'exam' && (
            <div className="sf-opts">
              {offered.map((p) => <button key={p.id} className="sf-opt" onClick={() => chooseProc(p)}><b>{p.name}</b><span>{p.price ? cop(p.price) : 'Valor por confirmar'} · {p.team}</span></button>)}
              <button className="sf-btn sm" onClick={() => setStep('menu')}>← Atrás</button>
            </div>
          )}
          {!busy && (step === 'order' || step === 'order0') && (
            <div className="sf-opts">
              <button className="sf-opt" onClick={() => attach(step === 'order0' ? offered.find((x) => x.id === 'rod') : undefined)}><b>📎 Adjuntar foto de la orden</b><span>Se usa una foto de ejemplo</span></button>
              <button className="sf-opt" onClick={() => { me('No la tengo ahora'); bot('Sin la orden no puedo agendarlo. Cuando la tenga, me la envía por aquí y seguimos.', () => setStep('menu')) }}><b>No la tengo ahora</b></button>
            </div>
          )}
          {!busy && step === 'order-ok' && (
            <div className="sf-opts row"><button className="sf-btn pri" onClick={() => { me('Sí, busque horario'); bot('Estos son los horarios libres:', () => setStep('slot')) }}>Sí, busque horario</button><button className="sf-btn" onClick={() => { me('Por ahora no'); setStep('menu') }}>Por ahora no</button></div>
          )}
          {!busy && step === 'slot' && pick.p && (
            <div className="sf-slots">
              <b>{pick.p.name}</b>
              {days.length === 0 && <span>No hay cupos próximos. Puedo pasarle con una persona.</span>}
              {days.map((d) => {
                const all = freeSlots(d, pick.p)
                const open = toMin(hours.open)
                const ts = all.filter((t) => (t - open) % 60 === 0).slice(0, 6)
                return (
                  <div key={d}><small>{dlabel(d)}</small>
                    <div className="chips">{ts.map((t) => <button key={t} className="sf-chip" onClick={() => { me(`${dlabel(d)} · ${hm(t)}`); setPick((x) => ({ ...x, d, t })); bot('¿A nombre de quién agendo la cita? Escriba su nombre completo.', () => setStep('name')) }}>{hm(t)}</button>)}</div>
                  </div>
                )
              })}
              <button className="sf-btn sm" onClick={() => setStep('menu')}>← Atrás</button>
            </div>
          )}
          {!busy && step === 'confirm' && (
            <div className="sf-opts">
              <div className="sf-sum">
                {[['Examen', pick.p.name], ['Día', dlabel(pick.d)], ['Hora', hm(pick.t)], ['A nombre de', pick.name], ['Valor particular', pick.p.price ? cop(pick.p.price) : 'Por confirmar']].map(([k, v]) => <div key={k}><span>{k}</span><b>{v}</b></div>)}
              </div>
              <div className="row"><button className="sf-btn pri" onClick={confirmBook}>Confirmar cita</button><button className="sf-btn" onClick={() => setStep('slot')}>Cambiar horario</button></div>
            </div>
          )}
          {!busy && step === 'mine' && (
            <div className="sf-opts">
              <b>Mis próximas citas</b>
              {mine.length === 0 && <span className="sf-mute">Todavía no tiene citas con nosotros. Puede agendar una desde «Agendar una cita».</span>}
              {mine.map((a) => { const p = procs.find((x) => x.id === a.proc); return <div key={a.id} className="sf-mine"><span><b>{p.name}</b><small>{dlabel(a.date)} · {hm(a.t)} · {a.name}</small></span><button className="sf-btn sm danger" onClick={() => { cancelAppt(a.id); me(`Cancelar ${p.name}`); bot('Listo, su cita quedó cancelada y el cupo se liberó.', () => setStep('menu')) }}>Cancelar</button></div> })}
              <button className="sf-btn sm" onClick={() => setStep('menu')}>← Atrás</button>
            </div>
          )}
          {!busy && step === 'human' && <div className="sf-opts"><button className="sf-opt" onClick={() => { me('Volver al asistente'); setStep('menu') }}><b>Volver al asistente</b></button></div>}
          <div ref={end} />
        </div>
        {lastMenu && (
          <div className="sf-chips">
            <button className="sf-chip" onClick={() => faq('¿Cómo me preparo para una resonancia?', explain(procs.find((p) => p.id === 'rod')))}>¿Cómo me preparo para una resonancia?</button>
            <button className="sf-chip" onClick={() => { me('Quiero agendar una ecografía abdominal'); chooseProcSilent(procs.find((p) => p.id === 'eco')) }}>Quiero agendar una ecografía abdominal</button>
            <button className="sf-chip" onClick={() => faq('¿Dónde quedan?', `Estamos en la Carrera 27 #48-15, barrio Cabecera (dirección de ejemplo). Atendemos ${hoursText(hours)}.`)}>¿Dónde quedan?</button>
            <button className="sf-chip" onClick={() => faq('¿Cómo recibo mis resultados?', 'Los informes salen entre 24 y 48 horas hábiles y se envían al correo o se recogen en recepción con su documento. Yo no interpreto resultados: eso lo hace su médico.')}>¿Cómo recibo mis resultados?</button>
          </div>
        )}
        <form className="sf-cin" onSubmit={onSend}>
          <input aria-label="Mensaje" value={text} onChange={(e) => setText(e.target.value)} placeholder={step === 'name' ? 'Escriba su nombre completo' : 'Escriba su pregunta…'} disabled={busy} />
          <button className="sf-btn pri">Enviar</button>
        </form>
        <p className="sf-cfoot">Asistente virtual con información de demostración. No reemplaza la valoración médica. En una urgencia llame al 123. Las llamadas con voz no se simulan aquí.</p>
      </div>
    </div>
  )
}

// ---------- vistas del panel ----------
function Inicio({ s }) {
  const { cost, convs, appts, procs, closures, hours, role } = s
  const days = s.daily
  const maxDay = Math.max(...days.map((d) => d.total))
  const unconf = appts.filter((a) => a.date === 26 && a.status === 'prog').length
  const conflicts = appts.filter((a) => a.status !== 'cancel' && closures.some((c) => c.date === a.date && c.all)).length
  const noPrice = procs.filter((p) => !p.price)
  const open = s.isOpen()
  const rows = [
    [`${11 + s.handoffs} conversaciones pasaron a una persona esta semana`, 'Revise si alguien las atendió', <button key="a" className="sf-btn sm" onClick={() => { s.setCallsPre({ out: 'Pasó a una persona' }); s.go('llamadas') }}>Revisar</button>],
    ['3 devoluciones de llamada pendientes', 'Se llaman solas al abrir el horario de atención', <Pill key="b" k="info">Automático</Pill>],
    [`${unconf} citas del lunes sin confirmar`, 'Sofía envía el recordatorio hoy a las 4:00 p. m.', <button key="c" className="sf-btn sm" onClick={() => { s.setWeek(26); s.go('citas') }}>Ver citas</button>],
    ['Aún no se consulta la EPS en ADRES', 'Sofía no puede confirmar la afiliación del paciente. La Rue la activa con ustedes.', <button key="d" className="sf-btn sm" onClick={() => s.toast('Aviso enviado a La Rue (simulado)')}>Avisar a La Rue</button>],
  ]
  if (conflicts > 0) rows.push([`${conflicts} citas por reprogramar por cierres del centro`, 'Hay cierres programados que cruzan citas ya agendadas', <button key="e" className="sf-btn sm" onClick={() => { s.setWeek(26); s.go('citas') }}>Ver citas</button>])
  if (noPrice.length > 0) rows.push([`${noPrice.length} procedimiento${noPrice.length > 1 ? 's' : ''} sin precio`, 'Sofía no informa precio de lo que no lo tiene', <button key="f" className="sf-btn sm" onClick={() => { s.setProcSel(noPrice[0].id); s.go('procedimientos') }}>Abrir</button>])
  return (
    <>
      <div className="sf-hello"><h2>Buen día, {GREET[role]}</h2><p>Esto es lo que ha pasado con Sofía en octubre. Los datos de esta maqueta son de ejemplo.</p></div>
      <div className="sf-kpis">
        <div className="sf-kpi"><span>Gasto estimado de octubre</span><b>{cop(cost.monthUsd * USD)}</b><small>{usd(cost.monthUsd)} · dólar a {cop(USD)}</small></div>
        <div className="sf-kpi"><span>Llamadas atendidas</span><b>84</b><small>301 min hablados · hoy 3</small></div>
        <div className="sf-kpi"><span>Conversaciones por WhatsApp</span><b>{235 + s.chatsNew}</b><small>hoy {8 + s.chatsNew}</small></div>
        <div className="sf-kpi"><span>Tiempo de recepción ahorrado</span><b>≈ {Math.round(((84 + 235 + s.chatsNew) * 4) / 60)} h</b><small>Estimado: 4 minutos por conversación atendida</small></div>
        <div className="sf-kpi"><span>Citas agendadas por Sofía</span><b>{132 + s.booked}</b><small>41 % de las conversaciones</small></div>
      </div>
      <div className="sf-g2">
        <Card title="Gasto diario, últimos 30 días" right={<button className="sf-btn sm" onClick={() => s.go('gastos')}>Ver detalle</button>}>
          <Bars days={days} max={maxDay} cap={s.cap} />
          <div className="sf-axis"><span>vie 25 sep</span><span>sáb 24 oct</span></div>
          <p className="sf-note">Día de mayor gasto: {usd(maxDay)}. Tope diario configurado: US$ {s.cap} {s.cap > maxDay * 2 ? '(muy por encima del gasto actual, por eso no se dibuja)' : '(línea punteada)'}.</p>
          <Legend />
        </Card>
        <Card title="Requiere su atención" pad={false}>
          {rows.map(([t, sub, act], i) => <div key={i} className="sf-arow"><div><b>{t}</b><small>{sub}</small></div>{act}</div>)}
        </Card>
      </div>
      <div className="sf-g2">
        <Card title="Últimas conversaciones" right={<button className="sf-btn sm" onClick={() => { s.setCallsPre(null); s.go('llamadas') }}>Ver todas</button>} pad={false}>
          {convs.slice(0, 5).map((c) => (
            <div key={c.id} className="sf-arow conv"><span className="sf-av">{initials(c.name)}</span><div><b>{c.name}</b><small>{c.d === TODAY ? `${dlabel(c.d)} ${hm(c.t)}` : dlabel(c.d)} · {c.ch === 'Llamada' ? `${Math.round(c.min)} min` : `${c.msgs} mensajes`}</small></div><Pill k={c.out === 'Pasó a una persona' ? 'warn' : c.out === 'Agendó una cita' ? 'ok' : ''}>{c.out}</Pill></div>
          ))}
        </Card>
        <Card title="Estado del servicio" pad={false}>
          {[['Llamadas', 'Línea activa, 1 llamada a la vez', 'Funcionando'], ['WhatsApp', 'Número verificado', 'Funcionando'], ['Respaldo de datos', 'Último: hoy, 3:15 a. m., cifrado', 'Al día'], ['Horario de atención', hours.on ? `${hoursText(hours).replace(/^de /, '').replace(/^./, (c) => c.toUpperCase())}` : 'Sofía contesta a toda hora', open ? 'Abierto ahora' : 'Cerrado ahora']].map(([t, sub, st]) => (
            <div key={t} className="sf-arow"><div><b>{t}</b><small>{sub}</small></div><Pill k={st === 'Cerrado ahora' ? 'warn' : 'ok'}>{st}</Pill></div>
          ))}
        </Card>
      </div>
    </>
  )
}
const COLORS = ['#0e7c86', '#d9822b', '#7c4ddb', '#2f64d9']
const SEGN = ['Inteligencia artificial', 'Texto a voz', 'Voz a texto', 'Telefonía']
const Legend = () => <div className="sf-legend">{SEGN.map((n, i) => <span key={n}><i style={{ background: COLORS[i] }} />{n}</span>)}</div>
function Bars({ days, max, cap }) {
  const scale = Math.max(max, cap > max * 2 ? 0 : cap)
  return (
    <div className="sf-bars" role="img" aria-label="Gasto diario en dólares">
      {days.map((d, i) => (
        <div key={i} className="sf-bar" title={`${d.label}: ${usd(d.total)}`}>
          <div style={{ height: `${(d.total / scale) * 100}%` }}>
            {[3, 2, 1, 0].map((k) => <i key={k} style={{ flex: d.parts[k], background: COLORS[k] }} />)}
          </div>
        </div>
      ))}
      {cap <= max * 2 && <span className="sf-cap" style={{ bottom: `${(cap / scale) * 100}%` }} />}
    </div>
  )
}

function Gastos({ s }) {
  const [period, setPeriod] = useState('30')
  const [real, setReal] = useState({})
  const m = TIERS[s.tier].m
  const f = { 7: 0.24, 30: 1, mes: 0.756 }[period]
  const base = [20.51 * m, 5.46, 0.81, 2.22]
  const parts = base.map((v) => v * f)
  const total = parts.reduce((a, b) => a + b, 0)
  const calls = Math.round(105 * f), mins = Math.round(404 * f)
  const proj = s.cost.monthUsd * (31 / 24)
  const per3 = [0.036 * 3 * m, 0.041, 0.006, 0.017]
  const per3t = per3.reduce((a, b) => a + b, 0)
  const rows = [
    ['Anthropic (IA)', s.cost.ia], ['Microsoft Azure (voz)', 4.06], ['Soniox (voz a texto)', 0.6], ['Telnyx (llamadas)', 35.16],
  ]
  const det = [['Inteligencia artificial', 'Anthropic · Medido con el uso real que reporta el proveedor'], ['Texto a voz', 'Microsoft Azure · Medido con lo que Sofía dijo en voz alta'], ['Voz a texto', 'Soniox · Medido con los segundos de audio'], ['Telefonía', 'Telnyx · Medido con los minutos de llamada; la línea y el canal se cobran aparte']]
  return (
    <>
      <div className="sf-toolbar"><Intro>Cuánto cuesta Sofía, con los datos de cada llamada. Los valores en dólares se pasan a pesos con el dólar a {cop(USD)}.</Intro>
        <span className="sf-seg">{[['7', '7 días'], ['30', '30 días'], ['mes', 'Este mes']].map(([id, l]) => <button key={id} className={period === id ? 'on' : ''} onClick={() => setPeriod(id)}>{l}</button>)}</span>
        <button className="sf-btn" onClick={() => dl('gastos.csv', csv([['Concepto', 'USD', 'COP'], ...det.map(([n], i) => [n, parts[i].toFixed(2), Math.round(parts[i] * USD)])]))}><Ic n="down" /> Exportar CSV</button></div>
      <div className="sf-kpis four">
        <div className="sf-kpi"><span>Gasto variable del periodo</span><b>{cop(total * USD)}</b><small>{usd(total)}</small></div>
        <div className="sf-kpi"><span>Costo promedio por llamada</span><b>{cop((total / calls) * USD)}</b><small>{usd(total / calls, 3)} · {calls} llamadas</small></div>
        <div className="sf-kpi"><span>Costo por minuto hablado</span><b>{cop((total / mins) * USD)}</b><small>{usd(total / mins, 3)} · {mins} min en el periodo</small></div>
        <div className="sf-kpi"><span>Proyección de octubre</span><b>{cop(proj * USD)}</b><small>{usd(proj)} variables + US$ 58,50 fijos</small></div>
      </div>
      <Card title="Gasto por día">
        <Bars days={period === '7' ? s.daily.slice(-7) : s.daily} max={Math.max(...s.daily.map((d) => d.total))} cap={s.cap} />
        <div className="sf-axis"><span>{period === '7' ? 'sáb 18 oct' : 'vie 25 sep'}</span><span>sáb 24 oct</span></div>
        <p className="sf-note">Día de mayor gasto: {usd(Math.max(...s.daily.map((d) => d.total)))}. Tope diario configurado: US$ {s.cap}.</p>
        <Legend />
      </Card>
      <div className="sf-g2">
        <Card title="En qué se va el dinero" pad={false}>
          <table className="sf-t"><thead><tr><th>Concepto</th><th className="r">Valor</th><th className="r">%</th></tr></thead>
            <tbody>{det.map(([n, sub], i) => (
              <tr key={n}><td><span className="sf-dot" style={{ background: COLORS[i] }} /><b>{n}</b><small className="blk">{sub}</small></td><td className="r"><b>{usd(parts[i])}</b><small className="blk">{cop(parts[i] * USD)}</small></td><td className="r">{Math.round((parts[i] / total) * 100)} %</td></tr>
            ))}</tbody></table>
          <p className="sf-note pad">WhatsApp: los primeros 1.000 mensajes de servicio al mes no se cobran (Meta). Aquí se mostrará lo que cobre Meta cuando se supere ese límite.</p>
        </Card>
        <Card title="Cuánto cuesta una llamada de 3 minutos">
          <div className="sf-big">{usd(per3t, 3)} <small>≈ {cop(per3t * USD)}</small></div>
          <p className="sf-note">Con el nivel de inteligencia actual ({TIERS[s.tier].label}) y las tarifas de lista.</p>
          {SEGN.map((n, i) => <div key={n} className="sf-mini"><span>{n}</span><div><i style={{ width: `${(per3[i] / per3t) * 100}%`, background: COLORS[i] }} /></div><b>{usd(per3[i], 3)}</b></div>)}
          <div className="sf-info"><Ic n="info" /> Es una estimación con tarifas de lista. Para que sea lo más cercana posible a la factura, abajo puede comparar con lo que cobra cada proveedor.</div>
        </Card>
      </div>
      <Card title="Comparar con las facturas" pad={false}>
        <p className="sf-note pad">Escriba lo que cobró cada proveedor este mes (en dólares) y vea la diferencia con lo estimado.</p>
        <table className="sf-t"><thead><tr><th>Proveedor</th><th className="r">Estimado</th><th className="r">Factura real</th><th className="r">Diferencia</th></tr></thead>
          <tbody>{rows.map(([n, est]) => {
            const v = parseFloat(String(real[n] ?? '').replace(',', '.'))
            return (
              <tr key={n}><td>{n}</td><td className="r">{usd(est)}</td>
                <td className="r"><input className="sf-in num" inputMode="decimal" aria-label={`Factura real ${n}`} placeholder="0,00" value={real[n] ?? ''} onChange={(e) => setReal({ ...real, [n]: e.target.value })} /></td>
                <td className="r">{Number.isFinite(v) ? `${v - est >= 0 ? '+' : '−'}${usd(Math.abs(v - est))}` : '—'}</td></tr>
            )
          })}</tbody></table>
      </Card>
      <Card title="Costos fijos mensuales" pad={false}>
        {[['Número y canal de telefonía', 33.5], ['Servidor y almacenamiento', 25]].map(([n, v]) => <div key={n} className="sf-fix"><b>{n}</b><span>{usd(v)}</span><em>{cop(v * USD)}</em></div>)}
      </Card>
    </>
  )
}

function Llamadas({ s }) {
  const pre = s.callsPre
  const [ch, setCh] = useState('Todos')
  const [range, setRange] = useState('30')
  const [out, setOut] = useState(pre?.out ?? '')
  const [page, setPage] = useState(0)
  useEffect(() => { if (pre?.out) setOut(pre.out) }, [pre])
  const m = TIERS[s.tier].m
  const cost = (c) => (c.ch === 'Llamada' ? c.min * (0.0213 + 0.036 * m) : c.msgs * 0.0016 * m)
  const list = s.convs.filter((c) => (ch === 'Todos' || (ch === 'Llamadas' ? c.ch === 'Llamada' : c.ch === 'WhatsApp')) && (range === '30' || (range === '7' ? c.d >= 18 : c.d === TODAY)) && (!out || c.out === out))
  const total = list.length
  const shown = list.slice(page * 12, page * 12 + 12)
  const tot = (n) => (n === 0 ? 0 : n)
  return (
    <>
      <Intro>Todas las llamadas y chats de WhatsApp que ha atendido Sofía, con su duración y su costo aproximado.</Intro>
      <div className="sf-filters">
        <span className="sf-seg">{['Todos', 'Llamadas', 'WhatsApp'].map((l) => <button key={l} className={ch === l ? 'on' : ''} onClick={() => { setCh(l); setPage(0) }}>{l}</button>)}</span>
        <select className="sf-in" aria-label="Rango" value={range} onChange={(e) => { setRange(e.target.value); setPage(0) }}><option value="1">Hoy</option><option value="7">Últimos 7 días</option><option value="30">Últimos 30 días</option></select>
        <select className="sf-in" aria-label="Resultado" value={out} onChange={(e) => { setOut(e.target.value); setPage(0) }}><option value="">Cualquier resultado</option>{OUTS.map((o) => <option key={o}>{o}</option>)}</select>
      </div>
      <Card pad={false}>
        <div className="sf-scroll"><table className="sf-t"><thead><tr><th>Cuándo</th><th>Canal</th><th>Contacto</th><th>Duración</th><th>Resultado</th><th className="r">Costo aprox.</th></tr></thead>
          <tbody>{shown.map((c) => (
            <tr key={c.id}><td>{dlabel(c.d)}<small className="blk">{hm(c.t)}</small></td><td>{c.ch}</td><td>{c.name}<small className="blk">{c.tel}</small></td><td>{c.ch === 'Llamada' ? `${Math.floor(c.min)} min ${Math.round((c.min % 1) * 60)} s` : `${c.msgs} mensajes`}</td><td><Pill k={c.out === 'Pasó a una persona' ? 'warn' : c.out === 'Agendó una cita' ? 'ok' : c.out === 'Colgó sin atender' ? 'bad' : ''}>{c.out}</Pill></td><td className="r">{usd(cost(c), 3)}<small className="blk">{cop(cost(c) * USD)}</small></td></tr>
          ))}{shown.length === 0 && <tr><td colSpan="6" className="sf-empty">No hay conversaciones con ese filtro.</td></tr>}</tbody></table></div>
        <Pager page={page} setPage={setPage} total={tot(total)} size={12} />
      </Card>
      {total > 0 && ch === 'Todos' && range === '30' && !out && <p className="sf-note">Mostrando una muestra de {total} de las conversaciones del mes.</p>}
    </>
  )
}

function Opinion({ s }) {
  const [on, setOn] = useState(false)
  const bars = [['5 puntos', 21], ['4 puntos', 20], ['3 puntos', 2], ['2 puntos', 3], ['1 punto', 0]]
  const topics = [['Precio', 7, 3], ['Trato del personal', 9, 0], ['Tiempo de espera', 8, 1], ['Preparación clara', 6, 1], ['Facilidad para agendar', 6, 0], ['Entrega de resultados', 5, 0]]
  const com = [['Muy amables y me explicaron todo antes del examen.', 'Trato del personal', 'hace 1 día', 10], ['Agendé por WhatsApp en dos minutos, sin llamar a nadie.', 'Facilidad para agendar', 'hace 2 días', 10], ['Me dijeron exactamente qué traer y cuántas horas de ayuno.', 'Preparación clara', 'hace 3 días', 9], ['Llegué a la hora y esperé más de 40 minutos para pasar.', 'Tiempo de espera', 'hace 4 días', 5], ['El informe se demoró más de lo que me dijeron.', 'Entrega de resultados', 'hace 5 días', 6], ['No me quedó claro cuánto iba a pagar al final.', 'Precio', 'hace 6 días', 7]]
  return (
    <>
      <Intro>Lo que dicen los pacientes después de su estudio. Sofía les escribe por WhatsApp al día siguiente con dos preguntas cortas. Las respuestas son anónimas: aquí no se ve quién contestó.</Intro>
      <div className="sf-kpis three">
        <div className="sf-kpi"><span>Satisfacción</span><b>4,3 de 5</b><small>46 respuestas en 30 días</small></div>
        <div className="sf-kpi"><span>Recomendación (NPS)</span><b>59</b><small>70 % lo recomienda · 11 % no</small></div>
        <div className="sf-kpi"><span>Respondieron</span><b>65 %</b><small>46 de 71 encuestas enviadas</small></div>
      </div>
      <div className="sf-g2">
        <Card title="Cómo calificaron">{bars.map(([l, n]) => <div key={l} className="sf-mini"><span>{l}</span><div><i style={{ width: `${(n / 21) * 100}%`, background: '#0e7c86' }} /></div><b>{n}</b></div>)}</Card>
        <Card title="De qué hablan">{topics.map(([t, a, b]) => <div key={t} className="sf-topic"><b>{t}</b><small>{a} a favor · {b} por mejorar</small></div>)}</Card>
      </div>
      <Card title="Comentarios recientes" pad={false}>
        {com.map(([q, t, w, n]) => <div key={q} className="sf-arow"><div><b>«{q}»</b><small>{t} · {w} · por WhatsApp</small></div><Pill k={n >= 9 ? 'ok' : n >= 7 ? 'info' : 'warn'}>{n} de 10</Pill></div>)}
      </Card>
      <Card title="Cómo funciona">
        <Sw on={on} set={(v) => { setOn(v); s.log('Ajustes', v ? 'Activó la encuesta de satisfacción' : 'Apagó la encuesta de satisfacción', v ? 'Apagada' : 'Activada', v ? 'Activada' : 'Apagada'); s.toast(v ? 'Encuesta activada' : 'Encuesta apagada') }} label="Enviar la encuesta al día siguiente del estudio" sub={on ? 'Encendida. Solo a pacientes que autorizaron y dentro del horario de contacto.' : `Apagada hasta que ${CENTER} la apruebe. Solo a pacientes que autorizaron y dentro del horario de contacto.`} />
        <p className="sf-note">La encuesta pregunta «¿del 0 al 10, qué tanto nos recomendaría?» y «¿qué fue lo mejor o lo que debemos mejorar?». Quien no contesta no recibe recordatorios de la encuesta.</p>
      </Card>
    </>
  )
}

function Pregunte({ s }) {
  const [q, setQ] = useState('')
  const [hist, setHist] = useState([])
  const m = TIERS[s.tier].m
  const live = s.appts.filter((a) => a.status !== 'cancel')
  const answer = (txt) => {
    const t = txt.toLowerCase()
    if (/gast|cost|cuest|dinero/.test(t)) return `Esta semana Sofía costó cerca de ${usd(s.cost.monthUsd * 0.24)} (${cop(s.cost.monthUsd * 0.24 * USD)}) con el nivel ${TIERS[s.tier].label}. El gasto de IA es ${Math.round(((15.61 * m) / s.cost.monthUsd) * 100)} % del total.`
    if (/vuelv|no regres|retorn/.test(t)) return 'De los pacientes atendidos en los últimos 90 días, 12 no han vuelto a agendar. 9 de ellos tenían un control recomendado. Sofía no les escribe sin autorización; puede pedirle a recepción que los contacte.'
    if (/señal|semana|alerta/.test(t)) return `Señales de la semana: ${11 + s.handoffs} conversaciones pasaron a una persona, ${live.filter((a) => a.status === 'noshow').length} inasistencias registradas y ${live.filter((a) => a.date >= 26 && a.status === 'prog').length} citas próximas sin confirmar.`
    if (/mes|va el|cómo va/.test(t)) return `En octubre van ${132 + s.booked} citas agendadas por Sofía, ${84} llamadas y ${235 + s.chatsNew} chats de WhatsApp. La satisfacción de los pacientes es 4,3 de 5 y el gasto estimado es ${cop(s.cost.monthUsd * USD)}.`
    return 'Puedo responder con las cifras que ya calcula Sofía: cómo va el mes, señales de la semana, pacientes que no vuelven y gasto. Pruebe con una de esas preguntas.'
  }
  const ask = (txt) => { const v = txt.trim(); if (!v) return; setHist((h) => [{ q: v, a: answer(v) }, ...h]); setQ('') }
  return (
    <>
      <Intro>Pregunte por cómo va el centro y responde con cifras ya calculadas de Sofía. No abre fichas ni conversaciones, y solo ve lo que su rol permite.</Intro>
      <Card title="¿Qué quiere saber de su centro hoy?">
        <form className="sf-ask" onSubmit={(e) => { e.preventDefault(); ask(q) }}><input className="sf-in" aria-label="Pregunta" value={q} onChange={(e) => setQ(e.target.value)} placeholder="Escriba su pregunta" /><button className="sf-btn pri">Preguntar</button></form>
        <div className="sf-chips2">{['¿Cómo va el mes?', 'Señales de la semana', 'Pacientes que no vuelven', '¿Cuánto gastamos esta semana?'].map((t) => <button key={t} className="sf-chip" onClick={() => ask(t)}>{t}</button>)}</div>
      </Card>
      {hist.map((h, i) => <Card key={i} title={h.q}><p className="sf-answer">{h.a}</p></Card>)}
    </>
  )
}

function Pacientes({ s }) {
  const [eps, setEps] = useState('')
  const [qq, setQq] = useState('')
  const [page, setPage] = useState(0)
  const [asc, setAsc] = useState(true)
  const [nu, setNu] = useState(null)
  const list = s.patients.filter((p) => (!eps || p.eps === eps) && (!qq || p.name.toLowerCase().includes(qq.toLowerCase()) || p.id.toLowerCase().includes(qq.toLowerCase()))).sort((a, b) => (asc ? 1 : -1) * a.name.split(' ').slice(1).join(' ').localeCompare(b.name.split(' ').slice(1).join(' ')))
  return (
    <>
      <Intro>Las personas que Sofía ha atendido o que ustedes cargan. Aquí se corrigen datos, se importan listas y se atienden solicitudes de los pacientes sobre sus datos.</Intro>
      <div className="sf-filters">
        <input className="sf-in" aria-label="Buscar paciente" placeholder="Buscar por nombre o código" value={qq} onChange={(e) => { setQq(e.target.value); setPage(0) }} />
        <select className="sf-in" aria-label="EPS" value={eps} onChange={(e) => { setEps(e.target.value); setPage(0) }}><option value="">Todas las EPS</option>{EPS.map((e) => <option key={e}>{e}</option>)}</select>
        <span className="sp" />
        <button className="sf-btn pri" onClick={() => setNu({ name: '', doc: '', phone: '', eps: 'Particular' })}><Ic n="plus" /> Nuevo paciente</button>
        <button className="sf-btn" onClick={() => s.toast('Importar: en esta demo no se carga ningún archivo')}><Ic n="up" /> Importar desde Excel</button>
        <button className="sf-btn" onClick={() => dl('pacientes.csv', csv([['Código', 'Nombre', 'Documento', 'Celular', 'EPS'], ...s.patients.map((p) => [p.id, p.name, p.doc, p.phone, p.eps])]))}><Ic n="down" /> Exportar</button>
      </div>
      <Card pad={false}>
        <div className="sf-scroll"><table className="sf-t"><thead><tr><th><button className="sf-th" onClick={() => setAsc(!asc)}>Paciente {asc ? '↑' : '↓'}</button></th><th>Documento</th><th>Celular</th><th>EPS</th><th>Autorización de datos</th></tr></thead>
          <tbody>{list.slice(page * 12, page * 12 + 12).map((p) => <tr key={p.id}><td><span className="sf-who"><span className="sf-av">{initials(p.name)}</span><span><b>{p.name}</b><small className="blk">{p.id}</small></span></span></td><td>{p.doc}</td><td>{p.phone}</td><td>{p.eps}</td><td>{p.auth}</td></tr>)}</tbody></table></div>
        <Pager page={page} setPage={setPage} total={list.length} size={12} />
      </Card>
      {nu && (
        <Modal title="Nuevo paciente" onClose={() => setNu(null)}>
          <form className="sf-form" onSubmit={(e) => {
            e.preventDefault()
            if (!nu.name.trim()) return
            const id = `P-${1100 + s.patients.length}`
            s.setPatients((l) => [...l, { id, name: nu.name.trim(), doc: nu.doc || 'CC sin registrar', phone: nu.phone || '—', eps: nu.eps, auth: `${dlabel(TODAY)} · Panel` }])
            s.log('Pacientes', `Creó el paciente ${id}`, '—', 'Nuevo registro')
            s.toast('Paciente creado'); setNu(null)
          }}>
            <label className="sf-f">Nombre completo<input className="sf-in" autoFocus value={nu.name} onChange={(e) => setNu({ ...nu, name: e.target.value })} /></label>
            <label className="sf-f">Documento<input className="sf-in" value={nu.doc} onChange={(e) => setNu({ ...nu, doc: e.target.value })} placeholder="CC 1.000.000.000" /></label>
            <label className="sf-f">Celular<input className="sf-in" inputMode="tel" value={nu.phone} onChange={(e) => setNu({ ...nu, phone: e.target.value })} /></label>
            <label className="sf-f">EPS<select className="sf-in" value={nu.eps} onChange={(e) => setNu({ ...nu, eps: e.target.value })}>{EPS.map((e) => <option key={e}>{e}</option>)}</select></label>
            <div className="sf-actions"><button className="sf-btn pri">Guardar paciente</button><button type="button" className="sf-btn" onClick={() => setNu(null)}>Cancelar</button></div>
          </form>
        </Modal>
      )}
    </>
  )
}

const STAT = { prog: ['Programada', 'info'], conf: ['Confirmada', 'ok'], done: ['Atendida', ''], noshow: ['No asistió', 'bad'], cancel: ['Cancelada', ''] }
function Citas({ s }) {
  const { appts, procs, week, setWeek, hours, closures } = s
  const [mode, setMode] = useState('semana')
  const [team, setTeam] = useState('')
  const [sel, setSel] = useState(null)
  const dates = [0, 1, 2, 3, 4, 5].map((i) => week + i)
  const open = toMin(hours.open), close = toMin(hours.close)
  const px = 48
  const procOf = (a) => procs.find((p) => p.id === a.proc)
  const vis = appts.filter((a) => a.status !== 'cancel' && (!team || procOf(a).team === team))
  const upd = (id, patch) => { s.setAppts((l) => l.map((a) => (a.id === id ? { ...a, ...patch } : a))); setSel(null) }
  const A = sel && appts.find((a) => a.id === sel)
  return (
    <>
      <Intro>La agenda de la semana. Lo sombreado está fuera del horario de atención o es un día cerrado. Toque una cita para verla o moverla.</Intro>
      <Card pad={false}>
        <div className="sf-caltop">
          <button className="sf-btn sm" aria-label="Semana anterior" onClick={() => setWeek(week - 7)}>←</button>
          <button className="sf-btn sm" onClick={() => setWeek(19)}>Hoy</button>
          <button className="sf-btn sm" aria-label="Semana siguiente" onClick={() => setWeek(week + 7)}>→</button>
          <b>{dlabel(week)} al {dlabel(week + 5)}</b>
          <span className="sp" />
          <span className="sf-seg">{[['semana', 'Semana'], ['lista', 'Lista']].map(([id, l]) => <button key={id} className={mode === id ? 'on' : ''} onClick={() => setMode(id)}>{l}</button>)}</span>
          <select className="sf-in" aria-label="Equipo" value={team} onChange={(e) => setTeam(e.target.value)}><option value="">Todos los equipos</option>{TEAMS.map((t) => <option key={t}>{t}</option>)}</select>
        </div>
        {mode === 'semana' ? (
          <div className="sf-cal">
            <div className="sf-calhead"><span />{dates.map((d) => <div key={d}>{DOW[dow(d)].replace(/^./, (c) => c.toUpperCase())}<small>{dn(d)}</small></div>)}</div>
            <div className="sf-calbody" style={{ height: 12 * px }}>
              <div className="sf-hours">{Array.from({ length: 12 }, (_, i) => <span key={i} style={{ height: px }}>{hh(420 + i * 60)}</span>)}</div>
              {dates.map((d) => {
                const closed = !hours.days[dow(d)] || closures.some((c) => c.date === d && c.all)
                const day = vis.filter((a) => a.date === d).sort((a, b) => a.t - b.t)
                const ends = [], lane = new Map()
                day.forEach((a) => { let l = ends.findIndex((e) => e <= a.t); if (l < 0) { l = ends.length; ends.push(0) } ends[l] = a.t + a.dur; lane.set(a.id, l) })
                const lanes = Math.max(1, ends.length)
                return (
                  <div key={d} className="sf-calcol" data-day={d}>
                    {closed ? <span className="sf-shade" style={{ top: 0, bottom: 0 }} /> : <><span className="sf-shade" style={{ top: 0, height: Math.max(0, ((open - 420) / 60) * px) }} /><span className="sf-shade" style={{ top: ((close - 420) / 60) * px, bottom: 0 }} /></>}
                    {d === TODAY && <span className="sf-now" style={{ top: ((NOW - 420) / 60) * px }} />}
                    {day.map((a) => (
                      <button key={a.id} className={`sf-ev ${a.status}`} onClick={() => setSel(a.id)} title={`${a.name} · ${procOf(a).name}`} style={{ top: ((a.t - 420) / 60) * px, height: Math.max(26, (a.dur / 60) * px - 2), left: `${(lane.get(a.id) / lanes) * 100}%`, width: `${100 / lanes - 2}%` }}>
                        <b>{hm(a.t)}</b><span>{procOf(a).name}</span><em>{first(a.name)}</em>
                      </button>
                    ))}
                  </div>
                )
              })}
            </div>
            <div className="sf-key">{[['prog', 'Programada'], ['conf', 'Confirmada'], ['done', 'Atendida'], ['noshow', 'No asistió']].map(([k, l]) => <span key={k}><i className={k} />{l}</span>)}</div>
          </div>
        ) : (
          <table className="sf-t"><thead><tr><th>Cuándo</th><th>Paciente</th><th>Examen</th><th>Origen</th><th>Estado</th></tr></thead>
            <tbody>{[...vis].filter((a) => a.date >= week && a.date <= week + 5).sort((a, b) => a.date - b.date || a.t - b.t).map((a) => <tr key={a.id}><td>{dlabel(a.date)}<small className="blk">{hm(a.t)}</small></td><td><button className="sf-th" onClick={() => setSel(a.id)}>{a.name}</button></td><td>{procOf(a).name}</td><td>{a.src}</td><td><Pill k={STAT[a.status][1]}>{STAT[a.status][0]}</Pill></td></tr>)}
              {vis.filter((a) => a.date >= week && a.date <= week + 5).length === 0 && <tr><td colSpan="5" className="sf-empty">No hay citas esta semana.</td></tr>}</tbody></table>
        )}
      </Card>
      {A && (
        <Modal title={A.name} onClose={() => setSel(null)}>
          <dl className="sf-dl"><dt>Examen</dt><dd>{procOf(A).name}</dd><dt>Día y hora</dt><dd>{dlabel(A.date)} · {hm(A.t)} ({A.dur} min)</dd><dt>Equipo</dt><dd>{procOf(A).team}</dd><dt>Origen</dt><dd>{A.src}</dd><dt>Estado</dt><dd><Pill k={STAT[A.status][1]}>{STAT[A.status][0]}</Pill></dd></dl>
          <div className="sf-actions">
            {A.status === 'prog' && <button className="sf-btn pri" onClick={() => upd(A.id, { status: 'conf' })}>Confirmar</button>}
            <button className="sf-btn" onClick={() => upd(A.id, { status: 'done' })}>Atendida</button>
            <button className="sf-btn" onClick={() => upd(A.id, { status: 'noshow' })}>No asistió</button>
            <button className="sf-btn danger" onClick={() => upd(A.id, { status: 'cancel' })}>Cancelar cita</button>
            <button className="sf-btn" onClick={() => setSel(null)}>Cerrar</button>
          </div>
        </Modal>
      )}
    </>
  )
}

function Procedimientos({ s }) {
  const { procs, setProcs } = s
  const [q, setQ] = useState('')
  const [tab, setTab] = useState('Datos')
  const sel = procs.find((p) => p.id === s.procSel) ?? procs[0]
  const [draft, setDraft] = useState(sel)
  useEffect(() => { setDraft(sel) }, [sel.id]) // eslint-disable-line react-hooks/exhaustive-deps
  const dirty = JSON.stringify(draft) !== JSON.stringify(sel)
  const set = (k, v) => setDraft((d) => ({ ...d, [k]: v }))
  const save = () => {
    if (draft.price !== sel.price) s.log('Procedimientos', `Cambió el precio de «${sel.name}»`, cop(sel.price), cop(draft.price))
    if (draft.name !== sel.name || draft.on !== sel.on || draft.team !== sel.team || draft.dur !== sel.dur || draft.prep !== sel.prep || draft.arrive !== sel.arrive || draft.after !== sel.after || draft.bring !== sel.bring || draft.order !== sel.order || draft.alias !== sel.alias || draft.cat !== sel.cat) s.log('Procedimientos', `Editó «${sel.name}»`, '—', 'Ficha actualizada')
    setProcs((l) => l.map((p) => (p.id === sel.id ? draft : p)))
    s.toast('Cambios guardados: Sofía ya los usa en los chats')
  }
  const list = procs.filter((p) => p.name.toLowerCase().includes(q.toLowerCase()))
  const n = filled(draft)
  const dataTab = {
    Datos: (
      <div className="sf-form two">
        <label className="sf-f">Nombre del procedimiento<input className="sf-in" value={draft.name} onChange={(e) => set('name', e.target.value)} /></label>
        <label className="sf-f">Cómo lo llama la gente<input className="sf-in" value={draft.alias} onChange={(e) => set('alias', e.target.value)} /><small>Separe con comas. Sofía lo usa para entender «la eco» o «la placa de pecho».</small></label>
        <label className="sf-f">Categoría<select className="sf-in" value={draft.cat} onChange={(e) => set('cat', e.target.value)}>{CATS.map((c) => <option key={c}>{c}</option>)}</select></label>
        <div className="sf-f">Estado<Sw on={draft.on} set={(v) => set('on', v)} label="Sofía lo ofrece" /></div>
        <div className="sf-f">Orden médica<Sw on={draft.order} set={(v) => set('order', v)} label="Se exige orden médica" /></div>
      </div>
    ),
    Agenda: (
      <div className="sf-form two">
        <label className="sf-f">Equipo<select className="sf-in" value={draft.team} onChange={(e) => set('team', e.target.value)}>{TEAMS.map((c) => <option key={c}>{c}</option>)}</select></label>
        <label className="sf-f">Duración en el equipo (min)<input className="sf-in" type="number" min="5" step="5" value={draft.dur} onChange={(e) => set('dur', Math.max(5, +e.target.value || 5))} /></label>
        <label className="sf-f">Llegar antes (min)<input className="sf-in" type="number" min="0" step="5" value={draft.arrive} onChange={(e) => set('arrive', Math.max(0, +e.target.value || 0))} /></label>
      </div>
    ),
    Preparación: (
      <div className="sf-form">
        <label className="sf-f">Qué debe hacer antes<textarea className="sf-in" rows="4" value={draft.prep} onChange={(e) => set('prep', e.target.value)} /></label>
        <label className="sf-f">Qué debe traer<textarea className="sf-in" rows="2" value={draft.bring} onChange={(e) => set('bring', e.target.value)} /></label>
      </div>
    ),
    Después: (
      <div className="sf-form"><label className="sf-f">Indicaciones después del estudio<textarea className="sf-in" rows="3" value={draft.after} onChange={(e) => set('after', e.target.value)} /></label></div>
    ),
    Precio: (
      <div className="sf-form two"><label className="sf-f">Valor particular (COP)<input className="sf-in" type="number" min="0" step="1000" aria-label="Valor particular" value={draft.price} onChange={(e) => set('price', Math.max(0, +e.target.value || 0))} /><small>{draft.price ? `Sofía dirá: «El valor particular es ${cop(draft.price)}.»` : 'Sin precio: Sofía no informa valor de lo que no lo tiene.'}</small></label></div>
    ),
  }
  return (
    <>
      <Intro>Aquí se define qué ofrece el centro y qué le dice Sofía al paciente de cada procedimiento. Lo que se escriba se usa de inmediato en las llamadas y los chats.</Intro>
      <div className="sf-split">
        <Card pad={false} cls="sf-plist">
          <div className="sf-cb"><input className="sf-in" aria-label="Buscar procedimiento" placeholder="Buscar procedimiento" value={q} onChange={(e) => setQ(e.target.value)} /></div>
          <div className="sf-pl">{list.map((p) => <button key={p.id} className={`sf-pi ${p.id === sel.id ? 'on' : ''}`} onClick={() => s.setProcSel(p.id)}><b>{p.name}</b><small>{p.team} · {p.price ? cop(p.price) : 'Sin precio'}{!p.on && ' · Oculto'}</small></button>)}</div>
          <div className="sf-cb sf-actions">
            <button className="sf-btn pri" onClick={() => { const id = `n${Date.now()}`; setProcs((l) => [...l, { id, name: 'Procedimiento nuevo', alias: '', cat: 'General', team: 'Ecógrafo', dur: 20, price: 0, on: false, order: true, arrive: 10, prep: '', bring: 'documento de identidad y orden médica', after: '' }]); s.setProcSel(id); s.log('Procedimientos', 'Creó un procedimiento nuevo', '—', 'Procedimiento nuevo') }}><Ic n="plus" /> Nuevo</button>
            <button className="sf-btn" onClick={() => s.toast('Importar: en esta demo no se carga ningún archivo')}><Ic n="up" /> Importar</button>
            <button className="sf-btn" onClick={() => dl('procedimientos.csv', csv([['Nombre', 'Categoría', 'Equipo', 'Minutos', 'Precio'], ...procs.map((p) => [p.name, p.cat, p.team, p.dur, p.price])]))}><Ic n="down" /> Exportar</button>
          </div>
        </Card>
        <div className="sf-stack">
          <Card title={draft.name} pad={false}>
            <div className="sf-tabs" role="tablist">{Object.keys(dataTab).map((t) => <button key={t} role="tab" aria-selected={tab === t} className={tab === t ? 'on' : ''} onClick={() => setTab(t)}>{t}</button>)}</div>
            <div className="sf-cb">{dataTab[tab]}</div>
            <div className="sf-savebar"><span>{dirty ? 'Hay cambios sin guardar' : 'Sin cambios por guardar'}</span><button className="sf-btn pri" disabled={!dirty} onClick={save}>Guardar cambios</button></div>
          </Card>
          <Card title="Así se lo explica Sofía" right={<Pill k="ok">Ficha {n}/8</Pill>}>
            <div className="sf-pv"><div className="sf-bub me">¿Qué necesito para {(draft.alias.split(',')[0] || draft.name).trim().toLowerCase()}?</div><div className="sf-bub">{explain(draft)}</div></div>
            <div className={`sf-info ${n === 8 ? 'ok' : 'warn'}`}><Ic n={n === 8 ? 'check' : 'info'} /> {n === 8 ? 'La ficha está completa.' : 'Faltan datos: complete la ficha para que Sofía responda bien.'}</div>
            <p className="sf-note">Sofía arma la respuesta con estos campos. Las reglas de seguridad (no da diagnósticos ni interpreta resultados) no se cambian desde aquí.</p>
          </Card>
        </div>
      </div>
    </>
  )
}

function Horarios({ s }) {
  const { hours, setHours, closures, setClosures } = s
  const [tab, setTab] = useState('Atención de Sofía')
  const [nc, setNc] = useState({ date: 30, reason: '', all: true })
  const [teamH, setTeamH] = useState(Object.fromEntries(TEAMS.map((t) => [t, { open: '07:00', close: '17:00', on: true }])))
  const [draft, setDraft] = useState(hours)
  const set = (k, v) => setDraft((d) => ({ ...d, [k]: v }))
  const dirty = JSON.stringify(draft) !== JSON.stringify(hours)
  const save = () => { setHours(draft); s.log('Horarios', 'Cambió el horario de atención de Sofía', hoursText(hours), hoursText(draft)); s.toast('Horario guardado') }
  const txt = hoursText(draft)
  return (
    <>
      <Intro>Cuándo atiende Sofía, cuándo trabaja cada equipo y qué días el centro no abre.</Intro>
      <div className="sf-tabs top" role="tablist">{['Atención de Sofía', 'Equipos', 'Festivos y cierres'].map((t) => <button key={t} role="tab" aria-selected={tab === t} className={tab === t ? 'on' : ''} onClick={() => setTab(t)}>{t}</button>)}</div>
      {tab === 'Atención de Sofía' && (
        <div className="sf-g2">
          <Card title="Horario de atención de Sofía">
            <Sw on={draft.on} set={(v) => set('on', v)} label="Atender solo en este horario" sub="Apagado, Sofía contesta a toda hora." />
            <div className="sf-lab">Días</div>
            <div className="sf-days">{DOW.map((d, i) => <button key={d} aria-pressed={!!draft.days[i]} className={draft.days[i] ? 'on' : ''} onClick={() => set('days', draft.days.map((v, j) => (j === i ? (v ? 0 : 1) : v)))}>{d.replace(/^./, (c) => c.toUpperCase())}</button>)}</div>
            <div className="sf-form two tight">
              <label className="sf-f">Abre<input className="sf-in" type="time" aria-label="Abre" value={draft.open} onChange={(e) => set('open', e.target.value)} /></label>
              <label className="sf-f">Cierra<input className="sf-in" type="time" aria-label="Cierra" value={draft.close} onChange={(e) => set('close', e.target.value)} /></label>
            </div>
            <label className="sf-f">Mensaje fuera de horario<textarea className="sf-in" rows="3" value={draft.msg} onChange={(e) => set('msg', e.target.value)} /></label>
            <Sw on={draft.callback} set={(v) => set('callback', v)} label="Devolver la llamada cuando abra el centro" />
            <Sw on={draft.wa} set={(v) => set('wa', v)} label="Responder WhatsApp fuera de horario con este mensaje" />
            <div className="sf-actions"><button className="sf-btn pri" disabled={!dirty} onClick={save}>Guardar horario</button></div>
          </Card>
          <Card title="Así responde Sofía">
            <div className="sf-pv"><div className="sf-bub me">Buenas noches, quisiera una cita.</div><div className="sf-bub">{`Hola, le habla Sofía de ${CENTER}. Nuestro horario de atención es ${txt}. ${draft.callback ? 'Con gusto le devolvemos la llamada cuando abramos.' : ''}`}</div>{draft.wa && <div className="sf-bub">{draft.msg}</div>}</div>
            <p className="sf-note">Hoy, el horario es: <b>{txt}</b>.</p>
          </Card>
        </div>
      )}
      {tab === 'Equipos' && (
        <Card title="Horario de cada equipo" pad={false}>
          <table className="sf-t"><thead><tr><th>Equipo</th><th>Trabaja</th><th>Abre</th><th>Cierra</th></tr></thead>
            <tbody>{TEAMS.map((t) => <tr key={t}><td><b>{t}</b></td><td><Sw on={teamH[t].on} set={(v) => setTeamH({ ...teamH, [t]: { ...teamH[t], on: v } })} label={`${t} activo`} /></td><td><input className="sf-in" type="time" aria-label={`Abre ${t}`} value={teamH[t].open} onChange={(e) => setTeamH({ ...teamH, [t]: { ...teamH[t], open: e.target.value } })} /></td><td><input className="sf-in" type="time" aria-label={`Cierra ${t}`} value={teamH[t].close} onChange={(e) => setTeamH({ ...teamH, [t]: { ...teamH[t], close: e.target.value } })} /></td></tr>)}</tbody></table>
          <div className="sf-savebar"><span>Sofía solo ofrece cupos cuando el equipo y el centro están abiertos.</span><button className="sf-btn pri" onClick={() => { s.log('Horarios', 'Ajustó el horario de los equipos', '—', 'Actualizado'); s.toast('Horario de equipos guardado') }}>Guardar</button></div>
        </Card>
      )}
      {tab === 'Festivos y cierres' && (
        <div className="sf-g2">
          <Card title="Cierres programados" pad={false}>
            {[...closures].sort((a, b) => a.date - b.date).map((c) => <div key={c.id} className="sf-arow"><div><b>{dlabel(c.date)}{c.all ? ', todo el día' : ''}</b><small>{c.reason}</small></div><button className="sf-btn sm danger" onClick={() => { setClosures((l) => l.filter((x) => x.id !== c.id)); s.log('Horarios', 'Quitó un cierre', `${dlabel(c.date)}: ${c.reason}`, '—'); s.toast('Cierre eliminado') }}>Quitar</button></div>)}
            {closures.length === 0 && <p className="sf-note pad">No hay cierres programados.</p>}
          </Card>
          <Card title="Agregar un cierre">
            <form className="sf-form" onSubmit={(e) => {
              e.preventDefault()
              if (!nc.reason.trim()) return
              setClosures((l) => [...l, { id: Date.now(), date: +nc.date, reason: nc.reason.trim(), all: nc.all }])
              s.log('Horarios', 'Agregó un cierre extraordinario', '—', `${dn(+nc.date)} ${mon(+nc.date)}, ${nc.all ? 'todo el día' : 'parcial'}: ${nc.reason.trim()}`)
              setNc({ ...nc, reason: '' }); s.toast('Cierre agregado')
            }}>
              <label className="sf-f">Fecha<select className="sf-in" aria-label="Fecha del cierre" value={nc.date} onChange={(e) => setNc({ ...nc, date: e.target.value })}>{[25, 26, 27, 28, 29, 30, 31, 32, 33, 34].map((d) => <option key={d} value={d}>{dlabel(d)}</option>)}</select></label>
              <label className="sf-f">Motivo<input className="sf-in" aria-label="Motivo del cierre" value={nc.reason} onChange={(e) => setNc({ ...nc, reason: e.target.value })} placeholder="Ej.: mantenimiento del resonador" /></label>
              <Sw on={nc.all} set={(v) => setNc({ ...nc, all: v })} label="Todo el día" />
              <div className="sf-actions"><button className="sf-btn pri">Agregar cierre</button></div>
              <small className="sf-note">Si el día ya tiene citas, aparecen en «Requiere su atención» para reprogramarlas.</small>
            </form>
          </Card>
        </div>
      )}
    </>
  )
}

function Asistente({ s }) {
  const [tab, setTab] = useState('Mensajes')
  const { msgs, setMsgs, info, setInfo } = s
  const [d, setD] = useState(msgs)
  const [ei, setEi] = useState(info[0].id)
  const cur = info.find((x) => x.id === ei) ?? info[0]
  const [txt, setTxt] = useState(cur.x)
  const [ntitle, setNtitle] = useState('')
  useEffect(() => { setTxt(cur.x) }, [cur.id]) // eslint-disable-line react-hooks/exhaustive-deps
  const dirty = JSON.stringify(d) !== JSON.stringify(msgs)
  return (
    <>
      <Intro>Lo que ustedes pueden cambiar de Sofía sin tocar sus instrucciones de fondo. La información que escriban se suma a esas instrucciones; no las reemplaza.</Intro>
      <div className="sf-tabs top" role="tablist">{['Mensajes', 'Información adicional', 'Reglas e instrucciones', 'Probar', 'Versiones'].map((t) => <button key={t} role="tab" aria-selected={tab === t} className={tab === t ? 'on' : ''} onClick={() => setTab(t)}>{t}</button>)}</div>
      {tab === 'Mensajes' && (
        <div className="sf-g2">
          <Card title="Lo que dice Sofía">
            <div className="sf-form two tight">
              <label className="sf-f">Nombre del asistente<input className="sf-in" value={d.assistant} onChange={(e) => setD({ ...d, assistant: e.target.value })} /></label>
              <label className="sf-f">Nombre del centro<input className="sf-in" value={d.center} onChange={(e) => setD({ ...d, center: e.target.value })} /></label>
            </div>
            <div className="sf-f">Trato<div><Pill k="lock">Usted</Pill> <small>Fijo para atención en salud.</small></div></div>
            {[['greeting', 'Saludo de bienvenida', 'Va antes del aviso de autorización de datos.'], ['busy', 'Cuando la línea está ocupada'], ['transfer', 'Cuando pasa a una persona'], ['bye', 'Despedida']].map(([k, l, sub]) => (
              <label key={k} className="sf-f">{l}<textarea className="sf-in" rows="2" value={d[k]} onChange={(e) => setD({ ...d, [k]: e.target.value })} />{sub && <small>{sub}</small>}</label>
            ))}
            <div className="sf-actions end"><button className="sf-btn pri" disabled={!dirty} onClick={() => { setMsgs(d); s.log('Asistente', 'Editó los mensajes de Sofía', '—', 'Mensajes actualizados'); s.toast('Mensajes guardados: el chat ya los usa') }}>Guardar mensajes</button></div>
          </Card>
          <div className="sf-stack">
            <Card title="Aviso de autorización de datos" right={<Pill k="lock">Bloqueado</Pill>}>
              <p className="sf-quote">«{AVISO}»</p>
              <div className="sf-tags"><Pill k="ok">Versión 2026-10-v5</Pill><Pill k="warn">Borrador: pendiente del abogado</Pill></div>
              <p className="sf-note">Este texto es la prueba de que el paciente autorizó. Para cambiarlo se pide a La Rue, que lo publica como una versión nueva sin afectar las autorizaciones anteriores.</p>
              <button className="sf-btn" onClick={() => s.toast('Solicitud de cambio enviada a La Rue (simulado)')}>Solicitar un cambio</button>
            </Card>
            <Card title="Vista previa">
              <div className="sf-pv"><div className="sf-bub">{d.greeting}</div><div className="sf-bub">Esta conversación queda registrada por escrito… ¿Me autoriza?</div><div className="sf-bub me">Sí, autorizo.</div><div className="sf-bub">Muchas gracias. ¿En qué le puedo ayudar?</div></div>
            </Card>
          </div>
        </div>
      )}
      {tab === 'Información adicional' && (
        <div className="sf-split">
          <Card pad={false} cls="sf-plist"><div className="sf-pl">{info.map((x) => <button key={x.id} className={`sf-pi ${x.id === cur.id ? 'on' : ''}`} onClick={() => setEi(x.id)}><b>{x.t}</b><small>versión {x.v}</small></button>)}</div>
            <form className="sf-cb sf-actions" onSubmit={(e) => { e.preventDefault(); if (!ntitle.trim()) return; const id = Date.now(); setInfo((l) => [...l, { id, t: ntitle.trim(), v: 1, x: '' }]); setEi(id); setNtitle(''); s.log('Información adicional', `Creó «${ntitle.trim()}»`, '—', 'versión 1') }}><input className="sf-in" aria-label="Título nuevo" placeholder="Título de una entrada nueva" value={ntitle} onChange={(e) => setNtitle(e.target.value)} /><button className="sf-btn pri">Agregar</button></form>
          </Card>
          <Card title={cur.t}>
            <label className="sf-f">Lo que Sofía debe saber<textarea className="sf-in" rows="6" value={txt} onChange={(e) => setTxt(e.target.value)} /></label>
            <div className="sf-actions"><button className="sf-btn pri" disabled={txt === cur.x} onClick={() => { setInfo((l) => l.map((x) => (x.id === cur.id ? { ...x, x: txt, v: x.v + 1 } : x))); s.log('Información adicional', `Editó «${cur.t}»`, `versión ${cur.v}`, `versión ${cur.v + 1}`); s.toast('Entrada guardada') }}>Guardar entrada</button></div>
            <p className="sf-note">Se suma a las instrucciones de fondo. Versión actual: {cur.v}.</p>
          </Card>
        </div>
      )}
      {tab === 'Reglas e instrucciones' && (
        <Card title="Reglas de seguridad" right={<Pill k="lock">Solo La Rue</Pill>}>
          <ul className="sf-rules">
            <li>No da diagnósticos ni interpreta resultados de exámenes.</li>
            <li>No recomienda ni suspende medicamentos: remite al médico tratante.</li>
            <li>Ante una urgencia indica llamar al 123 y pasa a una persona.</li>
            <li>Pide autorización de datos antes de guardar nada del paciente.</li>
            <li>No informa precios de lo que no tiene precio cargado.</li>
            <li>Pasa a una persona si el paciente lo pide o si hay molestia reiterada.</li>
          </ul>
          <p className="sf-note">Estas reglas las mantiene La Rue. Si necesita un cambio, solicítelo desde «Solicitar un cambio».</p>
        </Card>
      )}
      {tab === 'Probar' && (
        <Card title="Pruebe a Sofía"><p className="sf-note">Abra el chat de prueba para ver cómo responde con los mensajes, la información adicional, los procedimientos y los horarios que hay hoy.</p><button className="sf-btn pri" onClick={() => s.setView('chat')}>Abrir el chat de prueba</button></Card>
      )}
      {tab === 'Versiones' && (
        <Card title="Versiones del asistente" pad={false}>
          {[['2026-10-v5', 'Borrador', 'Hoy 09:40', 'Marcela Duque'], ['2026-10-v4', 'Publicada', '19 oct 16:10', 'Javier Rueda'], ['2026-09-v3', 'Anterior', '28 sep 11:25', 'Javier Rueda'], ['2026-09-v2', 'Anterior', '9 sep 10:02', 'Javier Rueda']].map(([v, st, w, who]) => <div key={v} className="sf-arow"><div><b>{v}</b><small>{w} · {who}</small></div><Pill k={st === 'Publicada' ? 'ok' : st === 'Borrador' ? 'warn' : ''}>{st}</Pill></div>)}
        </Card>
      )}
    </>
  )
}

function Equipo({ s }) {
  const { users, setUsers } = s
  const [inv, setInv] = useState(null)
  const [f2, setF2] = useState(true)
  const [idle, setIdle] = useState('Después de 30 minutos')
  const count = (r) => users.filter((u) => u.role === r).length
  const roles = [['Maestro (La Rue)', 'Todo el módulo, incluidos los ajustes técnicos del asistente. Lo usa quien da soporte.'], ['Administrador', 'Gestiona datos, procedimientos, horarios, usuarios y gastos. No toca los ajustes técnicos.'], ['Atención al cliente', 'Atiende pacientes y citas. Ve conversaciones; no ve gastos ni exporta datos.'], ['Consulta', 'Mira resúmenes y gastos. No ve conversaciones ni modifica nada.']]
  const M = [['Ver inicio y alertas', '✓', '✓', '✓', '✓'], ['Ver gastos y proyección', '✓', '✓', '—', '✓'], ['Ver el historial de llamadas (sin contenido)', '✓', '✓', '✓', '✓'], ['Leer el contenido de las conversaciones (queda registrado)', 'Parcial', '✓', '✓', '—'], ['Ver pacientes', '✓', '✓', '✓', '—'], ['Crear y editar pacientes', '✓', '✓', 'Parcial', '—'], ['Eliminar o anonimizar pacientes', '✓', '✓', '—', '—'], ['Crear, mover y cancelar citas', '✓', '✓', '✓', '—'], ['Editar procedimientos y precios', '✓', '✓', '—', '—'], ['Editar horarios, festivos y cierres', '✓', '✓', '—', '—'], ['Editar la información adicional de Sofía', '✓', '✓', 'Parcial', '—'], ['Importar datos (CSV)', '✓', '✓', '—', '—'], ['Exportar datos y respaldos', '✓', '✓', '—', '—'], ['Gestionar usuarios y roles', '✓', 'Parcial', '—', '—'], ['Ver la bitácora de cambios', '✓', '✓', '—', '—'], ['Ajustes técnicos (modelo, canales, topes, instrucciones base)', '✓', '—', '—', '—']]
  return (
    <>
      <Intro>Quién entra al módulo y qué puede hacer. Cada persona tiene su propio usuario, así la bitácora dice quién hizo cada cambio.</Intro>
      <Card title="Usuarios" right={<button className="sf-btn pri" onClick={() => setInv({ name: '', email: '', role: 'Atención al cliente' })}><Ic n="plus" /> Invitar persona</button>} pad={false}>
        <div className="sf-scroll"><table className="sf-t"><thead><tr><th>Persona</th><th>Rol</th><th>Último ingreso</th><th>Verificación en 2 pasos</th></tr></thead>
          <tbody>{users.map((u) => (
            <tr key={u.id}><td><span className="sf-who"><span className="sf-av">{initials(u.name)}</span><span><b>{u.name}</b><small className="blk">{u.email}</small></span></span></td>
              <td>{u.id === 1 ? 'Maestro (La Rue)' : <select className="sf-in" aria-label={`Rol de ${u.name}`} value={u.role} onChange={(e) => { setUsers((l) => l.map((x) => (x.id === u.id ? { ...x, role: e.target.value } : x))); s.log('Equipo', `Cambió el rol de ${u.name}`, u.role, e.target.value) }}>{ROLES.slice(1).map((r) => <option key={r}>{r}</option>)}</select>}</td>
              <td>{u.pending ? <>Invitación enviada <Pill k="warn">Pendiente</Pill></> : u.last}</td>
              <td><Pill k={u.f2 ? 'ok' : ''}>{u.f2 ? 'Activa' : 'No activa'}</Pill> {u.id !== 1 && <button className="sf-btn sm" onClick={() => { setUsers((l) => l.map((x) => (x.id === u.id ? { ...x, f2: !x.f2 } : x))); s.log('Equipo', `${u.f2 ? 'Desactivó' : 'Activó'} la verificación en 2 pasos de ${u.name}`, u.f2 ? 'Activa' : 'No activa', u.f2 ? 'No activa' : 'Activa') }}>{u.f2 ? 'Desactivar' : 'Activar'}</button>}</td></tr>
          ))}</tbody></table></div>
      </Card>
      <div className="sf-kpis four">{roles.map(([r, d]) => <div key={r} className="sf-kpi"><span>{r}</span><b>{count(r)} {count(r) === 1 ? 'persona' : 'personas'}</b><small>{d}</small></div>)}</div>
      <Card title="Qué puede hacer cada rol" pad={false}>
        <div className="sf-scroll"><table className="sf-t"><thead><tr><th>Acción</th><th>Maestro</th><th>Administrador</th><th>Atención</th><th>Consulta</th></tr></thead>
          <tbody>{M.map(([a, ...v]) => <tr key={a}><td>{a}</td>{v.map((x, i) => <td key={i} className={x === '✓' ? 'yes' : 'mut'}>{x}</td>)}</tr>)}</tbody></table></div>
        <p className="sf-note pad">«Parcial» en pacientes significa que solo corrige datos de contacto; en información adicional, que agrega entradas pero no cambia los mensajes.</p>
      </Card>
      <Card title="Seguridad de las cuentas">
        <Sw on={f2} set={setF2} label="Pedir verificación en 2 pasos a quien lea conversaciones (Administradores y Atención)" sub="Un código en el celular además de la contraseña." />
        <label className="sf-f">Cerrar la sesión por inactividad<select className="sf-in" value={idle} onChange={(e) => setIdle(e.target.value)}>{['Después de 30 minutos', 'Después de 2 horas', 'Después de 8 horas'].map((x) => <option key={x}>{x}</option>)}</select></label>
        <p className="sf-note">Tras 5 intentos fallidos de contraseña, la cuenta se bloquea 15 minutos y se avisa al administrador.</p>
      </Card>
      {inv && (
        <Modal title="Invitar persona" onClose={() => setInv(null)}>
          <form className="sf-form" onSubmit={(e) => {
            e.preventDefault()
            if (!inv.name.trim() || !inv.email.trim()) return
            setUsers((l) => [...l, { id: Date.now(), name: inv.name.trim(), email: inv.email.trim(), role: inv.role, last: 'Invitación enviada', pending: true, f2: false }])
            s.log('Equipo', `Invitó a ${inv.name.trim()} como ${inv.role}`, '—', 'Pendiente'); s.toast('Invitación enviada'); setInv(null)
          }}>
            <label className="sf-f">Nombre<input className="sf-in" autoFocus value={inv.name} onChange={(e) => setInv({ ...inv, name: e.target.value })} /></label>
            <label className="sf-f">Correo<input className="sf-in" type="email" value={inv.email} onChange={(e) => setInv({ ...inv, email: e.target.value })} /></label>
            <label className="sf-f">Rol<select className="sf-in" value={inv.role} onChange={(e) => setInv({ ...inv, role: e.target.value })}>{ROLES.slice(1).map((r) => <option key={r}>{r}</option>)}</select></label>
            <div className="sf-actions"><button className="sf-btn pri">Enviar invitación</button><button type="button" className="sf-btn" onClick={() => setInv(null)}>Cancelar</button></div>
          </form>
        </Modal>
      )}
    </>
  )
}

function Datos({ s }) {
  const [reqs, setReqs] = useState([
    { id: 'S-12', type: 'Consulta', who: 'P-1008', ch: 'WhatsApp · Titular', at: 'mar 20 oct', due: 'mié 4 nov', days: '7 días hábiles', done: false },
    { id: 'S-11', type: 'Rectificación', who: 'P-1022', ch: 'Presencial · Titular', at: 'vie 16 oct', due: 'lun 9 nov', days: '10 días hábiles', done: false },
    { id: 'S-10', type: 'Supresión', who: 'P-0987', ch: 'Correo · Titular', at: 'vie 2 oct', due: '—', days: '', done: true },
  ])
  const [nr, setNr] = useState(null)
  const [ret, setRet] = useState({ conv: '90 días (propuesta)', adres: '30 días (propuesta)', cb: '48 horas' })
  const [blocked, setBlocked] = useState([{ n: '••••••0142', why: 'Pidió no recibir mensajes', since: 'dom 18 oct', by: 'Laura Pérez' }, { n: '••••••0198', why: 'Revocó la autorización', since: 'dom 11 oct', by: 'Marcela Duque' }])
  const [num, setNum] = useState('')
  const sets = [['Pacientes', s.patients.length, true, () => csv([['Código', 'Nombre', 'EPS'], ...s.patients.map((p) => [p.id, p.name, p.eps])])], ['Procedimientos', s.procs.length, true, () => csv([['Nombre', 'Precio'], ...s.procs.map((p) => [p.name, p.price])])], ['Citas', s.appts.length, false, () => csv([['Fecha', 'Hora', 'Paciente', 'Estado'], ...s.appts.map((a) => [dlabel(a.date), hm(a.t), a.name, a.status])])], ['Horarios y cierres', 6 + s.closures.length, false, () => csv([['Fecha', 'Motivo'], ...s.closures.map((c) => [dlabel(c.date), c.reason])])], ['Información adicional', s.info.length, false, () => csv([['Título', 'Versión'], ...s.info.map((i) => [i.t, i.v])])], ['Conversaciones', 393 + s.chatsNew, false, () => csv([['Fecha', 'Canal', 'Resultado'], ...s.convs.map((c) => [dlabel(c.d), c.ch, c.out])])]]
  const prov = [['La Rue Developer', 'Desarrollo y soporte del servicio', 'Colombia', '—'], ['Railway', 'Servidor y almacenamiento', 'EE. UU. (California)', 'Hasta que se borre'], ['Telnyx', 'Telefonía', 'EE. UU.', 'Sin grabación de audio'], ['Soniox', 'Voz a texto', 'EE. UU.', 'Sin archivos guardados'], ['Microsoft Azure', 'Texto a voz', 'EE. UU.', 'Por confirmar'], ['Anthropic', 'Inteligencia artificial', 'EE. UU.', 'Por confirmar'], ['Meta (WhatsApp)', 'Canal de WhatsApp', 'EE. UU.', 'Según Meta'], ['Croma', 'Consulta de afiliación (ADRES)', 'EE. UU. (AWS)', 'Solo datos de la consulta, no el documento'], ['GitHub', 'Respaldos cifrados', 'EE. UU.', '30 días']]
  const Radio = ({ k, opts }) => <div className="sf-radio">{opts.map((o) => <button key={o} role="radio" aria-checked={ret[k] === o} className={ret[k] === o ? 'on' : ''} onClick={() => { setRet({ ...ret, [k]: o }); s.log('Datos', 'Cambió un plazo de retención', ret[k], o); }}>{o}</button>)}</div>
  return (
    <>
      <Intro>Cargar datos que ya tienen, bajar lo que hay en Sofía y atender a los pacientes que piden ver, corregir o borrar sus datos.</Intro>
      <Card title="Importar y exportar" pad={false}>
        <div className="sf-scroll"><table className="sf-t"><thead><tr><th>Información</th><th className="r">Registros</th><th>Importar</th><th>Exportar</th></tr></thead>
          <tbody>{sets.map(([n, c, imp, gen]) => (
            <tr key={n}><td><b>{n}</b></td><td className="r">{c}</td><td>{imp ? <><button className="sf-btn sm" onClick={() => s.toast('Importar: en esta demo no se carga ningún archivo')}>Importar desde Excel</button> <button className="sf-link" onClick={() => s.toast('Plantilla descargada (simulado)')}>Plantilla</button></> : <Pill>Próximamente</Pill>}</td>
              <td><button className="sf-btn sm" onClick={() => dl(`${n.toLowerCase().replace(/ /g, '-')}.csv`, gen())}>CSV</button> <button className="sf-btn sm" onClick={() => dl(`${n.toLowerCase().replace(/ /g, '-')}.json`, JSON.stringify(gen().split('\n').slice(1)), 'application/json')}>JSON</button></td></tr>
          ))}</tbody></table></div>
      </Card>
      <div className="sf-g2">
        <Card title="Historial de importaciones"><div className="sf-topic"><b>Pacientes · pacientes-sede-norte.csv</b><small>22 oct 15:30 · Javier Rueda · 38 nuevos, 2 actualizados, 1 con error</small></div></Card>
        <Card title="Respaldo">
          <div className="sf-topic"><b>Respaldo diario cifrado <Pill k="ok">Al día</Pill></b><small>Todos los días a las 3:15 a. m. · se guardan 30 días</small><small>Último: hoy 3:15 a. m. · 4,2 MB</small></div>
          <button className="sf-btn" onClick={() => { s.log('Datos', 'Descargó un respaldo', '—', 'respaldo-cifrado.json'); dl('respaldo-demo.json', JSON.stringify({ centro: CENTER, nota: 'Datos de ejemplo' }), 'application/json'); s.toast('Respaldo descargado') }}><Ic n="down" /> Descargar respaldo ahora</button>
        </Card>
      </div>
      <Card title="Quién trata los datos por cuenta de IPS Sendero Vital" pad={false}>
        <p className="sf-note pad">Cada proveedor necesita un contrato de transmisión de datos con IPS Sendero Vital. Hoy están pendientes.</p>
        <div className="sf-scroll"><table className="sf-t"><thead><tr><th>Proveedor</th><th>Para qué</th><th>País</th><th>Contrato</th><th>Retención declarada</th></tr></thead>
          <tbody>{prov.map(([a, b, c, d]) => <tr key={a}><td><b>{a}</b></td><td>{b}</td><td>{c}</td><td><Pill k="warn">Pendiente</Pill></td><td>{d}</td></tr>)}</tbody></table></div>
      </Card>
      <Card title="Solicitudes de pacientes sobre sus datos" right={<button className="sf-btn pri" onClick={() => setNr({ type: 'Consulta', who: '', ch: 'WhatsApp · Titular' })}>Registrar solicitud</button>} pad={false}>
        <p className="sf-note pad">Las consultas se responden en 10 días hábiles y los reclamos en 15 (el abogado confirma si hay prórroga). La consulta es gratuita.</p>
        <div className="sf-scroll"><table className="sf-t"><thead><tr><th>Solicitud</th><th>Tipo</th><th>Paciente y canal</th><th>Recibida</th><th>Plazo</th><th>Estado</th><th /></tr></thead>
          <tbody>{reqs.map((r) => <tr key={r.id}><td><b>{r.id}</b></td><td>{r.type}</td><td>{r.who}<small className="blk">{r.ch}</small></td><td>{r.at}</td><td>{r.due}<small className="blk">{r.days}</small></td><td><Pill k={r.done ? 'ok' : 'warn'}>{r.done ? 'Cumplida' : 'En trámite'}</Pill></td><td>{!r.done && <button className="sf-btn sm" onClick={() => { setReqs((l) => l.map((x) => (x.id === r.id ? { ...x, done: true, due: '—', days: '' } : x))); s.log('Datos', `Marcó cumplida la solicitud ${r.id}`, 'En trámite', 'Cumplida') }}>Marcar cumplida</button>}</td></tr>)}</tbody></table></div>
      </Card>
      <Card title="Cuánto tiempo se guardan los datos">
        <p className="sf-note">Esto lo define IPS Sendero Vital con su abogado; aquí se deja configurado.</p>
        <div className="sf-lab">Conversaciones por escrito</div><Radio k="conv" opts={['90 días (propuesta)', '6 meses', '1 año']} />
        <div className="sf-lab">Consultas de afiliación (ADRES)</div><Radio k="adres" opts={['30 días (propuesta)', '6 meses']} />
        <div className="sf-lab">Lista de devoluciones de llamada</div><Radio k="cb" opts={['48 horas', '7 días']} />
        <p className="sf-note">Son plazos propuestos mientras IPS Sendero Vital los define con su abogado. Pasado el plazo, queda solo la fecha, el canal y el resultado de cada conversación. Si hay una solicitud o reclamo abierto de una persona, sus datos no se borran.</p>
      </Card>
      <Card title="Números sin contacto automático" right={<form className="sf-inline" onSubmit={(e) => { e.preventDefault(); if (!num.trim()) return; setBlocked((l) => [...l, { n: `••••••${num.trim().slice(-4)}`, why: 'Pidió no recibir mensajes', since: dlabel(TODAY), by: WHO[s.role] }]); s.log('Datos', 'Agregó un número sin contacto automático', '—', `••••••${num.trim().slice(-4)}`); setNum('') }}><input className="sf-in" aria-label="Número a bloquear" inputMode="tel" placeholder="Celular" value={num} onChange={(e) => setNum(e.target.value)} /><button className="sf-btn">Agregar número</button></form>} pad={false}>
        <p className="sf-note pad">Sofía no les envía recordatorios, encuestas ni devoluciones de llamada. Si ellos escriben o llaman, los atiende normal.</p>
        <table className="sf-t"><thead><tr><th>Número</th><th>Motivo</th><th>Desde</th><th>Lo anotó</th><th /></tr></thead>
          <tbody>{blocked.map((b, i) => <tr key={i}><td>{b.n}</td><td>{b.why}</td><td>{b.since}</td><td>{b.by}</td><td><button className="sf-btn sm" onClick={() => { setBlocked((l) => l.filter((_, j) => j !== i)); s.log('Datos', 'Quitó un número sin contacto automático', b.n, '—') }}>Quitar</button></td></tr>)}</tbody></table>
      </Card>
      {nr && (
        <Modal title="Registrar solicitud" onClose={() => setNr(null)}>
          <form className="sf-form" onSubmit={(e) => {
            e.preventDefault()
            if (!nr.who.trim()) return
            const id = `S-${13 + reqs.length - 3}`
            setReqs((l) => [{ id, type: nr.type, who: nr.who.trim(), ch: nr.ch, at: dlabel(TODAY), due: 'mié 11 nov', days: '10 días hábiles', done: false }, ...l])
            s.log('Datos', `Registró la solicitud ${id}`, '—', nr.type); s.toast('Solicitud registrada'); setNr(null)
          }}>
            <label className="sf-f">Tipo<select className="sf-in" value={nr.type} onChange={(e) => setNr({ ...nr, type: e.target.value })}>{['Consulta', 'Rectificación', 'Supresión', 'Revocatoria'].map((t) => <option key={t}>{t}</option>)}</select></label>
            <label className="sf-f">Código del paciente<input className="sf-in" autoFocus placeholder="P-1001" value={nr.who} onChange={(e) => setNr({ ...nr, who: e.target.value })} /></label>
            <label className="sf-f">Canal<select className="sf-in" value={nr.ch} onChange={(e) => setNr({ ...nr, ch: e.target.value })}>{['WhatsApp · Titular', 'Llamada · Titular', 'Presencial · Titular', 'Correo · Titular'].map((t) => <option key={t}>{t}</option>)}</select></label>
            <div className="sf-actions"><button className="sf-btn pri">Registrar</button><button type="button" className="sf-btn" onClick={() => setNr(null)}>Cancelar</button></div>
          </form>
        </Modal>
      )}
    </>
  )
}

function Auditoria({ s }) {
  const [mod, setMod] = useState('')
  const [page, setPage] = useState(0)
  const list = s.audit.filter((a) => !mod || a.mod === mod)
  return (
    <>
      <Intro>Quién cambió qué y cuándo. Estas anotaciones no se pueden editar ni borrar.</Intro>
      <div className="sf-filters">
        <select className="sf-in" aria-label="Módulo" value={mod} onChange={(e) => { setMod(e.target.value); setPage(0) }}><option value="">Todos los módulos</option>{['Ajustes', 'Procedimientos', 'Horarios', 'Pacientes', 'Información adicional', 'Asistente', 'Datos', 'Equipo'].map((m) => <option key={m}>{m}</option>)}</select>
        <span className="sp" />
        <button className="sf-btn" onClick={() => dl('bitacora.csv', csv([['Cuándo', 'Quién', 'Módulo', 'Qué hizo', 'Antes', 'Después'], ...list.map((a) => [a.when, a.who, a.mod, a.what, a.before, a.after])]))}><Ic n="down" /> Exportar</button>
      </div>
      <Card pad={false}>
        <div className="sf-scroll"><table className="sf-t"><thead><tr><th>Cuándo</th><th>Quién</th><th>Módulo</th><th>Qué hizo</th><th>Antes</th><th>Después</th></tr></thead>
          <tbody>{list.slice(page * 8, page * 8 + 8).map((a) => <tr key={a.id}><td>{a.when}</td><td>{a.who}</td><td>{a.mod}</td><td>{a.what}</td><td>{a.before}</td><td>{a.after}</td></tr>)}</tbody></table></div>
        <Pager page={page} setPage={setPage} total={list.length} size={8} />
      </Card>
    </>
  )
}

function Ajustes({ s }) {
  const [warn80, setWarn80] = useState(true)
  const [cap, setCap] = useState(String(s.cap))
  const [ch, setCh] = useState({ voz: true, wa: true, resp: true })
  const per3 = (t) => 0.036 * 3 * TIERS[t].m + 0.064
  return (
    <>
      <Intro>Aquí están el nivel de inteligencia, los topes y las conexiones. Solo el soporte de La Rue los cambia.</Intro>
      <Card title="Nivel de inteligencia">
        <div className="sf-tiers" role="radiogroup" aria-label="Nivel de inteligencia">
          {Object.entries(TIERS).map(([k, v]) => (
            <button key={k} role="radio" aria-checked={s.tier === k} className={`sf-tier ${s.tier === k ? 'on' : ''}`} onClick={() => { if (k === s.tier) return; s.log('Ajustes', 'Cambió el nivel de inteligencia', TIERS[s.tier].label, v.label); s.setTier(k); s.toast(`Nivel ${v.label}: el gasto se recalcula`) }}>
              <b>{v.label}</b><span>{v.note}</span><small>Llamada de 3 min ≈ {usd(per3(k), 3)}</small>
            </button>
          ))}
        </div>
        <p className="sf-note">Gasto estimado de octubre con este nivel: <b>{cop(s.cost.monthUsd * USD)}</b> ({usd(s.cost.monthUsd)}).</p>
      </Card>
      <div className="sf-g2">
        <Card title="Topes de gasto">
          <label className="sf-f">Tope diario (US$)<input className="sf-in" inputMode="decimal" aria-label="Tope diario" value={cap} onChange={(e) => setCap(e.target.value)} /></label>
          <Sw on={warn80} set={(v) => { setWarn80(v); s.log('Ajustes', v ? 'Activó el aviso de gasto al 80 %' : 'Apagó el aviso de gasto al 80 %', v ? 'Desactivado' : 'Activado', v ? 'Activado' : 'Desactivado') }} label="Avisar al llegar al 80 % del tope" />
          <div className="sf-actions"><button className="sf-btn pri" disabled={Number(cap.replace(',', '.')) === s.cap || !(Number(cap.replace(',', '.')) > 0)} onClick={() => { const n = Number(cap.replace(',', '.')); s.log('Ajustes', 'Cambió el tope diario de gasto', usd(s.cap), usd(n)); s.setCap(n); s.toast('Tope guardado') }}>Guardar tope</button></div>
        </Card>
        <Card title="Conexiones">
          <Sw on={ch.voz} set={(v) => setCh({ ...ch, voz: v })} label="Llamadas" sub="Línea activa, 1 llamada a la vez" />
          <Sw on={ch.wa} set={(v) => setCh({ ...ch, wa: v })} label="WhatsApp" sub="Número verificado" />
          <Sw on={ch.resp} set={(v) => setCh({ ...ch, resp: v })} label="Respaldo diario" sub="3:15 a. m., cifrado" />
        </Card>
      </div>
    </>
  )
}

const Locked = ({ s, id }) => (
  <Card cls="sf-locked">
    <span className="sf-lockic"><Ic n="lock" /></span>
    {id === 'ajustes' ? (
      <><h2>Esta sección es del soporte de La Rue.</h2><p>Aquí están el nivel de inteligencia, los topes y las conexiones. Si necesita un cambio, avíseles y lo hacen con usted.</p><button className="sf-btn" onClick={() => s.toast('Aviso enviado a La Rue (simulado)')}>Avisar a La Rue</button></>
    ) : (
      <><h2>Su rol no tiene acceso a esta sección.</h2><p>Con el rol «{s.role}» no se muestra «{TITLES[id]}». Cambie «Ver como» para ver qué ve cada rol.</p></>
    )}
  </Card>
)

const VIEWS = { inicio: Inicio, gastos: Gastos, llamadas: Llamadas, opinion: Opinion, pregunte: Pregunte, pacientes: Pacientes, citas: Citas, procedimientos: Procedimientos, horarios: Horarios, asistente: Asistente, equipo: Equipo, datos: Datos, auditoria: Auditoria, ajustes: Ajustes }

// ---------- raíz ----------
export default function Sofia() {
  const [view, setView] = useState('admin')
  const [page, setPage] = useState('inicio')
  const [dark, setDark] = useState(false)
  const [role, setRole] = useState(ROLES[0])
  const [drawer, setDrawer] = useState(false)
  const [banner, setBanner] = useState(true)
  const [tier, setTier] = useState('medio')
  const [cap, setCap] = useState(10)
  const [appts, setAppts] = useState(SEED_APPTS)
  const [procs, setProcs] = useState(PROCS0)
  const [patients, setPatients] = useState(mkPatients)
  const [convs, setConvs] = useState(() => mkConvs(patients0()))
  const [hours, setHours] = useState({ on: true, days: [1, 1, 1, 1, 1, 1, 0], open: '07:00', close: '17:00', msg: `Nuestro horario de atención es de lunes a sábado, de 7:00 a. m. a 5:00 p. m. Con gusto le devolvemos la llamada cuando abramos.`, callback: true, wa: true })
  const [closures, setClosures] = useState([{ id: 1, date: 31, reason: 'Jornada de capacitación', all: true }, { id: 2, date: 12, reason: 'Festivo: Día de la Raza', all: true }])
  const [msgs, setMsgs] = useState({ assistant: 'Sofía', center: CENTER, greeting: `Hola, gracias por comunicarse con ${CENTER}. Le habla Sofía, la asistente virtual.`, busy: 'En este momento estamos atendiendo otra llamada. Le devolvemos la llamada en cuanto la línea quede libre.', transfer: 'Entiendo. Le comunico con una persona de nuestro equipo.', bye: 'Con gusto. Que tenga un buen día.' })
  const [info, setInfo] = useState(INFO0)
  const [users, setUsers] = useState(USERS0)
  const [audit, setAudit] = useState(AUDIT0)
  const [week, setWeek] = useState(19)
  const [procSel, setProcSel] = useState('eco')
  const [callsPre, setCallsPre] = useState(null)
  const [toastMsg, setToastMsg] = useState('')
  const [turns, setTurns] = useState(0)
  const [booked, setBooked] = useState(0)
  const [handoffs, setHandoffs] = useState(0)
  const [chatsNew, setChatsNew] = useState(0)
  const [palette, setPalette] = useState(false)
  const [bell, setBell] = useState(false)
  const [unread, setUnread] = useState(4)
  const [nu, setNu] = useState(null)
  const [pq, setPq] = useState('')
  const t0 = useRef(Date.now())
  const tm = useRef(null)
  const convIds = useRef(new Set())
  const rootRef = useRef(null)
  const [compact, setCompact] = useState(false)
  useEffect(() => {
    const el = rootRef.current
    if (!el) return undefined
    const fit = () => setCompact(el.clientWidth < 760)
    fit()
    const ro = new ResizeObserver(fit)
    ro.observe(el)
    return () => ro.disconnect()
  }, [])

  const toast = (t) => { setToastMsg(t); clearTimeout(tm.current); tm.current = setTimeout(() => setToastMsg(''), 3200) }
  useEffect(() => () => clearTimeout(tm.current), [])
  const clock = () => { const t = NOW + Math.floor((Date.now() - t0.current) / 60000); return `Hoy ${String(Math.floor(t / 60)).padStart(2, '0')}:${String(t % 60).padStart(2, '0')}` }
  const log = (mod, what, before = '—', after = '—') => setAudit((l) => [{ id: Date.now() + Math.random(), when: clock(), who: WHO[role], mod, what, before, after }, ...l])
  const go = (p) => { setPage(p); setDrawer(false); setBell(false) }
  const isOpen = () => hours.on ? !!hours.days[dow(TODAY)] && NOW >= toMin(hours.open) && NOW < toMin(hours.close) : true

  const freeSlots = useMemo(() => (date, p) => {
    if (date < TODAY) return []
    if (!hours.days[dow(date)] || closures.some((c) => c.date === date && c.all)) return []
    const o = toMin(hours.open), c = toMin(hours.close)
    const out = []
    for (let t = o; t + p.dur <= c; t += 20) {
      if (date === TODAY && t <= NOW) continue
      const clash = appts.some((a) => a.status !== 'cancel' && a.date === date && procs.find((x) => x.id === a.proc)?.team === p.team && a.t < t + p.dur && t < a.t + a.dur)
      if (!clash) out.push(t)
    }
    return out
  }, [appts, procs, hours, closures])
  const addAppt = (a) => { setAppts((l) => [...l, { ...a, id: Date.now() + Math.random() }]); setBooked((n) => n + 1) }
  const cancelAppt = (id) => setAppts((l) => l.map((a) => (a.id === id ? { ...a, status: 'cancel' } : a)))
  const upsertConv = (c) => {
    if (!convIds.current.has(c.id)) { convIds.current.add(c.id); setChatsNew((n) => n + 1) }
    setConvs((l) => {
      const row = { id: c.id, d: TODAY, t: NOW, ch: 'WhatsApp', name: c.name, tel: '***0000', min: 0, msgs: c.msgs, out: c.out }
      return l.some((x) => x.id === c.id) ? l.map((x) => (x.id === c.id ? { ...x, ...row, t: x.t } : x)) : [row, ...l]
    })
  }

  // gasto con el nivel de IA elegido
  const m = TIERS[tier].m
  const daily = useMemo(() => {
    const r = rng(5)
    const w = Array.from({ length: 30 }, (_, i) => (dow(-5 + i) === 6 ? 0.05 : 0.5 + r()))
    const sum = w.reduce((a, b) => a + b, 0)
    return w.map((x, i) => {
      const f = x / sum
      const parts = [20.51 * m * f, 5.46 * f, 0.81 * f, 2.22 * f]
      return { label: `día ${i + 1}`, parts, total: parts.reduce((a, b) => a + b, 0) }
    })
  }, [m])
  const cost = useMemo(() => {
    const ia = 15.61 * m + turns * 0.004 * m
    return { ia, monthUsd: ia + 4.06 + 0.6 + 1.66 }
  }, [m, turns])

  const s = { view, setView, page, go, role, tier, setTier, cap, setCap, appts, setAppts, procs, setProcs, patients, setPatients, convs, hours, setHours, closures, setClosures, msgs, setMsgs, info, setInfo, users, setUsers, audit, week, setWeek, procSel, setProcSel, callsPre, setCallsPre, toast, log, freeSlots, addAppt, cancelAppt, upsertConv, cost, daily, turns, booked, handoffs, chatsNew, isOpen, bumpTurn: () => setTurns((n) => n + 1), onHandoff: () => setHandoffs((n) => n + 1) }

  // Ctrl K abre el buscador
  useEffect(() => {
    const on = (e) => { if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') { e.preventDefault(); setPalette(true) } if (e.key === 'Escape') { setPalette(false); setBell(false) } }
    window.addEventListener('keydown', on)
    return () => window.removeEventListener('keydown', on)
  }, [])

  const denied = DENY[role].includes(page)
  const View = VIEWS[page]
  const bellItems = ['11 conversaciones pasaron a una persona esta semana', '3 devoluciones de llamada pendientes', 'Aún no se consulta la EPS en ADRES', 'Cierre programado el 31 oct: hay citas por reprogramar']
  const canNew = role !== 'Consulta' && !DENY[role].includes('citas')
  const newModal = nu && (
    <Modal title="Nueva cita" onClose={() => setNu(null)}>
      <NewAppt s={s} onClose={() => setNu(null)} />
    </Modal>
  )
  const results = NAV.flatMap(([, it]) => it).filter(([, l]) => l.toLowerCase().includes(pq.toLowerCase()))

  return (
    <div className={`sf ${dark ? 'dark' : ''}`} ref={rootRef}>
      <div className="sf-switch">
        <span className="sf-seg">{[['chat', 'Chat con la paciente'], ['admin', 'Panel de administración']].map(([id, l]) => <button key={id} className={view === id ? 'on' : ''} onClick={() => setView(id)}>{l}</button>)}</span>
        <span className="sp" />
        <span className="sf-demo">Datos de ejemplo · {CENTER}</span>
      </div>
      <div className="sf-chatslot" hidden={view !== 'chat'}><Chat s={s} /></div>
      {view === 'chat' ? null : (
        <div className="sf-admin">
          {drawer && <div className="sf-scrim" onClick={() => setDrawer(false)} />}
          <aside className={`sf-side ${drawer ? 'open' : ''}`} aria-label="Navegación">
            <div className="sf-brand"><span className="sf-logo">S</span><div><b>Sofía</b><small>{CENTER}</small></div></div>
            <nav>
              {NAV.map(([g, items]) => (
                <div key={g}><div className="sf-gl">{g}</div>
                  {items.map(([id, l, ic]) => <button key={id} className={`sf-item ${page === id ? 'on' : ''} ${DENY[role].includes(id) ? 'dim' : ''}`} aria-current={page === id ? 'page' : undefined} onClick={() => go(id)}><Ic n={ic} /><span>{l}</span>{DENY[role].includes(id) && <Ic n="lock" />}</button>)}
                </div>
              ))}
            </nav>
            {compact && <label className="sf-as in"><span>Ver como</span><select aria-label="Ver como" value={role} onChange={(e) => setRole(e.target.value)}>{ROLES.map((r) => <option key={r}>{r}</option>)}</select></label>}
            <button className="sf-help" onClick={() => toast('Soporte: escribanos por WhatsApp (simulado)')}>¿Necesita ayuda?</button>
            <p className="sf-sfoot">Responsable de los datos: {CENTER}<br /><u>Política de privacidad</u><br />Maqueta · datos de ejemplo</p>
          </aside>
          <div className="sf-main">
            <header className="sf-top">
              <button className="sf-btn sf-burger" aria-label="Abrir el menú" onClick={() => setDrawer(true)}><Ic n="menu" /></button>
              <h1>{TITLES[page]}</h1>
              <span className="sp" />
              <button className="sf-btn sf-searchb" aria-label="Buscar" onClick={() => { setPq(''); setPalette(true) }}><Ic n="search" /><span>Buscar</span><kbd>Ctrl K</kbd></button>
              <span className="sf-bellw"><button className="sf-btn sf-bell" aria-label="Notificaciones" onClick={() => setBell(!bell)}><Ic n="bell" />{unread > 0 && <i>{unread}</i>}</button>
                {bell && <div className="sf-pop" role="menu"><b>Notificaciones</b>{bellItems.map((t) => <p key={t}>{t}</p>)}<button className="sf-btn sm" onClick={() => { setUnread(0); setBell(false) }}>Marcar como leídas</button></div>}
              </span>
              {canNew && <button className="sf-btn pri sf-new" aria-label="Nueva cita" onClick={() => setNu(true)}><Ic n="plus" /><span>Nueva cita</span></button>}
              <button className="sf-btn" aria-label="Modo oscuro del panel" onClick={() => setDark(!dark)}><Ic n="moon" /></button>
              {!compact && <label className="sf-as"><span>Ver como</span><select aria-label="Ver como" value={role} onChange={(e) => setRole(e.target.value)}>{ROLES.map((r) => <option key={r}>{r}</option>)}</select></label>}
            </header>
            {banner && <div className="sf-banner"><span>Maqueta con datos de ejemplo: lo que cambie no se conserva al recargar. Use «Ver como» para ver qué ve cada rol.</span><button className="sf-btn sm ghost" onClick={() => setBanner(false)}>Ocultar</button></div>}
            <main className="sf-cont" key={page}>
              {denied ? <Locked s={s} id={page} /> : <View s={s} />}
            </main>
          </div>
          {newModal}
          {palette && (
            <div className="sf-mod top" onClick={() => setPalette(false)}>
              <div role="dialog" aria-label="Buscar" onClick={(e) => e.stopPropagation()}>
                <input className="sf-in" autoFocus aria-label="Buscar en el panel" placeholder="Buscar una sección…" value={pq} onChange={(e) => setPq(e.target.value)} onKeyDown={(e) => { if (e.key === 'Enter' && results[0]) { go(results[0][0]); setPalette(false) } }} />
                {results.map(([id, l, ic]) => <button key={id} className="sf-item" onClick={() => { go(id); setPalette(false) }}><Ic n={ic} /><span>{l}</span></button>)}
              </div>
            </div>
          )}
        </div>
      )}
      {toastMsg && <div className="sf-toast" role="status">{toastMsg}</div>}
    </div>
  )
}

function patients0() { return mkPatients() }

function NewAppt({ s, onClose }) {
  const offered = s.procs.filter((p) => p.on)
  const [f, setF] = useState({ name: '', proc: offered[0].id, date: 26, t: '' })
  const p = s.procs.find((x) => x.id === f.proc)
  const slots = s.freeSlots(+f.date, p)
  const t = f.t !== '' && slots.includes(+f.t) ? +f.t : slots[0]
  return (
    <form className="sf-form" onSubmit={(e) => {
      e.preventDefault()
      if (!f.name.trim() || t == null) return
      s.setAppts((l) => [...l, { id: Date.now(), date: +f.date, t, name: f.name.trim(), proc: p.id, status: 'prog', src: 'Panel', dur: p.dur }])
      s.toast(`Cita agendada: ${dlabel(+f.date)} ${hm(t)}`)
      s.setWeek(+f.date >= 26 ? 26 : 19); s.go('citas'); onClose()
    }}>
      <label className="sf-f">Paciente<input className="sf-in" autoFocus list="sf-pacs" value={f.name} onChange={(e) => setF({ ...f, name: e.target.value })} placeholder="Nombre completo" /></label>
      <datalist id="sf-pacs">{s.patients.slice(0, 12).map((x) => <option key={x.id} value={x.name} />)}</datalist>
      <label className="sf-f">Examen<select className="sf-in" value={f.proc} onChange={(e) => setF({ ...f, proc: e.target.value, t: '' })}>{offered.map((x) => <option key={x.id} value={x.id}>{x.name}</option>)}</select></label>
      <div className="sf-form two tight">
        <label className="sf-f">Día<select className="sf-in" value={f.date} onChange={(e) => setF({ ...f, date: e.target.value, t: '' })}>{[24, 26, 27, 28, 29, 30].map((d) => <option key={d} value={d}>{dlabel(d)}</option>)}</select></label>
        <label className="sf-f">Hora<select className="sf-in" value={t ?? ''} onChange={(e) => setF({ ...f, t: e.target.value })} disabled={!slots.length}>{slots.map((x) => <option key={x} value={x}>{hm(x)}</option>)}</select></label>
      </div>
      {!slots.length && <small className="sf-note">No hay cupos ese día para {p.team}. Pruebe otro día.</small>}
      <div className="sf-actions"><button className="sf-btn pri" disabled={!slots.length}>Guardar cita</button><button type="button" className="sf-btn" onClick={onClose}>Cancelar</button></div>
    </form>
  )
}
