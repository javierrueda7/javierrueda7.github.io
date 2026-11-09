import { useEffect, useRef, useState } from 'react'
import './ambiental.css'

// Proyecto "Vía Ficticia Km 12", documento, hallazgos y normativa citada de forma genérica: todo es inventado o público.
const PROJECT = 'Vía Ficticia Km 12'
const CATS = ['🚫 Edición Pendiente', '📐 Formato', '⚡ Contradicciones', '📋 TdR/Normativa', '🗺️ Contexto', '🔗 Referencias', '✍️ Redacción', '🔤 Ortografía']
const CAT_SHORT = ['Edición Pendiente', 'Formato', 'Contradicciones', 'TdR', 'Contexto', 'Referencias', 'Redacción', 'Ortografía']
const CAT_BTN = ['🚫 Edición Pendiente', '📐 Formato', '⚡ Contradicciones', '📋 TdR', '🗺️ Contexto', '🔗 Referencias', '✍️ Redacción', '🔤 Ortografía']
const PRIO = { blocker: ['Bloqueante', '🚫'], high: ['Alta', '⚠️'], medium: ['Media', 'ℹ️'], low: ['Baja', '📝'] }
const PORD = { blocker: 0, high: 1, medium: 2, low: 3 }

const DOC = [
  { id: 1, ch: 'Capítulo 1. Descripción del proyecto', t: 'El proyecto Vía Ficticia Km 12 consiste en el mejoramiento y ampliación de 12 km de vía existente entre las veredas El Pinar y La Loma, en el municipio ficticio de San Isidro, con ampliación de calzada a 7,3 m y construcción de cuatro alcantarillas de cajón.' },
  { id: 2, ch: 'Capítulo 1. Descripción del proyecto', t: 'La construcción tendrá una duración estimada de 18 meses. El caudal de captación autorizado para el campamento es de [COMPLETAR: caudal en L/s], tomado de la quebrada La Seca.' },
  { id: 3, ch: 'Capítulo 1. Descripción del proyecto', t: 'El material sobrante de excavación se dispondrá en las ZODME definidas en el plano 4, con capacidad total de 38.000 m³.' },
  { id: 4, ch: 'Capítulo 2. Caracterización del área de influencia', t: 'La quebrada La Seca es una fuente de caudal permanente que atraviesa el trazado en el K4+300 y abastece a dos acueductos veredales.' },
  { id: 5, ch: 'Capítulo 2. Caracterización del área de influencia', t: 'En el área de influencia se registraron 42 especies de flora, entre ellas roble y cedro, y 18 especies de fauna, en un mosaico de ecosistémas de bosque seco tropical fragmentado.' },
  { id: 6, ch: 'Capítulo 2. Caracterización del área de influencia', t: 'Tabla 2.1. Precipitación media mensual en la estación de referencia: 85, 102, 140, 210 y 195 mm.' },
  { id: 7, ch: 'Capítulo 3. Demanda de recursos naturales', t: 'Para los 14,5 km de intervención se requerirá aprovechamiento forestal de 3,2 ha, con permiso ante la autoridad ambiental competente.' },
  { id: 8, ch: 'Capítulo 3. Demanda de recursos naturales', t: 'El trámite de licenciamiento se ajusta a lo dispuesto en el Decreto 2820 de 2010, que reglamenta el Título VIII de la Ley 99 de 1993.' },
  { id: 9, ch: 'Capítulo 3. Demanda de recursos naturales', t: 'La compensación por pérdida de biodiversidad se definirá posteriormente con la autoridad ambiental.' },
  { id: 10, ch: 'Capítulo 4. Evaluación ambiental', t: 'El impacto sobre la calidad del agua de la quebrada La Seca, de régimen intermitente, se califica como moderado (cuadro 4.1).' },
  { id: 11, ch: 'Capítulo 4. Evaluación ambiental', t: 'Durante el movimiento de tierras, la sedimentación podría eventualmente afectar la quebrada La Seca, con consecuencias severas sobre los acueductos veredales.' },
  { id: 12, ch: 'Capítulo 4. Evaluación ambiental', t: 'En el área podría haber comunidades étnicas, lo cual será verificado más adelante en el proceso.' },
  { id: 13, ch: 'Capítulo 4. Evaluación ambiental', t: 'Figura 4. Perfil longitudinal del trazado entre el K0+000 y el K12+000.' },
  { id: 14, ch: 'Capítulo 4. Evaluación ambiental', t: 'Figura 6. Localización de las alcantarillas de cajón sobre el trazado.' },
]
const F0 = [
  { id: 'f1', cat: 0, prio: 'blocker', title: 'Dato pendiente de completar en el texto', para: 2, q: '[COMPLETAR: caudal en L/s]', revs: [3], desc: 'El caudal de captación del campamento quedó como marcador de plantilla. Sin ese dato no se puede verificar la concesión de aguas ni la demanda del Capítulo 3.', sug: 'Reemplazar el marcador por el caudal solicitado (L/s) y su fuente de captación, y reflejarlo en la ficha de demanda de recursos.', norm: 'Metodología General para la Elaboración y Presentación de Estudios Ambientales: la demanda de recursos debe cuantificarse (caudal, volumen, fuente) en el capítulo respectivo.' },
  { id: 'f2', cat: 2, prio: 'blocker', title: 'Longitud del proyecto inconsistente (12 km vs 14,5 km)', para: 7, q: '14,5 km', revs: [2, 3], desc: 'El Capítulo 1 describe 12 km de vía y el Capítulo 3 calcula el aprovechamiento forestal sobre 14,5 km de intervención. Una de las dos cifras es errónea y afecta el área de influencia.', sug: 'Unificar la longitud con el diseño vigente y recalcular el área de aprovechamiento forestal y las compensaciones asociadas.', norm: 'La descripción del proyecto es la base de todos los capítulos posteriores; las cifras deben ser coherentes entre capítulos (Términos de Referencia sectoriales).' },
  { id: 'f3', cat: 3, prio: 'high', title: 'Sin certificación sobre presencia de comunidades étnicas', para: 12, q: 'podría haber comunidades étnicas', revs: [1, 2, 3], desc: 'El estudio deja la verificación de comunidades étnicas para después. Los términos de referencia exigen la certificación de presencia o ausencia antes de radicar el estudio.', sug: 'Anexar la certificación de la entidad competente o la solicitud radicada, y ajustar el medio socioeconómico y el cronograma de consulta previa si aplica.', norm: 'Ley 21 de 1991 (Convenio 169 de la OIT) y Decreto 1076 de 2015: la consulta previa procede cuando la autoridad certifica presencia de comunidades étnicas en el área de influencia.' },
  { id: 'f4', cat: 4, prio: 'high', title: 'Régimen de la quebrada La Seca descrito de dos formas', para: 4, q: 'caudal permanente', revs: [3], desc: 'La caracterización la presenta como fuente de caudal permanente y la evaluación (Cap. 4) como de régimen intermitente. Cambia la calificación del impacto y el manejo en época seca.', sug: 'Validar con los aforos de la línea base y corregir en el capítulo que corresponda.', norm: 'La caracterización del medio abiótico (hidrología) debe sustentar el régimen del cuerpo de agua con datos de monitoreo.' },
  { id: 'f5', cat: 5, prio: 'high', title: 'Referencia a una norma derogada', para: 8, q: 'Decreto 2820 de 2010', revs: [2, 3], desc: 'El Decreto 2820 de 2010 fue reemplazado por el Decreto 2041 de 2014, hoy compilado en el Decreto Único Reglamentario del Sector Ambiente (Decreto 1076 de 2015).', sug: 'Citar el Decreto 1076 de 2015 y verificar que los umbrales de licenciamiento usados sean los vigentes.', norm: 'Decreto 1076 de 2015, Título 2, Capítulo 3 (licencias ambientales).' },
  { id: 'f6', cat: 1, prio: 'medium', title: 'Tabla sin fuente ni periodo de registro', para: 6, q: 'Tabla 2.1', revs: [1, 2, 3], desc: 'La tabla de precipitación no indica la estación, la entidad que la opera, el periodo ni las unidades de todos los meses.', sug: 'Agregar pie de tabla con fuente, código de estación y años de registro, e incluir los doce meses.', norm: 'Metodología General: toda información secundaria debe citarse con su fuente y fecha.' },
  { id: 'f7', cat: 6, prio: 'medium', title: 'Redacción ambigua en la evaluación del impacto', para: 11, q: 'podría eventualmente afectar', revs: [2, 3], desc: '«Podría eventualmente afectar» no cuantifica probabilidad ni magnitud y contradice la calificación del cuadro 4.1.', sug: 'Expresar el impacto con la escala de calificación del estudio (intensidad, extensión, duración) y no con adverbios.', norm: 'La evaluación ambiental debe calificar cada impacto con una metodología explícita y reproducible.' },
  { id: 'f8', cat: 2, prio: 'medium', title: 'Calificación del impacto: moderado vs consecuencias severas', para: 10, q: 'moderado', revs: [3], desc: 'El Capítulo 4 califica la afectación del agua como moderada y, dos párrafos después, anuncia consecuencias severas sobre los acueductos veredales.', sug: 'Revisar la calificación con el cuadro 4.1 y conciliar ambos párrafos.', norm: 'Coherencia entre la matriz de evaluación y el texto es requisito de revisión técnica del estudio.' },
  { id: 'f12', cat: 3, prio: 'medium', title: 'Compensación sin factor ni propuesta de áreas', para: 9, q: 'se definirá posteriormente', revs: [1, 2, 3], desc: 'El estudio difiere la compensación biótica. Debe presentar al menos el cálculo del factor y la propuesta de áreas.', sug: 'Incluir la cuantificación del área afectada por ecosistema, el factor de compensación y la propuesta de ubicación.', norm: 'Manual de Compensaciones del Componente Biótico (Resolución 256 de 2018).' },
  { id: 'f9', cat: 7, prio: 'low', title: 'Error de tilde en «ecosistemas»', para: 5, q: 'ecosistémas', revs: [1, 2, 3], desc: '«Ecosistémas» lleva tilde incorrecta; la palabra es llana terminada en -s y no se tilda.', sug: 'Corregir a «ecosistemas».', norm: 'Ortografía de la lengua española (RAE).' },
  { id: 'f10', cat: 1, prio: 'low', title: 'Numeración de figuras con salto', para: 14, q: 'Figura 6', revs: [3], desc: 'Tras la Figura 4 aparece la Figura 6; falta la Figura 5 o hay un error de numeración.', sug: 'Renumerar o agregar la figura faltante y revisar las referencias cruzadas.', norm: 'Formato de presentación de estudios ambientales: figuras y tablas numeradas de forma consecutiva.' },
  { id: 'f11', cat: 6, prio: 'low', title: 'Sigla ZODME sin definir', para: 3, q: 'ZODME', revs: [1, 2, 3], desc: 'La sigla aparece por primera vez sin su significado.', sug: 'Definir en la primera mención: zonas de disposición de material sobrante de excavación (ZODME).', norm: 'Buenas prácticas de redacción técnica: definir siglas en su primera aparición.' },
]
const HIST = [
  { t: 'Falta mapa de localización a escala', revs: [1] }, { t: 'Coordenadas sin sistema de referencia', revs: [1] }, { t: 'Área de influencia sin criterio de delimitación', revs: [1] },
  { t: 'Cronograma sin hitos de obra', revs: [1, 2] }, { t: 'Capítulo 3 sin índice de tablas', revs: [1, 2] }, { t: 'Inventario forestal sin intensidad de muestreo', revs: [2] },
]
const REVS = [{ n: 1, date: '12 de oct de 2026' }, { n: 2, date: '27 de oct de 2026' }, { n: 3, date: '09 de nov de 2026' }]

const FAQ = [
  ['¿Qué proyectos requieren licencia ambiental?', 'lic'],
  ['Contenidos mínimos de un EIA', 'eia'],
  ['¿Cuándo es obligatoria la Consulta Previa?', 'cp'],
  ['Principio de precaución — Ley 99/93', 'prec'],
  ['Plazos de la ANLA para licencias', 'plazo'],
]
const KB = {
  lic: { t: 'Requieren licencia ambiental los proyectos, obras y actividades que enumera el Decreto 1076 de 2015 (que compiló el Decreto 2041 de 2014), de competencia de la ANLA, de las CAR o de los grandes centros urbanos según sector y magnitud. En infraestructura vial, por ejemplo, la construcción o ampliación de carreteras suele requerirla según longitud y categoría. Mi criterio: antes de decidir, contrasta el proyecto con el listado vigente y, si hay dudas, pide concepto a la autoridad.', c: ['Decreto 1076 de 2015', 'Ley 99 de 1993'] },
  eia: { t: 'La Metodología General para la Elaboración y Presentación de Estudios Ambientales (Resolución 1402 de 2018) y los términos de referencia sectoriales piden, en esencia: generalidades, descripción del proyecto, áreas de influencia, caracterización (abiótica, biótica y socioeconómica), demanda de recursos, zonificación ambiental, evaluación ambiental, zonificación de manejo, planes de manejo, seguimiento y contingencia, y compensaciones. Cada capítulo debe sustentarse con fuentes y datos coherentes entre sí.', c: ['Resolución 1402 de 2018', 'Guía de contenido EIA (demo)'] },
  cp: { t: 'La consulta previa procede cuando el proyecto puede afectar directamente a comunidades étnicas. Se parte de una certificación de presencia o ausencia de comunidades en el área de influencia, que expide la autoridad competente. Si hay presencia, el proceso debe agotarse antes de la decisión sobre la licencia. Mi criterio: tramita la certificación al inicio, porque define el cronograma.', c: ['Ley 21 de 1991', 'Decreto 1076 de 2015'] },
  prec: { t: 'La Ley 99 de 1993 recoge entre sus principios generales el de precaución: cuando exista peligro de daño grave e irreversible, la falta de certeza científica absoluta no debe usarse como razón para postergar medidas que impidan la degradación del ambiente. En la práctica, justifica exigir estudios y medidas de manejo más estrictas cuando hay incertidumbre sobre un impacto crítico.', c: ['Ley 99 de 1993, principios generales'] },
  plazo: { t: 'El Decreto 1076 de 2015 fija plazos por etapa del trámite: verificación de documentos, solicitud de información adicional, concepto técnico y decisión de fondo. Los plazos han cambiado con reformas, así que confírmalos en la norma vigente o con la ANLA antes de comprometer fechas con el cliente.', c: ['Decreto 1076 de 2015'] },
}
const kbPick = (q) => {
  const s = q.toLowerCase()
  if (/licen/.test(s)) return 'lic'
  if (/eia|contenido|m[ií]nimo/.test(s)) return 'eia'
  if (/consulta|[eé]tnic/.test(s)) return 'cp'
  if (/precauci|ley 99/.test(s)) return 'prec'
  if (/plazo|anla|tiempo|demora/.test(s)) return 'plazo'
  return null
}

const NAV = [
  ['dash', '🛡️', 'Aseguramiento QA'], ['ctx', '🔔', 'Actualizaciones de Contexto', true], ['docs', '📝', 'Documentos Colaborativos'], ['chat', '🤖', 'Asistente ambiental'], ['gen', '📄', 'Generador de Informes'],
]
const TITLES = { dash: 'Proyectos', review: `Nueva Revisión — ${PROJECT}`, report: `Informe — ${PROJECT}`, ctx: '🔔 Actualizaciones de Contexto', docs: 'Documentos Colaborativos', chat: 'Asistente ambiental', gen: 'Generador de Informes' }

function Logo({ s = 40 }) {
  return (
    <svg width={s} height={s} viewBox="0 0 40 40" aria-hidden="true">
      <path d="M20 3 36 31H4z" fill="#1b5faa" /><path d="M20 3 28 17 12 17z" fill="#0d3460" /><circle cx="11" cy="14" r="4" fill="#f5b800" /><path d="M2 34h36" stroke="#f5b800" strokeWidth="3" />
    </svg>
  )
}
const Badge = ({ k, children }) => <span className={`ab-b ${k}`}>{children}</span>
const dl = (name, text) => {
  try {
    const a = document.createElement('a')
    a.href = URL.createObjectURL(new Blob([text], { type: 'text/plain;charset=utf-8' }))
    a.download = name
    document.body.appendChild(a)
    a.click()
    a.remove()
  } catch { /* sin descarga: no pasa nada */ }
}

/* ---------- público ---------- */
function PubNav({ go }) {
  return (
    <header className="ab-pnav">
      <button className="ab-brand" onClick={() => go('ingresar')}><Logo /><span><b>ESTUDIOS AMBIENTALES DEMO S.A.</b><small>Soluciones ambientales · Colombia</small></span></button>
      <nav>{['Inicio', 'Nosotros', 'Qué hacemos', 'Clientes', 'Experiencia'].map((x) => <a key={x} href="#/ambiental" onClick={(e) => e.preventDefault()}>{x}</a>)}</nav>
      <button className="ab-pill" onClick={() => go('ingresar')}>🤖 Portal IA</button>
      <button className="ab-pill" onClick={() => go('ingresar')}>🔐 Iniciar sesión</button>
    </header>
  )
}
function Privacy() {
  return (
    <div className="ab-priv">
      <div className="ab-draft"><b>BORRADOR — pendiente de revisión legal</b><p>Texto de ejemplo para la demo. Los datos marcados en <mark>amarillo</mark> deben completarse o confirmarse.</p></div>
      <h1>Política de tratamiento de datos personales</h1>
      <p className="ab-sub2">Portal de herramientas de IA de Estudios Ambientales Demo S.A. · Versión borrador 2026-10 · Ley 1581 de 2012, Decreto 1377 de 2013 (compilado en el Decreto 1074 de 2015)</p>
      <h2>1. Responsable del tratamiento</h2>
      <p>Estudios Ambientales Demo S.A., NIT <mark>[completar]</mark>, con sede en una ciudad ficticia. Correo para asuntos de datos personales: <mark>[confirmar]</mark>.</p>
      <h2>2. A quién aplica</h2>
      <p>A las personas que acceden al portal con una cuenta de Google por invitación (colaboradores, contratistas y personal autorizado de clientes) y a las personas cuyos datos aparezcan en los documentos que se suben al portal para su análisis.</p>
      <h2>3. Qué datos tratamos</h2>
      <table><thead><tr><th>Datos</th><th>De dónde vienen</th></tr></thead><tbody>
        <tr><td>Nombre, correo y foto de la cuenta</td><td>Cuenta de Google al iniciar sesión</td></tr>
        <tr><td>Documentos, revisiones y consultas al asistente</td><td>Lo que usted carga o escribe en el portal</td></tr>
      </tbody></table>
    </div>
  )
}

/* ---------- aplicación ---------- */
export default function Ambiental() {
  const [screen, setScreen] = useState('ingresar') // ingresar | priv | consent | app
  const [page, setPage] = useState('dash')
  const [analyzed, setAnalyzed] = useState(false)
  const [prog, setProg] = useState(null)
  const [st, setSt] = useState({})
  const [toast, setToast] = useState('')
  const [dropped, setDropped] = useState(false)
  const tt = useRef(0)
  const flash = (m) => { setToast(m); clearTimeout(tt.current); tt.current = setTimeout(() => setToast(''), 2200) }
  useEffect(() => () => clearTimeout(tt.current), [])
  const findings = analyzed ? F0 : []
  const stOf = (id) => st[id] || 'open'
  const openCount = findings.filter((f) => stOf(f.id) === 'open').length
  const revCount = analyzed ? 3 : 2
  const go = (p) => setPage(p)

  /* progreso simulado de la revisión */
  const run = (files) => {
    setProg({ pct: 0, msg: 'Leyendo documentos…', files })
    const steps = [[15, 'Leyendo documentos…'], [40, `Analizando ${files[0] || 'capítulos'} con IA…`], [65, 'Cruzando cifras entre capítulos…'], [85, 'Verificando referencias normativas…'], [100, 'Generando informe…']]
    steps.forEach(([pct, msg], i) => setTimeout(() => {
      setProg((p) => (p ? { ...p, pct, msg } : p))
      if (pct === 100) setTimeout(() => { setProg(null); setAnalyzed(true); setSt({}); setPage('report') }, 450)
    }, 500 * (i + 1)))
  }

  let content
  if (screen !== 'app') {
    content = (
      <div className="ab-pub">
        <PubNav go={(s) => setScreen(s)} />
        <div className="ab-pbody">
          {screen === 'ingresar' && (
            <div className="ab-login">
              <h1>Ingresar al portal</h1>
              <p>Acceso solo para personas invitadas. Inicia sesión con tu cuenta de Google para continuar.</p>
              <button className="ab-google" onClick={() => setScreen('consent')}>Continuar con Google</button>
              <hr />
              <small>Estudios Ambientales Demo S.A. tratará tu nombre, correo y foto de Google, y los datos que cargues en el portal, conforme a la <button className="ab-lk" onClick={() => setScreen('priv')}>Política de tratamiento de datos personales</button>. Algunos datos se envían a proveedores de inteligencia artificial y de nube ubicados fuera de Colombia. Después de ingresar se te pedirá aceptar la política. Puedes pedir la supresión de tus datos escribiendo al contacto indicado en ella.</small>
            </div>
          )}
          {screen === 'priv' && <Privacy />}
          {screen === 'consent' && <Consent onOk={() => { setScreen('app'); setPage('dash') }} onPriv={() => setScreen('priv')} />}
        </div>
      </div>
    )
  } else {
    content = (
      <div className="ab-app">
        <aside className="ab-side">
          <div className="ab-sl"><Logo s={34} /><span><b>Herramientas ambientales</b><small>Demo</small></span></div>
          <nav>
            <p>Principal</p>
            {NAV.map(([id, ic, lb, sub]) => {
              const on = page === id || (id === 'dash' && (page === 'review' || page === 'report'))
              return <button key={id} className={`${on ? 'on' : ''} ${sub ? 'sub' : ''}`} onClick={() => go(id)}><i>{ic}</i><span>{lb}</span></button>
            })}
          </nav>
          <div className="ab-user"><u>U</u><span><b>Usuario Demo</b><small>Líder de Aseguramiento</small></span><button aria-label="Salir" title="Salir" onClick={() => { setScreen('ingresar'); setPage('dash') }}>⏻</button></div>
        </aside>
        <section className="ab-main">
          <header className="ab-head">
            <h1>{TITLES[page]}</h1>
            <div className="ab-hbtns">
              {page === 'dash' && <><button className="ab-btn" onClick={() => flash('Los drives son simulados en la demo.')}>Escanear drives</button><button className="ab-btn gold" onClick={() => flash('Los drives son simulados en la demo.')}>+ Vincular Drive de Proyecto</button></>}
              {page === 'review' && <button className="ab-btn" onClick={() => go('dash')}>← Volver</button>}
              {page === 'report' && <><button className="ab-btn" onClick={() => go('dash')}>← Dashboard</button><button className="ab-btn" onClick={() => go('review')}>▶ Nueva Revisión</button><button className="ab-btn gold" disabled={!analyzed} onClick={() => dl('informe-via-ficticia-km12.txt', report(findings, st))}>⬇ Informe .txt</button></>}
            </div>
          </header>
          <div className="ab-body">
            {page === 'dash' && <Dash analyzed={analyzed} revCount={revCount} openCount={openCount} dropped={dropped} setDropped={setDropped} go={go} flash={flash} />}
            {page === 'review' && <Review go={go} run={run} prog={prog} />}
            {page === 'report' && <Report findings={findings} st={st} setSt={setSt} stOf={stOf} go={go} flash={flash} />}
            {page === 'ctx' && <Ctx />}
            {page === 'docs' && <Docs flash={flash} />}
            {page === 'chat' && <Chat />}
            {page === 'gen' && <Gen flash={flash} />}
          </div>
        </section>
      </div>
    )
  }
  return <div className="ab">{content}{toast && <div className="ab-toast" role="status">{toast}</div>}</div>
}

function report(findings, st) {
  const out = [`INFORME DE REVISIÓN — ${PROJECT}`, 'Revisión 3 · 09 de nov de 2026', 'Generado con asistencia de IA: complementa, no reemplaza, la revisión profesional.', '']
  const open = findings.filter((f) => (st[f.id] || 'open') === 'open')
  out.push(`Hallazgos: ${findings.length} · abiertos: ${open.length} · resueltos: ${findings.filter((f) => st[f.id] === 'resolved').length} · ignorados: ${findings.filter((f) => st[f.id] === 'ignored').length}`, '')
  ;[...findings].sort((a, b) => PORD[a.prio] - PORD[b.prio]).forEach((f, i) => {
    const p = DOC.find((d) => d.id === f.para)
    out.push(`${i + 1}. [${PRIO[f.prio][0].toUpperCase()}] ${f.title}`, `   Categoría: ${CAT_SHORT[f.cat]} · Estado: ${{ open: 'Abierto', resolved: 'Resuelto', ignored: 'Ignorado' }[st[f.id] || 'open']}`, `   Ubicación: ${p.ch}`, `   ${f.desc}`, `   Sugerencia: ${f.sug}`, `   Norma de referencia: ${f.norm}`, '')
  })
  return out.join('\n')
}

function Consent({ onOk, onPriv }) {
  const [ok, setOk] = useState(false)
  return (
    <div className="ab-consent">
      <h1>Autorización de tratamiento de datos</h1>
      <p>Antes de usar el portal necesitamos tu autorización para tratar tus datos personales. En resumen:</p>
      <ul>
        <li><b>Qué datos:</b> nombre, correo y foto de tu cuenta de Google, y lo que hagas en el portal (documentos, revisiones, consultas al asistente).</li>
        <li><b>Para qué:</b> darte acceso, controlar quién ve cada proyecto y operar las herramientas de revisión y el asistente.</li>
        <li><b>Inteligencia artificial:</b> lo que consultes o cargues puede enviarse a proveedores de IA y nube fuera de Colombia. Las respuestas pueden tener errores: verifica lo importante. No subas datos personales sensibles ni de menores sin autorización.</li>
        <li><b>Tus derechos:</b> conocer, actualizar, rectificar y pedir la supresión de tus datos, y revocar esta autorización.</li>
      </ul>
      <p>El texto completo está en la <button className="ab-lk" onClick={onPriv}>Política de tratamiento de datos personales</button>.</p>
      <label className="ab-chk"><input type="checkbox" checked={ok} onChange={(e) => setOk(e.target.checked)} /><span>He leído y acepto la Política de tratamiento de datos personales (versión borrador 2026-10).</span></label>
      <button className="ab-accept" disabled={!ok} onClick={onOk}>Aceptar y continuar</button>
    </div>
  )
}

/* ---------- dashboard ---------- */
const PROJECTS = [
  { n: PROJECT, d: 'Estudio de Impacto Ambiental – Vía Ficticia Km 12', c: 'Concesión Ejemplo A', s: ['En curso', 'blue'], p: 62, dr: 'drv-demo-001', live: true },
  { n: 'Puente Río Seco', d: 'Plan de Manejo Ambiental – Puente Río Seco', c: 'Cliente Ejemplo B', s: ['Alerta', 'amber'], p: 35, dr: 'drv-demo-002' },
  { n: 'Parque Solar Demo', d: 'Estudio de Impacto Ambiental – Parque Solar Demo', c: 'Cliente Ejemplo C', s: ['Completado', 'green'], p: 100, dr: 'drv-demo-003' },
  { n: 'Línea de transmisión Demo', d: 'Seguimiento gerencial', c: 'Cliente Ejemplo D', s: ['Crítico', 'red'], p: 18, dr: '— (solo gerencial)', gerencial: true },
]
function Dash({ analyzed, revCount, openCount, dropped, setDropped, go, flash }) {
  const [q, setQ] = useState('')
  const list = PROJECTS.filter((p) => !(dropped && p.gerencial) && `${p.n} ${p.c} ${p.d}`.toLowerCase().includes(q.toLowerCase()))
  const stat = [['Proyectos activos', dropped ? 3 : 4, 'en todos los drives'], ['Total revisiones', 10 + revCount, 'incrementales + completas'], ['Hallazgos abiertos', 24 + openCount, 'sin resolver']]
  return (
    <>
      <div className="ab-stats">
        {stat.map(([l, v, s]) => <div key={l} className="ab-card ab-stat"><small>{l}</small><b>{v}</b><span>{s}</span></div>)}
        <div className="ab-card ab-stat"><small>Drive corporativo</small><b className="ok">✓ Activo</b><span>Drive Corporativo Demo</span></div>
      </div>
      <div className="ab-card">
        <div className="ab-ch"><h2>📁 Mis Proyectos</h2><button className="ab-btn sm" onClick={() => flash('El registro manual no está en la demo.')}>+ Registrar manualmente</button><input className="ab-q" placeholder="Buscar proyecto…" value={q} onChange={(e) => setQ(e.target.value)} aria-label="Buscar proyecto" /></div>
        <div className="ab-tw"><table>
          <thead><tr><th>Proyecto</th><th>Cliente</th><th>Estado</th><th>Avance</th><th>Drive</th><th>Acciones</th></tr></thead>
          <tbody>
            {list.map((p) => (
              <tr key={p.n}>
                <td><b>{p.n}</b><small>{p.d}</small></td><td className="mu">{p.c}</td>
                <td><Badge k={p.s[1]}>{p.s[0]}</Badge></td>
                <td><span className="ab-bar"><i style={{ width: `${p.p}%` }} /></span><em>{p.p}%</em></td>
                <td className="mu sm">{p.dr}</td>
                <td className="ac">
                  {!p.gerencial && <button className="ab-btn gold sm" onClick={() => (p.live ? go('review') : flash('Proyecto de ejemplo: la demo solo revisa Vía Ficticia Km 12.'))}>▶ Revisar</button>}
                  {!p.gerencial && <button className="ab-btn sm" onClick={() => (p.live ? go('report') : flash('Proyecto de ejemplo: la demo solo revisa Vía Ficticia Km 12.'))}>📊 Informe</button>}
                  <button className="ab-btn red sm" onClick={() => (p.gerencial ? setDropped(true) : flash('En la demo solo puede desvincular el proyecto gerencial.'))}>🗑 Desvincular</button>
                </td>
              </tr>
            ))}
            {list.length === 0 && <tr><td colSpan="6" className="ab-none">Sin proyectos que coincidan.</td></tr>}
          </tbody>
        </table></div>
      </div>
      <div className="ab-card">
        <div className="ab-ch"><h2>💲 Uso y costo de IA (mes en curso)</h2></div>
        <p className="ab-hint">Costo estimado con tarifas de referencia (no es la factura del proveedor). Sirve para repartir el gasto por proyecto.</p>
        <p className="ab-cost"><b>US$ {analyzed ? '14,52' : '11,90'}</b> · {analyzed ? 128 : 104} llamadas</p>
      </div>
    </>
  )
}

/* ---------- nueva revisión ---------- */
const FILES = ['Capítulo 1. Descripción del proyecto.docx', 'Capítulo 2. Caracterización.docx', 'Capítulo 3. Demanda de recursos.docx', 'Capítulo 4. Evaluación ambiental.docx']
function Review({ go, run, prog }) {
  const [mode, setMode] = useState('inc')
  const [open, setOpen] = useState({ cap: true })
  const [sel, setSel] = useState(new Set())
  const M = [['inc', '🔄', 'Incremental', 'Solo archivos nuevos o modificados desde la última revisión.', 'Archivos nuevos/modificados'], ['esp', '🎯', 'Archivos específicos', 'Selecciona manualmente los archivos a revisar.', 'Archivos seleccionados'], ['all', '🔁', 'Revisión completa', 'Reprocesa todos los archivos desde cero.', 'Todos los archivos']]
  const m = M.find((x) => x[0] === mode)
  const files = mode === 'esp' ? FILES.filter((f) => sel.has(f)) : mode === 'inc' ? FILES.slice(0, 2) : FILES
  const tog = (f) => { const n = new Set(sel); n.has(f) ? n.delete(f) : n.add(f); setSel(n) }
  if (prog) {
    return (
      <div className="ab-card ab-prog" role="status">
        <h2>🌿 Analizando con IA…</h2>
        <p>{prog.msg}</p>
        <span className="ab-bar big"><i style={{ width: `${prog.pct}%` }} /></span>
        <small>{prog.pct}% · {prog.files.length} archivo{prog.files.length === 1 ? '' : 's'}</small>
      </div>
    )
  }
  return (
    <div className="ab-two">
      <div className="ab-col">
        <div className="ab-card">
          <div className="ab-ch"><h2>Modo de revisión</h2></div>
          {M.map(([k, ic, t, d]) => <button key={k} className={`ab-mode ${mode === k ? 'on' : ''}`} onClick={() => setMode(k)}><b>{ic} {t}</b><span>{d}</span></button>)}
          <p className="ab-sp">Módulo especial</p>
          <div className="ab-mode gis"><b>🗺️ Revisión Cartográfica (GDB vs Documento)</b><span>Cruza un documento con cartografía en GDB o Shapefile para verificar consistencia geoespacial. No disponible en la demo.</span></div>
        </div>
        <div className="ab-card">
          <div className="ab-ch"><h2>📁 Estructura del proyecto</h2><button className="ab-lk2">🔄 Recargar</button></div>
          <div className="ab-note">Los <Badge k="green">Estándares</Badge> siempre se incluyen como referencia. <Badge k="blue">Referencia</Badge> = no se analiza el contenido, sólo sirve como contexto. <Badge k="green">Contenido</Badge> = se analiza con IA.</div>
          <div className="ab-tree">
            <p><i>▸</i>📁 Estándares <Badge k="gold">Referencia</Badge><em>1 items</em></p>
            <button onClick={() => setOpen({ ...open, cap: !open.cap })}><i>{open.cap ? '▾' : '▸'}</i>📁 Capítulos <Badge k="green">Contenido</Badge><em>4 items</em></button>
            {open.cap && FILES.map((f) => (
              <label key={f} className="ab-file">{mode === 'esp' ? <input type="checkbox" checked={sel.has(f)} onChange={() => tog(f)} /> : <span className="dot" />}📄 {f}</label>
            ))}
            <p className="dim"><i />📁 Versiones <Badge k="gray">Historial</Badge><em>0 items</em></p>
          </div>
        </div>
      </div>
      <div className="ab-col">
        <div className="ab-card">
          <div className="ab-ch"><h2>Selección actual</h2><button className="ab-lk2" onClick={() => { setMode('inc'); setSel(new Set()) }}>Limpiar</button></div>
          <p className="ab-mline">Modo: <b>{m[4]}</b></p>
          <button className="ab-btn gold wide" disabled={mode === 'esp' && files.length === 0} onClick={() => run(files)}>▶ Iniciar Revisión</button>
        </div>
        <div className="ab-card ab-roles">
          <div className="ab-ch"><h2>ℹ️ Roles automáticos</h2></div>
          <p><b>Estándares</b> → Referencia (siempre)</p><p><b>Capítulos</b> → Contenido</p><p><b>Anexos .docx/.pdf</b> → Contenido</p><p><b>Anexos otros</b> → Referencia</p><p><b>Versiones</b> → No se analiza</p>
        </div>
      </div>
    </div>
  )
}

/* ---------- informe ---------- */
function Report({ findings, st, setSt, stOf, go, flash }) {
  const [tab, setTab] = useState('hall')
  const [cat, setCat] = useState('all')
  const [pri, setPri] = useState('all')
  const [stf, setStf] = useState('open')
  const [view, setView] = useState(null)
  const [chat, setChat] = useState(null)
  const [obs, setObs] = useState({})
  const [sent, setSent] = useState({})
  const [cmp, setCmp] = useState([1, 3])
  const blockers = findings.filter((f) => f.prio === 'blocker' && stOf(f.id) === 'open').length
  const shown = findings.filter((f) => (cat === 'all' || f.cat === cat) && (pri === 'all' || f.prio === pri) && (stf === 'all' || stOf(f.id) === stf))
  const groups = {}
  shown.forEach((f) => { const ch = DOC.find((d) => d.id === f.para).ch; (groups[ch] = groups[ch] || []).push(f) })
  const counts = CAT_SHORT.map((_, i) => findings.filter((f) => f.cat === i).length)
  if (!findings.length) {
    return <div className="ab-card ab-vac"><span>📊</span><b>Aún no hay una revisión de este proyecto</b><p>Ejecuta una revisión para que la IA analice el estudio y genere el informe.</p><button className="ab-btn gold" onClick={() => go('review')}>▶ Nueva Revisión</button></div>
  }
  const all = [...F0.map((f) => ({ t: f.title, revs: f.revs })), ...HIST]
  const [a, b] = cmp
  const inA = (x) => x.revs.includes(a), inB = (x) => x.revs.includes(b)
  const nuevos = all.filter((x) => inB(x) && !inA(x)), resu = all.filter((x) => inA(x) && !inB(x)), pers = all.filter((x) => inA(x) && inB(x))
  return (
    <>
      {blockers > 0 && <div className="ab-warn">⚠ Hay {blockers} hallazgo(s) bloqueante(s) sin resolver. Se recomienda resolverlos antes de entregar este informe.</div>}
      <div className="ab-rgrid">
        <div className="ab-card ab-side2"><h2>📁 Proyecto</h2><b>{PROJECT}</b><p>Estudio de Impacto Ambiental – {PROJECT}</p><small>3 revisión(es) • {findings.length} hallazgo(s) total</small></div>
        <div className="ab-card ab-side2"><h2>📊 Por categoría</h2>{CAT_SHORT.map((n, i) => counts[i] > 0 && <p key={n} className="ab-cr"><span>{n}</span><span className="ab-bar"><i style={{ width: `${counts[i] * 25}%` }} /></span><em>{counts[i]}</em></p>)}</div>
      </div>
      <div className="ab-tabs" role="tablist">{[['hall', 'Hallazgos'], ['hist', 'Historial']].map(([k, l]) => <button key={k} role="tab" aria-selected={tab === k} className={tab === k ? 'on' : ''} onClick={() => setTab(k)}>{l}</button>)}</div>
      {tab === 'hall' ? (
        <>
          <div className="ab-ai"><span>ℹ️</span><p><b>Informe generado con asistencia de IA.</b> Su propósito es complementar — no reemplazar — la revisión profesional de cada especialista. La IA puede cometer errores u omitir hallazgos. Se recomienda verificar los hallazgos reportados y continuar con la revisión detallada de cada documento.</p></div>
          <div className="ab-fl"><b>Severidad:</b>{[['all', 'Todas'], ['blocker', '🚫 Bloqueante'], ['high', '⚠️ Alta'], ['medium', 'ℹ️ Media'], ['low', '📝 Baja']].map(([k, l]) => <button key={k} className={pri === k ? 'on' : ''} onClick={() => setPri(k)}>{l}</button>)}</div>
          <div className="ab-fl"><b>Categoría:</b><button className={cat === 'all' ? 'on' : ''} onClick={() => setCat('all')}>Todas</button>{CAT_BTN.map((l, i) => <button key={l} className={cat === i ? 'on' : ''} onClick={() => setCat(i)}>{l}</button>)}</div>
          <div className="ab-fl"><b>Estado:</b>{[['open', 'Abiertos'], ['all', 'Todos'], ['resolved', 'Resueltos'], ['ignored', 'Ignorados']].map(([k, l]) => <button key={k} className={stf === k ? 'on' : ''} onClick={() => setStf(k)}>{l}</button>)}</div>
          {shown.length === 0 && <div className="ab-card ab-vac"><b>No hay hallazgos con estos filtros</b></div>}
          {Object.entries(groups).map(([ch, fs]) => (
            <div key={ch}>
              <h3 className="ab-chap">📄 {ch} <Badge k="blue">{fs.length} hallazgo(s)</Badge></h3>
              {[...fs].sort((x, y) => PORD[x.prio] - PORD[y.prio]).map((f) => (
                <article key={f.id} className={`ab-fc ${f.prio}`} data-sev={f.prio}>
                  <div className="ab-fh"><Badge k={f.prio}>{PRIO[f.prio][1]} {PRIO[f.prio][0]}</Badge><Badge k="blue">{CATS[f.cat]}</Badge><b>{f.title}</b>{stOf(f.id) !== 'open' && <Badge k={stOf(f.id) === 'resolved' ? 'green' : 'gray'}>{stOf(f.id) === 'resolved' ? '✓ Resuelto' : '— Ignorado'}</Badge>}{f.revs.length === 1 && f.revs[0] === 3 && <Badge k="gold">🆕 Nuevo</Badge>}</div>
                  <p className="ab-fm">📍 {f.q.length > 40 ? f.q.slice(0, 40) + '…' : `«${f.q}»`} · 🕐 {REVS[f.revs[0] - 1].date.slice(0, 6)}</p>
                  <p className="ab-fd">{f.desc}</p>
                  <p className="ab-fs">💡 <b>Sugerencia:</b> {f.sug}</p>
                  <div className="ab-fa">
                    {stOf(f.id) === 'open' ? <><button className="ab-btn sm" onClick={() => setSt({ ...st, [f.id]: 'resolved' })}>✓ Marcar resuelto</button><button className="ab-btn ghost sm" onClick={() => setSt({ ...st, [f.id]: 'ignored' })}>— Ignorar</button></> : <button className="ab-btn ghost sm" onClick={() => setSt({ ...st, [f.id]: 'open' })}>↩ Reabrir</button>}
                    <button className="ab-btn ghost sm" onClick={() => setView(f.id)}>📍 Ver en el texto</button>
                    <button className="ab-btn ghost sm" onClick={() => setObs({ ...obs, [f.id]: obs[f.id] === undefined ? '' : undefined })}>📝 Observación</button>
                    <button className="ab-btn ghost sm" onClick={() => setChat(chat === f.id ? null : f.id)}>💬 Preguntar</button>
                  </div>
                  {sent[f.id] && <p className="ab-sentobs">📝 Observación enviada: «{sent[f.id]}»</p>}
                  {obs[f.id] !== undefined && (
                    <div className="ab-obs"><textarea rows="2" placeholder="Escribe tu observación o corrección..." value={obs[f.id]} onChange={(e) => setObs({ ...obs, [f.id]: e.target.value })} /><div><button className="ab-btn gold sm" disabled={!obs[f.id].trim()} onClick={() => { setSent({ ...sent, [f.id]: obs[f.id].trim() }); setObs({ ...obs, [f.id]: undefined }); flash('Observación enviada (simulado).') }}>Enviar observación</button><button className="ab-btn ghost sm" onClick={() => setObs({ ...obs, [f.id]: undefined })}>Cancelar</button></div></div>
                  )}
                  {chat === f.id && <FChat f={f} onClose={() => setChat(null)} />}
                </article>
              ))}
            </div>
          ))}
        </>
      ) : (
        <div className="ab-card ab-hist">
          <div className="ab-ch"><h2>Historial de revisiones</h2></div>
          <table><thead><tr><th>Revisión</th><th>Fecha</th><th>Hallazgos</th><th /></tr></thead><tbody>
            {REVS.map((r) => <tr key={r.n}><td><b>Revisión {r.n}</b></td><td className="mu">{r.date}</td><td>{all.filter((x) => x.revs.includes(r.n)).length}</td><td>{r.n === 3 && <Badge k="blue">Actual</Badge>}</td></tr>)}
          </tbody></table>
          <div className="ab-cmp">
            <h3>Comparar revisiones</h3>
            <div className="ab-cmpsel">
              <label>Desde <select value={a} onChange={(e) => setCmp([+e.target.value, b])}>{REVS.map((r) => <option key={r.n} value={r.n}>Revisión {r.n}</option>)}</select></label>
              <label>Hasta <select value={b} onChange={(e) => setCmp([a, +e.target.value])}>{REVS.map((r) => <option key={r.n} value={r.n}>Revisión {r.n}</option>)}</select></label>
            </div>
            {a === b ? <p className="ab-hint">Elige dos revisiones distintas.</p> : (
              <div className="ab-cmpgrid" data-cmp>
                <div><b className="green" data-k="resueltos">{resu.length}</b><span>Resueltos</span>{resu.map((x) => <small key={x.t}>✓ {x.t}</small>)}</div>
                <div><b className="amber" data-k="persisten">{pers.length}</b><span>Persisten</span>{pers.map((x) => <small key={x.t}>• {x.t}</small>)}</div>
                <div><b className="red" data-k="nuevos">{nuevos.length}</b><span>Nuevos</span>{nuevos.map((x) => <small key={x.t}>🆕 {x.t}</small>)}</div>
              </div>
            )}
          </div>
        </div>
      )}
      {view && <TextView id={view} findings={findings} onClose={() => setView(null)} />}
    </>
  )
}

function FChat({ f, onClose }) {
  const [log, setLog] = useState([{ r: 'ai', t: `Hola, te ayudo con este hallazgo: «${f.title}». ¿Qué quieres saber?` }])
  const [v, setV] = useState('')
  const end = useRef(null)
  useEffect(() => { end.current?.scrollIntoView({ block: 'nearest' }) }, [log])
  const send = (e) => {
    e.preventDefault()
    const q = v.trim()
    if (!q) return
    setV('')
    setLog((l) => [...l, { r: 'me', t: q }])
    const reply = /norma|ley|decreto|resoluci|fundamento/i.test(q) ? `Fundamento de referencia: ${f.norm}` : /c[oó]mo|corregir|arreglar|soluci/i.test(q) ? `Lo corregiría así: ${f.sug}` : `${f.desc} Si quieres, pregúntame por la norma o por cómo corregirlo. (En la demo respondo con un guion.)`
    setTimeout(() => setLog((l) => [...l, { r: 'ai', t: reply }]), 450)
  }
  return (
    <div className="ab-fchat">
      <div className="ab-fchead"><b>💬 Chat con IA — {f.title}</b><button className="ab-btn ghost sm" onClick={onClose}>✕ Cerrar</button></div>
      <div className="ab-msgs">{log.map((m, i) => <p key={i} className={m.r}>{m.t}</p>)}<span ref={end} /></div>
      <form onSubmit={send}><input value={v} onChange={(e) => setV(e.target.value)} placeholder="Escribe tu pregunta aquí..." aria-label="Pregunta sobre el hallazgo" /><button className="ab-btn gold sm">Enviar</button></form>
    </div>
  )
}

function TextView({ id, findings, onClose }) {
  const f = findings.find((x) => x.id === id)
  const ref = useRef(null)
  useEffect(() => { ref.current?.scrollIntoView({ block: 'center' }) }, [id])
  const byPara = {}
  findings.forEach((x) => { (byPara[x.para] = byPara[x.para] || []).push(x) })
  let lastCh = ''
  return (
    <div className="ab-tv" role="dialog" aria-label="Ver en el texto">
      <header><b>Estudio de Impacto Ambiental — {PROJECT}</b><button className="ab-btn ghost sm" onClick={onClose}>✕ Cerrar</button></header>
      <div className="ab-tvbody">
        {DOC.map((p) => {
          const head = p.ch !== lastCh ? <h4 key={`h${p.id}`}>{p.ch}</h4> : null
          lastCh = p.ch
          const here = byPara[p.id] || []
          const cur = here.find((x) => x.id === id)
          let node = p.t
          if (cur) { const i = p.t.indexOf(cur.q); if (i >= 0) node = <>{p.t.slice(0, i)}<mark data-hit>{cur.q}</mark>{p.t.slice(i + cur.q.length)}</> }
          return <div key={p.id}>{head}<p ref={cur ? ref : null} className={`${here.length ? 'has' : ''} ${cur ? 'cur' : ''}`}>{node}</p></div>
        })}
      </div>
      <footer><span className={`ab-b ${f.prio}`}>{PRIO[f.prio][0]}</span> {f.title}</footer>
    </div>
  )
}

/* ---------- actualizaciones de contexto ---------- */
function Ctx() {
  const [f, setF] = useState({ t: '', tipo: 'Normativo', ap: 'Todos los estudios', d: '' })
  const [pend, setPend] = useState([])
  const [ok, setOk] = useState([])
  const set = (k) => (e) => setF({ ...f, [k]: e.target.value })
  return (
    <>
      <div className="ab-card">
        <div className="ab-ch"><h2>+ Proponer nueva actualización</h2></div>
        <p className="ab-hint pad">Describe un cambio normativo, metodológico o de proceso que afecta cómo se desarrollan los estudios ambientales. Una vez aprobado por el Líder de Aseguramiento, la IA lo tendrá en cuenta en todas las revisiones futuras.</p>
        <div className="ab-form3">
          <label>Título <i>*</i><input value={f.t} onChange={set('t')} placeholder="Ej: Nueva resolución sobre línea base hídrica" /></label>
          <label>Tipo <i>*</i><select value={f.tipo} onChange={set('tipo')}><option>Normativo</option><option>Metodológico</option><option>De proceso</option></select></label>
          <label>Aplica a<select value={f.ap} onChange={set('ap')}><option>Todos los estudios</option><option>Solo proyectos viales</option><option>Solo energía</option></select></label>
          <label className="w">Descripción <i>*</i><textarea rows="4" value={f.d} onChange={set('d')} placeholder="Describe el cambio en detalle: qué normativa aplica, qué metodología cambió, cómo afecta la elaboración de los estudios…" /></label>
        </div>
        <div className="ab-right"><button className="ab-btn gold" disabled={!f.t.trim() || !f.d.trim()} onClick={() => { setPend([...pend, { ...f, id: Date.now() }]); setF({ t: '', tipo: 'Normativo', ap: 'Todos los estudios', d: '' }) }}>Enviar propuesta</button></div>
      </div>
      {pend.length > 0 && (
        <div className="ab-card"><div className="ab-ch"><h2>⏳ Propuestas pendientes</h2><span className="ab-cnt">{pend.length}</span></div>
          {pend.map((p) => <div key={p.id} className="ab-pend"><div><b>{p.t}</b><small>{p.tipo} · {p.ap}</small><p>{p.d}</p></div><button className="ab-btn gold sm" onClick={() => { setOk([...ok, p]); setPend(pend.filter((x) => x.id !== p.id)) }}>Aprobar</button></div>)}
        </div>
      )}
      <div className="ab-card"><div className="ab-ch"><h2>✅ Actualizaciones aprobadas y activas</h2><span className="ab-cnt">{ok.length}</span></div>
        {ok.length === 0 ? <p className="ab-none">No hay actualizaciones aprobadas aún.</p> : ok.map((p) => <div key={p.id} className="ab-pend"><div><b>{p.t}</b><small>{p.tipo} · {p.ap}</small><p>{p.d}</p></div><Badge k="green">Activa</Badge></div>)}
      </div>
    </>
  )
}

/* ---------- documentos ---------- */
const DOCS0 = [
  { id: 1, t: 'Informe de avance – Vía Ficticia Km 12', est: 'En revisión', by: 'Usuario Demo', up: '08 de nov de 2026', secs: [['1. Resumen', 'Avance del 62 % en la línea base; pendiente la certificación de comunidades.'], ['2. Actividades del periodo', 'Monitoreos de agua en la quebrada La Seca y jornada de socialización.'], ['3. Pendientes', 'Completar la demanda de recursos del Capítulo 3.']] },
  { id: 2, t: 'Capítulo de línea base (demo)', est: 'Borrador', by: 'Profesional Demo', up: '05 de nov de 2026', secs: [['1. Medio abiótico', ''], ['2. Medio biótico', ''], ['3. Medio socioeconómico', ''], ['4. Paisaje', '']] },
  { id: 3, t: 'Resumen ejecutivo (demo)', est: 'Final', by: 'Usuario Demo', up: '31 de oct de 2026', secs: [['1. Objeto', ''], ['2. Alcance', ''], ['3. Conclusiones', '']] },
]
function Docs({ flash }) {
  const [docs, setDocs] = useState(DOCS0)
  const [cur, setCur] = useState(null)
  const d = docs.find((x) => x.id === cur)
  const upd = (patch) => setDocs((ds) => ds.map((x) => (x.id === cur ? { ...x, ...patch, up: '09 de nov de 2026' } : x)))
  const [col, setCol] = useState({})
  if (!d) {
    return (
      <div className="ab-card">
        <div className="ab-ch"><h2>📝 Mis Documentos</h2><button className="ab-btn gold sm" onClick={() => { const id = Date.now(); setDocs([{ id, t: 'Documento nuevo', est: 'Borrador', by: 'Usuario Demo', up: '09 de nov de 2026', secs: [['1. Introducción', '']] }, ...docs]); setCur(id) }}>+ Nuevo documento</button></div>
        <div className="ab-tw"><table><thead><tr><th>Título</th><th>Secciones</th><th>Estado</th><th>Creado por</th><th>Actualizado</th><th /></tr></thead><tbody>
          {docs.map((x) => <tr key={x.id}><td><b>{x.t}</b></td><td>{x.secs.length}</td><td><Badge k={x.est === 'Final' ? 'gray' : x.est === 'Borrador' ? 'gold' : 'blue'}>{x.est}</Badge></td><td className="mu">{x.by}</td><td className="mu sm">{x.up}</td><td><button className="ab-btn sm" onClick={() => { setCur(x.id); setCol({}) }}>Abrir →</button></td></tr>)}
        </tbody></table></div>
      </div>
    )
  }
  const allCol = d.secs.every((_, i) => col[i])
  return (
    <div className="ab-card">
      <div className="ab-ch ab-wrapb"><button className="ab-btn sm" onClick={() => setCur(null)}>← Volver</button><input className="ab-dt" value={d.t} onChange={(e) => upd({ t: e.target.value })} aria-label="Título del documento" />
        <select value={d.est} onChange={(e) => upd({ est: e.target.value })} aria-label="Estado"><option>Borrador</option><option>En revisión</option><option>Final</option></select></div>
      <div className="ab-dtools">
        <button className="ab-btn sm" onClick={() => upd({ secs: [...d.secs, [`${d.secs.length + 1}. Nueva sección`, '']] })}>+ Agregar sección</button>
        <button className="ab-btn ghost sm" onClick={() => setCol(Object.fromEntries(d.secs.map((_, i) => [i, !allCol])))}>{allCol ? '▼ Expandir todas' : '▶ Colapsar todas'}</button>
        <button className="ab-btn ghost sm" onClick={() => dl('documento.txt', `${d.t}\n\n${d.secs.map(([a, b]) => `${a}\n${b}`).join('\n\n')}`)}>⬇️ Exportar .txt</button>
        <button className="ab-btn ghost sm" onClick={() => flash('La estructura desde TdR usa IA y no está en la demo.')}>🏗️ Generar estructura desde TdR</button>
      </div>
      {d.secs.map(([a, b], i) => (
        <div key={i} className="ab-sec">
          <button onClick={() => setCol({ ...col, [i]: !col[i] })}><i>{col[i] ? '▸' : '▾'}</i>{a}</button>
          {!col[i] && <textarea rows="3" value={b} placeholder="Escribe el contenido de la sección…" onChange={(e) => upd({ secs: d.secs.map((s, j) => (j === i ? [s[0], e.target.value] : s)) })} />}
        </div>
      ))}
    </div>
  )
}

/* ---------- asistente ---------- */
function Chat() {
  const [log, setLog] = useState([])
  const [v, setV] = useState('')
  const [q, setQ] = useState('')
  const [busy, setBusy] = useState(false)
  const end = useRef(null)
  useEffect(() => { end.current?.scrollIntoView({ block: 'end' }) }, [log, busy])
  const docs = ['Decreto 1076 de 2015 (resumen)', 'Resolución 1402 de 2018 (resumen)', 'Guía de contenido EIA (demo)', 'Ley 99 de 1993 (resumen)', 'Manual de compensaciones (resumen)', `Estudio ${PROJECT} (Cap. 1-4)`].filter((d) => d.toLowerCase().includes(q.toLowerCase()))
  const ask = (text) => {
    const t = text.trim()
    if (!t || busy) return
    setV('')
    setLog((l) => [...l, { r: 'me', t }])
    setBusy(true)
    const k = kbPick(t)
    setTimeout(() => {
      setLog((l) => [...l, k ? { r: 'ai', t: KB[k].t, c: KB[k].c } : { r: 'ai', t: 'En esta demo respondo con un guion y solo cubro algunos temas: licencia ambiental, contenidos de un EIA, consulta previa, principio de precaución y plazos de trámite. Prueba con una de las preguntas frecuentes.', c: [] }])
      setBusy(false)
    }, 700)
  }
  return (
    <div className="ab-chat">
      <aside>
        <p className="ab-ct">Documentos indexados</p>
        <input placeholder="Buscar documento…" value={q} onChange={(e) => setQ(e.target.value)} aria-label="Buscar documento" />
        <ul>{docs.map((d) => <li key={d}>📄 {d}</li>)}{docs.length === 0 && <li className="ab-none">Sin resultados</li>}</ul>
        <p className="ab-ct">Preguntas frecuentes</p>
        {FAQ.map(([l]) => <button key={l} className="ab-faq" onClick={() => ask(l)}>{l}</button>)}
        <small>214 fragmentos en base de datos</small>
      </aside>
      <div className="ab-cmain">
        <div className="ab-cscroll">
          {log.length === 0 && <div className="ab-welcome"><span>🌿</span><h2>Consultor Ambiental</h2><p>Soy consultor ambiental senior con más de 20 años en licenciamiento, EIAs y gestión ante la autoridad ambiental. Pregúntame sobre normativa, proyectos, ecosistemas o los documentos indexados — te doy mi criterio técnico, no solo información.</p></div>}
          {log.map((m, i) => <div key={i} className={`ab-msg ${m.r}`}><p>{m.t}</p>{m.c?.length > 0 && <div className="ab-cites">{m.c.map((c) => <span key={c}>📎 {c}</span>)}</div>}</div>)}
          {busy && <div className="ab-msg ai"><p className="ab-dots">Consultando la base normativa…</p></div>}
          <span ref={end} />
        </div>
        <form className="ab-cin" onSubmit={(e) => { e.preventDefault(); ask(v) }}>
          <input value={v} onChange={(e) => setV(e.target.value)} placeholder="¿Qué proyectos requieren licencia ambiental según el Decreto 1076?" aria-label="Pregunta" />
          <button aria-label="Enviar" disabled={!v.trim() || busy}>→</button>
        </form>
        <p className="ab-disc">Asistente con inteligencia artificial: puede equivocarse, verifica lo importante. Lo que escribes se envía a proveedores de IA fuera de Colombia; no incluyas datos personales sensibles ni de terceros.</p>
      </div>
    </div>
  )
}

/* ---------- generador de informes ---------- */
const EX = {
  'Vía terciaria': { tipo: 'EIA', pr: 'Vía terciaria', mun: 'San Isidro', dep: 'Santander', act: 'Mejoramiento de 12 km de vía existente, ampliación de calzada a 7,3 m y cuatro alcantarillas de cajón.', eco: 'Bosque seco tropical fragmentado y pastizales.', agua: 'Quebrada La Seca (K4+300)', cp: 'No aplica' },
  'Granja solar': { tipo: 'EIA', pr: 'Granja solar', mun: 'Villa Clara', dep: 'Cesar', act: 'Instalación de 40 ha de paneles solares y subestación de 34,5 kV.', eco: 'Pastizales y relictos de bosque seco.', agua: 'Caño Seco (1,2 km)', cp: 'En proceso' },
}
function Gen({ flash }) {
  const [f, setF] = useState({ tipo: 'EIA', pr: 'Vía terciaria', mun: '', dep: '', act: '', eco: '', agua: '', cp: 'No aplica' })
  const [out, setOut] = useState('')
  const [busy, setBusy] = useState(false)
  const set = (k) => (e) => setF({ ...f, [k]: e.target.value })
  const filled = ['mun', 'dep', 'act', 'eco', 'agua'].filter((k) => f[k].trim()).length + 2
  const gen = () => {
    setBusy(true)
    setOut('')
    setTimeout(() => {
      setBusy(false)
      setOut(`BORRADOR — ${f.tipo} · ${f.pr}\n\n1. Generalidades\nEl presente ${f.tipo} corresponde al proyecto de tipo «${f.pr}» localizado en el municipio de ${f.mun || '[municipio]'}, departamento de ${f.dep || '[departamento]'}.\n\n2. Descripción del proyecto\n${f.act || '[Describa las actividades principales]'}\n\n3. Caracterización del área de influencia\nEcosistemas: ${f.eco || '[ecosistemas]'}.\nFuentes hídricas cercanas: ${f.agua || '[fuentes hídricas]'}.\n\n4. Participación y consulta previa\nEstado: ${f.cp}. Verificar la certificación de presencia de comunidades étnicas (Ley 21 de 1991; Decreto 1076 de 2015).\n\n5. Marco normativo\nLey 99 de 1993; Decreto 1076 de 2015; Resolución 1402 de 2018 (metodología general para estudios ambientales).\n\nBorrador listo para revisión técnica. Generado con IA: verifique cada dato.`)
    }, 900)
  }
  return (
    <div className="ab-gen">
      <div className="ab-card ab-gl">
        <div className="ab-gh"><h2>Datos del proyecto</h2><small>{filled} campos · borrador listo para revisión técnica</small></div>
        <div className="ab-gbody">
          <p className="ab-lbl">Cargar ejemplo</p>
          <div className="ab-ex">{Object.keys(EX).map((k) => <button key={k} onClick={() => setF({ ...EX[k] })}>{k}</button>)}</div>
          <div className="ab-g2"><label>Tipo de informe<select value={f.tipo} onChange={set('tipo')}><option>EIA</option><option>PMA</option><option>Informe de cumplimiento</option></select></label>
            <label>Tipo de proyecto<select value={f.pr} onChange={set('pr')}><option>Vía terciaria</option><option>Granja solar</option><option>Exploración petrolera</option></select></label>
            <label>Municipio<input value={f.mun} onChange={set('mun')} placeholder="Ej: San Isidro" /></label><label>Departamento<input value={f.dep} onChange={set('dep')} placeholder="Ej: Santander" /></label></div>
          <label className="ab-l1">Actividades principales del proyecto<textarea rows="3" value={f.act} onChange={set('act')} placeholder="Describa las actividades de construcción y operación…" /></label>
          <label className="ab-l1">Ecosistemas y área de influencia<textarea rows="2" value={f.eco} onChange={set('eco')} placeholder="Ej: Bosque seco tropical fragmentado, pastizales…" /></label>
          <label className="ab-l1">Fuentes hídricas cercanas<input value={f.agua} onChange={set('agua')} placeholder="Ej: Quebrada La Seca (K4+300)" /></label>
          <p className="ab-lbl">Consulta previa</p>
          <div className="ab-radios">{['No aplica', 'Requerida', 'En proceso', 'Completada'].map((x) => <label key={x}><input type="radio" name="cp" checked={f.cp === x} onChange={() => setF({ ...f, cp: x })} />{x}</label>)}</div>
          <button className="ab-gbtn" onClick={gen} disabled={busy}>🌿 Generar borrador con IA</button>
        </div>
      </div>
      <div className="ab-card ab-gr">
        <div className="ab-gh r"><h2>Borrador del informe</h2><small>{busy ? 'Generando…' : out ? 'Borrador listo' : 'Esperando datos…'}</small></div>
        <div className="ab-gtools"><button disabled={!out} onClick={() => { try { navigator.clipboard?.writeText(out) } catch { /* sin portapapeles */ } flash('Texto copiado.') }}>Copiar texto</button><button disabled={!out} onClick={() => dl('borrador-informe.txt', out)}>Exportar .txt</button><button onClick={() => setOut('')}>Nuevo informe</button></div>
        {out ? <pre className="ab-draftx">{out}</pre> : <div className="ab-empty"><span>📄</span><p>Complete los datos y presione<br />“Generar borrador”</p></div>}
      </div>
    </div>
  )
}
