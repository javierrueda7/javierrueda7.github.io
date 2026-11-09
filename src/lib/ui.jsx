import { useCallback, useRef, useState } from 'react'

const P = {
  home: 'M3 11l9-8 9 8M5 10v10h5v-6h4v6h5V10',
  ball: 'M12 3a9 9 0 100 18 9 9 0 000-18zm0 5l3 2-1 4h-4l-1-4 3-2z',
  users: 'M16 11a3 3 0 100-6M8 11a3 3 0 100-6M2 20c0-3 3-5 6-5s6 2 6 5M16 15c3 0 6 2 6 5',
  pin: 'M12 21s7-6 7-11a7 7 0 10-14 0c0 5 7 11 7 11zm0-8a3 3 0 100-6 3 3 0 000 6z',
  chart: 'M4 20V10M10 20V4M16 20v-8M22 20H2',
  music: 'M9 18V5l11-2v13M9 18a3 3 0 11-6 0 3 3 0 016 0zm11-2a3 3 0 11-6 0 3 3 0 016 0z',
  list: 'M8 6h13M8 12h13M8 18h13M3 6h.01M3 12h.01M3 18h.01',
  cal: 'M4 7h16v13H4zM4 11h16M8 3v4M16 3v4',
  mic: 'M12 15a3 3 0 003-3V6a3 3 0 00-6 0v6a3 3 0 003 3zm-6-3a6 6 0 0012 0M12 18v3',
  clock: 'M12 3a9 9 0 100 18 9 9 0 000-18zm0 5v5l3 2',
  cash: 'M3 7h18v10H3zM12 9.5a2.5 2.5 0 100 5 2.5 2.5 0 000-5z',
  store: 'M4 9l1-5h14l1 5M4 9v11h16V9M4 9a3 3 0 006 0 3 3 0 006 0 3 3 0 004 0',
}

export function Icon({ name }) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
      <path d={P[name]} />
    </svg>
  )
}

export function TabBar({ tabs, value, onChange }) {
  return (
    <div className="tabbar" role="tablist">
      {tabs.map((t) => (
        <button key={t.id} role="tab" aria-selected={value === t.id} className={value === t.id ? 'on' : ''} onClick={() => onChange(t.id)}>
          <Icon name={t.icon} />
          {t.label}
        </button>
      ))}
    </div>
  )
}

export function useToast() {
  const [msg, setMsg] = useState('')
  const timer = useRef()
  const show = useCallback((m) => {
    setMsg(m)
    clearTimeout(timer.current)
    timer.current = setTimeout(() => setMsg(''), 2200)
  }, [])
  const node = msg ? <div className="toast" role="status">{msg}</div> : null
  return [show, node]
}

export const cop = (n) => '$' + Math.round(n).toLocaleString('es-CO')
