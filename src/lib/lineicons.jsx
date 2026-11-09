// Iconos de trazo (estilo Lucide) compartidos por los simuladores de escritorio.
const P = {
  home: 'M3 11l9-8 9 8M5 10v10h5v-6h4v6h5V10',
  receipt: 'M5 3h14v18l-3-2-2 2-2-2-2 2-2-2-3 2zM9 8h6M9 12h6',
  folder: 'M3 6a2 2 0 012-2h4l2 2h8a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2z',
  bars: 'M4 20V10M10 20V4M16 20v-8M22 20H2',
  wallet: 'M3 7a2 2 0 012-2h13v4M3 7v11a2 2 0 002 2h15V9H5a2 2 0 01-2-2zM16 14.5h.01',
  clip: 'M9 4h6v3H9zM7 5H5v16h14V5h-2M9 14l2 2 4-4',
  layout: 'M3 3h8v10H3zM13 3h8v6h-8zM13 11h8v10h-8zM3 15h8v6H3z',
  plus: 'M12 5v14M5 12h14',
  search: 'M11 4a7 7 0 100 14 7 7 0 000-14zM21 21l-5-5',
  logout: 'M9 4H5v16h4M16 8l4 4-4 4M20 12H9',
  login: 'M15 4h4v16h-4M8 8l4 4-4 4M12 12H3',
  menu: 'M4 6h16M4 12h16M4 18h16',
  x: 'M6 6l12 12M18 6L6 18',
  right: 'M9 6l6 6-6 6',
  left: 'M15 6l-6 6 6 6',
  down: 'M6 9l6 6 6-6',
  up: 'M6 15l6-6 6 6',
  download: 'M12 4v11M7 11l5 5 5-5M5 20h14',
  sparkle: 'M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8zM19 17l.7 1.8L21.5 19.5l-1.8.7L19 22l-.7-1.8-1.8-.7 1.8-.7z',
  file: 'M14 3H6v18h12V7zM14 3v4h4M9 13h6M9 17h6',
  upload: 'M12 16V4M7 9l5-5 5 5M5 20h14',
  trash: 'M4 7h16M10 11v6M14 11v6M6 7l1 13h10l1-13M9 7V4h6v3',
  edit: 'M4 20h4L19 9l-4-4L4 16zM13 7l4 4',
  eye: 'M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12zM12 9a3 3 0 100 6 3 3 0 000-6z',
  map: 'M9 4L3 6v14l6-2 6 2 6-2V4l-6 2zM9 4v14M15 6v14',
  users: 'M16 11a3 3 0 100-6M8 11a3 3 0 100-6M2 20c0-3 3-5 6-5s6 2 6 5M16 15c3 0 6 2 6 5',
  user: 'M12 12a4 4 0 100-8 4 4 0 000 8zm-8 9c0-4 4-6 8-6s8 2 8 6',
  lock: 'M6 11h12v9H6zM8 11V8a4 4 0 018 0v3',
  cash: 'M3 7h18v10H3zM12 9.5a2.5 2.5 0 100 5 2.5 2.5 0 000-5z',
  sign: 'M4 20h16M5 16l8-8 3 3-8 8H5zM14 7l2-2 3 3-2 2',
  check: 'M5 12l5 5 9-10',
  alert: 'M12 4l9 16H3zM12 10v4M12 17h.01',
  gear: 'M12 9a3 3 0 100 6 3 3 0 000-6zM19 12l2-1-1-3-2 .5-1.5-1.5.5-2-3-1-1 2h-2l-1-2-3 1 .5 2L6.5 8.5 4.5 8 3.5 11l2 1v0l-2 1 1 3 2-.5L8 17.5 7.5 19.5l3 1 1-2h2l1 2 3-1-.5-2 1.5-1.5 2 .5 1-3z',
  list: 'M8 6h13M8 12h13M8 18h13M3 6h.01M3 12h.01M3 18h.01',
  assign: 'M9 4h6v3H9zM7 5H5v16h14V5h-2M9 12h6M9 16h6',
  edit2: 'M5 5h14v14H5zM9 9h6M9 13h4',
  chart: 'M4 20h16M7 16V10M12 16V6M17 16v-4',
  send: 'M4 12l16-8-6 16-3-7z',
  bell: 'M6 16V11a6 6 0 0112 0v5l2 2H4zM10 21h4',
  copy: 'M9 9h11v11H9zM5 15V4h11',
  filter: 'M3 5h18l-7 8v6l-4-2v-4z',
  image: 'M3 5h18v14H3zM3 16l5-5 4 4 3-3 6 6M9 9h.01',
  minus: 'M5 12h14',
}

export function LI({ n, size = 18, sw = 1.9 }) {
  return (
    <svg viewBox="0 0 24 24" width={size} height={size} fill="none" stroke="currentColor" strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" aria-hidden="true" style={{ flex: 'none' }}>
      <path d={P[n]} />
    </svg>
  )
}
