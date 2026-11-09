import { useEffect, useRef, useState } from 'react'
import { TabBar, useToast } from '../lib/ui.jsx'

// Canciones inventadas para la demo (letras originales, cortas).
const SONGS = [
  { id: 'a', title: 'Páramo', key: 'Am', bpm: 96, tuning: 'Estándar', lines: ['[Am]Subimos al páramo sin [F]mapa', '[C]solo el viento nos [G]guía', '[Am]cada paso es una [F]promesa', '[C]que no se [G]termina [Am]hoy'] },
  { id: 'b', title: 'Camino de herradura', key: 'Em', bpm: 120, tuning: 'Drop D', lines: ['[Em]Polvo en las botas y [C]sol', '[G]la tarde se cae des[D]pacio', '[Em]traigo la guitarra al [C]hombro', '[G]y el pueblo me [D]canta [Em]atrás'] },
  { id: 'c', title: 'Última función', key: 'D', bpm: 84, tuning: 'Estándar', lines: ['[D]Se apagan las luces del [A]teatro', '[Bm]queda un eco en la [G]sala', '[D]dime si volvemos ma[A]ñana', '[G]o si esto fue [A]todo, [D]nada'] },
  { id: 'd', title: 'Ruido blanco', key: 'Gm', bpm: 140, tuning: 'Drop D', lines: ['[Gm]Prende el amplificador, [Eb]que el barrio despierte', '[Bb]que tiemblen los vidrios [F]de la avenida', '[Gm]somos ruido, somos [Eb]fuego', '[Bb]somos lo que [F]queda [Gm]vivo'] },
  { id: 'e', title: 'Casa en el cerro', key: 'C', bpm: 76, tuning: 'Estándar', lines: ['[C]Hay una casa en el [Am]cerro', '[F]con la ventana al [G]sur', '[C]allí guardé mis canciones', '[F]y la [G]llave [C]azul'] },
]

const SHARP = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
const FLAT = { Db: 'C#', Eb: 'D#', Gb: 'F#', Ab: 'G#', Bb: 'A#' }
function tr(chord, n) {
  return chord.replace(/([A-G][#b]?)/g, (m) => {
    const i = SHARP.indexOf(FLAT[m] ?? m)
    return i < 0 ? m : SHARP[(i + n + 120) % 12]
  })
}

function Chart({ song, semis, size }) {
  return (
    <div style={{ fontSize: size, lineHeight: 2.3 }}>
      {song.lines.map((ln, i) => (
        <div key={i}>
          {ln.split(/(\[[^\]]+\])/).filter(Boolean).reduce((acc, part) => {
            if (part.startsWith('[')) acc.push({ c: tr(part.slice(1, -1), semis), t: '' })
            else if (acc.length && acc[acc.length - 1].t === '') acc[acc.length - 1].t = part
            else acc.push({ c: '', t: part })
            return acc
          }, []).map((seg, j) => (
            <span key={j} style={{ display: 'inline-block', position: 'relative', whiteSpace: 'pre' }}>
              <b style={{ position: 'absolute', top: '-1.25em', left: 0, color: '#ff8a5c', fontSize: '0.85em' }}>{seg.c}</b>
              {seg.t || ' '}
            </span>
          ))}
        </div>
      ))}
    </div>
  )
}

function useMetronome(bpm) {
  const [on, setOn] = useState(false)
  const [beat, setBeat] = useState(0)
  const ctx = useRef(null)
  useEffect(() => {
    if (!on) return
    ctx.current ??= new (window.AudioContext || window.webkitAudioContext)()
    const ac = ctx.current
    let n = 0
    const click = () => {
      const o = ac.createOscillator()
      const g = ac.createGain()
      o.frequency.value = n % 4 === 0 ? 1200 : 800
      g.gain.setValueAtTime(0.25, ac.currentTime)
      g.gain.exponentialRampToValueAtTime(0.0001, ac.currentTime + 0.06)
      o.connect(g).connect(ac.destination)
      o.start()
      o.stop(ac.currentTime + 0.07)
      setBeat(n % 4)
      n++
    }
    click()
    const id = setInterval(click, 60000 / bpm)
    return () => clearInterval(id)
  }, [on, bpm])
  return [on, setOn, beat]
}

function Stage({ song, onClose }) {
  const [semis, setSemis] = useState(0)
  const [size, setSize] = useState(17)
  const [auto, setAuto] = useState(false)
  const [on, setOn, beat] = useMetronome(song.bpm)
  const box = useRef(null)
  useEffect(() => {
    if (!auto) return
    const id = setInterval(() => { box.current && (box.current.scrollTop += 1) }, 40)
    return () => clearInterval(id)
  }, [auto])
  const btn = { border: '1px solid #444', background: '#1d1d1d', color: '#eee', borderRadius: 8, padding: '6px 10px', fontSize: 12 }
  return (
    <div style={{ position: 'absolute', inset: 0, background: '#0b0b0b', color: '#f2f2f2', display: 'flex', flexDirection: 'column', zIndex: 10 }}>
      <div className="row" style={{ padding: '40px 14px 8px' }}>
        <div><strong style={{ fontFamily: 'Sora', fontSize: 18 }}>{song.title}</strong><div style={{ fontSize: 12, color: '#999' }}>{tr(song.key, semis)} · {song.bpm} BPM · {song.tuning}</div></div>
        <button style={btn} onClick={onClose}>Salir</button>
      </div>
      <div ref={box} style={{ flex: 1, overflowY: 'auto', padding: '26px 14px 120px' }}><Chart song={song} semis={semis} size={size} /></div>
      <div style={{ padding: 10, borderTop: '1px solid #262626', display: 'grid', gap: 8, background: '#111' }}>
        <div className="row">
          <span style={{ fontSize: 12, color: '#999' }}>Tono</span>
          <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
            <button style={btn} aria-label="Bajar un semitono" onClick={() => setSemis((s) => s - 1)}>−</button>
            <span style={{ width: 28, textAlign: 'center' }}>{semis > 0 ? `+${semis}` : semis}</span>
            <button style={btn} aria-label="Subir un semitono" onClick={() => setSemis((s) => s + 1)}>+</button>
          </div>
          <span style={{ fontSize: 12, color: '#999' }}>Letra</span>
          <div style={{ display: 'flex', gap: 6 }}>
            <button style={btn} aria-label="Letra más pequeña" onClick={() => setSize((s) => Math.max(13, s - 2))}>A−</button>
            <button style={btn} aria-label="Letra más grande" onClick={() => setSize((s) => Math.min(30, s + 2))}>A+</button>
          </div>
        </div>
        <div className="row">
          <button style={{ ...btn, background: auto ? '#d9482b' : '#1d1d1d' }} onClick={() => setAuto(!auto)}>Autoscroll {auto ? 'on' : 'off'}</button>
          <button style={{ ...btn, background: on ? '#d9482b' : '#1d1d1d' }} onClick={() => setOn(!on)}>
            Metrónomo {on ? 'on' : 'off'}
          </button>
          <div style={{ display: 'flex', gap: 4 }} aria-hidden="true">{[0, 1, 2, 3].map((i) => <span key={i} style={{ width: 10, height: 10, borderRadius: '50%', background: on && beat === i ? '#d9482b' : '#333' }} />)}</div>
        </div>
      </div>
    </div>
  )
}

const EVENTS = [
  { id: 'e1', kind: 'Ensayo', title: 'Ensayo general', when: 'Jue 19 · 7:00 pm', place: 'Ensayadero La Caverna', going: { 'Tú': null, 'Lina': true, 'Mauro': true, 'Pipe': false } },
  { id: 'e2', kind: 'Toque', title: 'Toque en el Bar Oasis', when: 'Sáb 28 · 9:00 pm', place: 'Bar Oasis, Cabecera', going: { 'Tú': true, 'Lina': true, 'Mauro': null, 'Pipe': null } },
]

export default function Backline() {
  const [tab, setTab] = useState('rep')
  const [order, setOrder] = useState(['a', 'c', 'b', 'd', 'e'])
  const [events, setEvents] = useState(EVENTS)
  const [stage, setStage] = useState(null)
  const [toast, toastNode] = useToast()
  const [q, setQ] = useState('')
  const by = (id) => SONGS.find((s) => s.id === id)
  const move = (i, d) => setOrder((o) => { const n = [...o]; const j = i + d; if (j < 0 || j >= n.length) return o; [n[i], n[j]] = [n[j], n[i]]; return n })
  const rsvp = (id, v) => { setEvents((es) => es.map((e) => e.id === id ? { ...e, going: { ...e.going, Tú: v } } : e)); toast(v ? 'Confirmaste asistencia' : 'Marcaste que no vas') }
  const mins = Math.round(order.reduce((s, id) => s + 3.6, 0))
  const tabs = [
    { id: 'rep', label: 'Repertorio', icon: 'music' },
    { id: 'set', label: 'Setlist', icon: 'list' },
    { id: 'cal', label: 'Agenda', icon: 'cal' },
  ]
  const list = SONGS.filter((s) => s.title.toLowerCase().includes(q.toLowerCase()))

  return (
    <div className="app">
      <div className="app-top"><h3>Los Cafres del Páramo</h3><small>banda de ejemplo</small></div>
      <div className="app-body">
        {tab === 'rep' && (
          <>
            <input aria-label="Buscar canción" placeholder="Buscar canción…" value={q} onChange={(e) => setQ(e.target.value)} style={{ border: '1px solid #d6d6d0', borderRadius: 8, padding: 8 }} />
            {list.length === 0 && <div className="empty">Ninguna canción coincide.</div>}
            {list.map((s) => (
              <div key={s.id} className="card row">
                <div><strong>{s.title}</strong><div className="sub">{s.key} · {s.bpm} BPM · {s.tuning}</div></div>
                <button className="sbtn sm" onClick={() => setStage(s)}>Tocar</button>
              </div>
            ))}
          </>
        )}
        {tab === 'set' && (
          <>
            <div className="row"><div className="h">Toque Bar Oasis</div><span className="pill">{order.length} temas · ~{mins} min</span></div>
            {order.map((id, i) => (
              <div key={id} className="card row">
                <div><span className="sub">{i + 1}.</span> <strong>{by(id).title}</strong><div className="sub">{by(id).key} · {by(id).bpm} BPM</div></div>
                <div style={{ display: 'flex', gap: 4 }}>
                  <button className="sbtn ghost sm" aria-label={`Subir ${by(id).title}`} disabled={i === 0} onClick={() => move(i, -1)}>↑</button>
                  <button className="sbtn ghost sm" aria-label={`Bajar ${by(id).title}`} disabled={i === order.length - 1} onClick={() => move(i, 1)}>↓</button>
                </div>
              </div>
            ))}
            <button className="sbtn" onClick={() => setStage(by(order[0]))}>Abrir modo escenario</button>
          </>
        )}
        {tab === 'cal' && events.map((e) => (
          <div key={e.id} className="card">
            <div className="row"><strong>{e.title}</strong><span className={`pill ${e.kind === 'Toque' ? 'warn' : ''}`}>{e.kind}</span></div>
            <div className="sub">{e.when} · {e.place}</div>
            <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap', margin: '8px 0' }}>
              {Object.entries(e.going).map(([n, v]) => <span key={n} className={`pill ${v === true ? 'ok' : ''}`}>{n}: {v === true ? 'va' : v === false ? 'no va' : '¿?'}</span>)}
            </div>
            <div className="row" style={{ justifyContent: 'flex-start' }}>
              <button className={`sbtn sm ${e.going.Tú === true ? '' : 'ghost'}`} onClick={() => rsvp(e.id, true)}>Voy</button>
              <button className={`sbtn sm ${e.going.Tú === false ? '' : 'ghost'}`} onClick={() => rsvp(e.id, false)}>No voy</button>
            </div>
          </div>
        ))}
      </div>
      {toastNode}
      <TabBar tabs={tabs} value={tab} onChange={setTab} />
      {stage && <Stage song={stage} onClose={() => setStage(null)} />}
    </div>
  )
}
