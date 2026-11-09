import { useEffect, useRef, useState } from 'react'
import './menu.css'

// Menú digital (Flutter, Material 3). Negocios, platos y pedidos son inventados.
// Cada negocio usa un estilo con su color semilla y sus textos, como la app real.
const STYLES = {
  costeno: {
    seed: '#00838F', pt: '#00656e', sc: '#cde8ec', bg: '#f5fbfb', card: '#ecf3f4', hue: 190,
    tipo: '¿Cómo te provoca el pedido?', mesa: '¿En cuál mesa te acomodamos?', confirm: '¡Dale, confirmar pedido!', sent: '¡Listo! Tu pedido ya va pa\' la cocina.',
  },
  santandereano: {
    seed: '#8D6E3A', pt: '#74561f', sc: '#f2dfc0', bg: '#fffaf3', card: '#f6ece1', hue: 35,
    tipo: '¿Cómo va a ser el pedido?', mesa: '¿En qué mesa lo sentamos?', confirm: 'De una, confirmar pedido', sent: 'Pedido enviado a cocina, ya se lo alistamos.',
  },
  elegante: {
    seed: '#9C7A32', pt: '#7a5b14', sc: '#f6e0b6', bg: '#fff8f1', card: '#faeee0', hue: 40,
    tipo: '¿Cómo desea recibir su pedido?', mesa: 'Seleccione su mesa', confirm: 'Confirmar pedido', sent: 'Su pedido fue enviado a cocina.',
  },
  casual: {
    seed: '#2E7D32', pt: '#1f6a24', sc: '#cfe9ca', bg: '#f7fbf2', card: '#ebf1e6', hue: 110,
    tipo: '¿Cómo quieres tu pedido?', mesa: 'Elige tu mesa', confirm: 'Confirmar pedido', sent: 'Pedido enviado a cocina',
  },
}

const BUSINESSES = [
  {
    id: 'demo-costeno', name: 'La Terraza del Mar', kind: 'Restaurante costeño', style: 'costeno',
    cats: [
      ['Entradas', [['Ceviche de camarón', 'Camarón fresco, limón, cebolla morada y cilantro', 22000]]],
      ['Platos principales', [['Arroz con coco y camarones', 'Arroz titoté con camarones al ajillo', 30000], ['Pescado frito con patacón', 'Mojarra entera con patacón y ensalada', 34000]]],
      ['Bebidas', [['Limonada de coco', 'Limón, crema de coco y hielo', 8000]]],
      ['Postres', [['Cocadas', 'Dulce de coco rallado y panela', 6000]]],
    ],
  },
  {
    id: 'demo-santandereano', name: 'Fogón Santandereano', kind: 'Restaurante santandereano', style: 'santandereano',
    cats: [
      ['Entradas', [['Arepa santandereana', 'Arepa de maíz pelado con queso campesino', 9000]]],
      ['Platos principales', [['Mute santandereano', 'Sopa de maíz y carnes con papa y yuca', 22000], ['Carne oreada', 'Carne secada al sol con yuca y arepa', 30000]]],
      ['Bebidas', [['Masato', 'Bebida de arroz fermentada, servida fría', 6000]]],
      ['Postres', [['Bocadillo con queso', 'Bocadillo veleño con queso fresco', 7000]]],
    ],
  },
  {
    id: 'demo-elegante', name: 'Casa Alta', kind: 'Restaurante de autor', style: 'elegante',
    cats: [
      ['Entradas', [['Carpaccio de res', 'Láminas finas de res, parmesano y rúgula', 38000]]],
      ['Platos principales', [['Risotto de champiñones', 'Arroz arborio, champiñones y mantequilla', 42000], ['Solomo a la pimienta', 'Solomo a la parrilla con salsa de pimienta', 58000]]],
      ['Bebidas', [['Copa de vino', 'Tinto de la casa, 150 ml', 25000]]],
      ['Postres', [['Crème brûlée', 'Crema de vainilla con costra de azúcar', 18000]]],
    ],
  },
  {
    id: 'demo-business', name: 'Sabores del Barrio', kind: 'Restaurante casual', style: 'casual',
    cats: [
      ['Entradas', [['Empanadas colombianas (x4)', 'Cuatro empanadas de carne con ají', 12000], ['Patacones con hogao', 'Plátano verde frito con hogao casero', 14000]]],
      ['Platos fuertes', [['Bandeja paisa', 'Frijoles, arroz, chicharrón, carne, huevo y arepa', 32000], ['Ajiaco santafereño', 'Sopa de papas con pollo, mazorca y alcaparras', 28000]]],
      ['Bebidas', [['Gaseosa 400ml', 'Botella personal bien fría', 5000], ['Jugo de lulo', 'Lulo natural en agua o leche', 7000]]],
      ['Postres', [['Obleas con arequipe', 'Obleas crocantes con arequipe y queso', 8000]]],
    ],
  },
  {
    id: 'demo-cafeteria', name: 'Café de la Esquina', kind: 'Cafetería', style: 'casual',
    cats: [
      ['Cafés', [['Tinto', 'Café filtrado, taza de 8 oz', 3000], ['Café con leche', 'Café con leche caliente espumada', 5000], ['Chocolate santafereño', 'Chocolate espeso para acompañar con queso', 9000]]],
      ['Panadería', [['Pan de bono', 'Horneado cada mañana', 3500], ['Croissant', 'Mantequilla y hojaldre, tibio', 6000]]],
      ['Bebidas frías', [['Jugo natural', 'Fruta del día en agua o leche', 6000]]],
      ['Snacks', []],
    ],
  },
  {
    id: 'demo-cafe-especializado', name: 'Origen', kind: 'Café especializado', style: 'elegante',
    cats: [
      ['Espresso', [['Espresso', 'Doble, de finca de Huila', 5000], ['Cappuccino', 'Espresso con leche vaporizada', 8000]]],
      ['Filtrados', [['V60', 'Café de origen preparado a mano', 9000]]],
      ['Fríos', [['Cold brew', 'Extracción en frío de 18 horas', 9000]]],
      ['Postres', [['Torta de especialidad', 'Porción de torta de la semana', 11000]]],
    ],
  },
  {
    id: 'demo-bar', name: 'El Rincón', kind: 'Bar', style: 'casual',
    cats: [
      ['Cervezas', [['Cerveza artesanal', 'Línea local, botella 330ml', 12000]]],
      ['Cócteles', [['Mojito', 'Ron, hierbabuena, limón y soda', 20000], ['Margarita', 'Tequila, triple sec y limón', 22000]]],
      ['Piqueo', [['Picada surtida', 'Carnes, chorizo, papa criolla y arepa', 45000], ['Alitas BBQ', 'Doce alitas con salsa BBQ', 25000]]],
      ['Licores', [['Shot de tequila', 'Con sal y limón', 10000]]],
    ],
  },
]
BUSINESSES.forEach((b) => {
  let n = 0
  b.items = []
  b.cats.forEach(([, list], ci) => list.forEach(([name, desc, price]) => b.items.push({ id: `${b.id}-${n++}`, name, desc, price, cat: ci })))
})

const STAGES = ['Pendiente', 'En preparación', 'Listo', 'Entregado']
const PIN = '1234'

const P = {
  back: 'M19 12H5m6-6l-6 6 6 6',
  cart: 'M3 4h2l2.4 10.2a1 1 0 001 .8h8.9a1 1 0 001-.8L20 8H6M9.5 19.5h.01M17 19.5h.01',
  kitchen: 'M4 13h16a0 0 0 010 0 8 8 0 01-8 8 8 8 0 01-8-8zM9 4c-1 1.3 1 2 0 3.5M13 4c-1 1.3 1 2 0 3.5M20 13l1.5-2.5',
  chev: 'M9 6l6 6-6 6',
  delivery: 'M5 18.5a2.5 2.5 0 100-5 2.5 2.5 0 000 5zM19 18.5a2.5 2.5 0 100-5 2.5 2.5 0 000 5zM7.5 16h6l2-6h3M13 7h3M6 8h4l1 4',
  bag: 'M5 8h14l-1 12H6L5 8zM9 8V6a3 3 0 016 0v2',
  fork: 'M7 3v7a2 2 0 002 2v9M7 3v5M11 3v5M11 8a2 2 0 01-2 2M17 21V3c-2 1.5-3 4-3 7v3h3',
  plus: 'M12 8v8M8 12h8',
  minus: 'M8 12h8',
  trash: 'M5 7h14M9 7V4h6v3M7 7l1 13h8l1-13M10 11v6M14 11v6',
  check: 'M5 12.5l4.5 4.5L19 7.5',
  receipt: 'M6 3h12v18l-3-2-3 2-3-2-3 2V3zM9 8h6M9 12h6',
  table: 'M4 7h16M12 7v13M8 20h8M6 7l1.2 3.5h9.6L18 7',
  store: 'M4 9l1.5-5h13L20 9M4 9v11h16V9M4 9a2.7 2.7 0 005.3 0 2.7 2.7 0 005.4 0A2.7 2.7 0 0020 9M10 20v-5h4v5',
}
const Ic = ({ n, c = '', s }) => (
  <svg className={`mn-ic ${c}`} viewBox="0 0 24 24" aria-hidden="true" style={s ? { width: s, height: s } : undefined}><path d={P[n]} /></svg>
)
const cop = (n) => `${String(n).replace(/\B(?=(\d{3})+(?!\d))/g, '.')} $`
const hhmm = (d) => `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`

function Thumb({ item, hue }) {
  const h = (hue + item.name.length * 17 + item.cat * 23) % 360
  return (
    <span className="mn-thumb" style={{ background: `linear-gradient(135deg, hsl(${h} 45% 62%), hsl(${(h + 40) % 360} 50% 36%))` }} aria-hidden="true">
      <span>{item.name[0]}</span>
    </span>
  )
}

export default function Menu() {
  const [bizId, setBizId] = useState('demo-costeno')
  const [stack, setStack] = useState(['tipo'])
  const [mode, setMode] = useState(null)
  const [table, setTable] = useState(null)
  const [cart, setCart] = useState({})
  const [cat, setCat] = useState('all')
  const [orders, setOrders] = useState([])
  const [pin, setPin] = useState('')
  const [snack, setSnack] = useState('')
  const [tab, setTab] = useState('pedidos')
  const [stage, setStage] = useState(0)
  const nextId = useRef(1)
  const timer = useRef(null)

  const biz = BUSINESSES.find((b) => b.id === bizId)
  const st = STYLES[biz.style]
  const screen = stack[stack.length - 1]
  const push = (s) => setStack((a) => [...a, s])
  const pop = () => setStack((a) => (a.length > 1 ? a.slice(0, -1) : a))
  const replace = (s) => setStack((a) => [...a.slice(0, -1), s])
  const toast = (t) => { setSnack(t); clearTimeout(timer.current); timer.current = setTimeout(() => setSnack(''), 3500) }
  useEffect(() => () => clearTimeout(timer.current), [])

  const changeBiz = (id) => {
    setBizId(id); setStack(['tipo']); setMode(null); setTable(null); setCart({}); setCat('all'); setPin(''); setSnack(''); setTab('pedidos'); setStage(0)
  }
  const lines = biz.items.filter((i) => cart[i.id] > 0)
  const count = lines.reduce((s, i) => s + cart[i.id], 0)
  const total = lines.reduce((s, i) => s + cart[i.id] * i.price, 0)
  const add = (id, d) => setCart((c) => { const q = Math.max(0, (c[id] || 0) + d); const n = { ...c }; if (q) n[id] = q; else delete n[id]; return n })
  const modeLabel = mode === 'mesa' ? `Mesa ${table}` : mode === 'domicilio' ? 'Domicilio' : 'Para llevar'

  const confirm = () => {
    if (!lines.length) return
    const o = {
      id: nextId.current++, biz: bizId, mode, table, at: new Date(), stage: 0, closed: false,
      lines: lines.map((i) => ({ name: i.name, q: cart[i.id], price: i.price })), total,
    }
    setOrders((l) => [...l, o])
    setCart({})
    toast(`${st.sent}${mode === 'mesa' ? ' La mesa sigue abierta.' : ''}`)
    pop()
  }
  const advance = (id) => setOrders((l) => l.map((o) => (o.id === id ? { ...o, stage: Math.min(3, o.stage + 1) } : o)))
  const bizOrders = orders.filter((o) => o.biz === bizId)
  const openTables = [...new Set(bizOrders.filter((o) => o.mode === 'mesa' && !o.closed).map((o) => o.table))].sort((a, b) => a - b)
  const closeTable = (n) => setOrders((l) => l.map((o) => (o.biz === bizId && o.mode === 'mesa' && o.table === n ? { ...o, closed: true } : o)))
  const submitPin = (e) => {
    e.preventDefault()
    if (pin === PIN) { setPin(''); replace('staff') } else { setPin(''); toast('PIN incorrecto') }
  }

  const title = { tipo: st.tipo, mesas: st.tipo, home: biz.name, catalogo: 'Catálogo', carrito: 'Tu pedido', pin: 'Panel de cocina', staff: tab === 'mesas' ? 'Mesas' : 'Panel de cocina' }[screen]
  const showCart = screen === 'home' || screen === 'catalogo'

  return (
    <div className="mn-root">
      <div className="mn-bar">
        <label htmlFor="mn-biz">Negocio demo</label>
        <select id="mn-biz" value={bizId} onChange={(e) => changeBiz(e.target.value)}>
          {BUSINESSES.map((b) => <option key={b.id} value={b.id}>{b.name} · {b.kind}</option>)}
        </select>
      </div>
      <div className="mn-stage">
        <div
          className="mn-app"
          style={{ '--p': st.seed, '--pt': st.pt, '--sc': st.sc, '--bg': st.bg, '--card': st.card }}
        >
          <header className="mn-appbar">
            {stack.length > 1 && <button className="mn-ibtn" aria-label="Volver" onClick={pop}><Ic n="back" /></button>}
            <h1 className="mn-title" style={stack.length === 1 ? { paddingLeft: 16 } : undefined}>{title}</h1>
            {screen === 'home' && <button className="mn-ibtn" aria-label="Panel de cocina" title="Panel de cocina" onClick={() => push('pin')}><Ic n="kitchen" /></button>}
            {showCart && (
              <button className="mn-ibtn" aria-label="Carrito" onClick={() => push('carrito')}>
                <Ic n="cart" />
                {count > 0 && <span className="mn-badge" data-testid="badge">{count}</span>}
              </button>
            )}
          </header>
          {screen === 'carrito' && mode && <div className="mn-sub">{modeLabel}</div>}

          <div className="mn-body">
            {screen === 'tipo' && (
              <div className="mn-pad">
                {[['delivery', 'Domicilio', 'domicilio'], ['bag', 'Para llevar', 'llevar'], ['fork', 'Comer en el restaurante', 'mesa']].map(([ic, label, m]) => (
                  <button key={m} className="mn-card mn-tile" onClick={() => { setMode(m); if (m === 'mesa') push('mesas'); else { setTable(null); setStack(['home']) } }}>
                    <Ic n={ic} c="lead" /><span>{label}</span><Ic n="chev" c="trail" />
                  </button>
                ))}
              </div>
            )}
            {screen === 'mesas' && (
              <div className="mn-pad">
                <p className="mn-lead">{st.mesa}</p>
                <div className="mn-tables">
                  {[1, 2, 3, 4, 5, 6].map((n) => (
                    <button key={n} className="mn-table" onClick={() => { setTable(n); setStack(['home']) }}>Mesa {n}</button>
                  ))}
                </div>
              </div>
            )}
            {screen === 'home' && (
              <div className="mn-pad">
                <div className="mn-logo" aria-hidden="true"><Ic n="store" s={56} /></div>
                <h2 className="mn-h2">Categorías</h2>
                {biz.cats.map(([c], ci) => (
                  <button key={c} className="mn-card mn-tile mn-cat" onClick={() => { setCat(ci); push('catalogo') }}>
                    <span>{c}</span><Ic n="chev" c="trail" />
                  </button>
                ))}
              </div>
            )}
            {screen === 'catalogo' && (
              <>
                <div className="mn-chips">
                  <button className={`mn-chip ${cat === 'all' ? 'on' : ''}`} onClick={() => setCat('all')}>{cat === 'all' && <Ic n="check" c="ck" />}Todas</button>
                  {biz.cats.map(([c], ci) => (
                    <button key={c} className={`mn-chip ${cat === ci ? 'on' : ''}`} onClick={() => setCat(ci)}>{cat === ci && <Ic n="check" c="ck" />}{c}</button>
                  ))}
                </div>
                <div className="mn-list">
                  {biz.items.filter((i) => cat === 'all' || i.cat === cat).map((i) => (
                    <div key={i.id} className="mn-card mn-item">
                      <Thumb item={i} hue={st.hue} />
                      <div className="mn-info">
                        <b>{i.name}</b>
                        <span>{i.desc}</span>
                        <strong>{cop(i.price)}</strong>
                      </div>
                      {cart[i.id] > 0 ? (
                        <div className="mn-qty">
                          <button aria-label={`Quitar ${i.name}`} onClick={() => add(i.id, -1)}><Ic n="minus" c="ring" /></button>
                          <span>{cart[i.id]}</span>
                          <button aria-label={`Agregar ${i.name}`} onClick={() => add(i.id, 1)}><Ic n="plus" c="ring" /></button>
                        </div>
                      ) : (
                        <button className="mn-add" aria-label={`Agregar ${i.name}`} onClick={() => add(i.id, 1)}><Ic n="plus" c="solid" /></button>
                      )}
                    </div>
                  ))}
                  {biz.items.filter((i) => cat === 'all' || i.cat === cat).length === 0 && <p className="mn-empty">No hay productos en esta categoría</p>}
                </div>
              </>
            )}
            {screen === 'carrito' && (
              <>
                <div className="mn-list grow">
                  {lines.length === 0 && <p className="mn-empty">El carrito está vacío</p>}
                  {lines.map((i) => (
                    <div key={i.id} className="mn-card mn-line">
                      <div className="mn-info"><b>{i.name}</b><span>{cop(i.price)} c/u</span></div>
                      <div className="mn-qty">
                        <button aria-label={`Quitar ${i.name}`} onClick={() => add(i.id, -1)}><Ic n="minus" c="ring" /></button>
                        <span>{cart[i.id]}</span>
                        <button aria-label={`Agregar ${i.name}`} onClick={() => add(i.id, 1)}><Ic n="plus" c="ring" /></button>
                        <button aria-label={`Eliminar ${i.name}`} onClick={() => add(i.id, -cart[i.id])}><Ic n="trash" c="del" /></button>
                      </div>
                    </div>
                  ))}
                </div>
                <div className="mn-foot">
                  <div className="mn-total"><span>Total</span><b>{cop(total)}</b></div>
                  <button className="mn-cta" disabled={!lines.length} onClick={confirm}><Ic n="check" c="ctaic" />{st.confirm}</button>
                </div>
              </>
            )}
            {screen === 'pin' && (
              <form className="mn-pin" onSubmit={submitPin}>
                <p>Ingresa el PIN del negocio</p>
                <input type="password" inputMode="numeric" aria-label="PIN del negocio" value={pin} onChange={(e) => setPin(e.target.value)} autoComplete="off" />
                <button className="mn-tonal">Ingresar</button>
              </form>
            )}
            {screen === 'staff' && (
              <>
                {tab === 'pedidos' && (
                  <>
                    <div className="mn-tabs" role="tablist">
                      {STAGES.map((s, i) => <button key={s} role="tab" aria-selected={stage === i} className={stage === i ? 'on' : ''} onClick={() => setStage(i)}>{s}</button>)}
                    </div>
                    <div className="mn-list grow">
                      {bizOrders.filter((o) => o.stage === stage).length === 0 && <p className="mn-empty">Sin pedidos</p>}
                      {bizOrders.filter((o) => o.stage === stage).map((o) => (
                        <div key={o.id} className="mn-card mn-order">
                          <div className="mn-orow"><span>{hhmm(o.at)}</span><b>{cop(o.total)}</b></div>
                          <b className="mn-where">{o.mode === 'mesa' ? `Mesa ${o.table}` : o.mode === 'domicilio' ? 'Domicilio' : 'Para llevar'}</b>
                          <hr />
                          {o.lines.map((l) => <div key={l.name} className="mn-oline">{l.q}x {l.name}</div>)}
                          {o.stage < 3 && <button className="mn-outl" onClick={() => advance(o.id)}>Marcar como {STAGES[o.stage + 1]}</button>}
                        </div>
                      ))}
                    </div>
                  </>
                )}
                {tab === 'mesas' && (
                  <div className="mn-list grow">
                    {openTables.length === 0 && <p className="mn-empty">No hay mesas abiertas</p>}
                    {openTables.map((n) => {
                      const os = bizOrders.filter((o) => o.mode === 'mesa' && o.table === n && !o.closed)
                      return (
                        <div key={n} className="mn-card mn-mesa">
                          <div><b>Mesa {n}</b><span>Abierta desde {hhmm(os[0].at)}</span></div>
                          <div className="mn-mright"><b>{cop(os.reduce((s, o) => s + o.total, 0))}</b><button onClick={() => { closeTable(n); toast(`Mesa ${n} cerrada`) }}>Cerrar mesa</button></div>
                        </div>
                      )
                    })}
                  </div>
                )}
                <nav className="mn-nav">
                  {[['pedidos', 'Pedidos', 'receipt'], ['mesas', 'Mesas', 'table']].map(([id, l, ic]) => (
                    <button key={id} className={tab === id ? 'on' : ''} onClick={() => setTab(id)}><span className="pill"><Ic n={ic} /></span>{l}</button>
                  ))}
                </nav>
              </>
            )}
          </div>
          {snack && <div className="mn-snack" role="status">{snack}</div>}
        </div>
      </div>
    </div>
  )
}
