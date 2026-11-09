import { useEffect, useMemo, useRef, useState } from 'react'
import './backline.css'

// "Cuerda Floja", sus canciones, letras, eventos y salas son inventados. La interfaz sigue la app real.
const P = {
  home: 'M3 11l9-8 9 8M5 10v10h5v-6h4v6h5V10',
  music: 'M9 18V5l11-2v13M9 18a3 3 0 11-6 0 3 3 0 016 0zm11-2a3 3 0 11-6 0 3 3 0 016 0z',
  cal: 'M4 6h16v14H4zM4 10h16M8 3v4M16 3v4',
  grad: 'M2 9l10-5 10 5-10 5L2 9zm4 3v5c0 1 3 2.5 6 2.5s6-1.5 6-2.5v-5',
  compass: 'M12 3a9 9 0 100 18 9 9 0 000-18zm3.5 5.5l-2 5-5 2 2-5 5-2z',
  users: 'M9 11a3.5 3.5 0 100-7 3.5 3.5 0 000 7zM2 20c0-3.5 3-6 7-6s7 2.5 7 6M16 4.5a3.5 3.5 0 010 6.5M18 14.5c2.5.6 4 2.6 4 5.5',
  plus: 'M12 5v14M5 12h14', up: 'M12 15V4m-4 4l4-4 4 4M5 14v5h14v-5', search: 'M11 4a7 7 0 100 14 7 7 0 000-14zm9 16l-4-4',
  back: 'M19 12H5m6-6l-6 6 6 6', tag: 'M3 12V4h8l10 10-8 8L3 12zm5-4h.01', x: 'M6 6l12 12M18 6L6 18', reload: 'M20 12a8 8 0 11-2.6-5.9M20 4v5h-5',
  sun: 'M12 8a4 4 0 100 8 4 4 0 000-8zM12 2v2M12 20v2M2 12h2M20 12h2M5 5l1.5 1.5M17.5 17.5L19 19M5 19l1.5-1.5M17.5 6.5L19 5',
  chev: 'M6 9l6 6 6-6', left: 'M15 6l-6 6 6 6', right: 'M9 6l6 6-6 6', play: 'M7 4l13 8-13 8z', pause: 'M8 4v16M16 4v16', grip: 'M9 5h.01M15 5h.01M9 12h.01M15 12h.01M9 19h.01M15 19h.01',
  clock: 'M12 3a9 9 0 100 18 9 9 0 000-18zm0 5v5l3 2', door: 'M5 21V4h10v17M3 21h18M12 12h.01', store: 'M4 9l1-5h14l1 5M4 9v11h16V9M4 9c0 2 3 2 4 0 1 2 4 2 4 0 1 2 4 2 4 0 1 2 4 2 4 0',
  note: 'M5 4h14v16H5zM9 9h6M9 13h6',
}
const Ico = ({ n }) => <svg viewBox="0 0 24 24" className="bk-ico" aria-hidden="true"><path d={P[n]} /></svg>

const ME = 'm1'
const MEMBERS = [
  { id: 'm1', name: 'Andrea Rivas', ini: 'AR', inst: 'Guitarra' }, { id: 'm2', name: 'Tomás Guerra', ini: 'TG', inst: 'Voz' },
  { id: 'm3', name: 'Lina Marín', ini: 'LM', inst: 'Bajo' }, { id: 'm4', name: 'Sebas Duarte', ini: 'SD', inst: 'Batería' },
]
const ROLES = ['Guitarra', 'Bajo', 'Batería', 'Voz', 'Teclado / piano', 'Percusión', 'Vientos', 'Cuerdas', 'DJ / producción', 'Todo']

const SONGS0 = [
  { id: 's1', title: 'Humo en la Terraza', artist: 'Mareas del Sur', key: 'Em', bpm: 124, min: 4, status: 'lista', tuning: 'E estándar', notes: { Bajo: 'Raíz en corcheas, sin adornos hasta el coro.', Batería: 'Entra con hi-hat cerrado, abre en el coro.' },
    chart: [['Verso', ['[Em]Humo en la terraza, [C]nadie quiere irse', '[G]una luz de neón [D]dice que es temprano']], ['Coro', ['[Em]Quédate un rato más, [C]quédate un rato más', '[G]que el reloj [D]se quedó sin voz']]] },
  { id: 's2', title: 'Mapa de Sal', artist: 'Los Pájaros Mudos', key: 'Dm', bpm: 82, min: 4, status: 'lista', tuning: 'E estándar', notes: { Guitarra: 'Arpegio suave en el verso, rasgueo abierto en el coro.' },
    chart: [['Verso', ['[Dm]Dibujé en tu espalda [Bb]un mapa de sal', '[F]cada lunar [C]era un lugar']], ['Coro', ['[Dm]Llévame al norte [Bb]sin decir adónde', '[F]yo pongo el viaje, [C]tú pones el mar']]] },
  { id: 's3', title: 'Carretera Vacía', artist: 'Radio Cobre', key: 'B', bpm: 104, min: 5, status: 'lista', tuning: 'Drop D', change: 'B → D en puente', notes: { Guitarra: 'Afina la sexta a D antes de empezar.' },
    chart: [['Verso', ['[B]La carretera vacía [F#]no tiene dueño', '[G#m]y mi motor [E]canta bajito']], ['Puente (en D)', ['[D]Tuerce a la izquierda [A]donde se acaba el asfalto', '[G]ahí empieza [D]lo que no se nombra']]] },
  { id: 's4', title: 'Café con Hielo', artist: 'Dúo Naranja', key: 'Dm', bpm: 118, min: 5, status: 'aprendiendo', tuning: 'E estándar', guest: 'Trompeta invitada', notes: { Vientos: 'Frase de trompeta en el interludio, 4 compases.' },
    chart: [['Verso', ['[Dm]Café con hielo [Gm]a las tres de la tarde', '[A7]verano de tarima [Dm]y nadie sabe la letra']], ['Coro', ['[F]Sirve otro, sirve otro, [C]que la noche es larga', '[Gm]cantamos mal [A7]pero cantamos juntos']]] },
  { id: 's5', title: 'Lunes de Lluvia', artist: 'Faro Lento', key: 'F#m', bpm: 87, min: 4, status: 'pausa', tuning: 'E estándar', capo: 2, notes: {},
    chart: [['Verso', ['[F#m]Lunes de lluvia, [D]paraguas roto', '[A]el bus no llega [E]pero yo ya salí']], ['Coro', ['[F#m]Mojarse un poco [D]no le hace mal a nadie', '[A]se aprende más [E]bajo el agua']]] },
]
const SETS0 = [
  { id: 'l1', name: 'Toque Sótano 9', items: [{ t: 's', id: 's1' }, { t: 's', id: 's2' }, { t: 's', id: 's3' }, { t: 's', id: 's4' }] },
  { id: 'l2', name: 'Ensayo de jueves', items: [{ t: 's', id: 's2' }, { t: 's', id: 's5' }, { t: 's', id: 's1' }] },
  { id: 'l3', name: 'Acústico corto', items: [{ t: 's', id: 's2' }, { t: 's', id: 's5' }] },
]
const EV0 = [
  { id: 'e0', type: 'ensayo', title: 'Ensayo general', date: '2026-11-05', time: '7:00 pm', place: 'Sala Eco, Cabecera', set: 'l2', rsvp: { m1: 'si', m2: 'si', m3: 'si', m4: 'si' } },
  { id: 'e1', type: 'ensayo', title: 'Ensayo de jueves', date: '2026-11-12', time: '7:30 pm', place: 'Sala Eco, Cabecera', set: 'l2', rsvp: { m2: 'si', m3: 'si' } },
  { id: 'e2', type: 'toque', title: 'Toque Sótano 9', date: '2026-11-14', time: '9:30 pm', place: 'Sótano 9, Centro', set: 'l1', rsvp: { m2: 'si', m4: 'si', m3: 'quiza' } },
]
const LESSONS = {
  Guitarra: [
    { id: 'g1', grp: 'Primeros pasos', t: 'Araña cromática 1-2-3-4', min: 5, from: 60, to: 100, intro: 'Coordinar los cuatro dedos de la mano izquierda y la púa alternada.', diag: 'fret', steps: ['Pon el dedo 1 en el traste 1, el 2 en el 2, el 3 en el 3 y el 4 en el 4 de la sexta cuerda.', 'Toca cada nota con púa alternada (abajo-arriba), una por clic del metrónomo.', 'Al terminar la cuerda, pasa a la siguiente y sigue el mismo patrón.', 'Mantén los dedos cerca del traste, sin apretar de más. Sube 5 bpm solo cuando salga limpio cinco veces seguidas.'] },
    { id: 'g2', grp: 'Primeros pasos', t: 'Acordes abiertos Em y Am', min: 8, from: 50, to: 80, intro: 'Cambiar entre dos acordes sin parar el pulso.', diag: 'fret', steps: ['Forma Em con los dedos 2 y 3 en la quinta y cuarta cuerda, traste 2.', 'Rasguea cuatro veces y cambia a Am moviendo los dos dedos una cuerda abajo.', 'Cuenta cuatro tiempos por acorde y sin detener el metrónomo.', 'Cuando salga limpio, sube 5 bpm.'] },
    { id: 'g3', grp: 'Siguiente nivel', t: 'Ritmo de corcheas con púa', min: 6, from: 70, to: 110, intro: 'Púa alternada constante, acentuando los tiempos.', diag: 'fret', steps: ['Silencia las cuerdas con la mano izquierda.', 'Toca corcheas: abajo en el tiempo, arriba en el "y".', 'Acentúa el 1 y el 3 con un golpe más fuerte.', 'Añade un acorde cuando el pulso esté estable.'] },
  ],
  Bajo: [
    { id: 'b1', grp: 'Primeros pasos', t: 'Raíz y quinta en negras', min: 5, from: 60, to: 100, intro: 'La base de casi cualquier canción: raíz y quinta.', diag: 'fret', steps: ['Busca la raíz del acorde en la cuerda más grave.', 'Toca la raíz en el tiempo 1 y la quinta en el tiempo 3.', 'Alterna dedos índice y medio de la mano derecha.', 'Cuida que cada nota dure lo mismo.'] },
    { id: 'b2', grp: 'Primeros pasos', t: 'Silencios con la mano', min: 4, from: 60, to: 90, intro: 'Notas cortas y limpias para que el bombo respire.', diag: 'fret', steps: ['Apoya el pulgar derecho en la pastilla.', 'Toca la nota y silénciala con la mano izquierda.', 'Practica con el bombo del metrónomo.', 'Sube el tempo poco a poco.'] },
    { id: 'b3', grp: 'Siguiente nivel', t: 'Pentatónica menor en la', min: 8, from: 60, to: 100, intro: 'La escala que más vas a usar en rock.', diag: 'fret', steps: ['Empieza en el traste 5 de la cuerda más grave.', 'Sube la escala de a dos notas por cuerda.', 'Baja sin mirar el mástil.', 'Toca en negras y luego en corcheas.'] },
  ],
  Batería: [
    { id: 'd1', grp: 'Primeros pasos', t: 'Rock básico a octavos', min: 6, from: 60, to: 110, intro: 'Bombo, caja y hi-hat: el beat que sostiene todo.', diag: 'drums', steps: ['Hi-hat en cada octavo con la mano derecha.', 'Bombo en 1 y 3, caja en 2 y 4.', 'Cuenta en voz alta "1 y 2 y 3 y 4 y".', 'Sube el tempo cuando no se desacomode.'] },
    { id: 'd2', grp: 'Primeros pasos', t: 'Fill de cuatro golpes', min: 5, from: 60, to: 100, intro: 'Un cierre simple para terminar cada frase.', diag: 'drums', steps: ['Toca el beat tres compases.', 'En el cuarto, toca cuatro golpes: caja, tom, tom, piso.', 'Vuelve al beat sin perder el uno.', 'Repite con el metrónomo.'] },
    { id: 'd3', grp: 'Siguiente nivel', t: 'Hi-hat abierto en contratiempo', min: 7, from: 70, to: 110, intro: 'Más groove con el pie del hi-hat.', diag: 'drums', steps: ['Mantén el beat básico.', 'Abre el hi-hat en el "y" del 4.', 'Cierra con el pie en el 1.', 'Cuida que la caja no cambie de volumen.'] },
  ],
  Piano: [
    { id: 'p1', grp: 'Primeros pasos', t: 'Tríadas en Do, Fa y Sol', min: 6, from: 50, to: 90, intro: 'Los tres acordes que abren mil canciones.', diag: 'keys', steps: ['Forma Do mayor con Do, Mi, Sol.', 'Mueve la forma a Fa y a Sol.', 'Cambia de acorde cada cuatro tiempos.', 'Mantén la mano izquierda con la raíz.'] },
    { id: 'p2', grp: 'Primeros pasos', t: 'Arpegios en negras', min: 5, from: 50, to: 90, intro: 'Tocar las notas del acorde una por una.', diag: 'keys', steps: ['Toca Do, Mi, Sol, Mi con la derecha.', 'Deja la raíz sonando con la izquierda.', 'Repite con Fa y con Sol.', 'Sube el tempo cuando se oiga parejo.'] },
    { id: 'p3', grp: 'Siguiente nivel', t: 'Inversiones de acordes', min: 8, from: 50, to: 80, intro: 'Cambiar de acorde sin saltar por el teclado.', diag: 'keys', steps: ['Toca Do mayor en estado fundamental.', 'Pasa a la primera inversión: Mi, Sol, Do.', 'Pasa a la segunda: Sol, Do, Mi.', 'Haz la progresión Do, Fa, Sol usando la inversión más cercana.'] },
  ],
}
const COMM = [
  { id: 'c1', name: 'Marea Negra', msg: 'Busca baterista · rock alternativo · Cabecera', ini: 'MN' },
  { id: 'c2', name: 'Polvo de Cobre', msg: 'Busca voz femenina · covers en vivo · Floridablanca', ini: 'PC' },
  { id: 'c3', name: 'Los Cuervos del Norte', msg: 'Busca bajista · toques de fin de semana', ini: 'CN' },
]
const ROOMS = [
  { id: 'r1', name: 'Sala Eco', desc: 'Cabecera · bateria, 2 amplificadores · $ 25.000/h' },
  { id: 'r2', name: 'Cuarto Verde', desc: 'Centro · backline completo · $ 35.000/h' },
]

const NOTES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
const FLAT = { Db: 'C#', Eb: 'D#', Gb: 'F#', Ab: 'G#', Bb: 'A#' }
const tr1 = (n, s) => { const i = NOTES.indexOf(FLAT[n] ?? n); return i < 0 ? n : NOTES[(i + s + 120) % 12] }
const trChord = (c, s) => (s === 0 ? c : c.replace(/^([A-G][#b]?)/, (r) => tr1(r, s)).replace(/\/([A-G][#b]?)/, (_, r) => '/' + tr1(r, s)))
const parseLine = (l) => { const out = []; const re = /\[([^\]]+)\]([^[]*)/g; let m; let pre = l.split('[')[0]; if (pre) out.push(['', pre]); while ((m = re.exec(l))) out.push([m[1], m[2]]); return out }
const dur = (songs) => songs.reduce((a, s) => a + s.min, 0)
const MES = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC']
const fdate = (iso) => new Date(iso + 'T12:00:00').toLocaleDateString('es-CO', { weekday: 'long', day: 'numeric', month: 'long' })
const TODAY = '2026-11-09'

function useMetro(bpm, on) {
  const [beat, setBeat] = useState(-1)
  const ctx = useRef(null)
  useEffect(() => {
    if (!on) { setBeat(-1); return }
    let n = 0
    const click = (acc) => {
      try {
        ctx.current ??= new (window.AudioContext || window.webkitAudioContext)()
        const c = ctx.current; if (c.state === 'suspended') c.resume()
        const o = c.createOscillator(), g = c.createGain()
        o.frequency.value = acc ? 1500 : 1000; o.connect(g); g.connect(c.destination)
        g.gain.setValueAtTime(0.0001, c.currentTime); g.gain.exponentialRampToValueAtTime(0.4, c.currentTime + 0.005); g.gain.exponentialRampToValueAtTime(0.0001, c.currentTime + 0.06)
        o.start(); o.stop(c.currentTime + 0.07)
      } catch { /* sin audio */ }
    }
    const tick = () => { setBeat(n % 4); click(n % 4 === 0); n++ }
    tick()
    const id = setInterval(tick, 60000 / bpm)
    return () => clearInterval(id)
  }, [bpm, on])
  useEffect(() => () => { try { ctx.current?.close() } catch { /* nada */ } }, [])
  return beat
}

function Fret({ strings = 6 }) {
  const w = 300, h = 150, x0 = 20, fw = 52, ys = Array.from({ length: strings }, (_, i) => 18 + (i * (h - 56)) / (strings - 1))
  return (
    <svg viewBox={`0 0 ${w} ${h}`} role="img" aria-label="Diagrama de mástil">
      {ys.map((y, i) => <line key={i} x1={x0} x2={x0 + fw * 5} y1={y} y2={y} stroke="#9c9486" strokeWidth="1.5" />)}
      {[0, 1, 2, 3, 4, 5].map((i) => <line key={i} x1={x0 + fw * i} x2={x0 + fw * i} y1={ys[0]} y2={ys[strings - 1]} stroke="#4a443a" strokeWidth={i === 0 ? 4 : 1.4} />)}
      {[1, 2, 3, 4].map((d, i) => (
        <g key={d}><circle cx={x0 + fw * (i + 0.5)} cy={ys[strings - 2]} r="10" fill="#f2a33a" /><text x={x0 + fw * (i + 0.5)} y={ys[strings - 2] + 4} textAnchor="middle" fontSize="11" fontWeight="700" fill="#1a1105">{d}</text>
          <circle cx={x0 + fw * (i + 0.5)} cy={ys[strings - 1]} r="10" fill="#f2a33a" /><text x={x0 + fw * (i + 0.5)} y={ys[strings - 1] + 4} textAnchor="middle" fontSize="11" fontWeight="700" fill="#1a1105">{d}</text></g>
      ))}
      {[1, 2, 3, 4, 5].map((n, i) => <text key={n} x={x0 + fw * (i + 0.5)} y={h - 8} textAnchor="middle" fontSize="11" fill="#a1998b">{n}</text>)}
    </svg>
  )
}
function Drums() {
  const rows = [['Hi-hat', [1, 1, 1, 1, 1, 1, 1, 1]], ['Caja', [0, 0, 1, 0, 0, 0, 1, 0]], ['Bombo', [1, 0, 0, 0, 1, 0, 0, 0]]]
  return (
    <svg viewBox="0 0 300 130" role="img" aria-label="Diagrama de batería">
      {rows.map(([n, c], r) => (
        <g key={n}><text x="4" y={30 + r * 36} fontSize="11" fill="#a1998b">{n}</text>
          {c.map((v, i) => <circle key={i} cx={64 + i * 29} cy={26 + r * 36} r="10" fill={v ? '#f2a33a' : 'none'} stroke={v ? '#f2a33a' : '#3b352b'} strokeWidth="1.5" />)}</g>
      ))}
      {['1', 'y', '2', 'y', '3', 'y', '4', 'y'].map((t, i) => <text key={i} x={64 + i * 29} y="126" textAnchor="middle" fontSize="11" fill="#a1998b">{t}</text>)}
    </svg>
  )
}
function Keys() {
  return (
    <svg viewBox="0 0 300 130" role="img" aria-label="Diagrama de teclado">
      {Array.from({ length: 8 }, (_, i) => <rect key={i} x={30 + i * 30} y="10" width="30" height="100" fill="#ece4d2" stroke="#1c1915" />)}
      {[0, 1, 3, 4, 5].map((i) => <rect key={i} x={30 + i * 30 + 20} y="10" width="20" height="60" fill="#1c1915" />)}
      {[0, 2, 4].map((i, k) => <g key={i}><circle cx={45 + i * 30} cy="92" r="9" fill="#f2a33a" /><text x={45 + i * 30} y="96" textAnchor="middle" fontSize="11" fontWeight="700" fill="#1a1105">{k + 1}</text></g>)}
    </svg>
  )
}

function Metro({ from, to, bpm, setBpm }) {
  const [on, setOn] = useState(false)
  const beat = useMetro(bpm, on)
  return (
    <div className="bk-metro">
      <div className="bk-bpmrow">
        <button className="bk-sq" aria-label="Bajar bpm" onClick={() => setBpm(Math.max(40, bpm - 5))}>−</button>
        <div className="bk-bpm">{bpm}<small>bpm · meta {to}</small></div>
        <button className="bk-sq" aria-label="Subir bpm" onClick={() => setBpm(Math.min(220, bpm + 5))}>+</button>
      </div>
      <input type="range" min="40" max="220" value={bpm} onChange={(e) => setBpm(+e.target.value)} aria-label="Tempo" />
      <div className="bk-beats" aria-hidden="true">{[0, 1, 2, 3].map((i) => <i key={i} className={`${beat === i ? 'on' : ''} ${i === 0 ? 'ac' : ''}`} />)}</div>
      <button className="bk-btn pri blk" onClick={() => setOn(!on)}><svg viewBox="0 0 24 24" className="bk-ico"><path d={on ? P.pause : P.play} /></svg>{on ? 'Detener' : 'Empezar'}</button>
    </div>
  )
}

function Stage({ songs, setlist, start, onClose }) {
  const [i, setI] = useState(start)
  const [role, setRole] = useState(null)
  const [showRole, setShowRole] = useState(true)
  const [shift, setShift] = useState(0)
  const [auto, setAuto] = useState(false)
  const [speed, setSpeed] = useState(2)
  const [metro, setMetro] = useState(false)
  const [hi, setHi] = useState(false)
  const s = songs[i]
  const nxt = songs[i + 1]
  const body = useRef(null)
  const beat = useMetro(s.bpm, metro)
  useEffect(() => {
    if (!auto) return
    const id = setInterval(() => { if (body.current) body.current.scrollTop += speed }, 40)
    return () => clearInterval(id)
  }, [auto, speed])
  useEffect(() => { setShift(0); setAuto(false); if (body.current) body.current.scrollTop = 0 }, [i])
  const noChords = ['Voz', 'Batería', 'Percusión'].includes(role)
  const nextChange = nxt && nxt.tuning !== s.tuning ? nxt.tuning : null
  const key = trChord(s.key, shift)
  const note = role && s.notes[role]
  return (
    <div className="bk-st" role="dialog" aria-label="Modo escenario">
      <div className="bk-sth">
        <span className="pos">{i + 1} / {songs.length}<button className={`bk-sbtn ${hi ? 'on' : ''}`} style={{ border: 0, minHeight: 28, minWidth: 28 }} aria-label="Pantalla encendida" aria-pressed={hi} onClick={() => setHi(!hi)}><svg viewBox="0 0 24 24" className="bk-ico" style={{ width: 16, height: 16, color: 'var(--amber)' }}><path d={P.sun} /></svg></button></span>
        <button className="bk-sbtn" onClick={() => setShowRole(!showRole)}>Mi vista</button>
        <button className="bk-sbtn" aria-label="Recargar" onClick={() => { setShift(0); setAuto(false); setMetro(false); if (body.current) body.current.scrollTop = 0 }}><Ico n="reload" /></button>
        <button className="bk-sbtn" aria-label="Cerrar modo escenario" onClick={onClose}><Ico n="x" /></button>
      </div>
      {showRole && (
        <div className="bk-role">
          <p>¿Qué tocas? Así ves solo lo tuyo:</p>
          <div>{ROLES.map((r) => <button key={r} className={role === r || (r === 'Todo' && role === null && false) ? 'on' : ''} onClick={() => { setRole(r === 'Todo' ? null : r); setShowRole(false) }}>{r}</button>)}</div>
        </div>
      )}
      <div className="bk-stb" ref={body} style={hi ? { background: '#050505' } : undefined}>
        <h2 className="bk-stt">{s.title}</h2>
        <div className="bk-sta">{s.artist}</div>
        <div className="bk-chips"><span className="bk-bigchip k">{key}</span><span className="bk-bigchip">{s.bpm} bpm</span></div>
        <div className="bk-chips"><span className="bk-bigchip" style={{ fontSize: 15 }}>{s.tuning === 'Drop D' ? 'Guitarra: Drop D' : s.tuning}{s.capo ? ` · capo ${s.capo}` : ''}</span></div>
        {role && <div className="bk-eye" style={{ margin: '4px 0' }}>Vista: {role}</div>}
        {s.change && <div className="bk-chg">Cambio de tono: {s.change}</div>}
        {nextChange && <div className="bk-after">Después: {nextChange === 'Drop D' ? 'cambia a Guitarra: Drop D' : 'vuelve a E estándar'}</div>}
        {note && <div className="bk-note"><b>Nota para {role}</b>{note}</div>}
        <div className="bk-chart">
          {s.chart.map(([sec, lines]) => (
            <div key={sec}><h4>{sec}</h4>
              {lines.map((l, k) => <div className="bk-cl" key={k}>{parseLine(l).map(([c, t], j) => <span className="bk-seg-c" key={j}><em>{!noChords && c ? trChord(c, shift) : ' '}</em><span>{t || ' '}</span></span>)}</div>)}
            </div>
          ))}
        </div>
        {nxt && <div className="bk-next">Sigue: <b>{nxt.title}</b></div>}
      </div>
      <div className="bk-stf">
        <div className="bk-tools">
          <button className="bk-sbtn" aria-label="Bajar un semitono" onClick={() => setShift(shift - 1)}>−</button>
          <span className="lbl" aria-live="polite">Tono {shift > 0 ? '+' : ''}{shift}</span>
          <button className="bk-sbtn" aria-label="Subir un semitono" onClick={() => setShift(shift + 1)}>+</button>
          <span className="sp" />
          <button className={`bk-sbtn ${auto ? 'on' : ''}`} aria-pressed={auto} aria-label="Autoscroll" onClick={() => setAuto(!auto)}>{auto ? 'Scroll ■' : 'Scroll ▶'}</button>
          {auto && <button className="bk-sbtn" aria-label="Velocidad de scroll" onClick={() => setSpeed(speed >= 4 ? 1 : speed + 1)}>×{speed}</button>}
          <button className={`bk-sbtn ${metro ? 'on' : ''}`} aria-pressed={metro} aria-label="Metrónomo" onClick={() => setMetro(!metro)}>{metro ? (beat === 0 ? '●' : '○') + ' ' + s.bpm : 'Metro'}</button>
        </div>
        <div className="bk-nav2">
          <button className="bk-btn blk" disabled={i === 0} onClick={() => setI(i - 1)}><Ico n="left" />Anterior</button>
          <button className="bk-btn pri blk" disabled={!nxt} onClick={() => setI(i + 1)}>Siguiente<Ico n="right" /></button>
        </div>
      </div>
    </div>
  )
}

function Sheet({ onClose, children }) {
  return <div className="bk-sheet-bg" onClick={onClose}><div className="bk-sheet" role="dialog" onClick={(e) => e.stopPropagation()}>{children}</div></div>
}

export default function Backline() {
  const [mode, setMode] = useState('band')
  const [tab, setTab] = useState('home')
  const [songs, setSongs] = useState(SONGS0)
  const [sets, setSets] = useState(SETS0)
  const [events, setEvents] = useState(EV0)
  const [done, setDone] = useState({})
  const [invited, setInvited] = useState(false)
  const [msgs, setMsgs] = useState([{ who: 'm2', t: 'Mañana ensayo a las 7:30, ¿quién lleva el cable?', h: '6:12 pm' }, { who: 'm3', t: 'Yo lo llevo.', h: '6:20 pm' }])
  const [sub, setSub] = useState({ music: 'songs', learn: 'Guitarra', comm: 'bandas', bandaChat: false })
  const [view, setView] = useState(null) // {n:'set'|'lesson', id}
  const [sheet, setSheet] = useState(null)
  const [stage, setStage] = useState(null)
  const [toast, setToast] = useState(null)
  const [q, setQ] = useState('')
  const [filter, setFilter] = useState('todas')
  const [evf, setEvf] = useState('prox')
  const [contacted, setContacted] = useState({})
  const [bpms, setBpms] = useState({})
  const [seen, setSeen] = useState({ comm: false, banda: false })
  const [biz, setBiz] = useState({ tab: 'hoy', reqs: [{ id: 'q1', band: 'Marea Negra', sala: 'Sala Eco', when: 'mar 10 nov · 6:00 pm', st: 'pend' }, { id: 'q2', band: 'Polvo de Cobre', sala: 'Cuarto Verde', when: 'mié 11 nov · 8:00 pm', st: 'conf' }, { id: 'q3', band: 'Cuerda Floja', sala: 'Sala Eco', when: 'jue 12 nov · 7:30 pm', st: 'conf' }] })
  const say = (t) => { setToast(t); setTimeout(() => setToast(null), 2200) }
  const song = (id) => songs.find((s) => s.id === id)
  const go = (t) => { setTab(t); setView(null); if (t === 'comm') setSeen((x) => ({ ...x, comm: true })); if (t === 'banda') setSeen((x) => ({ ...x, banda: true })) }
  const upcoming = events.filter((e) => e.date >= TODAY).sort((a, b) => a.date.localeCompare(b.date))
  const setRsvp = (id, v) => setEvents((l) => l.map((e) => (e.id === id ? { ...e, rsvp: { ...e.rsvp, [ME]: v } } : e)))
  const setSongsOf = (l) => l.items.filter((x) => x.t === 's').map((x) => song(x.id)).filter(Boolean)

  const changes = (l) => { const ss = setSongsOf(l); let n = 0; let cur = 'E estándar'; ss.forEach((s) => { if (s.tuning !== cur) n++; cur = s.tuning }); return n }
  const pending = 2
  void pending

  const Rsvp = ({ e }) => {
    const mine = e.rsvp[ME]
    const yes = MEMBERS.filter((m) => e.rsvp[m.id] === 'si').length
    const none = MEMBERS.filter((m) => !e.rsvp[m.id])
    return (
      <div className="bk-rsvp">
        <div className="btns">
          {[['si', 'Voy', ''], ['quiza', 'Quizás', 'qz'], ['no', 'No voy', 'no']].map(([v, l, c]) => <button key={v} className={`${mine === v ? 'on' : ''} ${c}`} aria-pressed={mine === v} onClick={() => setRsvp(e.id, v)}>{l}</button>)}
        </div>
        <div className="bk-ok" style={{ color: yes >= 3 ? 'var(--sage)' : 'var(--mut)' }}>{yes}/{MEMBERS.length} confirmados</div>
        {none.length > 0 && <div className="bk-help" style={{ fontSize: 12.5 }}>Sin responder: {none.map((m) => m.name.split(' ')[0]).join(', ')}</div>}
      </div>
    )
  }
  const Ticket = ({ e }) => {
    const d = new Date(e.date + 'T12:00:00')
    const l = sets.find((x) => x.id === e.set)
    return (
      <div className="bk-ticket">
        <div className="bk-tdate"><span>{MES[d.getMonth()]}</span><b>{d.getDate()}</b></div>
        <div className="bk-tbody">
          <div className="bk-eye am">{e.type} · {fdate(e.date)}</div>
          <h3>{e.title}</h3>
          <div className="bk-li-s">{e.time} · {e.place}</div>
          {l && <button className="bk-link" style={{ fontSize: 13 }} onClick={() => { setTab('music'); setSub((s) => ({ ...s, music: 'sets' })); setView({ n: 'set', id: l.id }) }}>Ver setlist: {l.name}</button>}
        </div>
        {e.date >= TODAY && <Rsvp e={e} />}
      </div>
    )
  }

  // ---------- Inicio
  const homeV = () => {
    const next = upcoming[0]
    const steps = [['Agrega tus primeras 3 canciones', songs.length >= 3], ['Arma un setlist (o impórtalo del chat)', sets.length > 0], ['Invita a alguien de la banda', invited], ['Agenda el próximo ensayo', upcoming.length > 0]]
    const nd = steps.filter((x) => x[1]).length
    return (
      <>
        <div><div className="bk-eye">Buenos días</div><h1 className="bk-title">Cuerda Floja</h1></div>
        <div className="bk-sec">Lo próximo</div>
        {next ? <Ticket e={next} /> : <div className="bk-callout">Nada agendado todavía. <button className="bk-link" onClick={() => go('agenda')}>Agenda el próximo ensayo</button></div>}
        <div className="bk-sec">Primeros pasos · {nd}/4</div>
        <div className="bk-card">{steps.map(([t, ok], i) => <div key={i} className={`bk-check ${ok ? 'done' : ''}`}><span className="bk-box">{ok ? '✓' : ''}</span><span>{t}</span></div>)}</div>
        <div className="bk-sec">Repertorio</div>
        <div className="bk-stats"><div><b>{songs.length}</b><span>Canciones</span></div><div><b>{sets.length}</b><span>Listas</span></div><div><b>{songs.filter((s) => s.status !== 'lista').length}</b><span>Por pulir</span></div></div>
        <div className="bk-sec">Para practicar</div>
        <div className="bk-row2" style={{ borderTop: '1px solid var(--line)', borderBottom: '1px solid var(--line)', padding: '12px 0' }}>
          <div style={{ flex: 1 }}><div style={{ fontWeight: 700, fontSize: 16 }}>{LESSONS.Guitarra[0].t}</div><div className="bk-li-s">5 min · 60 → 100 bpm</div></div>
          <button className="bk-btn sm" onClick={() => { setTab('learn'); setView({ n: 'lesson', id: 'g1', ins: 'Guitarra' }) }}>Empezar</button>
        </div>
        <div className="bk-sec">La banda</div>
        <div className="bk-li-s">{MEMBERS.length} integrantes · {invited ? '1 invitación enviada' : 'Modo demostración.'}</div>
        <button className="bk-link" onClick={() => go('banda')}>Ver y administrar la banda</button>
        <div className="bk-sec">¿Tienes una sala de ensayos?</div>
        <div className="bk-callout">Publica tus salas, horarios y precios y recibe reservas. <button className="bk-link" onClick={() => { setMode('biz'); setBiz((b) => ({ ...b, tab: 'hoy' })) }}>Ir a mi negocio</button></div>
      </>
    )
  }

  // ---------- Música
  const [dragId, setDragId] = useState(null)
  const rowsRef = useRef({})
  const musicV = () => {
    if (view?.n === 'set') return setV(sets.find((x) => x.id === view.id))
    const isSongs = sub.music === 'songs'
    const list = songs.filter((s) => (filter === 'todas' || (filter === 'listas' && s.status === 'lista') || (filter === 'aprendiendo' && s.status === 'aprendiendo') || (filter === 'pausa' && s.status === 'pausa')) && (s.title + s.artist).toLowerCase().includes(q.toLowerCase())).sort((a, b) => a.title.localeCompare(b.title, 'es'))
    return (
      <>
        <div><div className="bk-eye">Música</div><h1 className="bk-title">{isSongs ? 'Repertorio' : 'Setlists'}</h1></div>
        <div className="bk-row2">
          <span className="bk-seg">{[['songs', 'Canciones'], ['sets', 'Setlists']].map(([id, l]) => <button key={id} className={sub.music === id ? 'on' : ''} onClick={() => setSub({ ...sub, music: id })}>{l}</button>)}</span>
          <span style={{ flex: 1 }} />
          {isSongs ? <><button className="bk-btn" onClick={() => setSheet({ n: 'song' })}><Ico n="plus" />Canción</button><button className="bk-btn" aria-label="Importar" style={{ padding: '0 11px' }} onClick={() => say('Importar por foto o archivo no está en la demo')}><Ico n="up" /></button></> : <button className="bk-btn" onClick={() => setSheet({ n: 'newset' })}><Ico n="plus" />Nuevo</button>}
        </div>
        {isSongs ? (
          <>
            <div className="bk-mline"><b>{songs.length}</b> canciones · <b>{sets.length}</b> listas · <b>{dur(songs)}</b> min</div>
            <div className="bk-prog"><i style={{ width: `${(songs.filter((s) => s.status === 'lista').length / Math.max(1, songs.length)) * 100}%` }} /></div>
            <label className="bk-search"><Ico n="search" /><input placeholder="Buscar por canción o artista" value={q} onChange={(e) => setQ(e.target.value)} aria-label="Buscar" /></label>
            <div className="bk-pills">{[['todas', 'Todas'], ['listas', 'Listas'], ['aprendiendo', 'Aprendiendo'], ['pausa', 'En pausa']].map(([id, l]) => <button key={id} className={`bk-pill ${filter === id ? 'on' : ''}`} aria-pressed={filter === id} onClick={() => setFilter(id)}>{l}</button>)}</div>
            <div style={{ borderTop: '1px solid var(--line)' }}>
              {list.length === 0 && <div className="bk-help" style={{ padding: 16 }}>Ninguna canción coincide.</div>}
              {list.map((s) => (
                <button key={s.id} className="bk-li" onClick={() => setSheet({ n: 'detail', id: s.id })}>
                  <span className={`bk-dot ${s.status === 'aprendiendo' ? 'ap' : s.status === 'pausa' ? 'pa' : ''}`} />
                  <span style={{ flex: 1, minWidth: 0 }}>
                    <span className="bk-li-t" style={{ display: 'block' }}>{s.title}</span><span className="bk-li-s" style={{ display: 'block' }}>{s.artist}</span>
                    <span className="bk-li-m">{s.tuning === 'Drop D' ? <span className="e">Guitarra: Drop D</span> : <span className="m">{s.tuning}{s.capo ? ` · capo ${s.capo}` : ''}</span>}{s.change && <span className="e">{s.change}</span>}{s.guest && <span className="m">{s.guest}</span>}{s.status === 'aprendiendo' && <span className="bk-chip">Aprendiendo</span>}{s.status === 'pausa' && <span className="bk-chip">En pausa</span>}</span>
                  </span>
                  <span className="bk-li-r"><b>{s.key}</b>{s.bpm} bpm</span>
                </button>
              ))}
            </div>
          </>
        ) : (
          <div className="bk-stack">
            {sets.map((l) => { const ss = setSongsOf(l); return (
              <button key={l.id} className="bk-card2" onClick={() => setView({ n: 'set', id: l.id })}>
                <div className="bk-eye am">Toque</div><h3>{l.name}</h3>
                <div className="bk-mono-s bk-mline">{ss.length} canciones · {dur(ss)} min · {changes(l)} {changes(l) === 1 ? 'cambio' : 'cambios'} de afinación</div>
                <div className="bk-li-s" style={{ marginTop: 4 }}>{ss.slice(0, 3).map((s) => s.title).join(' · ')}{ss.length > 3 ? ` · +${ss.length - 3} más` : ''}</div>
              </button>
            ) })}
          </div>
        )}
      </>
    )
  }

  const moveItem = (l, from, to) => setSets((all) => all.map((x) => { if (x.id !== l.id || to < 0 || to >= x.items.length) return x; const it = [...x.items]; const [m] = it.splice(from, 1); it.splice(to, 0, m); return { ...x, items: it } }))
  const startDrag = (e, l, idx) => {
    e.preventDefault()
    const el = e.currentTarget; el.setPointerCapture?.(e.pointerId)
    setDragId(idx)
    let cur = idx
    const move = (ev) => {
      const ys = l.items.map((_, k) => rowsRef.current[k]?.getBoundingClientRect()).map((r) => (r ? r.top + r.height / 2 : 0))
      let t = cur
      while (t > 0 && ev.clientY < ys[t - 1] + 0) t--
      while (t < ys.length - 1 && ev.clientY > ys[t + 1] - 0) t++
      if (t !== cur) { moveItem(l, cur, t); cur = t; setDragId(t) }
    }
    const up = () => { window.removeEventListener('pointermove', move); window.removeEventListener('pointerup', up); setDragId(null) }
    window.addEventListener('pointermove', move); window.addEventListener('pointerup', up)
  }
  const setV = (l) => {
    if (!l) return null
    const ss = setSongsOf(l)
    let cur = 'E estándar'; let n = 0
    const rows = l.items.map((it, idx) => {
      if (it.t === 'l') return { idx, label: it.text }
      const s = song(it.id); let strip = null
      if (s && s.tuning !== cur) { strip = s.tuning === 'Drop D' ? 'Cambiar a guitarra: Drop D' : 'Volver a E estándar'; cur = s.tuning; n++ }
      return { idx, s, strip }
    })
    let num = 0
    const meta = `${ss.length} canciones · ${dur(ss)} min · ${n} ${n === 1 ? 'cambio' : 'cambios'} de afinación`
    return (
      <>
        <button className="bk-back" onClick={() => setView(null)}><Ico n="back" />Setlists</button>
        <div className="bk-paper">
          <h2>{l.name}</h2><div className="meta">{meta}</div>
          {l.items.length === 0 && <div className="bk-pa" style={{ padding: '14px 0' }}>Este setlist está vacío. Agrega canciones.</div>}
          {rows.map((r) => r.label !== undefined ? (
            <div key={r.idx} className="bk-prow" ref={(el) => { rowsRef.current[r.idx] = el }} style={{ gridTemplateColumns: '18px minmax(0,1fr) auto' }}>
              <button className="bk-handle" aria-label="Arrastrar etiqueta" onPointerDown={(e) => startDrag(e, l, r.idx)}><svg viewBox="0 0 24 24"><path d={P.grip} stroke="currentColor" strokeWidth="3" strokeLinecap="round" /></svg></button>
              <span className="bk-strip" style={{ margin: 0 }}>{r.label}</span>
              <button className="bk-handle" style={{ cursor: 'pointer', fontSize: 15 }} aria-label="Quitar etiqueta" onClick={() => setSets((a) => a.map((x) => x.id === l.id ? { ...x, items: x.items.filter((_, k) => k !== r.idx) } : x))}>×</button>
            </div>
          ) : r.s && (
            <div key={r.idx} ref={(el) => { rowsRef.current[r.idx] = el }} style={{ display: 'grid' }}>
              {r.strip && <span className="bk-strip" style={{ margin: '9px 0 0', justifySelf: 'start' }}>{r.strip}</span>}
              <div className={`bk-prow ${dragId === r.idx ? 'drag' : ''}`} data-song={r.s.id} style={{ border: r.strip ? undefined : undefined }}>
                <button className="bk-handle" aria-label={`Arrastrar ${r.s.title}`} onPointerDown={(e) => startDrag(e, l, r.idx)}><svg viewBox="0 0 24 24"><path d={P.grip} stroke="currentColor" strokeWidth="3" strokeLinecap="round" /></svg></button>
                <span className="bk-pn">{++num}</span>
                <button style={{ border: 0, background: 'none', textAlign: 'left', padding: 0, color: 'inherit' }} onClick={() => setSheet({ n: 'detail', id: r.s.id })}><div className="bk-pt">{r.s.title}</div><div className="bk-pa">{r.s.artist}{r.s.tuning === 'Drop D' ? ' · Guitarra: Drop D' : ''}</div></button>
                <span className="bk-pk">{r.s.key} · {r.s.bpm}</span>
              </div>
            </div>
          ))}
        </div>
        <p className="bk-help">Arrastra el asa ⋮⋮ para cambiar el orden (también las etiquetas). Toca una canción para ver sus detalles.</p>
        <div className="bk-stack">
          <button className="bk-btn blk" onClick={() => setSheet({ n: 'addsongs', id: l.id })}><Ico n="plus" />Agregar canciones</button>
          <button className="bk-btn blk" onClick={() => setSheet({ n: 'label', id: l.id })}><Ico n="tag" />Agregar etiqueta</button>
          <button className="bk-btn pri blk" disabled={ss.length === 0} onClick={() => setStage({ l, start: 0 })}>Modo escenario</button>
          <button className="bk-btn blk" onClick={() => say('PDF con letras y acordes: no se genera en la demo')}>Exportar PDF con letras y acordes</button>
          <button className="bk-btn blk" onClick={() => say('PDF de solo la lista: no se genera en la demo')}>Exportar PDF solo la lista</button>
          <button className="bk-btn blk" onClick={() => { const txt = `${l.name}\n` + ss.map((s, k) => `${k + 1}. ${s.title} (${s.key} · ${s.bpm})`).join('\n'); try { navigator.clipboard?.writeText(txt) } catch { /* nada */ } say('Setlist copiado para WhatsApp') }}>Copiar para WhatsApp</button>
          <button className="bk-btn blk" onClick={() => setSheet({ n: 'editset', id: l.id })}>Editar setlist</button>
        </div>
      </>
    )
  }

  // ---------- Agenda
  const agendaV = () => {
    const list = evf === 'prox' ? upcoming : events.filter((e) => e.date < TODAY).sort((a, b) => b.date.localeCompare(a.date))
    return (
      <>
        <div><div className="bk-eye">Ensayos y toques</div><h1 className="bk-title">Agenda</h1></div>
        <p className="bk-help">Confirma si vas para que nadie tenga que preguntar en el chat.</p>
        <div className="bk-pills">{[['prox', `Próximos · ${upcoming.length}`], ['pas', 'Pasados']].map(([id, l]) => <button key={id} className={`bk-pill ${evf === id ? 'on' : ''}`} aria-pressed={evf === id} onClick={() => setEvf(id)}>{l}</button>)}</div>
        {list.length === 0 && <div className="bk-callout"><b>Nada agendado</b><br />Crea el próximo ensayo o toque y la banda podrá confirmar asistencia desde el celular. <button className="bk-link" onClick={() => setSheet({ n: 'event' })}>Agendar un evento</button></div>}
        {list.map((e) => (
          <div key={e.id} className="bk-stack"><Ticket e={e} />
            <div className="bk-row2" style={{ justifyContent: 'flex-end' }}><button className="bk-btn sm dng" onClick={() => setEvents((l) => l.filter((x) => x.id !== e.id))}>Eliminar</button></div></div>
        ))}
      </>
    )
  }

  // ---------- Aprender
  const learnV = () => {
    const ins = view?.ins ?? sub.learn
    if (view?.n === 'lesson') {
      const L = Object.values(LESSONS).flat().find((x) => x.id === view.id)
      const bpm = bpms[L.id] ?? L.from
      return (
        <>
          <button className="bk-back" onClick={() => setView(null)}><Ico n="back" />Aprender</button>
          <div className="bk-eye">{ins} · {L.grp} · {L.min} min</div>
          <h1 className="bk-title sm">{L.t}</h1>
          <p className="bk-help" style={{ fontSize: 15 }}>{L.intro}</p>
          <div className="bk-diag">{L.diag === 'fret' ? <Fret strings={ins === 'Bajo' ? 4 : 6} /> : L.diag === 'drums' ? <Drums /> : <Keys />}</div>
          <div className="bk-sec">Paso a paso</div>
          <div className="bk-steps">{L.steps.map((t, i) => <div className="bk-step" key={i}><b>{i + 1}</b><span>{t}</span></div>)}</div>
          <div className="bk-sec">Metrónomo</div>
          <Metro from={L.from} to={L.to} bpm={bpm} setBpm={(v) => setBpms({ ...bpms, [L.id]: v })} />
          <button className="bk-btn pri blk" onClick={() => { setDone({ ...done, [L.id]: !done[L.id] }); say(done[L.id] ? 'Lección desmarcada' : 'Lección completada') }}>{done[L.id] ? 'Completada (deshacer)' : 'Marcar como completada'}</button>
        </>
      )
    }
    const ls = LESSONS[ins]
    return (
      <>
        <div><div className="bk-eye">Práctica</div><h1 className="bk-title">Aprender</h1></div>
        <p className="bk-help">Lecciones cortas con diagrama y metrónomo. Sube el tempo solo cuando salga limpio.</p>
        <span className="bk-seg" style={{ alignSelf: 'flex-start' }}>{Object.keys(LESSONS).map((k) => <button key={k} className={sub.learn === k ? 'on' : ''} onClick={() => setSub({ ...sub, learn: k })}>{k}</button>)}</span>
        <div className="bk-eye">{ls.filter((x) => done[x.id]).length} de {ls.length} completadas</div>
        {['Primeros pasos', 'Siguiente nivel'].map((g) => (
          <div key={g}><div className="bk-sec">{g}</div>
            {ls.filter((x) => x.grp === g).map((x) => (
              <button key={x.id} className={`bk-lec ${done[x.id] ? 'done' : ''}`} onClick={() => setView({ n: 'lesson', id: x.id, ins })}>
                <span className="n">{done[x.id] ? '✓' : ls.indexOf(x) + 1}</span>
                <span style={{ flex: 1 }}><span style={{ display: 'block', fontWeight: 600, fontSize: 15.5 }}>{x.t}</span><span className="bk-li-s">{x.min} min · {x.from} → {x.to} bpm</span></span>
                <Ico n="right" />
              </button>
            ))}</div>
        ))}
      </>
    )
  }

  // ---------- Comunidad / Banda
  const commV = () => (
    <>
      <div><div className="bk-eye">Descubre</div><h1 className="bk-title">Comunidad</h1></div>
      <span className="bk-seg" style={{ alignSelf: 'flex-start' }}>{[['bandas', 'Bandas'], ['salas', 'Salas']].map(([id, l]) => <button key={id} className={sub.comm === id ? 'on' : ''} onClick={() => setSub({ ...sub, comm: id })}>{l}</button>)}</span>
      {(sub.comm === 'bandas' ? COMM : ROOMS).map((c) => (
        <div key={c.id} className="bk-card" style={{ padding: 12, display: 'flex', alignItems: 'center', gap: 10 }}>
          <span className="bk-mono-sq" style={{ width: 38, height: 38 }}>{(c.ini ?? c.name.slice(0, 2)).toUpperCase()}</span>
          <div style={{ flex: 1, minWidth: 0 }}><b style={{ fontSize: 15.5 }}>{c.name}</b><div className="bk-li-s" style={{ fontSize: 13 }}>{c.msg ?? c.desc}</div></div>
          <button className={`bk-btn sm ${contacted[c.id] ? '' : 'pri'}`} onClick={() => { setContacted({ ...contacted, [c.id]: !contacted[c.id] }); say(contacted[c.id] ? 'Solicitud cancelada' : sub.comm === 'bandas' ? 'Mensaje enviado' : 'Reserva solicitada') }}>{contacted[c.id] ? 'Enviado' : sub.comm === 'bandas' ? 'Contactar' : 'Reservar'}</button>
        </div>
      ))}
    </>
  )
  const [chatText, setChatText] = useState('')
  const bandaV = () => (
    <>
      <div><div className="bk-eye">Tu banda</div><h1 className="bk-title">Banda</h1></div>
      <span className="bk-seg" style={{ alignSelf: 'flex-start' }}>{[[false, 'Integrantes'], [true, 'Chat']].map(([v, l]) => <button key={l} className={sub.bandaChat === v ? 'on' : ''} onClick={() => setSub({ ...sub, bandaChat: v })}>{l}</button>)}</span>
      {!sub.bandaChat ? (
        <>
          <div className="bk-card">{MEMBERS.map((m) => <div key={m.id} className="bk-check"><span className="bk-av">{m.ini}</span><span style={{ flex: 1 }}><b>{m.name}</b>{m.id === ME ? ' (tú)' : ''}<div className="bk-li-s" style={{ fontSize: 12.5 }}>{m.inst}</div></span></div>)}
            {invited && <div className="bk-check"><span className="bk-av">…</span><span style={{ flex: 1 }}><b>Invitación enviada</b><div className="bk-li-s" style={{ fontSize: 12.5 }}>Pendiente de aceptar</div></span></div>}</div>
          <button className="bk-btn pri blk" onClick={() => setSheet({ n: 'invite' })}><Ico n="plus" />Invitar a alguien</button>
        </>
      ) : (
        <>
          <div className="bk-chat">
            {msgs.length === 0 && <div className="bk-help">Aquí empieza el chat de la banda. Escribe el primer mensaje.</div>}
            {msgs.map((m, i) => <div key={i} className={`bk-bub ${m.who === ME ? 'me' : ''}`}><small><b>{MEMBERS.find((x) => x.id === m.who).name.split(' ')[0]}</b> {m.h}</small>{m.t}</div>)}
          </div>
          <form className="bk-row2" onSubmit={(e) => { e.preventDefault(); if (!chatText.trim()) return; setMsgs([...msgs, { who: ME, t: chatText.trim(), h: 'ahora' }]); setChatText('') }}>
            <input className="bk-in" placeholder="Escribe un mensaje…" value={chatText} onChange={(e) => setChatText(e.target.value)} aria-label="Mensaje" />
            <button className="bk-btn pri" disabled={!chatText.trim()}>Enviar</button>
          </form>
        </>
      )}
    </>
  )

  // ---------- hojas
  const [f, setF] = useState({})
  const sheetV = () => {
    if (!sheet) return null
    const close = () => { setSheet(null); setF({}) }
    if (sheet.n === 'song') {
      const ok = (f.title ?? '').trim() && (f.artist ?? '').trim()
      return (
        <Sheet onClose={close}>
          <h3>Agregar canción</h3>
          <label className="bk-f">Título<input value={f.title ?? ''} onChange={(e) => setF({ ...f, title: e.target.value })} autoFocus /></label>
          <label className="bk-f">Artista original<input value={f.artist ?? ''} onChange={(e) => setF({ ...f, artist: e.target.value })} /></label>
          <div className="bk-grid2"><label className="bk-f">Tono<input value={f.key ?? ''} placeholder="Em" onChange={(e) => setF({ ...f, key: e.target.value })} /></label><label className="bk-f">BPM<input inputMode="numeric" value={f.bpm ?? ''} placeholder="120" onChange={(e) => setF({ ...f, bpm: e.target.value.replace(/\D/g, '') })} /></label></div>
          <div className="bk-grid2"><label className="bk-f">Duración (min)<input inputMode="numeric" value={f.min ?? ''} placeholder="4" onChange={(e) => setF({ ...f, min: e.target.value.replace(/\D/g, '') })} /></label>
            <label className="bk-f">Estado<select value={f.status ?? 'lista'} onChange={(e) => setF({ ...f, status: e.target.value })}><option value="lista">Lista</option><option value="aprendiendo">Aprendiendo</option><option value="pausa">En pausa</option></select></label></div>
          <label className="bk-f">Afinación<select value={f.tuning ?? 'E estándar'} onChange={(e) => setF({ ...f, tuning: e.target.value })}><option>E estándar</option><option>Drop D</option></select></label>
          <div className="bk-row2"><button className="bk-btn pri" style={{ flex: 1 }} disabled={!ok} onClick={() => { setSongs([...songs, { id: 's' + Date.now(), title: f.title.trim(), artist: f.artist.trim(), key: f.key || 'C', bpm: +f.bpm || 100, min: +f.min || 4, status: f.status ?? 'lista', tuning: f.tuning ?? 'E estándar', notes: {}, chart: [['Letra', ['[' + (f.key || 'C') + ']Aún sin letra, agrégala en el ensayo']]] }]); say('Canción agregada'); close() }}>Agregar</button><button className="bk-btn" onClick={close}>Cancelar</button></div>
        </Sheet>
      )
    }
    if (sheet.n === 'detail') {
      const s = song(sheet.id)
      return (
        <Sheet onClose={close}>
          <div className="bk-eye am">{s.status === 'lista' ? 'Lista' : s.status === 'aprendiendo' ? 'Aprendiendo' : 'En pausa'}</div>
          <h3>{s.title}</h3><div className="bk-li-s">{s.artist} · {s.key} · {s.bpm} bpm · {s.min} min · {s.tuning}{s.capo ? ` · capo ${s.capo}` : ''}</div>
          {s.change && <div className="bk-chg" style={{ fontSize: 14, margin: 0 }}>Cambio de tono: {s.change}</div>}
          <label className="bk-f">Estado<select value={s.status} onChange={(e) => setSongs(songs.map((x) => (x.id === s.id ? { ...x, status: e.target.value } : x)))}><option value="lista">Lista</option><option value="aprendiendo">Aprendiendo</option><option value="pausa">En pausa</option></select></label>
          {Object.entries(s.notes).map(([k, v]) => <div key={k} className="bk-note" style={{ margin: 0 }}><b>{k}</b>{v}</div>)}
          <div className="bk-row2"><button className="bk-btn dng" onClick={() => { setSongs(songs.filter((x) => x.id !== s.id)); setSets(sets.map((l) => ({ ...l, items: l.items.filter((it) => it.id !== s.id) }))); close() }}>Quitar del repertorio</button><span style={{ flex: 1 }} /><button className="bk-btn" onClick={close}>Cerrar</button></div>
        </Sheet>
      )
    }
    if (sheet.n === 'newset') {
      return (
        <Sheet onClose={close}>
          <h3>Nuevo setlist</h3>
          <label className="bk-f">Nombre<input value={f.name ?? ''} onChange={(e) => setF({ name: e.target.value })} autoFocus /></label>
          <div className="bk-row2"><button className="bk-btn pri" style={{ flex: 1 }} disabled={!(f.name ?? '').trim()} onClick={() => { const id = 'l' + Date.now(); setSets([...sets, { id, name: f.name.trim(), items: [] }]); setView({ n: 'set', id }); close() }}>Crear</button><button className="bk-btn" onClick={close}>Cancelar</button></div>
        </Sheet>
      )
    }
    const l = sets.find((x) => x.id === sheet.id)
    if (sheet.n === 'addsongs') {
      const inSet = l.items.filter((x) => x.t === 's').map((x) => x.id)
      return (
        <Sheet onClose={close}>
          <h3>Agregar canciones</h3>
          {songs.filter((s) => !inSet.includes(s.id)).map((s) => <label className="bk-pick" key={s.id}><input type="checkbox" checked={!!f[s.id]} onChange={(e) => setF({ ...f, [s.id]: e.target.checked })} /><span style={{ flex: 1 }}><b>{s.title}</b><div className="bk-li-s" style={{ fontSize: 12.5 }}>{s.artist}</div></span><span className="bk-pk" style={{ fontFamily: 'var(--mono)', fontSize: 12 }}>{s.key} · {s.bpm}</span></label>)}
          {songs.every((s) => inSet.includes(s.id)) && <div className="bk-help">Todas las canciones ya están en este setlist.</div>}
          <div className="bk-row2"><button className="bk-btn pri" style={{ flex: 1 }} onClick={() => { const add = songs.filter((s) => f[s.id]).map((s) => ({ t: 's', id: s.id })); setSets(sets.map((x) => (x.id === l.id ? { ...x, items: [...x.items, ...add] } : x))); close() }}>Agregar</button><button className="bk-btn" onClick={close}>Cancelar</button></div>
        </Sheet>
      )
    }
    if (sheet.n === 'label') {
      return (
        <Sheet onClose={close}>
          <h3>Agregar etiqueta</h3>
          <label className="bk-f">Texto<input value={f.t ?? ''} placeholder="Ej. Pausa, hablar con el público" onChange={(e) => setF({ t: e.target.value })} autoFocus /></label>
          <div className="bk-row2"><button className="bk-btn pri" style={{ flex: 1 }} disabled={!(f.t ?? '').trim()} onClick={() => { setSets(sets.map((x) => (x.id === l.id ? { ...x, items: [...x.items, { t: 'l', text: f.t.trim() }] } : x))); close() }}>Agregar</button><button className="bk-btn" onClick={close}>Cancelar</button></div>
        </Sheet>
      )
    }
    if (sheet.n === 'editset') {
      return (
        <Sheet onClose={close}>
          <h3>Editar setlist</h3>
          <label className="bk-f">Nombre<input value={f.name ?? l.name} onChange={(e) => setF({ ...f, name: e.target.value })} /></label>
          {l.items.map((it, k) => (
            <div key={k} className="bk-row2" style={{ borderBottom: '1px solid var(--line)', padding: '6px 0' }}>
              <span style={{ flex: 1, fontSize: 14.5 }}>{it.t === 's' ? song(it.id)?.title : `Etiqueta: ${it.text}`}</span>
              <button className="bk-btn sm" aria-label="Subir" disabled={k === 0} onClick={() => moveItem(l, k, k - 1)}>▲</button>
              <button className="bk-btn sm" aria-label="Bajar" disabled={k === l.items.length - 1} onClick={() => moveItem(l, k, k + 1)}>▼</button>
              <button className="bk-btn sm dng" aria-label="Quitar" onClick={() => setSets(sets.map((x) => (x.id === l.id ? { ...x, items: x.items.filter((_, j) => j !== k) } : x)))}>×</button>
            </div>
          ))}
          <div className="bk-row2"><button className="bk-btn pri" style={{ flex: 1 }} onClick={() => { if ((f.name ?? '').trim()) setSets(sets.map((x) => (x.id === l.id ? { ...x, name: f.name.trim() } : x))); close() }}>Listo</button><button className="bk-btn dng" onClick={() => { setSets(sets.filter((x) => x.id !== l.id)); setView(null); close() }}>Eliminar</button></div>
        </Sheet>
      )
    }
    if (sheet.n === 'event') {
      const ok = (f.title ?? '').trim() && f.date
      return (
        <Sheet onClose={close}>
          <h3>Nuevo evento</h3>
          <label className="bk-f">Tipo<select value={f.type ?? 'ensayo'} onChange={(e) => setF({ ...f, type: e.target.value })}><option value="ensayo">Ensayo</option><option value="toque">Toque</option></select></label>
          <label className="bk-f">Título<input value={f.title ?? ''} onChange={(e) => setF({ ...f, title: e.target.value })} autoFocus /></label>
          <div className="bk-grid2"><label className="bk-f">Fecha<input type="date" value={f.date ?? ''} onChange={(e) => setF({ ...f, date: e.target.value })} /></label><label className="bk-f">Hora<input value={f.time ?? ''} placeholder="7:30 pm" onChange={(e) => setF({ ...f, time: e.target.value })} /></label></div>
          <label className="bk-f">Lugar<input value={f.place ?? ''} onChange={(e) => setF({ ...f, place: e.target.value })} /></label>
          <label className="bk-f">Setlist<select value={f.set ?? ''} onChange={(e) => setF({ ...f, set: e.target.value })}><option value="">Sin setlist</option>{sets.map((x) => <option key={x.id} value={x.id}>{x.name}</option>)}</select></label>
          <div className="bk-row2"><button className="bk-btn pri" style={{ flex: 1 }} disabled={!ok} onClick={() => { setEvents([...events, { id: 'e' + Date.now(), type: f.type ?? 'ensayo', title: f.title.trim(), date: f.date, time: f.time || '7:00 pm', place: f.place || 'Por definir', set: f.set || null, rsvp: { [ME]: 'si' } }]); setEvf('prox'); say('Evento agendado'); close() }}>Agendar</button><button className="bk-btn" onClick={close}>Cancelar</button></div>
        </Sheet>
      )
    }
    if (sheet.n === 'invite') {
      return (
        <Sheet onClose={close}>
          <h3>Invitar a la banda</h3>
          <p className="bk-help">Comparte este enlace con quien quieras sumar. Aquí el enlace es de ejemplo.</p>
          <input className="bk-in" readOnly value="backline.app/unete/CF-4821" aria-label="Enlace de invitación" />
          <div className="bk-row2"><button className="bk-btn pri" style={{ flex: 1 }} onClick={() => { setInvited(true); say('Invitación enviada'); close() }}>Enviar invitación</button><button className="bk-btn" onClick={close}>Cancelar</button></div>
        </Sheet>
      )
    }
    return null
  }

  // ---------- Mi negocio
  const bizV = () => {
    const pend = biz.reqs.filter((r) => r.st === 'pend')
    const upd = (id, st) => setBiz({ ...biz, reqs: biz.reqs.map((r) => (r.id === id ? { ...r, st } : r)) })
    const tabs = [['hoy', 'Hoy', 'cal'], ['reservas', 'Reservas', 'clock'], ['salas', 'Salas', 'door'], ['perfil', 'Perfil', 'store'], ['bandas', 'Mis bandas', 'users']]
    return (
      <>
        <div className="bk-bar"><span className="bk-mono-sq">SE</span><span className="bk-bandname">Sala Eco</span><span className="bk-chip">Mi negocio</span></div>
        <div className="bk-main">
          {biz.tab === 'hoy' && (
            <>
              <div className="bk-bizb">Activa los avisos para enterarte al instante cuando una banda pida o cancele una reserva.<button className="bk-btn sm" style={{ justifySelf: 'start' }} onClick={() => say('Avisos activados')}>Activar avisos</button></div>
              <div><div className="bk-eye">Lunes, 9 de noviembre</div><h1 className="bk-title">Hoy</h1></div>
              <div className="bk-statsb"><div><b>{pend.length}</b><span>Por responder</span></div><div><b>{biz.reqs.filter((r) => r.st === 'conf').length}</b><span>Confirmadas</span></div><div><b>{biz.reqs.length}</b><span>Esta semana</span></div></div>
              <div className="bk-row2"><button className="bk-btn" style={{ flex: 1 }} onClick={() => { setBiz({ ...biz, reqs: [...biz.reqs, { id: 'q' + Date.now(), band: 'Reserva anotada', sala: 'Sala Eco', when: 'vie 13 nov · 5:00 pm', st: 'conf' }] }); say('Reserva anotada') }}>Anotar una reserva</button><button className="bk-btn" style={{ flex: 1 }} onClick={() => setBiz({ ...biz, tab: 'reservas' })}>Ver todas</button></div>
              <div className="bk-sec">Por responder · {pend.length}</div>
              {pend.length === 0 && <div className="bk-help">Nada pendiente.</div>}
              {pend.map((r) => <div key={r.id} className="bk-card2"><b style={{ fontSize: 16 }}>{r.band}</b><div className="bk-li-s">{r.sala} · {r.when}</div><div className="bk-row2" style={{ marginTop: 8 }}><button className="bk-btn dng" style={{ flex: 1 }} onClick={() => upd(r.id, 'rech')}>Rechazar</button><button className="bk-btn pri" style={{ flex: 1 }} onClick={() => upd(r.id, 'conf')}>Confirmar</button></div></div>)}
            </>
          )}
          {biz.tab === 'reservas' && (
            <>
              <div><div className="bk-eye">Sala Eco</div><h1 className="bk-title">Reservas</h1></div>
              <div className="bk-card">{biz.reqs.map((r) => <div key={r.id} className="bk-check"><span style={{ flex: 1 }}><b>{r.band}</b><div className="bk-li-s" style={{ fontSize: 12.5 }}>{r.sala} · {r.when}</div></span><span className="bk-chip" style={r.st === 'conf' ? { color: 'var(--sage)', borderColor: 'var(--sage)' } : r.st === 'rech' ? { color: 'var(--ember)', borderColor: 'var(--ember)' } : { color: 'var(--amber)', borderColor: 'var(--amber)' }}>{r.st === 'conf' ? 'Confirmada' : r.st === 'rech' ? 'Rechazada' : 'Pendiente'}</span>{r.st === 'conf' && <button className="bk-btn sm dng" onClick={() => upd(r.id, 'rech')}>Cancelar</button>}</div>)}</div>
            </>
          )}
          {biz.tab === 'salas' && (<><div><div className="bk-eye">Tu negocio</div><h1 className="bk-title">Salas</h1></div>{ROOMS.map((r) => <div key={r.id} className="bk-card2"><b style={{ fontSize: 16 }}>{r.name}</b><div className="bk-li-s">{r.desc}</div></div>)}</>)}
          {biz.tab === 'perfil' && (<><div><div className="bk-eye">Tu negocio</div><h1 className="bk-title">Perfil</h1></div><div className="bk-card2"><b style={{ fontSize: 16 }}>Sala Eco</b><div className="bk-li-s">Cabecera, Bucaramanga · lunes a sábado de 2:00 pm a 10:00 pm · dirección de ejemplo</div></div></>)}
          {biz.tab === 'bandas' && (<><div><div className="bk-eye">Tus bandas</div><h1 className="bk-title">Mis bandas</h1></div><div className="bk-card2"><b style={{ fontSize: 16 }}>Cuerda Floja</b><div className="bk-li-s">4 integrantes</div></div><button className="bk-btn pri blk" onClick={() => { setMode('band'); setTab('home') }}>Volver a mi banda</button></>)}
        </div>
        <nav className="bk-tabs" style={{ gridTemplateColumns: 'repeat(5, 1fr)' }}>
          {tabs.map(([id, l, ic]) => <button key={id} className={`bk-tab ${biz.tab === id ? 'on' : ''}`} onClick={() => setBiz({ ...biz, tab: id })}><Ico n={ic} />{l}</button>)}
        </nav>
      </>
    )
  }

  const TABS = [['home', 'Inicio', 'home'], ['music', 'Música', 'music'], ['agenda', 'Agenda', 'cal'], ['learn', 'Aprender', 'grad'], ['comm', 'Comunidad', 'compass'], ['banda', 'Banda', 'users']]
  const badge = { comm: seen.comm ? 0 : 2, banda: seen.banda ? 0 : 1 }
  const body = { home: homeV, music: musicV, agenda: agendaV, learn: learnV, comm: commV, banda: bandaV }[tab]

  return (
    <div className="bk">
      {mode === 'biz' ? bizV() : (
        <>
          <div className="bk-bar"><span className="bk-mono-sq">CF</span><span className="bk-bandname">Cuerda Floja</span><svg viewBox="0 0 24 24" className="bk-ico bk-chev"><path d={P.chev} /></svg><span className="bk-me" aria-label="Tu perfil">AR</span></div>
          <div className="bk-main" key={tab + (view?.id ?? '')}>{body()}</div>
          {tab === 'agenda' && <button className="bk-fab" onClick={() => setSheet({ n: 'event' })}><Ico n="plus" />Nuevo evento</button>}
          <nav className="bk-tabs" style={{ gridTemplateColumns: 'repeat(6, 1fr)' }}>
            {TABS.map(([id, l, ic]) => <button key={id} className={`bk-tab ${tab === id ? 'on' : ''}`} onClick={() => go(id)} aria-current={tab === id ? 'page' : undefined}><Ico n={ic} />{l}{badge[id] > 0 && <span className="bk-nb">{badge[id]}</span>}</button>)}
          </nav>
        </>
      )}
      {sheetV()}
      {stage && <Stage songs={setSongsOf(stage.l)} setlist={stage.l} start={stage.start} onClose={() => setStage(null)} />}
      {toast && <div className="bk-toast" role="status">{toast}</div>}
    </div>
  )
}
